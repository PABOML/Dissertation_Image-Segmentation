function [ Output_ImageArray ] = ReduceImgs( Input_ImageArray, px_length )
%ReduceImgs Summary of this function goes here
%   JM: 16.07.2015
%   Bilder Kleinrechnen. Längste Kante wird angegeben. Verhältnis bleibt
%   bestehen!

%Preallocate Memory!
%Output_ImageArray = zeros()

for i=1:length(Input_ImageArray)
N1 = px_length;
[height, width, ~] = size(Input_ImageArray(i));
N2 = N1*height/width;
N2 = uint64(N2);
Output_ImageArray{i} = imresize(Input_ImageArray{i}, [N2 N1], 'lanczos3'); %Resize Picture
end 

end

