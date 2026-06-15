SELECT
	t.table_name AS `Table`,
    i.column_name AS `Column`,
    i.index_name AS `Index Name`,
    CASE i.non_unique WHEN 0 THEN 'Unique' ELSE 'Non-Unique' END AS `Index Type`,
    -- i.collation AS `Ascending`,
    CASE i.nullable WHEN 'YES' THEN 'Yes' ELSE 'No' END AS `Nullable`,
    CASE i.non_unique WHEN 0 THEN '✓' ELSE '' END AS `Unique`,
    -- i.index_comment AS `Extra`,
    i.cardinality AS `Cardinality`
    -- i.index_comment AS `Comment`
FROM information_schema.statistics i
JOIN information_schema.tables t ON i.table_schema = t.table_schema AND i.table_name = t.table_name
WHERE
    i.table_schema = 'vov'
    AND i.index_name != 'PRIMARY'
    AND i.non_unique=0
ORDER BY t.table_name, i.index_name;
