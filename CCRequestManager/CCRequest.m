#import "CCRequest.h"
#import "JSONKit.h"
#import "CCRequestManager.h"
#import "CCAppDelegate+CCAdditions.h"
#import "EGOCache.h"
#import "XMLReader.h"

NSString * const CCRequestErrorDomain = @"info.nemoworks.CCRequest.ErrorDomain";

NSString * const CCRequestDurationPrefKey = @"CCRequestDuration";
NSString * const CCRequestLastRequestTime = @"never";
NSString * const CCRequestIsCachedData =@"isCachedData";

@interface CCRequest (Private)

- (void)terminateWithErrorCode:(CCRequestErrorCode)errCode userInfo:(NSDictionary *)userInfo;

- (void)runHandlerOnResult:(id)result;
- (BOOL)isUnderMinimumDuration;

@end


@implementation CCRequest

@synthesize url, resourcePath, getParams, postParams, cachePolicy, ifModifiedSince;
@synthesize format, delegate, timeout, minimumDuration;
@synthesize expectedResponseType, handler, result = _result;

+ (CCRequestErrorCode)internalCodeForNSError:(NSError *)error
{
	CCRequestErrorCode errCode;
	switch ([error code]) {
		case kCFURLErrorCannotConnectToHost: case kCFURLErrorCannotFindHost:
		case kCFURLErrorDNSLookupFailed: case kCFURLErrorResourceUnavailable:
			errCode = CCRequestErrorUnreachable;
			break;
		case kCFURLErrorNotConnectedToInternet: case kCFURLErrorInternationalRoamingOff: case kCFURLErrorNetworkConnectionLost:
			errCode = CCRequestErrorDeviceOffline;
			break;
		case kCFURLErrorTimedOut: case kCFURLErrorRequestBodyStreamExhausted: case kCFURLErrorDataLengthExceedsMaximum:
			errCode = CCRequestErrorTimeout;
			break;
		case kCFURLErrorBadServerResponse: case kCFURLErrorZeroByteResource: case kCFURLErrorCannotDecodeRawData:
		case kCFURLErrorCannotDecodeContentData: case kCFURLErrorCannotParseResponse: case kCFURLErrorRedirectToNonExistentLocation:
			errCode = CCRequestErrorBadResponse;
			break;
		case kCFURLErrorBadURL: case kCFURLErrorUnsupportedURL: case kCFURLErrorFileDoesNotExist: 
			errCode = CCRequestErrorBadRequest;
			break;
		case kCFURLErrorUserAuthenticationRequired:
			errCode = CCRequestErrorForbidden;
			break;
		case kCFURLErrorCancelled: case kCFURLErrorUserCancelledAuthentication: case kCFURLErrorCallIsActive:
			errCode = CCRequestErrorInterrupted;
			break;
		case kCFURLErrorDataNotAllowed: case kCFURLErrorUnknown: case kCFURLErrorHTTPTooManyRedirects:
		default:
			errCode = CCRequestErrorOther;
			break;
	}
    
    return errCode;
}

- (id)init {
    self = [super init];
    if (self) {
		self.cachePolicy = NSURLRequestUseProtocolCachePolicy;
		self.timeout = 30;
        self.minimumDuration=5;
		self.expectedResponseType = [NSObject class];
        self.format=CCResponseFormatJSON;
	}
	return self;
}

//- (BOOL)connectWithResponseType:(Class)responseType callback:(JSONObjectHandler)callback
//{
//    self.handler = [callback copy];
//    self.expectedResponseType = responseType;
//    return [self connect];
//}
//
//- (BOOL)connectWithCallback:(JSONObjectHandler)callback
//{
//    self.handler = [callback copy];
//    return [self connect];
//}

-(BOOL) connectWithCache:(BOOL)withCache{
    
    NSError *error = nil;
    NSDictionary *userInfo = nil;
    BOOL success = NO;
    
    NSString *urlAbsStr=[self.url absoluteString];
    
    if (self.minimumDuration && [self isUnderMinimumDuration]) {
        // don't want to show an error just because the data is fresh
		[self.delegate requestWillTerminate:self];
        [self cancel];
        return NO;
        
    }
    
    if (_connection) {
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"could not connect because the connection is already in use", @"message", nil];
        error = [NSError errorWithDomain:CCRequestErrorDomain code:CCRequestErrorBadRequest userInfo:userInfo];        
	}else{
        EGOCache *localCache = [EGOCache currentCache];
        if (withCache && [localCache hasCacheForKey:urlAbsStr]){
            DLog(@"Returning local cache of %@", [self.url absoluteString]);
            self.result=[[EGOCache currentCache] objectForKey:urlAbsStr];
            [self.delegate request:self didReceiveResult:self.result];
            return YES;
        }else {
            DLog(@"requesting %@", [self.url absoluteString]);
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url cachePolicy:self.cachePolicy timeoutInterval:self.timeout];
                    
            if (self.ifModifiedSince) {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
                [formatter setDateFormat:@"EEE', 'dd' 'MM' 'yyyy' 'HH':'mm':'ss' GMT'"];
                NSString *dateString = [formatter stringFromDate:self.ifModifiedSince];
                [request setValue:dateString forHTTPHeaderField:@"If-Modified-Since"];
            }
        
            if (![NSURLConnection canHandleRequest:request]) {
                userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"cannot handle request: %@", urlAbsStr], @"message", nil];
                error = [NSError errorWithDomain:CCRequestErrorDomain code:CCRequestErrorBadRequest userInfo:userInfo];
            } else {
                _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
                if (_connection) {
                    _data = [[NSMutableData alloc] init];
                    success = YES;
                }
            }
        }
    }
    
    if (!success) {
        if (!error) {
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"could not connect to url: %@", urlAbsStr], @"message", nil];
            error = [NSError errorWithDomain:CCRequestErrorDomain code:CCRequestErrorBadRequest userInfo:userInfo];
        }
        [[CCRequestManager sharedManager] showAlertForError:error request:self];
    }
    
    if (success) {
        [(CC_SHARED_APP_DELEGATE()) showNetworkActivityIndicator];
    }
    
	return success;

}
- (BOOL)connect {
    return [self connectWithCache:YES];

}
    

- (BOOL)isUnderMinimumDuration
{
    NSDictionary *preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:CCRequestDurationPrefKey];
    if (preferences) {    
        NSString *requestID = [self.url absoluteString];
        NSDate *lastRequestTime = (NSDate *)[preferences objectForKey:requestID];
        DLog(@"the request for %@ was last requested %@", self.url, lastRequestTime);
        if (lastRequestTime && [lastRequestTime timeIntervalSinceNow] + self.minimumDuration >= 0) {
            // lastRequestTime is more recent than (now - duration)
            DLog(@"aborting because the request was made within the specified time");
            return YES;
        }
    }

    return NO;
}

- (void)cancel {
	// we still may be retained by other objects
	self.delegate = nil;
    self.result = nil;
	
	_data = nil;
    
    if (_connection) {
        [_connection cancel];
        _connection = nil;
        [CC_SHARED_APP_DELEGATE() hideNetworkActivityIndicator];
    }
}


#pragma mark NSURLConnection

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _contentLength = [response expectedContentLength];
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        // TODO: decide how we want to handle this more generically
        // currently anyone who doesn't implement the callback will show the user a needless error
        if (statusCode == 304 && [self.delegate respondsToSelector:@selector(requestResponseUnchanged:)]) {
            [self.delegate requestResponseUnchanged:self];
        }
    }
    
	// could receive multiple responses (e.g. from redirect), so reset tempData with every request 
    // (last request received will deliver payload)
	// TODO: we may want to do something about redirects
	[_data setLength:0];
    if ([self.delegate respondsToSelector:@selector(requestDidReceiveResponse:)]) {
        [self.delegate requestDidReceiveResponse:self];
    }
}

// called repeatedly until connection is finished
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[_data appendData:data];
    if (_contentLength != NSURLResponseUnknownLength && [delegate respondsToSelector:@selector(request:didMakeProgress:)]) {
        NSUInteger lengthComplete = [_data length];
        CGFloat progress = (CGFloat)lengthComplete / (CGFloat)_contentLength;
        [delegate request:self didMakeProgress:progress];
    }
}

// no further messages will be received after this
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
    _connection = nil;

    [CC_SHARED_APP_DELEGATE() hideNetworkActivityIndicator];
	
    NSString *resultString =[[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];;
    _data = nil;
    
    if (!resultString) {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"empty response", @"message", nil];
        [self terminateWithErrorCode:CCRequestErrorBadResponse userInfo:params];
        return;
    }
    
    NSObject *resultObj = nil;
    
    NSError *error = nil;
    
    switch (self.format) {
            
        case CCResponseFormatXML:
            resultObj=[XMLReader dictionaryForXMLString:resultString error:&error];
            break;
        default: case CCResponseFormatJSON:
            resultObj = [resultString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode error:&error];
            break;
    }
    if (error){
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"malformed response", @"message", [error userInfo], @"error",nil];
        [self terminateWithErrorCode:CCRequestErrorBadResponse userInfo:params];
        return;
    }

    self.result=[resultObj copy];
    


	BOOL canProceed = [self.result isKindOfClass:self.expectedResponseType];
	if (!canProceed) { 
		NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"result type does not match expected response type", @"message", nil];
		[self terminateWithErrorCode:CCRequestErrorBadResponse userInfo:errorInfo];
		return;
	}
    
    // at this point we consider the request successful
    if (self.minimumDuration) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *preferences = [userDefaults dictionaryForKey:CCRequestDurationPrefKey];
        if (!preferences) {
            preferences = [NSDictionary dictionary];
        }
        NSMutableDictionary *mutablePrefs = [preferences mutableCopy];

        NSString *requestID = [self.url absoluteString];
        [mutablePrefs setObject:[NSDate date] forKey:requestID];
        
        [userDefaults setObject:mutablePrefs forKey:CCRequestDurationPrefKey];
        [userDefaults synchronize];
        
        EGOCache *localCache = [EGOCache currentCache];
        //caching the original resulted string
        [localCache setObject:resultString forKey:[self.url absoluteString]];
        [NSThread sleepForTimeInterval:2];
        NSLog(@"%@ cached %@", [self.url absoluteString], [localCache hasCacheForKey:[self.url absoluteString]]?@"successfully":@"unsuccessfully");
        NSLog(@"what's cached %@ ",  [localCache objectForKey:[self.url absoluteString]]);
        
    }
    
	if (self.handler != nil) {
        _thread = [[NSThread alloc] initWithTarget:self selector:@selector(runHandlerOnResult:) object:self.result];
		[self performSelector:@selector(setHandler:) onThread:_thread withObject:self.handler waitUntilDone:NO];
		[_thread start];
	} else {
		if ([self.delegate respondsToSelector:@selector(request:didReceiveResult:)]) {
			[self.delegate request:self didReceiveResult:self.result];
		}
		
		[self.delegate requestWillTerminate:self];
	}
}

// no further messages will be received after this
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	_connection = nil;
	_data = nil;

    DLog(@"connection failed with error %d: %@", [error code], [error description]);
    
    [CC_SHARED_APP_DELEGATE() hideNetworkActivityIndicator];
    CCRequestErrorCode errCode = [CCRequest internalCodeForNSError:error];
	
	[self terminateWithErrorCode:errCode userInfo:[error userInfo]];
}

//#ifdef ALLOW_SELF_SIGNED_CERTIFICATE
//
//// the implementations of the following two delegate methods allow NSURLConnection to proceed with self-signed certs
////http://stackoverflow.com/questions/933331/how-to-use-nsurlconnection-to-connect-with-ssl-for-an-untrusted-cert
//- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
//    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
//    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
//        if ([[[KGORequestManager sharedManager] host] isEqualToString:challenge.protectionSpace.host]) {
//            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]
//                 forAuthenticationChallenge:challenge];
//        }
//    }
//    
//    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
//}
//
//#endif

#pragma mark -

- (void)runHandlerOnResult:(id)result {
	NSInteger num = self.handler(result);
	[self performSelectorOnMainThread:@selector(handlerDidFinish:) withObject:[NSNumber numberWithInt:num] waitUntilDone:YES];
}

- (void)handlerDidFinish:(NSNumber *)result {
	if ([self.delegate respondsToSelector:@selector(request:didHandleResult:)]) {
		[self.delegate request:self didHandleResult:[result integerValue]];
	}
	[self.delegate requestWillTerminate:self];
}

- (void)terminateWithErrorCode:(CCRequestErrorCode)errCode userInfo:(NSDictionary *)userInfo {
    if (self.url) {
        NSMutableDictionary *mutableUserInfo = [userInfo mutableCopy];
        [mutableUserInfo setObject:[self.url absoluteString] forKey:@"url"];
        userInfo = [NSDictionary dictionaryWithDictionary:mutableUserInfo];
    }
    
	NSError *ccError = [NSError errorWithDomain:CCRequestErrorDomain code:errCode userInfo:userInfo];
	if ([self.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
		[self.delegate request:self didFailWithError:ccError];
	} else {
		[[CCRequestManager sharedManager] showAlertForError:ccError request:self];
	}
	
	[self.delegate requestWillTerminate:self];
}

@end
