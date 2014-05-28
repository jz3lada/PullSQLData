CREATE PROCEDURE [dbo].[sp_PullSQLData]   
(  
 @Table VARCHAR(92) = NULL   
)  
AS  
BEGIN  
  
	DECLARE @ObjId		INT,           
			@SysStat	SMALLINT,      
			@DBName		VARCHAR(20),  
			@ColName	VARCHAR(20),  
			@ColType	TINYINT,  
			@Str		VARCHAR(255),  
			@Field		VARCHAR(255),  
			@Quotes		VARCHAR(20),  
			@nCount		INT  
  
 /*============================================================================*/  
 /*  Make sure the @Table is local to the current database.                    */  
 /*============================================================================*/  
  
 IF @Table like '%.%.%' AND substring(@Table, 1, charindex('.', @Table) - 1) <> db_name()  
 BEGIN  
  RAISERROR(15250,-1,-1)  
  RETURN(1)  
 END  
  
 /*============================================================================*/  
 /*  Make sure the @Table exist.                                               */  
 /*============================================================================*/  
  
 SELECT @ObjId = id, @SysStat = sysstat FROM sysobjects WHERE id = object_id(@Table) AND type = 'U'  
 IF @ObjId IS NULL      
 BEGIN  
  SELECT @DBName = db_name()  
         RAISERROR(15009,-1,-1,@Table,@DBName)  
         RETURN(1)  
     END  
  
 SELECT @Quotes = '''' + '''' + '' + '''' + ''''   
  
 IF @sysstat & 0xf in (1, 2, 3)  -- system table, view, or user table.  
 BEGIN  
	DECLARE cur_table SCROLL CURSOR FOR  
	SELECT  
		c.name ,  
		t.type  
	FROM  
		syscolumns c  
		LEFT JOIN systypes t  
		ON c.usertype  =  t.usertype  
	WHERE  
		c.id =  @objid      
	ORDER BY colid  
  
  OPEN cur_table  
  
  SELECT @Field  = ' '  
  SELECT @Str = 'SELECT  ' + '''' + ' INSERT INTO ' + @Table + ' VALUES ( '' + '  
  SELECT @nCount = 0  
  PRINT  @Str  
  
  WHILE (1=1)  
  BEGIN  
   FETCH NEXT FROM cur_table  INTO    
       @colname ,  
       @coltype  
   IF @@FETCH_STATUS <> 0  
   BREAK 
  
	SELECT @Field =   
    CASE  
		 WHEN @ColType IN (62) --Para Campos Float sin Redondeo  
			THEN 'RTRIM(CONVERT(VARCHAR(25), CONVERT(NUMERIC(19,4), ISNULL(' + @ColName + ',0))))'  
		 WHEN @ColType IN (38,48,52,55,56,59,60,63,106,108,109,110,122)   
			THEN 'RTRIM(CONVERT(VARCHAR(25),ISNULL('      + @ColName + ',0)))'  
		 WHEN @ColType IN (61,111,58)          
			--THEN @Quotes + ' + ' + 'CONVERT(CHAR(10),'   + @colname + ',111)' + ' + ' + @Quotes  
			THEN @Quotes + ' + ' + 'CONVERT(CHAR(10),ISNULL('   + @ColName + ',''''),111)' + ' + ' + @Quotes  
		 WHEN @ColType IN (45,50,47,37,39)         
			THEN @Quotes + ' + ' + 'RTRIM(LTRIM(ISNULL(' + @ColName + ',0)))' + ' + ' + @Quotes   
    END  
  
    IF @nCount > 0  
    BEGIN  
		SELECT @Str =  '+' + ' ' + ''',''' + ' ' + '+' + ' '  + @Field   
		PRINT  @Str  
    END  
	ELSE  
		PRINT @Field  
		SELECT @nCount = @nCount + 1  
	END  
  
	IF @nCount > 0  
		SELECT @Str = '+ '')'' FROM ' + @Table   
        PRINT @Str  
    END  
  
    CLOSE  cur_table  
    DEALLOCATE  cur_table  
  
END  