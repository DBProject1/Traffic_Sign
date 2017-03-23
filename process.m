function [ result ] = process(Img,W)
    ISIZE = 56;
    R_HUE_MAX =14;
    R_HUE_MIN =230;
    R_SAT_MIN =43; %43
    R_SAT_MAX =255;
    B_HUE_MAX =230;
    B_HUE_MIN =214;
    B_SAT_MIN =45;
    a = double(Img);
    r=a(:,:,1);
    g=a(:,:,2);
    b=a(:,:,3);
    hslImage = rgb2hsy(r,g,b);
    hue = hslImage(:,:,1);
    sat = hslImage(:,:,2);
    lum = hslImage(:,:,3);
    [m n] = size(hue);
    h = zeros(m,n);
    for it = 1:m
        for jt = 1:n
            if hue(it,jt)>R_HUE_MIN && sat(it,jt)> R_SAT_MIN && sat(it,jt)< R_SAT_MAX
                h(it,jt) = 1;
            elseif hue(it,jt)<R_HUE_MAX && sat(it,jt) > R_SAT_MIN && sat(it,jt) < R_SAT_MAX
                h(it,jt) = 1;
            elseif hue(it,jt)<B_HUE_MAX && hue(it,jt) >B_HUE_MIN && sat(it,jt) > B_SAT_MIN
                h(it,jt) = 1;
            else
                h(it,jt) = 0;
            end
        end
    end
    thresholded_image = cat(1, h);
    binary_image = im2bw(thresholded_image,0.5);
    SE = strel('disk',1, 4);
    SE2 = strel('disk',1,4);
    binary_image = medfilt2(binary_image);
    binary_image = imdilate(binary_image,SE);
    binary_image = imerode(binary_image,SE2);
    binary_image = imfill(binary_image,'holes');
    segR = Img(:,:,1);
    segG = Img(:,:,2);
    segB = Img(:,:,3);
    cc = bwconncomp(gather(binary_image));
    if cc.NumObjects() not 0
        
        stats = regionprops(cc,'Area','BoundingBox');
        bbox = vertcat(stats.BoundingBox);
        AR = bbox(:,3)./bbox(:,4);
        area = vertcat(stats.Area);
        idx = find(area > m*n/1180 & AR < 1.3 & AR > 0.5 & area < m*n/50); 
        BW = ismember(labelmatrix(cc),idx);
        binary_filtered_image = bwconvhull(BW,'object');
        
        thickness = ceil(m*n*0.0000006);
        se = strel('disk',thickness,4);
        boundaries1 = bwperim(binary_filtered_image);
        boundaries1 = imdilate(boundaries1,se);
        connectedComp = bwconncomp(binary_filtered_image);
        istat = regionprops(connectedComp,'BoundingBox');
        
        segR(boundaries1) = 0;
        segG(boundaries1) = 255;
        segB(boundaries1) = 0;
        out = cat(3, segR, segG, segB);
        for i = 1:connectedComp.NumObjects()
            %ipa = imcrop(xx,labelmatrix(connectedComp)==i);
            %imshow(ipa);
            %mask = uint8(labelmatrix(connectedComp) == i);
            %finalimg = xx.*(repmat(mask,[1,1,3]));
            finalimg = imcrop(Img,istat(i).BoundingBox);
            finalimg = imresize(finalimg,[48 48]);
            %imwrite(finalimg,strcat('f.jpg'));%,num2str(k+i),'.jpg'));
            W.put('src',finalimg);
            W.execute('execfile(''classify.py'')');
            class = W.get('a');
            if class < 26
                folder = char(class + 65)
                tmp = imread(strcat('Templates/',folder,'/f.ppm'));
            else
                folder = char(class+39)
                tmp = imread(strcat('Templates/Z',folder,'/f.ppm'));
            end
            tmp = imresize(tmp,[ISIZE ISIZE]);
            posY = 1+(i-1)*ISIZE;
            out(posY:posY+ISIZE-1,1:ISIZE,:) = tmp;
        end
        result = out;
    else   
        result = Img;
    end
end