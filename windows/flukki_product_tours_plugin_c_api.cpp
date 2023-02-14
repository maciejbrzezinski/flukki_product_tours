#include "include/flukki_product_tours/flukki_product_tours_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flukki_product_tours_plugin.h"

void FlukkiProductToursPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flukki_product_tours::FlukkiProductToursPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
