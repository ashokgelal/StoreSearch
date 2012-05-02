#import "SearchViewController.h"
#import "SearchResult.h"
#import "SearchResultCell.h"

static NSString *const SearchResultCellIdentifier = @"SearchResultCell";
static NSString *const NothingFoundCellIdentifier = @"NothingFoundCell";
static NSString *const LoadingCellIdentifier = @"LoadingCell";

@interface SearchViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SearchViewController{
    NSMutableArray *searchResults;
    BOOL isLoading;
}

@synthesize searchBar = _searchBar;
@synthesize tableView = _tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *cellNib = [UINib nibWithNibName:SearchResultCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:SearchResultCellIdentifier];
    
    cellNib = [UINib nibWithNibName:NothingFoundCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:NothingFoundCellIdentifier];
    
    cellNib = [UINib nibWithNibName:LoadingCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:LoadingCellIdentifier];
    
    self.tableView.rowHeight = 80;
    
    [self.searchBar becomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isLoading){
        return 1;
    } else if (searchResults == nil) {
        return 0;
    } 
    else if ([searchResults count] == 0) {
        return 1;
    }
    else {
        return [searchResults count];
    }
}

-(NSString *)kindForDisplay:(NSString *)kind
{
    if([kind isEqualToString:@"album"]){
        return @"Album";
    }else if ([kind isEqualToString:@"audiobook"]) {
        return @"Audiobook";
    }else if ([kind isEqualToString:@"book"]) {
        return @"Book";
    }else if ([kind isEqualToString:@"ebook"]) {
        return @"E-Book";
    }else if ([kind isEqualToString:@"feature-movie"]) {
        return @"Movie";
    }else if ([kind isEqualToString:@"music-video"]) {
        return @"Music Video";
    }else if ([kind isEqualToString:@"podcast"]) {
        return @"Podcast";
    }else if ([kind isEqualToString:@"software"]) {
        return @"App";
    }else if ([kind isEqualToString:@"song"]) {
        return @"Song";
    }else if ([kind isEqualToString:@"tv-episode"]) {
        return @"TV Episode";
    }else{
        return kind;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isLoading){
        return [tableView dequeueReusableCellWithIdentifier:LoadingCellIdentifier];
    } else if([searchResults count] == 0){
        return [tableView dequeueReusableCellWithIdentifier:NothingFoundCellIdentifier];
    }
    else{
        SearchResultCell *cell = (SearchResultCell *)[tableView dequeueReusableCellWithIdentifier:SearchResultCellIdentifier];
        
        SearchResult *searchResult = [searchResults objectAtIndex:indexPath.row];
        cell.nameLabel.text = searchResult.name;
        
        
        NSString *artistName = searchResult.artistName;
        if(artistName == nil){
            artistName = @"Unknown";
        }
        
        NSString *kind = [self kindForDisplay: searchResult.kind];
        cell.artistNameLabel.text = [NSString stringWithFormat:@"%@ (%@)", artistName, kind];
        return cell;
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if([searchBar.text length] > 0){
        [searchBar resignFirstResponder];
        isLoading  = YES;
        [self.tableView reloadData];
        searchResults = [NSMutableArray arrayWithCapacity:100];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_async(queue, ^{
            NSURL *url = [self urlWithSearchText:searchBar.text];
            NSString *jsonString = [self performStoreRequestWithURL:url];
            
            if(jsonString == nil){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showNetworkError];
                });
                return;
            }
            
            NSDictionary *dictionary = [self parseJSON:jsonString];
            if(dictionary == nil){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showNetworkError];
                });
                return;
            }
            [self parseDictionary:dictionary];
            [searchResults sortUsingSelector:@selector(compareName:)];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                isLoading = NO;
                [self.tableView reloadData];
            });
        });
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
            [searchResults addObject:searchResult];
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

-(NSString *)performStoreRequestWithURL:(NSURL *)url
{
    NSError *error;
    NSString *resultString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    
    if(resultString == nil){
        NSLog(@"Download error: %@", error);
        return nil;
    }
    return resultString;
}

-(NSURL *)urlWithSearchText:(NSString *)searchText
{
    NSString *escapedSearchText = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"http://itunes.apple.com/search?term=%@&limit=200", escapedSearchText];
    
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

-(void)showNetworkError
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoops.." message:@"There was an error reading from iTunes Store" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alertView show];
}

-(NSDictionary *)parseJSON:(NSString *)jsonString
{
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    id resultObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if(resultObject == nil){
        NSLog(@"JSON Error: %@", error);
        return nil;
    }
    
    if(![resultObject isKindOfClass:[NSDictionary class]]){
        NSLog(@"JSON Error: Expected dictionary");
        return nil;
    }
    
    return resultObject;
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([searchResults count] == 0 || isLoading){
        return nil;
    }else {
        return indexPath;
    }
}

@end
