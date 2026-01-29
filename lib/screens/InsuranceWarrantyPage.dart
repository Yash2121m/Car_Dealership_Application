import 'package:flutter/material.dart';

import '../Assistance/ColorHelper.dart';

class InsuranceWarrantyScreen extends StatefulWidget {
  final Map<String, String>? selectedInsurance;
  final Map<String, String>? selectedWarranty;

  const InsuranceWarrantyScreen({
    Key? key,
    this.selectedInsurance,
    this.selectedWarranty,
  }) : super(key: key);

  @override
  _InsuranceWarrantyScreenState createState() =>
      _InsuranceWarrantyScreenState();
}

class _InsuranceWarrantyScreenState extends State<InsuranceWarrantyScreen> {
  Map<String, String>? _insurance;
  Map<String, String>? _warranty;

  // 🔹 Insurance Plans
  final List<Map<String, String>> insurancePlans = [
    {
      "title": "No Insurance",
      "subtitle": "Skip insurance plan selection.",
      "price": "₹0",
      "icon": "❌",
    },
    {
      "title": "Basic Insurance",
      "subtitle": "Covers only third-party damages.",
      "price": "₹5,000 / year",
      "icon": "🛡️",
    },
    {
      "title": "Comprehensive Insurance",
      "subtitle": "Covers both own vehicle & third-party.",
      "price": "₹12,000 / year",
      "icon": "🚗",
    },
    {
      "title": "Premium Insurance",
      "subtitle": "Full protection with add-ons (engine, theft, floods).",
      "price": "₹20,000 / year",
      "icon": "⭐",
    },
  ];

  // 🔹 Warranty Plans
  final List<Map<String, String>> warrantyPlans = [
    {
      "title": "No Warranty",
      "subtitle": "Skip warranty plan selection.",
      "price": "₹0",
      "icon": "❌",
    },
    {
      "title": "1-Year Standard Warranty",
      "subtitle": "Extends manufacturer warranty by 1 year.",
      "price": "₹8,000",
      "icon": "📅",
    },
    {
      "title": "3-Year Comprehensive Warranty",
      "subtitle": "Covers major parts + extended service.",
      "price": "₹18,000",
      "icon": "⚙️",
    },
    {
      "title": "5-Year Premium Warranty",
      "subtitle": "Complete coverage + free roadside assistance.",
      "price": "₹30,000",
      "icon": "🏆",
    },
  ];

  @override
  void initState() {
    super.initState();
    _insurance = widget.selectedInsurance;
    _warranty = widget.selectedWarranty;
  }

  void _confirmSelection() {
    Navigator.pop(context, {
      "insurance": _insurance,
      "warranty": _warranty,
    });
  }

  Widget _buildPlanCard({
    required Map<String, String> plan,
    required Map<String, String>? selectedValue,
    required Function(Map<String, String>) onChanged,
  }) {
    final isSelected = selectedValue?["title"] == plan["title"];

    return GestureDetector(
      onTap: () => onChanged(plan),
      child: Card(
        elevation: isSelected ? 6 : 2,
        shadowColor: isSelected ? Colors.deepPurple.withOpacity(0.3) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(plan["icon"]!, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan["title"]!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.deepPurple : Colors.black,
                        )),
                    const SizedBox(height: 4),
                    Text(plan["subtitle"]!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        )),
                    const SizedBox(height: 6),
                    Text(plan["price"]!,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: plan["price"] == "₹0"
                              ? Colors.red
                              : Colors.green.shade700,
                        )),
                  ],
                ),
              ),
              Radio<Map<String, String>>(
                value: plan,
                groupValue: selectedValue,
                onChanged: (val) {
                  if (val != null) onChanged(val);
                },
                activeColor: Colors.deepPurple,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            title: const Text("Insurance & Warranty Plans",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  const Text(
                    "Choose Your Insurance Plan",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...insurancePlans.map(
                        (plan) => _buildPlanCard(
                      plan: plan,
                      selectedValue: _insurance,
                      onChanged: (val) => setState(() => _insurance = val),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Choose Your Warranty Plan",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...warrantyPlans.map(
                        (plan) => _buildPlanCard(
                      plan: plan,
                      selectedValue: _warranty,
                      onChanged: (val) => setState(() => _warranty = val),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _insurance != null || _warranty != null
                  ? _confirmSelection
                  : null,
              icon: const Icon(Icons.check_circle),
              label: const Text("Confirm Selection"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent[100],
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
