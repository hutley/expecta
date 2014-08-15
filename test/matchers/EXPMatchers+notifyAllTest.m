#import "TestHelper.h"

@interface EXPMatchers_notifyAllTest : TEST_SUPERCLASS
@end

@implementation EXPMatchers_notifyAllTest

- (void)test_notify {
  assertPass(test_expect(^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"testNotification1" object:nil];
  }).to.notifyAll(@"testNotification1"));
  
  assertPass(test_expect(^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"testNotification1" object:nil];
  }).to.notifyAll(@[@"testNotification1"]));
  
  assertPass(test_expect(^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"testNotification1" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"testNotification2" object:nil];
  }).to.notifyAll(@[@"testNotification1", @"testNotification2"]));
  
  NSNotification *n1 = [[NSNotification alloc] initWithName:@"testNotification2" object:self userInfo:nil];
  
  assertPass(test_expect(^{
    [[NSNotificationCenter defaultCenter] postNotification:n1];
  }).to.notifyAll(n1));

  assertPass(test_expect(^{
    [[NSNotificationCenter defaultCenter] postNotification:n1];
  }).to.notifyAll(@[n1]));
  
  NSNotification *n2 = [[NSNotification alloc] initWithName:@"testNotification2" object:self userInfo:@{@"test" : @"value2"}];

  assertPass(test_expect(^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"testNotification2" object:self userInfo:@{@"test" : @"value2"}];
  }).to.notifyAll(n2));
  
  
  assertPass(test_expect(^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"testNotification1" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"testNotification2" object:self userInfo:@{@"test" : @"value2"}];
  }).to.notifyAll(@[n2,@"testNotification1"]));
  
  assertPass(test_expect(^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"testNotification1" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:n2];

  }).to.notifyAll(@[@"testNotification1",n2]));
  
  assertPass(test_expect(^{
    [[NSNotificationCenter defaultCenter] postNotification:n1];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"testNotification2" object:self userInfo:@{@"test" : @"value"}];
  }).to.notifyAll(n1));
  
  assertPass(test_expect(^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"testNotification1" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"testNotification2" object:nil];
  }).to.notifyAll(@"testNotification1"));
    
  assertPass(test_expect(^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"testNotification2" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"testNotification1" object:nil];
  }).to.notifyAll(@"testNotification1"));
    
  assertPass(test_expect(^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"testNotification2" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"testNotification1" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"testNotification2" object:nil];
  }).to.notifyAll(@"testNotification1"));

  assertPass(test_expect(^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"testNotification1" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"testNotification1" object:nil];
  }).to.notifyAll(@"testNotification1"));
  
  assertPass(test_expect(^{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
      [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationName" object:nil];
    });
  }).will.notifyAll(@"NotificationName"));
  
  assertFail(test_expect(^{
    // no notification
  }).to.notifyAll(@"testNotification2"),
             @"expected all of: testNotification2, got: none");
  
  assertFail(test_expect(nil).to.notify(@"testNotification"),
             @"the actual value is nil/null");
  
  assertFail(test_expect(^{
    // no notification
  }).to.notifyAll(nil),
             @"the expected value is nil/null");
  
  assertFail(test_expect(^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"testNotification1" object:nil];
  }).to.notifyAll(@"testNotification2"),
             @"expected all of: testNotification2, got: none");
  
  assertFail(test_expect(^{
    // not doing anything
  }).to.notifyAll([[NSObject alloc] init]), @"the actual value is not a notification, string, or list");
  
  assertFail(test_expect(^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"testNotification2" object:self userInfo:@{@"test" : @"value"}];
  }).to.notifyAll(n2), @"expected all of: testNotification2, got: none");
  
}

- (void)test_toNot_notify {
  assertPass(test_expect(^{
    // no notification
  }).notTo.notifyAll(@"testExpectaNotification1"));
  
  assertFail(test_expect(^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"testNotification1" object:nil];
  }).toNot.notifyAll(@[@"testNotification2",@"testNotification1"]),
             @"expected: none, got: testNotification1");
  
  assertFail(test_expect(^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"testNotification1" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"testNotification2" object:nil];

  }).toNot.notifyAll(@[@"testNotification2",@"testNotification1"]),
             @"expected: none, got: testNotification1, testNotification2");
  
  
  assertFail(test_expect(^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"testNotification1" object:nil];
  }).toNot.notifyAll(@"testNotification1"),
             @"expected: none, got: testNotification1");
  
  
  assertPass(test_expect(^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"testNotification1" object:nil];
  }).notTo.notifyAll(@"testNotification2"));
  
  NSNotification *n1 = [[NSNotification alloc] initWithName:@"testNotification4" object:self userInfo:nil];
  NSNotification *n2 = [[NSNotification alloc] initWithName:@"testNotification4" object:nil userInfo:nil];
  assertPass(test_expect(^{
    [[NSNotificationCenter defaultCenter] postNotification:n1];
  }).toNot.notifyAll(n2));
  
  assertPass(test_expect(^{
    // no notification
  }).willNot.notifyAll(@"NotificationName"));
  
  
  assertFail(test_expect(nil).toNot.notify(@"testNotification"),
             @"the actual value is nil/null");
  
  assertFail(test_expect(^{
    // no notification
  }).toNot.notifyAll(nil),
             @"the expected value is nil/null");
  
  assertFail(test_expect(^{
    // no notification
  }).toNot.notifyAll([[NSObject alloc] init]), @"the actual value is not a notification, string, or list");
  
}

@end
