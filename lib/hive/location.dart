import 'package:hive/hive.dart';

part 'location.g.dart';

@HiveType(typeId: 3)
class Location extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String mapsUrl;

  Location({required this.name, required this.mapsUrl});
}
