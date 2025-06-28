class PriseMedicament {
  final int? id;
  final int medicamentId;
  final DateTime datePrise;
  final String heurePrevue;
  final String? heureReelle;
  final bool pris;

  PriseMedicament({
    this.id,
    required this.medicamentId,
    required this.datePrise,
    required this.heurePrevue,
    this.heureReelle,
    this.pris = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicamentId': medicamentId,
      'datePrise': datePrise.toIso8601String(),
      'heurePrevue': heurePrevue,
      'heureReelle': heureReelle,
      'pris': pris ? 1 : 0,
    };
  }

  factory PriseMedicament.fromMap(Map<String, dynamic> map) {
    return PriseMedicament(
      id: map['id'],
      medicamentId: map['medicamentId'],
      datePrise: DateTime.parse(map['datePrise']),
      heurePrevue: map['heurePrevue'],
      heureReelle: map['heureReelle'],
      pris: map['pris'] == 1,
    );
  }
}
