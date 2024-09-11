# osrm-slurm
Here are a list of slurm code and R functions to calculate proximity metrics using a high performance computer (HPC) in a job based framework. This protocol is set up such that an osrm machine can have time to start up in the background when using a HPC to then take http requests from R code. 

## Route Engine Setup
Here are steps to get the route engine ready for use. 

* (1) Download map data for study area into a folder called data_car if driving based metrics are needed. Each of the flowing profiles will need the data downloaded again in to their respective folders, i.e. data_car, data_foot, data_bicycle if needed.

`wget http://download.geofabrik.de/europe/germany/berlin-latest.osm.pbf`

* (2) Extract, partition and customize to a specific profiles; car, foot, bicycle separately.


`singularity exec --bind "${PWD}/data_car:/data_car" osrm.sif osrm-extract -p /opt/car.lua /data_foot/us-latest.osm.pbf`
`singularity exec --bind "${PWD}/data_car:/data_car" osrm.sif osrm-partition -p /opt/car.lua /data_foot/us-latest.osrm`
`singularity exec --bind "${PWD}/data_car:/data_car" osrm.sif osrm-customize -p /opt/car.lua /data_foot/us-latest.osrm`


* (3) Start engine using the following code in a slurm job environment as demonstrated in the example_slurm.s file. 

`singularity exec --bind "${PWD}/data_car:/data_car" osrm.sif osrm-routed --algorithm mld /data_car/us-latest.osrm`

Now repeat steps 1 and 2 for changing folder names accordingly. The same folder should change in step 3 when running the job when using the slurm code. 

## Protocol

Now that map data and files are in the proper place, calculations should become routine. The proximity.R file is an example of R code used to calculate distance and duration between locations useing two data frames. Data frame one has the "from" coordinates, and data frame two has the "to" coordinates. Other arguments are specified and unique to the users dataset column names, and profile being used. 

A work flow might like like this

* (1) Use SCP to transfer data sets into a working directory
* (2) edit slurm code to match the names in the datasets and choose where to save the output
* (3) run the job and perform checks like making sure the terminal of the computer running the job is producing sensible results





