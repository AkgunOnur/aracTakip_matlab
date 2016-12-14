% 
% Araç Takip Projesi
% Matlab Uygulama Kodlarý
% 
% Yazan: Onur AKGÜN
%

clear all;
clc;

%Filtrelemer sonunda 250 pikselden buyuk cisimleri isaretleyecek kutu
%olusturuldu.
hedef_tespit = vision.BlobAnalysis('AreaOutputPort', false, 'CentroidOutputPort', false,'MinimumBlobArea', 250);

%Kucuk gurultuleri yok etmek icin medyan filtresi tanimlandi.
medyan_filtre = vision.MedianFilter([2 2]);

%Gurultuleri yok etmek icin morfolojik acma islemi tanimlandi
morfolojik_acma = strel('square', 1);

%Cismi olusturan noktalar arasindaki bos yerleri doldurmak icin morfolojik
%kapama islemi tanimlandi
morfolojik_kapama = strel('disk', 5);

%Morfolojik kapama sonrasi olusacak gurultuleri yok etmek icin yeni bir
%morfolojik acma islemi tanimlandi
morfolojik_acma2 = strel('square', 2);

%Ilk resim okundu
onceki_resim = rgb2gray(imread('in000001.jpg'));
onceki_resim = onceki_resim(30:240,1:310);

for k=600:1700
   %Resmin numarasina gore okunmasi saglandi
   if(k>=1000)
      dosyaIsmi = strcat('in00', num2str(k), '.jpg');
      elseif(k>=100)
      dosyaIsmi = strcat('in000', num2str(k), '.jpg');
      elseif(k>=10)
      dosyaIsmi = strcat('in0000', num2str(k), '.jpg');
   else
      dosyaIsmi = strcat('in00000', num2str(k), '.jpg');
   end
   
   %Resim siyah-beyaza donusturuldu
   resim = rgb2gray(imread(dosyaIsmi));
   
   %Calisma bolgesi secildi -ROI-
   resim = resim(30:240,1:310);
   
   %Iki resmin farki alinarak hareket eden cisimler tespit edildi
   onplan = resim - onceki_resim;
   
   %Esikleme yapilarak hareketli nesneler beyaz,arka plan siyah yapildi
   onplan_nesneler = im2bw(onplan,0.085);
   
   %Medyan filtresi ile kucuk gurultuler yok edildi
   onplan_nesneler = step(medyan_filtre,onplan_nesneler);
   
   %Morfolojik acma ile gurultulerden arindirildi
   filtreli_onplan = imopen(onplan_nesneler, morfolojik_acma);
   
   %Resimdeki nesneleri olusturan baglanti noktalari pekistirildi
   filtreli_onplan1 = imclose(filtreli_onplan, morfolojik_kapama);
   
   %Pekistirme islemi sonrasi artan gurultuler yok edildi
   filtreli_onplan2 = imopen(filtreli_onplan1, morfolojik_acma2);
   
   %Tanimlanan kutu goruntunun son haline eklendi
   kutu = step(hedef_tespit, filtreli_onplan2);
   
   %Dikdortgen resmin ilk halinde gosterildi
   sonuc = insertShape(resim, 'Rectangle', kutu, 'Color', 'red');
   
   %Resmin son hali gosterildi
   imshow(sonuc);
   
   %Fark islemi icin mevcut resim onceki_resim degiskenine atandi
   onceki_resim = resim;

end