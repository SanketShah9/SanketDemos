//
//  DB_DEMO
//  https://github.com/ccgus/fmdb
//  Created by Sanket Shah on 13/09/15.
//  Copyright (c) 2015 Sanket Shah. All rights reserved.
//

#import "DatabaseUtil.h"
#import "AppConstant.h"
static DatabaseUtil *databaseUtil = nil;

@implementation DatabaseUtil

+ (DatabaseUtil *)sharedDatabaseInstance {
    if (databaseUtil == nil) {
        databaseUtil = [[DatabaseUtil alloc]init];
    }
    return databaseUtil;
}

- (NSMutableArray *)executeSelectQuery:(NSString *)query
{
    NSMutableArray *arrResultDict = [[NSMutableArray alloc] init];
    
    @try {
        [APPDELEGATE openDb];
        
        FMResultSet *rs = [APPDELEGATE.db executeQuery:query];
        
        while ([rs next]) {
            [arrResultDict addObject:[[NSMutableDictionary alloc] initWithDictionary:[rs resultDictionary]]];
        }
    }
    @catch (NSException *exception) {
        ZDebug(@"executeSelectQuery=exception==%@",exception );
    }
    @finally {
        [APPDELEGATE closeDb];
    }
    return arrResultDict;
}



- (NSString *)formateDictToValue:(NSMutableDictionary *)dictValue
{
    dictValue = [self trimDataWithDict:dictValue];
    
    NSString *strValues = @"";
    NSArray *arrKeys = [dictValue allKeys];
    NSString *strKeys = @"(";
    NSString *strData = @"(";
    
    for (int i = 0; i < [arrKeys count]; i++) {
        
        if([[dictValue valueForKey:[arrKeys objectAtIndex:i]] isKindOfClass:[NSString class]]){
            strKeys = [strKeys stringByAppendingFormat:@"'%@',", [arrKeys objectAtIndex:i]];
            strData = [strData stringByAppendingFormat:@"'%@',", [dictValue valueForKey:[arrKeys objectAtIndex:i]]];
            
        }else if([[dictValue valueForKey:[arrKeys objectAtIndex:i]] isKindOfClass:[NSNull class]]){
            
        }else{
            strKeys = [strKeys stringByAppendingFormat:@"'%@',", [arrKeys objectAtIndex:i]];
            strData = [strData stringByAppendingFormat:@"%@,", [dictValue valueForKey:[arrKeys objectAtIndex:i]]];
        }
    }
    
    strKeys = [strKeys substringToIndex:[strKeys length] - 1];
    strData = [strData substringToIndex:[strData length] - 1];
    
    strValues = [NSString stringWithFormat:@"%@) VALUES %@)", strKeys, strData];
    
    return strValues;
}

- (NSString *)formateDictForUpdate:(NSMutableDictionary *)dictValue
{
    dictValue = [self trimDataWithDict:dictValue];
    NSString *strValues = @"";
    NSArray *arrKeys = [dictValue allKeys];
    
    for (int i = 0; i < [arrKeys count]; i++) {
        
        if([[dictValue valueForKey:[arrKeys objectAtIndex:i]] isKindOfClass:[NSString class]] && [[dictValue valueForKey:[arrKeys objectAtIndex:i]] isEqualToString:@""]){
            strValues = [strValues stringByAppendingFormat:@"'%@' = '%@',", [arrKeys objectAtIndex:i], [dictValue valueForKey:[arrKeys objectAtIndex:i]]];
            
        }else if([[dictValue valueForKey:[arrKeys objectAtIndex:i]] isKindOfClass:[NSString class]]){
            strValues = [strValues stringByAppendingFormat:@"'%@' = '%@',", [arrKeys objectAtIndex:i], [dictValue valueForKey:[arrKeys objectAtIndex:i]]];
            
        }else if([[dictValue valueForKey:[arrKeys objectAtIndex:i]] isKindOfClass:[NSNull class]]){
            
        }else{
            strValues = [strValues stringByAppendingFormat:@"'%@' = '%@',", [arrKeys objectAtIndex:i], [dictValue valueForKey:[arrKeys objectAtIndex:i]]];
        }
    }
    
    strValues = [strValues substringToIndex:[strValues length] - 1];
    
    return strValues;
}
- (NSMutableDictionary *)trimDataWithDict:(NSMutableDictionary *)dictData{
    
    [dictData enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
        
        if ([value isKindOfClass:[NSNull class]]) {
            //            [dictData setObject:@"" forKey:key];
        }else{
            NSString *strNew = [[NSString stringWithFormat:@"%@",value] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            [dictData setObject:strNew forKey:key];
        }
    }];
    return dictData;
}

- (BOOL)executeUpdateQuery:(NSString *)query
{
    BOOL queryStatus = FALSE;
    
    @try {
        [APPDELEGATE openDb];
        
        // ZDebug(@"executeUpdateQuery > query: %@",query);
        
        queryStatus = [APPDELEGATE.db executeUpdate:query];
        
        if(!queryStatus) {
            ZDebug(@"executeUpdateQuery > failed query: %@",query);
            ZDebug(@"executeUpdateQuery > error: %@",[APPDELEGATE.db lastErrorMessage]);
        }
    }
    @catch (NSException *exception) {
        ZDebug(@" executeUpdateQuery exception==%@", exception);
    }
    @finally {
        [APPDELEGATE closeDb];
    }
    return queryStatus;
}

// for finding last updated row
- (int)executeUpdateQueryfind:(NSString *)query
{
    BOOL queryStatus = FALSE;
    int lastRowId;
    //[APPDELEGATE openDb];
    
    queryStatus = [APPDELEGATE.db executeUpdate:query];
    
    if(!queryStatus) {
        ZDebug(@"executeUpdateQuery > failed query: %@",query);
        ZDebug(@"executeUpdateQuery > error: %@",[APPDELEGATE.db lastErrorMessage]);
    }
    //    lastRowId = [APPDELEGATE.db lastInsertRowId];
    lastRowId = (int)[APPDELEGATE.db lastInsertRowId];
    
    //[APPDELEGATE closeDb];
    
    return lastRowId;
}
- (int)insertDataWithDictionary:(NSMutableDictionary *)dictData tableName:(NSString *)tblName
{
    int queryStatus = 0;
    NSString *query = [NSString stringWithFormat:@"INSERT INTO %@ %@", tblName,[self formateDictToValue:dictData]];
    
    queryStatus = [self executeUpdateQueryfind:query];
    
    if (queryStatus != 0) {
        //     // ZDebug(@"yesh");
    }else
        ZDebug(@"nop query ==%@",query); //
    
    return queryStatus;
}

- (BOOL)insertDataWithDictionaryReturnBool:(NSMutableDictionary *)dictData tableName:(NSString *)tblName
{
    BOOL queryStatus = 0;
    NSString *query = [NSString stringWithFormat:@"INSERT INTO %@ %@", tblName,[self formateDictToValue:dictData]];
    
    queryStatus = [self executeUpdateQuery:query];
    
    if (queryStatus) {
        //     // ZDebug(@"yesh");
    }else
        ZDebug(@"nop query ==%@",query); //
    
    return queryStatus;
}

- (BOOL)updateQuery:(NSString *)strQuery
{
    BOOL queryStatus = FALSE;
    
    queryStatus = [self executeUpdateQuery:strQuery];
    
    if (queryStatus) {
        //     // ZDebug(@"yesh");
    }else
        ZDebug(@"nop query ==%@",strQuery); //
    
    return queryStatus;
}

- (BOOL)updateDataWithDictionary:(NSMutableDictionary *)dictData tableName:(NSString *)tblName andRefrenceId:(int)refrenceId andRefrenceKey:(NSString *)refrenceKey
{
    BOOL queryStatus = FALSE;
    
    if ([dictData valueForKey:@"LocalId"] != Nil) {
        [dictData removeObjectForKey:@"LocalId"];
    }
    
    NSString *query = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ = '%d'",tblName, [self formateDictForUpdate:dictData],refrenceKey, refrenceId];
    
    queryStatus = [self executeUpdateQuery:query];
    
    return queryStatus;
}

- (BOOL)searchDataFromTable:(NSString *)tblName searchtext:(NSString *)txtSearch searchKey:(NSString *)searchKey
{
    NSString *QUERY_SELECT_INSTALLATION = [NSString stringWithFormat:@"SELECT * FROM  %@  WHERE  %@ like '%@'",tblName,searchKey,txtSearch];
    
    NSMutableArray *arrData = [self executeSelectQuery:QUERY_SELECT_INSTALLATION];
    
    if (arrData.count > 0) {
        return TRUE;
    }else
        return FALSE;
}

- (BOOL)searchDataFromTable:(NSString *)tblName where:(NSString *)txtWhere
{
    NSString *QUERY_SELECT_INSTALLATION = [NSString stringWithFormat:@"SELECT * FROM  %@  WHERE  %@",tblName,txtWhere];
    
    NSMutableArray *arrData = [self executeSelectQuery:QUERY_SELECT_INSTALLATION];
    
    if (arrData.count > 0) {
        return TRUE;
    }else
        return FALSE;
}

- (BOOL)deleteDataFromTable:(NSString *)tblName andRefrenceId:(int)refrenceId andRefrenceKey:(NSString *)refrenceKey
{
    BOOL isDeleted = FALSE;
    NSString *query = [NSString stringWithFormat: @"Delete FROM %@ WHERE %@ ='%d'",tblName,refrenceKey,refrenceId];
    
    isDeleted = [self executeUpdateQuery:query];
    return isDeleted;
}

- (BOOL)deleteDataFromTable:(NSString *)tblName
{
    BOOL isDeleted = FALSE;
    NSString *query = [NSString stringWithFormat: @"Delete FROM %@",tblName];
    
    isDeleted = [self executeUpdateQuery:query];
    return isDeleted;
}

- (BOOL)deleteDataFromTable:(NSString *)tblName AndQuery:(NSString *)strQuery
{
    BOOL isDeleted = FALSE;
    NSString *query = [NSString stringWithFormat: @"Delete FROM %@ %@",tblName,strQuery];
    
    isDeleted = [self executeUpdateQuery:query];
    return isDeleted;
}

- (NSMutableArray *)selectDataFromTable:(NSString *)tblName whereQuery:(NSString *)whereQuery
{
    NSString *QUERY_SELECT_INSTALLATION = [NSString stringWithFormat:@"SELECT * FROM  %@ %@",tblName,whereQuery];
    
    NSMutableArray *arrData = [self executeSelectQuery:QUERY_SELECT_INSTALLATION];
    
    return arrData;
}

- (NSMutableArray *)selectDatawhereQuery:(NSString *)whereQuery
{
    NSString *QUERY_SELECT_INSTALLATION = [NSString stringWithFormat:@"%@",whereQuery];
    
    NSMutableArray *arrData = [self executeSelectQuery:QUERY_SELECT_INSTALLATION];
    
    return arrData;
}



//- (NSMutableArray *)executeSelectQuery:(NSString *)query
//{
//    NSMutableArray *arrResultDict = [[NSMutableArray alloc] init];
//    
//    @try {
//        [APPDELEGATE openDb];
//        
//        FMResultSet *rs = [APPDELEGATE.db executeQuery:query];
//        
//        while ([rs next]) {
//            [arrResultDict addObject:[[NSMutableDictionary alloc] initWithDictionary:[rs resultDict]]];
//        }
//    }
//    @catch (NSException *exception) {
//        ZDebug(@"executeSelectQuery=exception==%@",exception );
//    }
//    @finally {
//        [APPDELEGATE closeDb];
//    }
//    return arrResultDict;
//}
//
//- (NSString *)formateDictToValue:(NSMutableDictionary *)dictValue
//{
//    dictValue = [self trimDataWithDict:dictValue];
//    
//    NSString *strValues = @"";
//    NSArray *arrKeys = [dictValue allKeys];
//    NSString *strKeys = @"(";
//    NSString *strData = @"(";
//    
//    for (int i = 0; i < [arrKeys count]; i++) {
//        
//        if([[dictValue valueForKey:[arrKeys objectAtIndex:i]] isKindOfClass:[NSString class]]){
//            strKeys = [strKeys stringByAppendingFormat:@"'%@',", [arrKeys objectAtIndex:i]];
//            strData = [strData stringByAppendingFormat:@"'%@',", [dictValue valueForKey:[arrKeys objectAtIndex:i]]];
//            
//        }else if([[dictValue valueForKey:[arrKeys objectAtIndex:i]] isKindOfClass:[NSNull class]]){
//            
//        }else{
//            strKeys = [strKeys stringByAppendingFormat:@"'%@',", [arrKeys objectAtIndex:i]];
//            strData = [strData stringByAppendingFormat:@"%@,", [dictValue valueForKey:[arrKeys objectAtIndex:i]]];
//        }
//    }
//    
//    strKeys = [strKeys substringToIndex:[strKeys length] - 1];
//    strData = [strData substringToIndex:[strData length] - 1];
//    
//    strValues = [NSString stringWithFormat:@"%@) VALUES %@)", strKeys, strData];
//    
//    return strValues;
//}
//
//- (NSString *)formateDictForUpdate:(NSMutableDictionary *)dictValue
//{
//    dictValue = [self trimDataWithDict:dictValue];
//    NSString *strValues = @"";
//    NSArray *arrKeys = [dictValue allKeys];
//    
//    for (int i = 0; i < [arrKeys count]; i++) {
//        
//        if([[dictValue valueForKey:[arrKeys objectAtIndex:i]] isKindOfClass:[NSString class]] && [[dictValue valueForKey:[arrKeys objectAtIndex:i]] isEqualToString:@""]){
//            strValues = [strValues stringByAppendingFormat:@"'%@' = '%@',", [arrKeys objectAtIndex:i], [dictValue valueForKey:[arrKeys objectAtIndex:i]]];
//
//        }else if([[dictValue valueForKey:[arrKeys objectAtIndex:i]] isKindOfClass:[NSString class]]){
//            strValues = [strValues stringByAppendingFormat:@"'%@' = '%@',", [arrKeys objectAtIndex:i], [dictValue valueForKey:[arrKeys objectAtIndex:i]]];
//            
//        }else if([[dictValue valueForKey:[arrKeys objectAtIndex:i]] isKindOfClass:[NSNull class]]){
//                        
//        }else{
//            strValues = [strValues stringByAppendingFormat:@"'%@' = '%@',", [arrKeys objectAtIndex:i], [dictValue valueForKey:[arrKeys objectAtIndex:i]]];
//        }
//    }
//    
//    strValues = [strValues substringToIndex:[strValues length] - 1];
//    
//    return strValues;
//}
//
//- (BOOL)executeUpdateQuery:(NSString *)query
//{
//    BOOL queryStatus = FALSE;
//    
//    @try {
//        [APPDELEGATE openDb];
//        
//        // ZDebug(@"executeUpdateQuery > query: %@",query);
//        
//        queryStatus = [APPDELEGATE.db executeUpdate:query];
//        
//        if(!queryStatus) {
//            ZDebug(@"executeUpdateQuery > failed query: %@",query);
//            ZDebug(@"executeUpdateQuery > error: %@",[APPDELEGATE.db lastErrorMessage]);
//        }
//    }
//    @catch (NSException *exception) {
//        ZDebug(@" executeUpdateQuery exception==%@", exception);
//    }
//    @finally {
//        [APPDELEGATE closeDb];
//    }
//    return queryStatus;
//}
//
//// for finding last updated row
//- (int)executeUpdateQueryfind:(NSString *)query
//{
//    BOOL queryStatus = FALSE;
//    int lastRowId;
//    [APPDELEGATE openDb];
//    
//    queryStatus = [APPDELEGATE.db executeUpdate:query];
//    
//    if(!queryStatus) {
//        ZDebug(@"executeUpdateQuery > failed query: %@",query);
//        ZDebug(@"executeUpdateQuery > error: %@",[APPDELEGATE.db lastErrorMessage]);
//    }
//    //    lastRowId = [APPDELEGATE.db lastInsertRowId];
//    lastRowId = (int)[APPDELEGATE.db lastInsertRowId];
//    
//    [APPDELEGATE closeDb];
//    
//    return lastRowId;
//}
//
//// core methods over
//
//
//- (int)insertDataWithDictionary:(NSMutableDictionary *)dictData tableName:(NSString *)tblName
//{
//    int queryStatus = 0;
//    NSString *query = [NSString stringWithFormat:@"INSERT INTO %@ %@", tblName,[self formateDictToValue:dictData]];
//    
//    queryStatus = [self executeUpdateQueryfind:query];
//    
//    if (queryStatus != 0) {
//        //     // ZDebug(@"yesh");
//    }else
//        ZDebug(@"nop query ==%@",query); //
//    
//    return queryStatus;
//}
//
//- (BOOL)insertDataWithDictionaryReturnBool:(NSMutableDictionary *)dictData tableName:(NSString *)tblName
//{
//    BOOL queryStatus = 0;
//    NSString *query = [NSString stringWithFormat:@"INSERT INTO %@ %@", tblName,[self formateDictToValue:dictData]];
//    
//    queryStatus = [self executeUpdateQuery:query];
//    
//    if (queryStatus) {
//        //     // ZDebug(@"yesh");
//    }else
//        ZDebug(@"nop query ==%@",query); //
//    
//    return queryStatus;
//}
//
//- (BOOL)updateQuery:(NSString *)strQuery
//{
//    BOOL queryStatus = FALSE;
//    
//    queryStatus = [self executeUpdateQuery:strQuery];
//    
//    if (queryStatus) {
//        //     // ZDebug(@"yesh");
//    }else
//        ZDebug(@"nop query ==%@",strQuery); //
//    
//    return queryStatus;
//}


//- (int)insertOrUpdateDataWithDictionary:(NSMutableDictionary *)dictData tableName:(NSString *)tblName
//{
//    BOOL queryStatus = FALSE;
//    NSMutableArray *arrSameData ;
//    
//    if ([tblName isEqualToString:TBL_CLAIM]) {
//        
//        // claim
//        NSString *strSelectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where ClaimId = %@ and CompanyId = %@ and CompanyUserId = %@",tblName,[dictData valueForKey:DKEY_CLAIM_ID],[dictData valueForKey:KEY_UD_COMPANY_ID],[dictData valueForKey:KEY_UD_COMPANY_USER_ID]];
//        [arrSameData removeAllObjects];
//        
//        arrSameData = [self executeSelectQuery:strSelectQuery];
//        
//        if (arrSameData.count > 0) {
//            
//            NSString *queryClaim = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE ClaimId = %@ and CompanyId = %@ and CompanyUserId = %@",tblName, [self formateDictForUpdate:dictData], [dictData valueForKey:DKEY_CLAIM_ID],[dictData valueForKey:KEY_UD_COMPANY_ID],[dictData valueForKey:KEY_UD_COMPANY_USER_ID]];
//            
//            queryStatus = [self updateQuery:queryClaim];
//            
//        }else {
//            queryStatus =  [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//        }
//    }else if ([tblName isEqualToString:TBL_EXPENSE]) {
//        
//        // expense
//        
//        NSString *strSelectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where ClaimId = %@ and ExpensesId = %@ and CompanyUserId = %@",tblName,[dictData valueForKey:DKEY_CLAIM_ID],[dictData valueForKey:@"ExpensesId"],[dictData valueForKey:KEY_UD_COMPANY_USER_ID]];
//        [arrSameData removeAllObjects];
//        arrSameData = [self executeSelectQuery:strSelectQuery];
//        
//        if (arrSameData.count > 0) {
//            
//            NSString *queryClaim = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE ClaimId = %@ and ExpensesId = %@ and CompanyUserId = %@",tblName, [self formateDictForUpdate:dictData], [dictData valueForKey:DKEY_CLAIM_ID],[dictData valueForKey:@"ExpensesId"],[dictData valueForKey:KEY_UD_COMPANY_USER_ID]];
//            
//            queryStatus = [self updateQuery:queryClaim];
//            
//        }else {
//            queryStatus =  [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//        }
//    }else if ([tblName isEqualToString:TBL_MILEAGE]) {
//        
//        // mileage
//        
//        NSString *strSelectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where ClaimId = %@ and MileageId = %@ and CompanyUserId = %@",tblName,[dictData valueForKey:DKEY_CLAIM_ID],[dictData valueForKey:@"MileageId"],[dictData valueForKey:KEY_UD_COMPANY_USER_ID]];
//        
//        arrSameData = [self executeSelectQuery:strSelectQuery];
//        
//        if (arrSameData.count > 0) {
//            
//            NSString *queryClaim = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE ClaimId = %@ and MileageId = %@ and CompanyUserId = %@",tblName, [self formateDictForUpdate:dictData], [dictData valueForKey:DKEY_CLAIM_ID],[dictData valueForKey:@"MileageId"],[dictData valueForKey:KEY_UD_COMPANY_USER_ID]];
//            
//            queryStatus = [self updateQuery:queryClaim];
//            
//        }else {
//            queryStatus =  [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//        }
//    }else if ([tblName isEqualToString:TBL_PERDIEM]) {
//        
//        // perdiem
//        
//        NSString *strSelectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where ClaimId = %@ and PerDiemId = %@ and CompanyUserId = %@",tblName,[dictData valueForKey:DKEY_CLAIM_ID],[dictData valueForKey:@"PerDiemId"],[dictData valueForKey:KEY_UD_COMPANY_USER_ID]];
//        
//        arrSameData = [self executeSelectQuery:strSelectQuery];
//        
//        if (arrSameData.count > 0) {
//            
//            NSString *queryClaim = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE ClaimId = %@ and PerDiemId = %@ and CompanyUserId = %@",tblName, [self formateDictForUpdate:dictData], [dictData valueForKey:DKEY_CLAIM_ID],[dictData valueForKey:@"PerDiemId"],[dictData valueForKey:KEY_UD_COMPANY_USER_ID]];
//            
//            queryStatus = [self updateQuery:queryClaim];
//            
//        }else {
//            queryStatus =  [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//        }
//    }else if ([tblName isEqualToString:TBL_EXPENSE_LINE]) {
//        
//        // expense line
//        
//        NSString *strSelectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where ExpensesId = %@ and ExpenseLineId = %@ and CompanyUserId = %@",tblName,[dictData valueForKey:@"ExpensesId"],[dictData valueForKey:@"ExpenseLineId"],[dictData valueForKey:KEY_UD_COMPANY_USER_ID]];
//        
//        arrSameData = [self executeSelectQuery:strSelectQuery];
//        
//        if (arrSameData.count > 0) {
//            
//            NSString *queryClaim = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE ExpensesId = %@ and ExpenseLineId = %@ and CompanyUserId = %@",tblName, [self formateDictForUpdate:dictData], [dictData valueForKey:@"ExpensesId"],[dictData valueForKey:@"ExpenseLineId"],[dictData valueForKey:KEY_UD_COMPANY_USER_ID]];
//            
//            queryStatus = [self updateQuery:queryClaim];
//            
//        }else {
//            queryStatus =  [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//        }
//    }else if (([tblName isEqualToString:TBL_MASTER_DATA_SYNC]) || ([tblName isEqualToString:TBL_USER_SYNC])) {
//        
//        // master data and synch data
//        
//        NSString *strSelectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where CompanyId = %@ and CompanyUserId = %@",tblName,[dictData valueForKey:KEY_UD_COMPANY_ID],[dictData valueForKey:KEY_UD_COMPANY_USER_ID]];
//        [arrSameData removeAllObjects];
//        
//        arrSameData = [self executeSelectQuery:strSelectQuery];
//        
//        if (arrSameData.count > 0) {
//            
//            NSString *queryClaim = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE CompanyId = %@ and CompanyUserId = %@",tblName, [self formateDictForUpdate:dictData],[dictData valueForKey:KEY_UD_COMPANY_ID],[dictData valueForKey:KEY_UD_COMPANY_USER_ID]];
//            
//            queryStatus = [self updateQuery:queryClaim];
//            
//        }else {
//            queryStatus =  [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//        }
//    }else if (([tblName isEqualToString:@"tblClaimApproverComments"])) {
//        
//        // tblClaimApproverComments
//        
//        NSString *strSelectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where ClaimApproverCommentId = '%@' and ClaimId = %@",tblName,[dictData valueForKey:@"ClaimApproverCommentId"],[dictData valueForKey:@"ClaimId"]];
//        [arrSameData removeAllObjects];
//        
//        arrSameData = [self executeSelectQuery:strSelectQuery];
//        
//        if (arrSameData.count > 0) {
//            
//            NSString *queryClaim = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE ClaimApproverCommentId = '%@' and ClaimId = %@",tblName, [self formateDictForUpdate:dictData],[dictData valueForKey:@"ClaimApproverCommentId"],[dictData valueForKey:@"ClaimId"]];
//            
//            queryStatus = [self updateQuery:queryClaim];
//            
//        }else {
//            queryStatus =  [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//        }
//    }else if (([tblName isEqualToString:@"tblCashApproverComments"] || [tblName isEqualToString:@"tblTravelApproverComments"])) {
//        
//        // tblTravelApproverComments OR tblCashApproverComments
//        
//        NSString *strSelectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where ClaimApproverCommentId = '%@' and CashTravelID = %@",tblName,[dictData valueForKey:@"ClaimApproverCommentId"],[dictData valueForKey:@"CashTravelID"]];
//        [arrSameData removeAllObjects];
//        
//        arrSameData = [self executeSelectQuery:strSelectQuery];
//        
//        if (arrSameData.count > 0) {
//            
//            NSString *queryClaim = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE ClaimApproverCommentId = '%@' and CashTravelID = %@",tblName, [self formateDictForUpdate:dictData],[dictData valueForKey:@"ClaimApproverCommentId"],[dictData valueForKey:@"CashTravelID"]];
//            
//            queryStatus = [self updateQuery:queryClaim];
//            
//        }else {
//            queryStatus =  [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//        }
//    }else if (([tblName isEqualToString:TBL_CASH_ADVANCE])) {
//        
//        // TBL_CASH_ADVANCE
//        
//        NSString *strSelectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where CashAdvanceId = '%@' and ClaimId = %@ and CompanyUserId = %@",tblName,[dictData valueForKey:@"CashAdvanceId"],[dictData valueForKey:@"ClaimId"],[dictData valueForKey:KEY_UD_COMPANY_USER_ID]];
//        [arrSameData removeAllObjects];
//        
//        arrSameData = [self executeSelectQuery:strSelectQuery];
//        
//        if (arrSameData.count > 0) {
//            
//            NSString *queryClaim = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE CashAdvanceId = '%@' and ClaimId = %@ and CompanyUserId = %@",tblName, [self formateDictForUpdate:dictData],[dictData valueForKey:@"CashAdvanceId"],[dictData valueForKey:@"ClaimId"],[dictData valueForKey:KEY_UD_COMPANY_USER_ID]];
//            
//            queryStatus = [self updateQuery:queryClaim];
//            
//        }else {
//            queryStatus =  [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//        }
//    }else if (([tblName isEqualToString:TBL_TRAVEL_REQUEST])) {
//        
//        // TBL_TRAVEL_REQUEST
//        
//        NSString *strSelectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where TravelRequestId = '%@' and ClaimId = %@ and CompanyUserId = %@",tblName,[dictData valueForKey:@"TravelRequestId"],[dictData valueForKey:@"ClaimId"],[dictData valueForKey:KEY_UD_COMPANY_USER_ID]];
//        [arrSameData removeAllObjects];
//        
//        arrSameData = [self executeSelectQuery:strSelectQuery];
//        
//        if (arrSameData.count > 0) {
//            
//            NSString *queryClaim = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE TravelRequestId = '%@' and ClaimId = %@ and CompanyUserId = %@",tblName, [self formateDictForUpdate:dictData],[dictData valueForKey:@"TravelRequestId"],[dictData valueForKey:@"ClaimId"],[dictData valueForKey:KEY_UD_COMPANY_USER_ID]];
//            
//            queryStatus = [self updateQuery:queryClaim];
//            
//        }else {
//            queryStatus =  [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//        }
//    }else if (([tblName isEqualToString:TBL_TRAVEL_DETAIL_REQUEST])) {
//        
//        // tblTravelRequestDetail
//        
//        NSString *strSelectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where TravelRequestId = '%@' and TravelRequestDetailId = %@",tblName,[dictData valueForKey:@"TravelRequestId"],[dictData valueForKey:@"TravelRequestDetailId"]];
//        [arrSameData removeAllObjects];
//        
//        arrSameData = [self executeSelectQuery:strSelectQuery];
//        
//        if (arrSameData.count > 0) {
//            
//            NSString *queryClaim = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE TravelRequestId = '%@' and TravelRequestDetailId = %@",tblName, [self formateDictForUpdate:dictData],[dictData valueForKey:@"TravelRequestId"],[dictData valueForKey:@"TravelRequestDetailId"]];
//            
//            queryStatus = [self updateQuery:queryClaim];
//            
//        }else {
//            queryStatus =  [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//        }
//    }else if (([tblName isEqualToString:@"UserSettings"] || [tblName isEqualToString:@"CompanyUserDetail"])) {
//        
//        // UserSettings & CompanyUserDetail
//        
//        NSString *strSelectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where CompanyUserId = '%@'",tblName,[dictData valueForKey:@"CompanyUserID"]];
//        [arrSameData removeAllObjects];
//        
//        arrSameData = [self executeSelectQuery:strSelectQuery];
//        
//        if (arrSameData.count > 0) {
//            
//            NSString *queryClaim = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE CompanyUserId = '%@'",tblName, [self formateDictForUpdate:dictData],[dictData valueForKey:@"CompanyUserID"]];
//            
//            queryStatus = [self updateQuery:queryClaim];
//            
//        }else {
//            queryStatus =  [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//        }
//    }else if (([tblName isEqualToString:@"tblExchangeRateData"])) {
//        
//        // tblExchangeRateData
//        
//        NSString *strSelectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where ExchangeRateDataValueID = '%@'",tblName,[dictData valueForKey:@"ExchangeRateDataValueID"]];
//        [arrSameData removeAllObjects];
//        
//        arrSameData = [self executeSelectQuery:strSelectQuery];
//        
//        if (arrSameData.count > 0) {
//            
//            NSString *queryClaim = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE ExchangeRateDataValueID = '%@'",tblName, [self formateDictForUpdate:dictData],[dictData valueForKey:@"ExchangeRateDataValueID"]];
//            
//            queryStatus = [self updateQuery:queryClaim];
//            
//        }else {
//            queryStatus =  [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//        }
//    }
//    
//    if (queryStatus) {
//        //       ZDebug(@"yesh");
//    }else
//        ZDebug(@"nop tblName ==%@",tblName);
//    
//    return queryStatus;
//}
//
//- (int)insertOrUpdateMasterDataWithDictionary:(NSMutableDictionary *)dictData tableName:(NSString *)tblName
//{
//    BOOL queryStatus = FALSE;
//    
//    NSMutableArray *arrSameData ;
//    
//    if ([tblName isEqualToString:@"AllocationCodeCategory"]) {
//        
//        // AllocationCodeCategory
//        
//        NSString *strSelectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where AllocationCodeCategoryId = %@ and CompanyId = %@ ",tblName,[dictData valueForKey:@"AllocationCodeCategoryId"],[dictData valueForKey:KEY_UD_COMPANY_ID]];
//        [arrSameData removeAllObjects];
//        
//        arrSameData = [self executeSelectQuery:strSelectQuery];
//        
//        if (arrSameData.count > 0) {
//            
//            NSString *queryClaim = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE AllocationCodeCategoryId = %@ and CompanyId = %@ ",tblName, [self formateDictForUpdate:dictData], [dictData valueForKey:@"AllocationCodeCategoryId"],[dictData valueForKey:KEY_UD_COMPANY_ID]];
//            
//            queryStatus = [self updateQuery:queryClaim];
//            
//        }else {
//            queryStatus =  [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//        }
//    }else if ([tblName isEqualToString:@"AllocationCodeItem"]) {
//        
//        // AllocationCodeItem
//        
//        NSString *strSelectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where AllocationCodeCategoryId = %@ and CompanyId = %@ and AllocationCodeItemId =%@",tblName,[dictData valueForKey:@"AllocationCodeCategoryId"],[dictData valueForKey:KEY_UD_COMPANY_ID],[dictData valueForKey:@"AllocationCodeItemId"]];
//        
//        [arrSameData removeAllObjects];
//        arrSameData = [self executeSelectQuery:strSelectQuery];
//        
//        if (arrSameData.count > 0) {
//            
//            NSString *queryClaim = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE AllocationCodeCategoryId = %@ and CompanyId = %@ and AllocationCodeItemId =%@ ",tblName, [self formateDictForUpdate:dictData], [dictData valueForKey:@"AllocationCodeCategoryId"],[dictData valueForKey:KEY_UD_COMPANY_ID],[dictData valueForKey:@"AllocationCodeItemId"]];
//            
//            queryStatus = [self updateQuery:queryClaim];
//            
//        }else {
//            queryStatus =  [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//        }
//    }else if ([tblName isEqualToString:@"CompanyCountry"]) {
//        
//        // CompanyCountry
//        NSString *strSelectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where CompanyCountryId = %@ and CompanyId = %@ ",tblName,[dictData valueForKey:@"CompanyCountryId"],[dictData valueForKey:KEY_UD_COMPANY_ID]];
//        
//        arrSameData = [self executeSelectQuery:strSelectQuery];
//        
//        if (arrSameData.count > 0) {
//            
//            NSString *queryClaim = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE CompanyCountryId = %@ and CompanyId = %@ ",tblName, [self formateDictForUpdate:dictData], [dictData valueForKey:@"CompanyCountryId"],[dictData valueForKey:KEY_UD_COMPANY_ID]];
//            
//            queryStatus = [self updateQuery:queryClaim];
//            
//        }else {
//            queryStatus =  [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//        }
//    }else if ([tblName isEqualToString:@"CompanyLanguage"]) {
//        
//        // CompanyLanguage
//        
//        NSString *strSelectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where CompanyLanguageId = %@ and CompanyId = %@ ",tblName,[dictData valueForKey:@"CompanyLanguageId"],[dictData valueForKey:KEY_UD_COMPANY_ID]];
//        
//        arrSameData = [self executeSelectQuery:strSelectQuery];
//        
//        if (arrSameData.count > 0) {
//            
//            NSString *queryClaim = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE CompanyLanguageId = %@ and CompanyId = %@ ",tblName, [self formateDictForUpdate:dictData], [dictData valueForKey:@"CompanyLanguageId"],[dictData valueForKey:KEY_UD_COMPANY_ID]];
//            
//            queryStatus = [self updateQuery:queryClaim];
//            
//        }else {
//            queryStatus =  [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//        }
//    }else if ([tblName isEqualToString:@"Currency"]) {
//        
//        // Currency
//        
//        NSString *strSelectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where CurrencyId = %@ and CompanyId = %@ and CompanyCountryId =%@",tblName,[dictData valueForKey:@"CurrencyId"],[dictData valueForKey:KEY_UD_COMPANY_ID],[dictData valueForKey:@"CompanyCountryId"]];
//        
//        arrSameData = [self executeSelectQuery:strSelectQuery];
//        
//        if (arrSameData.count > 0) {
//            
//            NSString *queryClaim = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE CurrencyId = %@ and CompanyId = %@ and CompanyCountryId =%@ ",tblName, [self formateDictForUpdate:dictData], [dictData valueForKey:@"CurrencyId"],[dictData valueForKey:KEY_UD_COMPANY_ID],[dictData valueForKey:@"CompanyCountryId"]];
//            
//            queryStatus = [self updateQuery:queryClaim];
//            
//        }else {
//            queryStatus =  [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//        }
//    }else if ([tblName isEqualToString:@"ExpenseType"]) {
//        
//        // ExpenseType
//        
//        NSString *strSelectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where ExpenseTypeId = %@ and CompanyId = %@ and CompanyCountryId =%@",tblName,[dictData valueForKey:@"ExpenseTypeId"],[dictData valueForKey:KEY_UD_COMPANY_ID],[dictData valueForKey:@"CompanyCountryId"]];
//        
//        arrSameData = [self executeSelectQuery:strSelectQuery];
//        
//        if (arrSameData.count > 0) {
//            
//            NSString *queryClaim = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE ExpenseTypeId = %@ and CompanyId = %@ and CompanyCountryId =%@ ",tblName, [self formateDictForUpdate:dictData], [dictData valueForKey:@"ExpenseTypeId"],[dictData valueForKey:KEY_UD_COMPANY_ID],[dictData valueForKey:@"CompanyCountryId"]];
//            
//            queryStatus = [self updateQuery:queryClaim];
//            
//        }else {
//            queryStatus =  [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//        }
//    }else if ([tblName isEqualToString:@"ReimbursableRate"]) {
//        
//        // ReimbursableRate
//        
//        NSString *strSelectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where ReimbursableRateId = %@ and CompanyId = %@ ",tblName,[dictData valueForKey:@"ReimbursableRateId"],[dictData valueForKey:KEY_UD_COMPANY_ID]];
//        
//        arrSameData = [self executeSelectQuery:strSelectQuery];
//        
//        if (arrSameData.count > 0) {
//            
//            NSString *queryClaim = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE ReimbursableRateId = %@ and CompanyId = %@ ",tblName, [self formateDictForUpdate:dictData], [dictData valueForKey:@"ReimbursableRateId"],[dictData valueForKey:KEY_UD_COMPANY_ID]];
//            
//            queryStatus = [self updateQuery:queryClaim];
//            
//        }else {
//            queryStatus =  [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//        }
//    }else if ([tblName isEqualToString:@"VATCode"]) {
//        
//        // VATCode
//        
//        NSString *strSelectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where VATCodeId = %@ and CompanyId = %@ and CompanyCountryId =%@",tblName,[dictData valueForKey:@"VATCodeId"],[dictData valueForKey:KEY_UD_COMPANY_ID],[dictData valueForKey:@"CompanyCountryId"]];
//        
//        arrSameData = [self executeSelectQuery:strSelectQuery];
//        
//        if (arrSameData.count > 0) {
//            
//            NSString *queryClaim = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE VATCodeId = %@ and CompanyId = %@ and CompanyCountryId =%@ ",tblName, [self formateDictForUpdate:dictData], [dictData valueForKey:@"VATCodeId"],[dictData valueForKey:KEY_UD_COMPANY_ID],[dictData valueForKey:@"CompanyCountryId"]];
//            
//            queryStatus = [self updateQuery:queryClaim];
//            
//        }else {
//            queryStatus =  [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//        }
//    }else if ([tblName isEqualToString:@"AllocationCodeItemApprover"]) {
//        
//        // AllocationCodeItemApprover
//        
//        NSString *strSelectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where Id = %@ and AllocationCodeItemId = %@ ",tblName,[dictData valueForKey:@"Id"],[dictData valueForKey:@"AllocationCodeItemId"]];
//        
//        arrSameData = [self executeSelectQuery:strSelectQuery];
//        
//        if (arrSameData.count > 0) {
//            
//            NSString *queryClaim = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE Id = %@ and AllocationCodeItemId = %@",tblName, [self formateDictForUpdate:dictData], [dictData valueForKey:@"VATCodeId"],[dictData valueForKey:@"AllocationCodeItemId"]];
//            
//            queryStatus = [self updateQuery:queryClaim];
//            
//        }else {
//            queryStatus =  [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//        }
//    }else if ([tblName isEqualToString:@"DateFormat"]) {
//        
//        // DateFormat
//        
//        NSString *strSelectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where DateFormatValue = '%@'",tblName,[dictData valueForKey:@"DateFormatValue"]];
//        
//        arrSameData = [self executeSelectQuery:strSelectQuery];
//        
//        if (arrSameData.count > 0) {
//            
//            NSString *queryClaim = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE DateFormatValue = '%@'",tblName, [self formateDictForUpdate:dictData], [dictData valueForKey:@"DateFormatValue"]];
//            
//            queryStatus = [self updateQuery:queryClaim];
//            
//        }else {
//            queryStatus =  [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//        }
//    }else if ([tblName isEqualToString:@"TranslatedAllocationCodeCategory"]) {
//        
//        // TranslatedAllocationCodeCategory
//        
//        NSString *strSelectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where AllocationCodeCategoryId = %@ and TranslatedAllocationCodeCategoryId = %@ ",tblName,[dictData valueForKey:@"AllocationCodeCategoryId"],[dictData valueForKey:@"TranslatedAllocationCodeCategoryId"]];
//        [arrSameData removeAllObjects];
//        
//        arrSameData = [self executeSelectQuery:strSelectQuery];
//        
//        if (arrSameData.count > 0) {
//            
//            NSString *queryClaim = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE AllocationCodeCategoryId = %@ and TranslatedAllocationCodeCategoryId = %@ ",tblName, [self formateDictForUpdate:dictData], [dictData valueForKey:@"AllocationCodeCategoryId"],[dictData valueForKey:@"TranslatedAllocationCodeCategoryId"]];
//            
//            queryStatus = [self updateQuery:queryClaim];
//            
//        }else {
//            queryStatus =  [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//        }
//    }else if ([tblName isEqualToString:@"TranslatedAllocationCodeItem"]) {
//        
//        // TranslatedAllocationCodeItem
//        
//        NSString *strSelectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where TranslatedAllocationCodeItem = %@ and AllocationCodeItemId =%@",tblName,[dictData valueForKey:@"TranslatedAllocationCodeItem"],[dictData valueForKey:@"AllocationCodeItemId"]];
//        
//        [arrSameData removeAllObjects];
//        arrSameData = [self executeSelectQuery:strSelectQuery];
//        
//        if (arrSameData.count > 0) {
//            
//            NSString *queryClaim = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE TranslatedAllocationCodeItem = %@ and AllocationCodeItemId =%@ ",tblName, [self formateDictForUpdate:dictData], [dictData valueForKey:@"TranslatedAllocationCodeItem"],[dictData valueForKey:@"AllocationCodeItemId"]];
//            
//            queryStatus = [self updateQuery:queryClaim];
//            
//        }else {
//            queryStatus =  [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//        }
//    }else if ([tblName isEqualToString:@"TranslatedCompanyCountries"]) {
//        
//        // TranslatedCompanyCountries
//        
//        NSString *strSelectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where CompanyCountryId = %@ and TranslatedCompanyCountryId = %@ ",tblName,[dictData valueForKey:@"CompanyCountryId"],[dictData valueForKey:@"TranslatedCompanyCountryId"]];
//        
//        arrSameData = [self executeSelectQuery:strSelectQuery];
//        
//        if (arrSameData.count > 0) {
//            
//            NSString *queryClaim = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE CompanyCountryId = %@ and TranslatedCompanyCountryId = %@ ",tblName, [self formateDictForUpdate:dictData], [dictData valueForKey:@"CompanyCountryId"],[dictData valueForKey:@"TranslatedCompanyCountryId"]];
//            
//            queryStatus = [self updateQuery:queryClaim];
//            
//        }else {
//            queryStatus =  [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//        }
//    }else if ([tblName isEqualToString:@"TranslatedCurrency"]) {
//        
//        // TranslatedCurrency
//        
//        NSString *strSelectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where CurrencyId = %@ and TranslatedCurrencyId = %@ ",tblName,[dictData valueForKey:@"CurrencyId"],[dictData valueForKey:@"TranslatedCurrencyId"]];
//        
//        arrSameData = [self executeSelectQuery:strSelectQuery];
//        
//        if (arrSameData.count > 0) {
//            
//            NSString *queryClaim = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE CurrencyId = %@ and TranslatedCurrencyId = %@ ",tblName, [self formateDictForUpdate:dictData], [dictData valueForKey:@"CurrencyId"],[dictData valueForKey:@"TranslatedCurrencyId"]];
//            
//            queryStatus = [self updateQuery:queryClaim];
//            
//        }else {
//            queryStatus =  [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//        }
//    }else if ([tblName isEqualToString:@"TranslatedExpenseType"]) {
//        
//        // TranslatedExpenseType
//        
//        NSString *strSelectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where ExpenseTypeId = %@ and TranslatedExpenseTypeId = %@",tblName,[dictData valueForKey:@"ExpenseTypeId"],[dictData valueForKey:@"TranslatedExpenseTypeId"]];
//        
//        arrSameData = [self executeSelectQuery:strSelectQuery];
//        
//        if (arrSameData.count > 0) {
//            
//            NSString *queryClaim = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE ExpenseTypeId = %@ and TranslatedExpenseTypeId = %@ ",tblName, [self formateDictForUpdate:dictData], [dictData valueForKey:@"ExpenseTypeId"],[dictData valueForKey:@"TranslatedExpenseTypeId"]];
//            
//            queryStatus = [self updateQuery:queryClaim];
//            
//        }else {
//            queryStatus =  [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//        }
//    }else if ([tblName isEqualToString:@"TranslatedReimbursableRate"]) {
//        
//        // TranslatedReimbursableRate
//        
//        NSString *strSelectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where ReimbursableRateId = %@ and TranslatedReimbursableRateId = %@ ",tblName,[dictData valueForKey:@"ReimbursableRateId"],[dictData valueForKey:@"TranslatedReimbursableRateId"]];
//        
//        arrSameData = [self executeSelectQuery:strSelectQuery];
//        
//        if (arrSameData.count > 0) {
//            
//            NSString *queryClaim = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE ReimbursableRateId = %@ and TranslatedReimbursableRateId = %@ ",tblName, [self formateDictForUpdate:dictData], [dictData valueForKey:@"ReimbursableRateId"],[dictData valueForKey:@"TranslatedReimbursableRateId"]];
//            
//            queryStatus = [self updateQuery:queryClaim];
//            
//        }else {
//            queryStatus =  [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//        }
//    }else if ([tblName isEqualToString:@"TranslatedVATCodes"]) {
//        
//        // TranslatedVATCodes
//        
//        NSString *strSelectQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where VATCodeId = %@ and TranslatedVATCodeId = %@",tblName,[dictData valueForKey:@"VATCodeId"],[dictData valueForKey:@"TranslatedVATCodeId"]];
//        
//        arrSameData = [self executeSelectQuery:strSelectQuery];
//        
//        if (arrSameData.count > 0) {
//            
//            NSString *queryClaim = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE VATCodeId = %@ and TranslatedVATCodeId = %@ ",tblName, [self formateDictForUpdate:dictData], [dictData valueForKey:@"VATCodeId"],[dictData valueForKey:@"TranslatedVATCodeId"]];
//            
//            queryStatus = [self updateQuery:queryClaim];
//            
//        }else {
//            queryStatus =  [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//        }
//    }else{
//        queryStatus = [self insertDataWithDictionaryReturnBool:dictData tableName:tblName];
//    }
//    
//    if (queryStatus) {
//    }else
//        ZDebug(@"nop tblName ==%@",tblName); //
//    
//    return queryStatus;
//}
//
//- (void)updateClaimStatus:(NSString *)strClaimId{
//    
//    if (strClaimId != Nil && strClaimId.length > 0) {
//        
//        NSString *strQueryForClaim = [NSString stringWithFormat:@"UPDATE tblclaim SET Status = 'N' WHERE  ClaimId = %@ AND RawState = 0 AND Status = 'D' AND CompanyUserId = %@",strClaimId,[[NSUserDefaults standardUserDefaults] valueForKey:KEY_UD_COMPANY_USER_ID]];
//        [[DatabaseUtil sharedDatabaseInstance] executeUpdateQuery:strQueryForClaim];
//        
//        NSString *strQueryForExpense = [NSString stringWithFormat:@"UPDATE tblExpense SET Status = 'N' WHERE  ClaimId = %@ AND RawState = 0 AND Status = 'D' AND CompanyUserId = %@",strClaimId,[[NSUserDefaults standardUserDefaults] valueForKey:KEY_UD_COMPANY_USER_ID]];
//        [[DatabaseUtil sharedDatabaseInstance] executeUpdateQuery:strQueryForExpense];
//        
//        NSString *strQueryForMileage = [NSString stringWithFormat:@"UPDATE tblMileage SET Status = 'N' WHERE  ClaimId = %@ AND RawState = 0 AND Status = 'D' AND CompanyUserId = %@",strClaimId,[[NSUserDefaults standardUserDefaults] valueForKey:KEY_UD_COMPANY_USER_ID]];
//        [[DatabaseUtil sharedDatabaseInstance] executeUpdateQuery:strQueryForMileage];
//        
//        NSString *strQueryForPD = [NSString stringWithFormat:@"UPDATE tblPerDiem SET Status = 'N' WHERE  ClaimId = %@ AND RawState = 0 AND Status = 'D' AND CompanyUserId = %@",strClaimId,[[NSUserDefaults standardUserDefaults] valueForKey:KEY_UD_COMPANY_USER_ID]];
//        [[DatabaseUtil sharedDatabaseInstance] executeUpdateQuery:strQueryForPD];
//        
//        NSString *strQueryForExpenseLine = [NSString stringWithFormat:@"UPDATE tblExpenseLine  SET Status = (SELECT Status from tblExpense C where ExpensesId = tblExpenseLine.ExpensesId and C.CompanyUserId = %@) where tblExpenseLine.CompanyUserId = %@",[[NSUserDefaults standardUserDefaults] valueForKey:KEY_UD_COMPANY_USER_ID],[[NSUserDefaults standardUserDefaults] valueForKey:KEY_UD_COMPANY_USER_ID]];
//        
//        [[DatabaseUtil sharedDatabaseInstance] executeUpdateQuery:strQueryForExpenseLine];
//    }
//}
//- (void)insertPerDiem:(NSArray *)arrPerDiemData andOnlyInsert:(int)intOnlyInsert{
//    
//    for (int i = 0; i < arrPerDiemData.count; i++) {
//        
//        NSMutableDictionary *dictData = [arrPerDiemData objectAtIndex:i];
//        NSMutableDictionary *dictPerDiem = [[NSMutableDictionary alloc]init];
//        
//        [dictPerDiem setValue:[dictData valueForKey:@"PerDiemId"] forKey:@"PerDiemId"];
//        [dictPerDiem setValue:[dictData valueForKey:@"CompanyUserId"] forKey:@"CompanyUserId"];
//        [dictPerDiem setValue:[[NSString stringWithFormat:@"%@",[dictData valueForKey:@"Description"]] trimString] forKey:@"Description"];
//        [dictPerDiem setValue:[dictData valueForKey:@"ClaimId"] forKey:@"ClaimId"];
//        [dictPerDiem setValue:[dictData valueForKey:@"Status"] forKey:@"Status"];
//        [dictPerDiem setValue:[[NSString stringWithFormat:@"%@",[dictData valueForKey:@"StartDate"]] trimString] forKey:@"StartDate"];
//        [dictPerDiem setValue:[[NSString stringWithFormat:@"%@",[dictData valueForKey:@"EndDate"]] trimString] forKey:@"EndDate"];
//        [dictPerDiem setValue:[dictData valueForKey:@"FromCountryId"] forKey:@"FromCountryId"];
//        [dictPerDiem setValue:[dictData valueForKey:@"ToCountryId"] forKey:@"ToCountryId"];
//        [dictPerDiem setValue:[dictData valueForKey:@"ReimbursableRateId"] forKey:@"ReimbursableRateId"];
//        [dictPerDiem setValue:[dictData valueForKey:@"FullDays"] forKey:@"FullDays"];
//        [dictPerDiem setValue:[dictData valueForKey:@"PartialDays"] forKey:@"PartialDays"];
//        [dictPerDiem setValue:[dictData valueForKey:@"NoOfMeals"] forKey:@"NoOfMeals"];
//        [dictPerDiem setValue:[dictData valueForKey:@"Amount"] forKey:@"Amount"];
//        [dictPerDiem setValue:[[NSString stringWithFormat:@"%@",[dictData valueForKey:@"Notes"]] trimString] forKey:@"Notes"];
//        [dictPerDiem setValue:[[NSString stringWithFormat:@"%@",[dictData valueForKey:@"TransactionDate"]] trimString] forKey:@"TransactionDate"];
//        [dictPerDiem setValue:[dictData valueForKey:@"CreatedBy"] forKey:@"CreatedBy"];
//        [dictPerDiem setValue:[[NSString stringWithFormat:@"%@",[dictData valueForKey:@"CreatedDate"]] trimString] forKey:@"CreatedDate"];
//        [dictPerDiem setValue:[[NSString stringWithFormat:@"%@",[dictData valueForKey:@"CreatedIP"]] trimString] forKey:@"CreatedIP"];
//        [dictPerDiem setValue:[[NSString stringWithFormat:@"%@",[dictData valueForKey:@"ModifiedDate"]] trimString] forKey:@"ModifiedDate"];
//        [dictPerDiem setValue:[[NSString stringWithFormat:@"%@",[dictData valueForKey:@"ModifiedIP"]] trimString] forKey:@"ModifiedIP"];
//        [dictPerDiem setValue:[dictData valueForKey:@"RawState"] forKey:@"RawState"];
//        [dictPerDiem setValue:[dictData valueForKey:@"DeletedBy"] forKey:@"DeletedBy"];
//        [dictPerDiem setValue:[[NSString stringWithFormat:@"%@",[dictData valueForKey:@"DeletedDate"]] trimString] forKey:@"DeletedDate"];
//        [dictPerDiem setValue:[[NSString stringWithFormat:@"%@",[dictData valueForKey:@"DeletedIP"]] trimString] forKey:@"DeletedIP"];
//        [dictPerDiem setValue:[dictData valueForKey:@"LocalPerdimId"] forKey:@"LocalPerdimId"];
//        [dictPerDiem setValue:[[NSString stringWithFormat:@"%@",[dictData valueForKey:@"AllocationCodeItems"]] trimString] forKey:@"AllocationCodeItems"];
//        [dictPerDiem setValue:[dictData valueForKey:@"ModifiedBy"] forKey:@"ModifiedBy"];
//        [dictPerDiem setValue:[dictData valueForKey:@"PerDiemStatus"] forKey:@"PerDiemStatus"];
//        
//        BOOL isInserted = FALSE;
//        
//        if (intOnlyInsert == 0) {
//            isInserted = [[DatabaseUtil sharedDatabaseInstance] insertOrUpdateDataWithDictionary:dictPerDiem tableName:TBL_PERDIEM];
//        }else
//            isInserted = [[DatabaseUtil sharedDatabaseInstance] insertDataWithDictionary:dictPerDiem tableName:TBL_PERDIEM];
//        
//        if (isInserted) {
//            //            ZDebug(@"yesh");
//        }else
//            ZDebug(@"nop -- > TBL_PERDIEM");
//    }
//}

@end
