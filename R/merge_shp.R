## this script merges individual county shapefiles (from counties.zip) into a statewide shapefile, makes all polygons valid according to GEOS, and merges 2016 presidential returns at the precinct level


library(tidyverse)
library(plyr)
library(sf)
library(lwgeom)
library(janitor)

shps <- list.files(pattern = ".shp$", recursive = TRUE) # from counties.zip

for (i in 1:length(shps)){
  assign(gsub("/.*","",shps[i]), sf::st_read(shps[i]) %>% sf::st_transform(4326) %>% sf::st_cast("MULTIPOLYGON") %>% mutate(COUNTY = gsub("/.*","",shps[i])) %>% st_zm())
} # all read in as multipolygons in WGS84 (epsg:4326)

rm(i)
rm(shps)

## fixing some counties that had inconsistencies in variable names

athens <- athens %>%
  dplyr::rename(PRECINCT = NAME)

hocking <- hocking %>%
  dplyr::rename(PRECINCT)

logan <- logan %>%
  dplyr::rename(PRECINCT = NAME)

putnam <- putnam %>%
  dplyr::rename(PRECINCT = Code)

mercer <- mercer %>%
  dplyr::rename(PRECINCT = MAPNUM)


dfs = sapply(.GlobalEnv, is.data.frame) # all the dataframes in the global environment. Should be 88!!!!!


merged <- do.call(rbind.fill, mget(names(dfs)[dfs])) # force merge them all together

merged_sf <- merged %>%
  select(PRECINCT, COUNTY, geometry) %>%
  st_as_sf() # make them a spatial dataframe (sf)



validity_check <- st_is_valid(merged_sf) # are these valid?

sum(validity_check == FALSE, na.rm = TRUE) # how many invalid

merged_sf_valid <- st_make_valid(merged_sf) %>% # make them valid according to GEOS
  st_cast("MULTIPOLYGON") # avoid type errors down the road by casting everything to multipolygon



sum(st_is_valid(merged_sf_valid) == FALSE) # make sure validity fix worked




# ggplot(merged_sf_valid) +
#   geom_sf() +
#   ggthemes::theme_map() # can plot to see how it works

precinct_lookup <- read_csv("https://docs.google.com/spreadsheets/d/e/2PACX-1vQDv5XM3nt8HEQ9m9UgxSz-XxAUP9SFxlM_qhwKgG-EZ3oDwCjAP1574nBYrNvsFUzGRkLkZvxFxy1A/pub?gid=0&single=true&output=csv") # lookup table between shapefiles and election returns

precinct_lookup <- precinct_lookup %>%
  mutate(COUNTYNAME10 = tolower(gsub(" ", "", COUNTYNAME10)))


joined_shp <- merged_sf_valid %>%
  full_join(precinct_lookup, by = c("PRECINCT" = "PRECINCT_shp", "COUNTY" = "COUNTYNAME10")) 



# group by precincts and counties in order to simplify precinct boundaries

# library(patchwork)
# library(randomcoloR)
# 
# palette <- randomColor(167)
# 
# plot1 <- clermont %>%
#   ggplot() +
#   geom_sf(aes(fill = PRECINCT)) +
#   scale_fill_manual(values = palette) +
#   ggthemes::theme_map() +
#   theme(legend.position = "none")
# 
# plot2 <- clermont_experiment %>%
#   ggplot() +
#   geom_sf(aes(fill = PRECINCT)) +
#   scale_fill_manual(values = palette) +
#   ggthemes::theme_map() +
#   theme(legend.position = "none")
# 
# plot1 + plot2 

precincts_simplified <- joined_shp %>%
  select(-global_id) %>%
  dplyr::group_by_at(vars(-geometry)) %>%
  dplyr::summarise(n_pieces = n()) # combine pieces of the same precinct and tell us how many pieces there were

sum(st_is_valid(precincts_simplified) == FALSE)

election_results <- read_csv("https://docs.google.com/spreadsheets/d/e/2PACX-1vSYJZ9ZS1u54w_NE9OH_uKBYYQ-t_e4D57TrUaNViqynahz07UxJOs3q7u2-nWb87oIk23lGzseGWPn/pub?gid=0&single=true&output=csv") %>%
  clean_names() %>%
  mutate(turnout_percentage = str_replace(turnout_percentage, "%", "")) # election returns from 2016 presidential election

election_results <- election_results %>%
  mutate(turnout_percentage = as.numeric(turnout_percentage),
         county_to_join = tolower(gsub(" ", "", county_name)))


precincts_results <- precincts_simplified %>%
  full_join(election_results, by = c("PRECINCT_election_results" = "precinct_name", "COUNTY" = "county_to_join")) # merge shapefile with election returns

ggplot(precincts_results) +
  geom_sf(aes(fill = turnout_percentage), color = "white") +
  ggthemes::theme_map() +
  scale_fill_gradient(low = "#e0ecf4", high = "#6e016b", na.value = "#848484") # admire how nice it looks :)
