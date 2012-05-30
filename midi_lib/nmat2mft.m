function nmat2mft(nmat,ofname,tpq, tempo, tsig1, tsig2)
% Conversion of notematrix to MIDI text file
% nmat2mft(nmat, ofname, tpq, tempo, tsig1, tsig2)
%
% Input arguments: 
%	NMAT = notematrix
%	OFNAME = Output filename
%	TPQ = Ticks per quarter note
%	TEMPO = bpm, beats per minute
%	TSIG1&2 = Time-signature, e.g. 6/8 -> TSIG1 = 6, TSIG2 = 8
%
% Remarks: TEXT2MIDI converter needs to be handled differently in PC and Mac.
%
% Example: nmat2mft(nmat,'demo.txt', 120, 80, 4, 4);
%
%  Author		Date
% 30.2.2003	11:40	TE	Created under MATLAB 5.3 (PC)
%© Part of the MIDI Toolbox Software Package, Copyright © 2002, University of Jyväskylä, Finland
% See License.txt

if isempty(nmat), return; end

if nargin <2, ofname = 'temp.txt'; disp('Output filename missing, wrote results to "temp.txt" file'); end
if nargin <3, tpq=120;end
if nargin <4, tempo=100; end
if nargin <5, tsig1=4; end
if nargin <6, tsig2=4; disp('Default parameters used'); end

fid = fopen(ofname,'w');
ch = mchannels(nmat);
NCH = length(ch)+1;
str = [];

% write header
fprintf(fid,'MFile 1 %d %d\r\n', NCH, tpq);

% write conductor track
fprintf(fid,'MTrk\r\n');
fprintf(fid,'0 TimeSig %d/%d 24 8\r\n', tsig1, tsig2);
fprintf(fid,'0 Tempo %d\r\n', floor(1000000*60/tempo));
fprintf(fid,'0 Meta TrkEnd\r\n');
fprintf(fid,'TrkEnd\r\n');

for k=1:length(ch)
	tmp = [];
	nm = getmidich(nmat, ch(k));
	ontime=floor(onset(nm)*tpq);
	offtime = floor((onset(nm)+dur(nm))*tpq);
	p = pitch(nm);
	v = velocity(nm);
	for m=1:size(nm,1)
		tmp = [tmp; ontime(m) ch(k) p(m) v(m)];
		tmp = [tmp; offtime(m) ch(k) p(m) 0];
	end
	[Y,I] = sort(tmp(:,1));
	tmp2 = tmp(I,:);
	
	fprintf(fid,'MTrk\r\n');
	for m=1:size(tmp2,1)
		fprintf(fid,'%d On ch=%d n=%d v=%d\r\n', tmp2(m,1), tmp2(m,2), tmp2(m,3), tmp2(m,4));
	end
	fprintf(fid,'%d Meta TrkEnd\r\n', tmp2(end,1));
	fprintf(fid,'TrkEnd\r\n');
end

status = fclose(fid);
