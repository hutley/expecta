#import "EXPMatchers+notifyAll.h"

EXPMatcherImplementationBegin(notifyAll, (id expected)){
  BOOL actualIsNil = (actual == nil);
  BOOL expectedIsNil = (expected == nil);
  BOOL isNotification = [expected isKindOfClass:[NSNotification class]];
  BOOL isName = [expected isKindOfClass:[NSString class]];
  BOOL isList = [expected isKindOfClass:[NSArray class]];

  __block NSArray *expectedList;
  __block NSMutableArray* observers = [[NSMutableArray alloc] init];
  __block NSMutableArray* receivedNames = [[NSMutableArray alloc] init];
  __block NSMutableArray* expectedNames = [[NSMutableArray alloc] init];
  prerequisite(^BOOL{
    if (actualIsNil || expectedIsNil) return NO;
    if (isNotification || isName) {
      expectedList = @[expected];
    }else if(isList) {
      expectedList = expected;
    }
    else return NO;
    
    for (id expectedObj in expectedList) {
      
      BOOL expObjIsNotification = NO;

      NSString* expectedName = nil;
      if ([expectedObj isKindOfClass:[NSString class]]) {
        expectedName = expectedObj;
        expObjIsNotification = NO;
      } 
      else if ([expectedObj isKindOfClass:[NSNotification class]])
      {
        expObjIsNotification = YES;
        expectedName = [expectedObj name];
      }
      
      [expectedNames addObject:expectedName];

      id observer = [[NSNotificationCenter defaultCenter] addObserverForName:expectedName object:nil queue:nil usingBlock:^(NSNotification *note){
        BOOL expectedNotificationOccurred = NO;
        if (expObjIsNotification) {
          expectedNotificationOccurred |= [expectedObj isEqual:note];
        }else{
          expectedNotificationOccurred = YES;
        }
        
        if (expectedNotificationOccurred)
        {
          if(![receivedNames containsObject:expectedName])
          {
            [receivedNames addObject:expectedName];
          }
        }
      }];
      [observers addObject:observer];
    }

    ((EXPBasicBlock)actual)();
    return YES;
  });
  
  match(^BOOL{
    if (!self.negative)
    {
      BOOL receivedAll = (expectedNames.count == receivedNames.count);
      if (receivedAll) {
        for (id observer in observers) {
          [[NSNotificationCenter defaultCenter] removeObserver:observer];
        }
      }
      return receivedAll;
    }
    else 
    {
      return !(receivedNames.count == 0);
    }
  });
  
  failureMessageForTo(^NSString *{
    for (id observer in observers) {
      [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
    if(actualIsNil) return @"the actual value is nil/null";
    if(expectedIsNil) return @"the expected value is nil/null";
    if(!(isNotification || isName || isList)) return @"the actual value is not a notification, string, or list";
    NSString* received = [receivedNames componentsJoinedByString:@", "];
    return [NSString stringWithFormat:@"expected all of: %@, got: %@", [expectedNames componentsJoinedByString:@", "], (received.length > 0 ? received : @"none")];
  });
  
  failureMessageForNotTo(^NSString *{
    for (id observer in observers) {
      [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
    if(actualIsNil) return @"the actual value is nil/null";
    if(expectedIsNil) return @"the expected value is nil/null";
    if(!(isNotification || isName || isList)) return @"the actual value is not a notification, string, or list";
    return [NSString stringWithFormat:@"expected: none, got: %@", [receivedNames componentsJoinedByString:@", "]];
  });
}

EXPMatcherImplementationEnd
