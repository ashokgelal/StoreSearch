#import "Search.h"
#import "SearchResult.h"
#import "AFImageCache.h"
#import "AFJSONRequestOperation.h"

static NSOperationQueue *queue = nil;

@interface Search()
@property (nonatomic, readwrite, strong) NSMutableArray *searchResults;
@end

@implementation Search
@synthesize isLoading = _isLoading;
@synthesize searchResults = _searchResults;


-(void)dealloc{
    NSLog(@"dealloc %@", self);
}
+(void) initialize
{
    if(self == [Search class]){
        queue = [[NSOperationQueue alloc] init];
    }
}

-(void)performSearchForText:(NSString *)text category:(NSInteger)category completion:(SearchBlock)block{
    if([text length] > 0){
        [queue cancelAllOperations];
        [[AFImageCache sharedImageCache] removeAllObjects];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];

        self.isLoading  = YES;

        self.searchResults = [NSMutableArray arrayWithCapacity:100];

        NSURL *url = [self urlWithSearchText:text category:category];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];

        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
        {
            [self parseDictionary:JSON];
            [self.searchResults sortUsingSelector:@selector(compareName:)];

            self.isLoading = NO;
            block(YES);
        }

        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) 
        {
            self.isLoading = NO;
            block(NO);
        }];

        operation.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", nil];

        [queue addOperation:operation];
    }
}

-(void) parseDictionary:(NSDictionary *) dictionary
{
    NSArray *array = [dictionary objectForKey:@"results"];
    if(array == nil){
        NSLog(@"Expected 'results' array");
        return;
    }
    
    for (NSDictionary *resultDict in array) {
        SearchResult *searchResult;
        
        NSString *wrapperType = [resultDict objectForKey:@"wrapperType"];
        NSString *kind = [resultDict objectForKey:@"kind"];
        
        if([wrapperType isEqualToString:@"track"]){
            searchResult = [self parseTrack:resultDict];
        }else if ([wrapperType isEqualToString:@"audiobook"]) {
            searchResult = [self parseAudioBook:resultDict];
        }else if ([wrapperType isEqualToString:@"software"]) {
            searchResult = [self parseSoftware:resultDict];
        }else if ([kind isEqualToString:@"ebook"]) {
            searchResult = [self parseSoftware:resultDict];
        }
        
        if(searchResult != nil){
            [self.searchResults addObject:searchResult];
        }
    }
}

-(SearchResult *)parseTrack:(NSDictionary *)dictionary
{
    SearchResult *searchResult = [[SearchResult alloc] init];
    searchResult.name = [dictionary objectForKey:@"trackName"];
    searchResult.artistName= [dictionary objectForKey:@"artistName"];
    searchResult.artworkURL60= [dictionary objectForKey:@"artworkUrl60"];
    searchResult.artworkURL100= [dictionary objectForKey:@"artworkUrl100"];
    searchResult.storeURL= [dictionary objectForKey:@"trackViewUrl"];
    searchResult.kind= [dictionary objectForKey:@"kind"];
    searchResult.price= [dictionary objectForKey:@"trackPrice"];
    searchResult.currency= [dictionary objectForKey:@"currency"];
    searchResult.genre= [dictionary objectForKey:@"primaryGenreName"];
    
    return searchResult;
}
-(SearchResult *)parseAudioBook:(NSDictionary *)dictionary
{
    SearchResult *searchResult = [[SearchResult alloc] init];
    searchResult.name = [dictionary objectForKey:@"collectionName"];
    searchResult.artistName= [dictionary objectForKey:@"artistName"];
    searchResult.artworkURL60= [dictionary objectForKey:@"artworkUrl60"];
    searchResult.artworkURL100= [dictionary objectForKey:@"artworkUrl100"];
    searchResult.storeURL= [dictionary objectForKey:@"collectionViewURL"];
    searchResult.kind= @"audiobook";
    searchResult.price= [dictionary objectForKey:@"collectionPrice"];
    searchResult.currency= [dictionary objectForKey:@"currency"];
    searchResult.genre= [dictionary objectForKey:@"primaryGenreName"];
    
    return searchResult;
}
-(SearchResult *)parseSoftware:(NSDictionary *)dictionary
{
    SearchResult *searchResult = [[SearchResult alloc] init];
    searchResult.name = [dictionary objectForKey:@"trackName"];
    searchResult.artistName= [dictionary objectForKey:@"artistName"];
    searchResult.artworkURL60= [dictionary objectForKey:@"artworkUrl60"];
    searchResult.artworkURL100= [dictionary objectForKey:@"artworkUrl100"];
    searchResult.storeURL= [dictionary objectForKey:@"trackViewUrl"];
    searchResult.kind= [dictionary objectForKey:@"kind"];
    searchResult.price= [dictionary objectForKey:@"price"];
    searchResult.currency= [dictionary objectForKey:@"currency"];
    searchResult.genre= [dictionary objectForKey:@"primaryGenreName"];
    
    return searchResult;
}
-(SearchResult *)parseEBook:(NSDictionary *)dictionary
{
    SearchResult *searchResult = [[SearchResult alloc] init];
    searchResult.name = [dictionary objectForKey:@"trackName"];
    searchResult.artistName= [dictionary objectForKey:@"artistName"];
    searchResult.artworkURL60= [dictionary objectForKey:@"artworkUrl60"];
    searchResult.artworkURL100= [dictionary objectForKey:@"artworkUrl100"];
    searchResult.storeURL= [dictionary objectForKey:@"trackViewUrl"];
    searchResult.kind= [dictionary objectForKey:@"kind"];
    searchResult.price= [dictionary objectForKey:@"price"];
    searchResult.currency= [dictionary objectForKey:@"currency"];
    searchResult.genre= [(NSArray *)[dictionary objectForKey:@"genres"] componentsJoinedByString:@", "];
    
    return searchResult;
}

-(NSURL *)urlWithSearchText:(NSString *)searchText category:(NSInteger)category
{
    NSString *categoryName;
    switch (category) {
        case 0: categoryName = @""; break;
        case 1: categoryName = @"musicTrack"; break;             
        case 2: categoryName = @"software"; break;             
        case 3: categoryName = @"ebook"; break;             
    }
    
    NSString *escapedSearchText = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"http://itunes.apple.com/search?term=%@&limit=200&entity=%@", escapedSearchText, categoryName];
    
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

@end
