//
//  ViewModelTests.m
//  PopulationQueryTests
//
//  Copyright © 2017 Michael Edgcumbe. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "PopulationQuery-Swift.h"

@interface ViewModelTests : XCTestCase
@property (strong, nonatomic) MainViewController *viewController;
@property (strong, nonatomic) id mockViewController;
@property (strong, nonatomic) ViewModel *model;
@property (strong, nonatomic) id mockViewModel;
@property (strong, nonatomic) LocalStoreManager *localStoreManager;
@property (strong, nonatomic) id mockLocalStoreManager;

@end

@implementation ViewModelTests

- (void)setUp {
    [super setUp];
    self.viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MainViewController"];
    self.mockViewController = OCMPartialMock(self.viewController);
    self.model = [[ViewModel alloc] init];
    self.mockViewModel = OCMPartialMock(self.model);
    self.localStoreManager = [[LocalStoreManager alloc] init];
    self.mockLocalStoreManager = OCMPartialMock(self.localStoreManager);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [self.mockViewModel stopMocking];
    [self.mockLocalStoreManager stopMocking];
    [super tearDown];
}

- (void)testRefreshCallsManagerRefresh {
    OCMExpect([self.mockLocalStoreManager refreshWith:OCMOCK_ANY]);
    OCMStub([self.mockLocalStoreManager refreshWith:OCMOCK_ANY]);
    [self.model refreshWith:self.localStoreManager];
    OCMVerifyAll(self.mockLocalStoreManager);
}

- (void)testRefreshCompletionCallsModelDidUpdate {
    self.model.delegate = self.viewController;
    
    OCMExpect([self.mockViewController modelDidUpdate]);
    OCMStub([self.mockViewController modelDidUpdate]);
    OCMStub([self.mockLocalStoreManager refreshWith:OCMOCK_ANY]).andDo(^(NSInvocation *invocation){
        typedef void (^Completion)(void);
        __unsafe_unretained Completion completionPointer;
        [invocation getArgument:&completionPointer atIndex:2];
        completionPointer();
    });
    
    [self.model refreshWith:self.localStoreManager];
    OCMVerifyAll(self.mockViewController);
}

@end
