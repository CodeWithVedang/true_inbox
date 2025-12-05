import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/sms_provider.dart';
import '../widgets/message_card.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/otp_alert_card.dart';
import 'settings_screen.dart';
import 'security_center_screen.dart';
import 'analytics_screen.dart';
import 'reminders_screen.dart';
import 'financial_insights_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialise provider after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SmsProvider>().init();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final smsProvider = context.watch<SmsProvider>();
    final color = Theme.of(context).colorScheme;

    // Safely get lists
    final filtered = smsProvider.filteredMessages;
    final all = smsProvider.allMessages;

    // Choose which messages to show:
    final messagesToShow =
        filtered.isNotEmpty ? filtered : all;
    final hasAnyMessages = messagesToShow.isNotEmpty;

    // Determine loading states
    final isLoading = smsProvider.isLoading;
    final showSkeleton =
        isLoading &&
        !hasAnyMessages &&
        smsProvider.permissionStatus !=
            SmsPermissionStatus.denied;
    final showMainLoadingOverlay =
        isLoading && hasAnyMessages;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TrueInbox'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Analytics',
            icon: const Icon(Icons.insights_rounded),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AnalyticsScreen.routeName,
              );
            },
          ),
          IconButton(
            tooltip: 'Security Center',
            icon: const Icon(Icons.shield_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const SecurityCenterScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () =>
                Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const SettingsScreen(),
            )),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () => smsProvider.loadMessages(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  // ---------- TOP 4 BOXES DASHBOARD ----------
                  _QuickOverviewGrid(
                    inboxRiskScore: smsProvider.inboxRiskScore,
                    highRiskCount: smsProvider.highRiskCount,
                    maliciousCount: smsProvider.maliciousCount,
                    remindersCount:
                        smsProvider.upcomingReminders.length,
                    financialStressScore:
                        smsProvider.stressReport.score,
                    onTapInboxRisk: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const SecurityCenterScreen(),
                        ),
                      );
                    },
                    onTapMalicious: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const SecurityCenterScreen(
                            initialFilter:
                                SecurityFilter.malicious,
                          ),
                        ),
                      );
                    },
                    onTapReminders: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RemindersScreen(),
                        ),
                      );
                    },
                    onTapFinancial: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const FinancialInsightsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // OTP abuse / identity misuse alert card
                  OtpAlertCard(report: smsProvider.otpAbuseReport),

                  // ---------- PERMISSION WARNING ----------
                  if (smsProvider.permissionStatus ==
                      SmsPermissionStatus.denied)
                    Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color:
                            color.errorContainer.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.privacy_tip_rounded,
                              color: color.error),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SMS permission required',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                          fontWeight:
                                              FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'TrueInbox needs access to your SMS inbox to categorise OTP, spam, and malicious messages.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall,
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment:
                                      Alignment.centerLeft,
                                  child: TextButton.icon(
                                    onPressed: () => smsProvider
                                        .retryPermission(),
                                    icon: const Icon(
                                        Icons.refresh_rounded),
                                    label: const Text(
                                        'Grant permission'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ---------- SEARCH + CATEGORY FILTER ----------
                  TextField(
                    controller: _searchController,
                    onChanged: smsProvider.setSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Search by sender or text',
                      prefixIcon:
                          const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor:
                          color.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(999),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CategoryFilterBar(
                    selected: smsProvider.selectedCategory,
                    onChanged: smsProvider.setCategory,
                  ),
                  const SizedBox(height: 12),

                  // Debug info (keep for now; remove later if you want)
                  Text(
                    'Loaded: ${all.length} messages • Filtered: ${filtered.length}',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: color.outline),
                  ),
                  const SizedBox(height: 8),

                  // ---------- MAIN SMS LIST / STATES ----------
                  if (showSkeleton)
                    const _SkeletonMessageList()
                  else if (!hasAnyMessages)
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: Column(
                        children: [
                          Icon(Icons.mail_outline_rounded,
                              size: 64, color: color.outline),
                          const SizedBox(height: 12),
                          Text(
                            smsProvider.permissionStatus ==
                                    SmsPermissionStatus.granted
                                ? 'No messages found'
                                : 'No SMS loaded yet',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            smsProvider.permissionStatus ==
                                    SmsPermissionStatus.granted
                                ? 'Your inbox might be empty or inaccessible to this app.'
                                : 'Once SMS permission is granted and messages are read, they will appear here.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount: messagesToShow.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final msg = messagesToShow[index];
                        return MessageCard(
                          message: msg,
                        );
                      },
                    ),
                ],
              ),
            ),

            if (showMainLoadingOverlay)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.04),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ===================== TOP DASHBOARD GRID =====================

class _QuickOverviewGrid extends StatelessWidget {
  final int inboxRiskScore;
  final int highRiskCount;
  final int maliciousCount;
  final int remindersCount;
  final int financialStressScore;

  final VoidCallback onTapInboxRisk;
  final VoidCallback onTapMalicious;
  final VoidCallback onTapReminders;
  final VoidCallback onTapFinancial;

  const _QuickOverviewGrid({
    required this.inboxRiskScore,
    required this.highRiskCount,
    required this.maliciousCount,
    required this.remindersCount,
    required this.financialStressScore,
    required this.onTapInboxRisk,
    required this.onTapMalicious,
    required this.onTapReminders,
    required this.onTapFinancial,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: [
        _DashboardBox(
          icon: Icons.shield_rounded,
          iconColor: color.primary,
          title: 'Inbox risk',
          value: '$inboxRiskScore / 100',
          subtitle: '$highRiskCount high-risk SMS',
          onTap: onTapInboxRisk,
        ),
        _DashboardBox(
          icon: Icons.warning_amber_rounded,
          iconColor: color.error,
          title: 'Malicious SMS',
          value: maliciousCount.toString(),
          subtitle: 'Flagged as dangerous',
          onTap: onTapMalicious,
        ),
        _DashboardBox(
          icon: Icons.event_rounded,
          iconColor: color.tertiary,
          title: 'Smart reminders',
          value: remindersCount.toString(),
          subtitle: 'Upcoming events',
          onTap: onTapReminders,
        ),
        _DashboardBox(
          icon: Icons.account_balance_wallet_rounded,
          iconColor:
              financialStressScore >= 70 ? color.error : color.primary,
          title: 'Financial stress',
          value: '$financialStressScore / 100',
          subtitle: financialStressScore >= 70
              ? 'High stress signals'
              : 'Watching your SMS',
          onTap: onTapFinancial,
        ),
      ],
    );
  }
}

class _DashboardBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final VoidCallback onTap;

  const _DashboardBox({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 4),
              color: Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const Spacer(),
            Text(
              title,
              style: textTheme.bodySmall?.copyWith(
                color: color.outline,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: textTheme.labelSmall?.copyWith(
                color: color.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== SKELETON LOADER =====================

class _SkeletonMessageList extends StatelessWidget {
  const _SkeletonMessageList();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Column(
      children: List.generate(6, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: color.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: color.outline.withOpacity(0.4),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 10,
                          width: 140,
                          decoration: BoxDecoration(
                            color:
                                color.outline.withOpacity(0.20),
                            borderRadius:
                                BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 10,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color:
                                color.outline.withOpacity(0.16),
                            borderRadius:
                                BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 10,
                          width: 180,
                          decoration: BoxDecoration(
                            color:
                                color.outline.withOpacity(0.12),
                            borderRadius:
                                BorderRadius.circular(999),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
