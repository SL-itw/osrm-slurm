#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=1
#SBATCH --time=08:00:00
#SBATCH --mem=100GB
#SBATCH --job-name=myTest
#SBATCH --output=log_%j.out

module unload gcc
module load r/4.0.3
module load singularity

NODE_IP=$(hostname -I | awk '{print $1}')
DIR='/gpfs/data/adhikarilab/osrm/'
data1=pharmacies.csv
data2=centroids.csv
start_lat=latitude
start_lng=longitude
end_lat=location.lat
end_lng=location.lng
outputname=centroid_pharm_proximity
port=5000
profile=driving

Rscript proximity.R $NODE_IP $DIR $data1 $start_lat $start_lng $end_lat $end_lng $profile $outputname $port $data2  &

singularity exec --bind "${PWD}/e_car:/e_car" osrm.sif osrm-routed --algorithm mld /e_car/us-latest.osrm
