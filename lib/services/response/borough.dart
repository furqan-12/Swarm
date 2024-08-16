import 'package:swarm/services/response/hood.dart';

class Borough {
  String id;
  String name;
  String cityId;
  bool isSelected;
  List<Hood>? hoods;

  Borough(this.id, this.name, this.cityId, {this.isSelected = false});
}
