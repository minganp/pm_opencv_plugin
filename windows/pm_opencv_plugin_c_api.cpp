#include "include/pm_opencv_plugin/pm_opencv_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "pm_opencv_plugin.h"

void PmOpencvPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  pm_opencv_plugin::PmOpencvPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
