import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../db/database_helper.dart';
import '../main.dart';

const String kGoogleApiKey = 'AIzaSyC7HTjj4FVVj8UV5DAh61bLrmboFsfGHxw';

class PetaPage extends StatefulWidget {
  final double? latitude;
  final double? longitude;

  const PetaPage({super.key, this.latitude, this.longitude});

  @override
  State<PetaPage> createState() => _PetaPageState();
}

class _PetaPageState extends State<PetaPage> {
  GoogleMapController? _controller;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  LatLng _initial = const LatLng(-6.200000, 106.816666);
  LatLng? _userLocation;

  final TextEditingController _search = TextEditingController();

  String? _distanceText;
  String? _durationText;

  @override
  void initState() {
    super.initState();

    // ===== TERIMA KOORDINAT DARI DETAIL PAGE =====
    if (widget.latitude != null && widget.longitude != null) {
      final target = LatLng(widget.latitude!, widget.longitude!);
      _initial = target;

      _markers.add(
        Marker(
          markerId: const MarkerId('destinasi'),
          position: target,
          infoWindow: const InfoWindow(title: 'Destinasi'),
        ),
      );
    }

    _getUserLocation();
    _loadMarkers();
  }

  // ===================== USER LOCATION =====================
  Future<void> _getUserLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _userLocation = LatLng(pos.latitude, pos.longitude);

    _markers.add(
      Marker(
        markerId: const MarkerId('user'),
        position: _userLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Lokasi Anda'),
      ),
    );
    if (widget.latitude == null && widget.longitude == null) {
      _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(_userLocation!, 15),
      );
    }
    setState(() {});
  }

  // ===================== DESTINASI DATABASE =====================
  Future<void> _loadMarkers() async {
    final list = await DatabaseHelper.instance.getAllDestinasi();

    for (var d in list) {
      _markers.add(
        Marker(
          markerId: MarkerId(d.id.toString()),
          position: LatLng(d.latitude, d.longitude),
          infoWindow: InfoWindow(title: d.nama, snippet: d.lokasi),
        ),
      );
    }

    setState(() {});
  }

  // ===================== SEARCH =====================
  // ===================== SEARCH (OSM) =====================
  Future<void> _searchLocation() async {
    if (_search.text.length < 3) return;

    final url =
        'https://nominatim.openstreetmap.org/search'
        '?q=${_search.text}'
        '&format=json'
        '&limit=1';

    final res = await http.get(
      Uri.parse(url),
      headers: {'User-Agent': 'flutter-app'},
    );

    final data = json.decode(res.body);
    if (data.isEmpty) return;

    final lat = double.parse(data[0]['lat']);
    final lon = double.parse(data[0]['lon']);

    final target = LatLng(lat, lon);

    _markers.removeWhere((m) => m.markerId.value == 'search');
    _markers.add(
      Marker(
        markerId: const MarkerId('search'),
        position: target,
        infoWindow: const InfoWindow(title: 'Lokasi Tujuan'),
      ),
    );

    _controller?.animateCamera(CameraUpdate.newLatLngZoom(target, 14));

    _getRoute(target);

    setState(() {});
  }

  Future<void> _getPlaceDetail(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&key=$kGoogleApiKey';

    final res = await http.get(Uri.parse(url));
    final loc = json.decode(res.body)['result']['geometry']['location'];

    final target = LatLng(loc['lat'], loc['lng']);

    _markers.removeWhere((m) => m.markerId.value == 'search');
    _markers.add(
      Marker(
        markerId: const MarkerId('search'),
        position: target,
        infoWindow: const InfoWindow(title: 'Lokasi Tujuan'),
      ),
    );

    _controller?.animateCamera(CameraUpdate.newLatLngZoom(target, 14));
    _getRoute(target);

    setState(() {});
  }

  // ===================== ROUTE =====================
  Future<void> _getRoute(LatLng dest) async {
    if (_userLocation == null) return;

    final url =
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${_userLocation!.latitude},${_userLocation!.longitude}'
        '&destination=${dest.latitude},${dest.longitude}'
        '&key=$kGoogleApiKey';

    final res = await http.get(Uri.parse(url));
    final data = json.decode(res.body);

    final route = data['routes'][0];
    final leg = route['legs'][0];

    _distanceText = leg['distance']['text'];
    _durationText = leg['duration']['text'];

    final points = route['overview_polyline']['points'];
    final decoded = _decodePolyline(points);

    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        color: Colors.blue,
        width: 5,
        points: decoded,
      ),
    );

    setState(() {});
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, lat = 0, lng = 0;

    while (index < encoded.length) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  // ===================== UI (TIDAK DIUBAH) =====================
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const MainPage()),
                          (route) => false,
                        );
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'Peta Destinasi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 247, 235, 235),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _search,
                    onSubmitted: (_) => _searchLocation(),
                    decoration: const InputDecoration(
                      hintText: 'Telusuri lokasi...',
                      border: InputBorder.none,
                      icon: Icon(Icons.search),
                    ),
                  ),
                ),
                if (_distanceText != null)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      '$_distanceText • $_durationText',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _initial,
                        zoom: 12,
                      ),
                      markers: _markers,
                      polylines: _polylines,
                      myLocationEnabled: true,
                      onMapCreated: (c) {
                        _controller = c;
                        if (widget.latitude != null &&
                            widget.longitude != null) {
                          _controller!.animateCamera(
                            CameraUpdate.newLatLngZoom(
                              LatLng(widget.latitude!, widget.longitude!),
                              15,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
