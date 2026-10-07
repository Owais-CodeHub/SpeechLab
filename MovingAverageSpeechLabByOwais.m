function MovingAverageSpeechLabByOwais
% MovingAverageSpeechLabByOwais
% Interactive GUI for demonstrating moving-average filtering on speech.
% Muhammad Owais
% Research Scientist
% Khalifa University
% https://scholar.google.com/citations?hl=en&user=M6QUSTwAAAAJ&view_op=list_works&sortby=pubdate
%
% Workflow:
% STEP 1: Record or load speech
% STEP 2: Add Gaussian noise
% STEP 3: Apply moving-average filter
% STEP 4: Compare and listen
%
% Signals & Systems:
%   x[n] = original/input speech
%   w[n] = Gaussian noise
%   x_noisy[n] = x[n] + w[n]
%   h[n] = moving-average FIR coefficients
%   y[n] = filtered output
%
% For a W-point simple moving average:
%   y[n] = (1/W) sum_{k=0}^{W-1} x_noisy[n-k]
%
% MATLAB filter() uses zero initial conditions, so the causal output has
% the same number of samples as the input.

%% Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
S.fs = 44100;
S.original = [];
S.noise = [];
S.noisy = [];
S.filtered = [];
S.h = [];
S.player = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Main GUI
fig = uifigure('Name','Moving Average Speech Filter Lab', ...
    'Position',[80 45 1450 870], ...
    'Color',[0.97 0.98 1.00]);

main = uigridlayout(fig,[5 1]);
main.RowHeight = {78,170,'1x',100,30};
main.Padding = [14 12 14 10];
main.RowSpacing = 9;

%% Header
header = uipanel(main,'BackgroundColor',[0.90 0.95 1.00], ...
    'BorderType','line');

hg = uigridlayout(header,[2 1]);
hg.RowHeight = {38,26};
hg.Padding = [10 5 10 4];

uilabel(hg,'Text','Moving Average Filter: Speech Denoising by Dr. Muhammad Owais', ...
    'FontSize',22,'FontWeight','bold', ...
    'HorizontalAlignment','center', ...
    'FontColor',[0.05 0.20 0.40]);

uilabel(hg,'Text', ...
    'Research Scientist | Khalifa University', ...
    'FontSize',12,'HorizontalAlignment','center', ...
    'FontColor',[0.20 0.28 0.38]);

%% Clear step-by-step control area
controls = uipanel(main,'Title','Experiment Steps', ...
    'FontWeight','bold','BackgroundColor',[1 1 1]);

steps = uigridlayout(controls,[1 4]);
steps.ColumnWidth = {'1x','1x','1.15x','0.9x'};
steps.Padding = [8 8 8 8];
steps.ColumnSpacing = 10;

% STEP 1
p1 = uipanel(steps,'Title','STEP 1 - Voice Input', ...
    'FontWeight','bold','BackgroundColor',[0.96 0.98 1.00]);
g1 = uigridlayout(p1,[4 2]);
g1.RowHeight = {28,30,30,30};
g1.ColumnWidth = {'1x','1x'};
g1.Padding = [6 5 6 5];

uilabel(g1,'Text','Duration (s):','FontWeight','bold');
dur = uispinner(g1,'Limits',[3 20],'Value',10,'Step',1);

btnRecord = uibutton(g1,'Text','Record Voice', ...
    'ButtonPushedFcn',@recordVoice);
btnLoad = uibutton(g1,'Text','Load Audio', ...
    'ButtonPushedFcn',@loadAudio);

btnPlayOriginal = uibutton(g1,'Text','Play Original', ...
    'ButtonPushedFcn',@(src,event)playSignal('original'));
btnStop1 = uibutton(g1,'Text','Stop Audio', ...
    'ButtonPushedFcn',@stopAudio);

labStep1 = uilabel(g1,'Text','Record 10-15 s or load an audio file.', ...
    'FontAngle','italic','WordWrap','on');
labStep1.Layout.Row = 4;
labStep1.Layout.Column = [1 2];

% STEP 2
p2 = uipanel(steps,'Title','STEP 2 - Add Noise', ...
    'FontWeight','bold','BackgroundColor',[1.00 0.98 0.94]);
g2 = uigridlayout(p2,[4 2]);
g2.RowHeight = {28,30,30,30};
g2.ColumnWidth = {'1x','1x'};
g2.Padding = [6 5 6 5];

uilabel(g2,'Text','SNR (dB):','FontWeight','bold');
snrSpin = uispinner(g2,'Limits',[-5 40],'Value',10,'Step',1);

btnNoise = uibutton(g2,'Text','Add Noise', ...
    'ButtonPushedFcn',@addNoise);
btnNewNoise = uibutton(g2,'Text','New Noise', ...
    'ButtonPushedFcn',@addNoise);

btnPlayNoise = uibutton(g2,'Text','Play Noise', ...
    'ButtonPushedFcn',@(src,event)playSignal('noise'));
btnPlayNoisy = uibutton(g2,'Text','Play Noisy Voice', ...
    'ButtonPushedFcn',@(src,event)playSignal('noisy'));

labStep2 = uilabel(g2,'Text','Noise and noisy speech appear below.', ...
    'FontAngle','italic','WordWrap','on');
labStep2.Layout.Row = 4;
labStep2.Layout.Column = [1 2];

% STEP 3
p3 = uipanel(steps,'Title','STEP 3 - Moving Average Filter', ...
    'FontWeight','bold','BackgroundColor',[0.96 1.00 0.96]);
g3 = uigridlayout(p3,[4 2]);
g3.RowHeight = {28,30,32,30};
g3.ColumnWidth = {'1x','1.35x'};
g3.Padding = [6 5 6 5];

uilabel(g3,'Text','Window W:','FontWeight','bold');
winSpin = uispinner(g3,'Limits',[3 10],'Value',5,'Step',1);

uilabel(g3,'Text','Filter Type:','FontWeight','bold');
filterType = uidropdown(g3, ...
    'Items',{'Simple Moving Average','Weighted Moving Average'}, ...
    'Value','Simple Moving Average');

btnFilter = uibutton(g3,'Text','APPLY FILTER', ...
    'FontWeight','bold','FontSize',12, ...
    'ButtonPushedFcn',@applyFilter);
btnPlayFiltered = uibutton(g3,'Text','Play Filtered', ...
    'ButtonPushedFcn',@(src,event)playSignal('filtered'));

formula = uilabel(g3,'Text','Choose W = 3 to 10, then press APPLY FILTER.', ...
    'FontAngle','italic','WordWrap','on');
formula.Layout.Row = 4;
formula.Layout.Column = [1 2];

% STEP 4
p4 = uipanel(steps,'Title','STEP 4 - Compare', ...
    'FontWeight','bold','BackgroundColor',[0.98 0.98 1.00]);
g4 = uigridlayout(p4,[4 1]);
g4.RowHeight = {30,30,30,30};
g4.Padding = [6 5 6 5];

btnReplayNoisy = uibutton(g4,'Text','Replay Noisy Voice', ...
    'ButtonPushedFcn',@(src,event)playSignal('noisy'));
btnReplayFiltered = uibutton(g4,'Text','Replay Filtered', ...
    'ButtonPushedFcn',@(src,event)playSignal('filtered'));
btnStop2 = uibutton(g4,'Text','Stop Audio', ...
    'ButtonPushedFcn',@stopAudio);
btnReset = uibutton(g4,'Text','Reset All', ...
    'ButtonPushedFcn',@resetApp);

%% Plots
plotsPanel = uipanel(main,'BackgroundColor',[1 1 1]);

pg = uigridlayout(plotsPanel,[2 2]);
pg.RowHeight = {'1x','1x'};
pg.ColumnWidth = {'1x','1x'};
pg.Padding = [8 8 8 8];
pg.RowSpacing = 8;
pg.ColumnSpacing = 10;

ax1 = uiaxes(pg);
configureAxis(ax1,'1. Original Voice Signal  x[n]');

axNoise = uiaxes(pg);
configureAxis(axNoise,'2. Gaussian Noise  w[n]');

ax2 = uiaxes(pg);
configureAxis(ax2,'3. Noisy Voice  x_{noisy}[n] = x[n] + w[n]');

ax3 = uiaxes(pg);
configureAxis(ax3,'4. Filtered Output  y[n]');

%% Information panel
info = uipanel(main,'Title','Signals & Systems Interpretation', ...
    'FontWeight','bold','BackgroundColor',[0.97 1.00 0.97]);

ig = uigridlayout(info,[2 4]);
ig.RowHeight = {30,42};
ig.ColumnWidth = {'1x','1x','1x','1x'};
ig.Padding = [10 6 10 5];

labX = uilabel(ig,'Text','x[n]: Original speech','FontWeight','bold');
labNoise = uilabel(ig,'Text','w[n]: Gaussian noise','FontWeight','bold');
labH = uilabel(ig,'Text','h[n]: Filter not applied','FontWeight','bold');
labY = uilabel(ig,'Text','y[n]: Filtered output','FontWeight','bold');

note = uilabel(ig, ...
    'Text',['Observe the trade-off: increasing W generally gives more smoothing, ' ...
            'but a very large window can reduce speech detail and clarity.'], ...
    'WordWrap','on','FontSize',11);
note.Layout.Row = 2;
note.Layout.Column = [1 4];

%% Status
status = uilabel(main,'Text','Ready. Start with STEP 1.', ...
    'FontWeight','bold','FontColor',[0.10 0.30 0.55]);

updateButtons();

%% =========================== CALLBACKS =================================

    function recordVoice(~,~)
        stopAudio();
        seconds = round(dur.Value);

        try
            rec = audiorecorder(44100,16,1);
            status.Text = sprintf('Recording for %d seconds... Speak now.',seconds);
            status.FontColor = [0.75 0.15 0.10];
            drawnow;

            recordblocking(rec,seconds);
            x = getaudiodata(rec,'double');

            S.fs = 44100;
            S.original = safeNormalize(x);
            S.noise = [];
            S.noisy = [];
            S.filtered = [];
            S.h = [];

            plotOriginal();
            clearLaterPlots();

            status.Text = 'STEP 1 complete. Continue to STEP 2: Add Noise.';
            status.FontColor = [0.05 0.45 0.15];

            updateInfo();
            updateButtons();

        catch ME
            uialert(fig,ME.message,'Recording Error');
        end
    end

    function loadAudio(~,~)
        stopAudio();

        [f,p] = uigetfile({'*.wav;*.mp3;*.m4a;*.flac','Audio Files'; ...
                           '*.wav','WAV Files'; '*.*','All Files'}, ...
                           'Choose a speech recording');

        if isequal(f,0)
            return;
        end

        try
            [x,fs0] = audioread(fullfile(p,f));

            if size(x,2) > 1
                x = mean(x,2);
            end

            S.fs = fs0;
            S.original = safeNormalize(x);
            S.noise = [];
            S.noisy = [];
            S.filtered = [];
            S.h = [];

            plotOriginal();
            clearLaterPlots();

            status.Text = sprintf('Loaded %s. Continue to STEP 2: Add Noise.',f);
            status.FontColor = [0.05 0.45 0.15];

            updateInfo();
            updateButtons();

        catch ME
            uialert(fig,ME.message,'Audio File Error');
        end
    end

    function addNoise(~,~)
        if isempty(S.original)
            uialert(fig,'Please complete STEP 1 first: record or load a voice signal.', ...
                'No Input Signal');
            return;
        end

        stopAudio();

        x = S.original;
        targetSNR = snrSpin.Value;

        signalPower = mean(x.^2);

        if signalPower < eps
            uialert(fig,'The input signal has almost zero power.','Invalid Signal');
            return;
        end

        noisePower = signalPower / (10^(targetSNR/10));
        w = sqrt(noisePower) * randn(size(x));

        S.noise = w;
        S.noisy = x + w;
        S.filtered = [];
        S.h = [];

        t = (0:numel(x)-1)'/S.fs;

        plot(axNoise,t,S.noise,'LineWidth',0.7);
        configureAxis(axNoise, ...
            sprintf('2. Gaussian Noise  w[n]  (Target SNR = %.1f dB)',targetSNR));

        plot(ax2,t,S.noisy,'LineWidth',0.7);
        configureAxis(ax2,'3. Noisy Voice  x_{noisy}[n] = x[n] + w[n]');

        cla(ax3);
        configureAxis(ax3,'4. Filtered Output  y[n]');

        actualSNR = 10*log10(mean(x.^2)/mean(w.^2));

        status.Text = sprintf(['STEP 2 complete. Noise and noisy speech are displayed. ' ...
            'Actual SNR = %.2f dB. Continue to STEP 3.'],actualSNR);
        status.FontColor = [0.55 0.30 0.05];

        formula.Text = 'Choose W = 3 to 10, then press APPLY FILTER.';

        updateInfo();
        updateButtons();
    end

    function applyFilter(~,~)
        if isempty(S.noisy)
            uialert(fig,'Please complete STEP 2 first and add noise.', ...
                'No Noisy Signal');
            return;
        end

        stopAudio();

        W = round(winSpin.Value);

        if strcmp(filterType.Value,'Simple Moving Average')
            h = ones(1,W)/W;
            filterLabel = sprintf('%d-point Simple Moving Average',W);
            formula.Text = sprintf( ...
                'y[n] = (1/%d) sum_{k=0}^{%d} x_{noisy}[n-k]',W,W-1);
        else
            weights = W:-1:1;
            h = weights/sum(weights);
            filterLabel = sprintf('%d-point Weighted Moving Average',W);
            formula.Text = ...
                'y[n] = sum h[k]x_{noisy}[n-k] (larger weight on recent samples)';
        end

        % Causal same-length FIR filtering
        y = filter(h,1,S.noisy);

        S.filtered = safePlaybackScale(y);
        S.h = h;

        t = (0:numel(S.filtered)-1)'/S.fs;

        plot(ax3,t,S.filtered,'LineWidth',0.8);
        configureAxis(ax3,['4. Filtered Output  y[n] - ' filterLabel]);

        coeffText = sprintf(' %.3f',h);
        labH.Text = sprintf('h[n] = [%s ]',strtrim(coeffText));

        status.Text = sprintf(['STEP 3 complete. Filtered signal is displayed. ' ...
            'W = %d. Compare noisy and filtered audio in STEP 4.'],W);
        status.FontColor = [0.05 0.45 0.15];

        updateInfo();
        updateButtons();
    end

    function playSignal(whichOne)
        stopAudio();

        switch whichOne
            case 'original'
                x = S.original;
                label = 'original voice';

            case 'noise'
                x = S.noise;
                label = 'Gaussian noise';

            case 'noisy'
                x = S.noisy;
                label = 'noisy voice';

            case 'filtered'
                x = S.filtered;
                label = 'filtered voice';

            otherwise
                return;
        end

        if isempty(x)
            uialert(fig,['No ' whichOne ' signal is available yet.'], ...
                'Nothing to Play');
            return;
        end

        try
            S.player = audioplayer(safePlaybackScale(x),S.fs);
            play(S.player);

            status.Text = ['Playing ' label '...'];
            status.FontColor = [0.10 0.30 0.55];

        catch ME
            uialert(fig,ME.message,'Audio Playback Error');
        end
    end

    function stopAudio(~,~)
        if ~isempty(S.player)
            try
                if isplaying(S.player)
                    stop(S.player);
                end
            catch
            end
        end
    end

    function resetApp(~,~)
        stopAudio();

        S.original = [];
        S.noise = [];
        S.noisy = [];
        S.filtered = [];
        S.h = [];

        cla(ax1);     configureAxis(ax1,'1. Original Voice Signal  x[n]');
        cla(axNoise); configureAxis(axNoise,'2. Gaussian Noise  w[n]');
        cla(ax2);     configureAxis(ax2,'3. Noisy Voice  x_{noisy}[n] = x[n] + w[n]');
        cla(ax3);     configureAxis(ax3,'4. Filtered Output  y[n]');

        labH.Text = 'h[n]: Filter not applied';
        formula.Text = 'Choose W = 3 to 10, then press APPLY FILTER.';

        status.Text = 'Ready. Start with STEP 1.';
        status.FontColor = [0.10 0.30 0.55];

        updateInfo();
        updateButtons();
    end

%% ========================= HELPERS ======================================

    function plotOriginal()
        t = (0:numel(S.original)-1)'/S.fs;
        plot(ax1,t,S.original,'LineWidth',0.8);
        configureAxis(ax1,'1. Original Voice Signal  x[n]');
    end

    function clearLaterPlots()
        cla(axNoise);
        configureAxis(axNoise,'2. Gaussian Noise  w[n]');

        cla(ax2);
        configureAxis(ax2,'3. Noisy Voice  x_{noisy}[n] = x[n] + w[n]');

        cla(ax3);
        configureAxis(ax3,'4. Filtered Output  y[n]');
    end

    function configureAxis(ax,ttl)
        title(ax,ttl);
        xlabel(ax,'Time (s)');
        ylabel(ax,'Amplitude');
        grid(ax,'on');
        ax.Box = 'on';
    end

    function updateInfo()
        if isempty(S.original)
            labX.Text = 'x[n]: Original speech';
        else
            labX.Text = sprintf('x[n]: %d samples | Fs = %d Hz', ...
                numel(S.original),S.fs);
        end

        if isempty(S.noise)
            labNoise.Text = 'w[n]: Gaussian noise';
        else
            labNoise.Text = sprintf('w[n]: %d samples | SNR = %.1f dB', ...
                numel(S.noise),snrSpin.Value);
        end

        if isempty(S.filtered)
            labY.Text = 'y[n]: Filtered output';
        else
            labY.Text = sprintf('y[n]: %d samples (same length)', ...
                numel(S.filtered));
        end
    end

    function updateButtons()
        btnPlayOriginal.Enable = onOff(~isempty(S.original));
        btnNoise.Enable = onOff(~isempty(S.original));
        btnNewNoise.Enable = onOff(~isempty(S.original));

        btnPlayNoise.Enable = onOff(~isempty(S.noise));
        btnPlayNoisy.Enable = onOff(~isempty(S.noisy));

        btnFilter.Enable = onOff(~isempty(S.noisy));
        btnReplayNoisy.Enable = onOff(~isempty(S.noisy));

        btnPlayFiltered.Enable = onOff(~isempty(S.filtered));
        btnReplayFiltered.Enable = onOff(~isempty(S.filtered));

        btnStop1.Enable = 'on';
        btnStop2.Enable = 'on';
    end

    function out = onOff(tf)
        if tf
            out = 'on';
        else
            out = 'off';
        end
    end

    function y = safeNormalize(x)
        x = double(x(:));
        x(~isfinite(x)) = 0;

        mx = max(abs(x));

        if mx > 0
            y = 0.95*x/mx;
        else
            y = x;
        end
    end

    function y = safePlaybackScale(x)
        y = double(x(:));
        y(~isfinite(y)) = 0;

        mx = max(abs(y));

        if mx > 0.99
            y = 0.99*y/mx;
        end
    end

end
