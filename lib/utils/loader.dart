import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

import '../consts/consts.dart';

class LoaderHelper {
  static void show(BuildContext context) {
    Loader.show(context,
        progressIndicator: const CircularProgressIndicator(
          color: universalColorPrimaryDefault,
        ));
  }

  static void hide() {
    Loader.hide();
  }
}
