pro map_image2cgrid,cgridfile,imgfile,opfile,mins,maxs
syntx=n_params()
if syntx lt 3 then begin
print,'Script for mapping an image to a Cgrid:'
print,'1: The name of the cgridfile'
print,'2: The name of the image' 
print,'3: The name of the outputfile' 
print,'4: Lowest value in the output' 
print,'3: Highest value in the output' 
return
end
hem=strmid(file_basename(cgridfile),0,2)
nrcoor=n_elements(read_fs_surfdat(file_dirname(cgridfile)+'/'+hem+'.sulc'))
cgrid=(read_ascii(cgridfile)).(0)
cgrid(1:*)=ceil(cgrid(1:*))
opdat=fltarr(nrcoor)
img=read_image(imgfile)
dimtest=size(img)
if dimtest(0) eq 3 then img=byte(mean(img,dimension=1))
cgdims=[max(cgrid(1,*)),max(cgrid(2,*))]
img=float(reverse(congrid(img,cgdims(0),cgdims(1)),2))
mino=min(img)
maxo=max(img)
img=(img-mino)/(maxo-mino)*(maxs-mins)+mins
if hem eq 'rh' then img=reverse(img,1)
for i=0,cgdims(0)-1 do for j=0,cgdims(1)-1 do begin $
& inc=cgrid(0,where(cgrid(1,*) eq i+1 and cgrid(2,*) eq j+1,/NULL)) $
& if inc ne !NULL then opdat(inc)=img(i,j) $
& end
print,'Writing '+opfile
write_mgh,opdat,opfile
write_w,replace(opfile,'.mgh','.w'),opdat
write_metric,replace(opfile,'.mgh','.metric'),opdat
print,'Done'
return
end
