function [] = GeneratePlot( InputPicArray, NameArray )
%GeneratePlot Summary of this function goes here
%   JM: 16.07.2015
%   Generiert Vergleichsplot aller übergebenen Matrixen in der
%   Bilddarstellung
%   JM: 05.08.2015  - Einfügen von Namen als title

    [vertikal_number, horizontal_number] = size(InputPicArray);

    figure;
    
    for i = 1:vertikal_number
        for j = 1:horizontal_number
            subplot(vertikal_number, horizontal_number,j+i*horizontal_number-horizontal_number);
            imagesc(cell2mat(InputPicArray(i,j)));
            axis equal;
            title(NameArray{j}, 'interpreter', 'none');
        end
    end

end

