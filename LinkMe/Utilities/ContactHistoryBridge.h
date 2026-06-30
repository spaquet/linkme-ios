@import Contacts;

NS_ASSUME_NONNULL_BEGIN

/// Wraps the NS_SWIFT_UNAVAILABLE enumeratorForChangeHistoryFetchRequest:error: so Swift can call it.
@interface ContactHistoryResult : NSObject
@property (nonatomic, strong) NSEnumerator<CNChangeHistoryEvent *> *enumerator;
@property (nonatomic, copy) NSData *currentHistoryToken;
@end

@interface ContactHistoryBridge : NSObject
+ (nullable ContactHistoryResult *)fetchChangeHistoryWith:(CNChangeHistoryFetchRequest *)request
                                                fromStore:(CNContactStore *)store
                                                    error:(NSError **)error;
@end

NS_ASSUME_NONNULL_END
