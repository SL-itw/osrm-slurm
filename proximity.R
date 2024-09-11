args = commandArgs(trailingOnly=TRUE) # allows R to accept trailing arguments
# Argument --------------------------
# args[1] -> ip address of job
# args[2] -> defines where to save the resulting dataset
# args[3] -> first dataset of coordinates (from)
# args[4] -> variable name of the starting latitude
# args[5] -> variable name of the starting longitude
# args[6] -> variable name of the ending latitude
# args[7] -> variable name of the ending longitude
# args[8] -> osrm profile i.e. driving, foot, bicycle  
# args[9] -> where to save file
# args[10] -> osrm port that it is launched on  
# args[11] -> second dataset of coordinates (to)

ip = args[1]
DIR = args[2]
data_file_path1 = args[3]
start_lat = args[4]
start_lng = args[5]
end_lat = args[6]
end_lng = args[7]
profile = args[8]
output = args[9]
port = args[10]
data_file_path2 = args[11]

# Reading in data and pkgs----------------------

Packages <- c("tidyverse","httr")

invisible(lapply(Packages, library, character.only = TRUE))

# Defining functions ---------------------
sng_route <- function(i,ip = ip,
             meters_to_miles = 1.60934*1000, # converts meters to miles
             sec_to_min = 60, #converst seconds to minutes
             lat1,
             lng1,
             lat2,
             lng2,
             profile,
             port){



          url = paste0("http://",ip,":",port,"/route/v1/",profile,"/",
                lng1[i], ",", lat1[i], ";",
                lng2[i], ",", lat2[i],
                "?overview=false&steps=true")

          response = GET(url)

          if (status_code(response) == 200) {
            route = content(response, "parsed")
            distance = route$routes[[1]]$distance/meters_to_miles
            duration = route$routes[[1]]$duration/sec_to_min
          } else {
            distance = "error: check data"
          }

list(distance, duration)

}


proximity <- function(data, ip = ip,
                      meters_to_miles = 1.60934*1000, # converts meters to miles
                      sec_to_min = 60,
                      lat1,
                      lng1,
                      lat2,
                      lng2,
                      profile,
                      port){

  n_loop <- nrow(data)
  route_out <- vector(length = n_loop)

for (i in 1:n_loop) {

    try(
      route_out[i] <-  sng_route(i =i ,ip = ip,
                     meters_to_miles = meters_to_miles,
                     sec_to_min = sec_to_min,
                     lat1 = lat1,
                     lng1 = lng1,
                     lat2 = lat2,
                     lng2 = lng2,
                     profile = profile,
                     port = port))

}
  data %>% mutate(distance = map_dbl(route_out,1), duration = map_dbl(route_out,2))


}

# merging datasets -------------------
data1 = vroom::vroom(paste0(data_file_path1))
data2 = vroom::vroom(paste0(data_file_path2))

data = merge(data1,data2,by = NULL)


lng1 = data %>% pull(!!sym(start_lng))
lat1 = data %>% pull(!!sym(start_lat))
lng2 = data %>% pull(!!sym(end_lng))
lat2 = data %>% pull(!!sym(end_lat))

# Check server ----------------
    # Define the coordinates of the start and end points
    start_point <- c(lon = -73.9877376096568, lat = 40.74975622750664)
    end_point <- c(lon = -73.93992875654641, lat = 40.70528988083516)

    # Construct the request URL
    url <- paste0("http://",ip,":",port,"/route/v1/",profile,"/",
                  start_point["lon"], ",", start_point["lat"], ";",
                  end_point["lon"], ",", end_point["lat"],
                  "?overview=false&steps=true")

    server_run_check <- RCurl::url.exists(url)

    while(server_run_check == F){
      Sys.sleep(30)
      server_run_check <- RCurl::url.exists(url)
    }

    # Send the GET request to the OSRM server
    response <- GET(url)

    if (status_code(response) == 200) {
      route = content(response, "parsed")
            route$routes[[1]]$distance
    } else {
      print("error: check data")
    }

# Calculate proximity -----------------

if (status_code(response) == 200) {

  data = proximity(data, ip, lat1 = lat1, lng1 = lng1, lat2 = lat2, lng2 = lng2, profile = profile, port = port)

  write.csv(data, paste0(DIR,output,".csv"))
} else {
  print("error: check script or data")
}

