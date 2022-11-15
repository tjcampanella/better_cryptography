#import "CryptographyFlutterPlugin.h"
#if __has_include(<better_cryptography_flutter/better_cryptography_flutter-Swift.h>)
#import <better_cryptography_flutter/better_cryptography_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "better_cryptography_flutter-Swift.h"
#endif

@implementation CryptographyFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCryptographyFlutterPlugin registerWithRegistrar:registrar];
}
@end
