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
        artistName = NSLocalizedString(@"Unknown", @"Unknown");
    }
    
    NSString *kind = [searchResult kindForDisplay];
    
    self.artistNameLabel.text = [NSString stringWithFormat:@"%@ (%@)", artistName, kind];
    [self.artworkImageView setImageWithURL:[NSURL URLWithString:searchResult.artworkURL60] placeholderImage:[UIImage imageNamed:@"Placeholder"]];
}


-(void)prepareForReuse
{
    [super prepareForReuse];
    [self.artworkImageView cancelImageRequestOperation];
    self.nameLabel.text = nil;
    self.artistNameLabel.text = nil;
}


@end
