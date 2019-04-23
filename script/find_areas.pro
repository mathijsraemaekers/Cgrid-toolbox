function find_areas,subcode,hem,pfext,patchfile=patchfile
syntx=n_params()
if syntx lt 3 then begin
print,'Returns the ROIs in a patchfile.'
print,'Syntax not right; parms are :'
print,'1: The Freesurfer subject code'
print,'2: The hemisphere, should be lh or rh.'
print,'3: The paintfile type (e.g. aparc,aparc_a2009s etc)'
print,'Keyword patchfile sets the name of the patchfile you want to use for limiting the border search'
return,0
endif
spawn,'echo $SUBJECTS_DIR',fsdir
surfdir=fsdir+'/'+subcode+'/surf/'
paint=read_fs_annotation(subcode,hem,pfext,plegend=tpnames)
tpnames=reform(tpnames(1,*))
paint=reform(paint(1,*))
patch=read_fs_patch(patchfile,/erodep)
incpaint=paint(patch(0,*))
histp=histogram(incpaint,min=0)
incrois=tpnames(where(histp ge total(histp)/100.))
return,incrois
end

