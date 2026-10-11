import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'report_dialog.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _fallbackPosition = LatLng(35.681236, 139.767125);

  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionSubscription;
  Position? _position;
  String? _locationMessage;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _startLocationTracking() async {
    setState(() {
      _isLoadingLocation = true;
      _locationMessage = null;
    });

    await _positionSubscription?.cancel();
    _positionSubscription = null;

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _setLocationError('位置情報サービスを有効にしてください。');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _setLocationError('位置情報の利用が許可されていません。');
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        _setLocationError('設定アプリで位置情報の利用を許可してください。');
        return;
      }

      final initialPosition = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      _updatePosition(initialPosition);
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      ).listen(
        _updatePosition,
        onError: (Object error) {
          debugPrint('Location stream failed: $error');
          _setLocationError('位置情報を取得できませんでした。再試行してください。');
        },
      );
    } catch (error) {
      debugPrint('Unable to start location tracking: $error');
      _setLocationError('位置情報を取得できませんでした。再試行してください。');
    }
  }

  void _setLocationError(String message) {
    if (!mounted) return;
    setState(() {
      _isLoadingLocation = false;
      _locationMessage = message;
    });
  }

  void _updatePosition(Position position) {
    if (!mounted) return;
    setState(() {
      _position = position;
      _isLoadingLocation = false;
      _locationMessage = null;
    });

    _moveCamera(position);
  }

  Future<void> _moveCamera(Position position) async {
    await _mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude),
      ),
    );
  }

  Future<void> _showReportDialog() async {
    await showDialog<void>(
      context: context,
        barrierDismissible: false,
        builder: (context) => const ReportDialog(),
      );
    }

  @override
  Widget build(BuildContext context) {
    final currentPosition = _position;
    final currentLatLng = currentPosition == null
        ? null
        : LatLng(currentPosition.latitude, currentPosition.longitude);

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _fallbackPosition,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              final position = _position;
              if (position != null) _moveCamera(position);
            },
            markers: currentLatLng == null
                ? const {}
                : {
                    Marker(
                      markerId: const MarkerId('current-location'),
                      position: currentLatLng,
                      infoWindow: const InfoWindow(title: '現在地'),
                    ),
                  },
            myLocationButtonEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: false,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _LocationCard(
                isLoading: _isLoadingLocation,
                message: _locationMessage,
                onRetry: _startLocationTracking,
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 28,
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: _showReportDialog,
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: const Text(
                    '故障報告をする',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1769AA),
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.isLoading,
    required this.message,
    required this.onRetry,
  });

  final bool isLoading;
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final hasError = message != null;
    return Material(
      color: Colors.white,
      elevation: 3,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3FB),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.location_city_rounded,
                color: Color(0xFF1769AA),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'PublicIssueReporter',
                    style: TextStyle(
                      color: Color(0xFF14273D),
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message ??
                        (isLoading ? '現在地を確認しています' : '現在地を表示中'),
                    style: TextStyle(
                      color: hasError
                          ? const Color(0xFFB42318)
                          : const Color(0xFF687789),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (hasError)
              IconButton(
                onPressed: onRetry,
                tooltip: '再試行',
                icon: const Icon(Icons.refresh, color: Color(0xFF1769AA)),
              ),
          ],
        ),
      ),
    );
  }
}
