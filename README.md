<html>


<h1>particle_tracking</h1>

<p>A single-particle tracking library written in MATLAB.</p>

<h3>Files:</h3>
<ul>

<li>autoTrack:<br><span style='width:10px;'></span>
Automatically imports all tif files in a directory using importMovie,
tracks using findParticle, and saves the movie and tracked arrays to files.
Has an option of importing the movie in chunks, for times when the entire 
movie is too large to fit into memory. This results in several movie and
tracked files.
</li>

<li>findParticle:<br><span style='width:10px;'></span>
Contains the actual tracking algorithm.
</li>

<li>PlayMovie:<br><span style='width:10px;'></span>
Plays a movie imported using importMovie. Can be used to overlay the tracking
onto the actual images.
</li>

<li>superTrack:<br><span style='width:10px;'></span>
Script that utilizes autotrack to track all movies in a data set.
</li>

</ul>
</html>
