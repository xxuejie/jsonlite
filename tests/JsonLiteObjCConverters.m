//
//  JsonLiteObjCConverters.m
//  JsonLiteObjC
//
//  Created by admin on 6/22/13.
//  Copyright (c) 2013 Andrii Mamchur. All rights reserved.
//

#import "JsonLiteObjCConverters.h"
#import "JsonLiteParser.h"
#import "JsonLiteSerializer.h"
#import "JsonLiteDeserializer.h"
#import "JsonLiteMetaData.h"
#import "JsonLiteConverters.h"

@interface DecimalHolder : NSObject

@property (nonatomic, retain) NSDecimalNumber *number;

@end

@implementation DecimalHolder

- (void)dealloc {
    self.number = nil;
    [super dealloc];
}

@end

@interface URLHolder : NSObject

@property (nonatomic, retain) NSURL *url;

@end

@implementation URLHolder

- (void)dealloc {
    self.url = nil;
    [super dealloc];
}

@end

@interface DateHolder : NSObject

@property (nonatomic, retain) NSDate *date;

@end

@implementation DateHolder

- (void)dealloc {
    self.date = nil;
    [super dealloc];
}

@end

@implementation JsonLiteObjCConverters

- (void)testIncorrectDecimal {
    NSString *json = @"{\"number\": \"incorrect value\"}";
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    JsonLiteParser *parser = [[JsonLiteParser alloc] init];
    JsonLiteDeserializer *deserializer = [[JsonLiteDeserializer alloc] initWithRootClass:[DecimalHolder class]];
    deserializer.converter = [[[JsonLiteDecimal alloc] init] autorelease];
    parser.delegate = deserializer;
    [parser parse:data];
    STAssertNil(parser.parseError, @"Parse error");
    
    DecimalHolder *holder = [deserializer object];
    STAssertNotNil(holder.number, @"number is not nil");
    STAssertTrue([holder.number isKindOfClass:[NSString class]], @"Must be string");
    [deserializer release];
    [parser release];
}

- (void)testIncorrectURL {
    NSString *json = @"{\"url\": 1234}";
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    JsonLiteParser *parser = [[JsonLiteParser alloc] init];
    JsonLiteDeserializer *deserializer = [[JsonLiteDeserializer alloc] initWithRootClass:[URLHolder class]];
    deserializer.converter = [[[JsonLiteURL alloc] init] autorelease];
    parser.delegate = deserializer;
    [parser parse:data];
    STAssertNil(parser.parseError, @"Parse error");
    
    URLHolder *holder = [deserializer object];
    STAssertNotNil(holder.url, @"url is not nil");
    STAssertTrue([holder.url isKindOfClass:[NSNumber class]], @"Must be number");
    [deserializer release];
    [parser release];
}

- (void)testIncorrectDate {
    NSString *json = @"{\"date\": 1234}";
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    JsonLiteParser *parser = [[JsonLiteParser alloc] init];
    JsonLiteDeserializer *deserializer = [[JsonLiteDeserializer alloc] initWithRootClass:[DateHolder class]];
    deserializer.converter = [[[JsonLiteTwitterDate alloc] init] autorelease];
    parser.delegate = deserializer;
    [parser parse:data];
    STAssertNil(parser.parseError, @"Parse error");
    
    DateHolder *holder = [deserializer object];
    STAssertNotNil(holder.date, @"date is not nil");
    STAssertTrue([holder.date isKindOfClass:[NSNumber class]], @"Must be number");
    [deserializer release];
    [parser release];
}

@end
