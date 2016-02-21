%%% getcircle for IJK inputs

%% Find Center, Radius
for code = 2:8
      text = EData{i,code};
      l = size(text,2);
  if isempty(strfind(text,'J')) == 0
      Cy = str2num(text(2:l));
  elseif isempty(strfind(text,'I')) == 0
      Cx = str2num(text(2:l));
  end
end
           
C = [Xprev+Cx Yprev+Cy];
R  = sqrt((Xprev-C(1))^2 + (Yprev-C(2))^2);
X=C(1); Y=C(2);

%% Get theta somehow, then use to find length of cut in XY

    tnew = atan((Ynew-C(2))/(Xnew-C(1)));
    tprev = atan((Yprev-C(2))/(Xprev-C(1)));

if Xnew == Xprev && Ynew == Yprev
    LoC(i) = 2*pi*R;
else
    %Must eventually take G03, G02 into account
a = sqrt((Xnew-X)^2+(Ynew-Y)^2);
b = sqrt((Xnew-Xprev)^2+(Ynew-Yprev)^2);
c = sqrt((X-Xprev)^2+(Y-Yprev)^2);
theta = acos((a^2+c^2-b^2)/(2*a*c));
LoC(i) = R*theta;
end

%% Which elements were cut?
for e = 1:N
  if Xnew ~= Xprev || Ynew ~= Yprev
    if (Cx(e)-X)^2 + (Cy(e)-Y)^2 - (R+r)^2 <= 0    
        if (Cx(e)-X)^2 + (Cy(e)-Y)^2 - (R-r)^2 >= 0
            t1 = atan((Cy(e)-Y)/(Cx(e)-X)) - tprev;
            t2 = tnew - atan((Cy(e)-Y)/(Cx(e)-X));
           if t1>0 && t2 < 0
               in(e) = in(e)+1;
           end
        end
    end
  else
      if (Cx(e)-X)^2 + (Cy(e)-Y)^2 - (R+r)^2 <= 0    
        if (Cx(e)-X)^2 + (Cy(e)-Y)^2 - (R-r)^2 >= 0
            in(e) = in(e)+1;
        end
      end
  end
    
    if in(e) > 0
        if currentZ(e)>Zvalue
            if sum(strcmp(EData(i,:),'G02')) == 1 || sum(strcmp(EData(i,:),'G2')) == 1
                if (Cx(e)-X)^2 + (Cy(e)-Y)^2 - (R)^2 > 0
                    T = T+1;
                elseif (Cx(e)-X)^2 + (Cy(e)-Y)^2 - (R)^2 < 0
                    B = B+1;
                end
            elseif sum(strcmp(EData(i,:),'G03')) == 1 || sum(strcmp(EData(i,:),'G3')) == 1
                if (Cx(e)-X)^2 + (Cy(e)-Y)^2 - (R)^2 > 0
                    B = B+1;
                elseif (Cx(e)-X)^2 + (Cy(e)-Y)^2 - (R)^2 < 0
                    T = T+1;
                end
            end
            cut2(count2+1) = e; %If elements were cut to a new depth
            count2 = count2+1; %Counter for flag for area of cut
            
        end
        D(e)=abs(Zvalue-currentZ(e));
        currentZ(e)=Zvalue;
    end
    
end

if count2 >0
    flag =1; %If elements were cut in this block, then flag = 1 -> calculate IAoC, IdX, IdY
end

   
    
