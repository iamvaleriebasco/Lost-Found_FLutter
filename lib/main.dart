import 'dart:convert'; // Required for Base64 decoding

import 'package:flutter/material.dart';

String currentUserId = 'simulated_user_id';
// Global counter for simulated document IDs
int _reportIdCounter = 2;

// Simulated Firestore Collection paths
String get _missingCollectionPath => 'reports/missing/data';
String get _foundCollectionPath => 'reports/found/data';

// A simulated database structure to hold all reports in memory
Map<String, List<Report>> _simulatedDb = {
  'reports/missing/data': [
    Report(
      id: 'm1',
      type: ReportType.Missing,
      name: 'Lost: Blue Backpack',
      description:
          'Small, worn blue backpack . Last seen near the library entrance.',
      date: DateTime.now().subtract(const Duration(days: 2)),
      // UPDATED: More descriptive placeholder image
      imageUrl: 'lib/assets/backpack.jpg',
      userId: currentUserId,
    ),
  ],
  'reports/found/data': [
    Report(
      id: 'f1',
      type: ReportType.Found,
      name: 'Found: Prescription Glasses',
      description:
          'Black framed reading glasses found on bench near the cafeteria.',
      date: DateTime.now().subtract(const Duration(hours: 5)),
      imageUrl: 'lib/assets/glasses.jpg', // <-- HERE
      userId: currentUserId,
    ),
  ],
};

// Simulated onSnapshot listener (reads from simulated DB)
Stream<List<Report>> getReportsStream(ReportType type) async* {
  String path = type == ReportType.Missing
      ? _missingCollectionPath
      : _foundCollectionPath;
  // This simulates a real-time stream by yielding the current state of the list.
  yield _simulatedDb[path] ?? [];
}

// Simulated addDoc function (writes to simulated DB)
Future<void> addReportToFirestore(Report report) async {
  String path = report.type == ReportType.Missing
      ? _missingCollectionPath
      : _foundCollectionPath;

  // Assign a new simulated ID
  final newReportWithId = Report(
    id: 'id_${_reportIdCounter++}',
    type: report.type,
    name: report.name,
    description: report.description,
    date: report.date,
    imageUrl: report.imageUrl,
    userId: currentUserId,
  );

  // Simulate adding to the database list
  if (_simulatedDb.containsKey(path)) {
    _simulatedDb[path]!.add(newReportWithId);
  } else {
    _simulatedDb[path] = [newReportWithId];
  }
}

// --- 1. DATA MODEL (Custom Object) ---

enum ReportType { Missing, Found }

class Report {
  final String id;
  final ReportType type;
  final String name;
  final String description;
  final DateTime date;
  final String imageUrl;
  final String userId; // Who submitted it (for persistence)

  Report({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.date,
    required this.imageUrl,
    required this.userId,
  });
}

// --- 2. MAIN APPLICATION SETUP ---

void main() {
  // Simulate Firebase initialization
  // In a real app: WidgetsFlutterBinding.ensureInitialized();
  // In a real app: await Firebase.initializeApp();
  runApp(const MissingFoundApp());
}

class MissingFoundApp extends StatelessWidget {
  const MissingFoundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lost & Found Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      ),
      initialRoute: '/',
      routes: {'/': (context) => const MainScreen()},
    );
  }
}

// --- 3. STATEFUL WIDGET FOR GLOBAL DATA & NAVIGATION (USING STREAMS) ---

class MainScreen extends StatefulWidget {
  const MainScreen({super.key}); // Changed to MainScreen constructor

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // NOTE: Lists are now empty as they will be populated by the StreamBuilders
  List<Report> _missingItems = [];
  List<Report> _foundItems = [];

  // Function to save a new report (uses simulated addDoc)
  Future<void> _addItem(Report newReport) async {
    // In a real app, you would perform Firestore data validation here.
    await addReportToFirestore(newReport);

    // Navigate back to the main screen after submission
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // This function builds the specific page based on the selected index
  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return HomePage(onNavigate: _onItemTapped);
      case 1:
        // Use StreamBuilder to get real-time Missing data
        return StreamBuilder<List<Report>>(
          stream: getReportsStream(ReportType.Missing),
          builder: (context, snapshot) {
            _missingItems = snapshot.data ?? [];
            return ReportListPage(
              title: 'Lost Items List',
              reports: _missingItems,
              icon: Icons.search_off,
              color: Colors.red.shade400,
              isLoading: snapshot.connectionState == ConnectionState.waiting,
            );
          },
        );
      case 2:
        // Use StreamBuilder to get real-time Found data
        return StreamBuilder<List<Report>>(
          stream: getReportsStream(ReportType.Found),
          builder: (context, snapshot) {
            _foundItems = snapshot.data ?? [];
            return ReportListPage(
              title: 'Found Items List',
              reports: _foundItems,
              icon: Icons.check_circle_outline,
              color: Colors.green.shade400,
              isLoading: snapshot.connectionState == ConnectionState.waiting,
            );
          },
        );
      default:
        return HomePage(onNavigate: _onItemTapped);
    }
  }

  // --- BUILD METHOD FOR MAINSCREEN ---
  @override
  Widget build(BuildContext context) {
    // Simulate initial Firebase authentication here
    // In a real app: FirebaseAuth.instance.signInAnonymously();

    return Scaffold(
      appBar: AppBar(title: const Text('Lost and Found Tracker')),
      body: _getPage(_selectedIndex), // Display the selected StreamBuilder/Page
      // Floating Action Button to navigate to the form
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Routing to Form Page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportFormPage(
                onSubmit: _addItem,
              ), // Passing function as parameter
            ),
          );
        },
        label: const Text('Submit Report'),
        icon: const Icon(Icons.add_circle),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 168, 187, 227),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_search),
            label: 'Lost',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Found',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo.shade700,
        onTap: _onItemTapped,
      ),
    );
  }
}

// --- 4. HOMEPAGE (LANDING PAGE) ---

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

// Stateless Helper Widget for HomePage
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

// --- 5. REPORT LIST PAGE (MISSING/FOUND LIST) ---

class ReportListPage extends StatelessWidget {
  final String title;
  final List<Report> reports;
  final IconData icon;
  final Color color;
  final bool isLoading; // New property for loading indicator

  const ReportListPage({
    super.key,
    required this.title,
    required this.reports,
    required this.icon,
    required this.color,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(height: 0),

        Expanded(
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(color: color),
                ) // Show loading indicator
              : reports.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 60, color: color),
                      const SizedBox(height: 10),
                      Text('No ${title.split(' ')[0]} items reported yet.'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      elevation: 2,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ReportDetailPage(report: report),
                            ),
                          );
                        },
                        child: ListTile(
                          leading: Icon(
                            report.type == ReportType.Missing
                                ? Icons.warning
                                : Icons.thumb_up,
                            color: report.type == ReportType.Missing
                                ? Colors.red
                                : Colors.green,
                          ),
                          title: Text(report.name),
                          subtitle: Text(
                            report.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            '${report.date.month}/${report.date.day}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// --- 6. REPORT DETAIL PAGE ---

class ReportDetailPage extends StatelessWidget {
  final Report report;

  const ReportDetailPage({super.key, required this.report});

  // Helper to determine if the string is a Base64 image
  bool _isBase64(String s) {
    return s.length > 50 && !s.startsWith('http');
  }

  @override
  Widget build(BuildContext context) {
    // Check if the image URL is actually a Base64 string

    Widget imageWidget;

    // Check for asset image
    if (report.imageUrl.startsWith('asset:')) {
      final assetPath = report.imageUrl.replaceFirst('asset:', '');
      imageWidget = Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder("Asset image not found.");
        },
      );
    }
    // Check for Base64
    else if (_isBase64(report.imageUrl)) {
      try {
        final bytes = base64Decode(report.imageUrl);
        imageWidget = Image.memory(bytes, fit: BoxFit.cover);
      } catch (e) {
        imageWidget = _buildErrorPlaceholder('Base64 Decoding Error');
      }
    }
    // Otherwise treat as network
    else {
      imageWidget = Image.network(
        report.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder("No Image Provided");
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(report.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display Image (network or memory)
            Container(
              height: 500, // Increased height
              width: double.infinity,
              color: Colors.grey.shade200,
              child: imageWidget,
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: report.type == ReportType.Missing
                          ? Colors.red.shade600
                          : Colors.green.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      report.type == ReportType.Missing
                          ? 'MISSING REPORT'
                          : 'FOUND REPORT',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'Details / Identification:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.description,
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // Date Reported
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Reported on: ${report.date.month}/${report.date.day}/${report.date.year}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom error placeholder widget
  Widget _buildErrorPlaceholder(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            report.type == ReportType.Missing
                ? Icons.image_not_supported
                : Icons.photo,
            size: 50,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

// --- 7. REPORT SUBMISSION FORM (Stateful Widget) ---

class ReportFormPage extends StatefulWidget {
  // Passing function as parameter
  final Function(Report) onSubmit;

  const ReportFormPage({super.key, required this.onSubmit});

  @override
  State<ReportFormPage> createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  // Field for image URL / Base64 string
  String _imageUrl = '';
  ReportType _selectedType = ReportType.Missing;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Determine the final image URL: use the input if available, otherwise use a placeholder.
      final String finalImageUrl = _imageUrl.isNotEmpty
          ? _imageUrl
          : (_selectedType == ReportType.Missing
                ? 'https://placehold.co/600x400/FF5252/FFFFFF?text=MISSING+ITEM'
                : 'https://placehold.co/600x400/4CAF50/FFFFFF?text=FOUND+ITEM');

      // Create a new Report object
      final newReport = Report(
        // ID is placeholder for client side; Firestore generates the real ID on the server
        id: '',
        type: _selectedType,
        name: _name,
        description: _description,
        date: DateTime.now(),
        // UPDATED: Use the finalImageUrl
        imageUrl: finalImageUrl,
        userId: currentUserId,
      );

      // Call the passed function (which now runs addReportToFirestore)
      await widget.onSubmit(newReport);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Report Submission')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Select Report Type (Missing or Found)
              const Text(
                'Report Type:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<ReportType>(
                      title: const Text('Lost'),
                      value: ReportType.Missing,
                      groupValue: _selectedType,
                      onChanged: (ReportType? value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<ReportType>(
                      title: const Text('Found'),
                      value: ReportType.Found,
                      groupValue: _selectedType,
                      onChanged: (ReportType? value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const Divider(height: 30),

              // Text Field for Name
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Name/Title of Item or Person',
                  hintText: 'e.g., Lost Wallet or Found Black Jacket',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name or title.';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 20),

              // Text Field for Identification/Description
              TextFormField(
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Identification/Description',
                  hintText:
                      'Describe details (color, size, unique features, location).',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.description),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a detailed description.';
                  }
                  return null;
                },
                onSaved: (value) => _description = value!,
              ),
              const SizedBox(height: 20),

              // UPDATED: Text Field for Image URL or Base64
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Photo URL or Base64 String',
                  hintText:
                      'Paste a link (http) or a long Base64 string here (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  prefixIcon: Icon(Icons.image),
                ),
                onSaved: (value) => _imageUrl = value ?? '',
              ),
              const SizedBox(height: 40),

              // Button (Submission Button)
              Center(
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.send),
                  label: const Text(
                    'SUBMIT REPORT',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
