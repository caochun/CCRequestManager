#import <Foundation/Foundation.h>
#import "CCRequest.h"

@class Reachability;

@protocol CCRequestDelegate;

// use this class to create requests server.
@interface CCRequestManager : NSObject <CCRequestDelegate, UIAlertViewDelegate> {
    
    Reachability *_reachability;

    // the name of the server.
//	NSString *_server;
    
    // the base URL of Kurogo. generally the same as _host, but if the entire
    // website is run out of a subdirectory, e.g. www.example.com/department,
    // in this case _host is www.example.com and _extendedHost is
    // www.example.com/department
    NSString *_host;
    NSString *_extendedHost;
	NSString *_uriScheme; // http or https
	NSString *_accessToken;
	NSURL *_baseURL;

//    CCRequest *_helloRequest;
//    CCRequest *_retryRequest;
//    
//    // login info
//    CCRequest *_sessionRequest;
//    CCRequest *_logoutRequest;
//    NSDictionary *_sessionInfo;

//    // push notification info
//    CCRequest *_deviceRegistrationRequest;
//    NSString *_devicePushID;
//    NSString *_devicePushPassKey;
}

@property (nonatomic, retain) NSString *host;
//@property (nonatomic, readonly) NSURL *hostURL;   // without path extension
//@property (nonatomic, readonly) NSURL *serverURL; // with path extension

+ (CCRequestManager *)sharedManager;
- (BOOL)isReachable;

//- (BOOL)isModuleAvailable:(ModuleTag *)moduleTag;
//- (BOOL)isModuleAuthorized:(ModuleTag *)moduleTag;

- (CCRequest *)requestResourceWithDelegate:(id<CCRequestDelegate>)delegate
                                resourcePath:(NSString *)resourcePath
                            params:(NSDictionary *)params;

- (CCRequest *)requestURLWithDelegate:(id<CCRequestDelegate>)delegate
                      rawUrl:(NSString *)rawUrl
                            params:(NSDictionary *)params;

- (void)showAlertForError:(NSError *)error request:(CCRequest *)request;
- (void)showAlertForError:(NSError *)error request:(CCRequest *)request delegate:(id<UIAlertViewDelegate>)delegate;

- (void)selectServerConfig:(NSString *)config;

//#pragma mark -
//
//- (void)requestServerHello;

//#pragma mark Kurogo server login
//
//- (BOOL)isUserLoggedIn;
//- (void)requestSessionInfo;
//- (void)loginKurogoServer;
//- (void)logoutKurogoServer;
//- (BOOL)requestingSessionInfo;

//- (NSDictionary *)sessionInfo;

//@property (nonatomic, retain) NSString *loginPath;

//#pragma mark Push notification registration
//
//- (void)registerNewDeviceToken;
//
//// returned by Apple's push servers when we register.  nil if not available.
//@property (nonatomic, retain) NSData *devicePushToken;
//// device ID assigned by Kurogo server
//@property (nonatomic, readonly) NSString *devicePushID;
//// device pass key assigned by Kurogo server
//@property (nonatomic, readonly) NSString *devicePushPassKey;

@end
