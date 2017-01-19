#import <Foundation/Foundation.h>

@class BackendlessUser;

@interface TJMMessage : NSObject
@property (nonatomic, strong) NSString *file;
@property (nonatomic, strong) NSString *fileType;
@property (nonatomic, strong) NSString *ownerId;
@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSDate *updated;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) BackendlessUser *sender;
@property (nonatomic, strong) BackendlessUser *recipient;
@end