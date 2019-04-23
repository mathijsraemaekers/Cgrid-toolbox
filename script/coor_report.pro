pro coor_report,coorfile,cgridfiles,outputfile,annots=annots,niioutput=niioutput
syntx=n_params()
if syntx lt 3 then begin
print,'Usage:'
print,'The name of the ascii file containing the coordinates (3 columns)'
print,'The names of the cgrid files'
print,'The name of the file containing the report'
print,'Keyword annotations includes annotations in the report'
print,'Keyword niiouput includes a nii with electrode positions in Cgrid space'
return
end
print,'Generating report for the specified coordinates.'
hems=['lh','rh']
spawn,'echo $SUBJECTS_DIR',fsdir
subcode=replace(replace(file_dirname(cgridfiles(0)),fsdir+'/',''),'/surf','')
labeldir=fsdir+'/'+subcode+'/label/'
surfdir=fsdir+'/'+subcode+'/surf/'
mridir=fsdir+'/'+subcode+'/mri/'
surffiles=surfdir(0)+hems+'.pial'
lhsurf=read_fs_surface(surffiles(0))
rhsurf=read_fs_surface(surffiles(1))
surf=[[lhsurf.coordinates],[rhsurf.coordinates]]
nrlvert=n_elements(lhsurf.coordinates)/4
nrrvert=n_elements(rhsurf.coordinates)/4
lhind=[intarr(nrlvert),intarr(nrrvert)+1]
ocoors=read_ascii(coorfile)
ocoors=ocoors.(0)
spawn,'mri_info '+mridir+'T1.mgz --cras',trans
trans=stringdiv(trans)
coors=ocoors*0
for i=0,2 do coors(i,*)=ocoors(i,*)-trans(i)
nrcoor=n_elements(coors(0,*))
nrvert=n_elements(surf(0,*))
cvertices=lonarr(nrcoor)
projdist=fltarr(nrcoor)
for i=0,nrcoor-1 do begin
dists=surf(1:*,*)-rebin(reform(coors(*,i)),3,nrvert,/sample)
dists=sqrt(total(dists^2,1))
projdist(i)=min(dists)
cvertices(i)=where(dists eq projdist(i))
end
coornrs=transpose(['Coordinate:',trim(indgen(nrcoor)+1)])
disttosurf=transpose(['DistanceToSurface:',trim(projdist)])
ocoors=[['x-original:','y-original:','z-original:'],[trim(ocoors)]]
aras=[['x-aras:','y-aras:','z-aras:'],[trim(coors)]]
pcoors=[['x-projected:','y-projected:','z-projected:'],[trim(surf(1:*,cvertices))]]
pverts=[['projected vertex:'],[trim(surf(0,cvertices))]]
totcgrid=lonarr(2,nrvert)
xdim=0
ydim=0
for i=0,n_elements(cgridfiles)-1 do begin
hem=strmid(file_basename(cgridfiles(i)),0,2)
cgrid=read_ascii(cgridfiles(i))
cgrid=cgrid.(0)
if max(cgrid(1,*)) gt xdim then xdim=max(cgrid(1,*))
if max(cgrid(2,*)) gt ydim then ydim=max(cgrid(2,*))
if hem eq 'lh' then totcgrid(*,cgrid(0,*))=cgrid(1:2,*) else totcgrid(*,cgrid(0,*)+nrlvert)=cgrid(1:2,*)
end
gridcode=replace(strmid(file_basename(cgridfiles(0)),3,strlen(cgridfiles(0))),'.cgrid','')
cgridinfo=[[['x','y']+'-cgrid_'+gridcode],[trim(totcgrid(*,cvertices))]]
cgridinfo(where(cgridinfo eq '0'))='NA'
wrdat=[coornrs,disttosurf,ocoors,aras,pcoors,pverts,cgridinfo]
if keyword_set(annots) then begin
nrannots=n_elements(annots)
corannot=strarr(nrannots,nrcoor+1)
corannot(*,0)=annots+':'
for i=0,nrannots-1 do begin
lhpaints=read_fs_annotation(subcode,hems(0),annots(i),plegend=plegend)
rhpaints=read_fs_annotation(subcode,hems(1),annots(i))
paints=[reform(lhpaints(1,*)),reform(rhpaints(1,*))]
corannot(i,1:*)=hems(lhind(cvertices))+'.'+plegend(1,paints(cvertices))
end
wrdat=[wrdat,corannot]
end
print,'Writing '+outputfile
write_ascii,outputfile,wrdat
print,'Done'
if keyword_set(niioutput) then begin
opdat=intarr(xdim+1,ydim+1,2)
for i=0,nrcoor-1 do opdat(totcgrid(0,cvertices(i)),totcgrid(1,cvertices(i)),lhind(cvertices(i)))=opdat(totcgrid(0,cvertices(i)),totcgrid(1,cvertices(i)),lhind(cvertices(i)))+1
niioutput=replace(outputfile,'.txt','.nii')
print,'Writing '+niioutput
niihdrtool,niioutput,fdata=opdat(1:*,1:*,*),srow_x4=-xdim/2.+0.5,srow_y4=-ydim/2.+0.5,srow_z4=-0.5
print,'Done'
end
print,'Finished'
end

