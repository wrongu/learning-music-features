function data = mftxt2nmat(fn)
% Conversion of MIDI text file to notematrix
% data = mftxt2nmat(fn);
% converts a MIDI text file to a notematrix data=[]; 
%
% Input arguments: 
%	FN = Input filename
%
% Output: 
%	DATA = Notematrix
%
% Remarks:
%
% Change History :
% Date		Time	Prog	Note
% 11.8.2002	18:36	PT	Created under MATLAB 5.3 (Macintosh)
% 28.11.2002	21:32	TE	Revised
% 1.5.2003	12:00 PT	Revised
%© Part of the MIDI Toolbox Software Package, Copyright © 2004, University of Jyvaskyla, Finland
% See License.txt

fid=fopen(fn,'rt');
if fid<0
	disp('Could not open file!');
	data=[];
	return;
end
onsetcount = 0;
a=[];
while feof(fid) == 0
	a = fgetl(fid);
	if (~isempty(findstr(a,'On')) & isempty(findstr(a,'v=0')))
	    onsetcount = onsetcount + 1;
	end
end
fclose(fid); 
%%%%%%%%%%%%%%%%
MAXONSETS=2000;
if strcmp(computer,'MAC2')
	if onsetcount>MAXONSETS
		onsetcount=min([onsetcount, MAXONSETS]);
		disp('BIG FILE!');
		disp('Only first 1000 notes read in.');
	end
end
data=zeros(onsetcount,7);
tmpdata=zeros(2*onsetcount,4); 
tmpdata2=zeros(onsetcount,7);
data=[];
tempo = 0.5; % default value: duration of one beat in seconds 
fid=fopen(fn,'rt');
if fid==-1
	disp(strcat('Could not open file:',fn));
	return;
end

% read header
[a,count] = fscanf(fid,'MFile %d %d %d');
if count == 0 % empty file
	disp('Could not read file!!!');
	return;
end
counter=0;
mftype=a(1); nTracks=a(2); nTicks=a(3);
%read tracks
for tr=1:nTracks
	holdnote=cell(16,1); holdpedal=zeros(16,1);
	trkHeader = fgetl(fid);
	a=[];
	if strcmp(computer,'MAC2')
		if counter>MAXONSETS break; end % obey array size limitation
	end
	while not(strcmp(a,'TrkEnd'))
		[a,count] = fscanf(fid,'%s',1);
		switch a
		case 'TrkEnd'
			fgetl(fid); % read the end-of-line character (PT 220502)
		otherwise
			time = str2num(a);
			[b,count] = fscanf(fid,'%s',1);
			switch b
			case 'Tempo'
				[tempo,count] = fscanf(fid,'%d',1);
                  		tempo = tempo/1000000; % duration of one beat in seconds
               		case 'On'
                  		[ch,count] = fscanf(fid,' ch=%d',1);
				[n,count] = fscanf(fid,' n=%d',1);
                  		[v,count] = fscanf(fid,' v=%d',1);
                 	 	if v>0 | holdpedal(ch)==0
					event = [time ch n v];
                  			counter=counter+1;
                  			tmpdata(counter,:) = event;
				else
					holdnote{ch}=[holdnote{ch} n];
				end
			case 'Off'
				[ch,count] = fscanf(fid,' ch=%d',1);
				[n,count] = fscanf(fid,' n=%d',1);
                  		[v,count] = fscanf(fid,' v=%d',1);
				if holdpedal(ch)==0
                  			event = [time ch n 0]; % v=0 marks a note off message
                  			counter=counter+1;
                  			tmpdata(counter,:) = event;
				else
					holdnote{ch}=[holdnote{ch} n];
				end
			case 'Par'
				[ch,count] = fscanf(fid,' ch=%d',1);
				[c,count] = fscanf(fid,' c=%d',1);
                  		[v,count] = fscanf(fid,' v=%d',1);
				if c==64
					if v>63
						holdpedal(ch)=1;
					else
						holdpedal(ch)=0;
						if ~isempty(holdnote{ch})
							for k=1:length(holdnote{ch})
								event = [time ch holdnote{ch}(k) 0];
                  						counter=counter+1;
                  						tmpdata(counter,:) = event;
							end
							holdnote{ch}=[];
						end
					end
				end				
			otherwise
				li = fgetl(fid); % read the rest of the line and ignore it
			end
		end
						
	end
    for ch=1:16
        if ~isempty(holdnote{ch})
			for k=1:length(holdnote{ch})
				event = [time ch holdnote{ch}(k) 0];
                counter=counter+1;
                tmpdata(counter,:) = event;
			end
			holdnote{ch}=[];
		end
    end
end

% create notematrix
counter2=0;
for k=1:size(tmpdata,1)
	if tmpdata(k,4)>0
		for m=k+1:size(tmpdata,1)
			if tmpdata(k,2:3) == tmpdata(m,2:3)
				ch = tmpdata(k,2); n = tmpdata(k,3); v = tmpdata(k,4);
				timeBeats = tmpdata(k,1)/nTicks;
				timeSecs = timeBeats*tempo;
				dur = tmpdata(m,1)-tmpdata(k,1);
				durBeats = dur/nTicks;
				durSecs = durBeats*tempo;
				event = [timeBeats durBeats ch n v timeSecs durSecs];
				counter2=counter2+1;
				tmpdata2(counter2,:) = event;
				break;
			end
		end
	end
end
[tmp,ind] = sort(tmpdata2(:,1));
data = tmpdata2(ind,:);

fclose(fid); 
