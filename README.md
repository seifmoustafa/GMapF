# **Google Maps Tracking Application Documentation**

## **Overview**

This is a simple mobile application built with Flutter, leveraging the **Google Maps API**. The app allows users to:

- **Type a location** and set it as a destination.
- **Get the current location** of the user.
- **Track user movement** in real-time until the destination is reached.

## **Features**

- **Current Location Detection**: The app automatically detects and displays the user’s current location on the map.
- **Real-Time Tracking**: As the user moves, the app continuously updates their location on the map.
- **Destination Entry**: Users can input a destination (either manually or using a search field).
- **Navigation**: The app tracks the user’s path, updating as they approach their destination.
  
## **Installation**

To run this app locally, follow the steps below:

### **Prerequisites**

- **Flutter**: Ensure you have Flutter installed. You can follow the installation guide on the [official Flutter site](https://flutter.dev/docs/get-started/install).
- **Google Maps API Key**: You will need a Google Maps API key to use the Google Maps services. Follow the guide to [get your API key](https://developers.google.com/maps/gmp-get-started).

### **Steps to Install**

1. Clone the repository:
   ```bash
   git clone https://github.com/seifmoustafa/GMapF.git
   ```

2. Navigate into the project directory:
   ```bash
   cd GMapF
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Add your **Google Maps API Key**:
   - Open `android/app/src/main/AndroidManifest.xml`
   - In the `<application>` tag, add the following line with your API key:
   ```xml
   <meta-data
     android:name="com.google.android.maps.v2.API_KEY"
     android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
   ```

5. Run the application:
   ```bash
   flutter run
   ```

## **App Flow**

1. **Launch Screen**: Upon launching the app, the map will appear with a button to get the user's current location.
2. **Enter Destination**: Users can either search for a location or type the destination manually.
3. **Tracking**: The app will show the user’s current location, updating in real-time as they move.
4. **Arrival Notification**: Once the user reaches the destination, the app will notify them.

## **Technologies Used**

- **Flutter**: Cross-platform mobile app development framework.
- **Google Maps API**: For displaying maps and tracking locations.
- **Geolocator Package**: To fetch the user’s current location.

## **Troubleshooting**

- **Google Maps Not Loading**: Ensure your API key is correctly set in the AndroidManifest file and that you’ve enabled the necessary APIs in the Google Cloud Console.
- **Location Tracking Issue**: If the app isn’t tracking location properly, ensure the device has location services enabled and permissions granted.

## **Contributing**

Feel free to open issues or submit pull requests for any bugs or features. Contributions are always welcome!


