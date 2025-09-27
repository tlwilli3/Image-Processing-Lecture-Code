%% Color Map

I = imread("blood_epidural.jpg");
pseudocolortypes = {'hot','sine','jet','warm'};
values = length(pseudocolortypes)+1;
titles = cell(1,values);
for i=1:values
    if i==1
        Im = I;
        titles{i} = 'Original';
    else
        Im = classcolormap(I,pseudocolortypes{i-1});
        titles{i} = strcat(pseudocolortypes(i-1));
    end
    subplot(1,values,i)
    imshow(Im)
    title(titles{i})
end

% colormaps

function map = classcolormap(I,type)

I = im2double(I);
[rows,cols,~] = size(I);
[R,G,B] = imsplit(I);
sqmat = [1+sqrt(3),1-sqrt(3),2;
    1-sqrt(3),1+sqrt(3),2;
    -2,-2,2];
fq = 2;
omega = 2*pi*fq;
phi = 0;

switch type
    case 'hot'
        for k=1:3
            for i=1:rows
                for j=1:cols
                    switch k
                        case 1
                            if R(i,j) < 0.37
                                R(i,j) = 2.7027*R(i,j);
                            else
                                R(i,j) = 1;
                            end
                        case 2
                            if G(i,j) < 0.37
                                G(i,j) = 0;
                            elseif G(i,j) >= 0.37 && G(i,j) <= 0.74
                                G(i,j) = 2.7027*G(i,j) - 1;
                            else
                                G(i,j) = 1;
                            end
                        case 3
                            if B(i,j) < 0.74
                                B(i,j) = 0;
                            else
                                B(i,j) = 3.8461*B(i,j) - 2.8461;
                            end
                    end
                end
            end
        end
    case 'sine'
        for k=1:3
            for i=1:rows
                for j=1:cols
                    switch k
                        case 1
                            R(i,j) = -0.5*cos(pi*R(i,j)) + 0.5;
                        case 2
                            G(i,j) = sin(pi*G(i,j));
                        case 3
                            B(i,j) = 0.5*cos(pi*B(i,j)) + 0.5;
                    end
                end
            end
        end        
    case 'jet'
        for k=1:3
            for i=1:rows
                for j=1:cols
                    switch k
                        case 1
                            R(i,j) = eff(1.5 - abs(2*R(i,j) - 1));
                        case 2
                            G(i,j) = eff(1.5 - abs(2*G(i,j)));
                        case 3
                            B(i,j) = eff(1.5 - abs(2*B(i,j) + 1));
                    end
                end
            end
        end               
    case 'warm'
        for k=1:3
            for i=1:rows
                for j=1:cols
                    arrmat = [arr(R(i,j))*sin(omega*R(i,j)+phi);
                                arr(G(i,j))*cos(omega*G(i,j)+phi);
                                sqrt(3)*B(i,j)];
                    tmp = (1/(2*sqrt(3)))*(sqmat*arrmat);
                    R(i,j) = tmp(1); G(i,j) = tmp(2); B(i,j) = tmp(3);
                end
            end
        end        
end

map = cat(3,R,G,B);

end

function eff = eff(x)

if x < 0
    eff = 0;
elseif x >= 0 && x <= 1
    eff = x;
else
    eff = 1;
end

end

function arr = arr(x)

if x >= 0 && x < 0.5
    arr = sqrt(3/2)*x;
else
    arr = sqrt(3/2)*(1-x);
end

end
