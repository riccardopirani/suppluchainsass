import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { resolveCompanyTable } from '../_shared/company_table.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });

  const authHeader = req.headers.get('Authorization');
  if (!authHeader) return json({ error: 'Unauthorized' }, 401);

  const admin = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    { auth: { persistSession: false } },
  );

  const authClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    { global: { headers: { Authorization: authHeader } } },
  );

  const { data: { user } } = await authClient.auth.getUser(authHeader.replace('Bearer ', ''));
  if (!user) return json({ error: 'Unauthorized' }, 401);

  try {
    const body = await req.json();
    const { companyId, email, role, fullName } = body as {
      companyId: string;
      email: string;
      role?: string;
      fullName?: string;
    };

    if (!companyId || !email) {
      return json({ error: 'companyId and email are required' }, 400);
    }

    const memberRole = role ?? 'operator';
    if (!['admin', 'manager', 'operator', 'viewer'].includes(memberRole)) {
      return json({ error: 'Invalid role' }, 400);
    }

    const { data: inviter } = await admin
      .from('users')
      .select('company_id, role')
      .eq('id', user.id)
      .single();

    if (!inviter || inviter.company_id !== companyId) {
      return json({ error: 'You do not belong to this company' }, 403);
    }
    if (!['admin', 'manager'].includes(inviter.role)) {
      return json({ error: 'Only admin or manager can invite users' }, 403);
    }

    const companyTable = await resolveCompanyTable(admin);
    const { data: company } = await admin
      .from(companyTable)
      .select('seat_limit')
      .eq('id', companyId)
      .single();

    const seatLimit = company?.seat_limit ?? 10;

    const { count: activeMembers } = await admin
      .from('team_members')
      .select('id', { count: 'exact', head: true })
      .eq('company_id', companyId)
      .in('status', ['active', 'pending']);

    if ((activeMembers ?? 0) >= seatLimit) {
      return json({ error: `Seat limit reached (${seatLimit}). Upgrade your plan to add more users.` }, 403);
    }

    const { data: existing } = await admin
      .from('team_members')
      .select('id, status')
      .eq('company_id', companyId)
      .eq('email', email.toLowerCase())
      .maybeSingle();

    if (existing) {
      return json({ error: 'User already invited or active in this company' }, 409);
    }

    let invitedUserId: string | null = null;

    const { data: existingAuth } = await admin.auth.admin.listUsers();
    const matchedUser = existingAuth?.users?.find(
      (u: { email?: string }) => u.email?.toLowerCase() === email.toLowerCase(),
    );

    if (matchedUser) {
      invitedUserId = matchedUser.id;
    } else {
      const tempPassword = crypto.randomUUID().slice(0, 16);
      const { data: newUser, error: createErr } = await admin.auth.admin.createUser({
        email: email.toLowerCase(),
        password: tempPassword,
        email_confirm: true,
        user_metadata: {
          full_name: fullName ?? '',
          invited_to_company: companyId,
        },
      });
      if (createErr) {
        return json({ error: `Failed to create user: ${createErr.message}` }, 500);
      }
      invitedUserId = newUser?.user?.id ?? null;

      if (invitedUserId) {
        await admin.from('users').upsert({
          id: invitedUserId,
          email: email.toLowerCase(),
          full_name: fullName ?? '',
          role: memberRole,
          company_id: companyId,
        }, { onConflict: 'id' });
      }
    }

    const { data: member, error: memberErr } = await admin
      .from('team_members')
      .insert({
        company_id: companyId,
        user_id: invitedUserId,
        email: email.toLowerCase(),
        role: memberRole,
        status: invitedUserId ? 'active' : 'pending',
        invited_by: user.id,
        joined_at: invitedUserId ? new Date().toISOString() : null,
      })
      .select()
      .single();

    if (memberErr) {
      return json({ error: memberErr.message }, 500);
    }

    if (invitedUserId && !matchedUser) {
      await admin.from('users')
        .update({ company_id: companyId, role: memberRole })
        .eq('id', invitedUserId);
    }

    return json({
      member,
      isNewUser: !matchedUser,
      message: matchedUser
        ? 'Existing user added to company'
        : 'New user created and added to company',
    });
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});
