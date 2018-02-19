source("scrape_wdpr_url.R")

get_leg = lapply(df_by_dapil$url_leg, function(x) {
  read_html(paste0(wdpr_site,x))
}
)

profile = lapply(get_leg,function(x) {
  table_prof = x %>% html_nodes(".table-profile") %>% html_table()
  table_prof = table_prof[[1]]
  table_prof = table_prof[table_prof$X1!="",]
  table_prof = table_prof %>%  spread(X1,X2)
  table_prof
}
)

profiles = do.call(rbind,profile)
colnames(profiles) <- tolower(colnames(profiles))
colnames(profiles) <- gsub(" ","_",colnames(profiles))
profiles = cbind(profiles,df_by_dapil)
profiles = profiles %>% mutate(wikidpr_id = regmatches(url_leg, regexpr("[a-z0-9]+$",url_leg)))
write_csv(profiles,"wikidpr_profile_scrape.csv")

content_refs = mapply(function(x,y){
content = x %>% html_nodes(".main-content-profile")
content_id = y
content_link = content %>% html_nodes("a") %>% html_text()
content_url = content %>% html_nodes("a") %>% html_attr("href")
content_refs = data_frame(wikidpr_id = content_id,href = unlist(content_url),a = unlist(content_link))
content_refs$href = gsub("../../","http://wikidpr.org/",content_refs$href)
content_refs
},
get_leg,
profiles$wikidpr_id,
SIMPLIFY = F
)
content_refs = do.call(bind_rows,content_refs)
write_csv(content_refs,"wikidpr_refs_scrape.csv")


content_main = mapply(function(x,y){
  content = x %>% html_nodes(".main-content-profile")
  content_id = y
  content_main = content %>% html_text()
  content_main = data_frame(wikidpr_id = content_id,content_main = content_main)
},
get_leg,
profiles$wikidpr_id,
SIMPLIFY = F
)
content_main = do.call(bind_rows,content_main)
write_csv(content_main,"wikidpr_main_scrape.csv")
