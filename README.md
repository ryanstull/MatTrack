


# Particle Tracking

A single particle tracking library written in MATLAB.

##Files:

###autoTrack

Automatically imports all tif files in a directory using importMovie,
tracks using findParticle, and saves the movie and tracked arrays to files.
Has an option of importing the movie in chunks, for times when the entire 
movie is too large to fit into memory. This results in several movie and
tracked files.

###findParticle
Contains the actual tracking algorithm.

###PlayMovie
Plays a movie imported using importMovie. Can be used to overlay the tracking
onto the actual images.

###superTrack
Script that utilizes autotrack to track all movies in a data set.

