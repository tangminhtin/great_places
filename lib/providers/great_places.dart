import 'package:flutter/material.dart';
import 'package:great_places/helpers/db_helper.dart';
import 'package:great_places/helpers/location_helper.dart';
import 'package:great_places/models/place.dart';
import 'package:image_picker/image_picker.dart';

class GreatPlaces with ChangeNotifier {
  List<Place> _places = [];

  List<Place> get places => [..._places];

  Place findById(String id) => _places.firstWhere((place) => place.id == id);

  Future<void> addPlace(
    String pickedTitle,
    XFile pickedImage,
    PlaceLocation pickedLocation,
  ) async {
    final address = await LocationHelper.getPlaceAddress(
      pickedLocation.latitude,
      pickedLocation.longitude,
    );

    final updatedLocation = PlaceLocation(
      latitude: pickedLocation.latitude,
      longitude: pickedLocation.longitude,
      address: address,
    );

    final newPlace = Place(
      id: DateTime.now().toString(),
      title: pickedTitle,
      location: updatedLocation,
      image: pickedImage,
    );

    _places.add(newPlace);
    notifyListeners();

    DBHelper.insert(
      'user_places',
      {
        'id': newPlace.id,
        'title': newPlace.title,
        'image': newPlace.image.path,
        'loc_lat': newPlace.location.latitude,
        'loc_lng': newPlace.location.longitude,
        'address': newPlace.location.address as String,
      },
    );
  }

  Future<void> fetchAndSetPlaces() async {
    final dataList = await DBHelper.getData('user_places');
    _places = dataList
        .map(
          (place) => Place(
            id: place['id'],
            title: place['title'],
            image: XFile(place['image']),
            location: PlaceLocation(
              latitude: place['loc_lat'],
              longitude: place['loc_lng'],
              address: place['address'],
            ),
          ),
        )
        .toList();
    notifyListeners();
  }
}
