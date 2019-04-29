#import "NSString+Stylize.h"

@implementation NSString (Stylize)

+ (NSString *)stylizeText:(NSString *)text withMap:(NSDictionary *)map {
    NSMutableString *stylized = [NSMutableString string];
    NSUInteger length = text.length;
    unichar buffer[length + 1];

    [text getCharacters:buffer range:NSMakeRange(0, length)];

    for (int i = 0; i < length; i++) {
        NSString *key = [NSString stringWithFormat:@"%C", buffer[i]];

        if ([map objectForKey:key]) {
            [stylized appendString:map[key]];
        } else {
            [stylized appendString:key];
        }
    }

    return stylized;
}

+ (NSString *)stylizeTextSpongebob:(NSString *)text {
    NSCharacterSet *letters = [NSCharacterSet letterCharacterSet];
    NSMutableString *stylized = [NSMutableString string];
    NSUInteger length = text.length;
    unichar buffer[length + 1];

    [text getCharacters:buffer range:NSMakeRange(0, length)];

    int j = 0;
    for (int i = 0; i < length; i++) {
        NSString *s = [NSString stringWithFormat:@"%C", buffer[i]];

        if ([letters characterIsMember:buffer[i]]) {
            [stylized appendString:(j++ % 2) ? [s localizedUppercaseString] : [s localizedLowercaseString]];
        } else {
            [stylized appendString:s];
        }
    }

    return stylized;
}

+ (NSString *)stylizeText:(NSString *)text withCombiningChar:(NSString *)combiningChar {
    NSMutableString *stylized = [NSMutableString string];
    NSUInteger length = text.length;
    unichar buffer[length + 1];

    [text getCharacters:buffer range:NSMakeRange(0, length)];

    for (int i = 0; i < length; i++) {
        NSString *s = [NSString stringWithFormat:@"%C", buffer[i]];
        [stylized appendString:s];
        [stylized appendString:combiningChar];
    }

    return stylized;
}

+ (NSString *)stylizeText:(NSString *)text withStyle:(NSDictionary *)style {
    NSString *stylized;

    if (style[@"map"]) {
        stylized = [NSString stylizeText:text withMap:style[@"map"]];
    } else if (style[@"combine"]) {
        stylized = [NSString stylizeText:text withCombiningChar:style[@"combine"]];
    } else if ([style[@"function"] isEqualToString:@"spongebob"]) {
        stylized = [NSString stylizeTextSpongebob:text];
    }

    return stylized;
}

+ (NSString *)stylizeTextSpongebobActive:(NSString *)text counter:(int *)counter {
    NSString *stylized;
    *counter += 1;

    stylized = (*counter % 2) ? [text localizedUppercaseString] : [text localizedLowercaseString];
    return stylized;
}

@end
