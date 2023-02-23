#!/usr/bin/env python
# coding: utf-8

# ### The 3 steps :
# 
# 1) Read the video and convert it into a series of images and save it.
# 
# 2) Compare the series of images to a base image (going image by image) and assign a simillarity score
# 
# 3) Raise an incident if a certain threshold of similarity score is crossed

# ### Step 1

# In[2]:


# importing the packages for video to image comparision

import cv2
import os
import shutil


# In[3]:


# changing the working directory

os.chdir('C:\Anomaly detection IR')
os.getcwd()


# In[4]:


# creating video object

vid = cv2.VideoCapture('C:\\Anomaly detection IR\\video\\IR video.mp4')
current_frame = 0


# In[5]:


# creating a path where the video will be converted to images and stored

if not os.path.exists('video to images'):
    os.makedirs('video to images')


# In[6]:


# converting the video to images and storing in the folder (it gives an error, but does the job)

while(True):
    success, frame = vid.read()
    
    if success == False:
        break
    
    cv2.imshow('Output',frame)
    cv2.imwrite('.\\video to images\\frame' + str(current_frame)+ '.jpg', frame)
    current_frame=current_frame + 1
    
        
    if cv2.waitKey(20) & 0xFF == ord('q'):
        break


# In[7]:


# creating a path where the image comparision will be done

if not os.path.exists('Images to compare'):
    os.makedirs('Images to compare')


# ### Steps 2 and 3

# In[8]:


# importing the packages for the machine learning model

from sentence_transformers import SentenceTransformer, util
from PIL import Image
import glob


# In[9]:


# Load the OpenAI CLIP Model


print('Loading CLIP Model...')
model = SentenceTransformer('clip-ViT-B-32')


# In[17]:


#creating a text file with the command function "x" (create file if no file alerady exists)

f = open("algorithm results.txt", "w+")


# In[18]:


# storing all the concernedpaths in variables.

i = 1

image_name = 'C:\\Anomaly detection IR\\video to images\\frame{}.jpg'.format(i)
print(image_name)

image_name_rem = 'C:\\Anomaly detection IR\\Images to compare\\frame{}.jpg'.format(i)
print(image_name_rem)

image_name_fixed = 'C:\\Anomaly detection IR\\video to images\\frame0.jpg'
print(image_name_fixed)


# In[19]:


# placing the hard coded image in the empty file

shutil.copy(image_name_fixed, 'C:\\Anomaly detection IR\\Images to compare')


# ### declaring two states :
# 
# 1) 0 : No incident is raised (default)
# 
# 2) 1 : Incident is raised or maybe incident is raised
# 
# Note : Incident will only be raised if model state is 0

# In[20]:


model_state = 0


# In[21]:


# counting the number of images

# folder path
dir_path = r'C:\Anomaly detection IR\video to images'
count = 0
# Iterate directory
for path in os.listdir(dir_path):
    # check if current path is a file
    if os.path.isfile(os.path.join(dir_path, path)):
        count += 1
print('File count:', count)


# In[22]:


while i < count :
    shutil.copy(image_name, 'C:\\Anomaly detection IR\\Images to compare')
    print(image_name, 'copied')
    print('\n')
    
    
    # This is where the magic happens
    
    
    
    
    
        # Next we compute the embeddings
    # To encode an image, you can use the following code:
    # from PIL import Image
    # encoded_image = model.encode(Image.open(filepath))
    image_names = list(glob.glob('Images to compare\\*.jpg'))
    print("Images:", len(image_names))
    encoded_image = model.encode([Image.open(filepath) for filepath in image_names], batch_size=128, convert_to_tensor=True, show_progress_bar=True)

    # Now we run the clustering algorithm. This function compares images against
    # all other images and returns a list with the pairs that have the highest 
    # cosine similarity score
    processed_images = util.paraphrase_mining_embeddings(encoded_image)
    NUM_SIMILAR_IMAGES = 10 

    # =================
    # DUPLICATES
    # =================
    print('Finding duplicate images...')
    # Filter list for duplicates. Results are triplets (score, image_id1, image_id2) and is scorted in decreasing order
    # A duplicate image will have a score of 1.00
    # It may be 0.9999 due to lossy image compression (.jpg)
    duplicates = [image for image in processed_images if image[0] >= 0.999]


    # Output the top X duplicate images
    for score, image_id1, image_id2 in duplicates[0:NUM_SIMILAR_IMAGES]:
        print("\nScore: {:.3f}%".format(score * 100))
        print(image_names[image_id1])
        print(image_names[image_id2])


    # =================
    # NEAR DUPLICATES
    # =================
    print('Finding near duplicate images...')
    # Use a threshold parameter to identify two images as similar. By setting the threshold lower, 
    # you will get larger clusters which have less similar images in it. Threshold 0 - 1.00
    # A threshold of 1.00 means the two images are exactly the same. Since we are finding near 
    # duplicate images, we can set it at 0.99 or any number 0 < X < 1.00.
    threshold = 0.99
    near_duplicates = [image for image in processed_images if image[0] < threshold]


    for score, image_id1, image_id2 in near_duplicates[0:NUM_SIMILAR_IMAGES]:
        print("\nScore: {:.3f}%".format(score * 100))
        print(image_names[image_id1])
        print(image_names[image_id2])
        f = open('algorithm results.txt', 'a')
        f.write('\n')
        f.write(image_names[image_id1])
        f.write('\n')
        f.write(image_names[image_id2])
        f.write('\n')

    print('\n')
    print(score)    
    print('\n')
    if score > 0.95:
        print('No incident')
        
        f = open('algorithm results.txt', 'a')
        f.write('\n')
        f.write('No incident')
        f.write('\n')
        
        model_state = 0
        
        
    elif (score <= 0.95) & (score >= 0.92):
        if model_state == 0:
            print('maybe incident')

            f = open('algorithm results.txt', 'a')
            f.write('\n')
            f.write('maybe incident')
            f.write('\n')
            
        else:
            print('not incident')

            f = open('algorithm results.txt', 'a')
            f.write('\n')
            f.write('not incident')
            f.write('\n')
        
        model_state = 1
        
    else:
        if model_state == 0:
            print('report incident')
            
            f = open('algorithm results.txt', 'a')
            f.write('\n')
            f.write('report incident')
            f.write('\n')
        else:
            print('not incident')

            f = open('algorithm results.txt', 'a')
            f.write('\n')
            f.write('not incident')
            f.write('\n')
        
        model_state = 1


    print('\n')
    print('\n')
    
    
    
    
    os.remove(image_name_rem)
    print(image_name, 'removed')
    print('\n')
    
    i = i+1
    image_name = 'C:\\Anomaly detection IR\\video to images\\frame{}.jpg'.format(i)
    image_name_rem = 'C:\\Anomaly detection IR\\Images to compare\\frame{}.jpg'.format(i)
    


# In[16]:


f.close()


# In[ ]:




