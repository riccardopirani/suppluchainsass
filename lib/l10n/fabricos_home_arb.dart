import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'fabricos_home_arb_de.dart';
import 'fabricos_home_arb_en.dart';
import 'fabricos_home_arb_es.dart';
import 'fabricos_home_arb_fr.dart';
import 'fabricos_home_arb_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of FabricosHomeArb
/// returned by `FabricosHomeArb.of(context)`.
///
/// Applications need to include `FabricosHomeArb.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/fabricos_home_arb.dart';
///
/// return MaterialApp(
///   localizationsDelegates: FabricosHomeArb.localizationsDelegates,
///   supportedLocales: FabricosHomeArb.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the FabricosHomeArb.supportedLocales
/// property.
abstract class FabricosHomeArb {
  FabricosHomeArb(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static FabricosHomeArb? of(BuildContext context) {
    return Localizations.of<FabricosHomeArb>(context, FabricosHomeArb);
  }

  static const LocalizationsDelegate<FabricosHomeArb> delegate =
      _FabricosHomeArbDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
  ];

  /// No description provided for @home_hero_badge.
  ///
  /// In it, this message translates to:
  /// **'Software MES per il metalmeccanico'**
  String get home_hero_badge;

  /// No description provided for @home_hero_title_line1.
  ///
  /// In it, this message translates to:
  /// **'Fermi macchina, ritardi e stock-out'**
  String get home_hero_title_line1;

  /// No description provided for @home_hero_title_line2.
  ///
  /// In it, this message translates to:
  /// **'costano ogni giorno.'**
  String get home_hero_title_line2;

  /// No description provided for @home_hero_title_accent.
  ///
  /// In it, this message translates to:
  /// **'FabricOS li elimina.'**
  String get home_hero_title_accent;

  /// No description provided for @home_hero_subtitle.
  ///
  /// In it, this message translates to:
  /// **'La piattaforma operativa per aziende manifatturiere da 200 a 500 dipendenti. Controllo in tempo reale su macchine, ordini, fornitori e magazzino — con AI predittiva inclusa. Setup in 15 minuti, nessun IT richiesto.'**
  String get home_hero_subtitle;

  /// No description provided for @home_hero_cta_primary.
  ///
  /// In it, this message translates to:
  /// **'Inizia gratis 30 giorni'**
  String get home_hero_cta_primary;

  /// No description provided for @home_hero_cta_secondary.
  ///
  /// In it, this message translates to:
  /// **'Vedi demo 5 min'**
  String get home_hero_cta_secondary;

  /// No description provided for @home_hero_proof_1.
  ///
  /// In it, this message translates to:
  /// **'Nessuna carta di credito'**
  String get home_hero_proof_1;

  /// No description provided for @home_hero_proof_2.
  ///
  /// In it, this message translates to:
  /// **'Dati reali in 15 minuti'**
  String get home_hero_proof_2;

  /// No description provided for @home_hero_proof_3.
  ///
  /// In it, this message translates to:
  /// **'Cancella quando vuoi'**
  String get home_hero_proof_3;

  /// No description provided for @home_hero_proof_4.
  ///
  /// In it, this message translates to:
  /// **'GDPR compliant EU'**
  String get home_hero_proof_4;

  /// No description provided for @home_pain_eyebrow.
  ///
  /// In it, this message translates to:
  /// **'Il problema'**
  String get home_pain_eyebrow;

  /// No description provided for @home_pain_headline.
  ///
  /// In it, this message translates to:
  /// **'Gestisci ancora la fabbrica con Excel e WhatsApp?'**
  String get home_pain_headline;

  /// No description provided for @home_pain_subtitle.
  ///
  /// In it, this message translates to:
  /// **'Il 54% degli stabilimenti manifatturieri usa ancora fogli Excel e carta. Il costo di questa inefficienza si accumula silenziosamente ogni giorno — finché non è troppo tardi.'**
  String get home_pain_subtitle;

  /// No description provided for @home_pain_card1_title.
  ///
  /// In it, this message translates to:
  /// **'Fermo macchina non pianificato'**
  String get home_pain_card1_title;

  /// No description provided for @home_pain_card1_desc.
  ///
  /// In it, this message translates to:
  /// **'Un guasto non previsto costa €2.000–15.000 all\'ora di produzione ferma. Senza dati predittivi, scopri il problema quando è già tardi.'**
  String get home_pain_card1_desc;

  /// No description provided for @home_pain_card2_title.
  ///
  /// In it, this message translates to:
  /// **'Stock-out e ritardi consegne'**
  String get home_pain_card2_title;

  /// No description provided for @home_pain_card2_desc.
  ///
  /// In it, this message translates to:
  /// **'Senza visibilità in tempo reale su magazzino e fornitori, gli stock-out arrivano a sorpresa. E il cliente riceve la telefonata che nessuno vuole fare.'**
  String get home_pain_card2_desc;

  /// No description provided for @home_pain_card3_title.
  ///
  /// In it, this message translates to:
  /// **'Zero visibilità per la direzione'**
  String get home_pain_card3_title;

  /// No description provided for @home_pain_card3_desc.
  ///
  /// In it, this message translates to:
  /// **'Il direttore chiede i KPI operativi. L\'ufficio raccoglie dati da tre Excel diversi per 2 ore. Il report è già vecchio quando arriva.'**
  String get home_pain_card3_desc;

  /// No description provided for @home_pain_card4_title.
  ///
  /// In it, this message translates to:
  /// **'Fornitori fuori controllo'**
  String get home_pain_card4_title;

  /// No description provided for @home_pain_card4_desc.
  ///
  /// In it, this message translates to:
  /// **'Ritardi di consegna, qualità variabile, nessun sistema per monitorare i rischi. Ogni problema fornitore è una sorpresa gestita in emergenza.'**
  String get home_pain_card4_desc;

  /// No description provided for @home_stats_eyebrow.
  ///
  /// In it, this message translates to:
  /// **'I numeri del problema'**
  String get home_stats_eyebrow;

  /// No description provided for @home_stats_1_value.
  ///
  /// In it, this message translates to:
  /// **'54%'**
  String get home_stats_1_value;

  /// No description provided for @home_stats_1_label.
  ///
  /// In it, this message translates to:
  /// **'delle fabbriche usa ancora carta ed Excel'**
  String get home_stats_1_label;

  /// No description provided for @home_stats_1_source.
  ///
  /// In it, this message translates to:
  /// **'IoT Analytics, 2024'**
  String get home_stats_1_source;

  /// No description provided for @home_stats_2_value.
  ///
  /// In it, this message translates to:
  /// **'€15K'**
  String get home_stats_2_value;

  /// No description provided for @home_stats_2_label.
  ///
  /// In it, this message translates to:
  /// **'costo orario medio fermo macchina non pianificato'**
  String get home_stats_2_label;

  /// No description provided for @home_stats_2_source.
  ///
  /// In it, this message translates to:
  /// **'benchmark settore'**
  String get home_stats_2_source;

  /// No description provided for @home_stats_3_value.
  ///
  /// In it, this message translates to:
  /// **'8%'**
  String get home_stats_3_value;

  /// No description provided for @home_stats_3_label.
  ///
  /// In it, this message translates to:
  /// **'delle PMI manifatturiere ha un MES commerciale oggi'**
  String get home_stats_3_label;

  /// No description provided for @home_stats_3_source.
  ///
  /// In it, this message translates to:
  /// **'IoT Analytics, 2024'**
  String get home_stats_3_source;

  /// No description provided for @home_solution_eyebrow.
  ///
  /// In it, this message translates to:
  /// **'La soluzione'**
  String get home_solution_eyebrow;

  /// No description provided for @home_solution_headline.
  ///
  /// In it, this message translates to:
  /// **'Un\'unica piattaforma per controllare tutta la fabbrica — in tempo reale'**
  String get home_solution_headline;

  /// No description provided for @home_solution_subtitle.
  ///
  /// In it, this message translates to:
  /// **'FabricOS collega macchine, ordini, magazzino e fornitori in un\'unica dashboard operativa. Il tuo team vede tutto. La direzione decide in secondi, non in ore.'**
  String get home_solution_subtitle;

  /// No description provided for @home_module_1_name.
  ///
  /// In it, this message translates to:
  /// **'Macchine e manutenzione'**
  String get home_module_1_name;

  /// No description provided for @home_module_1_desc.
  ///
  /// In it, this message translates to:
  /// **'Stato in tempo reale, log manutenzioni e AI predittiva che anticipa i guasti prima che accadano. Fine alle emergenze notturne.'**
  String get home_module_1_desc;

  /// No description provided for @home_module_1_badge.
  ///
  /// In it, this message translates to:
  /// **'AI inclusa'**
  String get home_module_1_badge;

  /// No description provided for @home_module_2_name.
  ///
  /// In it, this message translates to:
  /// **'Supply chain e inventario'**
  String get home_module_2_name;

  /// No description provided for @home_module_2_desc.
  ///
  /// In it, this message translates to:
  /// **'Soglie di sicurezza automatiche, riordino suggerito dall\'AI e simulazioni what-if per non restare mai a secco nei momenti critici.'**
  String get home_module_2_desc;

  /// No description provided for @home_module_2_badge.
  ///
  /// In it, this message translates to:
  /// **'Auto-riordino'**
  String get home_module_2_badge;

  /// No description provided for @home_module_3_name.
  ///
  /// In it, this message translates to:
  /// **'Ordini e fornitori'**
  String get home_module_3_name;

  /// No description provided for @home_module_3_desc.
  ///
  /// In it, this message translates to:
  /// **'Monitoraggio ritardi, analisi rischio fornitore e alert automatici. Sai sempre chi sta per deluderti — prima che succeda.'**
  String get home_module_3_desc;

  /// No description provided for @home_module_3_badge.
  ///
  /// In it, this message translates to:
  /// **'Risk scoring'**
  String get home_module_3_badge;

  /// No description provided for @home_module_4_name.
  ///
  /// In it, this message translates to:
  /// **'Report per la direzione'**
  String get home_module_4_name;

  /// No description provided for @home_module_4_desc.
  ///
  /// In it, this message translates to:
  /// **'Dashboard CEO, report ESG e export PDF pronti in un clic. La riunione del lunedì mattina cambia per sempre.'**
  String get home_module_4_desc;

  /// No description provided for @home_module_4_badge.
  ///
  /// In it, this message translates to:
  /// **'PDF automatico'**
  String get home_module_4_badge;

  /// No description provided for @home_ai_eyebrow.
  ///
  /// In it, this message translates to:
  /// **'AI predittiva'**
  String get home_ai_eyebrow;

  /// No description provided for @home_ai_headline.
  ///
  /// In it, this message translates to:
  /// **'La fabbrica che si autogestisce è già possibile'**
  String get home_ai_headline;

  /// No description provided for @home_ai_desc.
  ///
  /// In it, this message translates to:
  /// **'L\'AI Copilot di FabricOS monitora continuamente macchine, scorte e fornitori. Quando rileva un rischio, non aspetta che tu lo scopra — ti avvisa e ti suggerisce l\'azione.'**
  String get home_ai_desc;

  /// No description provided for @home_ai_point_1.
  ///
  /// In it, this message translates to:
  /// **'Predizione rischio guasto per ogni macchina, aggiornata ogni ora'**
  String get home_ai_point_1;

  /// No description provided for @home_ai_point_2.
  ///
  /// In it, this message translates to:
  /// **'Forecasting domanda basato su storico ordini e stagionalità'**
  String get home_ai_point_2;

  /// No description provided for @home_ai_point_3.
  ///
  /// In it, this message translates to:
  /// **'Suggerimenti riordino automatici prima dello stock-out'**
  String get home_ai_point_3;

  /// No description provided for @home_ai_point_4.
  ///
  /// In it, this message translates to:
  /// **'Analisi rischio fornitori con score aggiornato in tempo reale'**
  String get home_ai_point_4;

  /// No description provided for @home_ai_point_5.
  ///
  /// In it, this message translates to:
  /// **'Copilot testuale: fai una domanda, ottieni risposta dai tuoi dati'**
  String get home_ai_point_5;

  /// No description provided for @home_ai_alert_machine.
  ///
  /// In it, this message translates to:
  /// **'Centro di lavoro CNC-04'**
  String get home_ai_alert_machine;

  /// No description provided for @home_ai_alert_desc.
  ///
  /// In it, this message translates to:
  /// **'Rischio guasto nelle prossime 72h — anomalia vibrazione rilevata. Manutenzione preventiva consigliata entro martedì.'**
  String get home_ai_alert_desc;

  /// No description provided for @home_ai_alert_time.
  ///
  /// In it, this message translates to:
  /// **'2 min fa · Manutenzione predittiva'**
  String get home_ai_alert_time;

  /// No description provided for @home_ai_suggestion_label.
  ///
  /// In it, this message translates to:
  /// **'Azione consigliata'**
  String get home_ai_suggestion_label;

  /// No description provided for @home_ai_suggestion_desc.
  ///
  /// In it, this message translates to:
  /// **'Pianifica intervento tecnico martedì 09:00. Parti di ricambio disponibili in magazzino (cod. MT-2291). Tempo stimato: 2h.'**
  String get home_ai_suggestion_desc;

  /// No description provided for @home_pricing_eyebrow.
  ///
  /// In it, this message translates to:
  /// **'Prezzi'**
  String get home_pricing_eyebrow;

  /// No description provided for @home_pricing_headline.
  ///
  /// In it, this message translates to:
  /// **'Scegli il piano. Cancella quando vuoi.'**
  String get home_pricing_headline;

  /// No description provided for @home_pricing_subtitle.
  ///
  /// In it, this message translates to:
  /// **'Nessun costo di implementazione. Nessun consulente SAP. Nessuna sorpresa in fattura. Solo un canone mensile fisso, tutto incluso.'**
  String get home_pricing_subtitle;

  /// No description provided for @home_pricing_disclaimer.
  ///
  /// In it, this message translates to:
  /// **'Confronto: SAP Digital Manufacturing parte da €200.000/anno con 18 mesi di implementazione. FabricOS Professionale è operativo in 15 minuti.'**
  String get home_pricing_disclaimer;

  /// No description provided for @home_plan_1_name.
  ///
  /// In it, this message translates to:
  /// **'Essenziale'**
  String get home_plan_1_name;

  /// No description provided for @home_plan_1_price.
  ///
  /// In it, this message translates to:
  /// **'€790'**
  String get home_plan_1_price;

  /// No description provided for @home_plan_1_period.
  ///
  /// In it, this message translates to:
  /// **'/mese'**
  String get home_plan_1_period;

  /// No description provided for @home_plan_1_annual.
  ///
  /// In it, this message translates to:
  /// **'€9.480/anno · 1 sito'**
  String get home_plan_1_annual;

  /// No description provided for @home_plan_1_cta.
  ///
  /// In it, this message translates to:
  /// **'Inizia gratis'**
  String get home_plan_1_cta;

  /// No description provided for @home_plan_2_name.
  ///
  /// In it, this message translates to:
  /// **'Professionale'**
  String get home_plan_2_name;

  /// No description provided for @home_plan_2_badge.
  ///
  /// In it, this message translates to:
  /// **'Più scelto'**
  String get home_plan_2_badge;

  /// No description provided for @home_plan_2_price.
  ///
  /// In it, this message translates to:
  /// **'€1.690'**
  String get home_plan_2_price;

  /// No description provided for @home_plan_2_period.
  ///
  /// In it, this message translates to:
  /// **'/mese'**
  String get home_plan_2_period;

  /// No description provided for @home_plan_2_annual.
  ///
  /// In it, this message translates to:
  /// **'€20.280/anno · fino a 3 siti'**
  String get home_plan_2_annual;

  /// No description provided for @home_plan_2_cta.
  ///
  /// In it, this message translates to:
  /// **'Inizia gratis'**
  String get home_plan_2_cta;

  /// No description provided for @home_plan_3_name.
  ///
  /// In it, this message translates to:
  /// **'Industriale'**
  String get home_plan_3_name;

  /// No description provided for @home_plan_3_price.
  ///
  /// In it, this message translates to:
  /// **'€3.490'**
  String get home_plan_3_price;

  /// No description provided for @home_plan_3_period.
  ///
  /// In it, this message translates to:
  /// **'/mese'**
  String get home_plan_3_period;

  /// No description provided for @home_plan_3_annual.
  ///
  /// In it, this message translates to:
  /// **'€41.880/anno · siti illimitati'**
  String get home_plan_3_annual;

  /// No description provided for @home_plan_3_cta.
  ///
  /// In it, this message translates to:
  /// **'Contattaci'**
  String get home_plan_3_cta;

  /// No description provided for @home_faq_headline.
  ///
  /// In it, this message translates to:
  /// **'Le domande che si fanno tutti prima di comprare'**
  String get home_faq_headline;

  /// No description provided for @home_faq_1_q.
  ///
  /// In it, this message translates to:
  /// **'Il nostro IT non ha tempo per un\'implementazione.'**
  String get home_faq_1_q;

  /// No description provided for @home_faq_1_a.
  ///
  /// In it, this message translates to:
  /// **'Non serve IT. FabricOS è un\'applicazione web e mobile — accedi con il browser, configuri l\'azienda in 15 minuti con la procedura guidata. Nessun server, nessuna installazione, nessun progetto.'**
  String get home_faq_1_a;

  /// No description provided for @home_faq_2_q.
  ///
  /// In it, this message translates to:
  /// **'Usiamo già un gestionale. Si integra?'**
  String get home_faq_2_q;

  /// No description provided for @home_faq_2_a.
  ///
  /// In it, this message translates to:
  /// **'Il piano Industriale include API aperte e connettori per i principali ERP (SAP Business One, Odoo, Zucchetti, Teamsystem). I piani inferiori funzionano in autonomia con import/export dati.'**
  String get home_faq_2_a;

  /// No description provided for @home_faq_3_q.
  ///
  /// In it, this message translates to:
  /// **'I nostri operatori non usano il computer.'**
  String get home_faq_3_q;

  /// No description provided for @home_faq_3_a.
  ///
  /// In it, this message translates to:
  /// **'FabricOS ha un\'app iOS e Android ottimizzata per uso in officina. Un capo reparto può vedere lo stato delle macchine, registrare un intervento e rispondere a un alert direttamente dallo smartphone — in 30 secondi.'**
  String get home_faq_3_a;

  /// No description provided for @home_faq_4_q.
  ///
  /// In it, this message translates to:
  /// **'Come facciamo a sapere che i dati sono al sicuro?'**
  String get home_faq_4_q;

  /// No description provided for @home_faq_4_a.
  ///
  /// In it, this message translates to:
  /// **'Infrastruttura su datacenter europei (UE), GDPR compliant by design, crittografia end-to-end, backup automatici giornalieri. I tuoi dati non lasciano mai l\'Europa.'**
  String get home_faq_4_a;

  /// No description provided for @home_testi_headline.
  ///
  /// In it, this message translates to:
  /// **'Chi ha già smesso di usare Excel in fabbrica'**
  String get home_testi_headline;

  /// No description provided for @home_testi_1_text.
  ///
  /// In it, this message translates to:
  /// **'In 3 mesi abbiamo ridotto i fermi macchina del 31%. L\'AI ci ha avvisato di un problema al tornio CNC una settimana prima che si rompesse. Abbiamo evitato 4 giorni di produzione ferma.'**
  String get home_testi_1_text;

  /// No description provided for @home_testi_1_name.
  ///
  /// In it, this message translates to:
  /// **'Marco R.'**
  String get home_testi_1_name;

  /// No description provided for @home_testi_1_role.
  ///
  /// In it, this message translates to:
  /// **'Direttore Produzione · Officina meccanica, 280 dip.'**
  String get home_testi_1_role;

  /// No description provided for @home_testi_2_text.
  ///
  /// In it, this message translates to:
  /// **'Il lunedì mattina il CEO ha già il report operativo sul telefono. Prima impiegavamo 3 ore per raccogliere i dati da diversi fogli. Ora ci vuole un clic.'**
  String get home_testi_2_text;

  /// No description provided for @home_testi_2_name.
  ///
  /// In it, this message translates to:
  /// **'Sara B.'**
  String get home_testi_2_name;

  /// No description provided for @home_testi_2_role.
  ///
  /// In it, this message translates to:
  /// **'Operations Manager · Componentistica, 340 dip.'**
  String get home_testi_2_role;

  /// No description provided for @home_cta_final_headline.
  ///
  /// In it, this message translates to:
  /// **'Quanti fermi macchina ti puoi ancora permettere?'**
  String get home_cta_final_headline;

  /// No description provided for @home_cta_final_subtitle.
  ///
  /// In it, this message translates to:
  /// **'Ogni giorno senza visibilità operativa è un costo nascosto. Inizia la prova gratuita di 30 giorni — nessuna carta di credito, cancella quando vuoi.'**
  String get home_cta_final_subtitle;

  /// No description provided for @home_cta_final_primary.
  ///
  /// In it, this message translates to:
  /// **'Inizia gratis — 30 giorni'**
  String get home_cta_final_primary;

  /// No description provided for @home_cta_final_secondary.
  ///
  /// In it, this message translates to:
  /// **'Parla con un esperto'**
  String get home_cta_final_secondary;

  /// No description provided for @home_cta_final_proof.
  ///
  /// In it, this message translates to:
  /// **'Setup in 15 minuti · Nessun IT richiesto · GDPR EU · Cancella quando vuoi'**
  String get home_cta_final_proof;
}

class _FabricosHomeArbDelegate extends LocalizationsDelegate<FabricosHomeArb> {
  const _FabricosHomeArbDelegate();

  @override
  Future<FabricosHomeArb> load(Locale locale) {
    return SynchronousFuture<FabricosHomeArb>(lookupFabricosHomeArb(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_FabricosHomeArbDelegate old) => false;
}

FabricosHomeArb lookupFabricosHomeArb(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return FabricosHomeArbDe();
    case 'en':
      return FabricosHomeArbEn();
    case 'es':
      return FabricosHomeArbEs();
    case 'fr':
      return FabricosHomeArbFr();
    case 'it':
      return FabricosHomeArbIt();
  }

  throw FlutterError(
    'FabricosHomeArb.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
