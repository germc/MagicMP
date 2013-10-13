//
//  MagicMP.h
//  DemoProject
//
//  Created by Pedro Piñera Buendía on 11/10/13.
//  Copyright (c) 2013 PPinera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
//Typedefs
typedef void(^errorBlock)(NSError *error);
typedef BOOL(^invitationBlock)(MCPeerID *peerID,NSData *context);
typedef void(^userFoundBlock)(MCPeerID *peerID,MCNearbyServiceBrowser *browser,NSDictionary* discoveryInfo);
typedef void(^userLostBlock)(MCPeerID *peerID,MCNearbyServiceBrowser *browser);

@interface MagicMP : NSObject <MCNearbyServiceAdvertiserDelegate,MCNearbyServiceBrowserDelegate,MCSessionDelegate>

+(id)sharedMP;
+(id)sharedMPWithSession:(MCSession*)session;
-(id)initWithSession:(MCSession*)session;

//Advertiser
-(BOOL)startAdvertisingWithPeer:(MCPeerID*)peer discoveryInfo:(NSDictionary*)discoveryInfo serviceType:(NSString*)servicetype withInvitationBlock:(invitationBlock)invitationBlock andError:(errorBlock)errorBlock;
-(BOOL)stopAdvertisingPeer;

//Browser
-(BOOL)startBrowsingWithPeer:(MCPeerID*)peer serviceType:(NSString*)serviceType withUserFound:(userFoundBlock)userFound UserLost:(userLostBlock)userLost andErrorBlock:(errorBlock)errorBlock;
-(BOOL)stopBrowsing;
-(BOOL)invitePeer:(MCPeerID*)peer withContext:(NSData*)context timeout:(NSTimeInterval)timeout;

// Properties
@property (nonatomic,strong) MCNearbyServiceAdvertiser *advertiserEntity;
@property (nonatomic,strong) MCNearbyServiceBrowser *browserEntity;
@property (nonatomic,strong) MCSession *session;
@property (nonatomic,readonly) NSMutableArray *foundAdvertisers;


@end
