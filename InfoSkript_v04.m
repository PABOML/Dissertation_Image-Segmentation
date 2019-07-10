% Johannes Maierhofer       TIP         06.07.2015-08.07.2015
%InfoSkript - Befehlssammlung zur Bildauswertung Fluoreszenzbilder

%% Merkliste:
% nearest, biliniear, box, lanczos2 oder lanczos3

clear all;
clc;

%% Bild einlesen, Kleinrechnen
%img = imread('image_cut.JPG');
img1 = imread('DSC_0033a.JPG'); %NP-Prozess
img2 = imread('DSC_0035a.JPG'); %TIP-Prozess
[height1, width1, planes1] = size(img1);
[height2, width2, planes2] = size(img2);
%N1 = 2048;
%N2 = N1*height1/width1;
%N2 = uint64(N2);
%rgbImage = imresize(img, [N2 N1], 'lanczos3'); %Resize Picture
rgbImage1 = img1; %Fullsize Picture
rgbImage2 = img2;
%imwrite(rgbImage,'image_small.jpg');

%% Convert RGB image to HSV
	hsvImage1 = rgb2hsv(rgbImage1);
    hsvImage2 = rgb2hsv(rgbImage2);
	% Extract out the H, S, and V images individually
	hImage1 = hsvImage1(:,:,1);
	sImage1 = hsvImage1(:,:,2);
	vImage1 = hsvImage1(:,:,3);

    hImage2 = hsvImage2(:,:,1);
	sImage2 = hsvImage2(:,:,2);
	vImage2 = hsvImage2(:,:,3);
    
        hueThresholdLow = 0.25;
        hueThresholdHigh = 0.45;
    
    % Maskieren der interessanten Bereiche
    hueMask1 = (hImage1 >= hueThresholdLow) & (hImage1 <= hueThresholdHigh);
	hueMask2 = (hImage2 >= hueThresholdLow) & (hImage2 <= hueThresholdHigh);
    %saturationMask = (sImage >= saturationThresholdLow) & (sImage <= saturationThresholdHigh);
	%valueMask = (vImage >= valueThresholdLow) & (vImage <= valueThresholdHigh);   
    %ObjectsMask = uint8(hueMask & saturationMask & valueMask);
    
%     hValue = sum(hueMask1);
%     hValue_t = sum(hueMask1');
%     hValue_sum = sum(hValue);
%     
    %Gewichten der Maske mit sValue des Bildes
    %hs_Value = hueMask.*(ones(uint64(N2),uint64(N1))-sImage); %Resize
    hs_Value1 = hueMask1.*(ones(height1,width1)-sImage1); %Fullsize-Picture
    hs_Value2 = hueMask2.*(ones(height2,width2)-sImage2); %Fullsize-Picture
  
    %surf(hs_Value);
    
    %hsValue = sum(hs_Value1);
    %hsValue_t = sum(hs_Value');
    %hsValue_sum = sum(hsValue);
    
    marked_1 = sum(sum(hueMask1));
    marked_2 = sum(sum(hueMask2));
    
    histmask_1 = (hs_Value1 >= 0.28) & (hs_Value1 <= 0.32);
    histmask_2 = (hs_Value2 >= 0.28) & (hs_Value2 <= 0.32);
    
    %% Histogrammmaskierung
    figure;
    subplot(2,2,1);
    imagesc(hs_Value1);
    subplot(2,2,3);
    imagesc(histmask_1);
    subplot(2,2,2);
    imagesc(hs_Value2);
    subplot(2,2,4);
    imagesc(histmask_2);
    
    %% Histogramm
    figure
    subplot(1,2,1)
    hist(hs_Value1)
    imhist(hs_Value1)
    subplot(1,2,2)
    imhist(hs_Value2)
    
    %% Kantendetektion
    Ed_1 = edge(hueMask1);
    Ed_2 = edge(hueMask2);
    
    Ed_num1 = sum(sum(Ed_1));
    Ed_num2 = sum(sum(Ed_2));
    
    figure;
    subplot(1,2,1);
    imagesc(Ed_1);
    axis equal;
    text(0,100,['Ed num1' num2str(Ed_num1)]);
    subplot(1,2,2);
    imagesc(Ed_2);
    axis equal;
    text(0,100,['Ed num2' num2str(Ed_num2)]);
    
    %% Mittelwert / Standardabweichung von hs_Value global
    
    u_1 = mean(mean(hs_Value1));
    u_2 = mean(mean(hs_Value2));
    
    %% Vergleichsplot
    figure;
    subplot(3,2,1);
    imagesc(rgbImage1);
    axis equal;
    subplot(3,2,2);
    imagesc(rgbImage2);
    axis equal;
    subplot(3,2,3);
    imagesc(hueMask1);
    axis equal;
    subplot(3,2,4);
    imagesc(hueMask2);
    axis equal;
    subplot(3,2,5);
    imagesc(hs_Value1);
    axis equal;
    subplot(3,2,6);
    imagesc(hs_Value2);
    axis equal;
   
    pause;
    %% Darstellung
%     figure;
%     subplot(2,2,1);
%     imagesc(rgbImage1);
%     axis equal;
%     subplot(2,2,2);
%     imagesc(hImage1);
%     axis equal;
%     subplot(2,2,3);
%     imagesc(vImage1);
%     axis equal;
%     subplot(2,2,4);
%     imagesc(sImage1);
%     axis equal;
%     
%      %% Abspeichern der einzelnen Schritte als Bilder
%     imwrite (hueMask1, 'image_hueMask.jpg');
%     imwrite (hImage1, 'image_hvalue.jpg');
%     imwrite (vImage1, 'image_vvalue.jpg');
%     imwrite (sImage1, 'image_svalue.jpg');
%     
%     %% Auswertung
%     hImage_filter = fspecial('gaussian',2, 0.5);
%     hImage_filtered = imfilter(hImage1, hImage_filter, 'replicate');
%     imwrite (hImage_filtered, 'image_hvalue_gauss.jpg');
%     surface = surf(hImage_filtered,vImage1);
%     
%     
%     pause;
%     %% Plot von Querschnitten in x-Richtung
%     for ind=10:10:N1
%     hline = filter(5,1,hImage1(:,ind));
%     subplot(1,2,1);
%     plot(hline);
%     hold;
%     vline = filter(2,1,vImage1(:,ind));
%     plot(vline);
%     hold;
%     subplot(1,2,2);
%     surf(hImage1(:,[1:ind]),vImage1(:,[1:ind]));
%     pause;
%     end 

