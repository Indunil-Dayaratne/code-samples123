-- Server: SQLTCHDBS01

select ModelID as [Model]
	, cast(ModelID as varchar) + ': ' + ModelName as [Name]
from CatResultsDatabase..Model
order by ModelID
for json path, root('Perils')