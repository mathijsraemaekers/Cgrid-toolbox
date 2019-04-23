function read_fs_patch,filename,erodep=erodep
syntx=n_params()
if syntx lt 1 then begin
print,'Returns the content of a Freesurfer patch file.'
print,'Syntax not right; parms are :'
print,'1: full filename of the patch file'
print,'Keyword erodep erodes the patch once'
return,0
endif
filesize=file_info(filename)
filesize=filesize.size
dat=bytarr(filesize)
rdbblk,filename,dat
byteorder,dat,/ntohl
nrcoor=long(dat,4,1)
patchdat=dblarr(4,nrcoor)
tmp=long(dat,8,nrcoor*4)
tmp=reform(tmp,4,nrcoor)
if keyword_set(erodep) then tmp(*,where(tmp(0,*) lt 0))=0
patchdat(0,*)=abs(tmp(0,*))-1
tmp=float(dat,8,nrcoor*4)
tmp=reform(tmp,4,nrcoor)
patchdat(1:*,*)=tmp(1:*,*)
if keyword_set(erodep) then patchdat=patchdat(*,where(patchdat(0,*) ne -1))
return,patchdat
end
