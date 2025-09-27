% the support functions %%%%%%%%%%%%%%%%%%%%%%%%
function outpict = kcurves(inpict,k)
    % input breakpoints
    xx = linspace(0,1,numel(k)+1);
    
    % output breakpoints
    va = xx(2)*k(1);
    vb = (xx(3)-xx(2))*k(2) + va;
    vc = (xx(4)-xx(3))*k(3) + vb;
    yy = [0 va vb vc];
    
    outpict = interp1(xx,yy,inpict,'linear');
end

function outpict = stretchcurve(inpict,kc)
    if kc == 1
        outpict = inpict;
        return;
    end
    
    c = 0.5; % input pivot point
    mk = abs(kc) < 1;
    mc = c < 0.5;
    if ~xor(mk,mc)
        pp = kc; kk = kc*c/(1-c);
    else
        kk = kc; pp = (1-c)*kc/c;
    end
    
    hi = inpict > c; lo = ~hi;
    outpict = zeros(size(inpict));
    outpict(lo) = 0.5*((1/c)*inpict(lo)).^kk;
    outpict(hi) = 1-0.5*((1-inpict(hi))*(1/(1-c))).^pp;
end