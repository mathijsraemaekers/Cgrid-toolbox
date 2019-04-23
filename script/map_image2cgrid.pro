pro map_image2cgrid,cgridfile,imgfile,opfile
syntx=n_params()
if syntx lt 3 then begin
print,'Script for mapping an image to a Cgrid:'
print,'1: The name of the cgridfile'
print,'2: The name of the image' 
print,'3: The name of the outputfile' 
return
end
cgrid=(read_ascii(cgridfile)).(0)
nrcoor=n_elements(cgrid(0,*))
opdat=fltarr(2,nrcoor)
opdat(0,*)=cgrid(0,*)
img=read_image(imgfile)
dimtest=size(img)
if dimtest(0) eq 3 then img=byte(mean(img,dimension=1))
cgdims=[max(cgrid(1,*)),max(cgrid(2,*))]
img=reverse(congrid(img,cgdims(0),cgdims(1)),2)
if strmid(file_basename(cgridfile),0,2) eq 'rh' then img=reverse(img,1)
for i=0,cgdims(0)-1 do for j=0,cgdims(1)-1 do begin
inc=where(cgrid(1,*) eq i+1 and cgrid(2,*) eq j+1,/NULL)
if inc ne !NULL then opdat(1,inc)=img(i,j)-128
end
print,'Writing '+opfile
write_w,opfile,opdat
print,'Done'
return
end
