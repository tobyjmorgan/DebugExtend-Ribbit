#import <Foundation/Foundation.h>

@interface TJMFileToDelete : NSObject
@property (nonatomic, strong) NSString *file;
@property (nonatomic, strong) NSString *ownerId;
@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSDate *updated;
@property (nonatomic, strong) NSDate *created;
@end
