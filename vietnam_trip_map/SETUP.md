# Vietnam Trip Map - Setup Guide

A Flutter app for planning your Vietnam trip with an interactive map and custom pins.

## Features

- 🗺️ Interactive MapBox map
- 📍 Custom pins with categories (shopping, activity, food, beauty, hotel)
- 💾 Data persistence with Supabase
- 🎨 Beautiful UI with handwritten-style markers
- 📱 Simple single-user design

## Prerequisites

- Flutter SDK (3.8.1 or higher)
- Supabase account (free tier works)
- MapBox account (free tier works)

## Setup Instructions

### 1. Supabase Setup

1. Go to [supabase.com](https://supabase.com) and create a free account
2. Create a new project
3. Once the project is ready, go to the SQL Editor
4. Run this SQL to create the pins table:

```sql
CREATE TABLE pins (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  type TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Enable Row Level Security
ALTER TABLE pins ENABLE ROW LEVEL SECURITY;

-- Create a policy that allows all operations (since this is single-user)
CREATE POLICY "Allow all operations" ON pins
  FOR ALL
  USING (true)
  WITH CHECK (true);
```

5. Go to Settings > API to get your:
   - Project URL (looks like: `https://xxxxx.supabase.co`)
   - Anon/Public Key (starts with `eyJ...`)

### 2. MapBox Setup

1. Go to [mapbox.com](https://www.mapbox.com) and create a free account
2. Go to your Account page
3. Copy your default public access token (starts with `pk.`)

### 3. Configure the App

Open `lib/config/app_config.dart` and replace the placeholder values:

```dart
class AppConfig {
  static const String supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';
  static const String mapboxAccessToken = 'YOUR_MAPBOX_TOKEN';

  // Update these to your preferred starting location
  static const double defaultLatitude = 10.8231;  // Ho Chi Minh City
  static const double defaultLongitude = 106.6297;
  static const double defaultZoom = 12.0;
}
```

### 4. iOS Setup (if testing on iOS)

Add the following to `ios/Runner/Info.plist` before the final `</dict>`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show you on the map</string>
<key>io.flutter.embedded_views_preview</key>
<true/>
```

### 5. Android Setup (if testing on Android)

Add the following to `android/app/src/main/AndroidManifest.xml` inside the `<application>` tag:

```xml
<meta-data
    android:name="com.mapbox.token"
    android:value="YOUR_MAPBOX_ACCESS_TOKEN" />
```

Also add these permissions before the `<application>` tag:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET"/>
```

### 6. Run the App

```bash
flutter pub get
flutter run
```

## How to Use

1. **Sign In**: Enter your name on the welcome screen
2. **Add a Pin**: Tap the "Add Pin" button, select a category, and add details
3. **View Pins**: Tap the list icon in the header to see all saved places
4. **Navigate**: Tap on a pin in the list to fly to it on the map
5. **Delete Pins**: Swipe or tap the delete icon in the pin list

## Pin Categories

- 🛍️ **Shopping**: Stores, markets, boutiques
- 🎨 **Activity**: Museums, tours, attractions
- 🍴 **Food**: Restaurants, cafes, street food
- 💅 **Beauty**: Salons, spas, nail shops
- 🏨 **Hotel**: Hotels, hostels, accommodations

## Troubleshooting

### MapBox not showing
- Verify your MapBox token is correct in `app_config.dart`
- For Android, ensure the token is also in `AndroidManifest.xml`
- Check that you have internet connectivity

### Supabase errors
- Verify your Supabase URL and anon key are correct
- Ensure the `pins` table was created successfully
- Check that Row Level Security policies are set up

### Build errors
- Run `flutter clean` then `flutter pub get`
- Make sure you're using Flutter 3.8.1 or higher

## Project Structure

```
lib/
├── config/
│   └── app_config.dart          # App configuration
├── models/
│   └── pin.dart                 # Pin data model
├── screens/
│   ├── signin_screen.dart       # Welcome/sign-in screen
│   └── map_screen.dart          # Main map view
├── services/
│   └── supabase_service.dart    # Database operations
├── widgets/
│   ├── add_pin_dialog.dart      # Dialog for adding new pins
│   └── pin_list_bottom_sheet.dart # Bottom sheet for viewing pins
└── main.dart                    # App entry point
```

## Next Steps

- Customize the pin categories to match your trip needs
- Adjust the default map location to your destination
- Add more fields to pins (photos, ratings, etc.)
- Export your pins to share with travel companions

Enjoy planning your Vietnam trip!
