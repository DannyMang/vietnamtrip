import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../config/app_config.dart';
import '../models/pin.dart';
import '../services/supabase_service.dart';
import '../widgets/add_pin_dialog.dart';
import '../widgets/pin_list_bottom_sheet.dart';

class MapScreen extends StatefulWidget {
  final String userName;

  const MapScreen({super.key, required this.userName});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapboxMap? _mapboxMap;
  final SupabaseService _supabaseService = SupabaseService();
  List<Pin> _pins = [];
  bool _isLoading = true;
  PointAnnotationManager? _pointAnnotationManager;

  @override
  void initState() {
    super.initState();
    _loadPins();
  }

  Future<void> _loadPins() async {
    setState(() => _isLoading = true);
    final pins = await _supabaseService.getPins();
    setState(() {
      _pins = pins;
      _isLoading = false;
    });
    _updateMapAnnotations();
  }

  Future<void> _updateMapAnnotations() async {
    if (_mapboxMap == null) return;

    _pointAnnotationManager ??=
        await _mapboxMap!.annotations.createPointAnnotationManager();

    await _pointAnnotationManager!.deleteAll();

    for (final pin in _pins) {
      final point = Point(
        coordinates: Position(pin.longitude, pin.latitude),
      );

      final options = PointAnnotationOptions(
        geometry: point,
        textField: pin.type.emoji,
        textSize: 24,
        iconSize: 1.5,
      );

      await _pointAnnotationManager!.create(options);
    }
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    _updateMapAnnotations();
  }

  void _showAddPinDialog() {
    if (_mapboxMap == null) return;

    _mapboxMap!.getCameraState().then((cameraState) {
      final center = cameraState.center;

      showDialog(
        context: context,
        builder: (context) => AddPinDialog(
          latitude: center.coordinates.lat.toDouble(),
          longitude: center.coordinates.lng.toDouble(),
          onPinAdded: (pin) async {
            final newPin = await _supabaseService.addPin(pin);
            if (newPin != null) {
              await _loadPins();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pin added successfully!')),
                );
              }
            }
          },
        ),
      );
    });
  }

  void _showPinsList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PinListBottomSheet(
        pins: _pins,
        onPinTap: (pin) {
          Navigator.pop(context);
          _mapboxMap?.flyTo(
            CameraOptions(
              center: Point(
                coordinates: Position(pin.longitude, pin.latitude),
              ),
              zoom: 15,
            ),
            MapAnimationOptions(duration: 1000),
          );
        },
        onPinDelete: (pin) async {
          final success = await _supabaseService.deletePin(pin.id!);
          if (success) {
            await _loadPins();
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pin deleted successfully!')),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapWidget(
            key: const ValueKey("mapWidget"),
            cameraOptions: CameraOptions(
              center: Point(
                coordinates: Position(
                  AppConfig.defaultLongitude,
                  AppConfig.defaultLatitude,
                ),
              ),
              zoom: AppConfig.defaultZoom,
            ),
            styleUri: MapboxStyles.MAPBOX_STREETS,
            textureView: true,
            onMapCreated: _onMapCreated,
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    '👋',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${widget.userName}!',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_pins.length} places saved',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.list),
                    onPressed: _showPinsList,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.orange.shade50,
                      foregroundColor: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'myLocation',
            onPressed: () {
              _mapboxMap?.flyTo(
                CameraOptions(
                  center: Point(
                    coordinates: Position(
                      AppConfig.defaultLongitude,
                      AppConfig.defaultLatitude,
                    ),
                  ),
                  zoom: AppConfig.defaultZoom,
                ),
                MapAnimationOptions(duration: 1000),
              );
            },
            backgroundColor: Colors.white,
            child: Icon(Icons.my_location, color: Colors.orange.shade700),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'addPin',
            onPressed: _showAddPinDialog,
            backgroundColor: Colors.orange.shade400,
            icon: const Icon(Icons.add_location),
            label: Text(
              'Add Pin',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
