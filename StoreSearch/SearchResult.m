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

-(NSString *)kindForDisplay
{
    if([self.kind isEqualToString:@"album"]){
        return @"Album";
    }else if ([self.kind isEqualToString:@"audiobook"]) {
        return @"Audiobook";
    }else if ([self.kind isEqualToString:@"book"]) {
        return @"Book";
    }else if ([self.kind isEqualToString:@"ebook"]) {
        return @"E-Book";
    }else if ([self.kind isEqualToString:@"feature-movie"]) {
        return @"Movie";
    }else if ([self.kind isEqualToString:@"music-video"]) {
        return @"Music Video";
    }else if ([self.kind isEqualToString:@"podcast"]) {
        return @"Podcast";
    }else if ([self.kind isEqualToString:@"software"]) {
        return @"App";
    }else if ([self.kind isEqualToString:@"song"]) {
        return @"Song";
    }else if ([self.kind isEqualToString:@"tv-episode"]) {
        return @"TV Episode";
    }else{
        return self.kind;
    }
}


@end
