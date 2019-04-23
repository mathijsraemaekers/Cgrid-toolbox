function read_fs_surfdat,filename
syntx=n_params()
if syntx lt 1 then begin
print,'Returns the content of a Freesurfer surface data file (e.g. lh.surf).'
print,'Syntax not right; parms are :'
print,'1: full filename of the surface data file'
return,0
endif
filesize=file_info(filename)
filesize=filesize.size
dat=bytarr(filesize)
rdbblk,filename,dat
tmpdat=dat(0:39)
byteorder,tmpdat,/ntohl
nrcoor=long(tmpdat,5,1)
tmpdat=dat(9:nrcoor*4+12)
byteorder,tmpdat,/ntohl
surfdat=float(tmpdat,2,nrcoor)
return,surfdat
end
