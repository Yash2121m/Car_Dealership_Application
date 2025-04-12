# 🚗 Car Dealer App – Flutter Project

Welcome to **Car Dealer** – a sleek and modern mobile app built with Flutter, where users can explore, favorite, and book cars with ease!

---

## 📲 App Overview

Car Dealer is your all-in-one solution to browse cars, manage wishlists, book test drives or purchases, and manage addresses — all backed by **Firebase** for real-time data handling.

---

## ✨ Features

### 🔐 User Authentication
- 🔑 Secure login & signup using **Firebase Authentication**
- 📧 Email/Password and optional Google Sign-In
- 👤 Auth-based access to user-specific data
<img src="https://github.com/user-attachments/assets/511fc3df-c0ec-43f3-acaa-98ad9a2a672b" width="300"/>
<img src="https://github.com/user-attachments/assets/04b3e207-a607-4114-9a03-724facaed274" width="300"/>

### 🚘 Car Listings
- 🛻 View a wide range of cars with images, models, and pricing
- 🔎 Optional filters/search functionality
- 📄 Detailed car information on tap
<img src="https://github.com/user-attachments/assets/e809f662-5960-4656-afbd-61cc0794f822" width="300"/>
<img src="https://github.com/user-attachments/assets/02388f19-92fa-4c9f-9e5a-2f2035f753be" width="300"/>
<img src="https://github.com/user-attachments/assets/1d4206de-415d-457c-9cb0-159b59ac9e2f" width="300"/>

### ❤️ Wishlist System
- 💾 Add or remove cars from your wishlist
- 🔄 Wishlist is synced in real-time with Firebase
- 🧡 Easy access to your favorite vehicles
<img src="https://github.com/user-attachments/assets/1f0ab288-517b-413b-8b27-cf8cd7435a9a" width="300"/>


### 🚘 Car Listings & Details
- 🏎️ Browse a collection of premium and budget-friendly cars
- 📷 View HD images of each car
- 📋 Car detail screen includes:
  - ✅ Model & brand name  
  - ⚙️ Engine type  
  - ⛽ Fuel type & mileage  
  - 💵 Price  
  - 📅 Year of manufacture  
  - 🌈 Available colors  
- 📖 Full spec breakdown for informed decisions
<img src="https://github.com/user-attachments/assets/965438e1-c9b7-41ea-aaf9-69c175b82532" width="300"/>

### 📅 Booking System
- 📝 Book cars with just a few taps
- 📍 Select an address for the booking
- 📊 Bookings stored in **Firebase Realtime Database**
<img src="https://github.com/user-attachments/assets/198f188e-865a-4ed3-b6e6-1de699fa2988" width="300"/>

### 💸 EMI Booking System
- 📆 Book cars using EMI (Equated Monthly Installment) option
- 🔢 Built-in EMI calculator:
  - Input down payment
  - Select duration (in months)
  - Auto-calculate monthly EMI
- 🧾 Shows total payable amount with interest
- 💾 Booking and EMI details stored in Firebase
<img src="https://github.com/user-attachments/assets/2c76a618-460a-47ae-9ffa-ca37271ad773" width="300"/>

### 🧾 Profile & Address Management
- 👤 Update profile information
- 🏠 Add, edit, or delete addresses
- 🌐 Use address data for booking purposes
<img src="https://github.com/user-attachments/assets/2a1a618f-7eff-4304-8600-24ddacfe5102" width="300"/>

### 📦 Order Management – Firebase Integration

- 📥 Fetches all user bookings (orders) from **Firebase Realtime Database**
- 🧾 Displays:
  - 🚘 Car name, 💵 price, and 📅 booking date
  - 📍 Selected address details
  - 💳 EMI-related data (if applicable)
- 🔄 Real-time updates whenever the booking is modified in Firebase
- 👤 User-specific order fetching using Firebase UID
- 📃 Neatly formatted booking history screen
- 🔍 Allows filtering recent or past orders
<img src="https://github.com/user-attachments/assets/b95cb666-9950-4898-a5a5-848459183d31" width="300"/>


---

#### 🧱 Firebase Data Structure Example

json
Bookings: {
  "userUID123": {
    "bookingId001": {
      "carName": "Tesla Model 3",
      "price": "₹45,00,000",
      "bookingDate": "2025-04-10",
      "emi": {
        "monthlyEmi": "₹45,000",
        "duration": "12 months",
        "downPayment": "₹5,00,000"
      },
      "address": "123, MG Road, Mumbai"
    },
    "bookingId002": {
      "carName": "Hyundai Creta",
      "price": "₹15,00,000",
      "bookingDate": "2025-04-11",
      "emi": null,
      "address": "456, Bandra West, Mumbai"
    }
  }
}

### 🔁 Firebase Realtime Integration
- ☁️ Syncs:
  - Car data
  - Wishlist
  - Bookings
  - User addresses
- 🔃 Real-time updates across the app

### 🤖 AI Car Recommendation *(Planned Feature)*
- 🧠 Suggests cars using a TensorFlow-based ML model
- 📚 Learns from wishlist and bookings to give smart suggestions

---

## 🛠 Tech Stack

| Tool | Purpose |
|------|---------|
| 💙 Flutter | Frontend UI |
| 🎯 Dart | Programming language |
| 🔥 Firebase | Auth, Realtime Database |
| 📦 Provider / Riverpod | State management |

