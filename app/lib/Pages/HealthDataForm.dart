import 'package:flutter/material.dart';
import '../Obj/User.dart';
import '../Model/HealthData.dart';
import '../Services/HealthDataService.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class HealthDataForm extends StatefulWidget {
  final User user;
  final bool isViewMode;
  final DateTime? predictionDate;
  final Map<String, dynamic>? inputData;
  final double? riskProbability;

  const HealthDataForm({
    Key? key,
    required this.user,
    this.isViewMode = false,
    this.predictionDate,
    this.inputData,
    this.riskProbability,
  }) : super(key: key);

  @override
  State<HealthDataForm> createState() => _HealthDataFormState();
}

class _HealthDataFormState extends State<HealthDataForm> {
  final _formKey = GlobalKey<FormState>();
  final _healthDataService = HealthDataService();
  bool _isLoading = false;

  // Controllers for form fields
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  String _selectedGender = 'Male';
  bool _hasStroke = false;
  bool _hasHeartCondition = false;

  @override
  void initState() {
    super.initState();
    if (widget.isViewMode && widget.inputData != null) {
      _loadInputData();
    }
  }

  void _loadInputData() {
    final data = widget.inputData!;
    _ageController.text = data['Age'].toString();
    _heightController.text = data['Height'].toString();
    _weightController.text = data['Weight'].toString();
    _selectedGender = data['Sex'] == 1 ? 'Male' : 'Female';
    _hasStroke = data['Stroke'] == 1;
    _hasHeartCondition = data['HeartDiseaseorAttack'] == 1;
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  double _calculateBMI() {
    final height =
        double.parse(_heightController.text) / 100; // Convert cm to m
    final weight = double.parse(_weightController.text);
    return weight / (height * height);
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _healthDataService.submitHealthData(
          context: context,
          height: double.parse(_heightController.text),
          weight: double.parse(_weightController.text),
          stroke: _hasStroke ? 1 : 0,
          heartDiseaseorAttack: _hasHeartCondition ? 1 : 0,
          sex: _selectedGender == 'Male' ? 1 : 0,
          age: int.parse(_ageController.text),
        );

        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.isViewMode ? 'Prediction Details' : 'Health Data Form'),
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.isViewMode)
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prediction Result',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Risk Probability: ${(widget.riskProbability! * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Prediction Date: ${DateFormat('MMM dd, yyyy hh:mm a').format(widget.predictionDate!.toLocal().add(Duration(hours: 6)))}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 24),
              Text(
                'Input Data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 18 || age > 120) {
                    return 'Please enter a valid age (18-120)';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(labelText: 'Gender'),
                items: ['Male', 'Female']
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              SwitchListTile(
                title: Text('Has Stroke'),
                value: _hasStroke,
                onChanged: (value) {
                  setState(() {
                    _hasStroke = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text('Has Heart Condition'),
                value: _hasHeartCondition,
                onChanged: (value) {
                  setState(() {
                    _hasHeartCondition = value;
                  });
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _heightController,
                decoration: InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your height';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid height';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your weight';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid weight';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Submit Health Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
