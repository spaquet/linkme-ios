#import "ContactHistoryBridge.h"

@implementation ContactHistoryResult
@end

@implementation ContactHistoryBridge

+ (nullable ContactHistoryResult *)fetchChangeHistoryWith:(CNChangeHistoryFetchRequest *)request
                                                fromStore:(CNContactStore *)store
                                                    error:(NSError **)error {
    CNFetchResult<NSEnumerator<CNChangeHistoryEvent *> *> *result =
        [store enumeratorForChangeHistoryFetchRequest:request error:error];
    if (!result) { return nil; }

    ContactHistoryResult *out = [[ContactHistoryResult alloc] init];
    out.enumerator = result.value;
    out.currentHistoryToken = result.currentHistoryToken;
    return out;
}

@end
