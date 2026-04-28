import 'package:flutter/material.dart';
import '../Assistance/ColorHelper.dart';
import '../Model/Car_Mode.dart';

class CompareCarsScreen extends StatefulWidget {
  final Car currentCar;
  final List<Car> allCars;

  const CompareCarsScreen({
    Key? key,
    required this.currentCar,
    required this.allCars,
  }) : super(key: key);

  @override
  State<CompareCarsScreen> createState() => _CompareCarsScreenState();
}

class _CompareCarsScreenState extends State<CompareCarsScreen> {
  List<Car> selectedCars = [];

  @override
  void initState() {
    super.initState();
    selectedCars.add(widget.currentCar);
  }

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
            title: const Text("Car Compare",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.allCars.length,
                itemBuilder: (context, index) {
                  Car car = widget.allCars[index];
                  bool isSelected = selectedCars.contains(car);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (!isSelected && selectedCars.length < 3) {
                          selectedCars.add(car);
                        } else if (isSelected && car != widget.currentCar) {
                          selectedCars.remove(car);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.all(10),
                      width: 150,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.white70,
                        border: Border.all(color: isSelected ? Colors.blueAccent : Colors.grey),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(car.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 4),
                          Text("₹${car.totalPrice.toStringAsFixed(0)}",
                              style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: selectedCars.length < 2
                  ? const Center(
                child: Text(
                  'Select at least 2 cars to compare',
                  style: TextStyle(color: Colors.black87, fontSize: 16),
                ),
              )
              : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(ColorSys.purple1),
                      columnSpacing: 24,
                      columns: [
                        const DataColumn(
                          label: Text(
                            'Feature',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ),
                        ...selectedCars
                            .map(
                              (car) => DataColumn(
                            label: Column(
                              children: [
                                Text(car.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, color: Colors.black87)),
                                Text("₹${car.totalPrice.toStringAsFixed(0)}",
                                    style: const TextStyle(color: Colors.black54, fontSize: 12)),
                              ],
                            ),
                          ),
                        ).toList(),
                      ],
                      rows: _buildComparisonRows(selectedCars),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DataRow> _buildComparisonRows(List<Car> cars) {
    return [
      _buildRow('Brand', cars.map((c) => c.brand).toList()),
      _buildRow('Price', cars.map((c) => '₹${c.totalPrice.toStringAsFixed(2)}').toList()),
      _buildRow('Mileage', cars.map((c) => '${c.mileage} km/l').toList()),
      _buildRow('Transmission', cars.map((c) => c.transmission).toList()),
      _buildRow('Seats', cars.map((c) => '${c.seats}').toList()),
      _buildRow('Top Speed', cars.map((c) => '${c.topSpeed} km/h').toList()),
      _buildRow('Horsepower', cars.map((c) => '${c.horsepower} HP').toList()),
      _buildRow('Body Type', cars.map((c) => c.bodyType).toList()),
      _buildRow('Doors', cars.map((c) => '${c.numberOfDoors}').toList()),
      _buildRow('Length', cars.map((c) => '${c.totalLength} mm').toList()),
      _buildRow('Width', cars.map((c) => '${c.overallWidth} mm').toList()),
      _buildRow('Height', cars.map((c) => '${c.overallHeight} mm').toList()),
      _buildRow('Wheelbase', cars.map((c) => '${c.wheelbase} mm').toList()),
      _buildRow('Ground Clearance', cars.map((c) => '${c.groundClearance} mm').toList()),
      _buildRow('Boot Capacity', cars.map((c) => '${c.bootCapacity} L').toList()),
      _buildRow('Fuel Tank', cars.map((c) => '${c.fuelTankCapacity} L').toList()),
    ];
  }

  DataRow _buildRow(String feature, List<String> values) {
    List<double?> numericValues = values.map((v) {
      String digitsOnly = v.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(digitsOnly);
    }).toList();

    bool allNumeric = numericValues.every((val) => val != null);
    double? maxVal = allNumeric ? numericValues.reduce((a, b) => a! > b! ? a : b)! : null;
    double? minVal = allNumeric ? numericValues.reduce((a, b) => a! < b! ? a : b)! : null;

    return DataRow(
      cells: [
        DataCell(Text(feature,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87))),
        ...List.generate(values.length, (i) {
          final value = values[i];
          Color color = Colors.black87;
          FontWeight weight = FontWeight.normal;

          if (allNumeric) {
            double current = numericValues[i]!;
            if (current == maxVal) {
              color = Colors.green;
              weight = FontWeight.bold;
            } else if (current == minVal) {
              color = Colors.red;
              weight = FontWeight.bold;
            }
          } else if (values.toSet().length > 1) {
            color = Colors.blueAccent;
            weight = FontWeight.bold;
          }

          return DataCell(Text(
            value,
            style: TextStyle(color: color, fontWeight: weight),
          ));
        }),
      ],
    );
  }
}
