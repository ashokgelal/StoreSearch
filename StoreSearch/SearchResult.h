#import <Foundation/Foundation.h>

@interface SearchResult : NSObject

@property (nonatomic, copy) NSString *artworkURL60;
@property (nonatomic, copy) NSString *artworkURL100;
@property (nonatomic, copy) NSString *storeURL;
@property (nonatomic, copy) NSString *kind;
@property (nonatomic, copy) NSString *currency;
@property (nonatomic, copy) NSDecimalNumber *price;
@property (nonatomic, copy) NSString *genre;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *artistName;

-(NSComparisonResult)compareName:(SearchResult *)other;

@end
