//
//  AFURLResponseSerializerWithData.m
//  Hubdin
//
//  Created by MAC237 on 5/13/14.
//  Copyright (c) 2014 MAC. All rights reserved.
//

#import "AFURLResponseSerializerWithData.h"

@implementation AFURLResponseSerializerWithData

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    id JSONObject = [super responseObjectForResponse:response data:data error:error];
    
    if (*error != nil) {
        NSMutableDictionary *userInfo = [(*error).userInfo mutableCopy];
        [userInfo setValue:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] forKey:JSONResponseSerializerWithDataKey];
        NSDictionary *jsonBody = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions
                              error:error];
        if (jsonBody != nil) {
            [userInfo setValue:jsonBody forKey:JSONResponseSerializerWithDataKey];
        }
        [userInfo setValue:[response valueForKey:JSONResponseSerializerWithBodyKey] forKey:JSONResponseSerializerWithBodyKey];
        NSError *newError = [NSError errorWithDomain:(*error).domain code:(*error).code userInfo:userInfo];
        (*error) = newError;
    }
    return JSONObject;
}
@end
