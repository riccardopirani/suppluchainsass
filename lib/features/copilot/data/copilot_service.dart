import 'dart:convert';

import 'package:fabricos/config/env.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final copilotServiceProvider = Provider<OperationsCopilotService>((ref) {
  final env = ref.watch(envProvider);
  if (env.openAiApiKey.isNotEmpty) {
    return OpenAiCopilotService(apiKey: env.openAiApiKey);
  }
  return const MockCopilotService();
});

abstract class OperationsCopilotService {
  Future<String> ask(String question, {Map<String, String>? context});
}

/// Deterministic responses for demos and offline dev.
class MockCopilotService implements OperationsCopilotService {
  const MockCopilotService();

  @override
  Future<String> ask(String question, {Map<String, String>? context}) async {
    final q = question.toLowerCase();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (q.contains('delay')) {
      return 'Delays are likely driven by supplier slippage and queue pressure. '
          'Check suppliers with the lowest reliability scores and orders past internal buffer. '
          'FabricOS flags these in Supply and Orders — start with the top 3 by revenue at risk.';
    }
    if (q.contains('machine') && q.contains('attention')) {
      return 'Prioritize machines with risk score > 70% or status warning/stopped. '
          'Open Machines, sort by risk, and create maintenance work orders before the next shift.';
    }
    if (q.contains('inventory') && q.contains('reduce')) {
      return 'Trim SKUs with coverage > 90 days and low turnover. '
          'Use ABC view: freeze buys on C-items until demand confirms, rebalance A-items safety stock.';
    }
    if (q.contains('supplier') && q.contains('risk')) {
      return 'Risky suppliers combine low reliability score, late deliveries, and single-source parts. '
          'Open Suppliers → scorecard, then add a secondary source for parts that hit your top orders.';
    }
    return 'I can help with delays, machine risk, inventory reduction, and supplier exposure. '
        'Try: "Which machine needs attention?" or "What supplier is risky?"';
  }
}

class OpenAiCopilotService implements OperationsCopilotService {
  OpenAiCopilotService({required this.apiKey, http.Client? client})
      : _client = client ?? http.Client();

  final String apiKey;
  final http.Client _client;

  @override
  Future<String> ask(String question, {Map<String, String>? context}) async {
    final buf = StringBuffer();
    if (context != null) {
      for (final e in context.entries) {
        buf.writeln('${e.key}: ${e.value}');
      }
    }
    try {
      final payload = jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are FabricOS Copilot — concise operations advisor for factories. Max 120 words.',
          },
          {
            'role': 'user',
            'content': '${buf.toString().trim()}\n$question',
          },
        ],
      });
      final res = await _client.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: payload,
      );
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        final choices = decoded['choices'] as List<dynamic>?;
        final msg = choices != null && choices.isNotEmpty
            ? (choices.first as Map<String, dynamic>)['message']
                as Map<String, dynamic>?
            : null;
        final content = msg?['content']?.toString();
        if (content != null && content.isNotEmpty) return content;
      }
    } catch (_) {
      // fall through
    }
    return const MockCopilotService().ask(question, context: context);
  }
}
