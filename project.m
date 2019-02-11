% project.m
% 
% Author: Imtiaz Ahmed
% CSc 4630/6630 Semester Project
%
% Created and tested using MATLAB r2018a
%
% Description: This program serves as an image transformation GUI. The user
% selects an image file from their computer and can perform a variety of
% operations on them including, but not limited to, pixelation, flip,
% rotate, negative, vectorization, etc.
%
% Input: The program takes an input of an image file. Multiple formats are
% able to be read by MATLAB including .jpg, .png, .jpeg, etc. Additionally,
% for certain functions, the user will be required to specify a specific
% area of the image they wish to mutate, or certain adjustable parameters
% for image transformation functions.
%
% Output: After every (successful) operation, the program will display the
% new image in the GUI, and the user can continue to perform
% transformations. The user can save a session for later using the 'Save &
% Quit' button, which will export a .mat file with the same name as the
% original file. The user can also opt to export the transformed image in
% the same format it was originally saved in.
% 
% Usage: Run this program in the MATLAB editor with command
% >> project
function varargout = project(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @project_OpeningFcn, ...
                   'gui_OutputFcn',  @project_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% Sets up the figure
function project_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to project (see VARARGIN)

% Get file, convert to double precision to maintain consistency
% throughout the program.
[file,path] = uigetfile({'*.*'});
try
    p = imread(fullfile(path,file));
%     p = imread('pics/spiderman.jpg');
    p = im2double(p);
catch e
    disp(e.message);
    disp('Program ending...');
    close;
    return;
end

% If grayscale, convert to rgb to work seamlessly with our functions.
if (size(size(p),2) == 2)
    p = cat(3,p,p,p);
end

% Make record of filename, so we can save and quit accordingly
handles.filename = file;
% handles.filename = 'spiderman.jpg';

handles.stack = Stack({p});
imshow(p);

% Choose default command line output for project
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = project_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
try
    varargout{1} = handles.output;
catch
    
end

% Validate ginput coordinates
function [x1,x2,y1,y2] = validate_ginput(x_vals,y_vals,p)
% Coordinates are rounded to nearest integer to avoid warning when indexing
x1 = round(x_vals(1));
x2 = round(x_vals(2));
y1 = round(y_vals(1));
y2 = round(y_vals(2));

% If the first value is greater than the second value, exchange them to
% prevent creating an empty array when adjusting.
if (x1 > x2)
   temp = x1;
   x1 = x2;
   x2 = temp;
end
if (y1 > y2)
   temp = y1;
   y1 = y2;
   y2 = temp;
end

% If the values exceed picture bounds, clamp them to the min/max
if (x1 < 0)
    x1 = 1;
end
if (x2 > size(p,2))
    x2 = size(p,2);
end
if (y1 < 0)
    y1 = 1;
end
if (y2 > size(p,1))
    y2 = size(p,1);
end

% Toggles UIControl elements (push buttons) on/off 
function buttonControl = buttonControl(handles,state)
fields = fieldnames(handles);
for i = 1:numel(fields)
    x = class(handles.(fields{i}));
    if ( strcmp(x,'matlab.ui.control.UIControl'))
        set(handles.(fields{i}), 'Enable', state)
    end
end

% Red eye
function pushbutton1_Callback(hObject, eventdata, handles)
buttonControl(handles,'off');
title('Select two points over a single eye for red-eye removal.')
[x_vals,y_vals] = ginput(2);
p = handles.stack.peek();
[x1,x2,y1,y2] = validate_ginput(x_vals,y_vals,p);

% Red eye removal
for x = x1:x2
    for y = y1:y2
        r = p(y,x,1);
        g = p(y,x,2);
        b = p(y,x,3);
        % If the red value is over 50% that of avg(b,g), we set red to
        % match avg(b,g)
        rIntensity = r/((g+b)/2);
        if (rIntensity > 1.5)
            p(y,x,1) = (g+b)/2;
        end
    end
end
imshow(p);
handles.stack = handles.stack.push(p);
buttonControl(handles,'on');
% This last line updates our universal stack
guidata(hObject,handles)

% Color bar
function pushbutton2_Callback(hObject, eventdata, handles)
try
    buttonControl(handles,'off');

    title('Select two points to overlay color bar.')
    [x_vals,y_vals] = ginput(2);
    p = handles.stack.peek();
    [x1,x2,y1,y2] = validate_ginput(x_vals,y_vals,p);

    % UI prompt to get RGB color array where R,G,B = [0,1]
    c = uisetcolor;

    % Set all pixels in range to specific color
    for x = x1:x2
        for y = y1:y2
            p(y,x,1) = c(1);
            p(y,x,2) = c(2);
            p(y,x,3) = c(3);
        end
    end
    imshow(p);
    handles.stack = handles.stack.push(p);
    buttonControl(handles,'on');
    % This last line updates our universal stack
    guidata(hObject,handles)
catch e
    disp(e.message)
    buttonControl(handles,'on');
end

% Pixelate
function pushbutton3_Callback(hObject, eventdata, handles)
buttonControl(handles,'off');

title('Select two points to pixelate.')
[x_vals,y_vals] = ginput(2);
p = handles.stack.peek();
[x1,x2,y1,y2] = validate_ginput(x_vals,y_vals,p);

% Number of pixels to blur 'n', default 11
% Get user input, use try/catch just in case.
prompt = {'Set number of pixels for pixelation'};
title1 = 'Set number of pixels for pixelation';
definput = {'11'};
try
    n = inputdlg(prompt,title1,[1 40],definput);
    n = str2double(n);
catch e
    disp(e.message)
    disp('Default value of 11 will be used.')
    n = 11;
end

xt = x1 + n;
yt = y1 + n;
yreset = y1;
% Blur, set all nxn squares to average RGB value of square
while(xt <= x2)
    while (yt <= y2)
        totalR = 0.0;
        totalG = 0.0;
        totalB = 0.0;
        for x = x1:xt
            for y = y1:yt
                totalR = totalR + p(y,x,1);
                totalG = totalG + p(y,x,2);
                totalB = totalB + p(y,x,3);
            end
        end
        for x = x1:xt
            for y = y1:yt
                p(y,x,1) = totalR/(n*n);
                p(y,x,2) = totalG/(n*n);
                p(y,x,3) = totalB/(n*n);
            end
        end
        y1 = yt;
        yt = yt + n;
    end
    x1 = xt;
    xt = xt + n;
    y1 = yreset;
    yt = y1 + n;
end
imshow(p);
handles.stack = handles.stack.push(p);
buttonControl(handles,'on');
% This last line updates our universal stack
guidata(hObject,handles)

% Undo
function pushbutton4_Callback(hObject, eventdata, handles)
% If the Stack only has one element...
if (size(handles.stack.stack,2) == 1)
    disp('There is nothing more you can undo...')
else
    disp('Undone.')
    handles.stack = handles.stack.pop;
    imshow(handles.stack.peek);
end
% This last line updates our universal stack
guidata(hObject,handles)

% Save
function pushbutton5_Callback(hObject, eventdata, handles)
filename = strsplit(handles.filename, '.');
tosave = strcat(filename(1), '.mat');
% I temporarily turn warnings off to supress the warning that saving
% graphics handle variables can create large files.
warning('off','all')
save(tosave{1})
warning('on','all')
close
return;

% Flip
function pushbutton6_Callback(hObject, eventdata, handles)
p = handles.stack.peek();

p = flip(p);

imshow(p);
handles.stack = handles.stack.push(p);
guidata(hObject,handles)

% Rotate
function pushbutton7_Callback(hObject, eventdata, handles)
% Since we are getting user input, we use try/catch
try
    p = handles.stack.peek();
    
    % Get user input
    prompt = {'Enter degrees to rotate clockwise'};
    title = 'Rotate';
    definput = {'90'};
    a = inputdlg(prompt,title,[1 40],definput);
    
    % Rotate
    p = imrotate(p,str2double(a)*-1);

    imshow(p);
    handles.stack = handles.stack.push(p);
    guidata(hObject,handles)
catch e
    disp(e.message);
end    

% Vectorize
function pushbutton8_Callback(hObject, eventdata, handles)
% Since we are getting user input, we use try/catch
try
    p = handles.stack.peek();
    
    prompt = {'Number of colors:','Qm: ','Qe: '};
    title1 = 'Input';
    dims = [1 35];
    definput = {'8','1','3'};
    a = inputdlg(prompt,title1,dims,definput);
    
    numColors = str2double(a{1});
    Qm = str2double(a{2});
    Qe = str2double(a{3});
        
    % Make our RGB image an indexed image using user specified amount of
    % colors
    [X, map] = rgb2ind(p,numColors);
    % Set our new color map temporarily
    colormap(map);
    % Perform ditherization to achieve desired effect
    p = dither(p, map, Qm, Qe);
    
    % To avoid issues b/c output image is indexed, we will write an read
    % again to maintain our image standard of a 3D double precision
    imwrite(p,map,'tempyeet.jpg');
    p = imread('tempyeet.jpg');
    p = im2double(p);

    if (size(size(p),2) == 2)
        p = cat(3,p,p,p);
    end
    
    imshow(p)
    handles.stack = handles.stack.push(p);
    guidata(hObject,handles)
catch e
    disp(e.message)
end

% Export
function pushbutton9_Callback(hObject, eventdata, handles)
% I add '_new' to the filename for new images for simplicity's sake
try
    filename = strsplit(handles.filename, '.');
    a = strcat(filename(1),'_new.',filename(2));
    imwrite(handles.stack.peek(),a{1})
    fprintf('Wrote image as %s \n', a{1})
catch e
    disp(e.message)
    disp('Unable to export file.')
end

% Brightness
function pushbutton10_Callback(hObject, eventdata, handles)
try
    buttonControl(handles,'off');
    title('Select two points over which you want to adjust brightness.')
    [x_vals,y_vals] = ginput(2);
    p = handles.stack.peek();
    [x1,x2,y1,y2] = validate_ginput(x_vals,y_vals,p);
    
    prompt = {'Enter a value for which you want to adjust brightness.'};
    title1 = 'Enter a positive or negative decimal value';
    dims = [1 35];
    % Through our tests, we found that this value suited most images
    definput = {'0.1'};
    a = inputdlg(prompt,title1,dims,definput);
    a = str2double(a);
    q = p+a;
    
    % Set pixels we adjusted in q to match ginput in p.
    for x = x1:x2
        for y = y1:y2
            p(y,x,1) = q(y,x,1);
            p(y,x,2) = q(y,x,2);
            p(y,x,3) = q(y,x,3);
        end
    end
    
    imshow(p);
    handles.stack = handles.stack.push(p);
    buttonControl(handles,'on');
    guidata(hObject,handles)
catch e
    disp(e.message)
    buttonControl(handles,'on');
end

% Contrast
function pushbutton11_Callback(hObject, eventdata, handles)
try
    buttonControl(handles,'off');
    title('Select two points over which you want to adjust contrast.')
    [x_vals,y_vals] = ginput(2);
    p = handles.stack.peek();
    [x1,x2,y1,y2] = validate_ginput(x_vals,y_vals,p);
    
    prompt = {'low rgb in:','high rgb in:','low rgb out:','high rgb out'};
    title1 = 'Enter values such that lowIn,lowOut < highIn, highOut';
    dims = [1 35];
    % Through our tests, we found these default values suited most images
    definput = {'0.1','0.5','0','1'};
    a = inputdlg(prompt,title1,dims,definput);
    
    lowin = str2double(a{1});
    highin = str2double(a{2});
    lowout = str2double(a{3});
    highout = str2double(a{4});
    
    q = imadjust(p,[lowin, highin], [lowout, highout]);
    % Set pixels we adjusted in q to match ginput in p.
    for x = x1:x2
        for y = y1:y2
            p(y,x,1) = q(y,x,1);
            p(y,x,2) = q(y,x,2);
            p(y,x,3) = q(y,x,3);
        end
    end
    
    imshow(p);
    handles.stack = handles.stack.push(p);
    buttonControl(handles,'on');
    guidata(hObject,handles)
catch e
    disp(e.message)
    buttonControl(handles,'on');
end

% Color Tint
function pushbutton12_Callback(hObject, eventdata, handles)
try
    buttonControl(handles,'off');
    title('Select two points to overlay color tint.')
    [x_vals,y_vals] = ginput(2);
    p = handles.stack.peek();
    [x1,x2,y1,y2] = validate_ginput(x_vals,y_vals,p);

    % UI prompt to get RGB color array where R,G,B = [0,1]
    c = uisetcolor;

    % Set all pixels in range to average between selected tint and actual
    for x = x1:x2
        for y = y1:y2
            p(y,x,1) = (p(y,x,1)+c(1))/2;
            p(y,x,2) = (p(y,x,2)+c(2))/2;
            p(y,x,3) = (p(y,x,3)+c(3))/2;
        end
    end
    imshow(p);
    handles.stack = handles.stack.push(p);
    buttonControl(handles,'on');
    % This last line updates our universal stack
    guidata(hObject,handles)
catch e
    disp(e)
    buttonControl(handles,'on');
end

% Color Picker
function pushbutton13_Callback(hObject, eventdata, handles)
% Since user input we use try/catch
try
    buttonControl(handles,'off');
    title('Select one point to pick color.')
    p = handles.stack.peek();
    % Get one point, round values to avoid indexing issues
    [x,y] = ginput(1);
    x = round(x);
    y = round(y);
    % Get r,g,b values, print to user.
    r = p(y,x,1);
    g = p(y,x,2);
    b = p(y,x,3);
    fprintf('R: %1.4f, G: %1.4f, B: %1.4f \n', r,g,b)
    buttonControl(handles,'on');
    imshow(p);
catch e
    disp(e.message)
    buttonControl(handles,'off');
end

% Sharpen
function pushbutton14_Callback(hObject, eventdata, handles)
% Since we take user input, we try/catch
try
    p = handles.stack.peek();
    
    % Different thresholding methods for binarization
    list = {'global','adaptive'};
    [i,returned] = listdlg('PromptString','Select a sharpening method.','SelectionMode','single','ListString',list);

    % If we selected global, simply perform normal binarization
    if (i == 1)
        p = imbinarize(p);
        imwrite(p,'tempyeet.jpg');
        p = imread('tempyeet.jpg');
        p = im2double(p);
        if (size(size(p),2) == 2)
            p = cat(3,p,p,p);
        end
    elseif (i == 2)
        % Adaptive thresholding requires some more information to work more
        % precisely, such as whether the foreground or background is
        % brighter, as well as a degree of which MATLAB will distinguish
        % between foreground and background pixels.
        list = {'bright','dark'};
        [i,returned] = listdlg('PromptString','Select bright if the foreground is brighter than the background, else select dark.','SelectionMode','single','ListString',list,'ListSize',[600,100]);
        a = inputdlg({'Enter a sensitivity value [0,1]'},'Input',[1 35],{'0.5'});
        p = imbinarize(p,'adaptive','ForegroundPolarity',list{i},'Sensitivity', str2double(a));
        imwrite(p,'tempyeet.jpg');
        p = imread('tempyeet.jpg');
        p = im2double(p);
        if (size(size(p),2) == 2)
            p = cat(3,p,p,p);
        end
    end
    imshow(p);
    handles.stack = handles.stack.push(p);
    guidata(hObject,handles)
catch e
    disp(e.message)
end

% Black & White
function pushbutton15_Callback(hObject, eventdata, handles)
try
buttonControl(handles,'off');
title('Select two points to change to black & white.')
[x_vals,y_vals] = ginput(2);
p = handles.stack.peek();
[x1,x2,y1,y2] = validate_ginput(x_vals,y_vals,p);

% Since im2bw() makes image logical 2D, we must restore it to our standard
% of 3D double precision.
q = im2bw(p);
q = im2double(q);
if (size(size(q),2) == 2)
    q = cat(3,q,q,q);
end

for x = x1:x2
    for y = y1:y2
        p(y,x,1) = q(y,x,1);
        p(y,x,2) = q(y,x,2);
        p(y,x,3) = q(y,x,3);
    end
end

imshow(p);
handles.stack = handles.stack.push(p);
buttonControl(handles,'on');
guidata(hObject,handles)
catch e
    disp(e.message)
    buttonControl(handles,'on');
end

% Negative
function pushbutton16_Callback(hObject, eventdata, handles)
try
    buttonControl(handles,'off');
    title('Select two points over which you want to make negative.')
    [x_vals,y_vals] = ginput(2);
    p = handles.stack.peek();
    [x1,x2,y1,y2] = validate_ginput(x_vals,y_vals,p);

    q = imcomplement(p);

    % Set pixels we adjusted in q to match ginput in p.
    for x = x1:x2
        for y = y1:y2
            p(y,x,1) = q(y,x,1);
            p(y,x,2) = q(y,x,2);
            p(y,x,3) = q(y,x,3);
        end
    end

    imshow(p);
    handles.stack = handles.stack.push(p);
    buttonControl(handles,'on');
    guidata(hObject,handles)
catch e
    disp(e.message)
    buttonControl(handles,'on');
end

% Painting
function pushbutton17_Callback(hObject, eventdata, handles)
try
    p = handles.stack.peek();

    % Get user input for how many superpixels we should use.
    prompt = {'Enter a number of superpixels'};
    defaults = {'1000'};
    a = inputdlg(prompt,'Input',[1 35],defaults);

    % superpixels(p,n) creates n 'superpixels' for image p, where each
    % superpixel consists of similar RGB values
    [L,N] = superpixels(p,str2double(a));
    q = zeros(size(p),'like',p);
    index = label2idx(L);
    % Set the rgb values of each pixel in output image to be average rgb value
    % for each superpixel region
    for i = 1:N
        r = index{i};
        g = index{i} + size(p,1)*size(p,2);
        b = index{i} + 2*size(p,1)*size(p,2);
        q(r) = mean(p(r));
        q(g) = mean(p(g));
        q(b) = mean(p(b));
    end
    p = q;

    imshow(p);
    handles.stack = handles.stack.push(p);
    guidata(hObject,handles)
catch e
    disp(e.message)
end

% Crop
function pushbutton18_Callback(hObject, eventdata, handles)
try
    buttonControl(handles,'off');
    title('Select two points over which to crop the image.')
    [x_vals,y_vals] = ginput(2);
    p = handles.stack.peek();
    [x1,x2,y1,y2] = validate_ginput(x_vals,y_vals,p);
    
    p = imcrop(p,[x1, y1, x2-x1, y2-y1]);
    imshow(p);
    handles.stack = handles.stack.push(p);
    buttonControl(handles,'on');
    guidata(hObject,handles)
catch e
    disp(e.message)
    buttonControl(handles,'on');
end
