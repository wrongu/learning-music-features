function n = writemidi(nmat, ofname, tpq, tempo, tsig1, tsig2)
% Writes a MIDI file from a NMAT 
% n = writemidi(nmat, ofname, <tpq>, <tempo>, <tsig1>, <tsig2>);
%
% Creates a MIDI file from a NMAT using various optional parameters
%
% Input arguments: NMAT = notematrix
%     OFNAME = Output filename (*.mid)
%	TPQ (Optional) = Ticks per quarter note (default 120)
%	TEMPO (Optional) = bpm, beats per minute (default 100)
%	TSIG1&2 (Optional) = Time-signature, e.g. 6/8 -> TSIG1 = 6, TSIG2 = 8 (default 4)
%
% Output: MIDI file
%
% Remarks: TEXT2MIDI converter needs to be handled differently in PC and Mac.
%
% Example: writemidi(a,'demo.mid'); creates a file name DEMO.MID from notematrix A with
% default settings. 
%
%  Author		Date
%  T. Eerola	1.2.2003
%© Part of the MIDI Toolbox, Copyright © 2004, University of Jyvaskyla, Finland
% See License.txt

if isempty(nmat), return; end
if nargin <2, ofname = 'temp.mid'; end
if nargin <3, tpq=120; end
if nargin <4, tempo=100; end
if nargin <5, tsig1=4; end
if nargin <6, tsig2=4; disp('Default parameters used'); end

% Create a temporary text filename
ofname0 = strrep(ofname, 'mid', 'txt');

% Convert to text file
nmat2mft(nmat, ofname0, tpq, tempo, tsig1, tsig2);

% Convert to MIDI file
mft2mf(ofname0,ofname)

% Delete text file
delete(ofname0)
