import 'package:flutter/material.dart';


//HOMEPAGE (LANDING PAGE)

class HomePage extends StatelessWidget {
  final Function(int) onNavigate;
  const HomePage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Icon(Icons.track_changes, size: 80, color: Colors.indigo.shade400),
          const SizedBox(height: 16),
          const Text(
            'Welcome to the Lost & Found Tracker',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          _SectionCard(
            title: 'View Lost Items',
            subtitle: 'Find items or people that have been reported lost.',
            icon: Icons.person_search,
            color: Colors.red.shade100,
            onTap: () => onNavigate(1),
          ),
          const SizedBox(height: 20),

          _SectionCard(
            title: 'View Found Items',
            subtitle:
                'See items that have been reported found and are awaiting pickup.',
            icon: Icons.location_on,
            color: Colors.green.shade100,
            onTap: () => onNavigate(2),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const Text(
            'Use the button below to submit a new report.',
            textAlign: TextAlign.center,
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// stateless widget for HomePage
class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.indigo.shade800),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
