#ifndef FLUTTER_PLUGIN_FLUKKI_PRODUCT_TOURS_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUKKI_PRODUCT_TOURS_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace flukki_product_tours {

class FlukkiProductToursPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlukkiProductToursPlugin();

  virtual ~FlukkiProductToursPlugin();

  // Disallow copy and assign.
  FlukkiProductToursPlugin(const FlukkiProductToursPlugin&) = delete;
  FlukkiProductToursPlugin& operator=(const FlukkiProductToursPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flukki_product_tours

#endif  // FLUTTER_PLUGIN_FLUKKI_PRODUCT_TOURS_PLUGIN_H_
