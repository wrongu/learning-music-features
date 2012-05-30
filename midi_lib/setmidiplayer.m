function midiplayer = setmidiplayer(fullpath)
% midiplayer = setmidiplayer(<fullpath>);
% Define MIDI player program in Windows
% midiplayer = setmidiplayer(<fullpath>);
% 
%
% Input argument: 
%	FULLPATH (optional) = define the full path of your player
%
% Remarks: Used by the PLAYMIDI function (in Windows OS). 
%
% Example : midiplayer = setmidiplayer('C:\Program Files\ ...
%               Windows Media Player\mplayer2.exe');
%
% Authors:
%  Date		Time	Prog	Note
% 12.3.2004	20:59	TE	Created under MATLAB 5.3 (PC)
%© Part of the MIDI Toolbox, Copyright © 2004, University of Jyvaskyla, Finland
% See License.txt

if strcmp(computer,'PCWIN')
else
   disp('function designed for setting up MIDI player in Windows.'); return
end

cur_dir = pwd;


	toolboxpath = which('readmidi');
	toolboxpath=toolboxpath(1:end-11); 
    cd(toolboxpath)


% CHECK IF DEFINITION EXISTS
if exist('midiplayer.txt','file')==2;
   midiplayer = char(textread('midiplayer.txt','%s','whitespace',''));
   % IF DEFINED IN FULLPATH ARGUMENT
   if nargin==1
      midiplayer=fullpath;
   end
   
   % CHECK WHETHER MIDIPLAYER DEFINITION IS VALID
   [midiplayerpath, filename, ext, versn] = fileparts(midiplayer);
   %		cur_dir = pwd;
   
   % CHECK WHETHER THE PATH EXISTS
   if isempty(exist(midiplayerpath))==1;
      disp('path is empty')
   else
      if exist(midiplayerpath)==7;
         %end
         
         % CHECK WHETHER THE APPLICATION EXISTS
         eval(['cd ''', midiplayerpath,'''']);
         d=dir([filename,ext]);
         % IF NOT, DEFINE THE APPLICATION
         if size(char(d.name),2)<3;
            if nargin<1
               disp('Default MIDI player not found!')
               disp('You need to define MIDI player (set full path to SETMIDIPLAYER)!')
               [file_name, path_name] = uigetfile('*.exe', 'Select a MIDI Player');     % open file using Windows default dialog box
               midiplayer = strcat(path_name, file_name);
               fid = fopen('midiplayer.txt','w'); fprintf(fid,'%s',midiplayer); fclose(fid)
               cd(cur_dir);
               return
            else
               disp(['=>''',fullpath,'''',' is NOT correct FULLPATH argument'])
               [file_name, path_name] = uigetfile('*.exe', 'Select a MIDI Player');     % open file using Windows default dialog box
               midiplayer = strcat(path_name, file_name);
               fid = fopen('midiplayer.txt','w'); fprintf(fid,'%s',midiplayer); fclose(fid)
               cd(cur_dir);
               return
            end
         else
            cd(cur_dir);
         end
         
      else
         disp('MIDI player not correctly defined!');
         [file_name, path_name] = uigetfile('*.exe', 'Select a MIDI Player');     % open file using Windows default dialog box
         midiplayer = strcat(path_name, file_name);
         fid = fopen('midiplayer.txt','w');
         fprintf(fid,'%s',midiplayer);
         fclose(fid)
         cd(cur_dir);
         return
      end
   end
else
   disp('MIDI player not defined in midiplayer.txt!');
   [file_name, path_name] = uigetfile('*.exe', 'Select a MIDI Player');     % open file using Windows default dialog box
   midiplayer = strcat(path_name, file_name);
   fid = fopen('midiplayer.txt','w');
   fprintf(fid,'%s',midiplayer);
   fclose(fid);
   cd(cur_dir);
end

