

#import <Foundation/Foundation.h>

@interface DatabaseUtil : NSObject

+ (DatabaseUtil *)sharedDatabaseInstance;
- (NSString *)formateDictToValue:(NSMutableDictionary *)dictValue;
- (NSString *)formateDictForUpdate:(NSMutableDictionary *)dictValue;
- (NSMutableDictionary *)trimDataWithDict:(NSMutableDictionary *)dictData;
- (BOOL)executeUpdateQuery:(NSString *)query;
- (int)executeUpdateQueryfind:(NSString *)query;
- (int)insertDataWithDictionary:(NSMutableDictionary *)dictData tableName:(NSString *)tblName;
- (BOOL)insertDataWithDictionaryReturnBool:(NSMutableDictionary *)dictData tableName:(NSString *)tblName;
- (BOOL)updateQuery:(NSString *)strQuery;
- (BOOL)updateDataWithDictionary:(NSMutableDictionary *)dictData tableName:(NSString *)tblName andRefrenceId:(int)refrenceId andRefrenceKey:(NSString *)refrenceKey;
- (BOOL)searchDataFromTable:(NSString *)tblName searchtext:(NSString *)txtSearch searchKey:(NSString *)searchKey;
- (BOOL)searchDataFromTable:(NSString *)tblName where:(NSString *)txtWhere;
- (BOOL)deleteDataFromTable:(NSString *)tblName andRefrenceId:(int)refrenceId andRefrenceKey:(NSString *)refrenceKey;
- (BOOL)deleteDataFromTable:(NSString *)tblName;
- (BOOL)deleteDataFromTable:(NSString *)tblName AndQuery:(NSString *)strQuery;
- (NSMutableArray *)selectDataFromTable:(NSString *)tblName whereQuery:(NSString *)whereQuery;
- (NSMutableArray *)selectDatawhereQuery:(NSString *)whereQuery;


@end
