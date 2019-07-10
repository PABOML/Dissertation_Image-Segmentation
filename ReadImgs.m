 function [X,img] = ReadImgs(Folder,ImgType)
 %   JM: 16.07.2015
 %   Laden aller Bilder im Entsprechenden Ordner
 
    Imgsdir = dir([Folder '/' ImgType]);
    
    for i = 1:length(Imgsdir)
    img{i} = imread([Folder '/' Imgsdir(i).name]);
    end
    
    X = length(Imgsdir);
    
end