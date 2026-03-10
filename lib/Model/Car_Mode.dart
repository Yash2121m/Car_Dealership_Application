class Car {
  final List<String> images;
  final String name;
  final String description;
  final String transmission;
  final int seats;
  final double totalPrice;
  final int topSpeed;
  final double mileage;
  final int horsepower;


  final String bodyType;
  final int numberOfDoors;
  final int totalLength;
  final int overallWidth;
  final int overallHeight;
  final int wheelbase;
  final int groundClearance;
  final int bootCapacity;
  final int fuelTankCapacity;
  final String brand;
  final String fuelType;

  Car({
    required this.images,
    required this.name,
    required this.description,
    required this.transmission,
    required this.seats,
    required this.totalPrice,
    required this.topSpeed,
    required this.mileage,
    required this.horsepower,
    required this.bodyType,
    required this.numberOfDoors,
    required this.totalLength,
    required this.overallWidth,
    required this.overallHeight,
    required this.wheelbase,
    required this.groundClearance,
    required this.bootCapacity,
    required this.fuelTankCapacity,
    required this.brand,
    required this.fuelType,
  });

  Map<String, dynamic> toJson() {
    return {
      'images': images,
      'name': name,
      'description': description,
      'transmission': transmission,
      'seats': seats,
      'totalPrice': totalPrice,
      'topSpeed': topSpeed,
      'mileage': mileage,
      'horsepower': horsepower,
      'bodyType': bodyType,
      'numberOfDoors': numberOfDoors,
      'totalLength': totalLength,
      'overallWidth': overallWidth,
      'overallHeight': overallHeight,
      'wheelbase': wheelbase,
      'groundClearance': groundClearance,
      'bootCapacity': bootCapacity,
      'fuelTankCapacity': fuelTankCapacity,
      'brand': brand,
      'fuelType': fuelType,
    };
  }
}
