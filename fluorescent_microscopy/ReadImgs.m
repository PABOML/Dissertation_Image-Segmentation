 function [X,img] = ReadImgs(Folder,ImgType)
 %   JM: 16.07.2015
 %   Laden aller Bilder im Entsprechenden Ordner
 %   JM: 05.08.2015     - Name mit ins Array speichern
 
    Imgsdir = dir([Folder '/' ImgType]);
    
    for i = 1:length(Imgsdir)
    img{i,1} = imread([Folder '/' Imgsdir(i).name]);
    img{i,2} = Imgsdir(i).name;
    end
    
    X = length(Imgsdir);
    
end