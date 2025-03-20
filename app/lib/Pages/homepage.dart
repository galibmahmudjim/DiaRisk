import 'package:animations/animations.dart';
import './HealthDataForm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../Model/sharedPref.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:logger/logger.dart';

import '../Obj/User.dart';
import '../Widget/loading.dart';
import '../homeLogin.dart';
import '../Constants/Constants.dart';

// Add PredictionData class at the top level
class PredictionData {
  final DateTime date;
  final double riskProbability;
  final Map<String, dynamic> inputData;

  PredictionData({
    required this.date,
    required this.riskProbability,
    required this.inputData,
  });
}

class HomePage extends StatefulWidget {
  final User? user;
  final String? id;
  final String? name;

  const HomePage({this.user, this.id, this.name});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final logger = Logger();
  TextEditingController textController = TextEditingController();
  String textControllertest = "";
  bool group = false;
  bool isLoading = false;
  User user = User();
  bool timeout = false;
  bool loadingHome = false;
  bool isMenuOpen = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // List to store prediction data
  List<PredictionData> predictionData = [];

  // Generate dates for the timeline

  Future<void> fetchRiskData() async {
    try {
      final token = await sharedPref.getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/api/v1/health/predictions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        logger.i('Fetched prediction data');
        final data = jsonDecode(response.body);
        setState(() {
          predictionData = (data as List)
              .map((item) => PredictionData(
                    date: DateTime.parse(item['created_at']),
                    riskProbability:
                        (item['risk_probability'] ?? 0.0).toDouble(),
                    inputData: item['input_data'],
                  ))
              .toList();

          // Sort predictions by date
          predictionData.sort((a, b) => a.date.compareTo(b.date));

          // Update risk data for the graph
          riskData = predictionData.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), entry.value.riskProbability);
          }).toList();

          // Update timeline labels based on actual dates
          timelineLabels.clear();
          timelineLabels.addAll(predictionData.map((prediction) =>
              DateFormat('MMM dd\nyyyy')
                  .format(prediction.date.toLocal().add(Duration(hours: 6)))));
        });
      } else {
        print('Failed to fetch prediction data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching prediction data: $e');
    }
  }

  final List<String> timelineLabels = []; // Will be initialized in initState
  List<FlSpot> riskData = []; // Will be initialized in initState
  final double minX = 0;
  final double maxY = 1;
  final double minY = 0;
  final double yInterval = 0.2;

  Future<void> checkLoggedIn() async {
    setState(() {
      loadingHome = true;
    });

    try {
      // Check for access token
      final token = await sharedPref.getToken();
      if (token == null || token.isEmpty) {
        setState(() {
          isLoading = false;
          timeout = false;
          loadingHome = false;
        });
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePageLogin()));
        return;
      }

      // If we have a token and user data, proceed
      if (widget.id != null && widget.name != null) {
        setState(() {
          isLoading = false;
          timeout = false;
          user = User(
            id: widget.id,
            name: widget.name,
          );
          loadingHome = false;
        });
      }

      // Verify token with API
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/api/v1/auth/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body)['data']['user'];
        setState(() {
          user = User(
            id: userData['_id'] ?? '',
            name: userData['name'] ?? '',
            email: userData['email'] ?? '',
            imageURL: userData['picture'] ?? '',
          );
          isLoading = false;
          timeout = false;
          loadingHome = false;
        });
      } else {
        await sharedPref.clearToken();
        setState(() {
          isLoading = false;
          timeout = true;
          loadingHome = false;
        });
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePageLogin()));
      }
    } catch (e) {
      await sharedPref.clearToken();
      setState(() {
        isLoading = false;
        timeout = true;
        loadingHome = false;
      });
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePageLogin()));
    }
  }

  @override
  void initState() {
    super.initState();
    isLoading = true;
    if (widget.user != null) {
      isLoading = false;
      user = widget.user!;
    } else {
      checkLoggedIn();
    }

    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Fetch risk data when the page loads
    fetchRiskData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      isMenuOpen = !isMenuOpen;
      if (isMenuOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  late double height;
  late double width;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = (MediaQuery.of(context).size.width);

    return Scaffold(
        floatingActionButton: Stack(
          children: [
            // Add Record Button (now top)
            Positioned(
              right: 0,
              bottom: 120,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _animation.value,
                    child: FloatingActionButton(
                      heroTag: 'add',
                      backgroundColor: Colors.grey[800],
                      onPressed: () {
                        print('Add button pressed'); // Debug print
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HealthDataForm(user: user),
                          ),
                        );
                      },
                      child: Icon(Icons.add, color: Colors.white),
                    ),
                  );
                },
              ),
            ),
            // Logout Button (now middle)
            Positioned(
              right: 0,
              bottom: 60,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _animation.value,
                    child: FloatingActionButton(
                      heroTag: 'logout',
                      backgroundColor: Colors.grey[800],
                      onPressed: () async {
                        await sharedPref.clearToken();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePageLogin()));
                      },
                      child: Icon(Icons.logout, color: Colors.white),
                    ),
                  );
                },
              ),
            ),
            // Main Menu Button
            Positioned(
              right: 0,
              bottom: 0,
              child: FloatingActionButton(
                heroTag: 'menu',
                backgroundColor: Colors.grey[800],
                onPressed: _toggleMenu,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _animation.value * (3.14159 / 2),
                      child: Icon(Icons.menu, color: Colors.white),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: SafeArea(
          top: true,
          bottom: true,
          left: true,
          right: true,
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    checkLoggedIn();
                    fetchRiskData();
                  });
                },
                notificationPredicate: (ScrollNotification notification) {
                  return notification.depth == 1;
                },
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Container(
                    height: height,
                    child: MainBody(),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  MainBody() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(),
          height: height,
          width: width,
          child: Column(
            children: [
              // Header container
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 30, height: 70),
                    CircleAvatar(
                      radius: 17,
                      backgroundImage:
                          user.imageURL != null && user.imageURL!.isNotEmpty
                              ? NetworkImage(user.imageURL!)
                              : null,
                      child: user.imageURL == null || user.imageURL!.isEmpty
                          ? Icon(Icons.person, size: 30, color: Colors.grey)
                          : null,
                    ),
                    SizedBox(width: 15),
                    Text(
                      ' ${user.name ?? "User"}',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Graph container with fixed height
              Container(
                height: 250,
                padding: EdgeInsets.fromLTRB(16, 16, 16, 42),
                child: Row(
                  children: [
                    // Y-axis labels
                    Container(
                      width: 40,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('1.0',
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 10)),
                          Text('0.8',
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 10)),
                          Text('0.6',
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 10)),
                          Text('0.4',
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 10)),
                          Text('0.2',
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 10)),
                          Text('0.0',
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 10)),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    // Graph
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: max(width * 2, predictionData.length * 60.0),
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: yInterval,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey[300]!,
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    reservedSize: 42,
                                    getTitlesWidget: (value, meta) {
                                      const style = TextStyle(
                                        color: Colors.grey,
                                        fontSize: 8,
                                      );
                                      Widget text;
                                      if (value.toInt() >= 0 &&
                                          value.toInt() <
                                              timelineLabels.length) {
                                        text = RotatedBox(
                                          quarterTurns: 1,
                                          child: Text(
                                            timelineLabels[value.toInt()],
                                            style: style,
                                            textAlign: TextAlign.left,
                                          ),
                                        );
                                      } else {
                                        text = const Text('');
                                      }
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        space: 8,
                                        child: text,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              minX: minX,
                              maxX: timelineLabels.length.toDouble() - 1,
                              minY: minY,
                              maxY: maxY,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: riskData,
                                  isCurved: true,
                                  color: Colors.grey[800],
                                  barWidth: 2,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.grey[800]!.withOpacity(0.1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Timeline vs Risk Probability',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 8),
              // Prediction history section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Prediction History',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              // Prediction list with remaining height
              Expanded(
                child: _buildPredictionHistory(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionHistory() {
    final sortedPredictions = List<PredictionData>.from(predictionData)
      ..sort((a, b) => b.date.compareTo(a.date));

    return SingleChildScrollView(
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: sortedPredictions.length,
        itemBuilder: (context, index) {
          final prediction = sortedPredictions[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HealthDataForm(
                    user: user,
                    isViewMode: true,
                    predictionDate: prediction.date,
                    inputData: prediction.inputData,
                    riskProbability: prediction.riskProbability,
                  ),
                ),
              );
            },
            child: Card(
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                height: 70,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        DateFormat('MMM dd, yyyy hh:mm a').format(
                            prediction.date.toLocal().add(Duration(hours: 6))),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getRiskColor(prediction.riskProbability)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(prediction.riskProbability * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getRiskColor(prediction.riskProbability),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getRiskColor(double riskProbability) {
    if (riskProbability < 0.3) {
      return Colors.green;
    } else if (riskProbability < 0.5) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }
}
