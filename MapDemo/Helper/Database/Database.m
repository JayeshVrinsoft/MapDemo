//
//  Database.h
//  BookReader
//
//  Created by Shashi on 18/07/12.
//  Copyright ©2012, Coho Software LLC. All rights reserved

#import "Database.h"
#import "defines.h"

static Database *shareDatabase =nil;

@implementation Database
#pragma mark -
#pragma mark Database


+(Database*) shareDatabase {
    
    if(!shareDatabase){
        shareDatabase = [[Database alloc] init];
    }
    
    return shareDatabase;
}

#pragma mark -
#pragma mark Get DataBase Path

NSString * const DataBaseName  = @"DBVirtualGuard.sqlite"; // Pass Your DataBase Name Over here

- (NSString *) GetDatabasePath:(NSString *) dbName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return [documentsDir stringByAppendingPathComponent:dbName];
}

-(BOOL) createEditableCopyOfDatabaseIfNeeded
{
    BOOL success;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:DataBaseName];
    
    NSLog(@"Database Path : %@",writableDBPath);
    //    APP_DELEGATE.strDatabasePath = writableDBPath;
    
    success = [fileManager fileExistsAtPath:writableDBPath];
    
    if (success)
        return success;
    
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DataBaseName];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    
    if (!success) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!!!" message:@"Failed to create writable database" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }
    
    return success;
}


#pragma mark -
#pragma mark Get All Record

-(NSMutableArray *)SelectAllFromTable:(NSString *)query
{
    sqlite3_stmt *statement = nil ;
    NSString *path = [self GetDatabasePath:DataBaseName];
    
    NSMutableArray *alldata = [[NSMutableArray alloc] init];
    
    if(sqlite3_open([path UTF8String],&databaseObj) == SQLITE_OK)
    {
        if((sqlite3_prepare_v2(databaseObj,[query UTF8String],-1, &statement, NULL)) == SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                NSMutableDictionary *currentRow = [[NSMutableDictionary alloc] init];
                
                int count = sqlite3_column_count(statement);
                
                for (int i=0; i < count; i++) {
                    
                    char *name = (char*) sqlite3_column_name(statement, i);
                    char *data = (char*) sqlite3_column_text(statement, i);
                    
                    NSString *columnData;
                    NSString *columnName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
                    
                    if ([columnName isEqualToString:@"image"])
                    {
                        const void *ptr = sqlite3_column_blob(statement, i);
                        int size = sqlite3_column_bytes(statement, i);
                        NSData  *data1 = [[NSData alloc] initWithBytes:ptr length:size];
                        if ([data1 length] == 0)
                        {
                            columnData = @"";
                        }
                        else
                        {
                            columnData = [data1 base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                        }
                    }
                    else
                    {
                        if(data != nil){
                            columnData = [NSString stringWithCString:data encoding:NSUTF8StringEncoding];
                        }else {
                            columnData = @"";
                        }
                    }
                    
                    [currentRow setObject:columnData forKey:columnName];
                }
                
                [alldata addObject:currentRow];
            }
        }
        sqlite3_finalize(statement);
    }
    
//    NSLog(@"%@",[self sqlite3StmtToString:statement]);
    
    if(sqlite3_close(databaseObj) == SQLITE_OK) {
        
    }
    else
    {
        NSAssert1(0, @"Error: failed to close database on memwarning with message '%s'.", sqlite3_errmsg(databaseObj));
    }
    
    return alldata;
}

//-(NSMutableString *) sqlite3StmtToString:(sqlite3_stmt*) statement
//{
//    NSMutableString *s = [NSMutableString new];
//    [s appendString:@"{\"statement\":["];
//    for (int c = 0; c < sqlite3_column_count(statement); c++){
//        [s appendFormat:@"{\"column\":\"%@\",\"value\":\"%@\"}",[NSString stringWithUTF8String:(char*)sqlite3_column_name(statement, c)],[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, c)]];
//        if (c < sqlite3_column_count(statement) - 1)
//            [s appendString:@","];
//    }
//    [s appendString:@"]}"];
//    return s;
//}

#pragma mark -
#pragma mark Get Record Count

-(int)getCount:(NSString *)query
{
    int m_count=0;
    sqlite3_stmt *statement = nil ;
    NSString *path = [self GetDatabasePath:DataBaseName];
    
    if(sqlite3_open([path UTF8String],&databaseObj) == SQLITE_OK)
    {
        if((sqlite3_prepare_v2(databaseObj,[query UTF8String],-1, &statement, NULL)) == SQLITE_OK)
        {
            if(sqlite3_step(statement) == SQLITE_ROW)
            {
                m_count= sqlite3_column_int(statement,0);
            }
        }
        sqlite3_finalize(statement);
    }
    if(sqlite3_close(databaseObj) == SQLITE_OK) {
        
    } else {
        NSAssert1(0, @"Error: failed to close database on memwarning with message '%s'.", sqlite3_errmsg(databaseObj));
    }
    return m_count;
}

#pragma mark -
#pragma mark Check For Record Present

-(BOOL)CheckForRecord:(NSString *)query
{
    sqlite3_stmt *statement = nil;
    NSString *path = [self GetDatabasePath:DataBaseName];
    int isRecordPresent = 0;
    
    if(sqlite3_open([path UTF8String],&databaseObj) == SQLITE_OK )
    {
        if((sqlite3_prepare_v2(databaseObj, [query UTF8String], -1, &statement, NULL)) == SQLITE_OK)
        {
            if(sqlite3_step(statement) == SQLITE_ROW)
            {
                isRecordPresent = 1;
            }
            else {
                isRecordPresent = 0;
            }
        }
    }
    sqlite3_finalize(statement);
    if(sqlite3_close(databaseObj) == SQLITE_OK){
        
    }else{
        NSAssert1(0, @"Error: failed to close database on memwarning with message '%s'.", sqlite3_errmsg(databaseObj));
    }
    return isRecordPresent;
}

#pragma mark -
#pragma mark Insert

- (void)Insert:(NSString *)query
{
    sqlite3_stmt *statement=nil;
    NSString *path = [self GetDatabasePath:DataBaseName];
    
    if(sqlite3_open([path UTF8String],&databaseObj) == SQLITE_OK)
    {
        if((sqlite3_prepare_v2(databaseObj, [query UTF8String], -1, &statement,NULL)) == SQLITE_OK)
        {
            sqlite3_bind_text(statement, 1, [query UTF8String], -1, SQLITE_TRANSIENT);
            if (sqlite3_step(statement) != SQLITE_DONE)
            {
                NSLog(@"SQL execution failed: %s", sqlite3_errmsg(databaseObj));
            }
            
            sqlite3_step(statement);
        }
    }
    sqlite3_finalize(statement);
    if(sqlite3_close(databaseObj) == SQLITE_OK)
    {
        
        
    }else{
        NSAssert1(0, @"Error: failed to close database on memwarning with message '%s'.", sqlite3_errmsg(databaseObj));
    }
}

- (void)InsertForImages:(NSString *)query
{
    sqlite3_stmt *statement=nil;
    NSString *path = [self GetDatabasePath:DataBaseName];
    
    if(sqlite3_open([path UTF8String],&databaseObj) == SQLITE_OK)
    {
        if((sqlite3_prepare_v2(databaseObj, [query UTF8String], -1, &statement,NULL)) == SQLITE_OK)
        {
            sqlite3_step(statement);
        }
    }
    sqlite3_finalize(statement);
    if(sqlite3_close(databaseObj) == SQLITE_OK)
    {
        
    }
    else
    {
        NSAssert1(0, @"Error: failed to close database on memwarning with message '%s'.", sqlite3_errmsg(databaseObj));
    }
}


#pragma mark -
#pragma mark DeleteRecord

-(void)Delete:(NSString *)query
{
    sqlite3_stmt *statement = nil;
    NSString *path = [self GetDatabasePath:DataBaseName] ;
    if(sqlite3_open([path UTF8String],&databaseObj) == SQLITE_OK )
    {
        if((sqlite3_prepare_v2(databaseObj, [query UTF8String], -1, &statement, NULL)) == SQLITE_OK)
        {
            sqlite3_step(statement);
        }
    }
    sqlite3_finalize(statement);
    if(sqlite3_close(databaseObj) == SQLITE_OK) {
        
    }
    else
    {
        NSAssert1(0, @"Error: failed to close database on memwarning with message '%s'.", sqlite3_errmsg(databaseObj));
    }
}

#pragma mark -
#pragma mark UpdateRecord

-(void)Update:(NSString *)query
{
    sqlite3_stmt *statement=nil;
    NSString *path = [self GetDatabasePath:DataBaseName] ;
    
    if(sqlite3_open([path UTF8String],&databaseObj) == SQLITE_OK)
    {
        if(sqlite3_prepare_v2(databaseObj, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_step(statement);
        }
        sqlite3_finalize(statement);
    }
    if(sqlite3_close(databaseObj) == SQLITE_OK)
    {
        
    }
    else
    {
        NSAssert1(0, @"Error: failed to close database on memwarning with message '%s'.", sqlite3_errmsg(databaseObj));
    }
}


#pragma handle database version

-(BOOL)createtable:(NSString *)tableName {
    
    BOOL ret;
    int rc;
    // SQL to create new table
    
    NSString *sql_str = [NSString stringWithFormat:@"CREATE TABLE %@ (pk INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , ItemName VARCHAR(100), Quantity INTEGER DEFAULT 0, Status BOOLEAN,Type VARCHAR(100))", tableName];
    
    const char *sqlStatement = (char *)[sql_str UTF8String];
    NSLog(@"query %s",sqlStatement);
    
    sqlite3_stmt *stmt;
    rc = sqlite3_prepare_v2(databaseObj, sqlStatement, -1, &stmt, NULL);
    
    ret = (rc == SQLITE_OK);
    if (ret)
    { // statement built, execute
        rc = sqlite3_step(stmt);
        ret = (rc == SQLITE_DONE);
    }
    
    sqlite3_finalize(stmt); // free statement
    NSLog(@"creating table");
    return ret;
}

@end
