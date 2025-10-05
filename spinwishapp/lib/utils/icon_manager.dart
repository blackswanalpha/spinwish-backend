import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// Centralized Icon Management System for SpinWish
///
/// This system provides:
/// 1. Consistent icon usage across the app
/// 2. Easy switching between icon sets (Material Icons vs HugeIcons)
/// 3. Semantic naming for better maintainability
/// 4. Icon variants (outlined, filled, etc.)
class SpinWishIcons {
  // Private constructor to prevent instantiation
  SpinWishIcons._();

  /// Icon set preference
  static IconSet _currentIconSet = IconSet.hugeicons;

  static IconSet get currentIconSet => _currentIconSet;

  static void setIconSet(IconSet iconSet) {
    _currentIconSet = iconSet;
  }

  // NAVIGATION ICONS
  static IconData get home => _getIcon(
        material: Icons.home,
        materialOutlined: Icons.home_outlined,
        huge: HugeIcons.strokeRoundedHome01,
      );

  static IconData get sessions => _getIcon(
        material: Icons.radio,
        materialOutlined: Icons.radio_outlined,
        huge: HugeIcons.strokeRoundedRadio,
      );

  static IconData get djs => _getIcon(
        material: Icons.headphones,
        materialOutlined: Icons.headphones_outlined,
        huge: HugeIcons.strokeRoundedHeadphones,
      );

  static IconData get music => _getIcon(
        material: Icons.library_music,
        materialOutlined: Icons.library_music_outlined,
        huge: HugeIcons.strokeRoundedMusicNote01,
      );

  static IconData get requests => _getIcon(
        material: Icons.queue_music,
        materialOutlined: Icons.queue_music_outlined,
        huge: HugeIcons.strokeRoundedPlaylist01,
      );

  static IconData get profile => _getIcon(
        material: Icons.person,
        materialOutlined: Icons.person_outline,
        huge: HugeIcons.strokeRoundedUser,
      );

  // ACTION ICONS
  static IconData get edit => _getIcon(
        material: Icons.edit,
        materialOutlined: Icons.edit_outlined,
        huge: HugeIcons.strokeRoundedEdit01,
      );

  static IconData get settings => _getIcon(
        material: Icons.settings,
        materialOutlined: Icons.settings_outlined,
        huge: HugeIcons.strokeRoundedSettings01,
      );

  static IconData get search => _getIcon(
        material: Icons.search,
        materialOutlined: Icons.search_outlined,
        huge: HugeIcons.strokeRoundedSearch01,
      );

  static IconData get filter => _getIcon(
        material: Icons.filter_list,
        materialOutlined: Icons.filter_list_outlined,
        huge: HugeIcons.strokeRoundedFilterHorizontal,
      );

  static IconData get download => _getIcon(
        material: Icons.download,
        materialOutlined: Icons.download_outlined,
        huge: HugeIcons.strokeRoundedDownload01,
      );

  static IconData get logout => _getIcon(
        material: Icons.logout,
        materialOutlined: Icons.logout_outlined,
        huge: HugeIcons.strokeRoundedLogout01,
      );

  // STATUS & CATEGORY ICONS
  static IconData get trending => _getIcon(
        material: Icons.trending_up,
        materialOutlined: Icons.trending_up_outlined,
        huge: HugeIcons.strokeRoundedArrowUpRight01,
      );

  static IconData get diamond => _getIcon(
        material: Icons.diamond,
        materialOutlined: Icons.diamond_outlined,
        huge: HugeIcons.strokeRoundedDiamond,
      );

  static IconData get colorize => _getIcon(
        material: Icons.colorize,
        materialOutlined: Icons.colorize_outlined,
        huge: HugeIcons.strokeRoundedPaintBrush01,
      );

  static IconData get rocket => _getIcon(
        material: Icons.rocket_launch,
        materialOutlined: Icons.rocket_launch_outlined,
        huge: HugeIcons.strokeRoundedRocket,
      );

  static IconData get sun => _getIcon(
        material: Icons.wb_sunny,
        materialOutlined: Icons.wb_sunny_outlined,
        huge: HugeIcons.strokeRoundedSun01,
      );

  static IconData get snowflake => _getIcon(
        material: Icons.ac_unit,
        materialOutlined: Icons.ac_unit_outlined,
        huge: HugeIcons.strokeRoundedSnow,
      );

  static IconData get eco => _getIcon(
        material: Icons.eco,
        materialOutlined: Icons.eco_outlined,
        huge: HugeIcons.strokeRoundedLeaf01,
      );

  static IconData get sparkles => _getIcon(
        material: Icons.auto_awesome,
        materialOutlined: Icons.auto_awesome_outlined,
        huge: HugeIcons.strokeRoundedSparkles,
      );

  // UI NAVIGATION ICONS
  static IconData get chevronRight => _getIcon(
        material: Icons.chevron_right,
        materialOutlined: Icons.chevron_right_outlined,
        huge: HugeIcons.strokeRoundedArrowRight01,
      );

  static IconData get arrowForward => _getIcon(
        material: Icons.arrow_forward_ios,
        materialOutlined: Icons.arrow_forward_ios_outlined,
        huge: HugeIcons.strokeRoundedArrowRight02,
      );

  // LOCATION & CONNECTIVITY
  static IconData get location => _getIcon(
        material: Icons.location_on,
        materialOutlined: Icons.location_on_outlined,
        huge: HugeIcons.strokeRoundedLocation01,
      );

  static IconData get notifications => _getIcon(
        material: Icons.notifications,
        materialOutlined: Icons.notifications_outlined,
        huge: HugeIcons.strokeRoundedNotification01,
      );

  // MEDIA CONTROLS
  static IconData get play => _getIcon(
        material: Icons.play_arrow,
        materialOutlined: Icons.play_arrow_outlined,
        huge: HugeIcons.strokeRoundedPlay,
      );

  static IconData get pause => _getIcon(
        material: Icons.pause,
        materialOutlined: Icons.pause_outlined,
        huge: HugeIcons.strokeRoundedPause,
      );

  static IconData get stop => _getIcon(
        material: Icons.stop,
        materialOutlined: Icons.stop_outlined,
        huge: HugeIcons.strokeRoundedStop,
      );

  static IconData get skipNext => _getIcon(
        material: Icons.skip_next,
        materialOutlined: Icons.skip_next_outlined,
        huge: HugeIcons.strokeRoundedNext,
      );

  static IconData get skipPrevious => _getIcon(
        material: Icons.skip_previous,
        materialOutlined: Icons.skip_previous_outlined,
        huge: HugeIcons.strokeRoundedPrevious,
      );

  static IconData get volume => _getIcon(
        material: Icons.volume_up,
        materialOutlined: Icons.volume_up_outlined,
        huge: HugeIcons.strokeRoundedVolumeHigh,
      );

  static IconData get volumeMute => _getIcon(
        material: Icons.volume_off,
        materialOutlined: Icons.volume_off_outlined,
        huge: HugeIcons.strokeRoundedVolumeMute01,
      );

  // SOCIAL & INTERACTION
  static IconData get favorite => _getIcon(
        material: Icons.favorite,
        materialOutlined: Icons.favorite_outline,
        huge: HugeIcons.strokeRoundedFavourite,
      );

  static IconData get share => _getIcon(
        material: Icons.share,
        materialOutlined: Icons.share_outlined,
        huge: HugeIcons.strokeRoundedShare01,
      );

  static IconData get comment => _getIcon(
        material: Icons.comment,
        materialOutlined: Icons.comment_outlined,
        huge: HugeIcons.strokeRoundedComment01,
      );

  // UTILITY ICONS
  static IconData get add => _getIcon(
        material: Icons.add,
        materialOutlined: Icons.add_outlined,
        huge: HugeIcons.strokeRoundedAdd01,
      );

  static IconData get remove => _getIcon(
        material: Icons.remove,
        materialOutlined: Icons.remove_outlined,
        huge: HugeIcons.strokeRoundedRemove01,
      );

  static IconData get close => _getIcon(
        material: Icons.close,
        materialOutlined: Icons.close_outlined,
        huge: HugeIcons.strokeRoundedCancel01,
      );

  static IconData get check => _getIcon(
        material: Icons.check,
        materialOutlined: Icons.check_outlined,
        huge: HugeIcons.strokeRoundedTick01,
      );

  // Helper method to get the appropriate icon based on current icon set
  static IconData _getIcon({
    required IconData material,
    IconData? materialOutlined,
    required IconData huge,
    IconVariant variant = IconVariant.outlined,
  }) {
    switch (_currentIconSet) {
      case IconSet.material:
        return variant == IconVariant.filled
            ? material
            : (materialOutlined ?? material);
      case IconSet.hugeicons:
        return huge;
    }
  }
}

/// Available icon sets
enum IconSet {
  material,
  hugeicons,
}

/// Icon variants for different visual styles
enum IconVariant {
  outlined,
  filled,
}

/// Extension to provide easy access to icon variants
extension SpinWishIconVariants on SpinWishIcons {
  /// Get filled variant of common icons
  static IconData getFilledVariant(IconData Function() iconGetter) {
    final currentSet = SpinWishIcons._currentIconSet;
    SpinWishIcons._currentIconSet = IconSet.material;
    final icon = iconGetter();
    SpinWishIcons._currentIconSet = currentSet;
    return icon;
  }
}
