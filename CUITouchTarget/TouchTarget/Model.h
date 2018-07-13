//
//  Model.h
//  TouchTarget
//
//  Created by Voxels on 1/12/17.
//  Copyright © 2017 Noise Derived. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface Model : NSObject

- (CFTimeInterval) getCurrentTime;

- (void) onTouchesBeganWithEvent:(NSEvent *)event;
- (void) onTouchesMovedWithEvent:(NSEvent *)event;
- (void) onTouchesEndedWithEvent:(NSEvent *)event;
- (void) onTouchesCancelled;

@end
