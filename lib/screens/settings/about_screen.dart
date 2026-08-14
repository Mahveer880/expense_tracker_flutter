import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About"), centerTitle: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 20),

            // =====================================================
            // APP ICON
            // =====================================================
            CircleAvatar(
              radius: 55,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.12),

              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            const SizedBox(height: 20),

            // =====================================================
            // APP NAME
            // =====================================================
            const Text(
              "Expense Tracker Pro",
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              "Version 1.0.0",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),

            const SizedBox(height: 30),

            // =====================================================
            // DESCRIPTION
            // =====================================================
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "About the App",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Expense Tracker Pro is a simple and powerful "
                      "personal finance application designed to help "
                      "you manage your income, expenses and budgets "
                      "in one place.",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =====================================================
            // FEATURES
            // =====================================================
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Features",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    _FeatureItem(
                      icon: Icons.add_chart,
                      title: "Income & Expense Tracking",
                      description:
                          "Record and manage your financial transactions.",
                    ),

                    _FeatureItem(
                      icon: Icons.analytics_outlined,
                      title: "Financial Analytics",
                      description:
                          "View spending patterns and financial summaries.",
                    ),

                    _FeatureItem(
                      icon: Icons.account_balance_wallet_outlined,
                      title: "Budget Management",
                      description: "Set monthly and yearly budgets.",
                    ),

                    _FeatureItem(
                      icon: Icons.search,
                      title: "Search & Filters",
                      description:
                          "Quickly find transactions using search and filters.",
                    ),

                    _FeatureItem(
                      icon: Icons.notifications_outlined,
                      title: "Notifications",
                      description:
                          "Receive notifications when transactions are added.",
                    ),

                    _FeatureItem(
                      icon: Icons.backup_outlined,
                      title: "Backup & Restore",
                      description:
                          "Create and restore your transaction backups.",
                    ),

                    _FeatureItem(
                      icon: Icons.picture_as_pdf_outlined,
                      title: "PDF Reports",
                      description:
                          "Generate a detailed financial report in PDF format.",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =====================================================
            // TECHNOLOGY
            // =====================================================
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  children: [
                    const Icon(Icons.code, size: 40),

                    const SizedBox(height: 10),

                    const Text(
                      "Built with Flutter",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Expense Tracker Pro is built using Flutter "
                      "with local data storage and modern Material UI.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // =====================================================
            // FOOTER
            // =====================================================
            Text(
              "Expense Tracker Pro",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              "© 2026",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// FEATURE ITEM
// =============================================================

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.12),

            child: Icon(
              icon,
              size: 21,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
