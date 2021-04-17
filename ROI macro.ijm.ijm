close("*"); //Close all images
if(isOpen("Results")){ //Close the results table if one is open
	selectWindow("Results");
	run("Close");
}

run("Bio-Formats Macro Extensions"); //Run bio-formats to be able to check number of slices in each image without opening them
dir = getDirectory("select lens analysis folder"); // this line selects the lens folder which needs to be analyzed
file_list = getFileList(dir); //Save a list of all files in directory "dir" to "file_list" 

setBatchMode(true); //Don't physically render images

for(a=0; a<file_list.length; a++){ //For each file in the list
	if(endsWith(file_list[a], ".tif")){ //Check that file name ends with ".tif"
		Ext.setId(dir+file_list[a]); //CHeck metadata to see if image only contains one slice
		Ext.getSizeT(sizeT);
		if(sizeT == 1){
			open(dir+file_list[a]); //Open the file in the give directory path
			intensityMeasurement(file_list[a]); //Process the image that was just opened
		}
	}
}

//Save the mask stack
selectWindow("Mask stack");
saveAs(".tif", dir+"Mask stack.tif");

function intensityMeasurement(image1) {
	  selectWindow(image1); //Make the most recent window opened the active window
	  selection_valid = false; // this line is saving the selection_valid as false
	  while (selection_valid == false){ //this loop is to make sure that the user actually makes a correct selection
	    run("Set Measurements...", "area mean min integrated redirect=None decimal=3"); // this line is selecting the properties of the measurement 
		run("Select None"); // this line removes all selections
		setTool("freehand"); //this line is selecting the free hand tool
		setBatchMode("show"); //Show the active image
		waitForUser("Trace outline of leans and press okay"); //this line selects the freehandtool and trace the outline of the lens
		if (selectionType() ==3){ // this line selects the free hand tool
			selection_valid = true; // this line checks whether the selection made is correct 
		}
		else {
			showMessage("Please draw a freehand selection");
		}
	}
	setBatchMode("hide"); //Hide active image
	run("Measure"); // this line is selecting the analyze --> measure 

	//Create a stack to record the ROIs that were drawn.
	selectWindow(image1); //Select the window being analyzed
	getDimensions(width, height, channels, slices, frames); //Get the pixel dimensions of the imge
	newImage("Mask slice", "8-bit black", width, height, 1); //Create a new image with the same dimensions
	
	//Transfer selection to mask window and fill with white
	selectWindow("Mask slice"); //Make the mask window active
	run("Restore Selection"); //Transfer the freehand selection to the mask window
	setForegroundColor(255, 255, 255); //Set foreground to white
	run("Fill", "slice"); //Fill ROI with foreground color (white);
	run("Select None"); //Remove the selection

	//Add mask to stack
	if(isOpen("Mask stack")){ //If there is already a stack, add slice to stack
		run("Concatenate...", "  title=[Mask stack] open image1=[Mask stack] image2=[Mask slice] image3=[-- None --]"); //Contatenate slice onto end of stack
	}
	else{ //Rename the first image mask to stack
		selectWindow("Mask slice");
		rename("Mask stack");	
	}
	selectWindow("Mask stack");
	close("\\Others"); //Close all images except for mask stack
} 
