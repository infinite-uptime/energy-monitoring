for e = 1:N
    if (Cx(e)-Xnew)^2 + (Cy(e)-Ynew)^2 - r^2 <= 0
        if currentZ(e) > Zvalue
            D(e)=abs(currentZ(e)-Zvalue);
            currentZ(e)=Zvalue;
        end
    end
end

if isnan(mode(D(find(D>0))')) == 1
        Depth(i) = 0;
else
        Depth(i)= mode(D(find(D>0))');
end

IdX(i) = 0; %IdX
IdY(i) = 0; %IdY
IAoC(i) = pi*r^2; %Area
LoC(i)=Depth(i);
TLoC(i) = Depth(i);%Total Length of cut

%These variables are written into EData separately outside the loop!!!