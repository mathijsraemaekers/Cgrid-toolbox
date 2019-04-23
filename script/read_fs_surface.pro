function read_fs_surface,filename
syntx=n_params()
if syntx lt 1 then begin
print,'Returns the content of a Freesurfer surface file.'
print,'Syntax not right; parms are :'
print,'1: full filename of the surface file'
return,0
endif
filesize=file_info(filename)
filesize=filesize.size
dat=bytarr(filesize)
rdbblk,filename,dat
count=6
tmp=[0,0]
while total(tmp-[10,10]) ne 0 do begin
tmp=dat([count,count+1])
count=count+1
end
nrcoor=long(byte([dat([count+4,count+3,count+2]),0]),0,1)
nrtopo=long(byte([dat([count+8,count+7,count+6]),0]),0,1)
coordat=dat(count+9:count+8+nrcoor*12)
byteorder,coordat,/ntohl
coordat=[transpose(lindgen(nrcoor)),reform(float(coordat,0,nrcoor*3),3,nrcoor)]
topodat=dat(count+9+nrcoor*12:count+8+nrcoor*12+nrtopo*12)
byteorder,topodat,/ntohl
topodat=reform(long(topodat,0,nrtopo*3),3,nrtopo)
surfacedat=create_struct('Info','Data')
surfacedat=create_struct(surfacedat,'COORDINATES',coordat)
surfacedat=create_struct(surfacedat,'TOPOLOGY',topodat)
return,surfacedat
end
