import 'package:flutter/material.dart';

import 'gps_tracking_active_page.dart';

class GpsTrackingPage extends StatelessWidget {
  final int vehicleId;
  final String vehicleName;

  const GpsTrackingPage({
    super.key,
    required this.vehicleId,
    this.vehicleName = 'My Ninja',
  });

  @override
  Widget build(BuildContext context) {
    return GpsTrackingActivePage(
      vehicleId: vehicleId,
      vehicleName: vehicleName,
    );
  }
}
