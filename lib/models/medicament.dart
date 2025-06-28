class Medicament {
  final int? id;
  final String nom;
  final String dosage;
  final int frequenceParJour;
  final List<String> heuresPrise;
  final bool aJeun;
  final int stockRestant;
  final String? photoPath;
  final String? effetsSecondaires;
  final String? conseils;

  Medicament({
    this.id,
    required this.nom,
    required this.dosage,
    required this.frequenceParJour,
    required this.heuresPrise,
    this.aJeun = false,
    required this.stockRestant,
    this.photoPath,
    this.effetsSecondaires,
    this.conseils,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'dosage': dosage,
      'frequenceParJour': frequenceParJour,
      'heuresPrise': heuresPrise.join(','),
      'aJeun': aJeun ? 1 : 0,
      'stockRestant': stockRestant,
      'photoPath': photoPath,
      'effetsSecondaires': effetsSecondaires,
      'conseils': conseils,
    };
  }

  factory Medicament.fromMap(Map<String, dynamic> map) {
    return Medicament(
      id: map['id'],
      nom: map['nom'],
      dosage: map['dosage'],
      frequenceParJour: map['frequenceParJour'],
      heuresPrise: map['heuresPrise'].split(','),
      aJeun: map['aJeun'] == 1,
      stockRestant: map['stockRestant'],
      photoPath: map['photoPath'],
      effetsSecondaires: map['effetsSecondaires'],
      conseils: map['conseils'],
    );
  }
}
