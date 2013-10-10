#import "EXPMatchers+equal.h"
#import "EXPMatcherHelpers.h"

EXPMatcherImplementationBegin(_equal, (id expected)) {
  match(^BOOL{
    if((actual == expected) || [actual isEqual:expected]) {
      return YES;
    } else if([actual isKindOfClass:[NSNumber class]] && [expected isKindOfClass:[NSNumber class]]) {
      if(EXPIsNumberFloat((NSNumber *)actual) || EXPIsNumberFloat((NSNumber *)expected)) {
        return [(NSNumber *)actual floatValue] == [(NSNumber *)expected floatValue];
      }
    } else if ([actual isKindOfClass:[NSString class]] && [expected isKindOfClass:[NSNumber class]])
    {
        @try {
            
            NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
            NSNumber* actualNumber = [formatter numberFromString:actual];
            return (actualNumber == expected || [actualNumber isEqual:expected]);
        }
        @catch (NSException *exception) {
            return NO;
        }
    }
    return NO;
  });

  failureMessageForTo(^NSString *{
    return [NSString stringWithFormat:@"expected: %@, got: %@", EXPDescribeObject(expected), EXPDescribeObject(actual)];
  });

  failureMessageForNotTo(^NSString *{
    return [NSString stringWithFormat:@"expected: not %@, got: %@", EXPDescribeObject(expected), EXPDescribeObject(actual)];
  });
}
EXPMatcherImplementationEnd
