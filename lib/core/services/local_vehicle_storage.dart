import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/vehicle_model.dart';

class LocalVehicleStorage {
  // Singleton pattern
  static final LocalVehicleStorage _instance = LocalVehicleStorage._internal();
  factory LocalVehicleStorage() => _instance;
  LocalVehicleStorage._internal();

  static const String _vehiclesKey = 'local_vehicles';
  static const String _nextIdKey = 'local_next_vehicle_id';

  /// Get next available local ID
  Future<int> _getNextId() async {
    final prefs = await SharedPreferences.getInstance();
    final currentId = prefs.getInt(_nextIdKey) ?? 1;
    await prefs.setInt(_nextIdKey, currentId + 1);
    return currentId;
  }

  /// Get all vehicles from local storage
  Future<List<VehicleModel>> getAllVehicles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vehiclesJson = prefs.getString(_vehiclesKey);
      
      if (vehiclesJson == null || vehiclesJson.isEmpty) {
        return [];
      }

      final List<dynamic> vehiclesList = json.decode(vehiclesJson);
      return vehiclesList.map((json) => VehicleModel.fromJson(json)).toList();
    } catch (e) {
      print('Error loading local vehicles: $e');
      return [];
    }
  }

  /// Save all vehicles to local storage
  Future<void> _saveAllVehicles(List<VehicleModel> vehicles) async {
    final prefs = await SharedPreferences.getInstance();
    final vehiclesJson = json.encode(vehicles.map((v) => v.toJson()).toList());
    await prefs.setString(_vehiclesKey, vehiclesJson);
  }

  /// Add new vehicle
  Future<VehicleModel> addVehicle(VehicleModel vehicle) async {
    final vehicles = await getAllVehicles();
    
    // Assign local ID if not set
    final newVehicle = vehicle.copyWith(
      id: vehicle.id ?? await _getNextId(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    vehicles.add(newVehicle);
    await _saveAllVehicles(vehicles);
    
    return newVehicle;
  }

  /// Update vehicle
  Future<VehicleModel?> updateVehicle(int id, VehicleModel updatedVehicle) async {
    final vehicles = await getAllVehicles();
    final index = vehicles.indexWhere((v) => v.id == id);
    
    if (index == -1) return null;
    
    final updated = updatedVehicle.copyWith(
      id: id,
      updatedAt: DateTime.now(),
    );
    
    vehicles[index] = updated;
    await _saveAllVehicles(vehicles);
    
    return updated;
  }

  /// Delete vehicle
  Future<bool> deleteVehicle(int id) async {
    final vehicles = await getAllVehicles();
    final initialLength = vehicles.length;
    
    vehicles.removeWhere((v) => v.id == id);
    
    if (vehicles.length < initialLength) {
      await _saveAllVehicles(vehicles);
      return true;
    }
    
    return false;
  }

  /// Get primary vehicle
  Future<VehicleModel?> getPrimaryVehicle() async {
    final vehicles = await getAllVehicles();
    try {
      return vehicles.firstWhere((v) => v.isPrimary);
    } catch (e) {
      return vehicles.isNotEmpty ? vehicles.first : null;
    }
  }

  /// Set vehicle as primary
  Future<VehicleModel?> setPrimaryVehicle(int id) async {
    final vehicles = await getAllVehicles();
    
    // Find the vehicle
    final vehicleIndex = vehicles.indexWhere((v) => v.id == id);
    if (vehicleIndex == -1) return null;
    
    // Update all vehicles: set all to not primary, then set selected one as primary
    for (var i = 0; i < vehicles.length; i++) {
      vehicles[i] = vehicles[i].copyWith(
        isPrimary: i == vehicleIndex,
        updatedAt: DateTime.now(),
      );
    }
    
    await _saveAllVehicles(vehicles);
    return vehicles[vehicleIndex];
  }

  /// Clear all local vehicles
  Future<void> clearAllVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_vehiclesKey);
    await prefs.remove(_nextIdKey);
  }

  /// Sync local vehicles to server (call this after login)
  Future<void> syncWithServer(
    Future<List<VehicleModel>> Function() fetchFromServer,
    Future<VehicleModel> Function(VehicleModel) uploadToServer,
  ) async {
    try {
      // Get local vehicles
      final localVehicles = await getAllVehicles();
      
      // Get server vehicles
      final serverVehicles = await fetchFromServer();
      
      // If no local vehicles, just use server data
      if (localVehicles.isEmpty) {
        await _saveAllVehicles(serverVehicles);
        return;
      }
      
      // If no server vehicles, upload all local vehicles
      if (serverVehicles.isEmpty) {
        for (var vehicle in localVehicles) {
          await uploadToServer(vehicle);
        }
        return;
      }
      
      // Merge logic: prefer server data as source of truth
      await _saveAllVehicles(serverVehicles);
    } catch (e) {
      print('Error syncing vehicles: $e');
    }
  }
}
