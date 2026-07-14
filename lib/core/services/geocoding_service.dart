import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org/reverse';
  
  // Cache to prevent duplicate requests
  static final Map<String, String> _addressCache = {};

  static Future<String> getAddressFromLatLng(double lat, double lng) async {
    final cacheKey = '${lat.toStringAsFixed(4)},${lng.toStringAsFixed(4)}';
    
    if (_addressCache.containsKey(cacheKey)) {
      return _addressCache[cacheKey]!;
    }

    try {
      final uri = Uri.parse('$_baseUrl?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1');
      final response = await http.get(
        uri, 
        headers: {
          'User-Agent': 'MotorcycleManagementApp/1.0',
          'Accept-Language': 'id-ID,id;q=0.9,en-US;q=0.8,en;q=0.7',
        }
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['display_name'] != null) {
          // Format better address
          String address = data['display_name'];
          
          // Optionally simplify address (e.g., take first 3-4 components)
          final parts = address.split(', ');
          if (parts.length > 3) {
            address = parts.take(4).join(', ');
          }
          
          _addressCache[cacheKey] = address;
          return address;
        }
      }
      return 'Lokasi tidak diketahui';
    } catch (e) {
      print('Geocoding error: $e');
      return 'Gagal memuat alamat';
    }
  }
}
