import 'package:flutter/material.dart';
import '../Assistance/ColorHelper.dart';
import '../Model/Car.dart';
import '../Model/Car_Mode.dart';
import 'Car_Detail_Screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchQuery = '';
  List<Car> filteredCars = [];
  List<Car> allCars = [];

  RangeValues priceRange = const RangeValues(100000, 1000000);
  RangeValues mileageRange = const RangeValues(10, 30);
  double minMileage = 10;
  double maxMileage = 30;

  String? selectedBrand;
  String? selectedTransmission;
  String? selectedBodyType;
  int? selectedSeats;

  String selectedSort = 'None';
  Set<String> wishlist = {};

  @override
  void initState() {
    super.initState();
    allCars = sedanCars + suvCars + Coupe + Hatchback + Convertible;
    filteredCars = allCars;
  }

  void updateSearch(String query) {
    searchQuery = query.toLowerCase();
    applyFilters();
  }

  void applyFilters() {
    filteredCars = allCars.where((car) {
      final matchesSearch = car.name.toLowerCase().contains(searchQuery);
      final matchesPrice = car.totalPrice >= priceRange.start && car.totalPrice <= priceRange.end;
      final matchesBrand = selectedBrand == null || car.brand == selectedBrand;
      final matchesTransmission = selectedTransmission == null || car.transmission == selectedTransmission;
      final matchesSeats = selectedSeats == null || car.seats == selectedSeats;
      final matchesBodyType = selectedBodyType == null || car.bodyType == selectedBodyType;
      final matchesMileage = car.mileage >= mileageRange.start && car.mileage <= mileageRange.end;

      return matchesSearch && matchesPrice && matchesBrand && matchesTransmission && matchesSeats && matchesBodyType && matchesMileage;
    }).toList();


    switch (selectedSort) {
      case 'Price: Low to High':
        filteredCars.sort((a, b) => a.totalPrice.compareTo(b.totalPrice));
        break;
      case 'Price: High to Low':
        filteredCars.sort((a, b) => b.totalPrice.compareTo(a.totalPrice));
        break;
      case 'Mileage: High to Low':
        filteredCars.sort((a, b) => b.mileage.compareTo(a.mileage));
        break;
      case 'Horsepower: High to Low':
        filteredCars.sort((a, b) => b.horsepower.compareTo(a.horsepower));
        break;
    }

    setState(() {});
  }

  List<String> getUniqueBrands() => allCars.map((car) => car.brand).toSet().toList();
  List<String> getUniqueBodyTypes() => allCars.map((car) => car.bodyType).toSet().toList();
  List<int> getUniqueSeats() => allCars.map((car) => car.seats).toSet().toList()..sort();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [ColorSys.purple1, ColorSys.purple2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: AppBar(
            title: const Text("Search Cars",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: updateSearch,
              decoration: InputDecoration(
                hintText: "Search for cars...",
                prefixIcon: const Icon(Icons.search, color: Colors.purple),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),


          ExpansionTile(
            title: const Text("Filters"),
            children: [

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedSort,
                  items: [
                    'None',
                    'Price: Low to High',
                    'Price: High to Low',
                    'Mileage: High to Low',
                    'Horsepower: High to Low',
                  ].map((value) {
                    return DropdownMenuItem(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (value) {
                    selectedSort = value!;
                    applyFilters();
                  },
                ),
              ),


              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Price Range (₹)", style: TextStyle(fontWeight: FontWeight.bold)),
                    RangeSlider(
                      values: priceRange,
                      min: 1000,
                      max: 10000000,
                      divisions: 19,
                      labels: RangeLabels("₹${priceRange.start.round()}", "₹${priceRange.end.round()}"),
                      onChanged: (values) {
                        priceRange = values;
                        applyFilters();
                      },
                    ),
                  ],
                ),
              ),


              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Mileage (km/l)", style: TextStyle(fontWeight: FontWeight.bold)),
                    RangeSlider(
                      values: mileageRange,
                      min: minMileage,
                      max: maxMileage,
                      divisions: 10,
                      labels: RangeLabels(
                        "${mileageRange.start.toStringAsFixed(1)}",
                        "${mileageRange.end.toStringAsFixed(1)}",
                      ),
                      onChanged: (values) {
                        mileageRange = values;
                        applyFilters();
                      },
                    ),
                  ],
                ),
              ),


              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: getUniqueBrands().map((brand) {
                    final selected = selectedBrand == brand;
                    return ChoiceChip(
                      label: Text(brand),
                      selected: selected,
                      selectedColor: Colors.blueAccent,
                      onSelected: (_) {
                        setState(() {
                          selectedBrand = selected ? null : brand;
                          applyFilters();
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),


          Expanded(
            child: filteredCars.isEmpty
                ? const Center(child: Text("No cars found matching your criteria"))
                : ListView.builder(
              itemCount: filteredCars.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final car = filteredCars[index];
                return GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => CarDetailScreen(car: car))),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Stack(
                      children: [

                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            car.images[0],
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),

                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(car.name,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: ColorSys.purple2,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "₹${car.totalPrice.toStringAsFixed(0)}",
                                      style: const TextStyle(
                                          color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),

                              IconButton(
                                icon: Icon(
                                  wishlist.contains(car.name)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: wishlist.contains(car.name) ? Colors.red : Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    wishlist.contains(car.name)
                                        ? wishlist.remove(car.name)
                                        : wishlist.add(car.name);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
