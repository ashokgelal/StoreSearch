#import "SearchResult.h"

@implementation SearchResult
@synthesize name = _name;
@synthesize artistName = _artistName;
@synthesize  artworkURL60 = _artworkURL60;
@synthesize artworkURL100 = _artworkURL100;
@synthesize storeURL = _storeURL;
@synthesize kind = _kind;
@synthesize currency = _currency;
@synthesize price = _price;
@synthesize genre = _genre;

-(NSComparisonResult)compareName:(SearchResult *)other
{
    return [self.name localizedCaseInsensitiveCompare:other.name];
}

@end
