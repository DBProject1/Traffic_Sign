function varargout = Traffic(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Traffic_OpeningFcn, ...
                   'gui_OutputFcn',  @Traffic_OutputFcn, ...
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

function Traffic_OpeningFcn(hObject, eventdata, handles, varargin)

global W;
W = Wormhole;
W.execute('execfile(''load.py'')');
pause(3);

handles.output = hObject;


guidata(hObject, handles);





function varargout = Traffic_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


function listbox1_Callback(hObject, eventdata, handles)
    list = get(handles.listbox1,'string');
    selection = get(handles.listbox1,'value');
    axes(handles.axes1);
    global Img;
    Img = imread(fullfile(handles.folder,cell2mat(list(selection))));
    image(Img);
    axis off;

function listbox1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton1_Callback(hObject, eventdata, handles)
    handles.folder = uigetdir;
    images = dir(fullfile(handles.folder,'*.ppm'));
    for it = 1:length(images)
        imglist{it} = images(it).name;
    end
    set(handles.listbox1,'String',imglist);
    guidata(hObject,handles);

function pushbutton2_Callback(hObject, eventdata, handles)
    global Img;
    global W;
    [ result] = process(Img,W);
    imshow(result);