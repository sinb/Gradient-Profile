
function img_filtered = convolutionTwoKernel(img, kernel1, kernel2, mid)
    % 1:mid, mid+1:end
    [h, w] = size(img);
    [k_h, k_w] = size(kernel1);

    pad_size = floor(k_h/2); % pad_size is 1/2 of kernel size
    half_k_size = floor(k_h/2);
    pad_img = zeros(pad_size*2+h, pad_size*2+w);
    pad_img(pad_size+1:pad_size+h, pad_size+1:pad_size+w) = img;
    output = zeros(pad_size*2+h, pad_size*2+w);
    for col = pad_size+1:pad_size+w
        for row = pad_size+1:pad_size+h
            if (col-pad_size < mid) && (col+half_k_size <= pad_size+mid) %left part
%                 fprintf(fid,'(%d, %d) left part\n', col-pad_size, row-pad_size);
                conv_matrix_temp = pad_img(row-pad_size:row+pad_size, col-pad_size:col+pad_size) ...
                    .* kernel1;
                output(row, col) = sum(conv_matrix_temp(:));
            else if (col-pad_size > mid) && (col-half_k_size > pad_size+mid) 
%                     fprintf(fid,'(%d, %d) right part\n', col-pad_size, row-pad_size);
                    conv_matrix_temp = pad_img(row-pad_size:row+pad_size, col-pad_size:col+pad_size) ...
                        .* kernel2;
                    output(row, col) = sum(conv_matrix_temp(:));
                else
%                     fprintf('(%d, %d) in between\n', col-pad_size, row-pad_size);

                    img_left_temp = ...
                    padarray(pad_img(row-pad_size:row+pad_size, col-pad_size:pad_size+mid), [0, k_h-length(col-pad_size:pad_size+mid)], 'post');
                    img_right_temp = ...
                    padarray(pad_img(row-pad_size:row+pad_size, pad_size+mid+1:col+pad_size), [0, k_h-length(pad_size+mid+1:col+pad_size)], 'pre');
                    conv_matrix_temp = img_left_temp.*kernel1 + img_right_temp.*kernel2;
                    output(row, col) = sum(conv_matrix_temp(:));
                
                end

                
            end

    end
    img_filtered = output(pad_size+1:pad_size+w, pad_size+1:pad_size+h);

end