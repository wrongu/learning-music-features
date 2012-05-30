% initialize workspace for project

clearvars -except song2d_cell parallel pool;
close all;
clc;

addpath('./midi_lib/');
addpath('./midi files/');
addpath('./testers/');
addpath('./saved data/');

helper_get_midi_names;