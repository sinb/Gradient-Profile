function  intercepColRow = findIntercept2(row, col, Gdir, Gmag)
%FINDINTERCEPT2 find interception points along line which's degree is 0
%since the line is horizontal, just return the same row value, and an array
%of integers of col.
    [row_size, col_size] = size(Gmag);
    intercepColRow = ones(col_size, 2);
    intercepColRow(:,1) = (1:col_size)';
    intercepColRow(:,2) = intercepColRow(:,2) * row;
    
end