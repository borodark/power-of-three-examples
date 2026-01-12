# Query cubes with ecto


```elixir

iex(one@localhost)6> import Ecto.Query, only: [from: 2]


iex(one@localhost)2> query = from o in Cubes.OrdersNoPreagg, group_by: o.brand_code,  select: {o.brand_code, sum(o.total_amount_sum)}, order_by: [desc: 2], limit: 1000

#Ecto.Query<from o0 in Cubes.OrdersNoPreagg, group_by: [o0.brand_code],
 order_by: [desc: 2], limit: 1000,
 select: {o0.brand_code, sum(o0.total_amount_sum)}>


iex(one@localhost)3> Cubes.Repo.all(query)

[debug] %Postgrex.Query{ref: nil, name: "ecto_2564", statement: "SELECT o0.\"brand_code\", sum(o0.\"total_amount_sum\") FROM \"orders_no_preagg\" AS o0 GROUP BY o0.\"brand_code\" ORDER BY 2 DESC LIMIT 1000", param_oids: nil, param_formats: nil, param_types: nil, columns: nil, result_oids: nil, result_formats: nil, result_types: nil, types: nil, cache: :reference} uses unknown oid(s) 25, 701forcing us to reload type information from the database. This is expected behaviour whenever you migrate your database.

[debug] QUERY OK source="orders_no_preagg" db=143.0ms decode=5.2ms queue=254.1ms idle=1071.9ms
SELECT o0."brand_code", sum(o0."total_amount_sum") FROM "orders_no_preagg" AS o0 GROUP BY o0."brand_code" ORDER BY 2 DESC LIMIT 1000 []
↳ :elixir.eval_external_handler/3, at: src/elixir.erl:386
[
  {"Delirium Tremens", 35058016.0},
  {"Sierra Nevada", 35043373.0},
  {"Heineken", 34968575.0},
  {"Amstel", 34855388.0},
  {"Guinness", 34798926.0},
  {"Sapporo Premium", 34776423.0},
  {"Carlsberg", 34692997.0},
  {"Pabst Blue Ribbon", 34610865.0},
  {"Leffe", 34557125.0},
  {"Corona Extra", 34479369.0},
  {"Lowenbrau", 34451586.0},
  {"Rolling Rock", 34419633.0},
  {"Pacifico", 34358087.0},
  {"Quimes", 34288698.0},
  {"Budweiser", 34275477.0},
  {"Fosters", 34259379.0},
  {"Murphys", 34208814.0},
  {"Miller Draft", 34196616.0},
  {"Dos Equis", 34138301.0},
  {"Blue Moon", 34112659.0},
  {"Coors lite", 34053570.0},
  {"Delirium Noctorum'", 34015748.0},
  {"Becks", 33987863.0},
  {"Samuel Adams", 33957779.0},
  {"BudLight", 33922738.0},
  {"Stella Artois", 33920629.0},
  {"Hoegaarden", 33841446.0},
  {"Birra Moretti", 33841093.0},
  {"Tsingtao", 33717093.0},
  {"Red Stripe", 33605572.0},
  {"Patagonia", 33564470.0},
  {"Paulaner", 33541372.0},
  {"Kirin Inchiban", 33460728.0},
  {"Harp", 33419137.0}
]

iex(one@localhost)4> query = from o in Cubes.OrdersNoPreagg, group_by: o.brand_code,  select: {o.brand_code, sum(o.total_amount_sum), count(o.count)}, order_by: [desc: 2], limit: 1000

#Ecto.Query<from o0 in Cubes.OrdersNoPreagg, group_by: [o0.brand_code],
 order_by: [desc: 2], limit: 1000,
 select: {o0.brand_code, sum(o0.total_amount_sum), count(o0.count)}>

iex(one@localhost)5> Cubes.Repo.all(query)

[debug] %Postgrex.Query{ref: nil, name: "ecto_1360", statement: "SELECT o0.\"brand_code\", sum(o0.\"total_amount_sum\"), count(o0.\"count\") FROM \"orders_no_preagg\" AS o0 GROUP BY o0.\"brand_code\" ORDER BY 2 DESC LIMIT 1000", param_oids: nil, param_formats: nil, param_types: nil, columns: nil, result_oids: nil, result_formats: nil, result_types: nil, types: nil, cache: :reference} uses unknown oid(s) 20forcing us to reload type information from the database. This is expected behaviour whenever you migrate your database.

[debug] QUERY OK source="orders_no_preagg" db=146.0ms queue=242.7ms idle=1782.5ms
SELECT o0."brand_code", sum(o0."total_amount_sum"), count(o0."count") FROM "orders_no_preagg" AS o0 GROUP BY o0."brand_code" ORDER BY 2 DESC LIMIT 1000 []
↳ :elixir.eval_external_handler/3, at: src/elixir.erl:386
[
  {"Delirium Tremens", 35058016.0, 12441},
  {"Sierra Nevada", 35043373.0, 12304},
  {"Heineken", 34968575.0, 12434},
  {"Amstel", 34855388.0, 12278},
  {"Guinness", 34798926.0, 12358},
  {"Sapporo Premium", 34776423.0, 12271},
  {"Carlsberg", 34692997.0, 12313},
  {"Pabst Blue Ribbon", 34610865.0, 12261},
  {"Leffe", 34557125.0, 12332},
  {"Corona Extra", 34479369.0, 12282},
  {"Lowenbrau", 34451586.0, 12307},
  {"Rolling Rock", 34419633.0, 12265},
  {"Pacifico", 34358087.0, 12251},
  {"Quimes", 34288698.0, 12266},
  {"Budweiser", 34275477.0, 12201},
  {"Fosters", 34259379.0, 12290},
  {"Murphys", 34208814.0, 12156},
  {"Miller Draft", 34196616.0, 12224},
  {"Dos Equis", 34138301.0, 12073},
  {"Blue Moon", 34112659.0, 12149},
  {"Coors lite", 34053570.0, 12179},
  {"Delirium Noctorum'", 34015748.0, 12096},
  {"Becks", 33987863.0, 12191},
  {"Samuel Adams", 33957779.0, 12073},
  {"BudLight", 33922738.0, 12118},
  {"Stella Artois", 33920629.0, 12097},
  {"Hoegaarden", 33841446.0, 12141},
  {"Birra Moretti", 33841093.0, 12148},
  {"Tsingtao", 33717093.0, 12126},
  {"Red Stripe", 33605572.0, 12109},
  {"Patagonia", 33564470.0, 12151},
  {"Paulaner", 33541372.0, 12015},
  {"Kirin Inchiban", 33460728.0, 11979},
  {"Harp", 33419137.0, 12006}
]


iex(one@localhost)7> query = from o in Cubes.OrdersWithPreagg, group_by: [o.brand_code, o.market_code],  select: {o.brand_code, o.market_code, sum(o.total_amount_sum), count(o.count)}, order_by: [desc: 3], limit: 10000

#Ecto.Query<from o0 in Cubes.OrdersWithPreagg,
 group_by: [o0.brand_code, o0.market_code], order_by: [desc: 3], limit: 10000,
 select: {o0.brand_code, o0.market_code, sum(o0.total_amount_sum), count(o0.count)}>
iex(one@localhost)8> Cubes.Repo.all(query)

[debug] QUERY OK source="orders_with_preagg" db=465.1ms decode=4.4ms queue=63.6ms idle=1969.8ms
SELECT o0."brand_code", o0."market_code", sum(o0."total_amount_sum"), count(o0."count") FROM "orders_with_preagg" AS o0 GROUP BY o0."brand_code", o0."market_code" ORDER BY 3 DESC LIMIT 10000 []
↳ :elixir.eval_external_handler/3, at: src/elixir.erl:386
[
  {"Sapporo Premium", "BQ", 318629.0, 99},
  {"Pabst Blue Ribbon", "BQ", 317019.0, 113},
  {"Budweiser", "BQ", 300214.0, 100},
  {"Blue Moon", "BQ", 292281.0, 94},
  {"Guinness", "BQ", 289572.0, 107},
  {"Samuel Adams", "BQ", 287989.0, 103},
  {"Pacifico", "BQ", 287117.0, 97},
  {"Sierra Nevada", "BQ", 285322.0, 97},
  {"Fosters", "BQ", 278013.0, 103},
  {"Dos Equis", "BQ", 276598.0, 97},
  {"Corona Extra", "BQ", 276251.0, 98},
  {"Red Stripe", "BQ", 276201.0, 101},
  {"Murphys", "BQ", 274747.0, 109},
  {"Coors lite", "BQ", 273765.0, 93},
  {"Miller Draft", "BQ", 267945.0, 93},
  {"Kirin Inchiban", "BQ", 265479.0, 94},
  {"Lowenbrau", "BQ", 263631.0, 95},
  {"Amstel", "BQ", 262521.0, 86},
  {"Leffe", "BQ", 262101.0, 100},
  {"Stella Artois", "BQ", 255799.0, 101},
  {"Harp", "BQ", 255116.0, 97},
  {"Birra Moretti", "BQ", 253663.0, 96},
  {"Patagonia", "BQ", 252580.0, 94},
  {"Delirium Noctorum'", "BQ", 248882.0, 85},
  {"Carlsberg", "BQ", 246613.0, 94},
  {"Paulaner", "BQ", 243588.0, 90},
  {"Rolling Rock", "BQ", 241537.0, 88},
  {"Quimes", "BQ", 240502.0, 94},
  {"Heineken", "BQ", 239358.0, 82},
  {"Leffe", "PW", 236982.0, 70},
  {"Tsingtao", "BQ", 233910.0, 88},
  {"Hoegaarden", "BQ", 232964.0, 89},
  {"Becks", "BQ", 231563.0, 89},
  {"Leffe", "LB", 229888.0, 68},
  {"Becks", "NP", 223388.0, 83},
  {"Rolling Rock", "PY", 219185.0, 73},
  {"Blue Moon", "AI", 218804.0, 69},
  {"Patagonia", "CM", 216829.0, 64},
  {"Budweiser", "BD", 216726.0, 68},
  {"BudLight", "BQ", 215081.0, 84},
  {"Tsingtao", "UA", 214073.0, 68},
  {"Heineken", "RU", 211357.0, 68},
  {"Murphys", "IL", 210477.0, 67},
  {"Delirium Noctorum'", "PH", 208952.0, 65},
  {"Guinness", "CI", 208822.0, 67},
  {"Delirium Noctorum'", "RW", 207017.0, 69},
  {"Pacifico", "EE", 206179.0, ...},
  {"Carlsberg", "GR", ...},
  {"Amstel", ...},
  {...},
  ...
]


```
