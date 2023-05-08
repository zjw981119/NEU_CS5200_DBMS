# Author: Zhang, Jinwei
# Course: CS5200
# Term: 2023 Spring
# Date: 2023-04-18

# Part 2 (40 pts) Create Star/Snowflake Schema

# Part 2.2
# create connection to MySQL db
library(DBI)
library(RMySQL)

dbcon2 <- dbConnect(MySQL(), user = 'root', password = 'root',
                    dbname = 'xml_mysql', host = 'localhost', port = 3306)
# update setting to enable batch save data with dbWriteTable()
dbSendQuery(dbcon2, "SET GLOBAL local_infile = true")

# Part 2.3
# drop author_fact table if exists
drop_table_sql <- "DROP TABLE IF EXISTS author_fact"
dbExecute(dbcon2, drop_table_sql)

# create author_fact table
create_table_sql <- "CREATE TABLE author_fact (
                        au_id INTEGER PRIMARY KEY,
                        last_name TEXT,
                        first_name TEXT,
                        initials TEXT,
                        suffix TEXT,
                        article_count INTEGER,
                        coauthor_count INTEGER
                     )"
dbExecute(dbcon2, create_table_sql)

# use sql statement to get the aggregated data for author fact table
# some authors may not have coauthors, use left join to handle this case
sql_query <- 
  "
  SELECT 
    authors.au_id,
    authors.last_name,
    authors.first_name,
    authors.initials,
    authors.suffix,
    COUNT(DISTINCT articles.ar_id) AS article_count,
    COUNT(DISTINCT coauths.au_id) AS coauthor_count
  FROM authors
  LEFT JOIN author2article ON authors.au_id = author2article.au_id
  LEFT JOIN articles ON author2article.ar_id = articles.ar_id
  LEFT JOIN author2article AS coauths ON articles.ar_id = coauths.ar_id AND authors.au_id != coauths.au_id
  GROUP BY authors.au_id
"

# get the data from sqlite db
author_fact <- dbGetQuery(dbcon, sql_query)
author_fact

# write author_fact dataframe to MySQL db
# by default, R assigns row_names to data frames starting from first row
# and dbWriteTable() will try to write the row names as a separate column in the table
# to prevent it, set row.names = FALSE
dbWriteTable(dbcon2, "author_fact", author_fact, append = T, row.names = FALSE)

# Part 2.4
# drop journal_fact table if exists
drop_table_sql <- "DROP TABLE IF EXISTS journal_fact"
dbExecute(dbcon2, drop_table_sql)

# drop journal_dim table if exists
drop_table_sql <- "DROP TABLE IF EXISTS journal_dim"
dbExecute(dbcon2, drop_table_sql)

# create star schema for journal fact table
# create journal_dim table
# in MySQL, we need to specify the maximum length for a text field when it's a key(primary/foreign).
create_table_sql <- "CREATE TABLE journal_dim (
                        issn VARCHAR(20) PRIMARY KEY,
                        issn_type TEXT,
                        iso_abbreviation TEXT
                     )"
dbExecute(dbcon2, create_table_sql)

# create journal_fact table
create_table_sql <- "CREATE TABLE journal_fact (
                        fact_id INTEGER PRIMARY KEY AUTO_INCREMENT,
                        issn VARCHAR(20),
                        title TEXT,
                        year INTEGER,
                        quarter INTEGER,
                        month INTEGER,
                        article_count INTEGER,
                        FOREIGN KEY(issn) REFERENCES journal_dim(issn)
                     )"
dbExecute(dbcon2, create_table_sql)

# populate data for journal_dim table
sql_query <- "SELECT issn, issn_type, iso_abbreviation FROM journals"
# get the data from sqlite db
journal_dim <- dbGetQuery(dbcon, sql_query)
journal_dim

# write journal_dim dataframe to MySQL db
dbWriteTable(dbcon2, "journal_dim", journal_dim, append = T, row.names = FALSE)

# populate data for journal_fact table
sql_query <- 
  "
SELECT 
  j.issn,
  j.title,
  CAST(strftime('%Y', a.pub_date) AS INTEGER) AS year,
  ((strftime('%m', a.pub_date) - 1) / 3) + 1 AS quarter,
  CAST(strftime('%m', a.pub_date) AS INTEGER) AS month,
  COUNT(*) AS article_count
FROM articles a
JOIN journals j ON a.issn = j.issn
GROUP BY j.issn, year, quarter, month
"

# get the data from sqlite db
journal_fact <- dbGetQuery(dbcon, sql_query)
journal_fact

# write journal_fact dataframe to MySQL db
dbWriteTable(dbcon2, "journal_fact", journal_fact, append = T, row.names = FALSE)
