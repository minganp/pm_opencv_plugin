#import "PmOpencvPlugin.h"
#if __has_include(<pm_opencv_plugin/pm_opencv_plugin-Swift.h>)
#import <pm_opencv_plugin/pm_opencv_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "pm_opencv_plugin-Swift.h"
#endif

@implementation PmOpencvPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPmOpencvPlugin registerWithRegistrar:registrar];
}
@end
