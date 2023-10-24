#-------------------------------------------------------------------------------
# Supporting information for 
#  'The Point Process Framework for Integrated Modelling of Biodiversity Data'
# Downloading and preparing the data
#
# Kwaku Peprah Adjei, Philip Mostert, Jorge Sicacha Parada, Emma Skarstein, 
# Robert B. O'Hara
#
# Code by Emma Skarstein, October 2023
#-------------------------------------------------------------------------------

library(rgbif)
library(maps)
library(stringr)

source("R/match_to_lake.R")

# Polygons of Norwegian lakes ----
# The lake polygons need to be downloaded from here:  
# https://bird.unit.no/resources/9b27e8f0-55dd-442c-be73-26781dad94c8/content, 
# click on “Innhold”-tab at the bottom of the page and select "Norwegian_lakes.rds".


lakes <- readRDS("data/Norwegian_lakes.rds")



# Citizen science observations from the Norwegian Species Observation Service ----

# The citizen science observations can be downloaded using the `rgbif` package. 
# We specify the species, country and dataset key to get the relevant subset of observations.

myspecies <- c("Salvelinus alpinus", "Esox lucius", "Salmo trutta", "Perca fluviatilis")

artsobs_raw <- rgbif::occ_data(scientificName = myspecies, 
                               hasCoordinate = TRUE, 
                               limit = 20000, 
                               country = "NO", # Only observations in Norway
                               year = "1990,2023",
                               # Norwegian Species Observation Service: 
                               datasetKey = "b124e1e0-4755-430f-9eab-894f25a9b59c")

artsobs_data_list <- vector("list", length(myspecies))
names(artsobs_data_list) <- myspecies
for(s in myspecies){
  sub_data <- artsobs_raw[[s]]$data
  artsobs_data_list[[s]] <- data.frame(species = s, sub_data)
}

artsobs_raw_joined <- bind_rows(artsobs_data_list)

artsobs_matched <- match_to_lake(artsobs_raw_joined, lakes, max_dist_from_lake = 50)[[1]] 

artsobs <- artsobs_matched %>% 
  mutate(occurrenceStatus = ifelse(occurrenceStatus == "PRESENT", 1, 0)) %>% 
  st_set_geometry(NULL) %>% 
  mutate(species = sub(" .*", "", str_replace(species, " ", "_"))) %>% 
  dplyr::select(decimalLongitude, decimalLatitude, species)


# Survey data ----

# The survey data is downloaded from here: 
# https://gbif.vm.ntnu.no/ipt/resource?r=fish_status_survey_of_nordic_lakes. 
# The downloaded file contains two data sets, one with occurrences and one with events, so we need to merge these. 
# Name the folder that contains the downloaded data "survey_raw".

# Merging occurence and events for the survey data:
occ <- read.table("data/survey_raw/occurrence.txt", 
                  header = TRUE, sep = "\t", quote = "\"'", fill = FALSE) %>% 
  mutate(species = gsub("verbatim scientific name: ", "", taxonRemarks)) %>% 
  filter(species %in% myspecies)

event <- read.table("data/survey_raw/event.txt", 
                    header = TRUE, sep = "\t", quote = "\"'", fill = FALSE)

survey_raw <- merge(occ, event, by = "eventID")

survey_list <- match_to_lake(survey_raw, lakes, max_dist_from_lake = 50)


# Note that around 80% of the observations will be removed, that is because there 
# are observations made in Sweden and Finland as well, which we won't be using.

survey_matched <- survey_list[[1]]
survey <- survey_matched %>% 
  mutate(occurrenceStatus = ifelse(occurrenceStatus == "present", 1, 0)) %>% 
    st_set_geometry(NULL) %>% 
  mutate(species = str_replace(species, " ", "_")) %>% 
  dplyr::select(occurrenceStatus, decimalLongitude, decimalLatitude, species)



## Saving the data ----

saveRDS(survey, "data/survey_clean.rds")
saveRDS(artsobs, "data/artsobs_clean.rds")



