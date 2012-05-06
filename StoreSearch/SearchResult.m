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
        return NSLocalizedString(@"Album", @"Localized kind: Album");
    }else if ([self.kind isEqualToString:@"audiobook"]) {
        return NSLocalizedString(@"Audiobook", @"Localized kind: Audiobook");
    }else if ([self.kind isEqualToString:@"book"]) {
        return NSLocalizedString(@"Book", @"Localized kind: Book");
    }else if ([self.kind isEqualToString:@"ebook"]) {
        return NSLocalizedString(@"E-Book", @"Localized kind: E-Book");
    }else if ([self.kind isEqualToString:@"feature-movie"]) {
        return NSLocalizedString(@"Movie", @"Localized kind: Movie");
    }else if ([self.kind isEqualToString:@"music-video"]) {
        return NSLocalizedString(@"Music Video", @"Localized kind: Music Video");
    }else if ([self.kind isEqualToString:@"podcast"]) {
        return NSLocalizedString(@"Podcast", @"Localized kind: Podcast");
    }else if ([self.kind isEqualToString:@"software"]) {
        return NSLocalizedString(@"App", @"Localized kind: App");
    }else if ([self.kind isEqualToString:@"song"]) {
        return NSLocalizedString(@"Song", @"Localized kind: Song");
    }else if ([self.kind isEqualToString:@"tv-episode"]) {
        return NSLocalizedString(@"TV Episode", @"Localized kind: TV Episode");
    }else{
        return self.kind;
    }
}


@end
