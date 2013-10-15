# MagicMP - MultiPeer framework done better
![image](http://img801.imageshack.us/img801/786/wpqo.png)
I noticed that the new MultiPeer framework introduced in iOS 7 was segmented in two main components and still using delegates. The framework has an abstraction layer in viewController format to explore nearby users, or advertiser devices, but.. What if we don't want to implement  the module using viewControllers? **Here's where MagicMP appears, it unifies both components in an easy way, with blocks and a singleton class, use whenever you want without depending on a ViewController**

##  Components
* **MagicMP Class:** Class where everything is implemented
* **DemoProject:** Where we've implemented MagicMP. It's useful to see the implementation
* **Unit Tests:** Module's been developed using TDD. This way if any change causes the module not to work as expected, Unit Tests will cause crash. TravisCI is connected with the repo.

![image](http://www.imageshack.com/scaled/large/834/v8ww.jpg)


## How it works
Wherever you wan't to start browsing or advertising peers you've to initialize  MagicMP objet or singleton instance **(It's important to pass the delegate to receive any communication information from MCSession)**. Another input parameter is the session, it has information about our peerID, securityIdentity or encrytionPreference (__You'll find more information in [Apple Documentation](https://developer.apple.com/library/ios/documentation/MultipeerConnectivity/Reference/MCSessionClassRef/Reference/Reference.html)__). **Session is optional but recommended if you want to control previously commented parameters**. 

```objective-c
MagicMP *mp=[MagicMP sharedMP];
[mp setDelegate:self andSession:[[MCSession alloc] initWithPeer:[[MCPeerID alloc] initWithDisplayName:@"testUser"]]];
```
MagicMP delegate is a wrapper of MCSession one. [Protocol methods](https://developer.apple.com/library/ios/documentation/MultipeerConnectivity/Reference/MCSessionDelegateRef/Reference/Reference.html#//apple_ref/occ/intf/MCSessionDelegate) are here and you should implement them to control communication process

### Starting advertising
Start advertising is very easy. Once you have MagicMP instance with delegate an session setup call the following method passing the required blocks to be executed when some event happens in the communication:

```objective-c
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
```
The meaning of parameters are the following:
* **DiscoveryInfo:** Is a dictionary of string key/value pairs that will be advertised for browsers to see. The content of discoveryInfo will be advertised within Bonjour TXT records, and keeping the dictionary small is good for keeping network traffic low.
* **ServiceType:**  is a short text string used to describe the app's networking protocol. It should be in the same format as a Bonjour service type: 1–15 characters long and valid characters include ASCII lowercase letters, numbers, and the hyphen. A short name that distinguishes itself from unrelated services is recommended; for example, a text chat app made by ABC company could use the service type "abc-txtchat". For more information about service types, read “Domain Naming Conventions”.

**Important:** Both, invitation and error blocks are required. Not passing them supposes not start advertising
__Note: MCNearbyServiceAdvertiser can be got from advertiserEntity property of mp object__

### Start browsing
We can browse in a similar way tat we advertise. With a MagicMP instance with delegate and session setup call the following method passing a block to be executed when user's been found or lost:
```objective-c
[mp startBrowsingWithServiceType:@"Data Transfer" withUserFound:^(MCPeerID *peerID, MCNearbyServiceBrowser *browser, NSDictionary *discoveryInfo) {
        
    } UserLost:^(MCPeerID *peerID, MCNearbyServiceBrowser *browser) {
        
    } andErrorBlock:^(NSError *error) {
        
    }];
```
* **ServiceType:**  is a short text string used to describe the app's networking protocol. It should be in the same format as a Bonjour service type: 1–15 characters long and valid characters include ASCII lowercase letters, numbers, and the hyphen. A short name that distinguishes itself from unrelated services is recommended; for example, a text chat app made by ABC company could use the service type "abc-txtchat". For more information about service types, read “Domain Naming Conventions”.
* **userFound**: A block to be executed when a new advertiser user has been found
* **userLost**: A block to be executed when a found user has been lost
* **error**: A block to be executed if something strange happens

#### Notes
* You can now whenever you want the numver of currently found users through MagicMP property **foundAdvertisers**.
* You can invite an user to your session through the MagicMP method:`-(BOOL)invitePeer:(MCPeerID*)peer withContext:(NSData*)context timeout:(NSTimeInterval)timeout;`

### MCSession and delegate
MCSession has always information about what's happening in the communication process. You can access it through property called **session** of MagicMP object. Delegate of session must be implemented by you to take control when something interesting happens in the session. Taken from the Apple's Docummentation the methods you should implement are the following:
```objective-c
– session:didReceiveData:fromPeer:  required method
– session:didReceiveResourceAtURL:fromPeer:  required method
– session:didReceiveStream:withName:fromPeer:  required method
– session:peer:didChangeState:  required method
– session:shouldAcceptCertificate:forPeer:  required method
```
**Note that all methods are required. More information [here](https://developer.apple.com/library/ios/documentation/MultipeerConnectivity/Reference/MCSessionDelegateRef/Reference/Reference.html)**

#### Sending data and resources
As you've access to session, it's easy to send data with following methods of [MCSession class](https://developer.apple.com/library/ios/documentation/MultipeerConnectivity/Reference/MCSessionClassRef/Reference/Reference.html):
```objective-c
– sendData:toPeers:withMode:error:
– sendResourceAtURL:toPeer:withTimeout:completionHandler:
– startStreamWithName:toPeer:error:
```
