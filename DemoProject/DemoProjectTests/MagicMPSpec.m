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
            [mp startAdvertisingWithDiscoveryInfo:discoveryInfo serviceType:serviceType withInvitationBlock:^BOOL(MCPeerID *peerID, NSData *context) {
                return NO;
            } andError:^(NSError *error) {
                
            }];
            [mp stopAdvertisingPeer];
        });
        
        it(@"shouldn't have MCNearbyServiceAdvertiser (stopped) ", ^{
            [[mp.advertiserEntity should] beNil];
        });
    });
    context(@"when start Advertising", ^{
        __block MCPeerID *peer;
        __block NSDictionary *discoveryInfo;
        __block NSString *serviceType;
        __block MagicMP *mp=[MagicMP sharedMP];
        beforeEach(^{
            peer = [[MCPeerID alloc] initWithDisplayName:@"testPeer"];
            discoveryInfo=@{@"Evironment":@"Test",@"DeviceType":@"iPhone"};
            serviceType=@"DataTransfer";
            [mp startAdvertisingWithDiscoveryInfo:discoveryInfo serviceType:serviceType withInvitationBlock:^BOOL(MCPeerID *peerID, NSData *context) {
                return NO;
            } andError:^(NSError *error) {
                
            }];
        });
        
        afterEach(^{
            [mp stopAdvertisingPeer];
        });
        
        it(@"should return shared instance",^{
            [[mp should] beNonNil];
        });
        
        it(@"should be the delegate of MCSession",^{
            [[(NSObject*)mp.advertiserEntity.delegate should] equal:mp];
        });
        it(@"should return error if serviceType is higher than 15 characters", ^{
            serviceType=@"HeeeeeeeeyyIamATestUserAham!";
            BOOL started=[mp startAdvertisingWithDiscoveryInfo:discoveryInfo serviceType:serviceType withInvitationBlock:^BOOL(MCPeerID *peerID, NSData *context) {
                return NO;
            } andError:^(NSError *error) {
            }];
            [[theValue(started) should] equal:theValue(NO)];
        });
        it(@"should not initialized if there's no error block passed",^{
            [mp startAdvertisingWithDiscoveryInfo:discoveryInfo serviceType:serviceType withInvitationBlock:^BOOL(MCPeerID *peerID, NSData *context) {
                return NO;
            } andError:nil];
            [[[[MagicMP sharedMP] advertiserEntity] should] beNil];
        });
        
        it(@"should not initialized if there's no invitation block passed",^{
            [mp startAdvertisingWithDiscoveryInfo:discoveryInfo serviceType:serviceType withInvitationBlock:nil andError:^(NSError *error) {
                
            }];
            [[[[MagicMP sharedMP] advertiserEntity] should] beNil];
        });
        
        it(@"should have an advertiserEntity ready to start adverstising",^{
            [[[mp advertiserEntity] should]    beNonNil];
        });
        
        it(@"MagicMP should be the delegate of advertiserEntity",^{
            [[(NSObject*)mp.advertiserEntity.delegate should] equal:mp];
        });
        
        it(@"MagicMP should have a session Opened",^{
            [[(NSObject*)mp.session should] beNonNil];
        });
    });
    
    context(@"when start Browsing", ^{
        __block MCPeerID *peer;
        __block NSString *serviceType;
        __block MagicMP *mp = [MagicMP sharedMP];
        
        beforeEach(^{
            peer = [[MCPeerID alloc] initWithDisplayName:@"testPeer"];
            serviceType=@"DataTransfer";
            [mp startBrowsingWithServiceType:@"DataTransfer" withUserFound:^(MCPeerID *peerID, MCNearbyServiceBrowser *browser, NSDictionary *discoveryInfo) {
                
            } UserLost:^(MCPeerID *peerID, MCNearbyServiceBrowser *browser) {
                
            } andErrorBlock:^(NSError *error) {
                
            }];
        });
        afterEach(^{
            [mp stopBrowsing];
        });
        
        it(@"should give error if there's no peer to invite", ^{
            BOOL success=[mp invitePeer:nil withContext:[@"TestContext" dataUsingEncoding:NSUTF8StringEncoding] timeout:20];
            [[theValue(success) should] equal:theValue(NO)];
        });
        it(@"should give error if there's no context", ^{
            BOOL success=[mp invitePeer:[[MCPeerID alloc] initWithDisplayName:@"testPeer"] withContext:nil timeout:20];
            [[theValue(success) should] equal:theValue(NO)];
        });

        it(@"should have no found advertisers", ^{
            [[theValue(mp.foundAdvertisers.count) should] equal:theValue(0)];
        });
        it(@"should fail if no UserFound block given",^{
            BOOL started=[mp startBrowsingWithServiceType:@"DataTransfer" withUserFound:nil UserLost:^(MCPeerID *peerID, MCNearbyServiceBrowser *browser) {
                
            } andErrorBlock:^(NSError *error) {
                
            }];
            [[theValue(started) should] equal:theValue(NO)];
        });
        
        it(@"should fail if no userLost block given",^{
            BOOL started=[mp startBrowsingWithServiceType:@"DataTransfer" withUserFound:^(MCPeerID *peerID, MCNearbyServiceBrowser *browser, NSDictionary *discoveryInfo) {
                
            } UserLost:nil andErrorBlock:^(NSError *error) {
                
            }];
            [[theValue(started) should] equal:theValue(NO)];
        });
        
        it(@"should have a browser entity valid", ^{
            [[mp.browserEntity should] beNonNil];
        });
        
    });
    context(@"when stop Browsing", ^{
        __block MCPeerID *peer;
        __block NSString *serviceType;
        __block MagicMP *mp = [MagicMP sharedMP];
        
        beforeEach(^{
            peer = [[MCPeerID alloc] initWithDisplayName:@"testPeer"];
            serviceType=@"DataTransfer";
            [mp startBrowsingWithServiceType:@"DataTransfer" withUserFound:^(MCPeerID *peerID, MCNearbyServiceBrowser *browser, NSDictionary *discoveryInfo) {
                
            } UserLost:^(MCPeerID *peerID, MCNearbyServiceBrowser *browser) {
                
            } andErrorBlock:^(NSError *error) {
                
            }];
            [mp stopBrowsing];
        });
       it(@"should have no browserEntity after stop browsing", ^{
           [[mp browserEntity] shouldBeNil];
       });
        it(@"should have no advertisers found", ^{
            [[theValue(mp.foundAdvertisers.count) should] equal:theValue(0)];
        });
    });
});

SPEC_END