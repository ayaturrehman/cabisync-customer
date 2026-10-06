import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/google_places_service.dart';

class RecentPlacesList extends StatelessWidget {
  const RecentPlacesList({
    super.key,
    required this.places,
    required this.onSelected,
  });
  final List<PlaceDetails> places;
  final ValueChanged<PlaceDetails> onSelected;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.symmetric(vertical: 16),
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text('Recent places', style: AppTextStyles.heading3),
      ),
      ...places.map(
        (place) => ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: const Icon(
            Icons.history,
            color: AppColors.textSecondary,
            size: 22,
          ),
          title: Text(place.name.isEmpty ? place.formattedAddress : place.name),
          subtitle:
              place.name != place.formattedAddress
                  ? Text(
                    place.formattedAddress,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                  : null,
          trailing: const Icon(
            Icons.north_west,
            color: AppColors.textSecondary,
            size: 18,
          ),
          onTap: () => onSelected(place),
        ),
      ),
    ],
  );
}
