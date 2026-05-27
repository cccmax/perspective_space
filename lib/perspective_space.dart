/// Buttery-smooth 3D perspective and parallax widgets for Flutter.
///
/// The library exposes a low-level pair — [PerspectiveSpace] and
/// [PerspectiveLayer] — plus three high-level presets that cover the most
/// common patterns:
///
/// * [PerspectiveTiltCard] — a single tilting card.
/// * [PerspectiveParallax] — a stack of layers with depth.
/// * [PerspectiveShakeEntry] — a one-shot entry shake.
library;

export 'src/perspective_layer.dart' show PerspectiveLayer;
export 'src/perspective_space.dart'
    show PerspectiveSpace, PerspectiveSpaceController;
export 'src/presets/perspective_parallax.dart'
    show PerspectiveLayerSpec, PerspectiveParallax;
export 'src/presets/perspective_shake_entry.dart' show PerspectiveShakeEntry;
export 'src/presets/perspective_tilt_card.dart' show PerspectiveTiltCard;
