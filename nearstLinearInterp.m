function [GradProfile, GradProfileX, GradProfileCenterLoc] = nearstLinearInterp(row, col, Gmag, Gdir, range)
%NEARSTLINEARINTERP use linear interpolation to calcute sub-pixel values
%and draw gradient profile

% row, col is the location of the edge point
    GradProfile = [];
    [row_size, col_size] = size(Gmag);
%   close all
%% plot grid
    subplot(3,1,2) %use this when draw sythetic image using subplot
%     figure
    imshow(Gmag); hold on
%     plot(repmat((1:col_size),2,1), [0, row_size], 'b-')
%     plot([0, col_size], repmat((1:row_size),2,1), 'b-')
%% divide points by their direction degree in order to draw line and do interpolation
%     range = 10; % line length
    left_count = 0;
    right_count = 0;
        if Gdir(row, col) > 0 && Gdir(row, col) <= 45 ...
        || Gdir(row, col) >=135 && Gdir(row, col) < 180
            %% plot gradient direction line
            drawDirection1(row, col, range, Gdir)
            %% find the interceptions along the line
            intercepColRow = findIntercept1(row, col, Gdir, Gmag);
            plot(intercepColRow(:,1),intercepColRow(:,2),'ro');
            plot(col, row, 'yo');
            %% find a local max value near edge point along the line, only search 1 neighbor
            edgePoint_idx = find(intercepColRow(:,1)==col);
            leftValue = Gmag(round(intercepColRow(edgePoint_idx-1,2)), round(intercepColRow(edgePoint_idx-1,1)));
            rightValue = Gmag(round(intercepColRow(edgePoint_idx+1,2)), round(intercepColRow(edgePoint_idx+1,1)));
            values = [leftValue, Gmag(row, col), rightValue];
            rowValues = [round(intercepColRow(edgePoint_idx-1,2)), row, round(intercepColRow(edgePoint_idx+1,2))];
            colValues = [round(intercepColRow(edgePoint_idx-1,1)), col, round(intercepColRow(edgePoint_idx+1,1))];
            [maxValue, maxIndex] = max(values);
            
            maxIndex = find(values == maxValue);
            maxIndex = maxIndex(end);
            plot(col, row, 'go');
            plot(round(intercepColRow(edgePoint_idx-1,1)), round(intercepColRow(edgePoint_idx-1,2)), 'yo')
            plot(round(intercepColRow(edgePoint_idx+1,1)), round(intercepColRow(edgePoint_idx+1,2)), 'yo')
            plot(colValues(maxIndex), rowValues(maxIndex), 'bo')
            % assign col, row to the local max point's locations, and
            % change Gdir(rowNew, colNew) to Gdir(row, col)
            Gdir(rowValues(maxIndex), colValues(maxIndex)) = Gdir(row, col);
            col = colValues(maxIndex);
            row = rowValues(maxIndex);
            %% redraw line and recompute interceptions because the start point has changed
            drawDirection1(row, col, range, Gdir);
            intercepColRow = findIntercept1(row, col, Gdir, Gmag);
            plot(intercepColRow(:,1),intercepColRow(:,2),'mo');
            plot(col, row, 'co');            
            %% do interpolation and return gradient profile
            edgePoint_idx = find(intercepColRow(:,1)==col);
            % from center, first go left, then go right
            GradProfile = [Gmag(intercepColRow(edgePoint_idx, 2), intercepColRow(edgePoint_idx, 1))];
            GradProfileX = [intercepColRow(edgePoint_idx, 1)];
%             delta = 1;
            for i = 1:1:col-1
                % go left
                % every point should have to nearest grid point, unless
                % they are grid point
                if left_count >= range
                    break;
                end
                    if intercepColRow(edgePoint_idx-i, 2) == fix(intercepColRow(edgePoint_idx-i, 2)) ...
                    && intercepColRow(edgePoint_idx-i, 1) == fix(intercepColRow(edgePoint_idx-i, 1))
                        % grid point, no need to interpolation, append left
                        % compute delta first
%                         delta = abs(GradProfile(1) - ...
%                             Gmag(intercepColRow(edgePoint_idx-i, 2), intercepColRow(edgePoint_idx-i, 1)));
                        interpValue = Gmag(intercepColRow(edgePoint_idx-i, 2), intercepColRow(edgePoint_idx-i, 1));
                        if (interpValue >= 0.9*GradProfile(1) && (interpValue-GradProfile(1))>0.0001) || interpValue < 0.0001
%                             if interpValue >= GradProfile(1) && interpValue ~= 0
%                                 GradProfile = ...
%                                 [Gmag(intercepColRow(edgePoint_idx-i, 2), intercepColRow(edgePoint_idx-i, 1)), GradProfile];
%                                 GradProfileX = [intercepColRow(edgePoint_idx-i, 1), GradProfileX];
%                                 left_count = left_count + 1;
%                             else
                                break;
%                             end
                        else
                            GradProfile = ...
                            [Gmag(intercepColRow(edgePoint_idx-i, 2), intercepColRow(edgePoint_idx-i, 1)), GradProfile];
                            GradProfileX = [intercepColRow(edgePoint_idx-i, 1), GradProfileX]; 
                            left_count = left_count + 1;
                        end                        
                    elseif intercepColRow(edgePoint_idx-i, 1) == fix(intercepColRow(edgePoint_idx-i, 1))
                            % need to do interpolation

                            % this point is on a vertical line
                            nearY1 = ceil(intercepColRow(edgePoint_idx-i, 2));
                            nearY2 = floor(intercepColRow(edgePoint_idx-i, 2));
                            interpValue = (intercepColRow(edgePoint_idx-i, 2) - nearY2) * ...
                              Gmag(nearY2, intercepColRow(edgePoint_idx-i, 1)) + ...
                              (nearY1 - intercepColRow(edgePoint_idx-i, 2)) * ...
                              Gmag(nearY1, intercepColRow(edgePoint_idx-i, 1));
                            if (interpValue >= 0.9*GradProfile(1) && (interpValue-GradProfile(1))>0.0001) || interpValue < 0.0001
%                                 if interpValue >= GradProfile(1) && interpValue ~= 0
%                                     GradProfile = [interpValue, GradProfile];
%                                     GradProfileX = [intercepColRow(edgePoint_idx-i, 1), GradProfileX];
%                                     left_count = left_count + 1;
%                                 else
                                    break;
%                                 end
                            else
                                GradProfile = [interpValue, GradProfile];
                                GradProfileX = [intercepColRow(edgePoint_idx-i, 1), GradProfileX];
                                left_count = left_count + 1;                  
                            end

                    else %need to do interpolation, this point is on horizion line
                        nearX2 = floor(intercepColRow(edgePoint_idx-i, 1));
                        nearX1 = ceil(intercepColRow(edgePoint_idx-i, 1));
                        interpValue = (intercepColRow(edgePoint_idx-i, 1) - nearX2) * ...
                            Gmag(intercepColRow(edgePoint_idx-i, 2), nearX2) + ...
                            (nearX1 - intercepColRow(edgePoint_idx-i, 1)) * ...
                            Gmag(intercepColRow(edgePoint_idx-i, 2), nearX1);
%                         delta = abs(interpValue - GradProfile(1));
                        if (interpValue >= 0.9*GradProfile(1) && (interpValue-GradProfile(1))>0.0001) || interpValue < 0.0001
%                             if interpValue >= GradProfile(1) && interpValue ~= 0
%                                 GradProfile = [interpValue, GradProfile];
%                                 GradProfileX = [intercepColRow(edgePoint_idx-i, 1), GradProfileX];  
%                                 left_count = left_count + 1;
%                             else
                                break;
%                             end
                        else
                            GradProfile = [interpValue, GradProfile];
                            GradProfileX = [intercepColRow(edgePoint_idx-i, 1), GradProfileX];
                            left_count = left_count + 1;
                        end

                    end
            end
            % store the center edge point's location in GradProfile
            GradProfileCenterLoc = length(GradProfile);
%             delta = 1; % give delta to 1 for a new loop
            for i=1:length(intercepColRow)-edgePoint_idx-1
                % go right
                if right_count >= range
                    break;
                end
                    if intercepColRow(edgePoint_idx+i, 2) == fix(intercepColRow(edgePoint_idx+i, 2)) ...
                    && intercepColRow(edgePoint_idx+i, 1) == fix(intercepColRow(edgePoint_idx+i, 1))
                        % grid point, no need to interpolation, append left
                        % compute delta first
%                         delta = abs(GradProfile(end) - ...
%                             Gmag(intercepColRow(edgePoint_idx+i, 2), intercepColRow(edgePoint_idx+i, 1)));
                        interpValue = Gmag(intercepColRow(edgePoint_idx+i, 2), intercepColRow(edgePoint_idx+i, 1));
%                             if interpValue >= 0.9*GradProfile(end)
                              if (interpValue >= 0.9*GradProfile(end) && (interpValue-GradProfile(end))>0.0001) || interpValue < 0.0001
%                                 if interpValue >= GradProfile(end) && interpValue ~= 0
%                                     GradProfile = ...
%                                     [GradProfile, interpValue];
%                                     GradProfileX = [GradProfileX, intercepColRow(edgePoint_idx+i, 1)];
%                                     right_count = right_count + 1;
%                                 else
                                    break;
%                                 end
                            else
                                GradProfile = ...
                                    [GradProfile, interpValue];
                                GradProfileX = [GradProfileX, intercepColRow(edgePoint_idx+i, 1)];
                                right_count = right_count + 1;
                                
                            end                          

                    elseif intercepColRow(edgePoint_idx+i, 1) == fix(intercepColRow(edgePoint_idx+i, 1))
                            % need to do interpolation

                            % this point is on a vertical line
                            nearY1 = ceil(intercepColRow(edgePoint_idx+i, 2));
                            nearY2 = floor(intercepColRow(edgePoint_idx+i, 2));
                            interpValue = (intercepColRow(edgePoint_idx+i, 2) - nearY2) * ...
                                Gmag(nearY2, intercepColRow(edgePoint_idx+i, 1)) + ...
                                (nearY1 - intercepColRow(edgePoint_idx+i, 2)) * ...
                                Gmag(nearY1, intercepColRow(edgePoint_idx+i, 1));
%                             if interpValue >= 0.9*GradProfile(end) || interpValue < 0.0001
                              if (interpValue >= 0.9*GradProfile(end) && (interpValue-GradProfile(end))>0.0001) || interpValue < 0.0001
%                                 if interpValue >= GradProfile(end) 
%                                     GradProfile = [GradProfile, interpValue];
%                                     GradProfileX = [GradProfileX, intercepColRow(edgePoint_idx+i, 1)];
%                                     right_count = right_count + 1;
%                                 else
                                    break;
%                                 end
                            else
                                GradProfile = [GradProfile, interpValue];
                                GradProfileX = [GradProfileX, intercepColRow(edgePoint_idx+i, 1)]; 
                                right_count = right_count + 1;
                            end                          

                    else % need to do interpolation, this point in on horizion line
                        nearX2 = floor(intercepColRow(edgePoint_idx+i, 1));
                        nearX1 = ceil(intercepColRow(edgePoint_idx+i, 1));
                        interpValue = (intercepColRow(edgePoint_idx+i, 1) - nearX2) * ...
                            Gmag(intercepColRow(edgePoint_idx+i, 2), nearX2) + ...
                            (nearX1 - intercepColRow(edgePoint_idx+i, 1)) * ...
                            Gmag(intercepColRow(edgePoint_idx+i, 2), nearX1);
%                             if interpValue >= 0.9*GradProfile(end)
                            if (interpValue >= 0.9*GradProfile(end) && (interpValue-GradProfile(end))>0.0001) || interpValue < 0.0001
%                                 if interpValue >= GradProfile(end) && interpValue ~= 0
%                                     GradProfile = [GradProfile, interpValue];
%                                     GradProfileX = [GradProfileX, intercepColRow(edgePoint_idx+i, 1)];
%                                     right_count = right_count + 1;
%                                 else
                                    break;
%                                 end
                            else
                                GradProfile = [GradProfile, interpValue];
                                GradProfileX = [GradProfileX, intercepColRow(edgePoint_idx+i, 1)];
                                right_count = right_count + 1;
                                
                            end                           

                    end
            end
        elseif (Gdir(row, col) - 0) <= 0.0001 || (Gdir(row, col) - 180)<= 0.0001
            % horizon line
            drawDirection2(row, col, range, Gdir)
            %% find local max
            intercepColRow = findIntercept2(row, col, Gdir, Gmag);
            localRange = 1;
            values = [Gmag(row, col)];
            colValues = [col-localRange:col+localRange];
            %append left and right
            for i=1:1:localRange
                values = [Gmag(row, col-i), values];
                values = [values, Gmag(row, col+i)];
            end

            [maxValue, maxIndex] = max(values);
            % assign col, row to the local max point's locations, and
            % change Gdir(rowNew, colNew) to Gdir(row, col)
            Gdir(row, colValues(maxIndex)) = Gdir(row, col);
            col = colValues(maxIndex);
            plot(col, row, 'go');
            
            %%
            % no need to do interpolation
            GradProfile = Gmag(row, col);
            GradProfileX = col;
            % start from center, go left
            for i=1:col-1
                if left_count >= range
                    break;
                end
                interpValue = Gmag(row, col-i);
                if (interpValue >= 0.9*GradProfile(1) && (interpValue-GradProfile(1))>0.0001) || interpValue < 0.0001
%                     if interpValue >= GradProfile(1) && interpValue ~= 0
%                         GradProfile = [Gmag(row, col-i), GradProfile];
%                         GradProfileX = [col-i, GradProfileX];  
%                         left_count = left_count + 1;
%                     else
                        break;
%                     end
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
                if (interpValue >= 0.9*GradProfile(end) && (interpValue-GradProfile(end))>0.0001)  || interpValue < 0.0001
%                     if interpValue >= GradProfile(end)
%                         GradProfile = [GradProfile, interpValue];
%                         GradProfileX = [GradProfileX, col+i];
%                         right_count = right_count + 1;
%                     else
                        break;
%                     end
                else
                    GradProfile = [GradProfile, interpValue];
                    GradProfileX = [GradProfileX, col+i];
                    right_count = right_count + 1;
                end
            end            

        elseif (Gdir(row, col) - 90) == 0.0001
                drawDirection3(row, col, range, Gdir)
               % vertical line, no need to do interpolation
                GradProfile = Gmag(row, col);
                GradProfileX = row; 
               % from center go up
               for i=1:row-1
                if left_count >= range
                    break;
                end                   
                   interpValue = Gmag(row-i, col);
%                    if interpValue >= 0.9*GradProfile(1)  || interpValue < 0.0001
                    if (interpValue >= 0.9*GradProfile(1) && (interpValue-GradProfile(1))>0.0001) || interpValue < 0.0001
%                        if interpValue >= GradProfile(1) && interpValue ~= 0
%                            GradProfile = [Gmag(row-i, col), GradProfile];
%                            GradProfileX = [row-i, GradProfileX];
%                            left_count = left_count + 1;
%                        else
                           break
%                        end
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
%                        if interpValue >= 0.9*GradProfile(end) || interpValue < 0.0001
                        if (interpValue >= 0.9*GradProfile(end) && (interpValue-GradProfile(end))>0.0001) || interpValue < 0.0001
%                            if interpValue >= GradProfile(end)
%                                GradProfile = [GradProfile, interpValue];
%                                GradProfileX = [GradProfileX, row+i];
%                                right_count = right_count + 1;
%                            else
                               break;
%                            end
                       else
                           GradProfile = [GradProfile, interpValue];
                           GradProfileX = [GradProfileX, row+i];
                           right_count = right_count + 1;
                       end
                       
                   end
               end
        else
            drawDirection4(row, col, range, Gdir)
            tanValue = tan(Gdir(row, col) *pi/180);
            %% find the interceptions
            intercepColRow = findIntercept4(row, col, Gdir, Gmag)
            plot(intercepColRow(:,1),intercepColRow(:,2),'ro');
            plot(col, row, 'yo');
            %% find a local max value near edge point along the line, only search 1 neighbor
            edgePoint_idx = find(intercepColRow(:,1)==col);
            leftValue = Gmag(round(intercepColRow(edgePoint_idx-1,2)), round(intercepColRow(edgePoint_idx-1,1)));
            rightValue = Gmag(round(intercepColRow(edgePoint_idx+1,2)), round(intercepColRow(edgePoint_idx+1,1)));
            values = [leftValue, Gmag(row, col), rightValue];
            rowValues = [round(intercepColRow(edgePoint_idx-1,2)), row, round(intercepColRow(edgePoint_idx+1,2))];
            colValues = [round(intercepColRow(edgePoint_idx-1,1)), col, round(intercepColRow(edgePoint_idx+1,1))];
            [maxValue, maxIndex] = max(values);
            plot(col, row, 'go');
            plot(round(intercepColRow(edgePoint_idx-1,1)), round(intercepColRow(edgePoint_idx-1,2)), 'yo')
            plot(round(intercepColRow(edgePoint_idx+1,1)), round(intercepColRow(edgePoint_idx+1,2)), 'yo')
            plot(colValues(maxIndex), rowValues(maxIndex), 'bo')
            % assign col, row to the local max point's locations, and
            % change Gdir(rowNew, colNew) to Gdir(row, col)
            Gdir(rowValues(maxIndex), colValues(maxIndex)) = Gdir(row, col);
            col = colValues(maxIndex);
            row = rowValues(maxIndex);
            %% redraw line and recompute interceptions because the start point has changed
            drawDirection4(row, col, range, Gdir);
            intercepColRow = findIntercept4(row, col, Gdir, Gmag);
            plot(intercepColRow(:,1),intercepColRow(:,2),'mo');
            plot(col, row, 'co');              
            %% do interpolation and return gradient profile
            edgePoint_idx = find(intercepColRow(:,1)==col);
            % from center, first go left, then go right
            GradProfile = [Gmag(intercepColRow(edgePoint_idx, 2), intercepColRow(edgePoint_idx, 1))];
            GradProfileX = [intercepColRow(edgePoint_idx, 1)];
            for i = 1:1:col-1
                if left_count >= range
                    break;
                end                
                % go left
                % every point should have two nearest grid points, unless
                % they are grid point
                    if intercepColRow(edgePoint_idx-i, 2) == fix(intercepColRow(edgePoint_idx-i, 2)) ...
                    && intercepColRow(edgePoint_idx-i, 1) == fix(intercepColRow(edgePoint_idx-i, 1))
                        % grid point, no need to interpolation, append left
                        % compute delta first
%                         delta = abs(GradProfile(1) - ...
%                             Gmag(intercepColRow(edgePoint_idx-i, 2), intercepColRow(edgePoint_idx-i, 1)));
                        interpValue = Gmag(intercepColRow(edgePoint_idx-i, 2), intercepColRow(edgePoint_idx-i, 1));
%                         if interpValue >= 0.9*GradProfile(1) || interpValue < 0.0001
                        if (interpValue >= 0.9*GradProfile(1) && (interpValue-GradProfile(1))>0.0001) || interpValue < 0.0001
%                             if interpValue >= GradProfile(1) && interpValue ~= 0
%                                 GradProfile = ...
%                                 [interpValue, GradProfile];
%                                 GradProfileX = [intercepColRow(edgePoint_idx-i, 1), GradProfileX]; 
%                                 left_count = left_count + 1;
%                             else
                                break;
%                             end
                        else
                            GradProfile = ...
                                [interpValue, GradProfile];
                            GradProfileX = [intercepColRow(edgePoint_idx-i, 1), GradProfileX]; 
                            left_count = left_count + 1;
                        end

                    elseif intercepColRow(edgePoint_idx-i, 1) == fix(intercepColRow(edgePoint_idx-i, 1))
                            % need to do interpolation

                            % this point is on a vertical line
                            nearY1 = ceil(intercepColRow(edgePoint_idx-i, 2));
                            nearY2 = floor(intercepColRow(edgePoint_idx-i, 2));
                            interpValue = (intercepColRow(edgePoint_idx-i, 2) - nearY2) * ...
                              Gmag(nearY2, intercepColRow(edgePoint_idx-i, 1)) + ...
                              (nearY1 - intercepColRow(edgePoint_idx-i, 2)) * ...
                              Gmag(nearY1, intercepColRow(edgePoint_idx-i, 1));
%                           if interpValue >= 0.9*GradProfile(1) || interpValue < 0.0001
                            if (interpValue >= 0.9*GradProfile(1) && (interpValue-GradProfile(1))>0.0001) || interpValue < 0.0001
%                               if interpValue >= GradProfile(1) && interpValue ~= 0
%                                   GradProfile = [interpValue, GradProfile];
%                                   GradProfileX = [intercepColRow(edgePoint_idx-i, 1), GradProfileX];
%                                   left_count = left_count + 1;
%                               else
                                  break
%                               end
                          else
                              GradProfile = [interpValue, GradProfile];
                              GradProfileX = [intercepColRow(edgePoint_idx-i, 1), GradProfileX];
                              left_count = left_count + 1;
                          end

                    else %need to do interpolation, this point in on horizion line
                        nearX2 = floor(intercepColRow(edgePoint_idx-i, 1));
                        nearX1 = ceil(intercepColRow(edgePoint_idx-i, 1));
                        interpValue = (intercepColRow(edgePoint_idx-i, 1) - nearX2) * ...
                            Gmag(intercepColRow(edgePoint_idx-i, 2), nearX2) + ...
                            (nearX1 - intercepColRow(edgePoint_idx-i, 1)) * ...
                            Gmag(intercepColRow(edgePoint_idx-i, 2), nearX1);
%                         if interpValue >= 0.9*GradProfile(1) || interpValue < 0.0001
                        if (interpValue >= 0.9*GradProfile(1) && (interpValue-GradProfile(1))>0.0001) || interpValue < 0.0001
%                             if interpValue >= GradProfile(1) && interpValue ~= 0
%                                 GradProfile = [interpValue, GradProfile];
%                                 GradProfileX = [intercepColRow(edgePoint_idx-i, 1), GradProfileX];
%                                 left_count = left_count + 1;
%                             else
                                break;
%                             end
                        else
                            GradProfile = [interpValue, GradProfile];
                            GradProfileX = [intercepColRow(edgePoint_idx-i, 1), GradProfileX];
                            left_count = left_count + 1;
                        end
                    end
            end
            % store the center edge point's location in GradProfile
            GradProfileCenterLoc = length(GradProfile);
            delta = 1; % give delta to 1 for a new loop
            for i=1:length(intercepColRow)-edgePoint_idx-1
                if right_count >= range
                    break;
                end                
                % go right
                    if intercepColRow(edgePoint_idx+i, 2) == fix(intercepColRow(edgePoint_idx+i, 2)) ...
                    && intercepColRow(edgePoint_idx+i, 1) == fix(intercepColRow(edgePoint_idx+i, 1))
                        % grid point, no need to interpolation, append left
                        interpValue = Gmag(intercepColRow(edgePoint_idx+i, 2), intercepColRow(edgePoint_idx+i, 1));
%                         if interpValue >= 0.9*GradProfile(end) || interpValue < 0.0001
                        if (interpValue >= 0.9*GradProfile(end) && (interpValue-GradProfile(end))>0.0001) || interpValue < 0.0001
%                             if interpValue >= GradProfile(end)
%                                 
%                                 GradProfile = ...
%                                     [GradProfile, interpValue];
%                                 GradProfileX = [GradProfileX, intercepColRow(edgePoint_idx+i, 1)];
%                                 right_count = right_count + 1;
%                             else
                                break;
%                             end
                        else
                            GradProfile = ...
                                [GradProfile, interpValue];
                            GradProfileX = [GradProfileX, intercepColRow(edgePoint_idx+i, 1)];
                        end

                    elseif intercepColRow(edgePoint_idx+i, 1) == fix(intercepColRow(edgePoint_idx+i, 1))
                            % need to do interpolation

                            % this point is on a vertical line
                            nearY1 = ceil(intercepColRow(edgePoint_idx+i, 2));
                            nearY2 = floor(intercepColRow(edgePoint_idx+i, 2));
                            interpValue = (intercepColRow(edgePoint_idx+i, 2) - nearY2) * ...
                              Gmag(nearY2, intercepColRow(edgePoint_idx+i, 1)) + ...
                              (nearY1 - intercepColRow(edgePoint_idx+i, 2)) * ...
                              Gmag(nearY1, intercepColRow(edgePoint_idx+i, 1));
%                           if interpValue >= 0.9*GradProfile(end) || interpValue < 0.0001
                        if (interpValue >= 0.9*GradProfile(end) && (interpValue-GradProfile(end))>0.0001) || interpValue < 0.0001
%                               if interpValue >= GradProfile(end)
%                                   GradProfile = [GradProfile, interpValue];
%                                   GradProfileX = [GradProfileX, intercepColRow(edgePoint_idx+i, 1)];
%                                   right_count = right_count + 1;
%                               else
                                  break;
%                               end
                          else
                              GradProfile = [GradProfile, interpValue];
                              GradProfileX = [GradProfileX, intercepColRow(edgePoint_idx+i, 1)];
                              right_count = right_count + 1;
                          end

                    else %need to do interpolation, this point in on horizion line
                        nearX2 = floor(intercepColRow(edgePoint_idx+i, 1));
                        nearX1 = ceil(intercepColRow(edgePoint_idx+i, 1));
                        interpValue = (intercepColRow(edgePoint_idx+i, 1) - nearX2) * ...
                            Gmag(intercepColRow(edgePoint_idx+i, 2), nearX2) + ...
                            (nearX1 - intercepColRow(edgePoint_idx+i, 1)) * ...
                            Gmag(intercepColRow(edgePoint_idx+i, 2), nearX1);
%                         if interpValue >= 0.9*GradProfile(end) || interpValue < 0.0001
                        if (interpValue >= 0.9*GradProfile(end) && (interpValue-GradProfile(end))>0.0001) || interpValue < 0.0001
%                             if interpValue >= GradProfile(end)
%                                 GradProfile = [GradProfile, interpValue];
%                                 GradProfileX = [GradProfileX, intercepColRow(edgePoint_idx+i, 1)];
%                                 right_count = right_count + 1;
%                             else
                                break;
%                             end
                        else
                            GradProfile = [GradProfile, interpValue];
                            GradProfileX = [GradProfileX, intercepColRow(edgePoint_idx+i, 1)];
                            right_count = right_count + 1;
                        end

                    end
            end            
        end
end