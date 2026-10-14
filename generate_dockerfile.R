# In the R console, with working directory set to the Shiny app folder (e.g., "myapp")
library(shiny2docker)

# Generate a Dockerfile for the Shiny app in the current directory
shiny2docker(path = ".")