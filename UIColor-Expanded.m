#import "UIColor-Expanded.h"

/*
 
 Thanks to Poltras, Millenomi, Eridius, Nownot, WhatAHam, 
 and everyone else who helped out but whose name is inadvertantly omitted
 
*/

/*
 Current outstanding request list:
 
 - August Joki - CSS named color set 
 - PolarBearFarm - color descriptions ([UIColor warmGrayWithHintOfBlueTouchOfRedAndSplashOfYellowColor])
 - Crayola color set
 - T Hillerson - Random Colors ([UIColor pickSomethingNice])
 - Eridius - UIColor needs a method that takes 2 colors and gives a third complementary one
 - Monochromization (something like 0.45 red + 0.35 green + 0.2 blue, what's the best formula?)
 - Eridius - colorWithHex:(NSInteger)hex, e.g. [UIColor colorWithHex:0xaabbcc]
 - Consider UIMutableColor that can be adjusted (brighter, cooler, warmer, thicker-alpha, etc)
 - Eridius - colorByAddingColor: and/or -colorWithAlpha: <-- Color with Alpha already exists. colorWithAlphaComponent:
 */

/*
 FOR REFERENCE: Color Space Models: enum CGColorSpaceModel {
	kCGColorSpaceModelUnknown = -1,
	kCGColorSpaceModelMonochrome,
	kCGColorSpaceModelRGB,
	kCGColorSpaceModelCMYK,
	kCGColorSpaceModelLab,
	kCGColorSpaceModelDeviceN,
	kCGColorSpaceModelIndexed,
	kCGColorSpaceModelPattern
};
*/

// Color to return when constructor cannot create a proper color -- can be nil
#define DEFAULT_VOID_COLOR	[UIColor clearColor]

@implementation UIColor (UIColor_Expanded)

// Return a UIColor's color space model
- (CGColorSpaceModel) colorSpaceModel
{
	return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
}

- (NSString *) colorSpaceString
{
	switch (self.colorSpaceModel)
	{
		case kCGColorSpaceModelUnknown:
			return @"kCGColorSpaceModelUnknown";
		case kCGColorSpaceModelMonochrome:
			return @"kCGColorSpaceModelMonochrome";
		case kCGColorSpaceModelRGB:
			return @"kCGColorSpaceModelRGB";
		case kCGColorSpaceModelCMYK:
			return @"kCGColorSpaceModelCMYK";
		case kCGColorSpaceModelLab:
			return @"kCGColorSpaceModelLab";
		case kCGColorSpaceModelDeviceN:
			return @"kCGColorSpaceModelDeviceN";
		case kCGColorSpaceModelIndexed:
			return @"kCGColorSpaceModelIndexed";
		case kCGColorSpaceModelPattern:
			return @"kCGColorSpaceModelPattern";
		default:
			return @"Not a valid color space";
	}
}

- (BOOL) canProvideRGBComponents
{
	switch (self.colorSpaceModel) {
		case kCGColorSpaceModelRGB:
		case kCGColorSpaceModelMonochrome:
			return YES;
		default:
			return NO;
	}
}

// Return a UIColor's components
- (NSArray *) arrayFromRGBAComponents
{
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -arrayFromRGBAComponents");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	
	NSArray *components;
	switch (self.colorSpaceModel) {
		case kCGColorSpaceModelRGB:
			components = [NSArray arrayWithObjects:
						  [NSNumber numberWithFloat:c[0]],
						  [NSNumber numberWithFloat:c[1]],
						  [NSNumber numberWithFloat:c[2]],
						  [NSNumber numberWithFloat:c[3]],
						  nil];
			break;
		case kCGColorSpaceModelMonochrome:
			components = [NSArray arrayWithObjects:
						  [NSNumber numberWithFloat:c[0]],
						  [NSNumber numberWithFloat:c[0]],
						  [NSNumber numberWithFloat:c[0]],
						  [NSNumber numberWithFloat:c[1]],
						  nil];
			break;
		default:
			// no support for other color spaces at this time
			components = nil;
	}
	return components;
}

- (CGFloat) red
{
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -red");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	return c[0];
}

- (CGFloat) green
{
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -green");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	if (self.colorSpaceModel == kCGColorSpaceModelMonochrome) return c[0];
	return c[1];
}

- (CGFloat) blue
{
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -blue");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	if (self.colorSpaceModel == kCGColorSpaceModelMonochrome) return c[0];
	return c[2];
}

- (CGFloat) white
{
	NSAssert(self.colorSpaceModel == kCGColorSpaceModelMonochrome, @"Must be a Monochrome color to use -white");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	return c[0];
}

- (CGFloat) alpha
{
	return CGColorGetAlpha(self.CGColor);
}

/*
 *
 * String Utilities
 *
 */

- (NSString *) stringFromColor
{
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -stringFromColor");
	NSString *result;
	switch (self.colorSpaceModel) {
		case kCGColorSpaceModelRGB:
			result = [NSString stringWithFormat:@"{%0.3f, %0.3f, %0.3f, %0.3f}", self.red, self.green, self.blue, self.alpha];
			break;
		case kCGColorSpaceModelMonochrome:
			result = [NSString stringWithFormat:@"{%0.3f, %0.3f}", self.white, self.alpha];
			break;
		default:
			result = nil;
	}
	return result;
}

- (NSString *) hexStringFromColor
{
	NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -hexStringFromColor");

	CGFloat r, g, b;
	r = MIN(MAX(self.red, 0.0f), 1.0f);
	g = MIN(MAX(self.green, 0.0f), 1.0f);
	b = MIN(MAX(self.blue, 0.0f), 1.0f);
	
	// Convert to hex string between 0x00 and 0xFF
	return [NSString stringWithFormat:@"%02X%02X%02X",
			 (int)roundf(r * 255), (int)roundf(g * 255), (int)roundf(b * 255)];
}

+ (UIColor *) colorWithString: (NSString *) stringToConvert
{
	NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
	if (![scanner scanString:@"{" intoString:NULL]) return nil;
	const NSUInteger kMaxComponents = 4;
	CGFloat c[kMaxComponents];
	NSUInteger i = 0;
	if (![scanner scanFloat:&c[i++]]) return nil;
	while (1) {
		if ([scanner scanString:@"}" intoString:NULL]) break;
		if (i >= kMaxComponents) return nil;
		if ([scanner scanString:@"," intoString:NULL]) {
			if (![scanner scanFloat:&c[i++]]) return nil;
		} else {
			// either we're at the end of there's an unexpected character here
			// both cases are error conditions
			return nil;
		}
	}
	if (![scanner isAtEnd]) return nil;
	UIColor *color;
	switch (i) {
		case 2: // monochrome
			color = [UIColor colorWithWhite:c[0] alpha:c[1]];
			break;
		case 4: // RGB
			color = [UIColor colorWithRed:c[0] green:c[1] blue:c[2] alpha:c[3]];
			break;
		default:
			color = nil;
	}
	return color;
}

+ (UIColor *) colorWithHexString: (NSString *) stringToConvert
{
	NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
	unsigned hexNum;
	if (![scanner scanHexInt:&hexNum]) return nil;
	CGFloat r, g, b;
	r = ((hexNum & 0xFF0000) >> 16) / 255.0f;
	g = ((hexNum & 0x00FF00) >> 8) / 255.0f;
	b = (hexNum & 0x0000FF) / 255.0f;
	return [UIColor colorWithRed:r green:g blue:b alpha:1.0f];
}
@end

#if SUPPORTS_UNDOCUMENTED_API
@implementation UIColor (UIColor_Undocumented_Expanded)
// Convert a color into RGB Color space, courtesy of Poltras
// via http://ofcodeandmen.poltras.com/2009/01/22/convert-a-cgcolorref-to-another-cgcolorspaceref/
//
- (UIColor *) rgbColor
{
	// Call to undocumented method "styleString".
	NSString *style = [self styleString];
	NSScanner *scanner = [NSScanner scannerWithString:style];
	CGFloat red, green, blue;
	if (![scanner scanString:@"rgb(" intoString:NULL]) return nil;
	if (![scanner scanFloat:&red]) return nil;
	if (![scanner scanString:@"," intoString:NULL]) return nil;
	if (![scanner scanFloat:&green]) return nil;
	if (![scanner scanString:@"," intoString:NULL]) return nil;
	if (![scanner scanFloat:&blue]) return nil;
	if (![scanner scanString:@")" intoString:NULL]) return nil;
	if (![scanner isAtEnd]) return nil;
	
	return [UIColor colorWithRed:red green:green blue:blue alpha:self.alpha];
}
@end
#endif // SUPPORTS_UNDOCUMENTED_API
