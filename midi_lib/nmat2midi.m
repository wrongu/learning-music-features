function M = nmat2midi(nmat, filename, ticks)
% M = nmat2midi(nmat,filename,ticks)
% Writes standard MIDI file of NMAT (Beta)
% Based on Ken Schutte's m-files (writemidi). 
%
% This beta might replace the mex-files used in the previous version of the toolbox as 
% newer versions of Matlab (7.4+) and various OS's need new compilations 
% of the mex files. Using the C sources and the compiled mex files provides
% faster reading of midi files but because the compatibility is limited, this 
% simple workaround is offered. This beta version is very primitive,
% though. - Tuomas Eerola
%
% KNOWN PROBLEMS: - ?
% 
% For more information on Ken Schutte's functions, see 
% http://www.kenschutte.com/software
%
% CREATED ON 31.12.2007 BY TE (MATLAB 7.4 MacOSX 10.4)

if nargin<3, ticks=120; end

%% START PREPROCESSING: CONVERT NMAT INTO Schutte-compatible matrix

% input matrix:
%   1     2    3  4   5  6  
%  [track chan nn vel t1 t2] (any more cols ignored...)
M(:,2)=nmat(:,3);
M(:,3)=nmat(:,4);
M(:,4)=nmat(:,5);
M(:,5)=nmat(:,6);
M(:,6)=nmat(:,6) + nmat(:,7); % 
M(:,1)=1;

%% END PREPROCESSING
tmp = matrix2midi(M,ticks);
writemidi(tmp,filename);

%% FUNCTIONS


function midi=matrix2midi(M,ticks_per_quarter_note)
% midi=matrix2midi(M,ticks_per_quarter_note)
%
% generates a midi matlab structure from a matrix
%  specifying a list of notes.  The structure output
%  can then be used by writemidi.m
%
% input matrix:
%   1     2    3  4   5  6  
%  [track chan nn vel t1 t2] (any more cols ignored...)
%
%
% TODO options:
%  - note-off vs vel=0
%  - tempo, ticks, etc
%
%---------------------------------------------------------------
% Subversion Revision: 14 (2006-01-25)
%
% This software can be used freely for non-commerical use.
% Visit http://www.kenschutte.com/software for more
%   documentation, copyright info, and updates.
%---------------------------------------------------------------

tracks = unique(M(:,1));
Ntracks = length(tracks);

% start building 'midi' struct

if (Ntracks==1)
  midi.format = 0;
else
  midi.format = 1;
end

disp(['Tracks: ',num2str(tracks),' Format: ',num2str(midi.format)])

midi.filename = '';
midi.ticks_per_quarter_note = ticks_per_quarter_note;

tempo = 500000;   % could be set by user, etc...
% (microsec per quarter note)

for i=1:Ntracks
  
  trM = M(i==M(:,1),:);
  
  note_events_onoff = [];
  note_events_n = [];
  note_events_ticktime = [];
 
  % gather all the notes:
  for j=1:size(trM,1)
    % note on event:
    note_events_onoff(end+1)    = 1;
    note_events_n(end+1)        = j;
    note_events_ticktime(end+1) = 1e6 * trM(j,5) * ticks_per_quarter_note / tempo;
    
    % note off event:
    note_events_onoff(end+1)    = 0;
    note_events_n(end+1)        = j;
    note_events_ticktime(end+1) = 1e6 * trM(j,6) * ticks_per_quarter_note / tempo;
  end

  
  msgCtr = 1;
  
  % set tempo...
  midi.track(i).messages(msgCtr).deltatime = 0;
  midi.track(i).messages(msgCtr).type = 81;
  midi.track(i).messages(msgCtr).midimeta = 0;
  midi.track(i).messages(msgCtr).data = encode_int1(tempo,3);
  midi.track(i).messages(msgCtr).chan = [];
  msgCtr = msgCtr + 1;
  
%   % set time sig...
%   midi.track(i).messages(msgCtr).deltatime = 0;
%   midi.track(i).messages(msgCtr).type = ;
%   midi.track(i).messages(msgCtr).midimeta = ;
%   midi.track(i).messages(msgCtr).data = ;
%   midi.track(i).messages(msgCtr).chan = ;
%   msgCtr = msgCtr + 1;
  
  
[junk,ord] = sort(note_events_ticktime);
  prevtick = 0;
  for j=1:length(ord)

    n = note_events_n(ord(j));
    cumticks = note_events_ticktime(ord(j));
    
    midi.track(i).messages(msgCtr).deltatime = cumticks - prevtick;
    midi.track(i).messages(msgCtr).midimeta = 1; 
    midi.track(i).messages(msgCtr).chan = trM(n,2);
    midi.track(i).messages(msgCtr).used_running_mode = 0;

    if (note_events_onoff(ord(j))==1)
      % note on:
      midi.track(i).messages(msgCtr).type = 144;
      midi.track(i).messages(msgCtr).data = [trM(n,3); trM(n,4)];
    else
      % note off:
      midi.track(i).messages(msgCtr).type = 128;
%      midi.track(i).messages(msgCtr).data = [trM(n,3); trM(n,4)]
      midi.track(i).messages(msgCtr).data = [trM(n,3); 0]; % EDIT BY TE

    end
    msgCtr = msgCtr + 1;
    
    prevtick = cumticks;
  end

  % end of track
  
end




% return a _column_ vector
% (copied from writemidi.m)
function A=encode_int1(val,Nbytes)

A = zeros(Nbytes,1);  %ensure col vector (diff from writemidi.m...)
for i=1:Nbytes
  A(i) = bitand(bitshift(val, -8*(Nbytes-i)), 255);
end





function rawbytes=writemidi(midi,filename,do_run_mode)
% rawbytes=writemidi(midi,filename,do_run_mode)
%
% writes to a midi file
%
% midi is a structure like that created by readmidi.m
%
% do_run_mode: flag - use running mode when possible.
%    if given, will override the msg.used_running_mode
%    default==0.  (1 may not work...)
%
% TODO: use note-on for note-off... (for other function...)
%
%---------------------------------------------------------------
% Subversion Revision: 14 (2006-12-03)
%
% This software can be used freely for non-commerical use.
% Visit http://www.kenschutte.com/software for more
%   documentation, copyright info, and updates.
%---------------------------------------------------------------


%if (nargin<3)
do_run_mode = 0;
%end


% do each track:
Ntracks = length(midi.track);

for i=1:Ntracks

  databytes_track{i} = [];
  
  for j=1:length(midi.track(i).messages)

    msg = midi.track(i).messages(j);

%    msg_bytes = encode_var_length(msg.deltatime);
    msg_bytes = encode_var_length(round(msg.deltatime*0.8167)); % EDIT TE

    if (msg.midimeta==1)

      % check for doing running mode
      run_mode = 0;
      run_mode = msg.used_running_mode;
      
      % should check that prev msg has same type to allow run
      % mode...
      
      
      %      if (j>1 && do_run_mode && msg.type == midi.track(i).messages(j-1).type)
%	run_mode = 1;
%      end


msg_bytes = [msg_bytes; encode_midi_msg(msg, run_mode)];
    
    
    else
      
      msg_bytes = [msg_bytes; encode_meta_msg(msg)];
      
    end

%    disp(msg_bytes')

%if (msg_bytes ~= msg.rawbytes)
%  error('rawbytes mismatch');
%end

    databytes_track{i} = [databytes_track{i}; msg_bytes];
    
  end
end 


% HEADER
% double('MThd') = [77 84 104 100]
rawbytes = [77 84 104 100 ...
	    0 0 0 6 ...
	    encode_int(midi.format,2) ...
	    encode_int(Ntracks,2) ...
	    encode_int(midi.ticks_per_quarter_note,2) ...
	   ]';

% TRACK_CHUCKS
for i=1:Ntracks
    disp('track chunks...')
  a = length(databytes_track{i});
  % double('MTrk') = [77 84 114 107]
  tmp = [77 84 114 107 ...
	 encode_int(length(databytes_track{i}),4) ...
	 databytes_track{i}']';
  rawbytes(end+1:end+length(tmp)) = tmp;
end


% write to file
fid = fopen(filename,'w');
%fwrite(fid,rawbytes,'char');
fwrite(fid,rawbytes,'uint8');
fclose(fid);

% return a _column_ vector
function A=encode_int(val,Nbytes)

for i=1:Nbytes
  A(i) = bitand(bitshift(val, -8*(Nbytes-i)), 255);
end


function bytes=encode_var_length(val)

binStr = dec2base(val,2);
Nbytes = ceil(length(binStr)/7);

binStr = ['00000000' binStr];
bytes = [];
for i=1:Nbytes
  if (i==1)
    lastbit = '0';
  else
    lastbit = '1';
  end
  B = bin2dec([lastbit binStr(end-i*7+1:end-(i-1)*7)]);
  bytes = [B; bytes];
end


function bytes=encode_midi_msg(msg, run_mode)

bytes = [];

if (run_mode ~= 1)
  bytes = msg.type;
  % channel:
  bytes = bytes + msg.chan;  % lower nibble should be chan
end

bytes = [bytes; msg.data];

function bytes=encode_meta_msg(msg)

bytes = 255;
bytes = [bytes; msg.type];
bytes = [bytes; encode_var_length(length(msg.data))];
bytes = [bytes; msg.data];

