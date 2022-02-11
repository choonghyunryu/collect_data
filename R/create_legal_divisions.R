################################################################################
## 법정동 명칭 데이터 적재하기
## 데이터 Source : https://www.code.go.kr/stdcodesrch/codeAllDownloadL.do
## 데이터 파일 : 법정동코드 전체자료.txt
################################################################################
library(tidyverse)

################################################################################
## 01. 데이터 정제하기
################################################################################
fname <- here::here("collect_data", "data", "법정동코드 전체자료.txt")
legal_divisions <- fname %>% 
  read.table(sep = "\t", header = TRUE, fileEncoding = "cp949",
             col.names = c("DIVISION_ID", "DIVISION_NM", "MAINTAIN")) %>% 
  mutate(DIVISION_ID = format(DIVISION_ID, scientific = FALSE, trim = TRUE)) %>% 
  mutate(MAINTAIN = case_when(
    MAINTAIN == "존재" ~ "Y",
    MAINTAIN == "폐지" ~ "N")
  ) %>% 
  mutate(MEGA_CD = substr(DIVISION_ID, 1, 2),
         MEGA_NM = stringr::str_extract(DIVISION_NM, "^[\\w]+")) %>% 
  mutate(CTY_CD = substr(DIVISION_ID, 1, 5),
         CTY_NM = stringr::str_extract(DIVISION_NM, " [\\w]+") %>% 
           stringr::str_remove("\\s")) %>% 
  mutate(ADMI_CD = substr(DIVISION_ID, 1, 8),
         ADMI_NM = stringr::str_remove(DIVISION_NM, "^[\\w]+ [\\w]+ ")) %>% 
  filter(!stringr::str_detect(DIVISION_ID, "000000$"))


################################################################################
## 02. 데이터 저장하기
################################################################################
db_name <- here::here("collect_data", "data", "GISDB.sqlite")

con <- DBI::dbConnect(RSQLite::SQLite(), db_name)
DBI::dbWriteTable(con, "TB_LEGAL_DIVISIONS", legal_divisions, overwrite = TRUE)
DBI::dbDisconnect(con)

