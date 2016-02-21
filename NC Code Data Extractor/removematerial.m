%% Is there a cut? What is the depth? Which material was removed?
% simulatecut plots toolpaths for each block over the workpiece grid and
% updates the Z values for parts of the grid with each cut 

%% Which elements in the grid were cut by tool? Cases for each direction:
% Note that 'in' counts each element within rectangular toolpath, in1
% counts each element from a semicircle extending from each end of the
% rectangular toopath, and in2 subtracts the elements counted within a
% semicircle within the rectangle from the start of the toolpath
for e = 1:N
          if slope ~= 0 && pslope ~=0
            if LBy(e)-slope*LBx(e)-const13 >= 0
                if LBy(e)-slope*LBx(e)-const24 <=0
                    if LBy(e) -pslope*LBx(e)-const12 >=0
                        if LBy(e) -pslope*LBx(e)-const34 <=0
                            in(e) = in(e)+ 1;
                        end
                    end
                end
            end
            if LTy(e)-slope*LTx(e)-const13 >= 0
                if LTy(e)-slope*LTx(e)-const24 <=0
                    if LTy(e) -pslope*LTx(e)-const12 >=0
                        if LTy(e) -pslope*LTx(e)-const34 <=0
                            in(e) = in(e)+ 1;
                        end
                    end
                end
            end
            if RBy(e)-slope*RBx(e)-const13 >= 0
                if RBy(e)-slope*RBx(e)-const24 <=0
                    if RBy(e) -pslope*RBx(e)-const12 >=0
                        if RBy(e) -pslope*RBx(e)-const34 <=0
                            in(e) = in(e)+ 1;
                        end
                    end
                end
            end
            if RTy(e)-slope*RTx(e)-const13 >= 0
                if RTy(e)-slope*RTx(e)-const24 <=0
                    if RTy(e) -pslope*RTx(e)-const12 >=0
                        if RTy(e) -pslope*RTx(e)-const34 <=0
                            in(e) = in(e)+ 1;
                        end
                    end
                end
            end
            
          elseif abs(slope)==Inf
           if LBy(e)>=min(Y1,Y3)
                if LBy(e)<=max(Y1,Y3)
                    if LBx(e)<= max(X1,X2)
                        if LBx(e)>= min(X1,X2)
                            in(e) = in(e)+ 1;
                        end
                    end
                end
            end
              if LTy(e)>=min(Y1,Y3)
                if LTy(e)<=max(Y1,Y3)
                    if LTx(e)<= max(X1,X2)
                        if LTx(e)>= min(X1,X2)
                            in(e) = in(e)+ 1;
                        end
                    end
                end
              end
              if RBy(e)>=min(Y1,Y3)
                if RBy(e)<=max(Y1,Y3)
                    if RBx(e)<= max(X1,X2)
                        if RBx(e)>= min(X1,X2)
                            in(e) = in(e)+ 1;
                        end
                    end
                end
              end
              if RTy(e)>=min(Y1,Y3)
                if RTy(e)<=max(Y1,Y3)
                    if RTx(e)<= max(X1,X2)
                        if RTx(e)>= min(X1,X2)
                            in(e) = in(e)+ 1;
                        end
                    end
                end
              end
            
          elseif abs(pslope) ==Inf
              if LBy(e)>=min(Y1,Y2)
                if LBy(e)<=max(Y1,Y2)
                    if LBx(e)<= max(X1,X3)
                        if LBx(e)>= min(X1,X3)
                            in(e) = in(e)+ 1;
                        end
                    end
                end
              end
              if LTy(e)>=min(Y1,Y2)
                if LTy(e)<=max(Y1,Y2)
                    if LTx(e)<= max(X1,X3)
                        if LTx(e)>= min(X1,X3)
                            in(e) = in(e)+ 1;
                        end
                    end
                end
              end
              if RBy(e)>=min(Y1,Y2)
                if RBy(e)<=max(Y1,Y2)
                    if RBx(e)<= max(X1,X3)
                        if RBx(e)>= min(X1,X3)
                            in(e) = in(e)+ 1;
                        end
                    end
                end
              end
              if RTy(e)>=min(Y1,Y2)
                if RTy(e)<=max(Y1,Y2)
                    if RTx(e)<= max(X1,X3)
                        if RTx(e)>= min(X1,X3)
                            in(e) = in(e)+ 1;
                        end
                    end
                end
              end
          end
          
           if (RTy(e)-Ynew)^2+(RTx(e)-Xnew)^2-r^2<0
               in1(e) = in1(e)+ 1;
                if (RBy(e)-Ynew)^2+(RBx(e)-Xnew)^2-r^2<0
                    in1(e) = in1(e)+ 1;
                    if (LTy(e)-Ynew)^2+(LTx(e)-Xnew)^2-r^2<0
                        in1(e) = in1(e)+ 1;
                        if (LBy(e)-Ynew)^2+(LBx(e)-Xnew)^2-r^2<0
                            in1(e) = in1(e)+ 1;
                        end
                    end
                end
           end
           
           if (RTy(e)-Yprev)^2+(RTx(e)-Xprev)^2-r^2<0
               in2(e) = in2(e)+ 1;
                if (RBy(e)-Yprev)^2+(RBx(e)-Xprev)^2-r^2<0
                    in2(e) = in2(e)+ 1;
                    if (LTy(e)-Yprev)^2+(LTx(e)-Xprev)^2-r^2<0
                        in2(e) = in2(e)+ 1;
                        if (LBy(e)-Yprev)^2+(LBx(e)-Xprev)^2-r^2<0
                            in2(e) = in2(e)+ 1;
                        end
                    end
                end
           end

%% If a cut occured (criteria in first two if statements: 
% Depth (D); Climb(T) / Conventional(B) / Both  (see .ppt slides for more info)
% For cutting strategy assuming clockwise spindle rotation (M03)
% T and B must be swapped for M04 
% Must consider multiple cases for tool path directions.

       if in(e) > 1 || in1(e) > 1 && in2(e) < 1
          if currentZ(e)>Zvalue
            if Xnew > Xprev && Ynew > Yprev
              if Cy(e) - slope*Cx(e) + middle <0
               B = B+1;
              else
               T = T+1;
              end
              
            end
           
           if Xnew < Xprev && Ynew > Yprev
             if Cy(e) - slope*Cx(e) + middle >0
               T = T+1;
             else
               B = B+1;
             end
           end
           
           if Xnew < Xprev && Ynew < Yprev
             if Cy(e) - slope*Cx(e) + middle >0
               T = T+1;
             else
               B = B+1;
             end
           end
           
           if Xnew > Xprev && Ynew < Yprev
             if Cy(e) - slope*Cx(e) + middle >0
               B = B+1;
             else
               T = T+1;
             end
           end
           
           if Xnew == Xprev
               if Ynew>Yprev
             if Cx(e)> Xprev
               T = T+1;
             else
               B = B+1;
             end
               end
               if Yprev>Ynew
             if Cx(e)> Xprev
               B = B+1;
             else
               T = T+1;
             end
               end
           end
           
           if Ynew == Yprev
               if Xnew > Xprev
                if Cy(e) > Yprev
                   B = B+1;
                 else
                   T = T+1;
                 end
               end
               if Xprev > Xnew
                if Cy(e) > Yprev
                   T = T+1;
                else
                   B = B+1;
                 end
               end
           end
   cut2(count2+1) = e; %If elements were cut to a new depth        
   count2 = count2+1; %Counter for flag for area of cut
          end
          
                D(e)=abs(Zvalue-currentZ(e)); %Depth = final - initial
                currentZ(e)=Zvalue; %Update current value of elements due to depth of cut
                cut(count) = e; %Which elements were cut to a new depth?
                count = count+1; %Counter for above
       end
       
end

if count2 >0
    flag =1; %If elements were cut in this block, then flag = 1 -> calculate IAoC, IdX, IdY
end

  
      