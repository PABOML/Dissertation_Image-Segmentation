% Johannes Maierhofer       TIP         09.07.2015
% Ergaenzung PBockelmann Idealimpraegnierung 12.07.2015
% Anpassung PBockelmann an Versuche vom 14.07.2015
% JM: 16.07.2015 - Speicherung der Werte als .mat-file
%                - Bilder in Array. Dynamische Anpassung der Bildanzahl
%                - kleine Verbesserungen
%               - ToDo:         - Bildname mitnehmen, 
%                                   um Ergebnisse eindeutig
%                               - Barplots - Funktion 
%                               - Globalen Wert definieren
%                               - Positionscharakteristic aufnehmen


clear all;
clc;

%% Parameter

 Folder_images = 'img_process';
 Folder_results = 'results';
 ImgType = '*.JPG';

 % QKleinrechnen = input('Bilder Kleinrechnen? 0 = Nein, 1 = Ja ');
 QKleinrechnen = 1;
 max_px_width = 2048;
 
 hueThresholdLow = 0.25; %Einstellung Johannes: 0.25 - 0.45
 hueThresholdHigh = 0.5;
%% Bild einlesen, (Kleinrechnen)
[Number_imgs, ImageArray] = ReadImgs(Folder_images,ImgType);
if QKleinrechnen == 1 
ImageArray = ReduceImgs(ImageArray, max_px_width);            
end

%% Convert RGB image to HSV
% Extract out the H, S, and V images individually

%ToDo: Preallocate Memory

for i = 1:Number_imgs
hsvImageArray{i} = rgb2hsv(ImageArray{i});
hImageArray{i} = hsvImageArray{i}(:,:,1);
sImageArray{i} = hsvImageArray{i}(:,:,2);
vImageArray{i} = hsvImageArray{i}(:,:,3);
end


    % Maskieren der interessanten Bereiche
    
    for i = 1:Number_imgs
    hueMask{i} = (hImageArray{i} >= hueThresholdLow) & (hImageArray{i} <= hueThresholdHigh);     
    hs_Value{i} = hueMask{i}.*(ones(size(hImageArray{i}))-sImageArray{i});
    end
    
    %% Darstellung der eingelesenen Bilder
    %% Vergleichsflächen ermitteln
    
    GeneratePlot([ImageArray; hueMask; hs_Value]);
    
    display('Erstes Bild zum Einzeichnen der Ellipse markieren');
    display('Weiter mit beliebiger Taste');
    pause;
    
    for i = 1:Number_imgs
    freehand = imellipse;
    display('Ellipse ziehen');
    pause;
    Freehand_mask{i} = createMask(freehand);
    A_ref(i) = sum(sum(Freehand_mask{i}));
    display('Bild markieren');
    pause;
    end
    
    %% Auswertungsblöcke 
    %% Markierte Pixel im Verhältnis zu Referenzflächen
    
    for i = 1:Number_imgs
        Anteil_marked(i) = sum(sum(hueMask{i}))/A_ref(i);
    end

    
    %% Mittelwert / Standardabweichung von hs_Value global
    
    GeneratePlot([ImageArray;Freehand_mask]);
    
    %% mittlerer Sättigungswert aller gefärbten Harzbereiche über das gesamte Bauteil 
    
    for i = 1:Number_imgs
       c_0(i) = sum(sum(hs_Value{i}))/A_ref(i); 
       Mittelwert(i) = mean(mean(hs_Value{i}));
       Standardabweichung(i) = std(std(hs_Value{i}));
    end

   
    %% Kantenerkennung & Kantendefiniertheit
    
    for i = 1:Number_imgs
       Edge_Mask{i} = edge(hueMask{1}, 'canny');
       Kantendefiniertheit(i) = sum(sum(Edge_Mask{i}))/A_ref(i);
    end
    
    %Kennwerte_Kantendefiniertheit = def_Ref/Kantendefiniertheit;
    
    GeneratePlot([ImageArray;Edge_Mask]);
    
    figure;
    bar (Kantendefiniertheit);
    
    %% Results plot

    
%     difu_1 = abs(u_1-c_01)/c_01;
%     difu_2 = abs(u_2-c_02)/c_02;
%     difu_3 = abs(u_3-c_03)/c_03;
%     difu_4 = abs(u_4-c_04)/c_04;
%     difu_5 = abs(u_5-c_05)/c_05;
%     difu = [difu_1 difu_2 difu_3 difu_4 difu_5];
%     
%     figure;
%     subplot(1,4,1); 
%     bar (u);
%     title('Mean hs value');
%     subplot(1,4,2);
%     bar (std);
%     title('Standard deviation hs value');
%     subplot(1,4,3);
%     bar (difu);
%     title('Deviation of mean from mean hs value');
%     subplot(1,4,4);
%     bar (Kantendefiniertheit);
%     title('Edges of h values');
    
    %% Globale Qualitätskennzahl
    % Bestehend aus Kantendefiniertheit, Verteilungsdichte, und
    % Positionswert
    
    
       Quality = Kantendefiniertheit .* Mittelwert %Beispiel ohne große physikalische Bedeutung 
   
    
    %% Sichern der Ergebnisse

    save results.mat Kantendefiniertheit c_0 Mittelwert Standardabweichung Quality