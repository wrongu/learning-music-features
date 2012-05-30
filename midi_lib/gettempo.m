function bpm = gettempo(nmat)
% Get tempo (in BPM)
% bpm = gettempo(nmat)
% Return the tempo of the NMAT. Note that MIDI files 
% can be encoded using any arbitrary tempo.
%
% Input argument:
%	NMAT = notematrix
%
% Output:
%	BPM = Tempo (in beats per minute)
%
% Change History :
% Date		Time	Prog	Note
% 1.7.2003	18:52	TE	Created under MATLAB 5.3 (PC)
%© Part of the MIDI Toolbox, Copyright © 2004, University of Jyvaskyla, Finland
% See License.txt

if isempty(nmat), return; end
beat=nmat(end,1);
beatdur=nmat(end,6); %
bpm = (60/beatdur)*beat;
