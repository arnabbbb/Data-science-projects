# Data-science-projects

Note : This readme is concerned with the IR python code.

Objective : To convert a video into images. Then compare the images to a base image. If the images being compared are different from the base image then an incident is triggered.

The code is divided into two parts :

1) Video to image comparision :

  Here are the packages used for that
      cv2 : Changes video to images
      os  : Creating new path for 
      
2) Image Comparision :
    Here are the packages used for that
      shutil : placing the hard coded image in the empty file
      os  : Creating new path for 
      sentence_transformers  : Used in model
      PIL  : Used in model
      glob  : used in model
   
   
FAQ :
   
Where will we store the photos? 

The photos will be stored to a directory using python code. 
This is how the code looks in python. The path given in imwrite() is where the photos are stored. 


How will we configure the capture rate in the video stream? 

Python already has a default capture rate in the cv2 library. We are currently using the default only. But it can be changed using the following lines of code :  
In OpenCV python, the FPS can be set as follows: 

cap = cv2. VideoCapture(0) 
cap. set(cv2. cv. CV_CAP_PROP_FPS, 60) 


What is the location of the base image? 

We will be creating a directory using python and store the base image there. (In our case the first image is the base image, it can also be hard coded) 


What happens after the image is processed? Will it be dumped or stored? 

Both.  
There are two files here.
One file is just converting the video into images and storing it. (All the pictures are stored here) 
The second file takes the base image and keeps it. Then it appends one image from the previous file, compares it to the base image, and then pops it. It repeats this operation till all the images in the first file have been iterated over. (This file dumps all the images except the base image) 


How is the threshold configured? How is the comparison metric measured? 

The threshold has to be understood manually. We test the scores that the model gives that we know are fine v/s those with some kind of a disturbance. We can come up with a threshold score accordingly. 
