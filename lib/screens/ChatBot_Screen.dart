import 'package:cardealer/Assistance/ColorHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Your models
import '../Model/AllCars.dart';
import '../Model/Car.dart';
import '../Model/Car_Mode.dart'; // ensure this exposes fields used below

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<types.Message> _messages = [];
  final types.User _user = const types.User(id: 'user', firstName: 'You');
  final types.User _bot = const types.User(id: 'bot', firstName: 'Assistant');
  final _uuid = const Uuid();

  // ====== Quick brand/fuel/type dictionaries (extend to your dataset) ======
  static const _brands = <String>{
    'tata','maruti','suzuki','maruti suzuki','hyundai','kia','mahindra','honda',
    'toyota','mg','skoda','volkswagen','vw','nissan','renault','jeep','bmw',
    'mercedes','mercedes-benz','audi','jaguar','land rover','volvo','lexus',
    'citroen','porsche','ferrari','lamborghini','bugatti','rolls-royce','mini'
  };

  static const _fuelMap = {
    'petrol': 'Petrol',
    'diesel': 'Diesel',
    'electric': 'Electric',
    'ev': 'Electric',
    'cng': 'CNG',
    'hybrid': 'Hybrid',
  };

  // normalize user mentions to your bodyType values
  static const _typeMap = {
    'suv': 'SUV',
    'sedan': 'Sedan',
    'hatchback': 'Hatchback',
    'hetchback': 'Hatchback', // common typo
    'convertible': 'Convertible',
    'coupe': 'Coupe',
    'mpv': 'MPV',
    'muv': 'MPV',
    'pickup': 'Pickup',
    'truck': 'Pickup',
    'sports': 'Sports',
    'sport': 'Sports',
    'luxury': 'Luxury',
    'offroad': 'Offroad',
    'off-road': 'Offroad',
    'crossover': 'Crossover',
  };

  // ====== CHAT HANDLERS ======
  Future<void> _handleSendPressed(types.PartialText message) async {
    final userMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: _uuid.v4(),
      text: message.text,
    );

    setState(() {
      _messages.insert(0, userMessage);
    });

    // Insert temporary typing indicator
    final typingId = _uuid.v4();
    final typingMessage = types.CustomMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: typingId,
      metadata: {"typing": true}, // custom flag
    );

    setState(() {
      _messages.insert(0, typingMessage);
    });

    // Start timer
    final start = DateTime.now();

    final botReply = await _getSmartCarSuggestion(message.text);

    // Calculate elapsed time
    final elapsed = DateTime.now().difference(start).inMilliseconds / 1000.0;
    final responseTime = elapsed.toStringAsFixed(1);

    // Remove typing indicator
    setState(() {
      _messages.removeWhere((m) => m.id == typingId);
    });

    // Add actual bot message
    final botMessage = types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: _uuid.v4(),
      text: "$botReply\n\n⏱️ Responded in ${responseTime}s",
    );

    setState(() {
      _messages.insert(0, botMessage);
    });
  }


  // ====== MAIN SUGGESTION PIPELINE ======
  Future<String> _getSmartCarSuggestion(String prompt) async {
    // 1) Extract preferences from free text
    final prefs = _extractPreferences(prompt);

    // 2) Run scoring & ranking against your allCars list
    final ranked = _rankCars(allCars, prefs);

    // 3) Build response
    if (ranked.isEmpty) {
      // fallback: nearest-by-price suggestions even if other prefs miss
      final nearest = _closestByPrice(allCars, prefs);
      if (nearest.isEmpty) {
        return "I couldn’t find anything matching that. Try sharing a budget (e.g. “under 10 lakh”) or a type (e.g. “SUV”).";
      }
      return _buildResponse(
        title: "No exact matches. Closest by price:",
        cars: nearest.take(3).toList(),
        prefs: prefs,
      );
    }

    // If user asked something not car-ish (e.g. “what’s your name”), fallback to LLM.
    final looksLikeCarQuery = _looksLikeCarIntent(prompt);
    if (!looksLikeCarQuery) {
      // Only call LLM if user message has nothing to do with cars.
      // If you prefer always trying LLM after suggestions, you can merge both.
      return await _getLLMResponse(prompt);
    }

    return _buildResponse(
      title: "🚗 Recommended for you",
      cars: ranked.take(3).toList(),
      prefs: prefs,
    );
  }

  // ====== INTENT CHECK ======
  bool _looksLikeCarIntent(String text) {
    final s = text.toLowerCase();
    final cues = [
      ..._typeMap.keys,
      ..._fuelMap.keys,
      'budget','price','lakh','lakhs','crore','₹','rs','rupees',
      'automatic','manual','family','mileage','range','performance','sport',
      'boot','space','ground clearance','test drive','book','service','servicing'
    ];
    return cues.any((c) => s.contains(c));
  }

  // ====== PREFERENCE EXTRACTION ======
  _Prefs _extractPreferences(String text) {
    final s = text.toLowerCase();

    // type
    String? bodyType;
    for (final k in _typeMap.keys) {
      if (s.contains(k)) {
        bodyType = _typeMap[k];
        break;
      }
    }

    // fuel
    String? fuelType;
    for (final k in _fuelMap.keys) {
      if (s.contains(k)) {
        fuelType = _fuelMap[k];
        break;
      }
    }

    // brand (first match wins)
    String? brand;
    for (final b in _brands) {
      if (s.contains(b)) {
        // keep original capitalization where possible
        brand = _capitalizeWords(b);
        break;
      }
    }

    // transmission
    String? transmission;
    if (RegExp(r'\bautomatic\b').hasMatch(s)) transmission = 'Automatic';
    if (RegExp(r'\bmanual\b').hasMatch(s)) transmission = 'Manual';

    // intent: mileage/performance/family/offroad
    bool wantsMileage = s.contains('mileage') || s.contains('economy') || s.contains('fuel efficient');
    bool wantsPerformance = s.contains('performance') || s.contains('power') || s.contains('sport');
    bool familyUse = s.contains('family') || s.contains('spacious') || s.contains('space');
    bool offroadUse = s.contains('offroad') || s.contains('off-road');

    // budget parsing
    final budget = _parseBudgetToINR(s);

    return _Prefs(
      bodyType: bodyType,
      fuelType: fuelType,
      brand: brand,
      transmission: transmission,
      budgetMax: budget?.$2,
      budgetMin: budget?.$1,
      wantsMileage: wantsMileage,
      wantsPerformance: wantsPerformance,
      familyUse: familyUse,
      offroadUse: offroadUse,
    );
  }

  /// Accepts patterns like:
  /// - "under 10 lakh", "below 8 lakhs", "budget 12-15 lakh", "around 7 lakh"
  /// - "₹12,50,000", "12.5 lakh", "0.2 crore"
  /// Returns a (min,max) in INR.
  (double, double)? _parseBudgetToINR(String s) {
    // Range like "10-15 lakh"
    final range = RegExp(r'(\d+(\.\d+)?)\s*[-to]+\s*(\d+(\.\d+)?)\s*(lakh|lakhs|crore|cr|k)?').firstMatch(s);
    if (range != null) {
      final a = double.parse(range.group(1)!);
      final b = double.parse(range.group(3)!);
      final unit = (range.group(5) ?? '').toLowerCase();
      final min = _toINR(a, unit);
      final max = _toINR(b, unit);
      return (min, max);
    }

    // "under/below/up to 10 lakh"
    final upper = RegExp(r'(under|below|upto|up to|<=|less than)\s*(\d+(\.\d+)?)\s*(lakh|lakhs|crore|cr|k)?')
        .firstMatch(s);
    if (upper != null) {
      final v = double.parse(upper.group(2)!);
      final unit = (upper.group(4) ?? '').toLowerCase();
      final max = _toINR(v, unit);
      return (0, max);
    }

    // direct INR like "₹12,50,000" or "1250000"
    final money = RegExp(r'(₹|rs\.?\s*)?([\d,]+)').firstMatch(s);
    if (money != null) {
      final numStr = money.group(2)!.replaceAll(',', '');
      final val = double.tryParse(numStr);
      if (val != null && val > 10000) {
        // treat as exact with ±15%
        final min = (val * 0.85);
        final max = (val * 1.15);
        return (min, max);
      }
    }

    // single with unit: "12.5 lakh", "0.2 crore", "800k"
    final single = RegExp(r'(\d+(\.\d+)?)\s*(lakh|lakhs|crore|cr|k)').firstMatch(s);
    if (single != null) {
      final v = double.parse(single.group(1)!);
      final unit = (single.group(3) ?? '').toLowerCase();
      final inr = _toINR(v, unit);
      return (inr * 0.85, inr * 1.15); // ±15% band
    }

    return null;
  }

  double _toINR(double value, String unit) {
    switch (unit) {
      case 'crore':
      case 'cr':
        return value * 10000000;
      case 'lakh':
      case 'lakhs':
        return value * 100000;
      case 'k':
        return value * 1000;
      default:
      // no unit given, assume lakh if value < 100, else assume INR
        if (value < 100) return value * 100000;
        return value;
    }
  }

  // ====== RANKING ======
  List<Car> _rankCars(List<Car> cars, _Prefs p) {
    if (cars.isEmpty) return [];

    // Filter softly first
    final filtered = cars.where((c) {
      final typeOk = p.bodyType == null || _eq(c.bodyType, p.bodyType!);
      final fuelOk = p.fuelType == null || _eq(c.fuelType, p.fuelType!);
      final brandOk = p.brand == null || (c.name.toLowerCase().contains(p.brand!.toLowerCase()));
      final transOk = p.transmission == null || _maybeEq(c, 'transmission', p.transmission!);
      final budgetOk = _withinBudget(c.totalPrice, p.budgetMin, p.budgetMax);
      return typeOk && fuelOk && brandOk && transOk && budgetOk;
    }).toList();

    final pool = filtered.isNotEmpty ? filtered : cars;

    // Score
    final scored = pool.map((c) => (car: c, score: _scoreCar(c, p))).toList();

    // Sort by score desc, then price asc
    scored.sort((a, b) {
      final cmp = b.score.compareTo(a.score);
      if (cmp != 0) return cmp;
      return a.car.totalPrice.compareTo(b.car.totalPrice);
    });

    // If we used the whole pool (no strict matches), take top few still
    final top = scored.take(10).map((e) => e.car).toList();
    return top;
  }

  int _scoreCar(Car c, _Prefs p) {
    int s = 0;

    // Hard matches
    if (p.bodyType != null && _eq(c.bodyType, p.bodyType!)) s += 25;
    if (p.fuelType != null && _eq(c.fuelType, p.fuelType!)) s += 20;
    if (p.brand != null && c.name.toLowerCase().contains(p.brand!.toLowerCase())) s += 15;
    if (p.transmission != null && _maybeEq(c, 'transmission', p.transmission!)) s += 8;

    // Budget proximity (closer to center of band is better)
    if (p.budgetMin != null || p.budgetMax != null) {
      final center = _bandCenter(p.budgetMin, p.budgetMax);
      final diff = (c.totalPrice - center).abs();
      // smaller diff -> higher score
      if (center > 0) {
        final ratio = diff / center; // 0..∞
        if (ratio < 0.1) s += 18;
        else if (ratio < 0.2) s += 14;
        else if (ratio < 0.3) s += 10;
        else if (ratio < 0.5) s += 6;
        else if (ratio < 0.75) s += 3;
      }
      // penalty if way out of band
      if (!_withinBudget(c.totalPrice, p.budgetMin, p.budgetMax)) s -= 10;
    }

    // Soft intents (if your Car has these fields, adjust weights)
    // mileage: prefer higher c.mileage if wantsMileage
    final mileageVal = _getNumField(c, 'mileage'); // e.g., kmpl
    if (p.wantsMileage && mileageVal != null) {
      if (mileageVal >= 22) s += 10;
      else if (mileageVal >= 18) s += 7;
      else if (mileageVal >= 15) s += 4;
    }

    // performance: prefer higher power if available
    final powerVal = _getNumField(c, 'power'); // e.g., bhp
    if (p.wantsPerformance && powerVal != null) {
      if (powerVal >= 180) s += 12;
      else if (powerVal >= 140) s += 8;
      else if (powerVal >= 110) s += 5;
    }

    // family: prefer SUVs/MPVs/Hatchbacks
    if (p.familyUse) {
      final bt = (c.bodyType ?? '').toLowerCase();
      if (bt.contains('suv') || bt.contains('mpv') || bt.contains('hatch')) s += 8;
      // bonus if has 'seater' in description/name
      if ((c.description ?? '').toLowerCase().contains('seater')) s += 3;
    }

    // offroad: prefer Offroad/SUV with description hints
    if (p.offroadUse) {
      final bt = (c.bodyType ?? '').toLowerCase();
      if (bt.contains('off') || bt.contains('suv')) s += 8;
      if ((c.description ?? '').toLowerCase().contains('4x4') ||
          (c.description ?? '').toLowerCase().contains('awd')) s += 5;
    }

    // Optional: rating/popularity if available
    final rating = _getNumField(c, 'rating');
    if (rating != null) s += (rating * 2).toInt(); // gentle boost

    final popularity = _getNumField(c, 'popularity');
    if (popularity != null) s += (popularity ~/ 10);

    return s;
  }

  // ====== HELPERS ======
  bool _eq(String? a, String b) => (a ?? '').toLowerCase() == b.toLowerCase();

  bool _maybeEq(Car c, String field, String value) {
    try {
      final v = (c.toJson()[field] ?? '').toString();
      return v.toLowerCase() == value.toLowerCase();
    } catch (_) {
      return false;
    }
  }

  double _bandCenter(double? min, double? max) {
    if (min != null && max != null) return (min + max) / 2;
    if (min != null) return min;
    if (max != null) return max;
    return 0;
  }

  bool _withinBudget(double price, double? min, double? max) {
    if (min != null && price < min) return false;
    if (max != null && price > max) return false;
    return true;
  }

  num? _getNumField(Car c, String field) {
    try {
      final val = c.toJson()[field];
      if (val == null) return null;
      if (val is num) return val;
      return num.tryParse(val.toString());
    } catch (_) {
      return null;
    }
  }

  String _capitalizeWords(String s) =>
      s.split(' ').map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');

  // If no strict match, show 3 cars closest by price to the center of budget band
  List<Car> _closestByPrice(List<Car> cars, _Prefs p) {
    if (p.budgetMin == null && p.budgetMax == null) return [];
    final center = _bandCenter(p.budgetMin, p.budgetMax);
    final sorted = [...cars]..sort((a, b) =>
        (a.totalPrice - center).abs().compareTo((b.totalPrice - center).abs()));
    return sorted.take(5).toList();
  }

  String _buildResponse({required String title, required List<Car> cars, required _Prefs prefs}) {
    final b = StringBuffer();
    b.writeln(title);

    if (prefs.describe().isNotEmpty) {
      b.writeln("• Based on: ${prefs.describe()}");
    }

    for (final car in cars) {
      b.writeln("\n🔸 ${car.name}");
      b.writeln("   💰 ${_formatINR(car.totalPrice)}");
      if ((car.fuelType).toString().isNotEmpty) {
        b.writeln("   ⛽ ${car.fuelType}");
      }
      if ((car.bodyType).toString().isNotEmpty) {
        b.writeln("   🚘 ${car.bodyType}");
      }
      final rating = _getNumField(car, 'rating');
      if (rating != null) b.writeln("   ⭐ ${rating.toStringAsFixed(1)} / 5");
      final desc = (car.description ?? '').trim();
      if (desc.isNotEmpty) {
        b.writeln("   📄 ${desc.length > 140 ? '${desc.substring(0, 140)}…' : desc}");
      }
    }

    b.writeln("\nTip: Refine with messages like “diesel automatic under 12 lakh” or “family SUV with good mileage”.");
    return b.toString();
  }

  // Indian-style currency
  String _formatINR(num amount) {
    String sign = amount < 0 ? '-' : '';
    amount = amount.abs();
    String s = amount.toStringAsFixed(0);
    if (s.length <= 3) return '₹$sign$s';
    final last3 = s.substring(s.length - 3);
    String head = s.substring(0, s.length - 3);
    final reg = RegExp(r'(\d+)(\d{2})');
    while (reg.hasMatch(head)) {
      head = head.replaceAllMapped(reg, (m) => '${m[1]},${m[2]}');
    }
    return '₹$sign$head,$last3';
  }

  // ====== LLM FALLBACK ======
  Future<String> _getLLMResponse(String prompt) async {
    final apiKey = dotenv.env['CHAT_BOT_API_KEY'];
    final endpoint = dotenv.env['CHAT_BOT_ENDPOINT'];

    try {
      final response = await http.post(
        Uri.parse(endpoint!),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "google/gemini-2.5-flash-lite",
          // "model": "allenai/molmo-2-8b:free",
          // "model": "deepseek/deepseek-chat",
          "messages": [
            {
              "role": "system",
              "content": "You are an assistant for a car dealership app. Help users with bookings, servicing, test drives, and car recommendations. If the user asks for cars, you must keep responses concise and structured."
            },
            {"role": "user", "content": prompt}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['choices'][0]['message']['content'] as String).trim();
      } else {
        return "AI Error: ${response.statusCode}\n${response.body}";
      }
    } catch (e) {
      return "Something went wrong with the AI service. Error: $e";
    }
  }

  // ====== UI ======
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
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
            title: const Text(
              "AI Car Assistant",
              style: TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF0F0F0), Color(0xFFE4E4E4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _messages.isEmpty
            ? _buildWelcomeScreen()
            : Chat(
          messages: _messages,
          onSendPressed: _handleSendPressed,
          user: _user,
          showUserAvatars: true,
          showUserNames: true,
          theme: DefaultChatTheme(
            inputBackgroundColor: Colors.white,
            inputTextColor: Colors.black,
            primaryColor: ColorSys.purple2,
            sentMessageBodyTextStyle:
            const TextStyle(color: Colors.white),
            receivedMessageBodyTextStyle:
            const TextStyle(color: Colors.black87),
            backgroundColor: Colors.transparent,
            userAvatarNameColors: [ColorSys.purple2],
          ),
          avatarBuilder: (user) {
            if (user.id == _bot.id) {
              return Lottie.asset(
                "images/Bot.json",
                width: 50,
                height: 50,
              );
            }
            return CircleAvatar(
              backgroundColor: ColorSys.purple2,
              child: Text(
                user.firstName?[0] ?? '?',
                style: const TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 👋 Welcome Screen when chat is empty
  Widget _buildWelcomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            "images/Bot_Chat.json",
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 20),
          const Text(
            "Welcome to AI Car Assistant",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              setState(() {
                // start chat with a welcome message from bot
                _messages.insert(
                  0,
                  types.TextMessage(
                    author: _bot,
                    createdAt: DateTime.now().millisecondsSinceEpoch,
                    id: _uuid.v4(),
                    text: "Hello 👋! Ask me anything about cars, bookings, or servicing.",
                  ),
                );
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorSys.purple2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              "Begin Chat",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ====== PREFERENCE MODEL ======
class _Prefs {
  final String? bodyType;
  final String? fuelType;
  final String? brand;
  final String? transmission;
  final double? budgetMin;
  final double? budgetMax;
  final bool wantsMileage;
  final bool wantsPerformance;
  final bool familyUse;
  final bool offroadUse;

  _Prefs({
    this.bodyType,
    this.fuelType,
    this.brand,
    this.transmission,
    this.budgetMin,
    this.budgetMax,
    this.wantsMileage = false,
    this.wantsPerformance = false,
    this.familyUse = false,
    this.offroadUse = false,
  });

  String describe() {
    final parts = <String>[];
    if (bodyType != null) parts.add(bodyType!);
    if (fuelType != null) parts.add(fuelType!);
    if (brand != null) parts.add(brand!);
    if (transmission != null) parts.add(transmission!);
    if (budgetMin != null || budgetMax != null) {
      final min = budgetMin != null ? _fmt(budgetMin!) : null;
      final max = budgetMax != null ? _fmt(budgetMax!) : null;
      if (min != null && max != null) parts.add('₹$min–₹$max');
      else if (max != null) parts.add('under ₹$max');
      else if (min != null) parts.add('above ₹$min');
    }
    if (wantsMileage) parts.add('good mileage');
    if (wantsPerformance) parts.add('performance');
    if (familyUse) parts.add('family use');
    if (offroadUse) parts.add('off-road');
    return parts.join(', ');
  }

  String _fmt(double v) {
    // very short INR formatter for describe()
    String s = v.toStringAsFixed(0);
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    String head = s.substring(0, s.length - 3);
    final reg = RegExp(r'(\d+)(\d{2})');
    while (reg.hasMatch(head)) {
      head = head.replaceAllMapped(reg, (m) => '${m[1]},${m[2]}');
    }
    return '$head,$last3';
  }
}
