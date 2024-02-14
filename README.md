
Code for generation of visual stimuli, and triggering 2p imaging from VS PC for Rosie Craddock CSF experiment (see Rosie Craddock 2024 thesis for details of setup)

PC setup/dependencies: 
Install NI MAX version 18.5 or later, setup NI card to read PCIe6131 as per thesis appendix __.
Install MATLAB2022a 
Download and install data acquisition toolkit and imaging toolkit.
Dowload code from this repos and save to C:\\Code 
Download PTB3 into C:\\Code folder as described here: http://psychtoolbox.org/
Add C:\\Code and all subdirectories to the MATLAB path
Using Screen command of PTB, find identifier and screen details for LCD screen used to present animal with visual stimulus
change rigConfig.mat file such as rigConfig.w.Number = identifier found by the step above, and rigConfig.w.size is correct to the screen size (in pixels) found using the screen command
change the rigConfig.mat file such that the rigConfig.vsStimGUIIP points to the IP address of the Master PC (see Rosie Craddock 2024 thesis for details). 
Change the saveData2 code such that localRepositoryRoot= a pre-made local repository in which all visual stimulus meta data will be saved on the VS PC.
change the saveData2 code such that the remoteRepositoryRoot= a pre-made remote repository to which visual stimulus metadata will be saved
Change RosieNewListen on line 243 such that teh IP address is correct for the 2P PC.

Running experiment:
Run "RosieNewListen" from the MATLAB cmd line

Contributions and Authorship:
Contribution and authorship of each code is indicated within the first few lines of each code. Most codes were written by Rosie Craddock 2024. 
Some vodes are written by Adam Ranson, some codes written by Rosie Craddock were based on previous work by Adam Ranson.
