

## Long Term SST extraction

#```{r, echo = T, eval = F}
# Include R code here
# all year
years="ersst"

# a year
#years=".2016"

# which data
setwd("C:/2_ersst/datafiles_v4")
setwd("C:/2_ersst/datafiles_v5")


# NES standard bounded by 34-46N and 78-62W
minlon= -78; maxlon= -62; minlat= 34; maxlat= 46
dataoutfile="C:/2_ersst/nes_std_area_v5.csv"

#  DELETE ONLY FILE WILL APPEND AND DOUBLE DATA
file.remove(dataoutfile)

##################################################  END SET

# LABRODOR SEA  
#minlon= -66; #maxlon= -44; #minlat= 50; #maxlat= 70
#dataoutfile="C:/2_ersst/lab_sea.csv"

# New eel
#minlon= -80; maxlon= -40; minlat= 20; maxlat= 40
#dataoutfile="C:/2_ersst/new eel.csv"

# G of Mex
#minlon= -98; maxlon= -82; minlat= 18; maxlat= 30
#dataoutfile="C:/2_ersst/gomex_area.csv"

# USSE INCLUDING  28-36N and 80-76W not bounding
#minlon= -80; #maxlon= -76; #minlat= 28; #maxlat= 36
#dataoutfile="C:/2_ersst/usse_area.csv"

# GSL standard bounded by 34-46N and 78-62W
#minlon= -68; maxlon= -60; minlat= 46; maxlat= 48
#dataoutfile="C:/2_ersst/gsl.csv"

# PACIFIC area bounded by 10-30N and 166-146W
#minlon= -166; #maxlon= -146; #minlat= 10; #maxlat= 30
#dataoutfile="C:/1_analyses/ersst/pac_islands_area.csv"

# Baltic area bounded by 52-66N and 14-28E
#minlon= 14; #maxlon= 28; #minlat= 52; #maxlat= 66
#dataoutfile="C:/2_ersst/baltic area.csv"

# North Atlantic Area bounded by 30-70N and 80W-20E
#minlon= -80; #maxlon= -2; #minlat= 30; #maxlat= 70
#dataoutfile="C:/2_ersst/na area1.csv"
# and ...
#minlon= 0; #maxlon= 20; #minlat= 30; #maxlat= 70
#dataoutfile="C:/1_analyses/ersst/na area2.csv"

# NorthEAST Atlantic Area bounded by 55-70N and 10W-20E
#minlon= -10; #maxlon= -2; #minlat= 56; #maxlat= 70
#dataoutfile="C:/1_analyses/ersst/ne atl 1.csv"
# and ...
#minlon= 0; #maxlon= 10; #minlat= 56; #maxlat= 70
#dataoutfile="C:/1_analyses/ersst/ne atl 2.csv"

# Pacific steelhead
#minlon= -160; #maxlon= -122; #minlat= 40; #maxlat= 62
#dataoutfile="C:/1_analyses/ersst/pac sh.csv"

#North Pacific in two parts
#1
#minlon= -180; #maxlon= -120; #minlat= 30; #maxlat= 72
#dataoutfile="C:/1_analyses/ersst/n_pac_1.csv"
#2
#minlon= 120; #maxlon= 178; #minlat= 30; #maxlat= 72
#dataoutfile="C:/1_analyses/ersst/n_pac_2.csv"

# North Atlantic Area bounded by 20-70N and 100W-30E
#minlon= -100; #maxlon= -2; #minlat= 20; #maxlat= 70
#dataoutfile="C:/1_analyses/ersst/na area1.csv"
# and ...
#minlon= 0; #maxlon= 30; #minlat= 20; #maxlat= 70
#dataoutfile="C:/1_analyses/ersst/na area2.csv"









# constants for area
R <- 6371 # Earth mean radius [km]
dheight =  222

#library(ncdf)
library(ncdf4)

# ERSST data  
# lon goes from 0E to 358E with lon at center of box
# lat goes from 88S to 88N with lat at center of box

# start with lon based on degrees lonew
# array  1  2  ...  90    91    92  ...  180
# lon    0  2  ... 178   180   182  ...  358
# lonew  0  2  ... 178  -180  -178  ...   -2
# star with lat + deg N, - deg S
# array    1  ...  45  ...  89
# lon    -88  ...   0  ...  88

# -> -> -> TO KEEP THINGS SIMPLE, RETRIEVALS CAN'T BE CONTINUOUS FROM - LONS TO + LONs
#          have to extract from -180W to -2W separately from 0E to 180E

# -> -> -> OUTPUT APPENDS SO NEED TO DELETE FILE IF ALREADY EXISTS

# -> -> -> USE APPROPRIATE lon lat and outfile block:






# set lon limits in array units
if ( minlon < 0){ 
  arrayminlon=(minlon+360)/2+1
} else { 
  arrayminlon=minlon/2+1 
} 

if ( maxlon < 0){ 
  arraymaxlon=(maxlon+360)/2+1
} else { 
  arraymaxlon=maxlon/2+1 
} 

# set lat limits in array units
arrayminlat=minlat/2+45
arraymaxlat=maxlat/2+45


filelist=list.files(pattern=years)

numfiles=length(filelist)

for (filenum in 1:numfiles){
  
  #  ersst = open.ncdf(filelist[filenum]) 
  ersst = nc_open(filelist[filenum]) 
  print(filelist[filenum])
  
  #  sst = get.var.ncdf( ersst, "sst") 
  sst <- ncvar_get(ersst,"sst" )
  
  year=as.numeric(substr(filelist[filenum],10,13))
  month=as.numeric(substr(filelist[filenum],14,15))
  
  for (arrlons in arrayminlon:arraymaxlon){
    for (arrlats in arrayminlat:arraymaxlat){
      
      
      if ( arrlons < 91){ 
        regenlon=(arrlons-1)*2
      } else { 
        regenlon=(arrlons-1)*2-360
      } 
      
      
      regenlat=(arrlats-45)*2
      
      long1=regenlon-1 *pi/180
      lat1=regenlat-1 *pi/180
      long2=regenlon+1 *pi/180
      lat2=regenlat-1 *pi/180
      dwidth1 <- acos(sin(lat1)*sin(lat2) + cos(lat1)*cos(lat2) * cos(long2-long1)) * R
      long1=regenlon-1 *pi/180
      lat1=regenlat+1 *pi/180
      long2=regenlon+1 *pi/180
      lat2=regenlat+1 *pi/180
      dwidth2 <- acos(sin(lat1)*sin(lat2) + cos(lat1)*cos(lat2) * cos(long2-long1)) * R
      area=((dwidth1 + dwidth1)/2) * dheight
      
      dataline <- matrix(c(year, month, regenlon, regenlat,
                           round(sst[arrlons,arrlats],digits=2),area),1,6)
      
      
      if(is.finite(sst[arrlons,arrlats])) {
        write.table(dataline,file=dataoutfile,sep=",",row.name=F,col.names=F,append=TRUE)   
      }
      
    }
  }
  
  #    close.ncdf(ersst) 
  nc_close(ersst)
  
}


#```