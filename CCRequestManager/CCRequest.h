// this class represents a request made to the configured Kurogo server.

#import <Foundation/Foundation.h>

@class CCRequest;

// blocks to operate on objects created from JSON in the background
// e.g. create core data objects
typedef NSInteger (^JSONObjectHandler)(id);

@protocol CCRequestDelegate <NSObject>

/* notifies the receiver that this request is no longer self-retained.
 * because requests are self-retaining, delegates' dealloc methods must
 * ensure that all requests' delegates are set to nil, preferably
 * by calling -cancel to terminate the associated url connection.
 */
- (void)requestWillTerminate:(CCRequest *)request;

@optional

- (void)request:(CCRequest *)request didFailWithError:(NSError *)error;

// generally delegates implement exactly one of the following per request
- (void)request:(CCRequest *)request didHandleResult:(NSInteger)returnValue; // retValue could be number of records updated
- (void)request:(CCRequest *)request didReceiveResult:(id)result; // no need to check result type since this is checked via expectedResponseType

// for showing determinate loading indicators. progress is between 0 and 1
- (void)request:(CCRequest *)request didMakeProgress:(CGFloat)progress;
- (void)requestDidReceiveResponse:(CCRequest *)request;

- (void)requestResponseUnchanged:(CCRequest *)request;

@end


extern NSString * const CCRequestErrorDomain;
// wrapper for most common kCFURLError constants, plus custom states
// TODO: coordinate with server-side error messages and 
// HTTP status codes
typedef enum {
	CCRequestErrorBadRequest,
	CCRequestErrorForbidden,
	CCRequestErrorUnreachable,
	CCRequestErrorDeviceOffline,
	CCRequestErrorTimeout,
	CCRequestErrorBadResponse,
	CCRequestErrorVersionMismatch,
	CCRequestErrorInterrupted,
	CCRequestErrorServerMessage,
	CCRequestErrorOther
} CCRequestErrorCode;

@interface CCRequest : NSObject {
	
	NSMutableData *_data;
	NSURLConnection *_connection;
    long long _contentLength;
    
	NSThread *_thread;
}

//@property(nonatomic, retain) NSString *module;
@property(nonatomic, retain) NSString *resourcePath;
@property(nonatomic, retain) NSDictionary *getParams;
@property(nonatomic, retain) NSDictionary *postParams;
@property(nonatomic, retain) NSDate *ifModifiedSince; // If-Modified-Since header

// maximum and minimum supported API versions. if either of them is
// different from the preferred version, set them manually after
// the request object is created.
//@property(nonatomic) NSInteger apiMaxVersion;
//@property(nonatomic) NSInteger apiMinVersion;

@property(nonatomic) NSTimeInterval minimumDuration;

@property(nonatomic, retain) NSString *format; // default is json
@property(nonatomic) NSURLRequestCachePolicy cachePolicy; // default is NSURLRequestReloadIgnoringLocalAndRemoteCacheData
@property(nonatomic) NSTimeInterval timeout; // default is 30 seconds

@property(nonatomic, assign) Class expectedResponseType; // default is NSDictionary
@property(nonatomic, copy) JSONObjectHandler handler;

@property(nonatomic, retain) id result;

// urls are of the form
// http://<server>/<basePath>/<resourcePath>?<key>=<value>
@property(nonatomic, retain) NSURL *url;
@property(nonatomic, assign) id<CCRequestDelegate> delegate;

- (BOOL)connect;
- (BOOL)connectWithResponseType:(Class)responseType callback:(JSONObjectHandler)callback;
- (BOOL)connectWithCallback:(JSONObjectHandler)callback;
- (void)cancel;  // call to stop receiving messages

+ (CCRequestErrorCode)internalCodeForNSError:(NSError *)error;

@end
