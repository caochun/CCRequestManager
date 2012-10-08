// Convenience wrapper for NSURLConnection's most common use case, asynchronous
// plain HTTP GET request of a URL string.
// 
// See Emergency Module for example usage.

#import <Foundation/Foundation.h>

@class CCConnectionWrapper;

@protocol CCConnectionWrapperDelegate <NSObject>

- (void)connection:(CCConnectionWrapper *)wrapper handleData:(NSData *)data;

@optional

- (void)connectionDidReceiveResponse:(CCConnectionWrapper *)wrapper; // an opportunity to turn on the spinny, i.e. [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
- (void)connection:(CCConnectionWrapper *)wrapper handleConnectionFailureWithError:(NSError *)error;
- (void)connection:(CCConnectionWrapper *)wrapper madeProgress:(CGFloat)progress;

@end


@interface CCConnectionWrapper : NSObject {
	NSMutableData *tempData;

    NSURL *theURL;
    NSURLConnection *urlConnection;
	BOOL isConnected;
    long long contentLength;
	
	id<CCConnectionWrapperDelegate> delegate;
}

@property (nonatomic, retain) NSURL *theURL;
@property (nonatomic, retain) NSURLConnection *urlConnection;
@property (nonatomic, assign, readonly) BOOL isConnected;
@property (nonatomic, retain) id<CCConnectionWrapperDelegate> delegate;

- (id)initWithDelegate:(id<CCConnectionWrapperDelegate>)theDelegate;
- (void)cancel;

- (void)resetObjects;

-(BOOL)requestDataFromURL:(NSURL *)url;
-(BOOL)requestDataFromURL:(NSURL *)url allowCachedResponse:(BOOL)shouldCache;

@end
