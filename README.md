# osrm-slurm
Here are a list of slurm code and R functions to calculate proximity metrics using a high performance computer in a job based framework

## Route Engine Setup
Here are steps to get the route engine ready for use. 

(1) Download map data for study area into a folder called data_car if driving based metrics are needed. Each of the flowing profiles will need the data downloaded again in to their respective folders, i.e. data_car, data_foot, data_bicycle if needed. 
`wget http://download.geofabrik.de/europe/germany/berlin-latest.osm.pbf`
(2) Extract, partition and customize to a specific profiles; car, foot, bicycle separately. 
`singularity exec --bind "${PWD}/data_car:/data_car" osrm.sif osrm-extract -p /opt/car.lua /data_foot/us-latest.osm.pbf`
`singularity exec --bind "${PWD}/data_car:/data_car" osrm.sif osrm-partition -p /opt/car.lua /data_foot/us-latest.osrm`
`singularity exec --bind "${PWD}/data_car:/data_car" osrm.sif osrm-customize -p /opt/car.lua /data_foot/us-latest.osrm`
(3) Start engine using the following code in a slurm job environment as demonstrated in the 

`singularity exec --bind "${PWD}/e_car:/e_car" osrm.sif osrm-routed --algorithm mld /e_car/us-latest.osrm`

Now repeat the same pro


