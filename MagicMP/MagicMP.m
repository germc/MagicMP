//
//  MagicMP.m
//  DemoProject
//
//  Created by Pedro Piñera Buendía on 11/10/13.
//  Copyright (c) 2013 PPinera. All rights reserved.
//

#import "MagicMP.h"

@interface MagicMP()
@property (nonatomic, copy) errorBlock errorBlock;
@property (nonatomic, copy) invitationBlock invitationBlock;

@end

@implementation MagicMP

#pragma mark - Initializer
+(id)sharedMP{
    static MagicMP *sharedMP = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMP = [[self alloc] init];
    });
    return sharedMP;
}

#pragma mark - Advertiser
-(void)startAdvertisingWithPeer:(MCPeerID*)peer discoveryInfo:(NSDictionary*)discoveryInfo serviceType:(NSString*)servicetype withInvitationBlock:(invitationBlock)invitationBlock andError:(errorBlock)errorBlock{
    //Stopping the current advertisingEntity
    if(self.advertiserEntity){
        [self.advertiserEntity stopAdvertisingPeer];
    }
    self.advertiserEntity=nil;
    
    //Detecting if there's no error block
    if(!errorBlock){
        NSLog(@"MagicMP: Error block required");
        return;
    }
    _errorBlock=errorBlock;
    
    //Detecting if there's no invitation block
    if(!invitationBlock){
        NSLog(@"MagicMP: Invitation block required");
        return;
    }
    _invitationBlock=invitationBlock;
    
    //Detecting if the serviceType length is less than 15 characters
    if (servicetype.length>15){
        errorBlock([NSError errorWithDomain:@"serviceType length should be 1-15 characters" code:1 userInfo:nil]);
        return;
    }

    
    //Detecting if there's peerID
    if(!peer){
        errorBlock([NSError errorWithDomain:@"PeerID cannot be nil" code:1 userInfo:nil]);
        return;
    }
    
    //Initializing
    _advertiserEntity = [[MCNearbyServiceAdvertiser alloc] initWithPeer:peer discoveryInfo:discoveryInfo serviceType:servicetype];
    
    //Setting delegate
    _advertiserEntity.delegate=self;

}


#pragma mark - MCNearbyServiceAdvertiserDelegate
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error{
    //Checking if the MCNearbyServiceAdvertiser is the same
    if(advertiser == self.advertiserEntity){
        self.errorBlock(error);
    }
}
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL accept, MCSession *session))invitationHandler{
    
    //Calling invitabion block
    BOOL peerAccepted=self.invitationBlock(peerID,context);
    
}
@end
