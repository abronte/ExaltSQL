# Exalt SQL
Exalt SQL is a suplimented SQL language with Ruby built ontop of [Presto](https://prestodb.io).

## Goals of Exalt SQL
* SQL is the main interface
* Easily supplement queries with for and while loops, if statements, etc.
* Keeps SQL queries simple

## Backends
Currently the only backend supported is [Presto](https://prestodb.io) but others such as Redshift or BigQuery are possible. 

## Running

1. Clone the repo
2. Edit `config.yml` with your Presto info
3. `bundle install`
4. `ruby app.rb`

## Examples:
Subquery
```
data = query("select * from tpch.sf1.customer limit 50")
data = query("select count(*) AS cnt FROM #{data.table}")
data.show()
```
