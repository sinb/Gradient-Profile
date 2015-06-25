% function init()
%     [img, left_val, right_val] = generateImage(100, 100)
% end
function img = generateImage(height, width, left_value, right_value, channel)
% generate synthetic image
    img = ones(height, width, channel);
    for channel_idx=1:1:channel
      img(:, 1:floor(width/2), channel_idx) = img(:, 1:floor(width/2), channel_idx)* left_value;
      img(:, floor(width/2)+1:end, channel_idx) = img(:, floor(width/2)+1:end, channel_idx) * right_value;
    end

end
