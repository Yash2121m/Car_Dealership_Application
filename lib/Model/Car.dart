// Sedan Cars
import 'Car_Mode.dart';

List<Car> sedanCars = [
  Car(
    image: 'images/sedan1.png',
    name: 'Toyota Camry',
    transmission: 'Automatic',
    seats: 4,
    totalPrice: 2500000, // price in rupees
    topSpeed: 220,
    mileage: 6.0,
    horsepower: 400,
    description: "The 2024 Toyota Camry is the ninth-generation for the sedan. It is positioned above the Innova Hycross in the brand's India range.",
  ),
  Car(
    image: 'images/sedan2.png',
    name: 'Honda Accord',
    transmission: 'Automatic',
    seats: 4,
    totalPrice: 2300000, // price in rupees
    topSpeed: 210,
    mileage: 5.8,
    horsepower: 470,
    description: "Honda Accord is a 5 seater Sedan with the last recorded price of Rs. 44.28 Lakh. It is available in 1 variant, 1993 cc engine option and 1 transmission option : Automatic.",
  ),
  Car(
    image: 'images/sedan3.png',
    name: 'Nissan Altima',
    transmission: 'Automatic',
    seats: 5,
    totalPrice: 1900000, // price in rupees
    topSpeed: 210,
    mileage: 5.5,
    horsepower: 400,
    description: "Imagine a sedan that gives you the kind of capability you’d expect from an SUV. Paired with Altima’s 2.5L engine, the available Intelligent All-Wheel Drive system continuously monitors road conditions"
  ),
  Car(
    image: 'images/sedan4.png',
    name: 'Hyundai Sonata',
    transmission: 'Automatic',
    seats: 5,
    totalPrice: 2000000, // price in rupees
    topSpeed: 200,
    mileage: 6.2,
    horsepower: 430,
    description: "Hyundai Sonata is a 5 seater Sedan with the last recorded price of Rs. 19.46 - 21.57 Lakh. It is available in 2 variants, 2359 cc engine option and 2 transmission options : Manual and Automatic."
  ),
  Car(
    image: 'images/sedan5.png',
    name: 'Mazda 6',
    transmission: 'Automatic',
    seats: 5,
    totalPrice: 2200000, // price in rupees
    topSpeed: 220,
    mileage: 5.9,
    horsepower: 450,
    description: "The Mazda6 Sedan is a sophisticated and stylish vehicle that has retained its allure despite its age. It features a luxurious interior with 10-way power adjustable drivers seat"
  ),
];

// SUV Cars
List<Car> suvCars = [
  Car(
    image: 'images/suv1.png',
    name: 'Ford Explorer',
    transmission: 'Automatic',
    seats: 5,
    totalPrice: 3500000, // price in rupees
    topSpeed: 210,
    mileage: 7.0,
    horsepower: 650,
    description: "Brawny broad-shouldered styling, available hearty V-6, new 12.3-inch infotainment touchscreen and software."
  ),
  Car(
    image: 'images/suv2.png',
    name: 'Jeep Wrangler',
    transmission: 'Manual',
    seats: 5,
    totalPrice: 3300000, // price in rupees
    topSpeed: 200,
    mileage: 6.5,
    horsepower: 620,
    description: "Intuitive technology like Adaptive Cruise Control & Forward Collision Warning let you venture out with confidence. "
  ),
  Car(
    image: 'images/suv3.png',
    name: 'Toyota Highlander',
    transmission: 'Automatic',
    seats: 7,
    totalPrice: 3500000, // price in rupees
    topSpeed: 200,
    mileage: 6.8,
    horsepower: 680,
    description: "It is offered in two powertrains, a 3.5L V6 gas and a 2.5L hybrid motor. The 3.5L V6 engine comes mated to an 8-speed direct shift automatic transmission."
  ),
  Car(
    image: 'images/suv41.png',
    name: 'Honda CR-V',
    transmission: 'Automatic',
    seats: 5,
    totalPrice: 2700000, // price in rupees
    topSpeed: 190,
    mileage: 7.5,
    horsepower: 620,
    description: "Honda CR V is a 5 seater SUV with the last recorded price of Rs. 28.34 - 32.84 Lakh. It is available in 5 variants, 1597 to 1997 cc engine options and 1 transmission option : Automatic."
  ),
  Car(
    image: 'images/suv5.png',
    name: 'Chevrolet Tahoe',
    transmission: 'Automatic',
    seats: 7,
    totalPrice: 4000000, // price in rupees
    topSpeed: 210,
    mileage: 6.0,
    horsepower: 576,
    description: "5.3L EcoTec3 V8 engine with Dynamic Fuel Management and 10-speed automatic transmission 18-inch Bright Silver-painted aluminum wheels and all-season tires 17.7-inch diagonal center touch-screen display "
  ),
];

// Sports Cars
List<Car> sportsCars = [
  Car(
    image: 'images/sports1.png',
    name: 'Chevrolet Corvette',
    transmission: 'Automatic',
    seats: 2,
    totalPrice: 5000000, // price in rupees
    topSpeed: 300,
    mileage: 4.0,
    horsepower: 495,
    description: "Stingray features a naturally aspirated V8 that’s positioned behind the driver, putting more power to the rear wheels where it matters most. And with a quarter-mile time of just 11.2 seconds"
  ),
  Car(
    image: 'images/sports2.png',
    name: 'Porsche 911',
    transmission: 'Automatic',
    seats: 2,
    totalPrice: 6000000, // price in rupees
    topSpeed: 310,
    mileage: 3.8,
    horsepower: 1050,
    description: "911 has been the epitome of an exciting, powerful sports car with day-to-day usability for 60 years. Take a seat behind the wheel of the new 911 and become part of a unique community."
  ),
  Car(
    image: 'images/sports3.png',
    name: 'Ferrari 488',
    transmission: 'Automatic',
    seats: 2,
    totalPrice: 6500000, // price in rupees
    topSpeed: 325,
    mileage: 3.5,
    horsepower: 1050,
    description: "The Ferrari 488 Pista is powered by the most powerful V8 engine in the Maranello marque’s history and is the company’s special series sports car with the highest level yet of technological transfer from racing."
  ),
  Car(
    image: 'images/sports4.png',
    name: 'Lamborghini Huracán',
    transmission: 'Automatic',
    seats: 2,
    totalPrice: 12000000, // price in rupees
    topSpeed: 330,
    mileage: 3.2,
    horsepower: 1100,
    description: "Sculptured and sensual, the Huracán’s design is based on the spiky hexagonal forms of the carbon atom, while the seamless roof profile is an unmistakable mark of the Lamborghini DNA."
  ),
  Car(
    image: 'images/sports5.png',
    name: 'Audi R8',
    transmission: 'Automatic',
    seats: 2,
    totalPrice: 11000000, // price in rupees
    topSpeed: 315,
    mileage: 3.6,
    horsepower: 1080,
    description: "Audi R8 is a 2 seater Coupe with the last recorded price of Rs. 2.30 - 2.72 Crore. It is available in 2 variants, 5204 cc engine option and 2 transmission options : Manual and Automatic"
  ),
];

// Luxury Cars
List<Car> luxuryCars = [
  Car(
    image: 'images/luxury1.png',
    name: 'Mercedes-Benz\nS-Class',
    transmission: 'Automatic',
    seats: 5,
    totalPrice: 9000000, // price in rupees
    topSpeed: 250,
    mileage: 5.5,
    horsepower: 800,
    description: "Modern luxury and first-class comfort reach a new level in the S-Class. It is the ideal haven for anyone for whom driving a car will always be about much more than simply transport."
  ),
  Car(
    image: 'images/luxury2.png',
    name: 'BMW 7 Series',
    transmission: 'Automatic',
    seats: 5,
    totalPrice: 8500000, // price in rupees
    topSpeed: 240,
    mileage: 5.7,
    horsepower: 850,
    description: "Pure elegance and multisensory entertainment come together in the BMW 7 Series Sedan to produce an absolute premium driving experience"
  ),
  Car(
    image: 'images/luxury3.png',
    name: 'Audi A8',
    transmission: 'Automatic',
    seats: 5,
    totalPrice: 8000000, // price in rupees
    topSpeed: 230,
    mileage: 5.8,
    horsepower: 820,
    description: "The price of Audi A8 L, a 4 seater Sedan, ranges from Rs. 1.34 - 1.63 Crore. It is available in 2 variants, with an engine of 2995 cc and a choice of 1 transmission: Automatic"
  ),
  Car(
    image: 'images/luxury4.png',
    name: 'Lexus LS',
    transmission: 'Automatic',
    seats: 5,
    totalPrice: 7500000, // price in rupees
    topSpeed: 230,
    mileage: 6.0,
    horsepower: 810,
    description: "Lexus LS is a 4 seater Sedan with the last recorded price of Rs. 1.82 - 2.27 Crore. It is available in 7 variants, 3456 cc engine option and 1 transmission option : Automatic."
  ),
  Car(
    image: 'images/luxury5.png',
    name: 'Jaguar XJ',
    transmission: 'Automatic',
    seats: 5,
    totalPrice: 7000000, // price in rupees
    topSpeed: 220,
    mileage: 6.2,
    horsepower: 800,
    description: "Jaguar XJ L is a 4 seater Sedan with the last recorded price of Rs. 99.56 Lakh - 1.97 Crore. It is available in 6 variants, 1999 to 5000 cc engine options and 1 transmission option : Automatic."
  ),
];

// Offroad Cars
List<Car> offroadCars = [
  Car(
    image: 'images/offroad1.png',
    name: 'Jeep Gladiator',
    transmission: 'Manual',
    seats: 4,
    totalPrice: 3500000, // price in rupees
    topSpeed: 180,
    mileage: 6.2,
    horsepower: 780,
    description: "All-conquering off-road abilities, the only pickup with removable doors and roof, strong towing capacity."
  ),
  Car(
    image: 'images/offroad2.png',
    name: 'Land Rover Defender',
    transmission: 'Automatic',
    seats: 5,
    totalPrice: 4500000, // price in rupees
    topSpeed: 190,
    mileage: 6.0,
    horsepower: 800,
    description: "The Land Rover Defender impresses with three- and five-door options, and a choice of three petrol and one diesel engine. Its unusual road presence, tank-like build quality."
  ),
  Car(
    image: 'images/offroad3.png',
    name: 'Toyota Land Cruiser',
    transmission: 'Automatic',
    seats: 5,
    totalPrice: 5500000, // price in rupees
    topSpeed: 180,
    mileage: 6.5,
    horsepower: 850,
    description: "The Land Cruiser boasts tank-like build quality and a spacious cabin for five with comfortable seats and enormous boot space. With loads of V6 diesel power, excellent visibility."
  ),
  Car(
    image: 'images/offroad4.png',
    name: 'Ford Bronco',
    transmission: 'Manual',
    seats: 4,
    totalPrice: 4000000, // price in rupees
    topSpeed: 170,
    mileage: 6.8,
    horsepower: 800,
    description: "The new model is offered in both two-door and four-door variants. Ford Bronco comes with two powertrain options, a 2.3L EcoBoost 4-cylinder and a 2.7L Turbo EcoBoost V6. "
  ),
  Car(
    image: 'images/offroad5.png',
    name: 'Mercedes-Benz\nG-Class',
    transmission: 'Automatic',
    seats: 5,
    totalPrice: 9000000, // price in rupees
    topSpeed: 200,
    mileage: 5.0,
    horsepower: 850,
    description: "The G-Class remains true to itself: In the interior, it combines impressive high-value appeal with a strong design idiom. Fine materials and a perfect finish enrich the interior."
  ),
];
