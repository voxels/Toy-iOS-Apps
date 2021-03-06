//
// Generated by CocoaPods-Keys
// on 19/06/2018
// For more information see https://github.com/orta/cocoapods-keys
//

#import <objc/runtime.h>
#import <Foundation/NSDictionary.h>
#import "PopulationQueryKeys.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation PopulationQueryKeys

  @dynamic bugsnagAPIKey;

#pragma clang diagnostic pop

+ (BOOL)resolveInstanceMethod:(SEL)name
{
  NSString *key = NSStringFromSelector(name);
  NSString * (*implementation)(PopulationQueryKeys *, SEL) = NULL;

  if ([key isEqualToString:@"bugsnagAPIKey"]) {
    implementation = _podKeysa3491556f1fc3a8895d0f5ea2c862c27;
  }

  if (!implementation) {
    return [super resolveInstanceMethod:name];
  }

  return class_addMethod([self class], name, (IMP)implementation, "@@:");
}

static NSString *_podKeysa3491556f1fc3a8895d0f5ea2c862c27(PopulationQueryKeys *self, SEL _cmd)
{
  
    
      char cString[33] = { PopulationQueryKeysData[246], PopulationQueryKeysData[454], PopulationQueryKeysData[498], PopulationQueryKeysData[746], PopulationQueryKeysData[47], PopulationQueryKeysData[535], PopulationQueryKeysData[561], PopulationQueryKeysData[850], PopulationQueryKeysData[417], PopulationQueryKeysData[493], PopulationQueryKeysData[618], PopulationQueryKeysData[756], PopulationQueryKeysData[396], PopulationQueryKeysData[384], PopulationQueryKeysData[537], PopulationQueryKeysData[373], PopulationQueryKeysData[308], PopulationQueryKeysData[64], PopulationQueryKeysData[592], PopulationQueryKeysData[614], PopulationQueryKeysData[767], PopulationQueryKeysData[370], PopulationQueryKeysData[62], PopulationQueryKeysData[694], PopulationQueryKeysData[653], PopulationQueryKeysData[668], PopulationQueryKeysData[192], PopulationQueryKeysData[16], PopulationQueryKeysData[793], PopulationQueryKeysData[15], PopulationQueryKeysData[12], PopulationQueryKeysData[463], '\0' };
    
    return [NSString stringWithCString:cString encoding:NSUTF8StringEncoding];
  
}


static char PopulationQueryKeysData[858] = "AjrJSpYPFPSN9Bkb7MIwOvnFm6buHnuNZh0f+A56UAzE1pVbIcuSWzWUW7Ajwt5B5vnwdD+42GGhpkC9gBROOrpz8JNsKZY1hVOSDphrGb6dDB2Nj6iv0o5ynIbs4vvZ1w+6YcsrcRaPKCBFwsTAwDSddLOTlbXqAiBw8bIWx0gq7q2OIvAStZgIeN0oFfGvfrL7d8M7NK6XKaPH+mOc094ebfb0lQeWtUXNqvvpYaDNt+kRRKKDZr8riJ/km1Gs+/z31uBIL7Fmy4uubO+iVMr6aoJ6TjYCJVYSUMbX9gkHZ5xz5JSI3SSuboRp9jG/qiS/7Z7KRzJhcn6LjKZmEwgUjTtDt+G++P8naOuBsuRSinVxSK2Ju7/yi3ZhmEaQauuUjd2ZuNwW1f8zPWBE+IaQ8LzS2c+G15Vr2+QV3ofiB5tfFUwMcpKFnUBC/WWpqpipl3dcrYRQH9AcJwgEBAUo0vPT0vvpKFTexIwktwmj204+oS87mvQY0uiIr0O/UWYlR3KTPb+USsFoWau0VPN6p5oGwkAWzRWcQdtSh6kheYaM91b7p7NIbwow9VNlbDHQolHkJSkUkTDrd8meL4+tBFcIC/vWezoGjU00WAbxcfm0O2v6ua/lNA3NroFTDGcMIGJ9Pvdx88/TNE75Z8V0KvA4f4QeJtiewkvvJs8ZCwbMl0/zQX0TdPicCb3ehr/ZvkLPcmmUt38eMF7LeTqibDe6RzHTjJE4SlUDkc4cXyL0JLIg94ffj9efjMD4xUsV6ws7itwaufS1mSSIkF3fd9gjwDIkLNNfHq8luGq9no3UswspQ4W24he6LnbHeFfPzw4KVzu/m38LG49TOQ==\\\"";

- (NSString *)description
{
  return [@{
            @"bugsnagAPIKey": self.bugsnagAPIKey,
  } description];
}

- (id)debugQuickLookObject
{
  return [self description];
}

@end
