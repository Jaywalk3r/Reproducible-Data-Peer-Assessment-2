setwd( "~/Documents/School/Coursera/Data Science Specialization/Reproducible Research/Project 2")

library( dplyr)



filePath = "./repdata-data-StormData.csv.bz2"

# If compressed file does not exist in working directory, a check is made for
#	the uncompressed file. The compressed file is preferred for loading into R,
#	under the (perhaps unjustified) assumption that reading a larger file from
#	the disk is more time consuming than the CPU decompressing the file.
if (! file.exists( "repdata-data-StormData.csv.bz2")) {
	
	if (file.exists( "repdata-data-StormData.csv")) {

		filePath = "./repdata-data-StormData.csv"
		
	} else {
	
		fileUrl = "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
		
		download.file( fileUrl, filePath, method = "curl")
	
	}
	
} 

# Make sure documentation is available
if (! file.exists( "repdata-peer2_doc-pd01016005curr.pdf")) {
	
	fileUrl = "https://d396qusza40orc.cloudfront.net/repdata%2Fpeer2_doc%2Fpd01016005curr.pdf"
	
	filePath = "./repdata-peer2_doc-pd01016005curr.pdf"
	
	download.file( fileUrl, filePath, method = "curl")
	
}

if (! file.exists( "repdata-peer2_doc-NCDC Storm Events-FAQ Page.pdf")) {
	
	fileUrl = "https://d396qusza40orc.cloudfront.net/repdata%2Fpeer2_doc%2FNCDC%20Storm%20Events-FAQ%20Page.pdf"
	
	filePath = "./repdata-peer2_doc-NCDC Storm Events-FAQ Page.pdf"
	
	download.file( fileUrl, filePath, method = "curl")
	
}

##################################################
#												 #
#      Uncomment next lines after completion     #
#												 #
##################################################

# StormData.raw = read.csv( filePath)

# save( StormData.raw, file = "./repdata-data-StormData.Rdata")



# clean up workspace

fileUrl = ""
	# ensure fileUrl exists to avoid warning message after next line

rm( filePath, fileUrl)




# Remove or comment out in final version
load( "~/Documents/School/Coursera/Data Science Specialization/Reproducible Research/Project 2/repdata-data-StormData.Rdata")

# Take a look at the data frame structure
str( StormData.raw)

# "$ EVTYPE    : Factor w/ 985 levels "

# "Table 1. Storm Data Event Table", from page 6 of
#	repdata-peer2_doc-pd01016005curr.pdf documentation indicates only 48
#	distinct event types. We would like a vector containing each of the 48
#	correct event types.




#
# Extracting multi-word entries from tables in PDF files is not a job for which
#	R is ideally suited. We use multi-platform open source Tabula version 1.01,
#	available from http://tabula.nerdpower.org/. The software is easy and
#	intuitive, but we provide detailed instructions in the interest of
#	reproducibility.
#
# Procedures are for Tabula running on Mac OS X 10.11.3 (El Capitan), using
#	Finder file manager application, with default browser set to Safari version
#	9.0.3. All mouse clicks are single left clicks unless otherwise specified.

#
# Assuming Tabula is installed (in /Applications directory, by default): 
#
#	 1. Open a Finder window and navigate to the /Applications directory.
#
# 	 2. Double click on Tabula name or icon. A Safari tab opens to
#	    http://127.0.0.1:8080. It looks like a Web page.
# 
#	 3. Click on the blue "Browse…" button underneath the "Import one or more
#	    PDFs" text and to the left of a text field.
#
#	 4. A drop down Finder window style menu appears. Navigate to the current
#	    working directory for R, where the repdata-peer2_doc-pd01016005curr.pdf
#	    file is located.
#
#	 5. Highlight the pdf file by clicking on its name or icon.
#
#	 6. Click the "Choose" button at the bottom-right corner of the drop down
#	    menu. The menu disappears and the file name appears in the text field
#	    adjacent to the "Browse…" button we clicked in step 3.
#
#	 7. Click the "Upload" button to the right of the field in which the file
#	    name appears. A status bar appears, indicating the progress. When the
#	    upload is complete, the repdata-peer2_doc-pd01016005curr.pdf appears in
#	    the window.
#
#	 8. The page numbers appearing in the displayed file match the page number
#	    labels provided by Tabula in the sidebar and immediately to the left of
#	    each page in the main window pane. Scroll down to page 6 of the pdf so
#	    Table 2.1.1 is fully visible.
#
#	 9. When moving the mouse pointer over the document, the pointer is a cross
#	    instead of an arrow, indicating a selection tool. Position the mouse
#	    pointer slightly above and to the left of "Astronomical" at the top of
#	    the left column. Click and drag the pointer to just below and to the
#	    right of the last "Z" in the second Designator column before releasing
#	    the mouse button. All entries in the table should be highlighted,
#		without the headers or legend.
#
#	10. Click the "Preview & Export Extracted Data" button near the top of the
#		page. A preview of the extracted table appears. It should have 24 rows
#		and 4 columns.
#
#	11. Near the top center of the page, "Export Format:" should indicate "CSV".
#		If it does not, the name indicating the current file type can be clicked
#		to activate a drop down menu, making CSV available for selection. Click
#		the "Export" button. The file is saved as
#		tabula-repdata-peer2_doc-pd01016005curr.csv in the default location
#		used by Safari for downloads (~/Downloads in default configuration).
#
#	13. Locate tabula-repdata-peer2_doc-pd01016005curr.csv in Finder. Move or
#		copy the file to the current working directory for R.



EventTypes = read.csv( "./tabula-repdata-peer2_doc-pd01016005curr.csv", header = FALSE, stringsAsFactors = FALSE)

EventTypes = c( EventTypes$V1, EventTypes$V3)
	# Create a character vector from our new data table.

head( EventTypes)
	# We have some undesired trailing spaces.
	
EventTypes = sub( "\\s+$", "", EventTypes)
	# remove trailing spaces




storm = StormData.raw
	# duplicate the data to easily revert

storm$EVTYPE = as.character( storm$EVTYPE)
	# convert EVTYPE from factor to character so values can be manipulated



length( unique( storm$EVTYPE)) # 985

# We first start reducing the number of distinct event types in our data by correcting some obvious differences among otherwise identical values.
	
storm$EVTYPE = tolower( storm$EVTYPE)
	# standardize case among values

length( unique( storm$EVTYPE))  # 898

storm$EVTYPE = gsub( "^\\s+|\\s+$", "", storm$EVTYPE)
	# eliminate leading, trailing spaces
	
length( unique( storm$EVTYPE)) # 890

storm = storm[ - grep( "summary", storm$EVTYPE, fixed = TRUE),]
	# eliminate summaries of multiple events from data

length( unique( storm$EVTYPE)) # 823


# We begin a systematic approach

# A

unique( EventTypes[ grep( "^[Aa]", EventTypes)])

#  [1] "Astronomical Low Tide" "Avalanche"

sort( unique( storm$EVTYPE[ grep( "^[a]", storm$EVTYPE)]))

#  [1] "abnormal warmth"        "abnormally dry"         "abnormally wet"        
#  [4] "accumulated snowfall"   "agricultural freeze"    "apache county"         
#  [7] "astronomical high tide" "astronomical low tide"  "avalance"              
# [10] "avalanche" 

storm$EVTYPE = sub( "avalance", "avalanche", storm$EVTYPE, fixed = TRUE)
	# correct misspelled word

storm$EVTYPE = sub( "astronomical high tide", "storm surge/tide", storm$EVTYPE, fixed = TRUE)
	# per documentation, section 7.37 Storm Surge/Tide (Z), page 68, "For coastal and lakeshore areas, the vertical rise above normal water level associated with a storm of tropical origin (e.g., hurricane, typhoon, or tropical storm) caused by any combination of strong, persistent onshore wind, high astronomical tide and low atmospheric pressure, resulting in damage, erosion, flooding, fatalities, or injuries. 

storm[ storm$EVTYPE == "apache county",]
#storm[ storm$EVTYPE == "apache county", 36]	
	# Remarks indicate thunderstorm wind

storm$EVTYPE = sub( "apache county", "thunderstorm wind", storm$EVTYPE, fixed = TRUE)

storm$EVTYPE = sub( "agricultural freeze", "frost/freeze", storm$EVTYPE, fixed = TRUE)

storm[ storm$EVTYPE == "abnormal warmth",]
#storm[ storm$EVTYPE == "abnormal warmth", 36]
	# unseasonably warm weather in February left early blooming plants vulnerable to normal freezes later in the season. We classify the event as frost/freeze, as that is what ultimately resulted in losses.

storm$EVTYPE = sub( "abnormal warmth", "frost/freeze", storm$EVTYPE, fixed = TRUE)

storm$EVTYPE = sub( "abnormally dry", "drought", storm$EVTYPE, fixed = TRUE)

#storm[ storm$EVTYPE == "accumulated snowfall", 36]
storm[ storm$EVTYPE == "accumulated snowfall",]

storm$EVTYPE = sub( "accumulated snowfall", "heavy snow", storm$EVTYPE, fixed = TRUE)
	# Although it doesn't fit exactly with the category description in the documentation, since the snowfall occurred over a period of a month, remarks indicate that the literally heavy snow resulted in collapsed buildings. This category seems most appropriate.

storm[ storm$EVTYPE == "abnormally wet",]
#storm[ storm$EVTYPE == "abnormally wet", 36]

storm$EVTYPE = sub( "abnormally wet", "heavy rain", storm$EVTYPE, fixed = TRUE)

unique( EventTypes[ grep( "^[Aa]", EventTypes)])
	# Distinct types we want

sort( unique( storm$EVTYPE[ grep( "^[a]", storm$EVTYPE)]))
	# Distinct types we have


# B

EventTypes[ grep( "^[Bb]", EventTypes)]
	# Distinct types we want
	#
	# [1] "Blizzard"

sort( unique( storm$EVTYPE[ grep( "^[b]", storm$EVTYPE)]))
	# Distinct types we have
	# 
	#  [1] "beach erosin"                   "beach erosion"                 
 	#  [3] "beach erosion/coastal flood"    "beach flood"                   
 	#  [5] "below normal precipitation"     "bitter wind chill"             
 	#  [7] "bitter wind chill temperatures" "black ice"                     
 	#  [9] "blizzard"                       "blizzard and extreme wind chil"
	# [11] "blizzard and heavy snow"        "blizzard weather"              
	# [13] "blizzard/freezing rain"         "blizzard/heavy snow"           
	# [15] "blizzard/high wind"             "blizzard/winter storm"         
	# [17] "blow-out tide"                  "blow-out tides"                
	# [19] "blowing dust"                   "blowing snow"                  
	# [21] "blowing snow & extreme wind ch" "blowing snow- extreme wind chi"
	# [23] "blowing snow/extreme wind chil" "breakup flooding"              
	# [25] "brush fire"                     "brush fires"  


storm[ storm$EVTYPE == "beach erosin",]
	# no useful information provided. 

storm = storm[ storm$EVTYPE != "beach erosin",]

storm[ storm$EVTYPE == "beach erosion",]
#storm[ storm$EVTYPE == "beach erosion", 36]

storm$EVTYPE[ storm$REFNUM %in% c( 253480, 359325, 435814)] = "coastal flood"
	# these three are reasonably classified as coastal flood.

# The last remaining entry with EVTYPE == "beach erosion" is not easily classified. Also, it lists 0 damage to persons or property, inconsistant with its remarks. We delete it from our data.
storm = storm[ storm$EVTYPE != "beach erosion",]

storm$EVTYPE = sub( "beach erosion/", "", storm$EVTYPE, fixed = TRUE)

storm[ storm$EVTYPE == "beach flood",]
#storm[ storm$EVTYPE == "beach flood", 36]

storm$EVTYPE = sub( "beach flood", "storm surge/tide", storm$EVTYPE, fixed = TRUE)

storm$EVTYPE = sub( "below normal precipitation", "drought", storm$EVTYPE, fixed = TRUE)

storm$EVTYPE = sub( "bitter wind chill", "extreme cold/wind chill", storm$EVTYPE, fixed = TRUE)

storm$EVTYPE = sub( "bitter wind chill temperatures", "extreme cold/wind chill", storm$EVTYPE, fixed = TRUE)

storm$EVTYPE = sub( "black ice", "frost/freeze", storm$EVTYPE, fixed = TRUE)

storm$EVTYPE = sub( "^blizzard.+", "blizzard", storm$EVTYPE)

storm$EVTYPE = sub( "blow[-]out tide$", "strong wind", storm$EVTYPE)

storm$EVTYPE = sub( "blow-out tides", "strong wind", storm$EVTYPE)

storm$EVTYPE = sub( "blowing dust", "dust storm", storm$EVTYPE, fixed = TRUE)

storm$EVTYPE = sub( "^blowing snow$", "winter weather", storm$EVTYPE)

storm$EVTYPE = sub( "^blowing snow & extreme wind ch", "extreme cold/wind chill", storm$EVTYPE)

storm$EVTYPE = sub( "^blowing snow- extreme wind chi", "extreme cold/wind chill", storm$EVTYPE)

storm$EVTYPE = sub( "^blowing snow/extreme wind chil", "extreme cold/wind chill", storm$EVTYPE)

storm$EVTYPE = sub( "^breakup flooding.*", "flood", storm$EVTYPE)

storm = storm[ - grep( "^brush fire.*", storm$EVTYPE),]
	# do not meet definition of wildfire, also no injuries, deaths, property
	#	damage
	


# C

EventTypes[ grep( "^[Cc]", EventTypes)]
	# Distinct types we want
	#
	# [1] "Coastal Flood"   "Cold/Wind Chill"

sort( unique( storm$EVTYPE[ grep( "^[c]", storm$EVTYPE)]))
	# Distinct types we have
	#
	#  [1] "coastal  flooding/erosion"    "coastal erosion"             
 	#  [3] "coastal flood"                "coastal flooding"            
 	#  [5] "coastal flooding/erosion"     "coastal storm"               
 	#  [7] "coastal surge"                "coastal/tidal flood"         
 	#  [9] "coastalflood"                 "coastalstorm"                
	# [11] "cold"                         "cold air funnel"             
	# [13] "cold air funnels"             "cold air tornado"            
	# [15] "cold and frost"               "cold and snow"               
	# [17] "cold and wet conditions"      "cold temperature"            
	# [19] "cold temperatures"            "cold wave"                   
	# [21] "cold weather"                 "cold wind chill temperatures"
	# [23] "cold/wind chill"              "cold/winds"                  
	# [25] "cool and wet"                 "cool spell"                  
	# [27] "cstl flooding/erosion" 


storm$EVTYPE = sub( "^c[a-z]+l\\s*(f|/).*$", "coastal flood", storm$EVTYPE)
	# convert all of the variations on coastal flood
	
storm$EVTYPE = sub( "^coastal e.+$", "coastal flood", storm$EVTYPE)

storm$EVTYPE = sub( "^coastal\\s*storm$", "tropical depression", storm$EVTYPE)

storm = storm[ - grep( "^cool and wet", storm$EVTYPE),]
	# No storm event, just a cool and wet summer, less than ideal for some
	#	farmers
storm = storm[ - grep( "^cool spell", storm$EVTYPE),]
	# No storm event, just a significantly cooler than average August
	
storm$EVTYPE = sub( "^cold and wet", "flood", storm$EVTYPE)

storm$EVTYPE[storm$REFNUM == "220848"] = sub( "^coastal surge", "storm surge/tide", storm$EVTYPE[ storm$REFNUM == "220848"])
	# Remarks indicate storm surge/tide is appropriate

storm$EVTYPE = sub( "^coastal surge", "coastal flood", storm$EVTYPE)

storm$EVTYPE = sub( "^cold air funnel[s]*", "funnel cloud", storm$EVTYPE)

storm$EVTYPE = sub( "^cold air tornado", "tornado", storm$EVTYPE)

storm = storm[ - grep( "^cold and frost", storm$EVTYPE),]
	# No storm, unseasonably cool weather, no injuries, fatalities, or damage

storm$EVTYPE = sub( "^cold.*", "cold/wind chill", storm$EVTYPE)

# D

EventTypes[ grep( "^[Dd]", EventTypes)]
	# Distinct types we want
	#
	# [1] "Debris Flow" "Dense Fog"   "Dense Smoke" "Drought"     "Dust Devil" 
	# [2] "Dust Storm"

sort( unique( storm$EVTYPE[ grep( "^[d]", storm$EVTYPE)]))
	# Distinct types we have
	#
	# [1] "dam break"              "dam failure"            "damaging freeze"       
	# [4] "deep hail"              "dense fog"              "dense smoke"           
 	# [7] "downburst"              "downburst winds"        "driest month"          
	# [10] "drifting snow"          "drought"                "drought/excessive heat"
	# [13] "drowning"               "dry"                    "dry conditions"        
	# [16] "dry hot weather"        "dry microburst"         "dry microburst 50"     
	# [19] "dry microburst 53"      "dry microburst 58"      "dry microburst 61"     
	# [22] "dry microburst 84"      "dry microburst winds"   "dry mircoburst winds"  
	# [25] "dry pattern"            "dry spell"              "dry weather"           
	# [28] "dryness"                "dust devel"             "dust devil"            
	# [31] "dust devil waterspout"  "dust storm"             "dust storm/high winds" 
	# [34] "duststorm"
	
storm$EVTYPE = sub( "^dam [bf].*", "flash flood", storm$EVTYPE)	
	
storm$EVTYPE = sub( "^dama.*", "frost/freeze", storm$EVTYPE)	
	
storm$EVTYPE = sub( "^d.+hail", "hail", storm$EVTYPE)	
	
storm$EVTYPE = sub( "^driest.+", "drought", storm$EVTYPE)	
	
storm$EVTYPE = sub( "^down.+", "thunderstorm wind", storm$EVTYPE)	
	
storm$EVTYPE = sub( "^drought.+", "drought", storm$EVTYPE)	
	
storm$EVTYPE = sub( "^drif.+", "winter weather", storm$EVTYPE)

storm$EVTYPE = sub( "^drow.+", "flash flood", storm$EVTYPE)

storm$EVTYPE = sub( "^dry$", "drought", storm$EVTYPE)

storm$EVTYPE = sub( "^dryness$", "drought", storm$EVTYPE)
	
storm$EVTYPE = sub( "^dry [chpsw].+", "drought", storm$EVTYPE)

storm$EVTYPE = sub( "^d.+mi.+", "thunderstorm wind", storm$EVTYPE)	
	
storm$EVTYPE = sub( "^d.+spout$", "dust devil", storm$EVTYPE)	
	
storm$EVTYPE = sub( "^du.+el$", "dust devil", storm$EVTYPE)	
	
storm$EVTYPE = sub( "^du.+nds$", "dust storm", storm$EVTYPE)	
	
storm$EVTYPE = sub( "^duststorm$", "dust storm", storm$EVTYPE)	
	


# E

EventTypes[ grep( "^[Ee]", EventTypes)]
	# Distinct types we want
	#	
	# [1] "Excessive Heat"          "Extreme Cold/Wind Chill"

sort( unique( storm$EVTYPE[ grep( "^[e]", storm$EVTYPE)]))
	# Distinct types we have
	#
	# [1] "early freeze"                         "early frost"                         
 	# [3] "early rain"                           "early snow"                          
 	# [5] "early snowfall"                       "erosion/cstl flood"                  
 	# [7] "excessive"                            "excessive cold"                      
 	# [9] "excessive heat"                       "excessive heat/drought"              
	# [11] "excessive precipitation"              "excessive rain"                      
	# [13] "excessive rainfall"                   "excessive snow"                      
	# [15] "excessive wetness"                    "excessively dry"                     
	# [17] "extended cold"                        "extreme cold"                        
	# [19] "extreme cold/wind chill"              "extreme cold/wind chill temperatures"
	# [21] "extreme heat"                         "extreme wind chill"                  
	# [23] "extreme wind chill/blowing sno"       "extreme wind chills"                 
	# [25] "extreme windchill"                    "extreme windchill temperatures"      
	# [27] "extreme/record cold"                  "extremely wet"	
	
	
storm$EVTYPE = sub( "^ea.+fr.+$", "frost/freeze", storm$EVTYPE)

storm = storm[ - grep( "^early rain", storm$EVTYPE),]
	# No storm event

storm = storm[ - grep( "^early snow", storm$EVTYPE),]
	# Light snowfall mid-fall. Remarks contradict fatality reports; damage and
	# fatalities listed as zero

storm$EVTYPE = sub( "^er.+od$", "coastal flood", storm$EVTYPE)
	
storm$EVTYPE = sub( "^excessive$", "drought", storm$EVTYPE)
	
storm$EVTYPE = sub( "^exc.+ld$", "drought", storm$EVTYPE)	
	
storm$EVTYPE = sub( "^exc.+ht$", "drought", storm$EVTYPE)

storm$EVTYPE = sub( "^exc.+on$", "heavy rain", storm$EVTYPE)

storm$EVTYPE = sub( "^exc.+in.*$", "heavy rain", storm$EVTYPE)

storm$EVTYPE = sub( "^exc.+ow$", "heavy snow", storm$EVTYPE)
	# too many (25) "excessive snow" entries to check individually
	
storm$EVTYPE = sub( "^exc.+ss$", "heavy rain", storm$EVTYPE)

storm$EVTYPE = sub( "^exc.+ry$", "drought", storm$EVTYPE)

storm$EVTYPE = sub( "^exte.+ld$", "cold/wind chill", storm$EVTYPE)

storm$EVTYPE = sub( "^extr.+cold.*$", "extreme cold/wind chill", storm$EVTYPE)

storm$EVTYPE = sub( "^extr.+cold.*$", "extreme cold/wind chill", storm$EVTYPE)

storm$EVTYPE = sub( "^extr.+ wind.*$", "extreme cold/wind chill", storm$EVTYPE)

storm$EVTYPE = sub( "^extr.+heat$", "excessive heat", storm$EVTYPE)

storm$EVTYPE = sub( "^ext.+wet$", "heavy rain", storm$EVTYPE)

sort( unique( storm$EVTYPE[ grep( "^[e]", storm$EVTYPE)]))


# F

EventTypes[ grep( "^[Ff]", EventTypes)]
	# Distinct types we want
	#	
	# [1] "Flash Flood"  "Flood"        "Frost/Freeze" "Funnel Cloud" "Freezing Fog"


sort( unique( storm$EVTYPE[ grep( "^[f]", storm$EVTYPE)]))
	# Distinct types we have
	#	
	# [1] "falling snow/ice"               "first frost"                   
	# [3] "first snow"                     "flash flood"                   
	# [5] "flash flood - heavy rain"       "flash flood from ice jams"     
	# [7] "flash flood landslides"         "flash flood winds"             
	# [9] "flash flood/"                   "flash flood/ flood"            
	# [11] "flash flood/ street"            "flash flood/flood"             
	# [13] "flash flood/heavy rain"         "flash flood/landslide"         
	# [15] "flash flooding"                 "flash flooding/flood"          
	# [17] "flash flooding/thunderstorm wi" "flash floods"                  
	# [19] "flash floooding"                "flood"                         
	# [21] "flood & heavy rain"             "flood conditions"              
	# [23] "flood flash"                    "flood flood/flash"             
	# [25] "flood watch/"                   "flood/flash"                   
	# [27] "flood/flash flood"              "flood/flash flooding"          
	# [29] "flood/flash/flood"              "flood/flashflood"              
	# [31] "flood/rain/wind"                "flood/rain/winds"              
	# [33] "flood/river flood"              "flood/strong wind"             
	# [35] "flooding"                       "flooding/heavy rain"           
	# [37] "floods"                         "fog"                           
	# [39] "fog and cold temperatures"      "forest fires"                  
	# [41] "freeze"                         "freezing drizzle"              
	# [43] "freezing drizzle and freezing"  "freezing fog"                  
	# [45] "freezing rain"                  "freezing rain and sleet"       
	# [47] "freezing rain and snow"         "freezing rain sleet and"       
	# [49] "freezing rain sleet and light"  "freezing rain/sleet"           
	# [51] "freezing rain/snow"             "freezing spray"                
	# [53] "frost"                          "frost/freeze"                  
	# [55] "frost\\freeze"                  "funnel"                        
	# [57] "funnel cloud"                   "funnel cloud."                 
	# [59] "funnel cloud/hail"              "funnel clouds"                 
	# [61] "funnels"         


storm$EVTYPE = sub( "^fall.+ice$", "heavy snow", storm$EVTYPE)

storm = storm[ - grep( "^first frost", storm$EVTYPE),]
	# No storm event

storm = storm[ - grep( "^first snow", storm$EVTYPE),]
	# No storm event, all accumulations under six inches

storm$EVTYPE = sub( "^fla.+des$", "debris flow", storm$EVTYPE)
	# Event best fits in debris flow category

storm$EVTYPE = sub( "^fla.+de$", "flash flood", storm$EVTYPE)
	# Event best fits flash flood category

storm$EVTYPE = sub( "^f.*lash.*$", "flash flood", storm$EVTYPE)

storm$EVTYPE = sub( "^flo.*$", "flood", storm$EVTYPE)

# Some events listed as fog indicate freezing fog in remarks; others indicate
#	dense fog

freezingFogIndex = grep( "[Ff]reez", storm$REMARKS)

storm$EVTYPE[ freezingFogIndex] = sub( "^fog$", "freezing fog", storm$EVTYPE[ freezingFogIndex])

storm$EVTYPE = sub( "^fog$", "dense fog", storm$EVTYPE)

storm$EVTYPE = sub( "^fog.+$", "dense fog", storm$EVTYPE)

storm$EVTYPE = sub( "^freezing [drs].+$", "ice storm", storm$EVTYPE)

storm$EVTYPE = sub( "^freeze$", "frost/freeze", storm$EVTYPE)

storm$EVTYPE = sub( "^frost$", "frost/freeze", storm$EVTYPE)

storm$EVTYPE = sub( "frost\\freeze", "frost/freeze", storm$EVTYPE, fixed = T)

storm$EVTYPE = sub( "^for.+$", "wildfire", storm$EVTYPE)

storm$EVTYPE = sub( "^funnel.*$", "funnel cloud", storm$EVTYPE)


# G

EventTypes[ grep( "^[Gg]", EventTypes)]
	# Distinct types we want
	#	
	# character(0)

sort( unique( storm$EVTYPE[ grep( "^[g]", storm$EVTYPE)]))
	# Distinct types we have
	#	
	# [1] "glaze"                    "glaze ice"                "glaze/ice storm"         
 	# [4] "gradient wind"            "gradient winds"           "grass fires"             
 	# [7] "ground blizzard"          "gustnado"                 "gustnado and"            
	# [10] "gusty lake wind"          "gusty thunderstorm wind"  "gusty thunderstorm winds"
#	 [13] "gusty wind"               "gusty wind/hail"          "gusty wind/hvy rain"     
	# [16] "gusty wind/rain"          "gusty winds"

storm$EVTYPE = sub( "^glaze.*$", "ice storm", storm$EVTYPE)

storm$EVTYPE = sub( "^grad.+$", "strong wind", storm$EVTYPE)

storm = storm[ - grep( "^grass fires$", storm$EVTYPE),]
	# criteria for wildfire not met.

storm$EVTYPE = sub( "^gro.+$", "winter storm", storm$EVTYPE)

storm$EVTYPE = sub( "^gustn.+$", "thunderstorm wind", storm$EVTYPE)

storm$EVTYPE = sub( "^gusty l.+$", "strong wind", storm$EVTYPE)

storm$EVTYPE = sub( "^g.+th.+$", "thunderstorm wind", storm$EVTYPE)

thunderstormWindIndex = grep( "[Tt]hunderstorm", storm$REMARKS)

storm$EVTYPE[ thunderstormWindIndex] = sub( "^gusty wind$", "thunderstorm wind", storm$EVTYPE[ thunderstormWindIndex])

tropicalStormIndex = grep( "[Tt]ropical [Ss]torm", storm$REMARKS)

storm$EVTYPE[ tropicalStormIndex] = sub( "^gusty wind$", "tropical storm", storm$EVTYPE[ tropicalStormIndex])

storm$EVTYPE = sub( "^gusty wind$", "strong wind", storm$EVTYPE)

tropicalStormIndex = grep( "[Tt]ropical [Ss]torm", storm$REMARKS)

storm$EVTYPE[ tropicalStormIndex] = sub( "^gusty winds$", "tropical storm", storm$EVTYPE[ tropicalStormIndex])

storm$EVTYPE[ thunderstormWindIndex] = sub( "^gusty winds$", "thunderstorm wind", storm$EVTYPE[ thunderstormWindIndex])

storm$EVTYPE = sub( "^gusty winds$", "strong wind", storm$EVTYPE)

storm$EVTYPE = sub( "^gusty wind.+[ln]$", "thunderstorm wind", storm$EVTYPE)


# H

EventTypes[ grep( "^[Hh]", EventTypes)]
	# Distinct types we want
	#	
	# [1] "Hail"                "Heat"                "Heavy Rain"         
	# [4] "Heavy Snow"          "High Surf"           "High Wind"          
	# [7] "Hurricane (Typhoon)"
	
sort( unique( storm$EVTYPE[ grep( "^[h]", storm$EVTYPE)]))
	# Distinct types we have
	#	
	# [1] "hail"                           "hail 0.75"                     
	#  [3] "hail 0.88"                      "hail 075"                      
  	# [5] "hail 088"                       "hail 1.00"                     
  	# [7] "hail 1.75"                      "hail 1.75)"                    
 	#  [9] "hail 100"                       "hail 125"                      
	#  [11] "hail 150"                       "hail 175"                      
	#  [13] "hail 200"                       "hail 225"                      
	#  [15] "hail 275"                       "hail 450"                      
	#  [17] "hail 75"                        "hail 80"                       
	#  [19] "hail 88"                        "hail aloft"                    
	#  [21] "hail damage"                    "hail flooding"                 
	#  [23] "hail storm"                     "hail(0.75)"                    
	#  [25] "hail/icy roads"                 "hail/wind"                     
	#  [27] "hail/winds"                     "hailstorm"                     
	#  [29] "hailstorms"                     "hard freeze"                   
	#  [31] "hazardous surf"                 "heat"                          
	#  [33] "heat drought"                   "heat wave"                     
	#  [35] "heat wave drought"              "heat waves"                    
	#  [37] "heat/drought"                   "heatburst"                     
	#  [39] "heavy lake snow"                "heavy mix"                     
	#  [41] "heavy precipatation"            "heavy precipitation"           
	#  [43] "heavy rain"                     "heavy rain and flood"          
	#  [45] "heavy rain and wind"            "heavy rain effects"            
	#  [47] "heavy rain; urban flood winds;" "heavy rain/flooding"           
	#  [49] "heavy rain/high surf"           "heavy rain/lightning"          
	#  [51] "heavy rain/mudslides/flood"     "heavy rain/severe weather"     
	#  [53] "heavy rain/small stream urban"  "heavy rain/snow"               
	#  [55] "heavy rain/urban flood"         "heavy rain/wind"               
	#  [57] "heavy rainfall"                 "heavy rains"                   
	#  [59] "heavy rains/flooding"           "heavy seas"                    
	#  [61] "heavy shower"                   "heavy showers"                 
	#  [63] "heavy snow"                     "heavy snow   freezing rain"    
	#  [65] "heavy snow & ice"               "heavy snow and"                
	#  [67] "heavy snow and high winds"      "heavy snow and ice"            
	#  [69] "heavy snow and ice storm"       "heavy snow and strong winds"   
	#  [71] "heavy snow andblowing snow"     "heavy snow shower"             
	#  [73] "heavy snow squalls"             "heavy snow-squalls"            
	#  [75] "heavy snow/blizzard"            "heavy snow/blizzard/avalanche" 
	#  [77] "heavy snow/blowing snow"        "heavy snow/freezing rain"      
	#  [79] "heavy snow/high"                "heavy snow/high wind"          
	#  [81] "heavy snow/high winds"          "heavy snow/high winds & flood" 
	#  [83] "heavy snow/high winds/freezing" "heavy snow/ice"                
	#  [85] "heavy snow/ice storm"           "heavy snow/sleet"              
	#  [87] "heavy snow/squalls"             "heavy snow/wind"               
	#  [89] "heavy snow/winter storm"        "heavy snowpack"                
	#  [91] "heavy surf"                     "heavy surf and wind"           
	#  [93] "heavy surf coastal flooding"    "heavy surf/high surf"          
	#  [95] "heavy swells"                   "heavy wet snow"                
	#  [97] "high"                           "high  swells"                  
	#  [99] "high  winds"                    "high seas"                     
	# [101] "high surf"                      "high surf advisories"          
	# [103] "high surf advisory"             "high swells"                   
	# [105] "high temperature record"        "high tides"                    
	# [107] "high water"                     "high waves"                    
	# [109] "high wind"                      "high wind (g40)"               
	# [111] "high wind 48"                   "high wind 63"                  
	# [113] "high wind 70"                   "high wind and heavy snow"      
	# [115] "high wind and high tides"       "high wind and seas"            
	# [117] "high wind damage"               "high wind/ blizzard"           
	# [119] "high wind/blizzard"             "high wind/blizzard/freezing ra"
	# [121] "high wind/heavy snow"           "high wind/low wind chill"      
	# [123] "high wind/seas"                 "high wind/wind chill"          
	# [125] "high wind/wind chill/blizzard"  "high winds"                    
	# [127] "high winds 55"                  "high winds 57"                 
	# [129] "high winds 58"                  "high winds 63"                 
	# [131] "high winds 66"                  "high winds 67"                 
	# [133] "high winds 73"                  "high winds 76"                 
	# [135] "high winds 80"                  "high winds 82"                 
	# [137] "high winds and wind chill"      "high winds dust storm"         
	# [139] "high winds heavy rains"         "high winds/"                   
	# [141] "high winds/coastal flood"       "high winds/cold"               
	# [143] "high winds/flooding"            "high winds/heavy rain"         
	# [145] "high winds/snow"                "highway flooding"              
	# [147] "hot and dry"                    "hot pattern"                   
	# [149] "hot spell"                      "hot weather"                   
	# [151] "hot/dry pattern"                "hurricane"                     
	# [153] "hurricane edouard"              "hurricane emily"               
	# [155] "hurricane erin"                 "hurricane felix"               
	# [157] "hurricane gordon"               "hurricane opal"                
	# [159] "hurricane opal/high winds"      "hurricane-generated swells"    
	# [161] "hurricane/typhoon"              "hvy rain"                      
	# [163] "hyperthermia/exposure"          "hypothermia"                   
	# [165] "hypothermia/exposure"


storm$EVTYPE = sub( "^hail.+$", "hail", storm$EVTYPE)

storm$EVTYPE = sub( "^ha.+ze$", "frost/freeze", storm$EVTYPE)

storm$EVTYPE = sub( "^ha.+rf$", "high surf", storm$EVTYPE)

storm$EVTYPE = sub( "^h.+wave.+ght$", "heat", storm$EVTYPE)

storm$EVTYPE = sub( "^h.+drought$", "drought", storm$EVTYPE)

storm$EVTYPE = sub( "^heatburst$", "high wind", storm$EVTYPE)

storm$EVTYPE = sub( "^heatburst$", "high wind", storm$EVTYPE)

storm$EVTYPE = sub( "^h.+lake.+ow$", "lake-effect snow", storm$EVTYPE)

storm$EVTYPE = sub( "^h.+wave[s]?$", "heat", storm$EVTYPE)

storm$EVTYPE = sub( "^h.+mix$", "winter storm", storm$EVTYPE)

storm$EVTYPE = sub( "^heavy precipitation$", "heavy rain", storm$EVTYPE)

storm$EVTYPE = sub( "^heavy precipatation$", "flash flood", storm$EVTYPE)

storm$EVTYPE = sub( "^heavy rain.+$", "heavy rain", storm$EVTYPE)

storm = storm[ - grep( "^heavy seas$", storm$EVTYPE),]
	# 2 incidents, neither appears to meet criteria of a storm event

storm$EVTYPE = sub( "^heavy shower[s]?$", "heavy rain", storm$EVTYPE)

storm$EVTYPE = sub( "^heavy s.+n$", "winter storm", storm$EVTYPE)

storm$EVTYPE = sub( "^heavy s.+ice.*$", "winter storm", storm$EVTYPE)

storm$EVTYPE = sub( "^heavy s.+and$", "winter storm", storm$EVTYPE)

storm$EVTYPE = sub( "^heavy sn.+wind.*$", "winter storm", storm$EVTYPE)

storm$EVTYPE = sub( "^heavy sn.+blowing.*$", "winter storm", storm$EVTYPE)

storm$EVTYPE = sub( "^heavy sn.+che$", "heavy snow", storm$EVTYPE)

storm$EVTYPE = sub( "^heavy sn.+wer$", "heavy snow", storm$EVTYPE)

lakeEffectIndex = grep( "[Ll]ake", storm$REMARKS)

storm$EVTYPE[ lakeEffectIndex] = sub( "^heavy s.+squalls$", "lake-effect snow", storm$EVTYPE[ lakeEffectIndex])

storm$EVTYPE = sub( "^heavy s.+squalls$", "heavy snow", storm$EVTYPE)

storm$EVTYPE = sub( "^heavy s.+ard$", "winter storm", storm$EVTYPE)

storm$EVTYPE = sub( "^heavy sn.+[/].+$", "winter storm", storm$EVTYPE)

storm$EVTYPE = sub( "^heavy snow.+$", "heavy snow", storm$EVTYPE)

storm$EVTYPE = sub( "^heavy surf$", "high surf", storm$EVTYPE)

storm = storm[ - grep( "^heavy surf and wind$", storm$EVTYPE),]
	# Unfortunate incident, does not appear to be storm event

storm$EVTYPE = sub( "^heavy.+ing$", "coastal flood", storm$EVTYPE)

storm$EVTYPE = sub( "^heavy.+surf$", "high surf", storm$EVTYPE)

storm$EVTYPE = sub( "^heavy.+lls$", "high surf", storm$EVTYPE)

storm$EVTYPE = sub( "^heavy .+snow$", "heavy snow", storm$EVTYPE)

storm$EVTYPE = sub( "^high$", "high winds", storm$EVTYPE)

storm = storm[ - grep( "^high  swells$", storm$EVTYPE),]
	# does not appear to be storm event

storm = storm[ - grep( "^high seas$", storm$EVTYPE),]
	# do not appear to be storm events, winds not mentioned

storm$EVTYPE = sub( "^high surf.+$", "high surf", storm$EVTYPE)

storm$EVTYPE = sub( "^high.+lls$", "high surf", storm$EVTYPE)

storm = storm[ - grep( "^high temperature record$", storm$EVTYPE),]
	# do not appear to be storm events, no damage, injuries, fatalities

storm$EVTYPE = sub( "^high tides$", "high surf", storm$EVTYPE)

storm$EVTYPE = sub( "^high wind[s]?.+[0-9][0-9].*$", "high wind", storm$EVTYPE)

storm$EVTYPE = sub( "^high.+snow$", "winter storm", storm$EVTYPE)

storm$EVTYPE = sub( "^high water$", "flood", storm$EVTYPE)

storm$EVTYPE = sub( "^high  winds$", "high wind", storm$EVTYPE)

storm$EVTYPE = sub( "^high wind.+tides$", "high wind", storm$EVTYPE)

storm$EVTYPE = sub( "^high wind .+$", "high wind", storm$EVTYPE)

storm$EVTYPE = sub( "^high wind.+blizzard.*$", "winter storm", storm$EVTYPE)

storm$EVTYPE = sub( "^high wind.+chill$", "high wind", storm$EVTYPE)

storm$EVTYPE = sub( "^high wind/seas$", "marine strong wind", storm$EVTYPE)
	
storm$EVTYPE = sub( "^high winds.?$", "high wind", storm$EVTYPE)

storm$EVTYPE = sub( "^high.+dust.+$", "dust storm", storm$EVTYPE)

storm$EVTYPE = sub( "^high.+rains$", "tropical storm", storm$EVTYPE)

storm$EVTYPE = sub( "^high.+rain$", "high wind", storm$EVTYPE)

storm$EVTYPE = sub( "^high.+ood$", "coastal flood", storm$EVTYPE)

storm$EVTYPE = sub( "^high.+cold$", "winter weather", storm$EVTYPE)

storm$EVTYPE = sub( "^high w.+ing$", "high wind", storm$EVTYPE)

storm$EVTYPE = sub( "^highway flooding$", "flood", storm$EVTYPE)

storm$EVTYPE = sub( "^hot.+dry$", "drought", storm$EVTYPE)

storm$EVTYPE = sub( "^hot.+$", "heat", storm$EVTYPE)

storm$EVTYPE = sub( "^hurr.+$", "hurricane (typhoon)", storm$EVTYPE)

storm$EVTYPE = sub( "^hvy.+$", "heavy rain", storm$EVTYPE)

storm$EVTYPE = sub( "^hyp.+$", "cold/wind chill", storm$EVTYPE)


# I

EventTypes[ grep( "^[Ii]", EventTypes)]
# Distinct types we want
	#	
	# [1] "Ice Storm"

sort( unique( storm$EVTYPE[ grep( "^[i]", storm$EVTYPE)]))
	# Distinct types we have
	#	
	# [1] "ice"                   "ice and snow"          "ice floes"            
 	# [4] "ice fog"               "ice jam"               "ice jam flood (minor" 
 	# [7] "ice jam flooding"      "ice on road"           "ice pellets"          
	# [10] "ice roads"             "ice storm"             "ice storm and snow"   
	# [13] "ice storm/flash flood" "ice/snow"              "ice/strong winds"     
	# [16] "icestorm/blizzard"     "icy roads"

storm$EVTYPE = sub( "^ice$", "ice storm", storm$EVTYPE)
	# Too many (61) to check individually, "freezing rain" common in REMARKS

storm$EVTYPE = sub( "^ice.+ow$", "winter storm", storm$EVTYPE)

boatIndex = grep( "[Bb]oat[s]?", storm$REMARKS)

storm$EVTYPE[ boatIndex] = sub( "^ice floes$", "marine strong wind", storm$EVTYPE[ boatIndex])
	# seems to be category of best match

storm$EVTYPE = sub( "^ice floes$", "winter storm", storm$EVTYPE)

storm$EVTYPE = sub( "^ice fog$", "freezing fog", storm$EVTYPE)

storm$EVTYPE = sub( "^ice jam.*$", "flood", storm$EVTYPE)
	# Closest category

storm$EVTYPE = sub( "^ic[ey].+road[s]?$", "winter weather", storm$EVTYPE)

storm$EVTYPE = sub( "^ice pellets$", "sleet", storm$EVTYPE)

storm$EVTYPE = sub( "^ice.+flood$", "ice storm", storm$EVTYPE)

storm$EVTYPE = sub( "^ice.+[ds]$", "winter storm", storm$EVTYPE)



# J

EventTypes[ grep( "^[Jj]", EventTypes)]
# Distinct types we want
	#	
	# character(0)

sort( unique( storm$EVTYPE[ grep( "^[j]", storm$EVTYPE)]))
	# Distinct types we have
	#	
	# character(0)
	


# K

EventTypes[ grep( "^[Kk]", EventTypes)]
# Distinct types we want
	#	
	# character(0)
	
sort( unique( storm$EVTYPE[ grep( "^[k]", storm$EVTYPE)]))
	# Distinct types we have
	#	
	# character(0)




# L

EventTypes[ grep( "^[Ll]", EventTypes)]
# Distinct types we want
	#	
	# [1] "Lake-Effect Snow" "Lakeshore Flood"  "Lightning"

sort( unique( storm$EVTYPE[ grep( "^[l]", storm$EVTYPE)]))
	# Distinct types we have
	#	
	# [1] "lack of snow"                   "lake effect snow"              
 	# [3] "lake flood"                     "lake-effect snow"              
 	# [5] "lakeshore flood"                "landslide"                     
 	# [7] "landslide/urban flood"          "landslides"                    
 	# [9] "landslump"                      "landspout"                     
	# [11] "large wall cloud"               "late freeze"                   
	# [13] "late season hail"               "late season snow"              
	# [15] "late season snowfall"           "late snow"                     
	# [17] "late-season snowfall"           "light freezing rain"           
	# [19] "light snow"                     "light snow and sleet"          
	# [21] "light snow/flurries"            "light snow/freezing precip"    
	# [23] "light snowfall"                 "lighting"                      
	# [25] "lightning"                      "lightning  wauseon"            
	# [27] "lightning and heavy rain"       "lightning and thunderstorm win"
	# [29] "lightning and winds"            "lightning damage"              
	# [31] "lightning fire"                 "lightning injury"              
	# [33] "lightning thunderstorm winds"   "lightning thunderstorm windss" 
	# [35] "lightning."                     "lightning/heavy rain"          
	# [37] "ligntning"                      "local flash flood"             
	# [39] "local flood"                    "locally heavy rain"            
	# [41] "low temperature"                "low temperature record"        
	# [43] "low wind chill"

storm$EVTYPE = sub( "^lack.+$", "drought", storm$EVTYPE)

storm$EVTYPE = sub( "^lake f.+$", "lakeshore flood", storm$EVTYPE)

storm$EVTYPE = sub( "^lake effect snow$", "lake-effect snow", storm$EVTYPE)

storm$EVTYPE = sub( "^landsl.+$", "debris flow", storm$EVTYPE)

storm$EVTYPE = sub( "^landsp.+$", "dust devil", storm$EVTYPE)

storm = storm[ - grep( "^large wall cloud$", storm$EVTYPE),]
	# No description of event or reported damage or injuries

storm$EVTYPE = sub( "^late f.+$", "frost/freeze", storm$EVTYPE)

storm$EVTYPE = sub( "^late.+hail$", "hail", storm$EVTYPE)

storm$EVTYPE = sub( "^late.+season snow.*$", "heavy snow", storm$EVTYPE)

storm$EVTYPE = sub( "^late snow$", "winter storm", storm$EVTYPE)

storm$EVTYPE = sub( "^light freezing rain$", "ice storm", storm$EVTYPE)

storm$EVTYPE = sub( "^light snow.+[pt]$", "winter weather", storm$EVTYPE)

storm$EVTYPE = sub( "^light snow.+$", "ice storm", storm$EVTYPE)

storm$EVTYPE = sub( "^lighting$", "lightning", storm$EVTYPE)

storm$EVTYPE = sub( "^lightning.+on$", "lightning", storm$EVTYPE)

storm$EVTYPE = sub( "^lightning a.+rain$", "heavy rain", storm$EVTYPE)

storm$EVTYPE = sub( "^lightning.+rain$", "lightning", storm$EVTYPE)

storm$EVTYPE = sub( "^lightning.+win$", "lightning", storm$EVTYPE)

storm$EVTYPE = sub( "^lightning.+winds[s]?$", "lightning", storm$EVTYPE)

storm$EVTYPE = sub( "^lightning.+[ey]$", "lightning", storm$EVTYPE)

storm$EVTYPE = sub( "^ligntning$", "lightning", storm$EVTYPE)

storm$EVTYPE = sub( "^lightning[.]$", "lightning", storm$EVTYPE)

storm$EVTYPE = sub( "^light snow$", "winter weather", storm$EVTYPE)
	# too many to verify individually

storm$EVTYPE = sub( "^local f.+flood$", "flash flood", storm$EVTYPE)

storm$EVTYPE = sub( "^local flood$", "flood", storm$EVTYPE)

storm$EVTYPE = sub( "^locally.+rain$", "flood", storm$EVTYPE)

storm$EVTYPE = sub( "^low.+[el]$", "cold/wind chill", storm$EVTYPE)

storm = storm[ - grep( "^low.+ord$", storm$EVTYPE),]
	# No storm event
	


# M

EventTypes[ grep( "^[Mm]", EventTypes)]
# Distinct types we want
	#	
	# [1] "Marine Hail"              "Marine High Wind"         "Marine Strong Wind"      
	# [4] "Marine Thunderstorm Wind"

sort( unique( storm$EVTYPE[ grep( "^[m]", storm$EVTYPE)]))
	# Distinct types we have
	#	
	# [1] "major flood"               "marine accident"           "marine hail"              
 	# [4] "marine high wind"          "marine mishap"             "marine strong wind"       
 	# [7] "marine thunderstorm wind"  "marine tstm wind"          "metro storm, may 26"      
	# [10] "microburst"                "microburst winds"          "mild and dry pattern"     
	# [13] "mild pattern"              "mild/dry pattern"          "minor flood"              
	# [16] "minor flooding"            "mixed precip"              "mixed precipitation"      
	# [19] "moderate snow"             "moderate snowfall"         "monthly precipitation"    
	# [22] "monthly rainfall"          "monthly snowfall"          "monthly temperature"      
	# [25] "mountain snows"            "mud slide"                 "mud slides"               
	# [28] "mud slides urban flooding" "mud/rock slide"            "mudslide"                 
	# [31] "mudslide/landslide"        "mudslides"

storm$EVTYPE = sub( "^major flood$", "flood", storm$EVTYPE)

storm = storm[ - grep( "^marine accident$", storm$EVTYPE),]
	# not enough information to classify as storm event

storm$EVTYPE = sub( "^marine mishap$", "marine strong wind", storm$EVTYPE)

storm$EVTYPE = sub( "^ma.+tstm.+nd$", "marine thunderstorm wind", storm$EVTYPE)

storm$EVTYPE = sub( "^metro storm, may 26$", "thunderstorm wind", storm$EVTYPE)

storm$EVTYPE = sub( "^microburst.*$", "thunderstorm wind", storm$EVTYPE)

storm = storm[ - grep( "^mild.+pattern$", storm$EVTYPE),]
	# unusually nice weather doesn't fit any of the storm event definitions.

storm$EVTYPE = sub( "^min.+flood.*$", "flood", storm$EVTYPE)

storm$EVTYPE = sub( "^mixed precip.*$", "winter storm", storm$EVTYPE)

# 100+ "^moderate snow.*$" events, some winter weather, some winter storms
winterStormIndex = unique( c( grep( "[Ff]reezing", storm$REMARKS), grep( "[Ss]leet", storm$REMARKS)))

storm$EVTYPE[ winterStormIndex] = sub( "^moderate snow.*$", "winter storm", storm$EVTYPE[ winterStormIndex])

storm$EVTYPE = sub( "^moderate snow.*$", "winter weather", storm$EVTYPE)

# 36 "monthly precipitation" entries are a mix of too much and too little rain.
dryIndex = unique( c( grep( "[Oo]nly", storm$REMARKS), grep( "[Dd]riest", storm$REMARKS)))

storm$EVTYPE[ dryIndex] = sub( "^month.+tion$", "drought", storm$EVTYPE[ dryIndex])

storm$EVTYPE = sub( "^month.+tion$", "heavy rain", storm$EVTYPE)

# We need to slightly modify the dryIndex to include a few more observations
dryIndex = unique( c( dryIndex, grep( "[Ll]ess than", storm$REMARKS), grep( "or less", storm$REMARKS)))

storm$EVTYPE[ dryIndex] = sub( "^month.+nfall$", "drought", storm$EVTYPE[ dryIndex])

storm$EVTYPE = sub( "^month.+nfall$", "heavy rain", storm$EVTYPE)

storm$EVTYPE = sub( "^month.+fall$", "heavy snow", storm$EVTYPE)
	# Heavy snow accumulation (2.5 - 5+ feet) best fits heavy snow event def.
	
storm = storm[ - grep( "^mon.+ture$", storm$EVTYPE),]
	# Colder than normal average temps, no storm event

storm$EVTYPE = sub( "^mountain snows$", "winter weather", storm$EVTYPE)

storm$EVTYPE = sub( "^mud.+flood.*$", "flood", storm$EVTYPE)

storm$EVTYPE = sub( "^mud.+$", "debris flow", storm$EVTYPE)




# N 















