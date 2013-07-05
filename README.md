### Introduction to jsonlite

* [What is jsonlite and JsonLite ObjC?](#what-is-jsonlite-and-jsonlite-objc)
* [Principles](#principles)
* [Getting Started with jsonlite](#getting-started-with-jsonlite)
  * [Validator](#validator)
  * [Summer](#summer)
  * [Beautifier](#beautifier)
* [Getting Started with JsonLite ObjC](#getting-started-with-jsonlite-objc)
  * [Parse to Cocoa Collection(s)](#parse-to-cocoa-collections)
  * [Chunks](#chunks)
  * [Model to JSON](#model-to-json)
  * [JSON to Model](#json-to-model)
  * [Decimal Number](#decimal-number)
* [Roadmap](#roadmap)
* [Code Coverage](#code-caverage)
* [Licence](#licence)

#### What is jsonlite and JsonLite ObjC

jsonlite is JSON [tokenizer](http://en.wikipedia.org/wiki/Tokenization). It's lightweight C libary that can be used for low-level JSON processing or parser development.

JsonLite ObjC is JSON parser base on jsonlite. It's the fastest and flexible JSON parser for Objective-C.

#### Principles
* **Lightweight is more important than syntax sugar** 
* **Reliability & quality is most important than everything else**
* **Do that which is necessary**
* **Divide and Rule**

#### Getting Started with jsonlite
###### Validator
Current example shows how quick, easy and using **232 bytes** (64 bit arch) or **116 bytes** (32 bit arch) validate JSON.

``` c
#include <assert.h>
#include "jsonlite.h"

int main(int argc, const char * argv[]) {
    const int JSON_DEPTH = 4;                                                   // Limitation of JSON depth
    char json[] = "[-1, 0, 1, true, false, null]";                              // JSON to validate
    size_t mem_used = jsonlite_parser_estimate_size(JSON_DEPTH);                // Estimate memory usage
    printf("jsonlite will use %zd bytes of RAM for JSON validation", mem_used);
    jsonlite_parser p = jsonlite_parser_init(JSON_DEPTH);                       // Init parser with specified depth
    jsonlite_result result = jsonlite_parser_tokenize(p, json, sizeof(json));   // Check JSON
    assert(result == jsonlite_result_ok);                                       // Check result
    jsonlite_parser_release(p);                                                 // Free resources
    return 0;
}
``` 

###### Summer
Next example shows how to work with number tokens. jsonlite does not convert any number by itself. That's why you may use [strtol](http://www.cplusplus.com/reference/cstdlib/strtol/) or even [arbitrary-precision arithmetic](http://en.wikipedia.org/wiki/Arbitrary-precision_arithmetic).

``` c
#include <stdlib.h>
#include <assert.h>
#include "jsonlite.h"
#include "jsonlite_token.h"

long long sum = 0;

static void number_callback(jsonlite_callback_context *ctx, jsonlite_token *token) {
    char *end = NULL;
    sum += strtoll((const char *)token->start, &end, 10);
    assert(end == (char *)token->end);
}

int main(int argc, const char * argv[]) {
    const int JSON_DEPTH = 4;                                   // Limitation of JSON depth
    char json[] = "[-13453453, 0, 1, 123, 45345, -94534555]";   // Numbers to sum
    jsonlite_parser_callbacks cbs = jsonlite_default_callbacks; // Init callbacks with default values
    cbs.number_found = &number_callback;                        // Assign new callback function
    jsonlite_parser p = jsonlite_parser_init(JSON_DEPTH);       // Init parser with specified depth
    jsonlite_parser_set_callback(p, &cbs);                      // Set callback function(s)
    jsonlite_parser_tokenize(p, json, sizeof(json));            // Tokenize/find numbers
    jsonlite_parser_release(p);                                 // Free resources
    printf("Total sum: %lld", sum);
    return 0;
}
```
###### Beautifier

The example shows how to quick make JSON pretty. The example is bigger than previous, please, see it [here](../master/Examples/Beautifier/Beautifier/main.c).

#### Getting Started with JsonLite ObjC

###### Parse to Cocoa Collection(s)
Current example shows how to quick tokenize and accumulate results to Cocoa collection.

``` objc
#import "JsonLiteAccumulator.h"

// ...

- (void)parse {
    NSString *json = @"[\"hello\", null, 1234567890]";
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    id result = [JsonLiteAccumulator objectFromData:data withMaxDepth:8];
    NSLog(@"%@", result);
}

// ...
```
###### Chunks

A [chunk](http://en.wikipedia.org/wiki/Chunk_(information) is a fragment of JSON. JsonLite ObjC allows you to process a chunk while other parts of JSON are delivering by network. 'Chunk Oriented' processing style allow developer to improve memory usage and increase program performance, also its' provide ability to work with huge JSON data.
``` objc
#import "JsonLiteParser.h"
#import "JsonLiteAccumulator.h"

// ...

- (void)parseChunks {
    NSString *json_part1 = @"[\"hello\", nu";
    NSString *json_part2 = @"ll, 1234567890]";
    NSData *data1 = [json_part1 dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data2 = [json_part2 dataUsingEncoding:NSUTF8StringEncoding];
    JsonLiteParser *parser = [JsonLiteParser parserWithDepth:8];
    JsonLiteAccumulator *acc = [JsonLiteAccumulator accumulatorWithDepth:8];
    parser.delegate = acc;
    [parser parse:data1];
    [parser parse:data2];    
    NSLog(@"Full object - %@", [acc object]);
}

// ...
```
###### JSON to Model

It's really hard to deal with Cocoa collections. The best way is to bind JSON to some model.
``` objc
#import "JsonLiteParser.h"
#import "JsonLiteDeserializer.h"

@interface Model : NSObject

@property (nonatomic, copy) NSString *string;
@property (nonatomic, copy) NSNumber *number;
@property (nonatomic, copy) NSArray *array;

@end

@implementation Model

- (void)dealloc {
    self.string = nil;
    self.number = nil;
    self.array = nil;
    [super dealloc];
}

@end
// ...
- (void)parseToModel {
    NSString *json = @"{\"string\": \"hello\", \"number\" : 100, \"array\": [1, 2, 3]}";
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    JsonLiteParser *parser = [JsonLiteParser parserWithDepth:8];
    JsonLiteDeserializer *des = [JsonLiteDeserializer deserializerWithRootClass:[Model class]];
    parser.delegate = des;
    [parser parse:data];
    
    Model *model = [des object];
    NSLog(@"String - %@", model.string);
    NSLog(@"Number - %@", model.number);
    NSLog(@"Array - %@", model.array);
}
// ...
```

###### Model to JSON

``` objc

#import "JsonLiteSerializer.h"

- (void)buildFromModel {
    Model *model = [[[Model alloc] init] autorelease];
    model.string = @"Hello World";
    model.number = [NSNumber numberWithInt:256];
    model.array = [NSArray arrayWithObjects:@"Test", [NSNull null], nil];
    JsonLiteSerializer *serializer = [JsonLiteSerializer serializer];
    NSData *data = [serializer serializeObject:model];
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", json);
    [json release];
}
```
###### Decimal Number

Only JsonLite ObjC can work with NSDecimalNumber object and you can forgot about workaround with strings. It's very important feature for finance project. 

``` objc
@interface Model : NSObject

@property (nonatomic, copy) NSString *string;
@property (nonatomic, copy) NSDecimalNumber *number;

@end

@implementation Model

- (void)dealloc {
    self.string = nil;
    self.number = nil;
    [super dealloc];
}

@end

- (void)parseDecimalToModel {
    NSString *json = @"{\"string\": \"This is Decimal!\", \"number\" : 95673465936453649563978.99 }";
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    JsonLiteParser *parser = [JsonLiteParser parserWithDepth:8];
    JsonLiteDeserializer *des = [JsonLiteDeserializer deserializerWithRootClass:[Model class]];
    des.converter = [[[JsonLiteDecimal alloc] init] autorelease]; // Look here
    parser.delegate = des;
    [parser parse:data];
    
    Model *model = [des object];
    NSLog(@"String - %@", model.string);
    NSLog(@"Number - %@", model.number);
}
```

#### Code Coverage

Full function, statement and branch coverage. 

![Image](../master/JsonLiteObjC/cov.png?raw=true)

#### Roadmap

* Create Doxygen documentation
* Create framework for Xcode projects
* Create extension for Python

#### Licence

jsonlite and JsonLite ObjC are licensed under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

Copyright 2012-2013, Andrii Mamchur
