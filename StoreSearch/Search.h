#import <Foundation/Foundation.h>
typedef void (^SearchBlock)(BOOL success);

@interface Search : NSObject
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, readonly, strong) NSMutableArray *searchResults;

-(void)performSearchForText:(NSString *)text category:(NSInteger)category completion:(SearchBlock)block;

@end
