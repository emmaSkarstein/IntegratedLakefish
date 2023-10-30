# IntegratedLakefish
Code and reproducible research files for "The Point Process Framework for Integrated Modelling of Biodiversity Data", by Kwaku Peprah Adjei, Philip Mostert, Jorge Sicacha Parada, Emma Skarstein and Robert B. O'Hara. Article available as preprint.

## Getting started
Follow these steps to reproduce our results! (note: the model takes around 3 hours to run)

1. **Download lake polygons for Norway:** Go to https://bird.unit.no/resources/9b27e8f0-55dd-442c-be73-26781dad94c8/content (click on "Innhold"-tab at the bottom of the page to download only selected sets of lakes). The object name should be Norwegian_lakes.rds, and it should be placed in a "data" folder on the top level (the same level as the R-project).
2. **Get species observations:** Run the file `data_preparation.R` to download the citizen science data from GBIF and clean it along with the survey data.
3. **Fit the species distribution model:** Run the file `integrated_lakefish.rmd` to fit the model.
