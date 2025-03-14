class HealthData {
  final String id;
  final double bmi;
  final int stroke;
  final int heartDiseaseorAttack;
  final int sex;
  final int age;
  final String riskLevel;
  final double riskProbability;
  final DateTime createdAt;

  HealthData({
    required this.id,
    required this.bmi,
    required this.stroke,
    required this.heartDiseaseorAttack,
    required this.sex,
    required this.age,
    required this.riskLevel,
    required this.riskProbability,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bmi': bmi,
      'stroke': stroke,
      'heartDiseaseorAttack': heartDiseaseorAttack,
      'sex': sex,
      'age': age,
      'riskLevel': riskLevel,
      'riskProbability': riskProbability,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(
      id: json['id'],
      bmi: json['bmi'].toDouble(),
      stroke: json['stroke'],
      heartDiseaseorAttack: json['heartDiseaseorAttack'],
      sex: json['sex'],
      age: json['age'],
      riskLevel: json['riskLevel'],
      riskProbability: json['riskProbability'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
