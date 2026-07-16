import 'package:flutter/material.dart';

import '../../../../core/model/vehicle_model.dart';
import 'gps_tracking_active_page.dart';

class GpsTrackingPage extends StatelessWidget {
  final int vehicleId;
  final String vehicleName;
  final VehicleModel? currentVehicle;

  const GpsTrackingPage({
    super.key,
    required this.vehicleId,
    this.vehicleName = 'My Ninja',
    this.currentVehicle,
  });

  @override
  Widget build(BuildContext context) {
    return GpsTrackingActivePage(
      vehicleId: vehicleId,
      vehicleName: vehicleName,
      currentVehicle: currentVehicle,
    );
  }
}
