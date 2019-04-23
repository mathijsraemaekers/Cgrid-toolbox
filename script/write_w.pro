pro write_w,filename,dat
syntx=n_params()
if syntx lt 1 then begin
print,'Script for writing FreeSurfer w files'
print,'The filename of the file to write'
print,'The data to write, format 2,nrcoors (float). dat(0,*) are the vertex numbers. dat(1,*) are the values' 
return
end
nrcoor=n_elements(dat(0,*))
bcoor=byte(nrcoor,0,4)
hdr=[byte([0,0]),bcoor([2,1,0])]
opdat=bytarr(7,nrcoor)
vnrs=long(dat(0,*))
bverts=byte(vnrs,0,4*nrcoor)
bverts=reform(bverts,4,nrcoor)
opdat(0:2,*)=bverts([2,1,0],*)
bvals=reform(byte(dat(1,*),0,4*nrcoor),4,nrcoor)
opdat(3:*,*)=bvals([3,2,1,0],*)
get_lun,unit
openw,unit,filename
writeu,unit,hdr,opdat
close,unit
free_lun,unit
end
