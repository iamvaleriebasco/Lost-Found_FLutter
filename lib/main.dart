import 'package:flutter/material.dart';
import 'package:hopelink/homepage.dart';
import 'package:hopelink/reportdetail.dart';
import 'package:hopelink/reportform.dart';

String currentUserId = 'simulated_user_id';
// global counter for simulated document IDs
int _reportIdCounter = 2;

//simulated firestore collection paths
String get _missingCollectionPath => 'reports/missing/data';
String get _foundCollectionPath => 'reports/found/data';

//simulated database structure to hold all reports in memory
Map<String, List<Report>> _simulatedDb = {
  'reports/missing/data': [
    Report(
      id: 'm1',
      type: ReportType.Missing,
      name: 'Lost: Blue Backpack',
      description:
          'Small, worn blue backpack . Last seen near the library entrance.',
      date: DateTime.now().subtract(const Duration(days: 2)),
      // UPDATED: more descriptive placeholder image
      imageUrl: 'assets/images/backpack.jpg',
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
      //image
      imageUrl: 'assets/images/glasses.jpg',
      userId: currentUserId,
    ),
  ],
};

//simulated onSnapshot listener (reads from simulated DB)
Stream<List<Report>> getReportsStream(ReportType type) async* {
  String path = type == ReportType.Missing
      ? _missingCollectionPath
      : _foundCollectionPath;
  //simulates a real-time stream by yielding the current state of the list.
  yield _simulatedDb[path] ?? [];
}

//simulated addDoc function (writes to simulated DB)
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

  //simulate adding to the database list
  if (_simulatedDb.containsKey(path)) {
    _simulatedDb[path]!.add(newReportWithId);
  } else {
    _simulatedDb[path] = [newReportWithId];
  }
}

//1. DATA MODEL (Custom Object)

enum ReportType { Missing, Found }

class Report {
  final String id;
  final ReportType type;
  final String name;
  final String description;
  final DateTime date;
  final String imageUrl;
  final String userId; //the one who submitted

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

//2. MAIN APPLICATION SETUP

void main() {
  //simulate firebase initialization
  //in a real app: WidgetsFlutterBinding.ensureInitialized();
  //in a real app: await Firebase.initializeApp();
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

//3. STATEFUL WIDGET FOR GLOBAL DATA & NAVIGATION

class MainScreen extends StatefulWidget {
  const MainScreen({super.key}); // changed to mainscreen constructor

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  //PS:lists are now empty as they will be populated by the streambuilders
  List<Report> _missingItems = [];
  List<Report> _foundItems = [];

  //function to save a new report
  Future<void> _addItem(Report newReport) async {
    //in a real app, can perform firestore data validation here
    await addReportToFirestore(newReport);

    //navigate back to the main screen after submission
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  //this function builds the specific page based on the selected index
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
        //streamBuilder to get real-time found data
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

  //build method for main screen
  @override
  Widget build(BuildContext context) {
    //simulatation of initial firebase authentication here
    //in a real app: FirebaseAuth.instance.signInAnonymously();

    return Scaffold(
      appBar: AppBar(title: const Text('Lost and Found Tracker')),
      body: _getPage(_selectedIndex), // display the selected streamBuilder/page
      // floating action button to navigate to the form
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

//5.REPORT LIST PAGE (LOST/FOUND LIST)
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
