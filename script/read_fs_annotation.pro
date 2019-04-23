function read_fs_annotation,subcode,hem,atlas,plegend=plegend
syntx=n_params()
if syntx lt 1 then begin
print,'Returns the content of a Freesurfer annotation file.'
print,'Syntax not right; parms are :'
print,'1: The Freesurfer subject code'
print,'2: The hemisphere (lh/rh)'
print,'3: The atlas to use (e.g. aparc/aparc.a2009s/aparc.DKTatlas40/BA_exvivo)'
print,'Keyword plegend gives a matrix with the label names'
return,0
endif
spawn,'echo $SUBJECTS_DIR',fsdir
labeldir=fsdir+'/'+subcode+'/label/'
annotfile=labeldir+hem+'.'+atlas+'.annot'
if strpos(atlas,'aparc') ne -1 then ctabfile=labeldir+'aparc.annot.'+replace(atlas,'aparc','')+'.ctab' else ctabfile=labeldir+atlas+'.ctab'
ctabfile=replace(ctabfile,'..','.')
ctab=read_ctab(ctabfile)
nrrois=n_elements(ctab(0,*))
filesize=file_info(annotfile)
filesize=filesize.size
dat=bytarr(filesize)
rdbblk,annotfile,dat
tmpdat=dat(0:3)
byteorder,tmpdat,/ntohl
nrcoor=long(tmpdat,0,1)
dat=reform(dat(4:3+nrcoor*8),8,nrcoor)
annots=reverse(dat(5:*,*),1)
coors=long(dat,0,2*nrcoor)
plabels=lonarr(nrcoor)
vertices=dat(0:3,*)
byteorder,vertices,/ntohl
vertices=long(vertices,0,nrcoor)
for i=0,nrrois-1 do begin
tm=transpose([[bytarr(nrcoor)+ctab(2,i)],[bytarr(nrcoor)+ctab(3,i)],[bytarr(nrcoor)+ctab(4,i)]])
plabels(where(total(abs(annots-tm),1) eq 0,/NULL))=i
end
op=transpose([[vertices],[plabels]])
plegend=ctab(0:1,*)
return,op
end
