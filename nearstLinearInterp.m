function [GradProfile, GradProfileX, GradProfileCenterLoc] = nearstLinearInterp(row, col, Gmag, Gdir, range)
% row, col is the location of the edge point
    GradProfile = [];
    [row_size, col_size] = size(Gmag);
%     close all
%% plot grid
    figure(1)
    fig = imshow(Gmag); hold on
%     plot(repmat((1:col_size),2,1), [0, row_size], 'b-')
%     plot([0, col_size], repmat((1:row_size),2,1), 'b-')
%% divide points by their direction degree in order to draw line and do interpolation
%     range = 10; % line length
    left_count = 0;
    right_count = 0;
        if Gdir(row, col) > 0 && Gdir(row, col) <= 45 ...
        || Gdir(row, col) >=135 && Gdir(row, col) < 180
            %% plot gradient direction line
            x_near = (col-range:1:col+range);
            y_near = ones(size(x_near))*row;
            tanValue = tan(Gdir(row, col) *pi/180);
            x_near_dist = x_near - col;
            y_near_dist = x_near_dist * tanValue;
            y_near = y_near + y_near_dist;  
            plot(x_near, y_near, 'r-');  
            %% find the interceptions along the line
            lxmb = @(x,mb) mb(1).*x + mb(2);    % Line equation: y = m*x+b
            m = tanValue;
            b = row - col*tanValue;
            mb = [m;b];
%             x = x_near;
%             y = (row-range:1:row+range);
            x = (0:size(Gmag, 2));
            y = (0:size(Gmag, 1));
            L1 = lxmb(x,mb);           
            hix = @(y,mb) [(y-mb(2))./mb(1);  y];   % Calculate horizontal intercepts
            vix = @(x,mb) [x;  lxmb(x,mb)];     % Calculate vertical intercepts
            hrz = hix(y,mb)' ;              % [X Y] Matrix of horizontal intercepts
            vrt = vix(x,mb)'  ;             % [X Y] Matrix of vertical intercepts
            hvix = [hrz; vrt];                 % Concatanated ‘hrz’ and ‘vrt’ arrays
            srtd = unique(round(hvix*10^4)/10^4,'rows');        % Remove repeats and sort ascending by ‘x’
            plot(srtd(:,1),srtd(:,2),'ro');
            plot(col, row, 'yo');
            %% do interpolation and return gradient profile
            edgePoint_idx = find(srtd(:,1)==col);
            % from center, first go left, then go right
            GradProfile = [Gmag(srtd(edgePoint_idx, 2), srtd(edgePoint_idx, 1))];
            GradProfileX = [srtd(edgePoint_idx, 1)];
%             delta = 1;
            for i = 1:1:col-1
                % go left
                % every point should have to nearest grid point, unless
                % they are grid point
                if left_count >= range
                    break;
                end
                    if srtd(edgePoint_idx-i, 2) == fix(srtd(edgePoint_idx-i, 2)) ...
                    && srtd(edgePoint_idx-i, 1) == fix(srtd(edgePoint_idx-i, 1))
                        % grid point, no need to interpolation, append left
                        % compute delta first
%                         delta = abs(GradProfile(1) - ...
%                             Gmag(srtd(edgePoint_idx-i, 2), srtd(edgePoint_idx-i, 1)));
                        interpValue = Gmag(srtd(edgePoint_idx-i, 2), srtd(edgePoint_idx-i, 1));
                        if interpValue >= 0.98*GradProfile(1)
                            if interpValue >= GradProfile(1) && interpValue ~= 0
                                GradProfile = ...
                                [Gmag(srtd(edgePoint_idx-i, 2), srtd(edgePoint_idx-i, 1)), GradProfile];
                                GradProfileX = [srtd(edgePoint_idx-i, 1), GradProfileX];
                                left_count = left_count + 1;
                            else
                                break;
                            end
                        else
                            GradProfile = ...
                            [Gmag(srtd(edgePoint_idx-i, 2), srtd(edgePoint_idx-i, 1)), GradProfile];
                            GradProfileX = [srtd(edgePoint_idx-i, 1), GradProfileX]; 
                            left_count = left_count + 1;
                        end                        
                    elseif srtd(edgePoint_idx-i, 1) == fix(srtd(edgePoint_idx-i, 1))
                            % need to do interpolation

                            % this point is on a vertical line
                            nearY1 = ceil(srtd(edgePoint_idx-i, 2));
                            nearY2 = floor(srtd(edgePoint_idx-i, 2));
                            interpValue = (srtd(edgePoint_idx-i, 2) - nearY2) * ...
                              Gmag(nearY2, srtd(edgePoint_idx-i, 1)) + ...
                              (nearY1 - srtd(edgePoint_idx-i, 2)) * ...
                              Gmag(nearY1, srtd(edgePoint_idx-i, 1));
                            if interpValue >= 0.98*GradProfile(1) || interpValue == 0
                                if interpValue >= GradProfile(1) && interpValue ~= 0
                                    GradProfile = [interpValue, GradProfile];
                                    GradProfileX = [srtd(edgePoint_idx-i, 1), GradProfileX];
                                    left_count = left_count + 1;
                                else
                                    break;
                                end
                            else
                                GradProfile = [interpValue, GradProfile];
                                GradProfileX = [srtd(edgePoint_idx-i, 1), GradProfileX];
                                left_count = left_count + 1;                  
                            end

                    else %need to do interpolation, this point is on horizion line
                        nearX2 = floor(srtd(edgePoint_idx-i, 1));
                        nearX1 = ceil(srtd(edgePoint_idx-i, 1));
                        interpValue = (srtd(edgePoint_idx-i, 1) - nearX2) * ...
                            Gmag(srtd(edgePoint_idx-i, 2), nearX2) + ...
                            (nearX1 - srtd(edgePoint_idx-i, 1)) * ...
                            Gmag(srtd(edgePoint_idx-i, 2), nearX1);
%                         delta = abs(interpValue - GradProfile(1));
                        if interpValue >= 0.98*GradProfile(1)
                            if interpValue >= GradProfile(1) && interpValue ~= 0
                                GradProfile = [interpValue, GradProfile];
                                GradProfileX = [srtd(edgePoint_idx-i, 1), GradProfileX];  
                                left_count = left_count + 1;
                            else
                                break;
                            end
                        else
                            GradProfile = [interpValue, GradProfile];
                            GradProfileX = [srtd(edgePoint_idx-i, 1), GradProfileX];
                            left_count = left_count + 1;
                        end

                    end
            end
            % store the center edge point's location in GradProfile
            GradProfileCenterLoc = length(GradProfile);
%             delta = 1; % give delta to 1 for a new loop
            for i=1:length(srtd)-edgePoint_idx-1
                % go right
                if right_count >= range
                    break;
                end
                    if srtd(edgePoint_idx+i, 2) == fix(srtd(edgePoint_idx+i, 2)) ...
                    && srtd(edgePoint_idx+i, 1) == fix(srtd(edgePoint_idx+i, 1))
                        % grid point, no need to interpolation, append left
                        % compute delta first
%                         delta = abs(GradProfile(end) - ...
%                             Gmag(srtd(edgePoint_idx+i, 2), srtd(edgePoint_idx+i, 1)));
                        interpValue = Gmag(srtd(edgePoint_idx+i, 2), srtd(edgePoint_idx+i, 1));
                            if interpValue >= 0.98*GradProfile(end)
                                if interpValue >= GradProfile(end) && interpValue ~= 0
                                    GradProfile = ...
                                    [GradProfile, interpValue];
                                    GradProfileX = [GradProfileX, srtd(edgePoint_idx+i, 1)];
                                    right_count = right_count + 1;
                                else
                                    break;
                                end
                            else
                                GradProfile = ...
                                    [GradProfile, interpValue];
                                GradProfileX = [GradProfileX, srtd(edgePoint_idx+i, 1)];
                                right_count = right_count + 1;
                                
                            end                          

                    elseif srtd(edgePoint_idx+i, 1) == fix(srtd(edgePoint_idx+i, 1))
                            % need to do interpolation

                            % this point is on a vertical line
                            nearY1 = ceil(srtd(edgePoint_idx+i, 2));
                            nearY2 = floor(srtd(edgePoint_idx+i, 2));
                            interpValue = (srtd(edgePoint_idx+i, 2) - nearY2) * ...
                                Gmag(nearY2, srtd(edgePoint_idx+i, 1)) + ...
                                (nearY1 - srtd(edgePoint_idx+i, 2)) * ...
                                Gmag(nearY1, srtd(edgePoint_idx+i, 1));
                            if interpValue >= 0.98*GradProfile(end) || interpValue == 0
                                if interpValue >= GradProfile(end) 
                                    GradProfile = [GradProfile, interpValue];
                                    GradProfileX = [GradProfileX, srtd(edgePoint_idx+i, 1)];
                                    right_count = right_count + 1;
                                else
                                    break;
                                end
                            else
                                GradProfile = [GradProfile, interpValue];
                                GradProfileX = [GradProfileX, srtd(edgePoint_idx+i, 1)]; 
                                right_count = right_count + 1;
                            end                          

                    else % need to do interpolation, this point in on horizion line
                        nearX2 = floor(srtd(edgePoint_idx+i, 1));
                        nearX1 = ceil(srtd(edgePoint_idx+i, 1));
                        interpValue = (srtd(edgePoint_idx+i, 1) - nearX2) * ...
                            Gmag(srtd(edgePoint_idx+i, 2), nearX2) + ...
                            (nearX1 - srtd(edgePoint_idx+i, 1)) * ...
                            Gmag(srtd(edgePoint_idx+i, 2), nearX1);
                            if interpValue >= 0.98*GradProfile(end)
                                if interpValue >= GradProfile(end) && interpValue ~= 0
                                    GradProfile = [GradProfile, interpValue];
                                    GradProfileX = [GradProfileX, srtd(edgePoint_idx+i, 1)];
                                    right_count = right_count + 1;
                                else
                                    break;
                                end
                            else
                                GradProfile = [GradProfile, interpValue];
                                GradProfileX = [GradProfileX, srtd(edgePoint_idx+i, 1)];
                                right_count = right_count + 1;
                                
                            end                           

                    end
            end
        elseif Gdir(row, col) == 0 || Gdir(row, col) == 180
            % horizon line
            x_near = (col-range:1:col+range);
            y_near = ones(size(x_near))*row;
            tanValue = tan(Gdir(row, col) *pi/180);
            x_near_dist = x_near - col;
            y_near_dist = x_near_dist * tanValue;
            y_near = y_near + y_near_dist;  
            plot(x_near, y_near, 'r-'); 
            plot(col, row, 'yo');
            % no need to do interpolation
            GradProfile = Gmag(row, col);
            GradProfileX = col;
            % start from center, go left
            for i=1:col-1
                if left_count >= range
                    break;
                end
                interpValue = Gmag(row, col-i);
                if interpValue >= 0.98*GradProfile(1) || interpValue == 0
                    if interpValue >= GradProfile(1) && interpValue ~= 0
                        GradProfile = [Gmag(row, col-i), GradProfile];
                        GradProfileX = [col-i, GradProfileX];  
                        left_count = left_count + 1;
                    else
                        break;
                    end
                else
                    GradProfile = [interpValue, GradProfile];
                    GradProfileX = [col-i, GradProfileX];
                    left_count = left_count + 1;
                end
            end
            GradProfileCenterLoc = length(GradProfile);
            % go right
            for i=1:length(Gmag)-col-1
                if right_count >= range
                    break;
                end                
                interpValue = Gmag(row, col+i);
                if interpValue >= 0.98*GradProfile(end)  || interpValue == 0
                    if interpValue >= GradProfile(end)
                        GradProfile = [GradProfile, interpValue];
                        GradProfileX = [GradProfileX, col+i];
                        right_count = right_count + 1;
                    else
                        break;
                    end
                else
                    GradProfile = [GradProfile, interpValue];
                    GradProfileX = [GradProfileX, col+i];
                    right_count = right_count + 1;
                end
            end            

        elseif Gdir(row, col) == 90
               y_near = (row-range:1:row+range);
               x_near = ones(size(y_near))*col;
               plot(x_near, y_near, 'b-');hold on
               plot(col, row, 'ro');
               % vertical line, no need to do interpolation
                GradProfile = Gmag(row, col);
                GradProfileX = row; 
               % from center go up
               for i=1:row-1
                if left_count >= range
                    break;
                end                   
                   interpValue = Gmag(row-i, col);
                   if interpValue >= 0.98*GradProfile(1)  || interpValue == 0
                       if interpValue >= GradProfile(1) && interpValue ~= 0
                           GradProfile = [Gmag(row-i, col), GradProfile];
                           GradProfileX = [row-i, GradProfileX];
                           left_count = left_count + 1;
                       else
                           break
                       end
                   else
                       GradProfile = [Gmag(row-i, col), GradProfile];
                       GradProfileX = [row-i, GradProfileX];
                       left_count = left_count + 1;
                   end
                   GradProfileCenterLoc = length(GradProfile);
                   % go down
                   for i=1:length(Gmag)-row-1
                       if right_count >= range
                           break;
                       end
                       interpValue = Gmag(row+i, col);
                       if interpValue >= 0.98*GradProfile(end) || interpValue == 0
                           if interpValue >= GradProfile(end)
                               GradProfile = [GradProfile, interpValue];
                               GradProfileX = [GradProfileX, row+i];
                               right_count = right_count + 1;
                           else
                               break;
                           end
                       else
                           GradProfile = [GradProfile, interpValue];
                           GradProfileX = [GradProfileX, row+i];
                           right_count = right_count + 1;
                       end
                       
                   end
               end
        else
            tanValue = tan(Gdir(row, col) *pi/180);
            y_near = (row-range:1:row+range);
            y_near_dist = y_near - row;
            x_near = ones(size(y_near))*col;
            x_near_dist = y_near_dist / tanValue;
            x_near = x_near + x_near_dist;
            plot(x_near, y_near, 'b-');
            plot(col, row, 'ro'); 
            %% find the interceptions
            lxmb = @(x,mb) mb(1).*x + mb(2);    % Line equation: y = m*x+b
            m = tanValue;
            b = row - col*tanValue;
            mb = [m;b];
%             x = x_near;
%             y = (row-range:1:row+range);
            x = (0:length(Gmag));
            y = x;
            L1 = lxmb(x,mb);           
            hix = @(y,mb) [(y-mb(2))./mb(1);  y];   % Calculate horizontal intercepts
            vix = @(x,mb) [x;  lxmb(x,mb)];     % Calculate vertical intercepts
            hrz = hix(y,mb)' ;            % [X Y] Matrix of horizontal intercepts
            vrt = vix(x,mb)'  ;             % [X Y] Matrix of vertical intercepts
            hvix = [hrz; vrt];                 % Concatanated ‘hrz’ and ‘vrt’ arrays
            srtd = unique(round(hvix*10^4)/10^4,'rows');        % Remove repeats and sort ascending by ‘x’
            plot(srtd(:,1),srtd(:,2),'ro');
            plot(col, row, 'yo');
            %% do interpolation and return gradient profile
            edgePoint_idx = find(srtd(:,1)==col);
            % from center, first go left, then go right
            GradProfile = [Gmag(srtd(edgePoint_idx, 2), srtd(edgePoint_idx, 1))];
            GradProfileX = [srtd(edgePoint_idx, 1)];
            for i = 1:1:col-1
                if left_count >= range
                    break;
                end                
                % go left
                % every point should have two nearest grid points, unless
                % they are grid point
                    if srtd(edgePoint_idx-i, 2) == fix(srtd(edgePoint_idx-i, 2)) ...
                    && srtd(edgePoint_idx-i, 1) == fix(srtd(edgePoint_idx-i, 1))
                        % grid point, no need to interpolation, append left
                        % compute delta first
%                         delta = abs(GradProfile(1) - ...
%                             Gmag(srtd(edgePoint_idx-i, 2), srtd(edgePoint_idx-i, 1)));
                        interpValue = Gmag(srtd(edgePoint_idx-i, 2), srtd(edgePoint_idx-i, 1));
                        if interpValue >= 0.98*GradProfile(1) || interpValue == 0
                            if interpValue >= GradProfile(1) && interpValue ~= 0
                                GradProfile = ...
                                [interpValue, GradProfile];
                                GradProfileX = [srtd(edgePoint_idx-i, 1), GradProfileX]; 
                                left_count = left_count + 1;
                            else
                                break;
                            end
                        else
                            GradProfile = ...
                                [interpValue, GradProfile];
                            GradProfileX = [srtd(edgePoint_idx-i, 1), GradProfileX]; 
                            left_count = left_count + 1;
                        end

                    elseif srtd(edgePoint_idx-i, 1) == fix(srtd(edgePoint_idx-i, 1))
                            % need to do interpolation

                            % this point is on a vertical line
                            nearY1 = ceil(srtd(edgePoint_idx-i, 2));
                            nearY2 = floor(srtd(edgePoint_idx-i, 2));
                            interpValue = (srtd(edgePoint_idx-i, 2) - nearY2) * ...
                              Gmag(nearY2, srtd(edgePoint_idx-i, 1)) + ...
                              (nearY1 - srtd(edgePoint_idx-i, 2)) * ...
                              Gmag(nearY1, srtd(edgePoint_idx-i, 1));
                          if interpValue >= 0.98*GradProfile(1) || interpValue == 0
                              if interpValue >= GradProfile(1) && interpValue ~= 0
                                  GradProfile = [interpValue, GradProfile];
                                  GradProfileX = [srtd(edgePoint_idx-i, 1), GradProfileX];
                                  left_count = left_count + 1;
                              else
                                  break
                              end
                          else
                              GradProfile = [interpValue, GradProfile];
                              GradProfileX = [srtd(edgePoint_idx-i, 1), GradProfileX];
                              left_count = left_count + 1;
                          end

                    else %need to do interpolation, this point in on horizion line
                        nearX2 = floor(srtd(edgePoint_idx-i, 1));
                        nearX1 = ceil(srtd(edgePoint_idx-i, 1));
                        interpValue = (srtd(edgePoint_idx-i, 1) - nearX2) * ...
                            Gmag(srtd(edgePoint_idx-i, 2), nearX2) + ...
                            (nearX1 - srtd(edgePoint_idx-i, 1)) * ...
                            Gmag(srtd(edgePoint_idx-i, 2), nearX1);
                        if interpValue >= 0.98*GradProfile(1) || interpValue == 0
                            if interpValue >= GradProfile(1) && interpValue ~= 0
                                GradProfile = [interpValue, GradProfile];
                                GradProfileX = [srtd(edgePoint_idx-i, 1), GradProfileX];
                                left_count = left_count + 1;
                            else
                                break;
                            end
                        else
                            GradProfile = [interpValue, GradProfile];
                            GradProfileX = [srtd(edgePoint_idx-i, 1), GradProfileX];
                            left_count = left_count + 1;
                        end
                    end
            end
            % store the center edge point's location in GradProfile
            GradProfileCenterLoc = length(GradProfile);
            delta = 1; % give delta to 1 for a new loop
            for i=1:length(srtd)-edgePoint_idx-1
                if right_count >= range
                    break;
                end                
                % go right
                    if srtd(edgePoint_idx+i, 2) == fix(srtd(edgePoint_idx+i, 2)) ...
                    && srtd(edgePoint_idx+i, 1) == fix(srtd(edgePoint_idx+i, 1))
                        % grid point, no need to interpolation, append left
                        interpValue = Gmag(srtd(edgePoint_idx+i, 2), srtd(edgePoint_idx+i, 1));
                        if interpValue >= 0.98*GradProfile(end) || interpValue == 0
                            if interpValue >= GradProfile(end)
                                
                                GradProfile = ...
                                    [GradProfile, interpValue];
                                GradProfileX = [GradProfileX, srtd(edgePoint_idx+i, 1)];
                                right_count = right_count + 1;
                            else
                                break;
                            end
                        else
                            GradProfile = ...
                                [GradProfile, interpValue];
                            GradProfileX = [GradProfileX, srtd(edgePoint_idx+i, 1)];
                        end

                    elseif srtd(edgePoint_idx+i, 1) == fix(srtd(edgePoint_idx+i, 1))
                            % need to do interpolation

                            % this point is on a vertical line
                            nearY1 = ceil(srtd(edgePoint_idx+i, 2));
                            nearY2 = floor(srtd(edgePoint_idx+i, 2));
                            interpValue = (srtd(edgePoint_idx+i, 2) - nearY2) * ...
                              Gmag(nearY2, srtd(edgePoint_idx+i, 1)) + ...
                              (nearY1 - srtd(edgePoint_idx+i, 2)) * ...
                              Gmag(nearY1, srtd(edgePoint_idx+i, 1));
                          if interpValue >= 0.98*GradProfile(end) || interpValue == 0
                              if interpValue >= GradProfile(end)
                                  GradProfile = [GradProfile, interpValue];
                                  GradProfileX = [GradProfileX, srtd(edgePoint_idx+i, 1)];
                                  right_count = right_count + 1;
                              else
                                  break;
                              end
                          else
                              GradProfile = [GradProfile, interpValue];
                              GradProfileX = [GradProfileX, srtd(edgePoint_idx+i, 1)];
                              right_count = right_count + 1;
                          end

                    else %need to do interpolation, this point in on horizion line
                        nearX2 = floor(srtd(edgePoint_idx+i, 1));
                        nearX1 = ceil(srtd(edgePoint_idx+i, 1));
                        interpValue = (srtd(edgePoint_idx+i, 1) - nearX2) * ...
                            Gmag(srtd(edgePoint_idx+i, 2), nearX2) + ...
                            (nearX1 - srtd(edgePoint_idx+i, 1)) * ...
                            Gmag(srtd(edgePoint_idx+i, 2), nearX1);
                        if interpValue >= 0.98*GradProfile(end) || interpValue == 0
                            if interpValue >= GradProfile(end)
                                GradProfile = [GradProfile, interpValue];
                                GradProfileX = [GradProfileX, srtd(edgePoint_idx+i, 1)];
                                right_count = right_count + 1;
                            else
                                break;
                            end
                        else
                            GradProfile = [GradProfile, interpValue];
                            GradProfileX = [GradProfileX, srtd(edgePoint_idx+i, 1)];
                            right_count = right_count + 1;
                        end

                    end
            end            
        end
end