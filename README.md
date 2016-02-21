# Data Processing for Block-wise Data Analytics

## MTConnect Power and Controller Data Extractor

The MTConnect data extractor is a set of Matlab codes used to transform the data collected by the MTConnect agent from the Mori Seiki controller and the corresponding HSPM (High Speed Power Meter)

### Architecture

	* Main functions and sub-functions
		- MTC_Data_Log_Transformer_Advanced.m is the main function. This can be called by launching it directly from Matlab command line or running it from the script editor
		'''matlab
		MTC_Data_Log_Transformer_Advanced
		'''
		
		- simulatecut.m : Called by MTC_Data_Log_Transformer_Advanced.m - simulates the entire cutting process by meshing the surface of the part.
		- removematerial.m : Calculates the elements (after meshing) removed by a motion of the tool
		- getcorners.m : Calculates the corners of the tool motion for a particular line of NC code
		- getcircleR.m : Calculates the elements removed in a line of NC code, with either a G02 or G03 (circular interpolation), where radius R is defined directly
		- getcircleIJK.m : Calculates the elements removed in a line of NC code, with either a G02 or G03 (circular interpolation), where radius is not defined directly, but as a function of distances I, J and K
		- getclimbconventional.m : Calculates the number of elements removed on each side and determines whether an operation is climb milling or conventional milling
		- getspiralIJK.m : Calculates the elements removed in a spiral motion of the tool
		- getZcut.m : Calculates the elements removed in a plunge motion of the tool
		- sample.m : Generates a data sample
		- time.m : Generates the time transpired in seconds since the beginning of the NC code
		
	* Parameters
		- Filename(s) : The filename(s) must point to an Excel sheet in the LOGFILES folder following the format / procedure below
		- Batch quantity `q` : The batch quantity `q` determines how many data files are to be processed in a batch. Set `q` to an integer and have the same number of filenames in the `filenames` variable. Follow the comments in the codes
		- Calibration Factor `CF` : This is based on calibration with the Yokogawa and scales the data to give absolute power values. Use 0.038 for the right machine and 0.046 for the left machine.
		- Workpiece geometry : Parameters `length`, `breadth` and `height` define the geometry of the part. Length is the dimension in X-axis, breadth is the dimension in Y-axis and Height is the dimension in Z-axis. All dimensions in mm.
		- Tool diameter : `tooldia` is the variable for the tool diameter in mm.
		- Mesh size : The `ms` variable directly determines the accuracy of the data processing, and inversely the time it will take to run.
		- Tolerance : `tolerance` determines how much tolerance is given to the decision made in classifying climb and conventional milling. Amount of material removed on either side of the tool motion is compared to determine this. If the amount of material one side is greater than `tolerance` times the other, a classification is made.
		- Initial Geometry : Set initial part geometry here. For flat face,
			'''matlab
			currentZ = zeros(1,N);
			'''
			For slots down the center with different widths of 5 and 10 mm,
			'''matlab
			for e=1:N
      			if Cx(e)>-10 && Cx(e)<10 && Cy(e)>0
          			currentZ(e)=-20;
      			elseif Cx(e)>-5 && Cx(e)<5 && Cy(e)<0
          			currentZ(e)=-20;
      			else currentZ(e)=0;
      			end
  			end
			'''
			
### Data extraction procedure
	
	1. Save raw MTConnect data into a .txt file in the LOGFILES folder
	2. Create a new Excel document, with extension .xlsx and same filename as the .txt file
	3. Copy entire contents of the raw data into the newly created Excel file
	4. Use the Paste Wizard at the bottom of the Excel sheet once you paste the data
	5. Use delimiters '|', ',' and '[space]' while pasting
	6. Delete the initial rows until the first line of power data
	7. Run MTC_Data_Log_Transformer_Advanced.m in Matlab with the appropriate parameters and filename
	
### Saved data

	Three files are created on running MTC_Data_Log_Transformer_Advanced.m:
	* filename_alpha : Consists of the processed block-wise data without any cutting simulation
	* filename_beta : Consists of entire processed block-wise data with cutting simulation
	* filename_variables : Consists of the MATLAB variables of the matrix stored in filename_beta called `EData`