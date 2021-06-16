# Image-Effects-with-MATLAB
This program serves as an image transformation GUI. The user selects an image file from their computer and can perform a variety of operations on them including, but not limited to, pixelation, flip, rotate, negative, vectorization, etc.

## Input
The program takes an input of an image file. Multiple formats are able to be read by MATLAB including .jpg, .png, .jpeg, etc. Additionally, for certain functions, the user will be required to specify a specific area of the image they wish to mutate, or certain adjustable parameters for image transformation functions.

## Output
After every (successful) operation, the program will display the new image in the GUI, and the user can continue to perform transformations. The user can save a session for later using the 'Save & Quit' button, which will export a .mat file with the same name as the original file. The user can also opt to export the transformed image in the same format it was originally saved in.

### Usage
Run this program in the MATLAB editor with the command `>> project`

### Example
Vectorizing and Floyd-steinberg dithering using 4 colors, Q<sub>m</sub> = 1 and Q<sub>e</sub> = 2,  where Q<sub>m</sub> specifies the number of quantization bits to use along each color axis for the inverse color map, and Q<sub>e</sub> specifies the number of quantization bits to use for the color space error calculations.

![alt text](https://raw.githubusercontent.com/iahmed98/Image-Effects-with-MATLAB/master/src/examples/spiderman_new.jpg)

