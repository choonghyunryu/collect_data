#!/bin/bash

# 한글 환경 설정
export LANG=ko_KR.UTF-8

# 오늘 날짜
YMD=`date "+%Y-%m-%d"`

# 작업 디렉토리
## Your directory
work_dir='/collect_data'

# 로그 파일경로 및 이름
log_file="$work_dir"/log/trade_apt_"$YMD".log

/usr/local/bin/Rscript "$work_dir"/R/02_import_trade_apt.R > "$log_file"
