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
@property (nonatomic, copy) userFoundBlock userFoundBlock;
@property (nonatomic, copy) userLostBlock userLostBlock;
@property (nonatomic,strong) NSMutableArray *foundAdvertisers;
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
#pragma mark - Browser
-(BOOL)startBrowsingWithPeer:(MCPeerID*)peer serviceType:(NSString*)serviceType withUserFound:(userFoundBlock)userFound UserLost:(userLostBlock)userLost andErrorBlock:(errorBlock)errorBlock{
    
    return YES;
}
-(BOOL)stopBrowsing{
    
    return YES;
}
-(NSMutableArray*)foundAdvertisers{
    if(!_foundAdvertisers)_foundAdvertisers=[NSMutableArray new];
    return _foundAdvertisers;
}
#pragma mark - Advertiser
-(BOOL)startAdvertisingWithPeer:(MCPeerID*)peer discoveryInfo:(NSDictionary*)discoveryInfo serviceType:(NSString*)servicetype withInvitationBlock:(invitationBlock)invitationBlock session:(MCSession*)session andError:(errorBlock)errorBlock{
    //Stopping the current advertisingEntity
    [self stopAdvertisingPeer];
    
    //Detecting if there's no error block
    if(!errorBlock){
        NSLog(@"MagicMP: Error block required");
        return NO;
    }
    _errorBlock=errorBlock;
    
    //Detecting if there's no invitation block
    if(!invitationBlock){
        NSLog(@"MagicMP: Invitation block required");
        return NO;
    }
    _invitationBlock=invitationBlock;
    
    //Detecting if the serviceType length is less than 15 characters
    if (servicetype.length>15){
        errorBlock([NSError errorWithDomain:@"serviceType length should be 1-15 characters" code:1 userInfo:nil]);
        return NO;
    }
    
    
    //Detecting if there's peerID
    if(!peer){
        errorBlock([NSError errorWithDomain:@"PeerID cannot be nil" code:1 userInfo:nil]);
        return NO;
    }
    
    //Initializing
    _advertiserEntity = [[MCNearbyServiceAdvertiser alloc] initWithPeer:peer discoveryInfo:discoveryInfo serviceType:servicetype];
    
    //Setting delegate
    _advertiserEntity.delegate=self;
    
    //Pointing session
    self.advertiserSession=session;
    self.advertiserSession.delegate=self;

    return YES;
}
-(BOOL)startAdvertisingWithPeer:(MCPeerID*)peer discoveryInfo:(NSDictionary*)discoveryInfo serviceType:(NSString*)servicetype withInvitationBlock:(invitationBlock)invitationBlock andError:(errorBlock)errorBlock{
    
    //Initializing session (because it's not passed)
    if(!peer){
        // Have to return because we can't init session
        errorBlock([NSError errorWithDomain:@"PeerID cannot be nil" code:1 userInfo:nil]);
        return NO;
    }
    MCSession *session = [[MCSession alloc] initWithPeer:peer securityIdentity:nil encryptionPreference:MCEncryptionOptional];
    return [self startAdvertisingWithPeer:peer discoveryInfo:discoveryInfo serviceType:servicetype withInvitationBlock:invitationBlock session:session andError:errorBlock];
    
}
-(BOOL)stopAdvertisingPeer{
    //Cleaning the session
    [self.advertiserSession disconnect];
    
    self.advertiserSession=nil;
    
    //Cleaning the advertiser
    self.advertiserEntity = nil;
    
    //Deleting peers
    self.peers=nil;
    
    return YES;
}
-(NSMutableArray*)peers{
    if(!_peers)_peers=[NSMutableArray new];
    return _peers;
}

#pragma mark - MCNearbyServiceAdvertiserDelegate
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error{
    //Checking if the MCNearbyServiceAdvertiser is the same
    if(advertiser == self.advertiserEntity){
        self.errorBlock(error);
    }
}
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL accept, MCSession *session))invitationHandler{
    
    //Calling invitabion block to get if the peer is acepted or not
    BOOL peerAccepted=self.invitationBlock(peerID,context);
    
    if(peerAccepted){
        
    }
}
@end
