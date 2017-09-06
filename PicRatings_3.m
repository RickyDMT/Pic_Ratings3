function PicRatings_3(varargin)
% Cycle through three sets of ratings. 1) How appetizing is food; 2) How
% much is this food worht; 3) How attractive are women.

%1. How many images:    This is currently set to run through an entire
%directory of images for food (all images rated for value & appetizing) and
%another directory of images for models. This can be changed to split foods
%images into either value or appetizing.

%2. Ratings: Rates images for appetizing and attractive on 1-9; food value
%on <$1 - $10+

%3. Save file:   This currently saves a file for each of the blocks of
%ratings and one "Fulldata" file. Either one can be eliminated.

%Glossary
%ID:            Participant ID
%Session:       Which session was this
%Date:          Date that the task was run.
%BlockNumber:   Block type. 1 = Food - Appetizing; 2 = Food - Value; 3 = Model -
%               Attractive
%BlockName:     As above, block type.
%Trial:         Trial number within block.
%Image:         Image name.
%Rating:        Rating, from 1:10
%RT:            Reaction time to make rating

global wRect w XCENTER rects mids COLORS KEYS

COLORS = struct;
COLORS.BLACK = [0 0 0];
COLORS.WHITE = [255 255 255];
COLORS.RED = [255 0 0];
COLORS.GREEN = [0 255 0];
COLORS.BLUE = [130 130 255];
COLORS.rect = COLORS.GREEN;

KbName('UnifyKeyNames');

KEYS = struct;
KEYS.ONE= KbName('1!');
KEYS.TWO= KbName('2@');
KEYS.THREE= KbName('3#');
KEYS.FOUR= KbName('4$');
KEYS.FIVE= KbName('5%');
KEYS.SIX= KbName('6^');
KEYS.SEVEN= KbName('7&');
KEYS.EIGHT= KbName('8*');
KEYS.NINE= KbName('9(');
KEYS.TEN= KbName('0)');
rangetest = cell2mat(struct2cell(KEYS));
KEYS.val = min(rangetest):max(rangetest);
%The search fo KEYS.all is completed in each block to allow 1-9 in some and
%1-10 in others.
% KEYS.all = KEYS.ONE:KEYS.NINE;

currdate = clock;

%% Keyboard stuff for Macs...


% %list devices
% [keyboardIndices, productNames] = GetKeyboardIndices;
% 
% isxkeys=strcmp(productNames,'Xkeys');
% 
% xkeys=keyboardIndices(isxkeys);
% macbook = keyboardIndices(strcmp(productNames,'Apple Internal Keyboard / Trackpad'));
% 
% %in case something goes wrong or the keyboard name isn?t exactly right
% if isempty(macbook)
%     macbook=-1;
% end
% 
% %in case you?re not hooked up to the scanner, then just work off the keyboard
% if isempty(xkeys)
%     xkeys=macbook;
% end
%%
prompt={'SUBJECT ID' 'Session'}; %'fMRI? (1 = Y, 0 = N)'};
defAns={'4444' '1'};

answer=inputdlg(prompt,'Please input subject info',1,defAns);

ID=str2double(answer{1});
SESS = str2double(answer{2});

if isempty(SESS) || SESS < 1 || ~isnumeric(SESS) || isempty(ID) || ID < 1 || ~isnumeric(ID);
    error('Session & ID must be whole number, 1 - (infinity?). Please input which session this data collection represents.')
end

% prompts = {'How appetizing is this food?','How attractive is this woman','How much do you value this food?'};
rate_order = randperm(3);

results = '/Users/canelab/Desktop/PicRatings3/Results';
% subj_imgdir = [results filesep sprintf('%d',ID)];

% savefile = [subj_imgdir filesep sprintf('PicRating_%d_%d.mat',ID,SESS)];


%%
% Find images
imgdir_food = '/Users/canelab/Desktop/PicRatings3/IMGs/Food';
imgdir_mod = '/Users/canelab/Desktop/PicRatings3/IMGs/Model';
% imgdir = 'S:\stice\TestNew\MasterPics'; %'S:\stice\Cognitive paradigms\Attentional retraining\Programmed by Erik\MasterPics_NEW';

try
    cd(imgdir_food);
    food_img = [dir('*.jpeg'); dir('*.jpg')];
    [foodapp_order] = {food_img(randperm(length(food_img))).name};
    [foodval_order] = {food_img(randperm(length(food_img))).name};
    %If half of images into appetizing & value, use this instead.
    %Randomizes images & splits list in half. Rest of task length is based
    %on these lists.
    %[food_order] = {food_img(randperm(length(food_img))).name};
    %foodapp_order = food_order(1:length(food_order)/2);
    %foodval_order = food_order((length(food_order)/2)+1:length(food_order));
    
catch
    error('Could not find food images.');
end

try
    cd(imgdir_mod);
    mod_img = [dir('*.jpeg'); dir('*.jpg')];
    %This assumes all model images will be used for all participants
    [mod_order] = {mod_img(randperm(length(mod_img))).name};
catch
    error('Could not find model images.');
end


commandwindow;

%%
%change this to 0 to fill whole screen
DEBUG=0;

%set up the screen and dimensions

%list all the screens, then just pick the last one in the list (if you have
%only 1 monitor, then it just chooses that one)
Screen('Preference', 'SkipSyncTests', 1);

screenNumber=max(Screen('Screens'));

if DEBUG==1;
    %create a rect for the screen
    winRect=[0 0 640 480];
    %establish the center points
    XCENTER=320;
    YCENTER=240;
else
    %change screen resolution
%     Screen('Resolution',0,1024,768,[],32);
    
    %this gives the x and y dimensions of our screen, in pixels.
    [swidth, sheight] = Screen('WindowSize', screenNumber);
    XCENTER=fix(swidth/2);
    YCENTER=fix(sheight/2);
    %when you leave winRect blank, it just fills the whole screen
    winRect=[];
end

%open a window on that monitor. 32 refers to 32 bit color depth (millions of
%colors), winRect will either be a 1024x768 box, or the whole screen. The
%function returns a window "w", and a rect that represents the whole
%screen. 
[w, wRect]=Screen('OpenWindow', screenNumber, 0,winRect,32,2);

%%
%you can set the font sizes and styles here
Screen('TextFont', w, 'Arial');
%Screen('TextStyle', w, 1);
Screen('TextSize',w,35);

%% Grids for Ratings
%This produces indices for the rectangles that frame the ratings numbers.
%This is now down in each block to allow 1-9 for certain blocks and 1-10
%for other blocks.

% [rects,mids] = DrawRectsGrid(1);

%% Saving Data etc.
fulldata = cell2table(cell(0,9),'VariableNames',{'ID' 'Session' 'Date' 'BlockNumber' 'BlockName' 'Trial' 'Image' 'Rating' 'RT'});

%%
for block = 1:3 %Three Different Rating blocks...
    thisblock = rate_order(block);
    switch thisblock
        case 1
            %This is FoodApp
            cd(imgdir_food);
            trialsinthisblock = length(food_img);
            blockimgs = foodapp_order;
            blockname = 'FoodApp';
%             blockdata = FoodApp;
            block_instruct_text = 'In this round, we''re going to ask you to rate how appetizing food looks!\nPress any key to continue.';
            verbage = 'How appetizing is this food?';
            [rects,mids] = DrawRectsGrid(9);
            KEYS.all = KEYS.ONE:KEYS.NINE;
            
        case 2
            %This is FoodVal
            cd(imgdir_food);
            trialsinthisblock = length(food_img);
            blockimgs = foodval_order;
            blockname = 'FoodVal';
%             blockdata = FoodVal;
            block_instruct_text = 'In this round, we''re going to ask you how much you think this food is worth!\nPress any key to continue.';
            verbage = 'How much is this food worth?';
            [rects,mids] = DrawRectsGrid(10);
            KEYS.all = KEYS.ONE:KEYS.TEN;
        case 3
            %This is ModAtt
            cd(imgdir_mod);
            trialsinthisblock = length(mod_img);
            blockimgs = mod_order;
            blockname = 'ModelAtt';
%             blockdata = ModelAtt;
            block_instruct_text = 'In this round, we''re going to ask you how attractive you think models are!\nPress any key to continue.';
            verbage = 'How attractive is this model?';
            [rects,mids] = DrawRectsGrid(9);
            KEYS.all = KEYS.ONE:KEYS.NINE;
    end
    
    %Make a struct for this block's data.
    blockdata = struct;
    for bbb = 1:length(blockimgs);
        blockdata(bbb).ID = ID;
        blockdata(bbb).Session = SESS;
        blockdata(bbb).Date = date;
        blockdata(bbb).BlockNumber = block;
        blockdata(bbb).BlockName = blockname; 
        blockdata(bbb).Trial = bbb;
        blockdata(bbb).Image = blockimgs{bbb};
        blockdata(bbb).Rating = NaN;
        blockdata(bbb).RT = NaN;
        
    end
    
    %Instructions here.
    DrawFormattedText(w,block_instruct_text,'center','center',COLORS.WHITE,50,[],[],1.5);
    Screen('Flip',w);
    KbWait;
    Screen('Flip',w);
    
    for trial = 1:trialsinthisblock
        %Show images, get ratings
        DrawFormattedText(w,'+','center','center',COLORS.WHITE);
        Screen('Flip',w);
        WaitSecs(.25);
        
        tp = imread(getfield(blockdata,{trial},'Image'));
        tpx = Screen('MakeTexture',w,tp);
        Screen('DrawTexture',w,tpx);
        
        if thisblock == 2
            drawValues();
        else
            drawRatings();
        end
        DrawFormattedText(w,verbage,'center',(wRect(4)*.75),COLORS.BLUE);
        RT_start = Screen('Flip',w);
        
        FlushEvents();
        while 1
            [keyisdown, ~, keycode] = KbCheck(-1);
%             rt_elap = GetSecs() - RT_start;
            if (keyisdown==1 && any(keycode(KEYS.all)))
                %                     PicRating_CC(xy).RT = rt - rateon;
                rt_elap = GetSecs() - RT_start;
                if iscell(KbName(keycode)) && numel(KbName(keycode))>1  %You have mashed 2 keys; shame on you.
                    rating = KbName(find(keycode,1));
                    rating = str2double(rating(1));
                    while isnan(rating);        %This key selection is not a number!
                        newrating = KbName(keycode);
                        for kk = 2:numel(newrating)
                            rating = str2double(newrating(kk));
                            if ~isnan(rating)
                                break
                            elseif kk == length(KbName(keycode)) && isnan(rating);
                                %something has gone horrible awry;
                                warning('Trial #%d rating is NaN for some reason',xy);
                                rating = NaN;
                            end
                        end
                    end
                else
                    rating = KbName(find(keycode));
                    rating = str2double(rating(1));
                    if rating == 0;
                        %Zero is used for tens
                        rating = 10;
                    end
                end
                
                Screen('DrawTexture',w,tpx);
                if thisblock == 2
                    drawValues(keycode);
                else
                    drawRatings(keycode);
                end
                DrawFormattedText(w,verbage,'center',(wRect(4)*.75),COLORS.BLUE);
                Screen('Flip',w);
                WaitSecs(.25);
                break;
            end
        end
        blockdata(trial).Rating = rating;
        blockdata(trial).RT = rt_elap;
    end
    %Save this block's data
    data_out = struct2table(blockdata);
    fulldata = vertcat(fulldata,data_out);
    
    %Also save a separate .csv, bc #yolo
    savename = sprintf('PicRatings_%s_%04d_%d_%d%02d%02d.csv',blockname,ID,SESS,currdate(1),currdate(2),currdate(3));
    saveloc = [results filesep savename];
    
    %How about we don't overwrite date?
    fileexist = exist(saveloc,'file');
    addon = 2;
    while fileexist == 2;
        savename = sprintf('PicRatings_%s_%04d_%d_%d%02d%02d_%d.csv',blockname,ID,SESS,currdate(1),currdate(2),currdate(3),addon);
        saveloc = [results filesep savename];
        fileexist = exist(saveloc,'file');
        addon = addon + 1;
    end
    writetable(data_out,saveloc)
end
%save the full data as one long one...
fullsavename = sprintf('PicRatings_FullData_%04d_%d_%d%02d%02d.csv',ID,SESS,currdate(1),currdate(2),currdate(3));
fullsaveloc = [results filesep fullsavename];

%How about we don't overwrite date?
fileexist = exist(fullsaveloc,'file');
addon = 2;
while fileexist == 2;
    fullsavename = sprintf('PicRatings_FullData_%04d_%d_%d%02d%02d_%d.csv',ID,SESS,currdate(1),currdate(2),currdate(3),addon);
    fullsaveloc = [results filesep fullsavename];
    fileexist = exist(fullsaveloc,'file');
    addon = addon + 1;
end
writetable(fulldata,fullsaveloc);

%% End Screen
DrawFormattedText(w,'That concludes this task.\nThe assessor will be with you shortly.','center','center',COLORS.WHITE,50,[],[],1.5);
Screen('Flip',w);
WaitSecs(5);

sca
end

%%
function [rects,mids] = DrawRectsGrid(appRval)
%DrawRectGrid:  Builds a grid of squares with gaps in between.

global wRect XCENTER

%Size of image will depend on screen size. First, an area approximately 80%
%of screen is determined. Then, images are 1/4th the side of that square
%(minus the 3 x the gap between images.
% if appRval == 1;
%     num_rects = 9;                 %How many rects?
% elseif appRval == 2;
%     num_rects = 10;
% end
num_rects = appRval;

xlen = wRect(3)*.9;           %Make area covering about 90% of vertical dimension of screen.
gap = 10;                       %Gap size between each rect
square_side = fix((xlen - (num_rects-1)*gap)/num_rects); %Size of rect depends on size of screen.

squart_x = XCENTER-(xlen/2);
squart_y = wRect(4)*.8;         %Rects start @~80% down screen.

rects = zeros(4,num_rects);

% for row = 1:DIMS.grid_row;
    for col = 1:num_rects;
%         currr = ((row-1)*DIMS.grid_col)+col;
        rects(1,col)= squart_x + (col-1)*(square_side+gap);
        rects(2,col)= squart_y;
        rects(3,col)= squart_x + (col-1)*(square_side+gap)+square_side;
        rects(4,col)= squart_y + square_side;
    end
% end
mids = [rects(1,:)+square_side/2; rects(2,:)+square_side/2+5];

end

%%
function drawRatings(varargin)

global w KEYS COLORS rects mids

num_rects = 9;  
colors=repmat(COLORS.BLUE',1,num_rects);
% rects=horzcat(allRects.rate1rect',allRects.rate2rect',allRects.rate3rect',allRects.rate4rect');

%Needs to feed in "code" from KbCheck, to show which key was chosen.
if nargin >= 1 && ~isempty(varargin{1})
    response=varargin{1};
    
    key=find(response);
    if length(key)>1
        key=key(1);
    end;
    
    switch key
        
        case {KEYS.ONE}
            choice=1;
        case {KEYS.TWO}
            choice=2;
        case {KEYS.THREE}
            choice=3;
        case {KEYS.FOUR}
            choice=4;
        case {KEYS.FIVE}
            choice=5;
        case {KEYS.SIX}
            choice=6;
        case {KEYS.SEVEN}
            choice=7;
        case {KEYS.EIGHT}
            choice=8;
        case {KEYS.NINE}
            choice=9;
%         case {KEYS.TEN}
%             choice = 10;
    end
    
    if exist('choice','var')
        
        
        colors(:,choice)=COLORS.GREEN';
        
    end
end


    window=w;
   

Screen('TextFont', window, 'Arial');
Screen('TextStyle', window, 1);
oldSize = Screen('TextSize',window,35);

% Screen('TextFont', w2, 'Arial');
% Screen('TextStyle', w2, 1)
% Screen('TextSize',w2,60);



%draw all the squares
Screen('FrameRect',window,colors,rects,1);


% Screen('FrameRect',w2,colors,rects,1);


%draw the text (1-10)
for n = 1:num_rects;
    numnum = sprintf('%d',n);
    CenterTextOnPoint(window,numnum,mids(1,n),mids(2,n),COLORS.BLUE);
end


Screen('TextSize',window,oldSize);

end

function drawValues(varargin)

global w KEYS COLORS rects mids

num_rects = 10;  
colors=repmat(COLORS.BLUE',1,num_rects);
% rects=horzcat(allRects.rate1rect',allRects.rate2rect',allRects.rate3rect',allRects.rate4rect');

%Needs to feed in "code" from KbCheck, to show which key was chosen.
if nargin >= 1 && ~isempty(varargin{1})
    response=varargin{1};
    
    key=find(response);
    if length(key)>1
        key=key(1);
    end;
    
    switch key
        
        case {KEYS.ONE}
            choice=1;
        case {KEYS.TWO}
            choice=2;
        case {KEYS.THREE}
            choice=3;
        case {KEYS.FOUR}
            choice=4;
        case {KEYS.FIVE}
            choice=5;
        case {KEYS.SIX}
            choice=6;
        case {KEYS.SEVEN}
            choice=7;
        case {KEYS.EIGHT}
            choice=8;
        case {KEYS.NINE}
            choice=9;
         case {KEYS.TEN}
            choice = 10;
    end
    
    if exist('choice','var')
        
        
        colors(:,choice)=COLORS.GREEN';
        
    end
end


    window=w;
   

Screen('TextFont', window, 'Arial');
Screen('TextStyle', window, 1);
oldSize = Screen('TextSize',window,35);

% Screen('TextFont', w2, 'Arial');
% Screen('TextStyle', w2, 1)
% Screen('TextSize',w2,60);



%draw all the squares
Screen('FrameRect',window,colors,rects,1);


% Screen('FrameRect',w2,colors,rects,1);


%draw the text (1-10)
for n = 1:num_rects;
    if n == 1;
        numnum = sprintf('<$%d',n);
    elseif n == 10;
        numnum = sprintf('$%d+',n);
    else
        numnum = sprintf('$%d',n);
    end
    CenterTextOnPoint(window,numnum,mids(1,n),mids(2,n),COLORS.BLUE);
end


Screen('TextSize',window,oldSize);

end

%%
function [nx, ny, textbounds] = CenterTextOnPoint(win, tstring, sx, sy,color)
% [nx, ny, textbounds] = DrawFormattedText(win, tstring [, sx][, sy][, color][, wrapat][, flipHorizontal][, flipVertical][, vSpacing][, righttoleft])
%
% 

numlines=1;

if nargin < 1 || isempty(win)
    error('CenterTextOnPoint: Windowhandle missing!');
end

if nargin < 2 || isempty(tstring)
    % Empty text string -> Nothing to do.
    return;
end

% Store data class of input string for later use in re-cast ops:
stringclass = class(tstring);

% Default x start position is left border of window:
if isempty(sx)
    sx=0;
end

% if ischar(sx) && strcmpi(sx, 'center')
%     xcenter=1;
%     sx=0;
% else
%     xcenter=0;
% end

xcenter=0;

% No text wrapping by default:
% if nargin < 6 || isempty(wrapat)
    wrapat = 0;
% end

% No horizontal mirroring by default:
% if nargin < 7 || isempty(flipHorizontal)
    flipHorizontal = 0;
% end

% No vertical mirroring by default:
% if nargin < 8 || isempty(flipVertical)
    flipVertical = 0;
% end

% No vertical mirroring by default:
% if nargin < 9 || isempty(vSpacing)
    vSpacing = 1.5;
% end

% if nargin < 10 || isempty(righttoleft)
    righttoleft = 0;
% end

% Convert all conventional linefeeds into C-style newlines:
newlinepos = strfind(char(tstring), '\n');

% If '\n' is already encoded as a char(10) as in Octave, then
% there's no need for replacemet.
if char(10) == '\n' %#ok<STCMP>
   newlinepos = [];
end

% Need different encoding for repchar that matches class of input tstring:
if isa(tstring, 'double')
    repchar = 10;
elseif isa(tstring, 'uint8')
    repchar = uint8(10);    
else
    repchar = char(10);
end

while ~isempty(newlinepos)
    % Replace first occurence of '\n' by ASCII or double code 10 aka 'repchar':
    tstring = [ tstring(1:min(newlinepos)-1) repchar tstring(min(newlinepos)+2:end)];
    % Search next occurence of linefeed (if any) in new expanded string:
    newlinepos = strfind(char(tstring), '\n');
end

% % Text wrapping requested?
% if wrapat > 0
%     % Call WrapString to create a broken up version of the input string
%     % that is wrapped around column 'wrapat'
%     tstring = WrapString(tstring, wrapat);
% end

% Query textsize for implementation of linefeeds:
theight = Screen('TextSize', win) * vSpacing;

% Default y start position is top of window:
if isempty(sy)
    sy=0;
end

winRect = Screen('Rect', win);
winHeight = RectHeight(winRect);

% if ischar(sy) && strcmpi(sy, 'center')
    % Compute vertical centering:
    
    % Compute height of text box:
%     numlines = length(strfind(char(tstring), char(10))) + 1;
    %bbox = SetRect(0,0,1,numlines * theight);
    bbox = SetRect(0,0,1,theight);
    
    
    textRect=CenterRectOnPoint(bbox,sx,sy);
    % Center box in window:
    [rect,dh,dv] = CenterRect(bbox, textRect);

    % Initialize vertical start position sy with vertical offset of
    % centered text box:
    sy = dv;
% end

% Keep current text color if noone provided:
if nargin < 5 || isempty(color)
    color = [];
end

% Init cursor position:
xp = sx;
yp = sy;

minx = inf;
miny = inf;
maxx = 0;
maxy = 0;

% Is the OpenGL userspace context for this 'windowPtr' active, as required?
[previouswin, IsOpenGLRendering] = Screen('GetOpenGLDrawMode');

% OpenGL rendering for this window active?
if IsOpenGLRendering
    % Yes. We need to disable OpenGL mode for that other window and
    % switch to our window:
    Screen('EndOpenGL', win);
end

% Disable culling/clipping if bounding box is requested as 3rd return
% % argument, or if forcefully disabled. Unless clipping is forcefully
% % enabled.
% disableClip = (ptb_drawformattedtext_disableClipping ~= -1) && ...
%               ((ptb_drawformattedtext_disableClipping > 0) || (nargout >= 3));
% 

disableClip=1;

% Parse string, break it into substrings at line-feeds:
while ~isempty(tstring)
    % Find next substring to process:
    crpositions = strfind(char(tstring), char(10));
    if ~isempty(crpositions)
        curstring = tstring(1:min(crpositions)-1);
        tstring = tstring(min(crpositions)+1:end);
        dolinefeed = 1;
    else
        curstring = tstring;
        tstring =[];
        dolinefeed = 0;
    end

    if IsOSX
        % On OS/X, we enforce a line-break if the unwrapped/unbroken text
        % would exceed 250 characters. The ATSU text renderer of OS/X can't
        % handle more than 250 characters.
        if size(curstring, 2) > 250
            tstring = [curstring(251:end) tstring]; %#ok<AGROW>
            curstring = curstring(1:250);
            dolinefeed = 1;
        end
    end
    
    if IsWin
        % On Windows, a single ampersand & is translated into a control
        % character to enable underlined text. To avoid this and actually
        % draw & symbols in text as & symbols in text, we need to store
        % them as two && symbols. -> Replace all single & by &&.
        if isa(curstring, 'char')
            % Only works with char-acters, not doubles, so we can't do this
            % when string is represented as double-encoded Unicode:
            curstring = strrep(curstring, '&', '&&');
        end
    end
    
    % tstring contains the remainder of the input string to process in next
    % iteration, curstring is the string we need to draw now.

    % Perform crude clipping against upper and lower window borders for
    % this text snippet. If it is clearly outside the window and would get
    % clipped away by the renderer anyway, we can safe ourselves the
    % trouble of processing it:
    if disableClip || ((yp + theight >= 0) && (yp - theight <= winHeight))
        % Inside crude clipping area. Need to draw.
        noclip = 1;
    else
        % Skip this text line draw call, as it would be clipped away
        % anyway.
        noclip = 0;
        dolinefeed = 1;
    end
    
    % Any string to draw?
    if ~isempty(curstring) && noclip
        % Cast curstring back to the class of the original input string, to
        % make sure special unicode encoding (e.g., double()'s) does not
        % get lost for actual drawing:
        curstring = cast(curstring, stringclass);
        
        % Need bounding box?
%         if xcenter || flipHorizontal || flipVertical
            % Compute text bounding box for this substring:
            bbox=Screen('TextBounds', win, curstring, [], [], [], righttoleft);
%         end
        
        % Horizontally centered output required?
%         if xcenter
            % Yes. Compute dh, dv position offsets to center it in the center of window.
%             [rect,dh] = CenterRect(bbox, winRect);
            [rect,dh] = CenterRect(bbox, textRect);
            % Set drawing cursor to horizontal x offset:
            xp = dh;
%         end
            
%         if flipHorizontal || flipVertical
%             textbox = OffsetRect(bbox, xp, yp);
%             [xc, yc] = RectCenter(textbox);
% 
%             % Make a backup copy of the current transformation matrix for later
%             % use/restoration of default state:
%             Screen('glPushMatrix', win);
% 
%             % Translate origin into the geometric center of text:
%             Screen('glTranslate', win, xc, yc, 0);
% 
%             % Apple a scaling transform which flips the direction of x-Axis,
%             % thereby mirroring the drawn text horizontally:
%             if flipVertical
%                 Screen('glScale', win, 1, -1, 1);
%             end
%             
%             if flipHorizontal
%                 Screen('glScale', win, -1, 1, 1);
%             end
% 
%             % We need to undo the translations...
%             Screen('glTranslate', win, -xc, -yc, 0);
%             [nx ny] = Screen('DrawText', win, curstring, xp, yp, color, [], [], righttoleft);
%             Screen('glPopMatrix', win);
%         else
            [nx ny] = Screen('DrawText', win, curstring, xp, yp, color, [], [], righttoleft);
%         end
    else
        % This is an empty substring (pure linefeed). Just update cursor
        % position:
        nx = xp;
        ny = yp;
    end

    % Update bounding box:
    minx = min([minx , xp, nx]);
    maxx = max([maxx , xp, nx]);
    miny = min([miny , yp, ny]);
    maxy = max([maxy , yp, ny]);

    % Linefeed to do?
    if dolinefeed
        % Update text drawing cursor to perform carriage return:
        if xcenter==0
            xp = sx;
        end
        yp = ny + theight;
    else
        % Keep drawing cursor where it is supposed to be:
        xp = nx;
        yp = ny;
    end
    % Done with substring, parse next substring.
end

% Add one line height:
maxy = maxy + theight;

% Create final bounding box:
textbounds = SetRect(minx, miny, maxx, maxy);

% Create new cursor position. The cursor is positioned to allow
% to continue to print text directly after the drawn text.
% Basically behaves like printf or fprintf formatting.
nx = xp;
ny = yp;

% Our work is done. If a different window than our target window was
% active, we'll switch back to that window and its state:
if previouswin > 0
    if previouswin ~= win
        % Different window was active before our invocation:

        % Was that window in 3D mode, i.e., OpenGL rendering for that window was active?
        if IsOpenGLRendering
            % Yes. We need to switch that window back into 3D OpenGL mode:
            Screen('BeginOpenGL', previouswin);
        else
            % No. We just perform a dummy call that will switch back to that
            % window:
            Screen('GetWindowInfo', previouswin);
        end
    else
        % Our window was active beforehand.
        if IsOpenGLRendering
            % Was in 3D mode. We need to switch back to 3D:
            Screen('BeginOpenGL', previouswin);
        end
    end
end

return;
end
