## n 번째 word string 가져오기
get_nth_word <- function(string, pos = 1) {
  library(tidyverse)
  
  string %>% 
    purrr::map_chr({
      function(x)
        x %>% 
        stringr::str_split(x, pattern = " ", n = (pos + 1)) %>% 
        "["(pos) 
    })
}
# get_nth_word(c("서울특별시 중구 충무로4가", 
#                "서울특별시 중구 주자동"), pos = 2)

## n 번째 까지의 word string 가져오기
get_n_word <- function(string, n = 1) {
  library(tidyverse)
  
  string %>% 
    purrr::map_chr({
      function(x)
        x %>% 
        stringr::str_split(x, pattern = " ", n = (n + 1)) %>% 
        "["(1:n) %>% 
        stringr::str_c(collapse = " ")
    })
}
# get_n_word(c("서울특별시 중구 충무로4가", 
#              "서울특별시 중구 주자동"), n = 2)