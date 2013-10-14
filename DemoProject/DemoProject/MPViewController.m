//
//  MPViewController.m
//  DemoProject
//
//  Created by Pedro Piñera Buendía on 10/10/13.
//  Copyright (c) 2013 PPinera. All rights reserved.
//

#import "MPViewController.h"

@interface MPViewController ()

@end

@implementation MPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    MagicMP *mp=[MagicMP sharedMP];
    [mp setDelegate:self andSession:[[MCSession alloc] initWithPeer:[[MCPeerID alloc] initWithDisplayName:@"testUser"]]];
    
    [mp startAdvertisingWithDiscoveryInfo:@{@"Info":@"Magic Data Transfer"} serviceType:@"Data Transfer" withInvitationBlock:^BOOL(MCPeerID *peerID, NSData *context) {
        //Depending on the peerID I allow or not connection
        if([peerID.displayName isEqualToString:@"testPeer"]){
            return YES;
        }
        return NO;
    } andError:^(NSError *error) {
        //Something bad happened
        NSLog(@"%@",error);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
