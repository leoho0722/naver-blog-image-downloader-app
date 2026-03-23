import 'package:flutter/material.dart';

import '../view_model/photo_detail_view_model.dart';

/// A capsule-shaped bottom bar for the photo detail view,
/// containing info and save action buttons.
class PhotoDetailCapsuleBar extends StatelessWidget {
  const PhotoDetailCapsuleBar({
    super.key,
    required this.onInfoTap,
    required this.onSaveTap,
    required this.saveState,
  });

  final VoidCallback onInfoTap;
  final VoidCallback? onSaveTap;
  final SaveState saveState;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHigh.withValues(alpha: 0.85),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onInfoTap,
              icon: const Icon(Icons.info_outline),
            ),
            const VerticalDivider(),
            IconButton(
              onPressed: saveState == SaveState.idle ? onSaveTap : null,
              icon: _buildSaveIcon(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveIcon() {
    switch (saveState) {
      case SaveState.saving:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case SaveState.saved:
        return const Icon(Icons.check);
      case SaveState.idle:
        return const Icon(Icons.save_alt);
    }
  }
}
