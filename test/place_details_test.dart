import 'package:cabisync_customer/services/google_places_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reverse-geocoded pickup displays its address when name is absent', () {
    final place = PlaceDetails.fromJson({
      'place_id': 'pickup',
      'formatted_address': 'Station Road, Doncaster, UK',
      'geometry': {
        'location': {'lat': 53.52, 'lng': -1.14},
      },
    });
    expect(place.name, 'Station Road, Doncaster, UK');
    expect(place.latitude, 53.52);
    expect(place.longitude, -1.14);
  });
  test('named places retain their name', () {
    final place = PlaceDetails.fromJson({
      'place_id': 'station',
      'name': 'Doncaster Station',
      'formatted_address': 'Station Road, Doncaster, UK',
    });
    expect(place.name, 'Doncaster Station');
  });
}
