################################################################################
## 01.  Create meta datas
################################################################################
JOB_LAWD_INFO <- koscrap::legal_divisions %>% 
  filter(MAINTAIN %in% "Y") %>% 
  select(MEGA_CD, MEGA_NM, CTY_CD, CTY_NM) %>% 
  unique() %>% 
  mutate(DEAL_YM = NA)
  
################################################################################
## 02.  Export to DBMS
################################################################################
db_name <- here::here("data", "TRADE.sqlite")

con <- DBI::dbConnect(RSQLite::SQLite(), db_name)
DBI::dbWriteTable(con, "TB_JOB_LAWD_INFO", JOB_LAWD_INFO, overwrite = TRUE)
DBI::dbDisconnect(con)
