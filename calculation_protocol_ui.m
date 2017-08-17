function varargout = calculation_protocol_ui(varargin)
% CALCULATION_PROTOCOL_UI MATLAB code for calculation_protocol_ui.fig
%      CALCULATION_PROTOCOL_UI, by itself, creates a new CALCULATION_PROTOCOL_UI or raises the existing
%      singleton*.
%
%      H = CALCULATION_PROTOCOL_UI returns the handle to a new CALCULATION_PROTOCOL_UI or the handle to
%      the existing singleton*.
%
%      CALCULATION_PROTOCOL_UI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CALCULATION_PROTOCOL_UI.M with the given input arguments.
%
%      CALCULATION_PROTOCOL_UI('Property','Value',...) creates a new CALCULATION_PROTOCOL_UI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before calculation_protocol_ui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to calculation_protocol_ui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help calculation_protocol_ui

% Last Modified by GUIDE v2.5 31-Jul-2017 18:11:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @calculation_protocol_ui_OpeningFcn, ...
                   'gui_OutputFcn',  @calculation_protocol_ui_OutputFcn, ...
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


% --- Executes just before calculation_protocol_ui is made visible.
function calculation_protocol_ui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to calculation_protocol_ui (see VARARGIN)

% Choose default command line output for calculation_protocol_ui
handles.output = hObject;

% set up the variables to hold initial problem data
handles.currentmode = 'initializing'; 
handles.tic_start = tic; 
handles.data = []; 
handles.maxtoanswer = 60; %max # of seconds allowed to answer
set(handles.timerdisplay,'String',sprintf('%i', handles.maxtoanswer)); 
handles.countdown = timer('executionMode','FixedRate', 'StartDelay', 1, ...
    'TimerFcn',@(h, e) timedecrement(h, e, handles)); 
handles.timerdisplay.set('ForegroundColor', 'black'); 
stop(handles.countdown); 

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes calculation_protocol_ui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = calculation_protocol_ui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

% sequence goes like this : 
% initializing (only once at beginning of session) or problem (new problem)
% answer (answer has been given by participant -- stop the timer, but don't
%   display the answer yet)
% solution (display the solution)
% ended (exits all other cases, displays statistics)
h_display = handles.mathdisplay; 

if strcmp(handles.currentmode, 'ended')
    return; %session ended.
end

%'e' forces end of session and displays stats
if eventdata.Key == 'e'
    %stop timer
    stop(handles.countdown);
    h_display.FontSize = 100; 
    if ~(isempty(handles.data))
        answers = cell2mat(handles.data(:,6)); 
        times = cell2mat(handles.data(:,5)); 
        mean_time_correct = mean(times(answers == 'y')); 
        if (isnan(mean_time_correct)) mean_time_correct = 0; end;
        h_display.String = sprintf(' %i correct, %i incorrect, %i N/A\nAverage %.2f seconds per correct answer', ...
            sum(answers == 'y'), sum(answers == 'n'), sum(answers == 'x'), mean_time_correct); 
    else 
        h_display.String = 'No questions scored.'; 
    end
    handles.currentmode = 'ended'; 
    guidata(hObject, handles);
    return;
else
    if h_display.FontSize ~= 320
        h_display.FontSize = 320; 
    end
end
    
if strcmp(handles.currentmode, 'initializing') || strcmp(handles.currentmode, 'problem')
    if strcmp(handles.currentmode, 'problem')
        % we are in "new problem" mode, so store the results from the last
        % problem based on key input (y, n, x)
        keyinput = eventdata.Key; 
        if (handles.problem_elapsed > handles.maxtoanswer) 
            keyinput = 'x'; 
        end
        if isempty(handles.data) 
            %make handles.data be our completed problem information
            disp('creating new data store'); 
            handles.data = {handles.problem_starttime, handles.current_problem(1), handles.current_problem(2), handles.current_problem(3), handles.problem_elapsed, keyinput}; 
            handles.data
        else
            %add our completed problem information to the handles.data
            disp('adding to data store'); 
            handles.data = [handles.data; {handles.problem_starttime, handles.current_problem(1), handles.current_problem(2), handles.current_problem(3), handles.problem_elapsed, keyinput}]; 
            handles.data
        end
    end
    disp('generating new problem');
    handles.problem_starttime = now; 
    [input_1, input_2, answer] = newproblem(); 
    current_problem = [input_1, input_2, answer]; 
    handles.current_problem = current_problem;  
    h_display.String = sprintf('\t   %i \n x %i', handles.current_problem(1), handles.current_problem(2)); 
    handles.statsdisplay.String = sprintf('%s elapsed since session start', datestr(toc(handles.tic_start)/86400, 'HH:MM:SS')); 
    handles.currentmode = 'answer'; 
    tic; 
    % start counting down the timer
    handles.timerdisplay.String = handles.maxtoanswer; 
    handles.timerdisplay.set('ForegroundColor', 'black'); 
    start(handles.countdown); 
    guidata(hObject, handles);
elseif strcmp(handles.currentmode, 'answer')
    % participant is giving answer ... just stop the timer, but don't
    % display the solution yet
    handles.problem_elapsed = toc;
    if handles.problem_elapsed > handles.maxtoanswer 
        handles.statsdisplay.String = 'Time expired before answer!'
    else
        handles.statsdisplay.String = sprintf('%.0f seconds to answer!', min(handles.problem_elapsed, handles.maxtoanswer)); 
    end
    stop(handles.countdown); 
    handles.currentmode = 'solution'; %next keypress will show the solution
    guidata(hObject, handles);
elseif strcmp(handles.currentmode, 'solution')
    disp('showing current solution'); 
    h_display.String = sprintf('%i x %i = %i', handles.current_problem(1), handles.current_problem(2), handles.current_problem(3)); 
    handles.currentmode = 'problem'; %next keypress will show a new problem
    guidata(hObject, handles);
end
        
function timedecrement(a,b, currenthandles)
    t=str2double(get(currenthandles.timerdisplay,'String')); %the t value for the string
    t=t-1;
    timestring = 'Time up!'; 
    %see if t is 0; if not do
    if (t>0)
        timestring = num2str(t); 
    end
    if (t<10) 
        set(currenthandles.timerdisplay, 'ForegroundColor', 'red'); 
    end
    set(currenthandles.timerdisplay,'String',timestring); %update t

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
stop(handles.countdown); 
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~(isempty(handles.data))
    S = 8; 
    ts = sprintf( '%08x', uint32(rand(1,ceil(S/8)) * 2^32))
    savefile = sprintf('%s.mat', ts(1:S)) 
    sessiondata = handles.data; 
    save(savefile, 'sessiondata'); 
end

% Hint: delete(hObject) closes the figure
delete(hObject);
