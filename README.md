![Alt text](images/tekst_logo.png?raw=true "Optional Title")
The Cgrid-toolbox can be used to generate rectangular representations of brain areas. This approach is meant to make interpretation of cortical patterns and localization in the cortex more straightforward. Details on the procedure can be found on: https://www.biorxiv.org/content/10.1101/786368v1. The toolboox is an extension to FreeSurfer package and it runs under the IDL virtual machine, all of which are available free of charge. The toolbox is fully GUI driven and the output is compatible with all of the main MRI/fMRI software analyses packages including SPM and FSL. The full installation instructions can be found in cgrid_manual.pdf. The process includes extracting and flattening portions of cortex, defining sets of 4 borders, and assigning Cartesian x and y coordinates to all vertices within the patch by fitting and interpolating te defined borders. The x/y-labels can then be used to warp volumetric data or any surface based metric into a rectangular shape.

![Alt text](images/cgrid_anmimated.gif?raw=true "Optional Title")


Cgrids can be generated for any portion of cortex for which 4 borders can be defined based on any of the FreeSurfer annotation schemes. The entire surface of the cortex can be represented as Cgrids.


![Alt text](images/rotating_brain.gif?raw=true "Optional Title")
