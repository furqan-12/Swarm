class Hood {
  String id;
  String name;
  String boroughId;
  double longitude;
  double latitude;
  bool isSelected;

  Hood(this.id, this.name, this.boroughId, this.longitude, this.latitude,
      {this.isSelected = false});
}
