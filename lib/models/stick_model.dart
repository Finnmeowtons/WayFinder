class StickModel {
  final int id;
  String name;
  final double latitude;
  final double longitude;
  final String location;
  final int? distance;
  String? profilePic;


  StickModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.location,
    this.distance,
    this.profilePic,
  });
}