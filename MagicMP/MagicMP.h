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


@interface MagicMP : NSObject <MCNearbyServiceAdvertiserDelegate>

+(id)sharedMP;
-(void)startAdvertisingWithPeer:(MCPeerID*)peer discoveryInfo:(NSDictionary*)discoveryInfo serviceType:(NSString*)servicetype withInvitationBlock:(invitationBlock)invitationBlock andError:(errorBlock)errorBlock;

// Properties
@property (nonatomic,strong) MCNearbyServiceAdvertiser *advertiserEntity;
@property (nonatomic,strong) MCSession *advertiserSession;



@end
