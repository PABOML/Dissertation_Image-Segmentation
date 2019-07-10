function [] = GeneratePlot( Input )
%GeneratePlot Summary of this function goes here
%   JM: 16.07.2015
%   Generiert Vergleichsplot aller übergebenen Matrixen in der
%   Bilddarstellung

    [vertikal_number, horizontal_number] = size(Input);

    figure;
    
    for i = 1:vertikal_number
        for j = 1:horizontal_number
            subplot(vertikal_number, horizontal_number,j+i*4-4);
            imagesc(cell2mat(Input(i,j)));
            axis equal;
        end
    end

end

