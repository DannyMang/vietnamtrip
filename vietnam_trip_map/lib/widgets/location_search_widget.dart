import 'package:flutter/material.dart';
import 'package:mapbox_search/mapbox_search.dart';
import '../config/app_config.dart';

class LocationSearchWidget extends StatefulWidget {
  final Function(MapBoxPlace) onLocationSelected;

  const LocationSearchWidget({
    super.key,
    required this.onLocationSelected,
  });

  @override
  State<LocationSearchWidget> createState() => _LocationSearchWidgetState();
}

class _LocationSearchWidgetState extends State<LocationSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final GeoCoding _geoCoding = GeoCoding(
    apiKey: AppConfig.mapboxAccessToken,
    limit: 5,
  );
  List<MapBoxPlace> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final response = await _geoCoding.getPlaces(query);

      response.fold(
        (success) {
          setState(() {
            _searchResults = success;
            _isSearching = false;
          });
        },
        (failure) {
          setState(() {
            _searchResults = [];
            _isSearching = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Search failed: ${failure.error}')),
            );
          }
        },
      );
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search location...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _isSearching
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchResults = []);
                        },
                      )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          onChanged: (value) {
            if (value.length >= 3) {
              _searchLocation(value);
            } else {
              setState(() => _searchResults = []);
            }
          },
        ),
        if (_searchResults.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final place = _searchResults[index];
                return ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.orange),
                  title: Text(
                    place.placeName ?? 'Unknown',
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    widget.onLocationSelected(place);
                    _searchController.clear();
                    setState(() => _searchResults = []);
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
