%getcorners plots the tool path for 4 possible direction taking into
%account the radius of the tool. It also finds a 'middle' toolpath to
%establish a criteria for climb vs conventional cutting.

if Xnew >= Xprev && Ynew >= Yprev
     theta=atan((Ynew-Yprev)/(Xnew-Xprev));
        slope=(Ynew-Yprev)/(Xnew-Xprev);
        pslope = -slope^-1;

        quadrant(i)=1;
        X1 = Xprev + r*sin(theta);
        Y1 = Yprev - r*cos(theta);
        
        X2 = Xprev - r*sin(theta);
        Y2 = Yprev + r*cos(theta);
        
        X3 = Xnew + r*sin(theta);
        Y3 = Ynew - r*cos(theta);
        
        X4 = Xnew - r*sin(theta);
        Y4 = Ynew + r*cos(theta);
        
        const13= -slope*X1+Y1;
        const24= -slope*X2+Y2;
        const12 = -pslope*X1+Y1;
        const34 = -pslope*X3+Y3;
        middle = -slope*Xprev + Yprev;
end

if Xnew < Xprev && Ynew >= Yprev
     theta=atan((Ynew-Yprev)/-(Xnew-Xprev));
        slope=(Ynew-Yprev)/(Xnew-Xprev);
        pslope = -slope^-1;
        
        quadrant(i)=2;
        X1 = Xprev - r*sin(theta);
        Y1 = Yprev - r*cos(theta);
        
        X2 = Xprev + r*sin(theta);
        Y2 = Yprev + r*cos(theta);
        
        X3 = Xnew - r*sin(theta);
        Y3 = Ynew - r*cos(theta);
        
        X4 = Xnew + r*sin(theta);
        Y4 = Ynew + r*cos(theta);
        
        const13= -slope*X1+Y1;
        const24= -slope*X2+Y2;
        const12 = -pslope*X1+Y1;
        const34 = -pslope*X3+Y3;
        middle = -slope*Xprev + Yprev;
end

if Xnew < Xprev && Ynew < Yprev
     theta=atan((Ynew-Yprev)/(Xnew-Xprev));
        slope=(Ynew-Yprev)/(Xnew-Xprev);
        pslope = -slope^-1;
        
        quadrant(i)=3;
        X3 = Xprev + r*sin(theta);
        Y3 = Yprev - r*cos(theta);
        
        X4 = Xprev - r*sin(theta);
        Y4 = Yprev + r*cos(theta);
        
        X1 = Xnew + r*sin(theta);
        Y1 = Ynew - r*cos(theta);
        
        X2 = Xnew - r*sin(theta);
        Y2 = Ynew + r*cos(theta);
        
        const13= -slope*X1+Y1;
        const24= -slope*X2+Y2;
        const12 = -pslope*X1+Y1;
        const34 = -pslope*X3+Y3;
        middle = -slope*Xprev + Yprev;
end

if Xnew >= Xprev && Ynew < Yprev
     theta=atan(-(Ynew-Yprev)/(Xnew-Xprev));
        slope=(Ynew-Yprev)/(Xnew-Xprev);
 
        pslope = -slope^-1;
        
        quadrant(i)=4;
        X4 = Xprev + r*sin(theta);
        Y4 = Yprev + r*cos(theta);
        
        X3 = Xprev - r*sin(theta);
        Y3 = Yprev - r*cos(theta);
        
        X2 = Xnew + r*sin(theta);
        Y2 = Ynew + r*cos(theta);
        
        X1 = Xnew - r*sin(theta);
        Y1 = Ynew - r*cos(theta);
        
        const13= -slope*X1+Y1;
        const24= -slope*X2+Y2;
        const12 = -pslope*X1+Y1;
        const34 = -pslope*X3+Y3;
        middle = -slope*Xprev + Yprev;
end