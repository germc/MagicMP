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
-(void)setDelegate:(id)delegate andSession:(MCSession*)session{
    self.delegate=delegate;
    self.session=session;
}
+(id)sharedMP{
    static MagicMP *sharedMP = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMP = [[self alloc] init];
    });
    return sharedMP;
}
-(id)initWithSession:(MCSession*)session andDelegate:(id)delegate{
    // Returning if no delegate or session
    if(!delegate){
        return nil;
    }
    
    self=[super init];
    if(self){
        if(session)
            self.session=session;
        self.delegate=delegate;
    }
    return self;
}
#pragma mark - Session
-(MCSession*)session{
    if(!_session)_session=[[MCSession alloc] initWithPeer:[[MCPeerID alloc] initWithDisplayName:@"MagicMPeer"]];
    _session.delegate=self.delegate;
    return _session;
}

#pragma mark - Browser

-(BOOL)startBrowsingWithServiceType:(NSString*)serviceType withUserFound:(userFoundBlock)userFound UserLost:(userLostBlock)userLost andErrorBlock:(errorBlock)errorBlock{

    //Stopping the current browserEntity
    [self stopBrowsing];
    
    //Detecting if there's no error block
    if(!errorBlock){
        NSLog(@"MagicMP: Error block required");
        return NO;
    }
    _errorBlock=errorBlock;
    
    //Detecting if there's no userFound block
    if(!userFound){
        NSLog(@"MagicMP: Invitation userFound block required");
        return NO;
    }
    _userFoundBlock=userFound;
    
    //Detecting if there's no userLost block
    if(!userLost){
        NSLog(@"MagicMP: Invitation userLost block required");
        return NO;
    }
    _userLostBlock=userLost;
    
    //Detecting if the serviceType length is less than 15 characters
    if (serviceType.length>15){
        errorBlock([NSError errorWithDomain:@"serviceType length should be 1-15 characters" code:1 userInfo:nil]);
        return NO;
    }
    
    //Initializing browser entity
    _browserEntity = [[MCNearbyServiceBrowser alloc] initWithPeer:self.session.myPeerID serviceType:serviceType];
    
    //Setting delegate
    _browserEntity.delegate=self;
    
    [self.browserEntity startBrowsingForPeers];
    
    return YES;
}
-(BOOL)stopBrowsing{
    // Stopping browsingEntity
    [self.browserEntity stopBrowsingForPeers];
    self.browserEntity=nil;

    // Cleaning foundAdvertisersArray
    self.foundAdvertisers=nil;
    
    return YES;
}
-(NSMutableArray*)foundAdvertisers{
    if(!_foundAdvertisers)_foundAdvertisers=[NSMutableArray new];
    return _foundAdvertisers;
}
-(BOOL)invitePeer:(MCPeerID*)peer withContext:(NSData*)context timeout:(NSTimeInterval)timeout{
    //Detecting if there's user
    if(!peer){
        NSLog(@"MagicMP: No peer given to invite");
        return NO;
    }
    
    //Detecting if there's context
    if(!context){
        NSLog(@"MagicMP: No context given to invite");
        return NO;
    }
    
    if(!self.browserEntity || !self.session){
        return NO;
    }
    [self.browserEntity invitePeer:peer toSession:self.session withContext:context timeout:timeout];
    return YES;
}
#pragma mark - MCNearbyBrowserDelegate
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info{
    if(self.userFoundBlock && [browser isEqual:self.browserEntity]){
        self.userFoundBlock(peerID,browser,info);
        
        //Adding user to array
        [self.foundAdvertisers addObject:peerID];
    }
}
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID{
    if(self.userLostBlock && [browser isEqual:self.browserEntity]){
        self.userLostBlock(peerID,browser);
        
        //Deleting user from array
        [self.foundAdvertisers removeObject:peerID];
    }
}
- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error{
    if(self.errorBlock && [browser isEqual:self.browserEntity]){
        self.errorBlock(error);
    }
}
#pragma mark - Advertiser
-(BOOL)startAdvertisingWithDiscoveryInfo:(NSDictionary*)discoveryInfo serviceType:(NSString*)servicetype withInvitationBlock:(invitationBlock)invitationBlock andError:(errorBlock)errorBlock{
    
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
    
    //Initializing
    _advertiserEntity = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.session.myPeerID discoveryInfo:discoveryInfo serviceType:servicetype];
    
    //Setting delegate
    _advertiserEntity.delegate=self;
    
    return YES;
}
-(BOOL)stopAdvertisingPeer{
    
    //Cleaning the advertiser
    [self.advertiserEntity stopAdvertisingPeer];
    self.advertiserEntity=nil;
    
    return YES;
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
    
    //Accepting connection from peer
    invitationHandler(peerAccepted,self.session);
}
@end
