#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "SimplePermissionsPlugin.h"

FOUNDATION_EXPORT double simple_permissionsVersionNumber;
FOUNDATION_EXPORT const unsigned char simple_permissionsVersionString[];

