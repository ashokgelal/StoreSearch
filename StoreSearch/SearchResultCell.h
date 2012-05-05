#import <UIKit/UIKit.h>
@class SearchResult;

@interface SearchResultCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *artworkImageView;

-(void)configureForSearchResult:(SearchResult *)searchResult;

@end
