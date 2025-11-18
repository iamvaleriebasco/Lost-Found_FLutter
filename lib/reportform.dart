import 'package:flutter/material.dart';
import 'package:hopelink/main.dart';

//REPORT SUBMISSION FORM (Stateful Widget)

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
        // ID is placeholder for client side;
        id: '',
        type: _selectedType,
        name: _name,
        description: _description,
        date: DateTime.now(),
        // UPDATED: Use the finalImageUrl
        imageUrl: finalImageUrl,
        userId: currentUserId,
      );

      // call the passed function
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

              //text Field for identification/description
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

              // UPDATED: text field for image URL
              TextFormField(
                decoration: const InputDecoration(
                  labelText:
                      'Find similar photo online and paste the image URL here (Optional)',
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


// THANK YOU, SIR! I REALLY LEARNED A LOT FROM YOU. SEE YOU AROUND!