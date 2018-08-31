# Ohio Precinct Shapefiles

> Georeferencing democracy, one precinct at a time.

![A map of Ohio's precincts](https://user-images.githubusercontent.com/8108892/44927973-59b0ff80-ad24-11e8-847b-2dd019356172.png "Ohio Precincts")

Katie Jolly (katiejolly6@gmail.com) | Ruth Buck | Katya Kelly

## Overview

Our job this summer has been to find out what type of data individual counties have on their precinct boundaries, and to work towards turning that into a unified shapefile of Ohio’s precincts. Some counties already have shapefiles, many do not. Most of the counties that do not have shapefiles have PDF or hardcopy precinct maps. The quality of these maps vary greatly. Some of the maps are rough boundaries drawn over highway maps in magic marker. Certain counties did not know where their precinct boundaries were at all. Below is a breakdown of tasks with the number of counties in each category.

- cleaning and merging shapefiles that were publicly accessible or were provided by counties (46)
- digitizing and merging the precinct maps provided by Ohio county officials, whether PDF (27) or paper (18)
- using Ohio's public voterfile to approximate boundaries for the ones that provided no maps (7 counties)

### Precincts from Digitizing

The first thing we have to do when we receive a precinct map in the form of a PDF (after converting it to a JPEG) is to georeference the image. we manually pick points on the JPEG that we can visually match to a point in an OpenStreetMap in QGIS (a GIS software). This allows us to give lat/long coordinates to the map image. The next step in the process is to digitize the boundaries shown in the georeferenced image. This means turning the boundaries in the image (which is a raster file) into a usable vector layer (shapefile). We aggregated 2010 census blocks to create the precinct shapes in the georeferenced images.

### Precincts from Voterfiles

For counties that did not have maps available of their precincts, we needed to find another way to estimate the boundaries. Ohio's voterfiles are public and they include both addresses and precinct designations for the registered voters in a county. We used a Census API to find 2010 census block GEOIDs for each voter. Using these GEOIDs we developed a methodology to draw approximate precincts from census blocks. First, we classify the census blocks that already have addresses assigned to them based on the precinct designations of those voters. Then using rook contiguity we can classify nearby blocks. We ran the algorithm multiple times in order to account for blocks that initially have no classified rook contiguity neighbors. While this is not perfect, we have found that it provides a workable approximation when tested on counties for which we already have shapefiles. When we tested this method against Monroe County's precincts (chosen for its relatively small voterfile), we found that only 2.9% of the area in the county was assigned to the wrong precinct and consider that to be within an acceptable margin of error.

### Joining Election Data

We found the data for 2016 election returns on the [Ohio secretary of state website](https://www.sos.state.oh.us/elections/election-results-and-data/2016-official-elections-results/). We then created a lookup table for precincts by manually matching precinct names and codes from the election data to the precinct information from the shapefiles we merged. After filtering out invalid precincts from the merged shapefiles, we performed a full join on both precinct and county names to obtain a complete shapefile with the election data attached.

### Collaborators

- Ethan Ackerman (digitizing)
- Emilia Alvarez (digitizing)
- Assaf Bar-Natan (data collection, digitizing)
- Eion Blanchard (data collection, digitizing)
- Ruth Buck (project leader)
- Sophia Caldera (digitizing)
- Eduardo Chavez-Heredia (digitizing)
- Coly Elhai (digitizing)
- Michelle Feng (digitizing)
- Natalia Hajlasz (digitizing)
- Mallory Harris (digitizing)
- Max Hully (digitizing)
- Amara Jaeger (digitizing)
- Katie Jolly (project leader)
- Katya Kelly (data collection, digitizing, voterfiles, joining)
- Samir Khan (digitizing)
- Zach Levitt (data collection, digitizing)
- Heather MacDougall <sup>1</sup> (voterfiles)
- Bryce McLaughlin (digitizing)
- Everett Meike (digitizing)
- Sloan Nietert (digitizing)
- Cara Nix (voterfiles)
- Nathaniel Poland (digitizing, voterfiles)
- Adriana Rogers (data collection, digitizing)
- Sarita Rosenstock (digitizing)
- Kaki Ryan (digitizing, voterfiles)
- Anna Schall (digitizing)
- Lily Wang (digitizing)
- Hannah Wheelen (data collection, digitizing, voterfiles, joining)
- Cory Wilson (digitizing)

<sup>1</sup> Not affiliated with VRDI

## About the shapefiles

###Metadata

Below are listed all of the variables in the attribute table for the precinct shapefile and a brief explanation of each one:

- `PREC_SHP`: name of the precinct as displayed in the merged shapefile
- `CNTY_NAME`: name of the county in which the precinct is located
- `CNTY_GEOID`: GEOID of the county in which the precinct is located
- `PREC_ELEC`: name of the precinct as displayed in the election data
- `PREC_CODE`: a three-letter code, unique only within each county, assigned to the precinct in the election data
- `PREC_MIS`: contains comma-separated names and codes of mismatched precincts between the shapefile and election data
- `REGION`: broader region of Ohio in which the precinct is located
- `MET_AREA`: metropolitan/media area in which the precinct is located
- `NUM_REG`: number of registered voters
- `TRNOUT`: number of people who actually voted
- `TRNOUT_PCT`: percentage of registered voters who actually voted
- `PRES_DEM`: number of votes for the Democratic presidential candidate
- `PRES_IND`: number of votes for the Independent presidential candidate
- `PRES_GRN`: number of votes for the Green Party presidential candidate
- `PRES_REP`: number of votes for the Republican presidential candidate

### Projection

The precinct shapefile is currently displayed using the NAD83(HARN) UTM zone 17N projection, which has an accuracy of better than 1m in the contiguous United States. We chose this projection because the extent of the data is only the state boundary of Ohio, which makes a localized projection such as a UTM zone a good choice.
