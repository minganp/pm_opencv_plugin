#ifndef FLUTTER_PLUGIN_PM_OPENCV_PLUGIN_H_
#define FLUTTER_PLUGIN_PM_OPENCV_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace pm_opencv_plugin {

class PmOpencvPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  PmOpencvPlugin();

  virtual ~PmOpencvPlugin();

  // Disallow copy and assign.
  PmOpencvPlugin(const PmOpencvPlugin&) = delete;
  PmOpencvPlugin& operator=(const PmOpencvPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace pm_opencv_plugin

#endif  // FLUTTER_PLUGIN_PM_OPENCV_PLUGIN_H_
