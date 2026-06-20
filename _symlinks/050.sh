SELECT
    t.table_name AS `Table`,
    GROUP_CONCAT(i.column_name ORDER BY i.seq_in_index SEPARATOR ', ') AS `Columns`,
    i.index_name AS `Index Name`,
    CASE i.non_unique WHEN 0 THEN 'Unique' ELSE 'Non-Unique' END AS `Index Type`,
    CASE i.nullable WHEN 'YES' THEN 'Yes' ELSE 'No' END AS `Nullable`,
    CASE i.non_unique WHEN 0 THEN '✓' ELSE '' END AS `Unique`,
    i.cardinality AS `Cardinality`
FROM information_schema.statistics i
JOIN information_schema.tables t ON i.table_schema = t.table_schema AND i.table_name = t.table_name
WHERE
    i.table_schema = 'vov'
    AND i.index_name != 'PRIMARY'
    AND i.non_unique = 0
GROUP BY t.table_name, i.index_name, i.non_unique, i.nullable, i.cardinality
ORDER BY t.table_name, i.index_name;
