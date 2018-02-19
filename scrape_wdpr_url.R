source("req.R")

wdpr_site = "http://wikidpr.org/"
wdpr_site_read = read_html(wdpr_site)

dd_options = wdpr_site_read %>% 
  html_nodes("#search-provinsi") %>% 
  html_nodes("option") %>%
  html_attr("value")
dd_options = gsub(" ","%20",dd_options)
dd_options = na.omit(dd_options)

get_by_dapil = lapply(dd_options,function(x) {
  dapil = read_html(paste0(wdpr_site,"/dapil?id=",x))
  dapil_name = dapil %>% html_nodes("#anggota-wrapper .anggota-name")
  dapil_name
}
)

nama_leg = sapply(get_by_dapil, html_text)
url_leg = sapply(get_by_dapil, function(x) {
  x %>% html_nodes("a") %>% html_attr("href")
}
)
df_by_dapil = data_frame(nama_leg = unlist(nama_leg),url_leg = unlist(url_leg))
df_by_dapil = df_by_dapil[!duplicated(df_by_dapil),]
