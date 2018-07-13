//
//  ViewController.m
//  TouchTarget
//
//  Created by Voxels on 1/12/17.
//  Copyright © 2017 Noise Derived. All rights reserved.
//

#import "ViewController.h"
#import "Model.h"

@interface ViewController()
@property (strong, nonatomic) Model *model;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.acceptsTouchEvents = true;
    self.model = [[Model alloc] init];
    
    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

// MARK: - Mouse Events

- (void)mouseDown:(NSEvent *)event
{
    
}

- (void)mouseUp:(NSEvent *)event
{
    
}

- (void)mouseMoved:(NSEvent *)event
{
    
}

- (void)mouseDragged:(NSEvent *)event
{
    
}

- (void)mouseExited:(NSEvent *)event
{
    
}

- (void)mouseEntered:(NSEvent *)event
{
    
}


// MARK: - Touch Events

- (void)touchesBeganWithEvent:(NSEvent *)event
{
    NSLog(@"Touches began");
    [self.model onTouchesBeganWithEvent:event];
}

- (void)touchesMovedWithEvent:(NSEvent *)event
{
    // Do Nothing
}

- (void)touchesEndedWithEvent:(NSEvent *)event
{
    NSLog(@"Touches ended");
    [self.model onTouchesEndedWithEvent:event];
}

- (void)touchesCancelledWithEvent:(NSEvent *)event
{
    NSLog(@"Touches cancelled");
    [self.model onTouchesCancelled];
}


@end
