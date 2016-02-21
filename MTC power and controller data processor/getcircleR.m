%getcircle for R inputs
C = zeros(2,5); 
%given 2 points and radius (R), find two possible centers of the circular
d =sqrt((Xnew-Xprev)^2+(Ynew-Yprev)^2); Mx = .5*(Xnew+Xprev); My = .5*(Ynew+Yprev); %distance, midpt between Prev,New

%store in (x,y; x,y;) format
%Reference: http://mathforum.org/library/drmath/view/53027.html
C(1,1) = Mx + sqrt(R^2-(d/2)^2)*(Yprev-Ynew)/d;
C(1,2) = My + sqrt(R^2-(d/2)^2)*(Xnew-Xprev)/d;
C(2,1) = Mx - sqrt(R^2-(d/2)^2)*(Yprev-Ynew)/d;
C(2,2) = My - sqrt(R^2-(d/2)^2)*(Xnew-Xprev)/d;
%Removed if center is real then continue statment, shouldn't be necessary
for j = 1:2
    C(j,4) = atan((Ynew-C(j,2))/(Xnew-C(j,1))); %tnew
    C(j,5) = atan((Yprev-C(j,2))/(Xprev-C(j,1))); %tprev
    C(j,3) = C(j,4) - C(j,5);  %tnew - tprev
end
if abs(C(1,3) - C(2,3)) < 1E-14 %special case for 90 degree arcs
    C(1,4) = atan((((Yprev+2*Ynew)/3)-C(1,2))/(((Xprev+2*Xnew)/3)-C(1,1))); 
    C(1,5) = atan((((2*Yprev+Ynew)/3)-C(1,2))/(((2*Xprev+Xnew)/3)-C(1,1)));
    C(2,4) = atan((((Yprev+2*Ynew)/3)-C(2,2))/(((Xprev+2*Xnew)/3)-C(2,1)));
    C(2,5) = atan((((2*Yprev+Ynew)/3)-C(2,2))/(((2*Xprev+Xnew)/3)-C(2,1)));
    C(1,3) = C(1,4) - C(1,5); C(2,3) = C(2,4) - C(2,5);
end
    

C = sortrows(C,3); %Sort possible center points based on angle (Prev,C,New) (ascending)
% If angle is negative that indicates a G02 cut -> C = C(1,:)
    if sum(strcmp(EData(i,:),'G02')) == 1 || sum(strcmp(EData(i,:),'G2')) == 1; %Clockwise circle
    X = C(1,1); Y = C(1,2); tnew = C(1,4); tprev = C(1,5);
    elseif sum(strcmp(EData(i,:),'G03')) == 1 || sum(strcmp(EData(i,:),'G3')) == 1;%Counterclockwise circle
    X = C(2,1); Y = C(2,2); tnew = C(2,4); tprev = C(2,5);
    end

%side lengths for law of cosines, for theta = angle of opening, for LoC
a = sqrt((Xnew-X)^2+(Ynew-Y)^2);
b = sqrt((Xnew-Xprev)^2+(Ynew-Yprev)^2);
c = sqrt((X-Xprev)^2+(Y-Yprev)^2);
theta = acos((a^2+c^2-b^2)/(2*a*c));
LoC(i) = R*theta;

%cut
for e = 1:N
    if (Cx(e)-X)^2 + (Cy(e)-Y)^2 - (R+r)^2 <= 0    
        if (Cx(e)-X)^2 + (Cy(e)-Y)^2 - (R-r)^2 >= 0
            t1 = atan((Cy(e)-Y)/(Cx(e)-X))-tprev;
            t2 = atan((Cy(e)-Y)/(Cx(e)-X))-tnew;
            
a = sqrt((Cx(e)-X)^2+(Cy(e)-Y)^2);
c = sqrt((X-Xprev)^2+(Y-Yprev)^2);
b = sqrt((Cx(e)-Xprev)^2+(Cy(e)-Yprev)^2);
cosprev = acos((a^2+c^2-b^2)/(2*a*c));

a = sqrt((Cx(e)-X)^2+(Cy(e)-Y)^2);
c = sqrt((X-Xnew)^2+(Y-Ynew)^2);
b = sqrt((Cx(e)-Xnew)^2+(Cy(e)-Ynew)^2);
cosnew = acos((a^2+c^2-b^2)/(2*a*c));


           if  cosprev<=theta && cosnew<=theta %t1<0 && t2>0
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
  
