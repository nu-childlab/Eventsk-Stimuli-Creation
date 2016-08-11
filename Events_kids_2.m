function [] = Events_kids_2()
Screen('Preference', 'SkipSyncTests', 1);
close all;
sca
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);
rng('shuffle');
KbName('UnifyKeyNames')
Priority(9);

%subj=input('Subject Number: ', 's');
subj = 's999';

%cond=input('Initial Condition (m or q): ', 's');
cond = 'q';

%%%%%%%%
%COLOR PARAMETERS
%%%%%%%%
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white/2;
grassGreen = [0 .8 0];
pink = [1 .6 .8];
skyBlue = [.4 .7 1];
%orange
% top_bg = [1 .769 .537];
% top_ground = [1 .671 .337];
%green
top_bg = [.82 1 .643];
top_ground = [.667 1 .345];
%purple
bottom_bg = [.871 .741 1];
bottom_ground = [.773 .541 1];

textsize = 32;
textspace = 1;
crossTime = .5;


readp = csvread('eventsparametersKIDS.csv',1,0);


questions = {'MORE TIMES'...
    'HIGHER'...
    'LONGER'...
    'MORE'};


interjump = .1;




screens = Screen('Screens');
screenNumber = max(screens);
%Sets the display screen to the most external screen.
%PsychDebugWindowConfiguration(-1, .5) %opacity
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
%opens a window in the most external screen and colors it)
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
%Anti-aliasing or something? It's from a tutorial
ifi = Screen('GetFlipInterval', window);
%Drawing intervals; used to change the screen to animate the image
%screen refresh rate = approx. .0167
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
%The size of the screen window in pixels
[xCenter, yCenter] = RectCenter(windowRect);
%The center of the screen window
HideCursor;	% Hide the mouse cursor
Priority(MaxPriority(window));

%%%IMAGE 1

theImageLocation = 'bluecheetah.png';
[imagename, ~, alpha] = imread(theImageLocation);
imagename(:,:,4) = alpha(:,:);
[s1, s2, ~] = size(imagename);
if s1 > screenYpixels || s2 > screenYpixels
    disp('ERROR! Image is too big to fit on the screen');
    sca;
    return;
end
topTexture = Screen('MakeTexture', window, imagename);

%%%IMAGE 2

theImageLocation = 'redcheetah.png';
[imagename, ~, alpha] = imread(theImageLocation);
imagename(:,:,4) = alpha(:,:);
[s1, s2, ~] = size(imagename);
if s1 > screenYpixels || s2 > screenYpixels
    disp('ERROR! Image is too big to fit on the screen');
    sca;
    return;
end
bottomTexture = Screen('MakeTexture', window, imagename);

%%%GRASS

half_Rect = [0 0 screenXpixels*2 screenYpixels];
centered_half_Rect = CenterRectOnPointd(half_Rect, 0, 0);
half_rectColor = top_bg;

top_Rect = [0 0 screenXpixels*2 screenYpixels/6];
centered_top_Rect = CenterRectOnPointd(top_Rect, 0, (screenYpixels/2-(screenYpixels/12)));
top_rectColor = top_ground;

bottom_Rect = [0 0 screenXpixels*2 screenYpixels/6];
centered_bottom_Rect = CenterRectOnPointd(bottom_Rect, 0, (screenYpixels-(screenYpixels/12)));
bottom_rectColor = bottom_ground;
time = 0;
sizeRect = [0 0 s2 s1];
% sizeRect = [0 0 594 486];






ground = screenXpixels - (3 * screenXpixels/4);
topypos = screenYpixels/4;
bottomypos = 3 * screenYpixels/4;


% Sync us and get a time stamp
vbl = Screen('Flip', window);
waitframes = 1;
pauseframes = repmat([ground], 1, round(interjump/ifi));


questions = questions(randperm(numel(questions)));

block1 = readp;

blocks = {block1};


for b = 1:numel(blocks)
    switchScreen(window, textsize, textspace, questions{b}, screenYpixels)
    blok = block1;
    for t = 1:1%numel(blok(:,1))
        vars = blok(t,:);

        topJumps = vars(1);
        topHeight = vars(2);
        topTime = vars(3)/topJumps;
        bottomJumps = vars(4);
        bottomHeight = vars(5);
        bottomTime = vars(6)/bottomJumps;

        topframes = round(topTime / ifi) + 1;
        topcount=linspace(0,pi,topframes);
        bottomframes = round(bottomTime / ifi) + 1;
        bottomcount=linspace(0,pi,bottomframes);


        posUp = linspace(ground,ground+topHeight,round(topframes/2));
        posDown = linspace (ground+topHeight,ground,round(topframes/2));
        topxpos = [posUp posDown pauseframes];
%%%%%%%%%%%%%%%%%%%%%
        posUp = linspace(ground,ground+bottomHeight,round(bottomframes/2));
        posDown = linspace (ground+bottomHeight,ground,round(bottomframes/2));
        bottomxpos = [posUp posDown pauseframes];
%%%%%%%%%%%%%%%%%%%%%
        sentence = ['Did the orange monkey jump ' questions{b} ' than the purple monkey?'];

        fixCross(xCenter, yCenter, window, crossTime);

        %%%TOP ANIMATION
        Screen('FillRect', window, bottom_bg);
        for j = 1:topJumps;
            t1 = GetSecs();
            m = 1;
            while m <= numel(topcount)
                %static y positions, change the x
                topYpos = topypos;       
                topXpos = topxpos(m);
                bottomYpos = bottomypos;
                bottomXpos = ground;
                

                topdestRect = CenterRectOnPointd(sizeRect .* 1.5,...
                    topXpos, topYpos);

                bottomdestRect = CenterRectOnPointd(sizeRect .* 1.5,...
                    bottomXpos, bottomYpos);
                Screen('FillRect', window, half_rectColor, centered_half_Rect);
                Screen('FillRect', window, top_rectColor, centered_top_Rect);
                Screen('FillRect', window, bottom_rectColor, centered_bottom_Rect);
                Screen('DrawTexture', window, topTexture, [], topdestRect, 0);
                Screen('DrawTexture', window, bottomTexture, [], bottomdestRect, 0);
                vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

                % Increment the time
                time = time + ifi;
                m =  m + 1;
            end
            t2 = GetSecs();
            time = t2 - t1;

            WaitSecs(interjump);
        end


        %%%BOTTOM ANIMATION

        for j = 1:bottomJumps;
            t1 = GetSecs();
            m = 1;
            while m <= numel(bottomcount)
                topYpos = topypos;       
                topXpos = ground;
                bottomYpos = bottomypos;
                bottomXpos = bottomxpos(m);

                topdestRect = CenterRectOnPointd(sizeRect .* 1.5,...
                    topXpos, topYpos);

                bottomdestRect = CenterRectOnPointd(sizeRect .* 1.5,...
                    bottomXpos, bottomYpos);
                Screen('FillRect', window, half_rectColor, centered_half_Rect);
                Screen('FillRect', window, top_rectColor, centered_top_Rect);
                Screen('FillRect', window, bottom_rectColor, centered_bottom_Rect);
                Screen('DrawTexture', window, topTexture, [], topdestRect, 0);
                Screen('DrawTexture', window, bottomTexture, [], bottomdestRect, 0);
                vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                %vbl  = Screen('Flip', window, starttime + .005);

                % Increment the time
                time = time + ifi;
                m =  m + 1;
            end
            t2 = GetSecs();
            time = t2 - t1;

            WaitSecs(interjump);
        end
        breakScreen(window, textsize, textspace)
    end
end

finish(window, textsize, textspace);
sca
ListenChar(1);
fclose('all');
end



function [] = breakScreen(window, textsize, textspace)
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize);
    black = BlackIndex(window);
    white = WhiteIndex(window);
    textcolor = white;
    quote = '''';
    DrawFormattedText(window, ['That' quote 's it for that block! \n\n' ...
        ' Please press the spacebar when you are ready to continue to the next block. '], 'center', 'center',...
        textcolor, 70, 0, 0, textspace);
    Screen('Flip', window);
    % Wait for keypress
    RestrictKeysForKbCheck(KbName('space'));
    KbStrokeWait;
    Screen('Flip', window);
    RestrictKeysForKbCheck([]);
end

function [] = blockbreakScreen(window, textsize, textspace, screenYpixels, c)
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize+22);
    black = BlackIndex(window);
    white = WhiteIndex(window);
    textcolor = white;
    quote = '''';
    DrawFormattedText(window, ['Part ' c], 'center', 'center',...
        textcolor, 70, 0, 0, textspace);
    Screen('TextSize',window,textsize);
    DrawFormattedText(window, 'Ready? Press spacebar to continue.', 'center', screenYpixels/2+75,...
        textcolor, 70, 0, 0, textspace);
    Screen('Flip', window);
    % Wait for keypress
    RestrictKeysForKbCheck(KbName('space'));
    KbStrokeWait;
    Screen('Flip', window);
    RestrictKeysForKbCheck([]);
end

function [] = switchScreen(window, textsize, textspace, question, screenYpixels)
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize);
    black = BlackIndex(window);
    white = WhiteIndex(window);
    textcolor = white;
    DrawFormattedText(window, ['In this block, you are being asked to say'...
        ' whether the following sentence accurately describes the animation: '], 'center', (screenYpixels/2)-150,...
        textcolor, 70, 0, 0, textspace);
    sent = ['\n\n The star jumped ' question ' than the heart.'];
    Screen('TextSize',window, textsize+6);
    DrawFormattedText(window, sent, 'center', 'center', textcolor, 70, 0, 0, textspace);
    
    Screen('TextSize',window,textsize);
        DrawFormattedText(window, ['Ready? Press spacebar to continue.'], 'center', (screenYpixels/2) + 150,...
        textcolor, 70, 0, 0, textspace);
    Screen('Flip', window);
    % Wait for keypress
    RestrictKeysForKbCheck(KbName('space'));
    KbStrokeWait;
    Screen('Flip', window);
    RestrictKeysForKbCheck([]);
end

function[] = fixCross(xCenter, yCenter, window, crossTime)
    fixCrossDimPix = 40;
    white = WhiteIndex(window);
    xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
    yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
    allCoords = [xCoords; yCoords];
    lineWidthPix = 4;
    Screen('DrawLines', window, allCoords,...
        lineWidthPix, white, [xCenter yCenter], 2);
    Screen('Flip', window);
    WaitSecs(crossTime);
end

function [] = sentDisplay(window, sentence, textsize, textspace)
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize);
    black = BlackIndex(window);
    white = WhiteIndex(window);
    textcolor = white;
    DrawFormattedText(window, sentence, 'center', 'center', textcolor, 70, 0, 0, textspace);
    Screen('Flip', window);
    % Wait for keypress
    RestrictKeysForKbCheck(KbName('space'));
    KbStrokeWait;
    Screen('Flip', window);
    RestrictKeysForKbCheck([]);
end

function [response, time] = getResponse(window, sentence, textsize, screenYpixels)
    black = BlackIndex(window);
    white = WhiteIndex(window);
    textcolor = white;
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize+6);
    quote = '''';
    DrawFormattedText(window, sentence, 'center', 'center', textcolor, 70, 0, 0, 1.5);
    Screen('TextSize',window,textsize);
    DrawFormattedText(window, ['Press ' quote 'f' quote ' for YES and ' quote 'j' quote ' for NO'],...
        'center', screenYpixels/2 + 80, textcolor, 70);
    Screen('Flip',window);

    % Wait for the user to input something meaningful
    inLoop=true;
    %response = '-1';
    yesno = [KbName('f') KbName('j')];
    starttime = GetSecs;
    while inLoop
        %code = [];
        [keyIsDown, ~, keyCode]=KbCheck;
        if keyIsDown
            code = find(keyCode);
            if any(code(1) == yesno)
                endtime = GetSecs;
                if code == 9
                    response = 'f';
                    inLoop=false;
                end
                if code== 13
                    response= 'j';
                    inLoop=false;
                end
            end
        end
    end
    time = endtime - starttime;
end


function [subj] = subjcheck(subj)
    if ~strncmpi(subj, 's', 1)
        %forgotten s
        subj = ['s', subj];
    end
    if strcmp(subj,'s')
        subj = input(['Please enter a subject ' ...
                'ID:'], 's');
        subj = subjcheck(subj);
    end
    numstrs = ['1'; '2'; '3'; '4'; '5'; '6'; '7'; '8'; '9'; '0'];
    for x = 2:numel(subj)
        if ~any(subj(x) == numstrs)
            subj = input(['Subject ID ' subj ' is invalid. It should ' ...
                'consist of an "s" followed by only numbers. Please use a ' ...
                'different ID:'], 's');
            subj = subjcheck(subj);
            return
        end
    end
    if (exist([subj '.csv'], 'file') == 2) && ~strcmp(subj, 's999')...
            && ~strcmp(subj,'s998')
        temp = input(['Subject ID ' subj ' is already in use. Press y '...
            'to continue writing to this file, or press '...
            'anything else to try a new ID: '], 's');
        if strcmp(temp,'y')
            return
        else
            subj = input(['Please enter a new subject ' ...
                'ID:'], 's');
            subj = subjcheck(subj);
        end
    end
end

function [cond] = condcheck(cond)
    while ~strcmp(cond, 'm') && ~strcmp(cond, 'q')
        cond = input('Condition must be m or q. Please enter m (simul) or q (seq):', 's');
    end
end

function [] = instructions(window, screenXpixels, screenYpixels, textsize, textspace)
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize);
    black = BlackIndex(window);
    white = WhiteIndex(window);
    textcolor = white;
    xedgeDist = floor(screenXpixels / 3);
    quote = '''';
    intro = ['Welcome to the experiment. In this experiment, you will be asked to evaluate',...
        ' sentences relative to short animations. There are 2 sets of 4 blocks in the experiment,',...
        ' and each block contains 30 trials. In each block, you will be asked to evaluate',...
        ' a different sentence. You will be given a short break between blocks. \n\n',...
        ' For each animation, you will indicate whether the sentence accurately describes',...
        ' that animation by pressing ' quote 'f' quote ' for YES or ' quote 'j' quote ' for NO.',...
        ' You will be reminded of these response keys throughout. '];
    
    DrawFormattedText(window, intro, 'center', screenYpixels/3, textcolor, 70, 0, 0, textspace);
    
    intro2 = ['The experiment will proceed in two main parts. Please indicate to the experimenter if you have any questions, '...
        'or are ready to begin the experiment. \n\n When the experimenter has '...
        'left the room, you may press spacebar to begin.'];
    
    DrawFormattedText(window, intro2, 'center', 2*screenYpixels/3, textcolor, 70, 0, 0, textspace);
    Screen('Flip', window);
    RestrictKeysForKbCheck(KbName('space'));
    KbStrokeWait;
    Screen('Flip', window);
    RestrictKeysForKbCheck([]);

end

function [] = finish(window, textsize, textspace)
    Screen('TextFont',window,'Arial');
    Screen('TextSize',window,textsize);
    black = BlackIndex(window);
    white = WhiteIndex(window);
    textcolor = white;
    closing = ['Thank you for your participation.\n\nPlease let the ' ...
        'experimenter know that you are finished.'];
    DrawFormattedText(window, closing, 'center', 'center', textcolor, 70, 0, 0, textspace);
    Screen('Flip', window);
    % Wait for keypress
    RestrictKeysForKbCheck(KbName('ESCAPE'));
    KbStrokeWait;
    Screen('Flip', window);
end