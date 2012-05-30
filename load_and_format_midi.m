% load_and_format_midi(path_to_midi)
%
% Given path to song3D, returns matrix of my custom song3D format
%
% Format:
%   song3D: 3D matrix
%     - dim 1 : beat
%     - dim 2 : pitch  (1:12)
%     - dim 3 : octave (1:4)

function [song2D, song3D] = load_and_format_midi(path_to_midi)
    try
        songmat = midi2nmat(path_to_midi);
        fprintf('loading song %s\n', path_to_midi);

        midi_lo = 21; % low A

        % middle C is midi 60, and is called 'C4'
        %  <http://www.phys.unsw.edu.au/jw/notes.html>

        onset_beats = songmat(:,1);
        durations   = songmat(:,2);
        midi_pitch  = songmat(:,4);

        beat_intervals = diff(onset_beats);
        nonzero_intervals = beat_intervals(beat_intervals > 1E-5);
        smallest_interval = max(min(nonzero_intervals), 0.0625);

        max_beat = max(onset_beats) / smallest_interval;

        midi_shifted = midi_pitch - midi_lo;
        midi_note    = mod(midi_shifted, 12)  + 1;
        midi_octave  = floor(midi_pitch / 12) + 1;
        onset_beats  = beat_to_time_index(onset_beats, smallest_interval);

        song3D = zeros(ceil(max_beat), 12, 8);
        song2D = zeros(ceil(max_beat), 88);

        for i = 1:length(onset_beats)
            note = midi_note(i);
            oct = midi_octave(i);
            onset = onset_beats(i);
            duration = beat_to_time_index(durations(i), smallest_interval);

            song3D(onset:onset+duration, note, oct) = 1;
            song2D(onset:onset+duration, midi_shifted(i)) = 1;
        end
    catch e
        fprintf('error reading song %s\n', path_to_midi);
        song2D = [];
    end
end

function index = beat_to_time_index(beat, smallest_interval)
    index = floor(beat / smallest_interval);
end