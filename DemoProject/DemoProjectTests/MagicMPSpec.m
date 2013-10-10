//
//  MagicMPSpec.m
//  DemoProject
//
//  Created by Pedro Piñera Buendía on 11/10/13.
//  Copyright (c) 2013 PPinera. All rights reserved.
//

#import "Kiwi.h"
#import "MagicMP.h"

SPEC_BEGIN(MagicMPSpec)

describe(@"MagicMP", ^{
    context(@"when start Advertising", ^{
        __block MCPeerID *peer;
        __block NSDictionary *discoveryInfo;
        __block NSString *serviceType;
        beforeEach(^{
            peer = [[MCPeerID alloc] initWithDisplayName:@"testPeer"];
            discoveryInfo=@{@"Evironment":@"Test",@"DeviceType":@"iPhone"};
            serviceType=@"DataTransfer";
        });
        it(@"should return shared instance",^{
            [[[MagicMP sharedMP] should] beNonNil];
        });
        it(@"should return error if serviceType is higher than 15 characters", ^{
            serviceType=@"HeeeeeeeeyyIamATestUserAham!";
            __block NSError *error;
            [[MagicMP sharedMP] startAdvertisingWithPeer:peer discoveryInfo:discoveryInfo serviceType:serviceType withInvitationBlock:^BOOL(MCPeerID *peerID, NSData *context) {
                return NO;
            } andError:^(NSError *error) {
                error=error;
            }];
            [[error shouldAfterWait] beNonNil];
        });
        it(@"should return error if there's no peer id", ^{
            peer=nil;
            __block NSError *error;
            [[MagicMP sharedMP] startAdvertisingWithPeer:peer discoveryInfo:discoveryInfo serviceType:serviceType withInvitationBlock:^BOOL(MCPeerID *peerID, NSData *context) {
                return NO;
            } andError:^(NSError *error) {
                error=error;
            }];
            [[error shouldAfterWait] beNonNil];
        });
        it(@"should not initialized if there's no error block passed",^{
            [[MagicMP sharedMP] startAdvertisingWithPeer:peer discoveryInfo:discoveryInfo serviceType:serviceType withInvitationBlock:^BOOL(MCPeerID *peerID, NSData *context) {
                return NO;
            } andError:nil];
            [[[[MagicMP sharedMP] advertiserEntity] should] beNil];
        });
        
        it(@"should not initialized if there's no invitation block passed",^{
            [[MagicMP sharedMP] startAdvertisingWithPeer:peer discoveryInfo:discoveryInfo serviceType:serviceType withInvitationBlock:nil andError:nil];
            [[[[MagicMP sharedMP] advertiserEntity] should] beNil];
        });
        
        it(@"should have an advertiserEntity ready to start adverstising",^{
            [[MagicMP sharedMP] startAdvertisingWithPeer:peer discoveryInfo:discoveryInfo serviceType:serviceType withInvitationBlock:^BOOL(MCPeerID *peerID, NSData *context) {
                return NO;
            } andError:^(NSError *error) {
            }];
            [[[[MagicMP sharedMP] advertiserEntity] should]    beNonNil];
        });
        
        it(@"MagicMP should be the delegate of advertiserEntity",^{
            MagicMP *mp = [MagicMP sharedMP];
            [mp startAdvertisingWithPeer:peer discoveryInfo:discoveryInfo serviceType:serviceType withInvitationBlock:^BOOL(MCPeerID *peerID, NSData *context) {
                return NO;
            } andError:^(NSError *error) {
                
            }];
            [[(NSObject*)mp.advertiserEntity.delegate should] equal:mp];
        });
        
        it(@"MagicMP should have a session Opened",^{
            MagicMP *mp = [MagicMP sharedMP];
            [mp startAdvertisingWithPeer:peer discoveryInfo:discoveryInfo serviceType:serviceType withInvitationBlock:^BOOL(MCPeerID *peerID, NSData *context) {
                return NO;
            } andError:^(NSError *error) {
            }];
            [[(NSObject*)mp.advertiserSession should] beNonNil];
        });
        
    });
    
});

SPEC_END