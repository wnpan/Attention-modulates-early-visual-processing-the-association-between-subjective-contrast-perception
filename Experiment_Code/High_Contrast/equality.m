function equality(subjectid,practice,start,over)
%%  equality +stair
% last edit by PWN 2020/2/25
%

global inc background white
%% %%%%%%%%%%%%%%%%%%%%%%%%%% ������Ļ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
HideCursor;
% Screen('Preference', 'SkipSyncTests', 1);
screenNumber=max(Screen('Screens'));
block_num = 0;%���㵱ǰ�ǵڼ���block

% ��Ļ��ɫ
white=WhiteIndex(screenNumber);
black=BlackIndex(screenNumber);
grey=round((white+black)/2);
if grey == white
    grey=white / 2;
end
inc = abs(white-grey);
background=grey;
wait_color = (grey+black)./2;

% ��һ����Ļ
[w,rect]=Screen('OpenWindow',screenNumber,background);
% [w,rect]=Screen('OpenWindow',screenNumber,background,[0 0 1024 768]);

% % ��Ļ�����趨
AssertGLSL;                                                                 % Make sure this GPU supports shading at all
load('newclut');
load('oldclut');
Screen('LoadNormalizedGammaTable',screenNumber,newclut);                    % write CLUTs, screen normalization
Screen(w,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);             % Enable alpha blending for typical drawing of masked textures
priorityLevel=MaxPriority(w);
Priority(priorityLevel);

% % ��Ļˢ��Ƶ��
frameRate=Screen('FrameRate',w);
frameDura=1000/frameRate;
if  round(frameRate)~=100                                                   % ȷ��ˢ��Ƶ����85hz�����������
    quit
end
% frameRate = 100;
% frameDura = 10;

% ��Ļ�ߴ�
xcenter=rect(3)/2;                                                          % ��Ļ���ĺ�����
ycenter=rect(4)/2;


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%% ���巴Ӧ���� %%%%%%%%%%%%%%%%%%%%%%%%%%%
KbName('UnifyKeyNames');
key_s=KbName('s');
key_d=KbName('d');

key_p=KbName('p');
space=KbName('space');


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%% �̼������趨 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% size
% �̼���С
pixelPerDegree = round(degree2pixel(1));
sizeFix = round(degree2pixel(0.2));
% linethickness = round(degree2pixel(0.1));
% sizeFixArea = round(degree2pixel(2));
r = 1.5;
GratingR = round(degree2pixel(r));  % �뾶
sizeCue = round(degree2pixel(0.3));
cueColor = black;

%% destinations
% ע�ӵ��λ��
% desFix = [xcenter-sizeFix/2,ycenter-sizeFix/2,xcenter+sizeFix/2,ycenter+sizeFix/2];
% desFix(1,:) = [xcenter-sizeFix xcenter+sizeFix xcenter xcenter];
% desFix(2,:) = [ycenter ycenter ycenter-sizeFix ycenter+sizeFix];
desFix = [xcenter,ycenter];

% gratings % 1 �� 2 ��
grating_rect = [round(degree2pixel(3.6)) round(degree2pixel(1.8))]; % ���ľ���
desCenter(:,:,1) = [xcenter-grating_rect(1)-GratingR ycenter-grating_rect(2)-GratingR...
    xcenter-grating_rect(1)+GratingR ycenter-grating_rect(2)+GratingR]; % left
desCenter(:,:,2) = [xcenter+grating_rect(1)-GratingR ycenter-grating_rect(2)-GratingR...
    xcenter+grating_rect(1)+GratingR ycenter-grating_rect(2)+GratingR]; % right

% cue��λ��
eccentricity_cue = round(degree2pixel(3.6)); % ���ľ���
desCue(:,:,1) = [xcenter-eccentricity_cue ycenter]; % left
desCue(:,:,2) = [xcenter ycenter]; % neutral
desCue(:,:,3) = [xcenter+eccentricity_cue ycenter]; % right

%% durations
% fixation
fixDura = 500;
fixFrames = round(fixDura/frameDura);

% cue
cueDura = 50;
cueFrames = round(cueDura/frameDura);

% ISI
SOA = 150;
blankDura = SOA-cueDura;
blankFrames = round(blankDura/frameDura);

% gratingDura
gratingDura = 50;
gratingFrames = round(gratingDura/frameDura);

% ISI2
gratingBetweenDura = 150;
gratingBetweenFrames = round(gratingBetweenDura/frameDura);

% no response duration
NoResponseDura = 250;
NoResponseFrames = round(NoResponseDura/frameDura);

%% ----------ERP����ʼ������˿�----------
ioObj = io64;
status = io64(ioObj);
address = hex2dec('378'); %standard LPT1 output port address
%% %%%%%%%%%%%%%%%%%%%% eye tracking setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% eye tracker setup
%%����֮ǰ��ʼ�����ڣ��ر� ɾ�����ܴ��ڵĴ��ڣ�
% IOPort('closeall');
%
% %%��������
% % [handle, errmsg] = IOPort('OpenSerialPort', 'com3','BaudRate=256000 ReceiveTimeout=0.3');
% [handle, errmsg] = IOPort('OpenSerialPort', 'com3','BaudRate=512000 ReceiveTimeout=0.2');
% IOPort('Purge',handle); %������ж�д����������
% %%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%1 ����StimRD��stimuli ready���ź� �̼�������׼����
% StimRD='R';
% [nwritten, when, errmsg] = IOPort('Write', handle, StimRD);

% %%2 ����Tobii������׼�����ź�
% while KbCheck; end
% TobReSig=0;
% qkey=KbName('q');
% keycode=zeros(1,256);
% while ~keycode(qkey) && ~TobReSig
%     [data, when, errmsg] = IOPort('Read', handle,0,1);
%     IOPort('Purge',handle); %������ж�д����������
%     tobiiready=char(data);
%     [keydown secs keycode]=KbCheck;
%
%     if strcmp(tobiiready,'R')==1
%         fprintf('Tobii is ready! \n');
%         fprintf('------------------------------------------\n');
%         TobReSig=1;
%     else
%         [nwritten, when, errmsg] = IOPort('Write', handle, StimRD);
%         fprintf('%f Waiting for Tobii getting ready. \n', when);
%         WaitSecs(1);
%     end
% end

%% %%%%%%%%%%%%%%%%%%%%%%%  ����buildmatrix %%%%%%%%%%%%%%%%%%%%%%%%%
% buildmatrixSOA(subjectid,SOA);
filename = ['data/',subjectid,'_paramatrix'];
load(filename);

blockNum = 15;
npblock = length(paramatrix(:,1))/blockNum;

%% %%%%%%%%%%%%%%%%%% �ȴ����԰��¿ո����ʼʵ�� %%%%%%%%%%%%%%%%%

Screen('Flip',w); % ��߾���
WaitSecs(0.5);
[keyisdown,secs,keycode] = KbCheck;
while keycode(space) == 0
    KbWait;
    [keyisdown,secs,keycode] = KbCheck;
    WaitSecs(0.001);
    
    % ��p���˳�
    if keycode(key_p)
        ShowCursor;
        Priority(0);
        %             Screen('LoadNormalizedGammaTable',screenNumber,oldclut);
        Screen('CloseAll');
        %             ExpOver='O';
        %             [nwritten, when, errmsg] = IOPort('Write', handle, ExpOver);
        %             fprintf('%f Experiment Over!!�� \n',when);
        %             IOPort('closeall');
        ShowCursor; %
        return
    end
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%% ѭ���ṹ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for index = start:over
    
    % ��դ��ز���
    % ��դ�Աȶ�
    cRef = paramatrix(index,6)/100;
    minc = paramatrix(index,15)/100;
    maxc = paramatrix(index,16)/100;
    cTest0 = [minc maxc];
    stepdir0 = [1 -1];
    
    % �ռ�Ƶ��spatial frequency
    cyclePerDegree = 4;
    period = pixelPerDegree/cyclePerDegree; % how many pixels in one cycle
    sf = 1/period;
    angleRef = 0;
    angleTest = 0;
    phase = rand(1)*2*pi;
    
    trialtype = paramatrix(index,2);
    initialdir = (paramatrix(index,13)+3)/2;
    
    indexDesCue = paramatrix(index,3)+2;
    
    indexDesRef = (paramatrix(index,4)+3)/2;%-1  1��1 2
    indexDesTest = (paramatrix(index,5)+3)/2;%-1  1��1 2
    
    indexTaskType = paramatrix(index,7);
    indexITI = paramatrix(index,8);
    ITIFrames = round(indexITI/frameDura);
    
    % �Ե��ַ�
    trigger1 = paramatrix(index,17);
%     trigger2 = 100;
    
    indexMatrix = paramatrix(find(paramatrix(:,2)==trialtype),1); % �õ���trialtype��trial���к�
    
    % the first trial
    if paramatrix(indexMatrix,9)==0 % test contrast matrix
        paramatrix(index,9) = cTest0(initialdir)*100;
        paramatrix(index,10) = log(cTest0(initialdir)*100);
        paramatrix(index,14) = stepdir0(initialdir);
    end
    
    cTest = paramatrix(index,9)/100;
    
    MatrixTest = TextureCenter(GratingR,angleTest,cTest,sf,phase);
    test = Screen('MakeTexture',w, MatrixTest);
    MatrixRef = TextureCenter(GratingR,angleRef,cRef,sf,phase);
    ref = Screen('MakeTexture',w, MatrixRef);
    nograting = Screen('MakeTexture',w, [background]);
    if indexTaskType == 1
        gratingTexture1 = [test ref];
        gratingTexture2 = [nograting nograting];
    elseif indexTaskType == 2
        gratingTexture1 = [nograting ref];
        gratingTexture2 = [test nograting];
    elseif indexTaskType == 3
        gratingTexture2 = [test ref];
        gratingTexture1 = [nograting nograting];
    else
        gratingTexture1 = [nograting nograting];
        gratingTexture2 = [nograting nograting];
    end
    desGrating = reshape([desCenter(:,:,indexDesTest) desCenter(:,:,indexDesRef)],4,2);
    
    %     Screen('FillRect', w, 100, desFix);
    %     Screen('DrawDots',w,desFix,sizeFix,wait_color,[],1);
    %     Screen('DrawLines',w,desFix,linethickness,black,[],1);
    Screen('Flip', w);
    %     WaitSecs(0.5);
    %     [keyisdown,secs,keycode] = KbCheck;
    %     while keycode(space) == 0
    %         KbWait;
    %         [keyisdown,secs,keycode] = KbCheck;
    %         WaitSecs(0.001);
    %
    %         % ��q���˳�
    %         if keycode(key_q)
    %             ShowCursor;
    %             Priority(0);
    %             %             Screen('LoadNormalizedGammaTable',screenNumber,oldclut);
    %             Screen('CloseAll');
    %             %             ExpOver='O';
    %             %             [nwritten, when, errmsg] = IOPort('Write', handle, ExpOver);
    %             %             fprintf('%f Experiment Over!!�� \n',when);
    %             %             IOPort('closeall');
    %             ShowCursor; %
    %             return
    %         end
    %     end
    
    %     %%3 ����StaRec�źţ�Ҫ���۶��ǿ�ʼ��¼�۶�����
    %     StartRecord='B';
    %     [nwritten, when, errmsg] = IOPort('Write', handle, StartRecord);
    %     fprintf('Trial %i.\n',index);
    %     fprintf('%f Ask Tobii to begin to record. \n',when);
    
    %     %%4 ���ִ̼�
    %     fprintf('Presenting Stimuli ....... \n');

   
    % ���ո�ʼ
    %     if keycode(space)
    % 0. �Դο�ʼǰ��ITI
    for r = 1:ITIFrames
        Screen('Flip',w);
    end
    
    % 1. ע�ӵ����
    for r = 1:fixFrames
        Screen('DrawDots',w,desFix,sizeFix,black,[],1);
        Screen('Flip',w);
    end
    
    % 2. cue����
    for r = 1:cueFrames
        Screen('DrawDots',w,desCue(:,:,indexDesCue),sizeCue,cueColor,[],1);
        %             Screen('DrawTextures', w,Adaption_gratingTexture,[],Adaption_desGrating); % gratings
        %             Screen('FillRect', w, black, desFix);
        %             Screen('DrawLines',w,desFix,linethickness,black,[],1);
        Screen('DrawDots',w,desFix,sizeFix,black,[],1);
        Screen('Flip', w);
    end
    
    % 3. ISI1
    for r = 1:blankFrames
        %             Screen('FillRect', w, black, desFix);
        %             Screen('DrawLines',w,desFix,linethickness,black,[],1);
        %             Screen('DrawTextures', w,Adaption_gratingTexture,[],Adaption_desGrating); % gratings
        Screen('DrawDots',w,desFix,sizeFix,black,[],1);
        Screen('Flip',w);
    end
    
    io64(ioObj, address, trigger1);
    
    % 4. pre�̼�����
    for r = 1: gratingFrames
        Screen('DrawTextures', w,gratingTexture1,[],desGrating); % grating
        %             Screen('FillRect', w, black, desFix);
        %             Screen('DrawLines',w,desFix,linethickness,black,[],1);
        Screen('DrawDots',w,desFix,sizeFix,black,[],1);
        start_time = Screen('Flip',w);
    end
    
%         io64(ioObj, address, trigger2);
%         %%%%%ERP:�����ʼ��%%%%
%         io64(ioObj, address, 0);  %%��ʼΪ0
%         %%%%%%%
    
    if indexTaskType == 2 || indexTaskType == 3 || indexTaskType == 4 %����һ�ڵ�һ�γ��ֹ�դ�󼴿ɷ�Ӧ
        
        % 5. ISI2
        for r = 1:gratingBetweenFrames
            %             Screen('FillRect', w, black, desFix);
            %             Screen('DrawLines',w,desFix,linethickness,black,[],1);
            %             Screen('DrawTextures', w,Adaption_gratingTexture,[],Adaption_desGrating); % gratings
            Screen('DrawDots',w,desFix,sizeFix,black,[],1);
            Screen('Flip',w);
        end
        
        % 6. post�̼�����
        for r = 1: gratingFrames
            Screen('DrawTextures', w,gratingTexture2,[],desGrating); % grating
            %             Screen('FillRect', w, black, desFix);
            %             Screen('DrawLines',w,desFix,linethickness,black,[],1);
            Screen('DrawDots',w,desFix,sizeFix,black,[],1);
            Screen('Flip',w);
        end
    end
    
    if indexTaskType == 4 %�������ж���ĵȴ�ʱ��
        % 7. no response blank
        for r = 1: NoResponseFrames
            %             Screen('DrawTextures', w,gratingTexture2,[],desGrating); % grating
            %             Screen('FillRect', w, black, desFix);
            %             Screen('DrawLines',w,desFix,linethickness,black,[],1);
            Screen('DrawDots',w,desFix,sizeFix,black,[],1);
            Screen('Flip',w);
        end
    end
    
    
    %     %%3 Tobii ֹͣ��¼
    %     StopRecord='S';
    %     [nwritten, when, errmsg] = IOPort('Write', handle, StopRecord);
    %     fprintf('%f Ask Tobii to stop recording. \n',when);
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%% ��¼��Ӧ ������%%%%%%%%%%%%%%%%%%%%%%%%%%
    Screen('DrawDots',w,desFix,sizeFix,black,[],1);
    Screen('Flip',w);
    
    %%%%%ERP:�����ʼ��%%%%
    io64(ioObj, address, 0);  %%��ʼΪ0
    %%%%%%%
    
    if indexTaskType~=4 %������������з�Ӧ
        
        key = 0;
        
        while key == 0
            %         Screen('FillRect', w, black, desFix);
            %             Screen('DrawDots',w,desFix,sizeFix,black,[],1);
            %             Screen('Flip',w);
            
            % ��Ӧ��¼
            [keyisdown, secs, keycode] =  KbCheck;
            over_time=GetSecs;
            WaitSecs(0.001);
            paramatrix(index,12) = (over_time-start_time)*1000;
            
%             if round(rand(1))
%                 WaitSecs(0.6);
%                 keycode(key_s) = 1;
%             else
%                 WaitSecs(0.6);
%                 keycode(key_d) = 1;
%             end
            
            if keycode(key_s)
                key = 1;
                paramatrix(index,11) = 1;                                        % same response
                trigger3 = 1;  %same = 1 ; different = 2
                break
            elseif keycode(key_d)
                key = 1;
                paramatrix(index,11) = -1;                                       % different response
                trigger3 = 2;  %same = 1 ; different = 2
                break
            elseif keycode(key_p)
                Priority(0);
                Screen('LoadNormalizedGammaTable',screenNumber,oldclut);
                Screen('CloseAll');
                %             ExpOver='O';
                %             [nwritten, when, errmsg] = IOPort('Write', handle, ExpOver);
                %             fprintf('%f Experiment Over!!�� \n',when);
                %             IOPort('closeall');
                ShowCursor; %
                return
            end
        end
        Screen('Flip',w);
       
        io64(ioObj, address, trigger3);
        
%         %��ϰ��������
%         if practice
%             if round(cTest*100) == round(cRef*100) && trigger3 == 1
%                 Beeper(500);
%             elseif round(cTest*100) == round(minc*100) && trigger3 == 2
%                 Beeper(500);
%             elseif round(cTest*100) == round(maxc*100) && trigger3 == 2
%                 Beeper(500);
%             end
%         end
        %% %% next trial %%%
        
        contrastMatrix = paramatrix(indexMatrix,9)/100;
        responseMatrix = paramatrix(indexMatrix,11);
        dirMatrix = paramatrix(indexMatrix,14);
        [cTest2,stepdir2] = equalitystair(contrastMatrix,responseMatrix,dirMatrix,minc,maxc,cTest0(initialdir));
        index1=length(find(contrastMatrix~=0));      %��ǰ��trial��ţ������һ��ǿ�Ȳ�Ϊ0��trial��
        if index1 < size(contrastMatrix,1)
            index2 = indexMatrix(index1+1);              % next sequence index of this type
            paramatrix(index2,9) = cTest2*100;
            paramatrix(index2,10) = log(cTest2*100);
            paramatrix(index2,14) = stepdir2;
        end
    else
        paramatrix(index,11) = 0;
    end
    
    %     %%6�����۶�������
    %     fprintf('%f Receiving data .......\n',when);
    %     XYPositionTimepoint=ReceiveEyemoveData(handle);
    %     PositionTime{index}=XYPositionTimepoint;
    %     save(['fixData/',subjectid,'_FixData'],'PositionTime','rect')
    %     % WaitSecs(1);
    %     fprintf('------------------------------------------\n');
    
    %% save
    save(filename,'paramatrix');
        
    % ��Ϣ
    if mod(index,npblock)==0 && index~=over
        block_num = block_num+1;
        text_rest = strcat('Take A Rest. Block num = ',num2str(block_num))
        Screen('DrawText',w,text_rest,xcenter-80,ycenter, [0 0 0]);
        Screen('Flip',w);
        WaitSecs(5);
        KbWait;
    elseif index==over
        %         ExpOver='O';
        %         [nwritten, when, errmsg] = IOPort('Write', handle, ExpOver);
        %         fprintf('%f Experiment Over!!�� \n',when);
        %         IOPort('closeall');
        
        Screen('DrawText',w,'The end. Thank You! ',xcenter-150,ycenter, [0 0 0]);
        Screen('Flip',w);
        WaitSecs(1);
        KbWait;
        break
    end
    
    Screen('close',gratingTexture1);                                         % close screen
    Screen('close',gratingTexture2);
    %%%%%ERP:�����ʼ��%%%%
        io64(ioObj, address, 0);  %%��ʼΪ0
    %%%%%%%
end

%% %%%%%%%%%%%%%%%%%%%%%% �رմ���%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Priority(0);
Screen('LoadNormalizedGammaTable',screenNumber,oldclut);
Screen('CloseAll');
ShowCursor; % ��ʾ���

end









