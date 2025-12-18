import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

const String kGoogleApiKey = 'AIzaSyC7HTjj4FVVj8UV5DAh61bLrmboFsfGHxw';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  GoogleMapController? _controller;
  LatLng? _userLatLng;
  Marker? _picked;
  bool _loading = true;
  double? _distanceKm;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  /// ===== AMBIL LOKASI USER =====
  Future<void> _initLocation() async {
    final status = await Permission.location.request();
    if (!status.isGranted) return;

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _userLatLng = LatLng(pos.latitude, pos.longitude);
    setState(() => _loading = false);

    _controller?.animateCamera(CameraUpdate.newLatLngZoom(_userLatLng!, 15));
  }

  /// ===== TAP MAP =====
  void _onTap(LatLng pos) {
    setState(() {
      _picked = Marker(
        markerId: const MarkerId('picked'),
        position: pos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      );

      if (_userLatLng != null) {
        _distanceKm = _calculateDistance(
          _userLatLng!.latitude,
          _userLatLng!.longitude,
          pos.latitude,
          pos.longitude,
        );
      }
    });
  }

  /// ===== SEARCH HTTP (GOOGLE PLACES) =====
  Future<void> _searchPlace() async {
    final result = await showSearch(
      context: context,
      delegate: _PlaceSearchDelegate(),
    );

    if (result == null) return;

    _controller?.animateCamera(CameraUpdate.newLatLngZoom(result, 15));

    _onTap(result);
  }

  /// ===== HITUNG JARAK =====
  double _calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(deg) => deg * (pi / 180);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFBEEBFA), Color(0xFFDDF3E4)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              /// HEADER
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Pilih Lokasi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              /// SEARCH BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: _searchPlace,
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search),
                        SizedBox(width: 12),
                        Text('Telusuri di sini'),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// MAP
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _userLatLng!,
                            zoom: 14,
                          ),
                          onMapCreated: (c) => _controller = c,
                          onTap: _onTap,
                          markers: {
                            if (_picked != null) _picked!,
                            Marker(
                              markerId: const MarkerId('user'),
                              position: _userLatLng!,
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueBlue,
                              ),
                            ),
                          },
                          myLocationEnabled: true,
                        ),
                ),
              ),

              /// DISTANCE
              if (_distanceKm != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Perkiraan jarak: ${_distanceKm!.toStringAsFixed(2)} km',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),

              /// SAVE
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _picked == null
                        ? null
                        : () {
                            Navigator.pop(context, {
                              'lat': _picked!.position.latitude,
                              'lng': _picked!.position.longitude,
                            });
                          },
                    child: const Text('Simpan Lokasi'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===== SEARCH DELEGATE (HTTP AUTOCOMPLETE) =====
class _PlaceSearchDelegate extends SearchDelegate<LatLng?> {
  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear)),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) => const SizedBox();

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.length < 3) {
      return const Center(child: Text('Ketik minimal 3 huruf'));
    }

    return FutureBuilder(
      future: _search(query),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = snapshot.data as List<Map<String, dynamic>>;

        if (results.isEmpty) {
          return const Center(
            child: Text(
              'Lokasi tidak ditemukan',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (_, i) => ListTile(
            leading: const Icon(Icons.place),
            title: Text(results[i]['description']),
            onTap: () {
              final latLng = LatLng(results[i]['lat'], results[i]['lng']);
              close(context, latLng);
            },
          ),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _search(String input) async {
    final url =
        'https://nominatim.openstreetmap.org/search'
        '?q=$input'
        '&format=json'
        '&addressdetails=1'
        '&limit=10'
        '&countrycodes=id';

    final res = await http.get(
      Uri.parse(url),
      headers: {'User-Agent': 'travel-wisata-lokal-app'},
    );

    final List data = json.decode(res.body);

    return data
        .map(
          (e) => {
            'description': e['display_name'],
            'lat': double.parse(e['lat']),
            'lng': double.parse(e['lon']),
          },
        )
        .toList();
  }
}
