################################################################################
## 01. Prepare
################################################################################

cat(glue::glue("Start Job - {lubridate::now()}\n\n"))

##==============================================================================
## 01.01. Load library
##==============================================================================
library("dbplyr", warn.conflicts = FALSE)
library("dplyr", warn.conflicts = FALSE)

##==============================================================================
## 01.02. Set parameters
##==============================================================================
## Your authorize key
auth_key <- "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

DEAL_YMD <- "20060101" %>%
  as.Date(format = "%Y%m%d") %>%
  seq(to = as.Date("20211201", format = "%Y%m%d"),  by = "month") %>%
  format("%Y%m")

##==============================================================================
## 01.03. Connect DBMS
##==============================================================================
#db_name <- here::here("data", "TRADE.sqlite")

## Your directory 
db_name <- "/data/TRADE.sqlite"
con <- DBI::dbConnect(RSQLite::SQLite(), db_name)


################################################################################
## 02. Scrap data from REST API server
################################################################################
##==============================================================================
## 02.01. 대상 지역코드 선정
##==============================================================================
LAWD_CD <- con %>%
  tbl("TB_JOB_LAWD_INFO") %>%
  filter(is.na(DEAL_YM)) %>%
  filter(row_number() <= 4) %>%
  select(CTY_CD) %>%
  pull()

##==============================================================================
## 02.02. 작업 대상 파라미터 선정
##==============================================================================
conditions <- tidyr::expand_grid(DEAL_YMD, LAWD_CD)


##==============================================================================
## 02.03. Scrap from 국토교통부_아파트매매 실거래 상세 자료 REST server
##==============================================================================
trade_list <- NROW(conditions) %>%
  seq() %>%
  purrr::map_df({
    function(x) {
      koscrap::trade_apt(auth_key,
                LAWD_CD = conditions$LAWD_CD[x],
                DEAL_YMD = conditions$DEAL_YMD[x],
                chunk = 1000,
                do_done = TRUE
      )
    }
  }) %>%
  mutate(CREATE_DT = as.POSIXlt(date(), format = "%a %b %d %H:%M:%S %Y")) %>%
  mutate(CREATE_DT = as.character(CREATE_DT))

cat(glue::glue("{NROW(trade_list)} cases of data were collected.\n\n"))

##==============================================================================
## 02.04. 작업 정보 업데이트
##==============================================================================
TB_JOB_LAWD_INFO <- con %>%
  tbl("TB_JOB_LAWD_INFO") %>%
  left_join(
    trade_list %>%
      mutate(DEAL_DATE = substr(DEAL_DATE, 1, 7)) %>%
      mutate(DEAL_DATE = stringr::str_remove(DEAL_DATE, "-")) %>%
      group_by(LAWD_CD) %>%
      summarise(DEAL_DATE = max(DEAL_DATE)),
    by = c("CTY_CD" = "LAWD_CD"),
    copy = TRUE
  ) %>%
  mutate(DEAL_YM = ifelse(is.na(DEAL_YM), DEAL_DATE, DEAL_YM)) %>%
  select(-DEAL_DATE) %>%
  collect()

##==============================================================================
## 02.05. 작업 정보와 수집 데이터 DB 저장
##==============================================================================
DBI::dbWriteTable(con, "TB_TRADE_APT", trade_list, append = TRUE)
DBI::dbWriteTable(con, "TB_JOB_LAWD_INFO", TB_JOB_LAWD_INFO, overwrite = TRUE)
DBI::dbDisconnect(con)

cat(glue::glue("Finsh Job - {lubridate::now()}\n\n"))

# con %>%
#   tbl("TB_TRADE_APT") %>%
#   mutate(DEAL_DATE = substr(DEAL_DATE, 1, 7)) %>%
#   group_by(LAWD_CD, DEAL_DATE) %>%
#   tally() %>%
#   arrange(desc(n))

