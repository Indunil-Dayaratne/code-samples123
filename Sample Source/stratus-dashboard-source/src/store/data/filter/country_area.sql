-- Server: SQLTCHDBS01

SELECT (select AccumulationID as GeographySid
			, AccumulationName as Name
			, CountryCode
			FROM [CatResultsDatabase].[dbo].[Accumulation]
			where AccumulationLevel in ('COUN')
			order by 
			case AccumulationLevel
				when 'COUN' then 1
				when 'AREA' then 2
				else 3
			end, CountryCode, AreaCode, SubAreaCode
			for json path) as Countries
	, (SELECT AccumulationID as GeographySid
			, AccumulationName as Name
			, CountryCode
			, AreaCode
			FROM [CatResultsDatabase].[dbo].[Accumulation]
			where AccumulationLevel in ('AREA')
			order by 
			case AccumulationLevel
				when 'COUN' then 1
				when 'AREA' then 2
				else 3
			end, CountryCode, AreaCode, SubAreaCode
			for json path) as Areas
for json path, WITHOUT_ARRAY_WRAPPER