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

