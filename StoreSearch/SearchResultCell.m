#import "SearchResultCell.h"
#import "SearchResult.h"
#import "UIImageView+AFNetworking.h"

@implementation SearchResultCell
@synthesize nameLabel = _nameLabel;
@synthesize artistNameLabel = _artistNameLabel;
@synthesize artworkImageView = _artworkImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    UIImage *image = [UIImage imageNamed:@"TableCellGradient"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:image];
    self.backgroundView = backgroundImageView;
    
    UIImage *selectedImage = [UIImage imageNamed:@"SelectedTableCellGradient"];
    UIImageView *selectedBackgroundImageView= [[UIImageView alloc] initWithImage:selectedImage];
    self.selectedBackgroundView = selectedBackgroundImageView;
}

-(void)configureForSearchResult:(SearchResult *)searchResult
{
    self.nameLabel.text = searchResult.name;
    
    NSString *artistName = searchResult.artistName;
    
    if (artistName == nil) {
        artistName = @"Unknown";
    }
    
    NSString *kind = [self kindForDisplay:searchResult.kind];
    
    self.artistNameLabel.text = [NSString stringWithFormat:@"%@ (%@)", artistName, kind];
    [self.artworkImageView setImageWithURL:[NSURL URLWithString:searchResult.artworkURL60] placeholderImage:[UIImage imageNamed:@"Placeholder"]];
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

-(void)prepareForReuse
{
    [super prepareForReuse];
    [self.artworkImageView cancelImageRequestOperation];
    self.nameLabel.text = nil;
    self.artistNameLabel.text = nil;
}


@end
