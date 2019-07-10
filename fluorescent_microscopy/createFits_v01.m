function [fitresult, gof] = createFits_JM_v01(hist_x, hist_z, Folder_results, imagename1)

%% Initialization.

% Initialize arrays to store fits and goodness-of-fit.
fitresult = cell( 2, 1 );
gof = struct( 'sse', cell( 2, 1 ), ...
    'rsquare', [], 'dfe', [], 'adjrsquare', [], 'rmse', [] );

%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( [], hist_z );

% Set up fittype and options.
ft = fittype( 'poly1' );

% Fit model to data.
[fitresult{1}, gof(1)] = fit( xData, yData, ft );

% % Plot fit with data.
% fit1 = figure( 'Name', 'untitled fit 1' );
% h = plot( fitresult{1}, xData, yData );
% legend( h, 'hist_z', 'untitled fit 1', 'Location', 'NorthEast' );
% % Label axes
% ylabel hist_z
% grid on
% 
%         % Ausgabe als .pdf zur Ansicht.
%     set(fit1,'PaperOrientation','landscape');
%     set(fit1,'PaperUnits','normalized');
%     set(fit1,'PaperPosition', [0 0 1 1]);
%     print(fit1, '-dpdf', [Folder_results,'/',imagename1,'_fit1_print.pdf']);

%% Fit: 'untitled fit 2'.
[xData, yData] = prepareCurveData( [], hist_x );

% Set up fittype and options.
ft = fittype( 'poly1' );

% Fit model to data.
[fitresult{2}, gof(2)] = fit( xData, yData, ft );

% Plot fit with data.
% fit2 = figure( 'Name', 'untitled fit 2' );
% h = plot( fitresult{2}, xData, yData );
% legend( h, 'hist_x', 'untitled fit 2', 'Location', 'NorthEast' );
% % Label axes
% ylabel hist_x
% grid on
% 
%     % Ausgabe als .pdf zur Ansicht.
%     set(fit2,'PaperOrientation','landscape');
%     set(fit2,'PaperUnits','normalized');
%     set(fit2,'PaperPosition', [0 0 1 1]);
%     print(fit2, '-dpdf', [Folder_results,'/',imagename1,'_fit2_print.pdf']);

