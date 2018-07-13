//
//  Model.m
//  TouchTarget
//
//  Created by Voxels on 1/12/17.
//  Copyright © 2017 Noise Derived. All rights reserved.
//

#import "Model.h"

#import "CTimeClock.hpp"
#import "CUITouchTarget.hpp"

@interface Model()
{
    CTimeClock clock;
    CUITouchTarget target;
}

// Using an array to hold on to the memory space for the locations of the touch events
// Memory management is assumed to be handled elsewhere
@property (strong, nonatomic) NSMutableArray<NSValue *> *allPositions;

@end

@implementation Model

- (id) init
{
    self = [super init];
    if( self )
    {
        self.allPositions = [NSMutableArray new];
    }
    return self;
}

- (CFTimeInterval) getCurrentTime
{
    return clock.GetCurrentTime();
}


- (void) onTouchesBeganWithEvent:(NSEvent *)event
{
    NSMutableArray *positions = [self positionsForEvent:event];
    
    if( positions.count == 0 )
    {
        return;
    }
    
    CUIPoint convertedPositions[positions.count];
    
    for( int ii = 0; ii < positions.count; ++ii )
    {
        NSValue *value = positions[ii];
        NSPoint thisPoint = value.pointValue;
        
        CUIPoint convertedPoint = [self pointFromNSPoint:thisPoint];
        NSValue *storePoint = [NSValue valueWithBytes:&convertedPoint objCType:@encode(CUIPoint)];

        [self.allPositions addObject:storePoint];
        convertedPositions[ii] = convertedPoint;
    }
    
    target.OnTouchBegan(*convertedPositions, positions.count);
}

- (void) onTouchesMovedWithEvent:(NSEvent *)event
{
    // Do nothing
//    NSMutableArray *positions = [self positionsForEvent:event];
//    NSLog(@"Positions: %@", positions);
}

- (void) onTouchesEndedWithEvent:(NSEvent *)event
{
    NSMutableArray *positions = [self positionsForEvent:event];
    CUIPoint convertedPositions[positions.count];
    
    for( int ii = 0; ii < positions.count; ++ii )
    {
        NSValue *value = positions[ii];
        NSPoint thisPoint = value.pointValue;
        
        CUIPoint convertedPoint = [self pointFromNSPoint:thisPoint];
        NSValue *storePoint = [NSValue valueWithBytes:&convertedPoint objCType:@encode(CUIPoint)];
        
        [self.allPositions addObject:storePoint];
        convertedPositions[ii] = convertedPoint;
    }
    
    target.OnTouchEnded(*convertedPositions, positions.count);
}

- (void) onTouchesCancelled
{
    target.OnTouchCancelled();
}

- (NSMutableArray *)positionsForEvent:(NSEvent *)event
{
    NSSet *touches = event.allTouches;
    
    NSMutableArray *allPositions = [[NSMutableArray alloc] init];
    for ( NSTouch *touch in touches )
    {
        NSPoint position = touch.normalizedPosition;
        NSValue *positionValue = [NSValue valueWithPoint:position];
        [allPositions addObject:positionValue];
    }
    
    return allPositions;
}

- (CUIPoint) pointFromNSPoint:(NSPoint)point
{
    CUIPoint retval = CUIPoint();
    retval.xPos = point.x;
    retval.yPos = point.y;
    return retval;
}

@end
