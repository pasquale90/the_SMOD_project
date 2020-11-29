%SMOD_Sound Visualizer

%Dependencies : mirtoolbox1-7-2

frameLength = 1024;  
 
%reads the wav song 
song = dsp.AudioFileReader('SmoD_final_mix.wav','SamplesPerFrame',frameLength);%'ReadRange',[120*44100 inf] %-> replace with corresponding filename
%for playback the song
playbackSong = audioDeviceWriter('SampleRate',song.SampleRate); 
%getting the microphone input
%%KompleteMicReader = audioDeviceReader();
 
 
%initialize fft
ft = dsp.FFT('FFTLengthSource','Property', ...
    'FFTLength',512);
 
%increases input signal’s gain func
process = @(x) x.*9; 
 
scope = dsp.ArrayPlot( ...                 
    'SampleIncrement',1, ...
    'PlotType','Line', ...
    'AxesScaling','Manual', ...
    'MaximizeAxes','Off', ...
    'Name','ArrayPlotVisualizer', ...
    'ShowGrid',false);
 
disp('Start...')
tic
while toc<155%155song’s length in sec
    song_signal = song();
    %%mic = KompleteMicReader();    %microphone signal
    pr_ss = process(song_signal); 
    ft_s=ft(pr_ss);
    L=length(ft_s);
    
        %MODE 1
        
        %left channel -> mono to right side of fft -->zoomed(+L/25)-remove
        %part of the high frequencies
        left=ft_s(L/2+round(L/25):end,1);
        %right channel --> mono to left side of fft -->zoomed(-L/25)
        right=ft_s(1:L/2-round(L/25),2);
        %concatenate the selected values into a mono double side fft 
        final_fft=[right;left];
        
        %MODE 2
        %{
            final_fft=[left;right];
        %}
        
        %MODE 3_end   %concatenate only the parts of the specrum where
        %specific song's ending theme visualization is maximum for both channels 
        %{
            left_out=ft_s(7:round(L/7),1);
            left_in=ft_s(end-round(L/7):end-7,1);
            
            right_in=ft_s(7:round(L/7),2);
            right_out=ft_s(end-round(L/7):end-7,2);
        
            final_fft=[left_out;left_in;right_in;right_out];
        %}
         
        %Further...(optional)
        %{      
                %convert stereo fft to mono fft
                
                %1.convert fft to mono
                flip=flipud(left);
                fsum=right+flip;
                mono_averaged_right_and_left=fsum./2;
        
                %calculate magnitudes
                abs_mono_averaged_right_and_left=abs(mono_averaged_right_and_left);
        %}
            
  
    playbackSong(song_signal);
    scope(final_fft);
end
disp('End ...')
 
release(song);
release(playbackSong);
release(scope);
%release(KompleteMicReader);


