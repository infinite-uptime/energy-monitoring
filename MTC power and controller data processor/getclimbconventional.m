            if Xnew > Xprev && Ynew > Yprev
               counter1(i) = 1;
              if Cy(e) - slope*Cx(e) + middle <0
               B = B+1;
             else
               T = T+1;
             end
           end
           
           if Xnew < Xprev && Ynew > Yprev
                              counter2(i) = 1;
             if Cy(e) - slope*Cx(e) + middle >0
               T = T+1;
             else
               B = B+1;
             end
           end
           
           if Xnew < Xprev && Ynew < Yprev
                              counter3(i) = 1;
             if Cy(e) - slope*Cx(e) + middle >0
               T = T+1;
             else
               B = B+1;
             end
           end
           
           if Xnew > Xprev && Ynew < Yprev
                              counter4(i) = 1;
             if Cy(e) - slope*Cx(e) + middle >0
               B = B+1;
             else
               T = T+1;
             end
           end
           
           if Xnew == Xprev
                              counter5(i) = 1;
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
               counter6(i) = 1;
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
   