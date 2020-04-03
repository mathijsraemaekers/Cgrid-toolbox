pro cgrid2vol,cgridfile,ext=ext,opdir=opdir,method=method,parms=parms
syntx=n_params()
if syntx lt 1 then begin
print,'Usage:'
print,'The cgrid files'
print,'Keyword ext provides the file extension of the to be written files (default is .nii)'
print,'Keyword opdir provides the output folder of the to be written files (default is the freesurfer mri folder of the subject)'
print,'Keyword method sets the mapping approach (frac or abs)'
print,'Keyword parms is a floating array with length 3 describing the mapping details (start,stop,delta). Default is [0,1,0.1]'
return
end
if not keyword_set(method) then method='frac'
if not keyword_set(parms) then parms=[0.,1.,0.1]
parms=string(parms)
spawn,'echo $SUBJECTS_DIR',fsdir
if not keyword_set(ext) then ext='.nii'
subcode=replace(replace(file_dirname(cgridfile),fsdir+'/',''),'/surf','')
patchcode=replace(replace(replace(file_basename(cgridfile),'.cgrid',''),'lh_',''),'rh_','')
hem=strmid(file_basename(cgridfile),0,2)
surfdir=fsdir+'/'+subcode+'/surf/'
labeldir=fsdir+'/'+subcode+'/label/'
mridir=fsdir+'/'+subcode+'/mri/'
if not keyword_set(opdir) or opdir eq '' then opdir=mridir
nrcgridfiles=n_elements(cgridfiles)
opfile1=opdir+subcode+'_cgrid_'+patchcode+'_x_'+hem+ext
opfile2=opdir+subcode+'_cgrid_'+patchcode+'_y_'+hem+ext
label2volxc='mri_label2vol --subject '+subcode+' --temp '+mridir+'T1.mgz --o '+opfile1+' --identity --proj '+method+' '+parms(0)+' '+parms(1)+' '+parms(2)+' --hemi '+hem
label2volyc='mri_label2vol --subject '+subcode+' --temp '+mridir+'T1.mgz --o '+opfile2+' --identity --proj '+method+' '+parms(0)+' '+parms(1)+' '+parms(2)+' --hemi '+hem
labelfiles=''
cgrid=read_ascii(cgridfile)
cgrid=cgrid.(0)
cgrid(1:2,*)=ceil(cgrid(1:2,*))
xdim=max(cgrid(1,*))
ydim=max(cgrid(2,*))
surf=read_fs_surface(surfdir+hem+'.white')
coords=trim(surf.COORDINATES)
for j=0,xdim-1 do begin
tmpdat=cgrid(0,where(cgrid(1,*) eq j+1))
tmpcoor=n_elements(tmpdat)
tmpdat=transpose(['#!ascii label',trim(tmpcoor),reform(trim(long(tmpdat))+'  '+coords(1,*)+'  '+coords(2,*)+'  '+coords(3,*)+'  '+strcompress(string(fltarr(tmpcoor)),/remove_all))])
labelfile=labeldir+hem+'.cgrid_'+patchcode+'_x'+string(j+1,FORMAT='(I04)')+'.label'
write_ascii,labelfile,tmpdat
label2volxc=label2volxc+' --label '+labelfile
labelfiles=[labelfiles,labelfile]
end
for j=0,ydim-1 do begin
tmpdat=cgrid(0,where(cgrid(2,*) eq j+1))
tmpcoor=n_elements(tmpdat)
tmpdat=transpose(['#!ascii label',trim(tmpcoor),reform(trim(long(tmpdat))+'  '+coords(1,*)+'  '+coords(2,*)+'  '+coords(3,*)+'  '+strcompress(string(fltarr(tmpcoor)),/remove_all))])
labelfile=labeldir+hem+'.cgrid_'+patchcode+'_y'+string(j+1,FORMAT='(I04)')+'.label'
write_ascii,labelfile,tmpdat
label2volyc=label2volyc+' --label '+labelfile
labelfiles=[labelfiles,labelfile]
end
print,'Mapping CGRID x-coordinates to volume'
spawn,label2volxc
print,'Results written to '+opfile1
print,'Done'
print,'Mapping CGRID y-coordinates to volume'
spawn,label2volyc
print,'Results written to '+opfile2
print,'Done'
for i=1,n_elements(labelfiles)-1 do spawn,'rm '+labelfiles(i)
end

