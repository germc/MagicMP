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
    context(@"when stop Advertising", ^{
        __block MCPeerID *peer;
        __block NSDictionary *discoveryInfo;
        __block NSString *serviceType;
        __block MagicMP *mp = [MagicMP sharedMP];

        beforeEach(^{
            peer = [[MCPeerID alloc] initWithDisplayName:@"testPeer"];
            discoveryInfo=@{@"Evironment":@"Test",@"DeviceType":@"iPhone"};
            serviceType=@"DataTransfer";
            [mp startAdvertisingWithPeer:peer discoveryInfo:discoveryInfo serviceType:serviceType withInvitationBlock:^BOOL(MCPeerID *peerID, NSData *context) {
                return NO;
            } andError:^(NSError *error) {
            }];
            [mp stopAdvertisingPeer];
        });
        
        it(@"should delete all peers", ^{
            [[theValue(mp.peers.count) should] equal:theValue(0)];
        });
        it(@"should clean the session", ^{
            [[mp.advertiserSession should] beNil];
        });
        it(@"shouldn't have MCNearbyServiceAdvertiser (stopped) ", ^{
            [[mp.advertiserEntity should] beNil];
        });
    });
    context(@"when start Advertising", ^{
        __block MCPeerID *peer;
        __block NSDictionary *discoveryInfo;
        __block NSString *serviceType;
        beforeEach(^{
            peer = [[MCPeerID alloc] initWithDisplayName:@"testPeer"];
            discoveryInfo=@{@"Evironment":@"Test",@"DeviceType":@"iPhone"};
            serviceType=@"DataTransfer";
        });
        
        afterEach(^{
            [(MagicMP*)[MagicMP sharedMP] stopAdvertisingPeer];
        });
        
        it(@"should return shared instance",^{
            [[[MagicMP sharedMP] should] beNonNil];
        });
        it(@"should have no peers",^{
            [[theValue([[[MagicMP sharedMP] peers] count]) should] equal:theValue(0)];
        });
        it(@"should be the delegate of MCSession",^{
            [[(id)[[[MagicMP sharedMP] advertiserSession] delegate] should] equal:[MagicMP sharedMP]];
        });
        it(@"should return error if serviceType is higher than 15 characters", ^{
            serviceType=@"HeeeeeeeeyyIamATestUserAham!";
            BOOL started=[[MagicMP sharedMP] startAdvertisingWithPeer:peer discoveryInfo:discoveryInfo serviceType:serviceType withInvitationBlock:^BOOL(MCPeerID *peerID, NSData *context) {
                return NO;
            } andError:^(NSError *error) {
            }];
            [[theValue(started) should] equal:theValue(NO)];
        });
        it(@"should return error if there's no peer id", ^{
            peer=nil;
            BOOL started=[[MagicMP sharedMP] startAdvertisingWithPeer:peer discoveryInfo:discoveryInfo serviceType:serviceType withInvitationBlock:^BOOL(MCPeerID *peerID, NSData *context) {
                return NO;
            } andError:^(NSError *error) {
            }];
            [[theValue(started) should] equal:theValue(NO)];
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
    
    context(@"when start Browsing", ^{
        __block MCPeerID *peer;
        __block NSString *serviceType;
        __block MagicMP *mp = [MagicMP sharedMP];
        
        beforeEach(^{
            peer = [[MCPeerID alloc] initWithDisplayName:@"testPeer"];
            serviceType=@"DataTransfer";
            [mp stopBrowsing];
        });
        it(@"shoudl have no found advertisers", ^{
           [mp startBrowsingWithPeer:peer serviceType:@"DataTransfer" withUserFound:^(MCPeerID *peerID, MCNearbyServiceBrowser *browser, NSDictionary *discoveryInfo) {
               
           } UserLost:^(MCPeerID *peerID, MCNearbyServiceBrowser *browser) {
               
           } andErrorBlock:^(NSError *error) {
               
           }];
        });
        
        
    });
    context(@"when stop Browsing", ^{
       it(@"should have no browserEntity after stop browsing", ^{
           [[MagicMP sharedMP] stopBrowsing];
           [[[MagicMP sharedMP] browserEntity] shouldBeNil];
       });
    });
});

SPEC_END