pro mgh2cgrid,niifiles,cgridfiles,mval=mval
syntx=n_params()
if syntx lt 2 then begin
print,'Usage:'
print,'The nifi files to convert'
print,'The cgridfile'
print,'Set keyword mval to fill in missing data points in the CGRID'
return
end
spawn,'echo $SUBJECTS_DIR',fsdir
nrniifiles=n_elements(niifiles)
hems=['lh','rh']
hemt=['left','right']
lniis=niifiles(where(strpos(niifiles,'left') ne -1))
tmpniifiles=strarr(2,n_elements(lniis))
tmpniifiles(0,*)=lniis
tmpniifiles(1,*)=replace(lniis,'left','right')
subcode=replace(replace(file_dirname(cgridfiles(0)),fsdir+'/',''),'/surf','')
patchcode=replace(replace(replace(file_basename(cgridfiles(0)),'.cgrid',''),'lh_',''),'rh_','')
surfdir=fsdir+'/'+subcode+'/surf/'
nrcgridfiles=n_elements(cgridfiles)
tmpcgriddat=read_ascii(cgridfiles(0))
tmpcgriddat=tmpcgriddat.(0)
xdim=max(tmpcgriddat(1,*))
ydim=max(tmpcgriddat(2,*))
cgrids=create_struct(patchcode+'_'+trim(1),tmpcgriddat)
if nrcgridfiles gt 1 then for i=1,nrcgridfiles-1 do begin
tmpcgriddat=read_ascii(cgridfiles(i))
tmpcgriddat=tmpcgriddat.(0)
tmpxdim=max(tmpcgriddat(1,*))
tmpydim=max(tmpcgriddat(2,*))
if tmpxdim gt xdim then xdim=tmpxdim
if tmpydim gt ydim then ydim=tmpydim
cgrids=create_struct(cgrids,patchcode+'_'+trim(i+1),tmpcgriddat)
end
if keyword_set(mval) then begin
mvals=fltarr(xdim,ydim,2)+1
for j=0,nrcgridfiles-1 do begin 
hem=strmid(file_basename(cgridfiles(j)),0,2)
sind=where(hems eq hem)
cgrid=cgrids.(j)
for k=0,xdim-1 do for l=0,ydim-1 do if where(cgrid(1,*) eq k+1 and cgrid(2,*) eq l+1,/NULL) eq !NULL then mvals(k,l,sind)=0
end
end
areas=create_struct('lh',read_fs_surfdat(surfdir+'lh.area.mid'))
areas=create_struct(areas,'rh',read_fs_surfdat(surfdir+'rh.area.mid'))
for i=0,n_elements(tmpniifiles(0,*))-1 do begin
for j=0,nrcgridfiles-1 do begin
hem=strmid(file_basename(cgridfiles(j)),0,2)
sind=where(hems eq hem)
area=areas.(sind)
cgrid=cgrids.(j)
readmgh,tmpniifiles(j,i),surfdat
nrscans=n_elements(surfdat(0,0,0,*))
surfdat=reform(surfdat,n_elements(surfdat(*,0,0,0)),nrscans)
if j eq 0 then opdat=fltarr(xdim,ydim,2,nrscans)
for k=0,nrscans-1 do surfdat(*,k)=surfdat(*,k)*area
for k=0,xdim-1 do for l=0,ydim-1 do begin
inc=where(cgrid(1,*) eq k+1 and cgrid(2,*) eq l+1,/NULL)
if inc ne !NULL then opdat(k,l,sind,*)=total(surfdat(cgrid(0,inc),*),1)/total(area((cgrid(0,inc))))
end
end
if keyword_set(mval) then for l=0,1 do begin
tmpinc=where(mvals(*,*,l) eq 0,/NULL)
if tmpinc ne !NULL then for k=0,nrscans-1 do begin
tmpdat=opdat(*,*,l,k)
tmpdat(tmpinc)=!VALUES.F_NAN
smtmpdat=gauss_smooth(tmpdat,0.5,/NAN,/edge_truncate,/normalize)
tmpdat(tmpinc)=smtmpdat(tmpinc)
opdat(*,*,l,k)=tmpdat
end
end
outputfile=replace(replace(file_basename(tmpniifiles(0,i)),'.mgh','.nii'),'left','')
dtest=strpos(outputfile,'-',/reverse_search)
if dtest ne -1 then outputfile=strmid(outputfile,0,dtest)+'_cgrid_'+patchcode+strmid(outputfile,dtest,strlen(outputfile)) else outputfile=replace(outputfile,'.nii','')+'_cgrid_'+patchcode+'.nii'
wrfile=file_dirname(niifiles(i))+'/'+outputfile
print,'Writing '+wrfile
niihdrtool,wrfile,fdata=opdat,srow_x4=-xdim/2.+0.5,srow_y4=-ydim/2.+0.5,srow_z4=-0.5
print,'Done'
end
end
