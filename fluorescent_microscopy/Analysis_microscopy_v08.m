%Auswertung_Mikroskopie_v06_JM
% Johannes Maierhofer       TIP         05.08.2015

% VORRAUSSETZUNGEN Skripten/Funktionen:
% GeneratePlot.m
% ReadImgs.m
% ReduceImgs.m

% BESCHREIBUNG: Dieses Skript wertet alle Bilder im Folder_images
% entsprechend der entwickelten Methode aus und erzeug jeweils einen
% .pdf-plot

% Changelog:
% JM: 08.12.2015: Erstellung des ersten Version
% JM: 13.12.2015: Anpassungen und Erweiterungen
% JM_PB: 15.12.2015: Umstellen von hue auf v-Value Threshold; Curvefitting
% als Kennwerte einrichten
% JM: 18.12.2015: feste ROI-Größe implementieren; Reduzierung der
% hist_Vektoren
% JM: 22.12.2015: Umstellen auf 16bit Grauwerte
%%

close all;
clear all;
clc;

%% Parameter

 Folder_images = 'Daten';
 Folder_results = 'Daten';
 
 ImgType = '*.tif';

 % QKleinrechnen = input('Bilder Kleinrechnen? 0 = Nein, 1 = Ja ');
 QKleinrechnen = 0;
 max_px_width = 4096;
  
 %Skalierungsfaktor in Echtgrößen bei unskalierten Bildern:
 Scale_mm_px = 0.001; %#ToDo: Skalierungsfaktor ermitteln
 
 number_ein_aus = 1; %Ein/Ausschalten von manueller Speicherpunktanzahl 0 ist aus
 number_faktor = 5;
 number_x = 1200; %Speicherpunkte in Excel "insgesamt 100 st/Bildbreite werden abgelegt"
 number_z = 150;
 
 vThresholdLow = 150; %
 vThresholdHigh = 5000  ;
 
 ROI_ein_aus = 1; %Ein/Ausschalten der manuellen ROI_vorgabe 0 ist aus
 ROI_width = 11823;
 ROI_height = 847;

%% Bild einlesen, (Kleinrechnen)
[Number_imgs, ImageArray] = ReadImgs(Folder_images,ImgType);
if QKleinrechnen == 1 
[ImageArray(:,1), Scale_mm_px] = ReduceImgs(ImageArray(:,1), max_px_width, Scale_mm_px);            
end


%% Convert RGB image to HSV
% Extract out the H, S, and V images individually

%#ToDo: Preallocate Memory

% for i = 1:Number_imgs
% hsvImageArray{i} = rgb2hsv(ImageArray{i,1});
% hImageArray{i} = hsvImageArray{i}(:,:,1);
% sImageArray{i} = hsvImageArray{i}(:,:,2);
% vImageArray{i} = hsvImageArray{i}(:,:,3);
% end
 

    % Maskieren der fluoreszierenden Bereiche
    
    for i = 1:Number_imgs
    vMask{i} = (ImageArray{i,1} >= vThresholdLow) & (ImageArray{i,1} <= vThresholdHigh);     
%     hs_Value{i} = vMask{i}.*(ones(size(hImageArray{i}))-sImageArray{i});
%     hv_Value{i} = vMask{i}.*hImageArray{i};
    end
 
    
    %% Wenn bereits ROIs vorliegen diese Verwenden
    
    try 
        display('Versuche ROI aus Datei zu laden');
        load([Folder_results '/ROIs.mat']);
        if strcmp(ImageArray(:,2),ROI(:,3))
            Freehand_mask = ROI(:,1)';
            A_ref = cell2mat(ROI(:,2))';
            display('Erfolgreich ROI aus Datei zu Bildern geladen');
        else
            display('Datei gefunden. Aber nicht passend zu den Bildern');
            rethrow(err)
        end
    catch err
        display('Keine ROI für die entsprechenden Bilder gefunden. Neue Anlegen:');
            for i = 1:Number_imgs
             figure;
             imagesc(cell2mat(ImageArray(i,1)));
             axis equal;
             title(ImageArray{i,2}, 'interpreter', 'none');
             h = imrect;
             if ROI_ein_aus == 0
                 [ROI_height, ROI_width, ~] = size(ImageArray{i,1});
                 ROI_height=ROI_height-1;
                 ROI_width=ROI_width-1;
             end    
             setPosition(h,[0,0,ROI_width,ROI_height]);
             setResizable(h,0);
             if ROI_ein_aus == 0
                setConstrainedPosition(h,[0,0,ROI_width,ROI_height]);
             end
             freehand = h;
             annotation('textbox',[0.15, 0.25, 0.2, 0.3],'String','Nächstes Bild mit beliebiger Taste', 'color', 'white');
             display('Nächstes Bild mit beliebiger Taste');
             pause;
             rect_roi{i}= getPosition(freehand);
             Freehand_mask{i} = createMask(freehand);
             A_ref(i) = sum(sum(Freehand_mask{i}));
             close;
        end
            
        ROI = [Freehand_mask',num2cell(A_ref)',ImageArray(:,2),rect_roi'];
        save([Folder_results '/ROIs.mat'], 'ROI');
    end
    
    %% Ausgabe der Maske als .jpg
    for i = 1:Number_imgs
        
          [wy, wx, ~] = size(ImageArray{i,1});
        
          pos = round(cell2mat(ROI(i,4)));
          pos(pos<=0)=1;
          if pos(3)>(pos(1)+wx)
             pos(2)=wx-pos(1); 
          end
          if pos(4)>(pos(2)+wy)
             pos(4)=wy-pos(2); 
          end
          
         rect{i} = zeros(wy,wx);
         rect{i}(pos(2),pos(1):(pos(3)+pos(1)))=1;
         rect{i}((pos(2)+pos(4)),pos(1):(pos(3)+pos(1)))=1;
         rect{i}(pos(2):(pos(2)+pos(4)),pos(1))=1;
         rect{i}(pos(2):(pos(2)+pos(4)),pos(1)+pos(3))=1;
          
        imwrite(cat(3,rect{i}*255,vMask{i}*255,zeros(wy,wx)), [Folder_results '/log/h-mask_' num2str(i) '.jpg']);
 
        % apply gamma correction
        imageRGBGamma = imadjust(ImageArray{i,1},[],[], 0.25);
        % convert to 8 bit
        imagegray8 = im2uint8(imageRGBGamma); 
        %imshow(imagegray8);
        imwrite((cat(3,imagegray8,imagegray8,imagegray8)+uint8(cat(3,rect{i}*255,zeros(wy,wx),zeros(wy,wx)))), [Folder_results '/log/img_' num2str(i) '.jpg']); 
        imwrite(imcrop(cat(3,imagegray8,imagegray8,imagegray8),cell2mat(ROI(i,4))), [Folder_results '/log/img_crop_' num2str(i) '.jpg']); 
    end
    
    %% Maske der ROI auf h-Maske-Ebenen anwenden
    
    for i = 1:Number_imgs
        vMask{i} = Freehand_mask{i} & vMask{i};   
    end
    
    GeneratePlot([ImageArray(:,1)'; vMask;],ImageArray(:,2));
    
    %% MESSUNG 1
    % Markierte Pixel im Verhältnis zu Referenzflächen
    
    for i = 1:Number_imgs
        Anteil_marked(i) = sum(sum(vMask{i}))/A_ref(i);
    end

  
  %% Häufigkeitsverteilung in x- und y-Richtung inklusive plot der Daten

for i = 1:Number_imgs
  
    imagename=ImageArray{i,2};
    imagename1=[imagename,'-Ausgabe'];
    
    [wy, wx, ~] = size(ImageArray{i,1});
    
    I2{i} = imcrop(ImageArray{i,1},cell2mat(ROI(i,4)));
    I3_vMask{i} = imcrop(cat(3,zeros(wy,wx),vMask{i}*255,zeros(wy,wx)),cell2mat(ROI(i,4))); 
    
    [wy_klein, wx_klein, ~] = size(I3_vMask{i}(:,:,2));   
    
      hist_x = sum(I3_vMask{i}(:,:,2),1)/A_ref(i);
      hist_z = sum(I3_vMask{i}(:,:,2),2)/A_ref(i);
      
      if number_ein_aus == 0
          number_x = round(wx_klein/number_faktor);
          number_z = round(wy_klein/number_faktor);
      end
  % Reduzieren der Vektoren für hist_x und hist_z:
  xq = linspace(0,wx_klein,number_x);
  zq = linspace(0,wy_klein,number_z);
  
        hist_x_short = interp1(hist_x,xq);
        hist_z_short = interp1(hist_z,zq);
    
        cumhist_x_short = cumtrapz(hist_x_short(2:end));
        cumhist_z_short = cumtrapz(hist_z_short(2:end));
        
   %Kennwerte durch Fit von erwarteten Funktionen 
      [fitresult{i}, gof{i}]=createFits_JM_v01(hist_x_short,hist_z_short,Folder_results,imagename1);
        
  %Plot der Daten in eine figure
  
    pic=figure;
    subplot(3,3,[7 8]);
            imageRGBGamma = imadjust(I2{i},[0.0 0.03],[],0.35);
            imagegray8 = im2uint8(imageRGBGamma);
    imshow(imagegray8);
    subplot(3,3, [4 5]);
    imshow(I3_vMask{i});
%   imshow(ImageArray{i,1});
    grid on;
    subplot(3,3,[1 2]);
    [AX,H1,H2] = plotyy((1:number_x),hist_x_short,(2:number_x),cumhist_x_short);
%    h1=plot(fitresult{i}{2},'predobs');
%    h1 = legend('hide');
    title('x-Richtung');
    ylabel(AX(1),'Häufigkeit');
    ylabel(AX(2),'Integral');
    xlabel('x');
    ylim(AX(1),[0,0.04]);
    AX(1).YTick = [0:0.005:0.04];
    AX(1).YTickLabel=[0:0.005:0.04];
    xlim(AX(1),[0,number_x]);
    ylim(AX(2),[0,20]);
    AX(2).YTick = [0:2.5:20];
    AX(2).YTickLabel=[0:2.5:20];
    xlim(AX(2),[0,number_x]);
    grid on;
    ax = subplot(3,3,3);
    ax.Visible='off';
    coeffvals_x = coeffvalues(fitresult{i}{2});
    text(0,1,['Bildname: ',imagename],'interpreter','none');
    text(0,0.7,['Parameter x-fit:']);
    text(0,0.6,['h(x)= ',num2str(coeffvals_x(1)),'x+',num2str(coeffvals_x(2))]);
    text(0,0.5,['Integral Endwert: ',num2str(cumhist_x_short(end))]);
    coeffvals_z = coeffvalues(fitresult{i}{1});
    text(0,0.2,['Parameter z-fit:']);
    text(0,0.1,['h(z)= ',num2str(coeffvals_z(1)),'z+',num2str(coeffvals_z(2))]);
    text(0,0,['Integral Endwert: ',num2str(cumhist_z_short(end))]);
    subplot(3,3,6);
    %h=plot(hist_z);
    %hold on;
    plot(hist_z_short);
    hold on;
%    plot(cumhist_z_short);
    h2=plot(fitresult{i}{1},'predobs');
    h2 = legend('hide');
    title('z-Richtung');
    ylabel('Häufigkeit');
    xlabel('z');
    ylim([0,0.3]);
    xlim([0,number_z]);
    grid on;
    view(90,90);
    
    %set(pic,'color','none');
    saveas(pic,[Folder_results,'/',imagename1],'svg') ;       % Ausgabe als Vektorgrafik. 

    % Ausgabe als .pdf zur Ansicht.
    set(pic,'PaperOrientation','landscape');
    set(pic,'PaperUnits','normalized');
    set(pic,'PaperPosition', [0 0 1 1]);
    print(pic, '-dpdf', [Folder_results,'/',imagename1,'_print.pdf']);

  %Sichern der Daten als .xls
  %%
%     Ergebnisse={num2str(hist_x_short); num2str(hist_z_short);num2str(cumhist_x_short);num2str(cumhist_z_short);num2str(coeffvals_x);num2str(coeffvals_z)};
%     file = 'Mikroskopieauswertung.xls';
%     [~,a,~] = xlsread(file);      % store data of file in variable a
%     nRows = (size(a,1));    % last row with data in the file
%     nRows = nRows +8;       % plus 2 to write in the next line
%     b = num2str(nRows);      % convert number to string
%     c = strcat('A', b);      % if you want to add data to the collum A you make concat strings
%     d = strcat('B', b);
%     xlswrite('Mikroskopieauswertung.xls',{imagename},1,c);
%     xlswrite('Mikroskopieauswertung.xls',Ergebnisse,1,d);
    
    save(['mikroskopieauswertung_',imagename,'.mat'], 'hist_x_short', 'hist_z_short', 'cumhist_x_short', 'cumhist_z_short', 'coeffvals_x', 'coeffvals_z');
end