#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"com.foodzippy.customer";

/// The "AccentColor" asset catalog color resource.
static NSString * const ACColorNameAccentColor AC_SWIFT_PRIVATE = @"AccentColor";

/// The "banner" asset catalog image resource.
static NSString * const ACImageNameBanner AC_SWIFT_PRIVATE = @"banner";

/// The "burger" asset catalog image resource.
static NSString * const ACImageNameBurger AC_SWIFT_PRIVATE = @"burger";

/// The "corporate_cashback" asset catalog image resource.
static NSString * const ACImageNameCorporateCashback AC_SWIFT_PRIVATE = @"corporate_cashback";

/// The "favourites" asset catalog image resource.
static NSString * const ACImageNameFavourites AC_SWIFT_PRIVATE = @"favourites";

/// The "redeem_coupon" asset catalog image resource.
static NSString * const ACImageNameRedeemCoupon AC_SWIFT_PRIVATE = @"redeem_coupon";

/// The "student_cashback" asset catalog image resource.
static NSString * const ACImageNameStudentCashback AC_SWIFT_PRIVATE = @"student_cashback";

#undef AC_SWIFT_PRIVATE
