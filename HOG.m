function [featureVec] = HOG( img_input,height,width,Picture_Cut_Size,step,orient)
% Hog ������ȡͼ������ֵ
% ��hog��������Ҫ�������£� 
% 1���ҶȻ��� 
% 2��gammaУ���� 
% 3����ÿ�����ص��ݶȺͷ��� 
% 4������cell��8*8pixel/cell�������ݷ�ֵ�ͷ�����ȡÿ��cell���ݶ�ֱ��ͼ�� 
% 5�����block��2*2cell/block��������4��cell���ݶ�ֱ��ͼ����һ����Ϊ��block������������ 
% 6�������е�block���������������������Ϊ��ͼ���hog����������

% 1��%�ҶȻ�
img=rgb2gray(img_input);
% �¼������
[m,n] = size(img); % �õ�ͼƬ��С
m1 = round(m/2);n1=round(n/2);  % ��ͼ�����ĵ�
img_midle = img(m1-(Picture_Cut_Size/2-1):m1+(Picture_Cut_Size/2),n1-(Picture_Cut_Size/2-1):n1+(Picture_Cut_Size/2));%��ȡ�м�ͼ��
img_resize = imresize(img_midle,[height,width]);%������С
% �¼���������
img=double(img_resize);

if(step==0)
    step=8;      %step*step��������Ϊһ��cell
end
[m1 n1]=size(img);
%�ı�ͼ��ߴ�Ϊstep�����������
img=imresize(img,[floor(m1/step)*step,floor(n1/step)*step],'nearest');

[m n]=size(img);

% 2��%٤��У��
img=sqrt(img);

% 3�����ݶȺͷ���
fy=[-1 0 1];        %������ֱģ��
fx=fy';             %����ˮƽģ��
Iy=imfilter(img,fy,'replicate');    %��ֱ�ݶ�
Ix=imfilter(img,fx,'replicate');    %ˮƽ�ݶ�
Ied=sqrt(Ix.^2+Iy.^2);              %�ݶ�ֵ
Iphase=Iy./Ix;              %��Եб�ʣ���ЩΪinf,-inf,nan������nan��Ҫ�ٴ���һ��
the=atan(Iphase)*180/3.14159; %���ݶȽǶ�

for i=1:m
    for j=1:n
        if(Ix(i,j)>=0&Iy(i,j)>=0) %��һ����
            the(i,j)=the(i,j);
        elseif(Ix(i,j)<=0&Iy(i,j)>=0) %�ڶ�����
            the(i,j)=the(i,j)+180;
        elseif(Ix(i,j)<=0&Iy(i,j)<=0) %��������
            the(i,j)=the(i,j)+180;
        elseif(Ix(i,j)>=0&Iy(i,j)<=0) %��������
            the(i,j)=the(i,j)+360;
        end

        if isnan(the(i,j))==1  %0/0��õ�nan�����������nan������Ϊ0
            the(i,j)=0;
        end

    end
end
the=the+0.000001; %��ֹ�Ƕ�Ϊ0

% 4������cell����cell��ֱ��ͼ( 1 cell = 8*8 pixel )
clear i j;
%��������cell
%step=8;                %step*step��������Ϊһ��cell
%orient=9;               %����ֱ��ͼ�ķ������
jiao=360/orient;        %ÿ����������ĽǶ���
Cell=cell(1,1);              %���еĽǶ�ֱ��ͼ,cell�ǿ��Զ�̬���ӵģ�����������һ��
ii=1;
jj=1;

for i=1:step:m
    ii=1;
    for j=1:step:n
        Hist1(1:orient)=0;
        for p=1:step
            for q=1:step
                %�ݶȷ���ֱ��ͼ
                Hist1(ceil(the(i+p-1,j+q-1)/jiao))=Hist1(ceil(the(i+p-1,j+q-1)/jiao))+Ied(i+p-1,j+q-1);
            end
        end
        Cell{ii,jj}=Hist1;       %����Cell��
        ii=ii+1;
    end
    jj=jj+1;
end

% 5������block����block������ֵ,ʹ���ص���ʽ( 1 block = 2*2 cell )
clear m n i j;
[m n]=size(Cell);
feature=cell(1,(m-1)*(n-1));
for i=1:m-1
    for j=1:n-1
        block=[];
        block=[Cell{i,j}(:)' Cell{i,j+1}(:)' Cell{i+1,j}(:)' Cell{i+1,j+1}(:)'];
        block=block./sum(block); %��һ��
        feature{(i-1)*(n-1)+j}=block;
    end
end

% 6��ͼ���HOG����ֵ
[m n]=size(feature);
l=2*2*orient;
featureVec=zeros(1,n*l);
for i=1:n
    featureVec((i-1)*l+1:i*l)=feature{i}(:);
end

end
