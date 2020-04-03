pro gen_fs_patch_widget
spawn,'echo $SUBJECTS_DIR',fsdir
spawn,'echo $HOME',homedir
surfs=['inflated','sphere','sphere.reg','very_inflated']
hems=['lh','rh']
hemtest=[1,1]
pictsel=0
surf=surfs(0)
fssubs=file_basename(file_search(fsdir+'/*',/test_directory))
nrsub=n_elements(fssubs)
subtest=intarr(nrsub)
base=widget_base(column=3,title='Select Freesurfer subject',xsize=250)
subselect=widget_combobox(base,value=fssubs)
proceed=widget_button(base,value='Proceed') 
quit=widget_button(base,value='Quit')
widget_control,base,/realize
resp=widget_event(base,/nowait)
subcode=fssubs(0)
while resp.id ne proceed do begin
resp=widget_event(base)
if resp.id eq subselect then subcode=resp.str
if resp.id eq quit then begin
widget_control,base,/destroy
return
end
end
labeldir=fsdir+'/'+subcode+'/label/'
surfdir=fsdir+'/'+subcode+'/surf/'
subtest(where(fssubs eq subcode))=1
widget_control,base,/destroy
annots=replace(replace(file_basename(file_search(labeldir+'lh.*.annot')),'lh.',''),'.annot','')
atest=where(annots eq 'aparc',/NULL)
stest=0
pvolume=annots(atest)
if atest eq !NULL then atest=0
base=widget_base(/row,title='Select Hemispheres(s) and Annotation Scheme',xsize=450)
proceed=widget_button(base,value='Proceed')
hemsel=cw_bgroup(base,hems,/column,/nonexclusive,label_top='Hemisphere',set_value=hemtest)
annotsel=cw_bgroup(base,annots,/column,/exclusive,label_top='Annotation scheme',set_value=atest)
surfsel=cw_bgroup(base,surfs,/column,/exclusive,label_top='Surface',set_value=stest)
quit=widget_button(base,value='Quit')
resp=widget_event(base,/nowait)
widget_control,base,/realize
while resp.id ne proceed or total(hemtest) eq 0 do begin
if resp.id eq proceed and total(hemtest) eq 0 then print,'No hemispheres selected. Choose at least one hemisphere.'
resp=widget_event(base)
if resp.id eq annotsel then pvolume=annots(resp.value)
if resp.id eq surfsel then surf=surfs(resp.value)
if resp.id eq hemsel then hemtest(resp.value)=resp.select
if resp.id eq quit then begin
widget_control,base,/destroy
return
end
end
widget_control,base,/destroy
if strpos(pvolume,'aparc') ne -1 then ctabfile=labeldir+'aparc.annot.'+replace(pvolume,'aparc','')+'.ctab' else ctabfile=labeldir+pvolume+'.ctab'
ctabfile=replace(ctabfile,'..','.')
ctabinfo=read_ctab(ctabfile)
rois=reform(ctabinfo(1,*))
outputprefix='patch'
distsi=20
distra=7.
base=widget_base(/row,title='Choose patch properties')
proceed=widget_button(base,value='Proceed')
procbatch=widget_button(base,value='Proceed to multiple subject selection')
picts=cw_bgroup(base,'Save PNG images of patches',/nonexclusive)
sbase=widget_base(base,/column)
namesel=cw_field(sbase,title='Prefix for patchfiles       ',/all_events,/string,value='patch')
distsis=cw_field(sbase,title='Max neighbours used         ',/all_events,/integer,value=distsi)
distras=cw_field(sbase,title='Radius used                 ',/all_events,/float,value=distra)
roisel=cw_bgroup(base,rois,column=3,/nonexclusive,label_top='ROI(s) to include in patch',/frame)
quit=widget_button(base,value='Quit')
resp=widget_event(base,/nowait)
widget_control,base,/realize
roitest=intarr(n_elements(rois))
while min(abs([proceed,procbatch]-resp.id)) ne 0 or outputprefix eq '' or total(roitest) eq 0 or distsi le 0 or distra le 0 do begin
resp=widget_event(base)
if min(abs([proceed,procbatch]-resp.id)) eq 0 then if outputprefix eq '' then print,'No prefix for patchfile defined.'
if min(abs([proceed,procbatch]-resp.id)) eq 0 then if total(roitest) eq 0 then print,'No ROIs included. Choose at least one ROI.'
if min(abs([proceed,procbatch]-resp.id)) eq 0 then if distsi le 0 then print,'Neigbours used should be larger than 0.'
if min(abs([proceed,procbatch]-resp.id)) eq 0 then if distra le 0 then print,'Radius used should be larger than 0.'
if resp.id eq picts then pictsel=resp.select
if resp.id eq namesel then outputprefix=resp.value
if resp.id eq distsis then distsi=resp.value
if resp.id eq distras then distra=resp.value
if resp.id eq roisel then roitest(resp.value)=resp.select
if resp.id eq quit then begin
widget_control,base,/destroy
return
end
end
if outputprefix eq '' then outputprefix='patch'
if resp.id eq procbatch then mss=1 else mss=0
widget_control,base,/destroy
distflag=' -distances '+trim(distsi)+' '+trim(distra)
if mss eq 1 then begin
base=widget_base(/row,title='Include multiple subjects')
proceed=widget_button(base,value='Proceed')
roisel=cw_bgroup(base,fssubs,column=8,/nonexclusive,label_top='Subjects to include',/frame,set_value=subtest)
quit=widget_button(base,value='Quit')
resp=widget_event(base,/nowait)
widget_control,base,/realize
while resp.id ne proceed or total(subtest) eq 0 do begin
resp=widget_event(base)
if resp.id eq proceed then if total(subtest) eq 0 then print,'No subjects included. Include at least one subject'
if resp.id eq roisel then subtest(resp.value)=resp.select
if resp.id eq quit then begin
widget_control,base,/destroy
return
end
end
widget_control,base,/destroy
end
plabels=rois(where(roitest eq 1))
for k=0,nrsub-1 do if subtest(k) eq 1 then for j=0,1 do if hemtest(j) eq 1 then  begin
subcode=fssubs(k)
labeldir=fsdir+'/'+subcode+'/label/'
surfdir=fsdir+'/'+subcode+'/surf/'
hem=hems(j)
outputfile=fsdir+'/'+subcode+'/surf/'+hem+'.'+outputprefix+'.3d'
flat_outputfile=fsdir+'/'+subcode+'/surf/'+hem+'.'+outputprefix+'_flat.3d'
tmppaints=read_fs_annotation(subcode,hem,pvolume,plegend=plegend)
if surf eq 'very_inflated' then if not file_test(surfdir+hem+'.very_inflated') then spawn,'mris_inflate '+surfdir+hem+'.inflated '+surfdir+hem+'.very_inflated'
fssurface=read_fs_surface(surfdir+hem+'.'+surf)
print,'Extracting patch from '+surfdir+hem+'.'+surf
nrpaints=n_elements(plabels)
paintnrs=intarr(nrpaints)
for i=0,nrpaints-1 do paintnrs(i)=fix(plegend(0,where(plegend(1,*) eq plabels(i))))
paints=reform(tmppaints(1,*))*0
for i=0,nrpaints-1 do paints(where(tmppaints(1,*) eq paintnrs(i)))=1
coords=fssurface.COORDINATES
topo=fssurface.TOPOLOGY
paints(topo(*,where(stddev(paints(topo),dimension=1) ne 0)))=1
csel=where(paints ne 0)
nrcsel=n_elements(csel)
ptopo=where(stddev(paints(topo),dimension=1) ne 0)
ctopo=topo(*,ptopo)
bcoor=ctopo(where(paints(ctopo) eq 1))
bcoor=bcoor(sort(bcoor))
bcoor=bcoor(uniq(bcoor))
coords(0,*)=coords(0,*)+1
coords(0,bcoor)=-coords(0,bcoor)
coords=coords(*,csel)
wrdat=bytarr(16,nrcsel)
wrdat(4:*,*)=byte(coords(1:*,*),0,4*nrcsel*3)
wrdat(0:3,*)=byte(long(coords(0,*)),0,4*nrcsel)
wrdat=reform(wrdat,16*nrcsel)
nrcode=byte(nrcsel,0,4)
wrdat=[byte([255,255,255,255]),nrcode,wrdat]
byteorder,wrdat,/htonl
wrbblk,outputfile,wrdat
cd,homedir
print,'Start flattening '+outputfile
fc='mris_flatten '+outputfile+' '+flat_outputfile+distflag
print,fc
spawn,fc
print,'Writing '+flat_outputfile
print,'Done'
spawn,'rm '+outputfile
tmpfile=homedir+'/'+file_basename(flat_outputfile)+'.out'
if file_test(tmpfile) then spawn,'rm '+tmpfile
if pictsel eq 1 then begin
patch=read_fs_patch(flat_outputfile)
if strpos(pvolume,'aparc') ne -1 then ctabfile=labeldir+'aparc.annot.'+replace(pvolume,'aparc','')+'.ctab' else ctabfile=labeldir+pvolume+'.ctab'
ctabfile=replace(ctabfile,'..','.')
ctab=read_ctab(ctabfile)
patchcols=tmppaints(1,patch(0,*))
allcols=patchcols(sort(patchcols))
allcols=allcols(uniq(allcols))
for l=0,n_elements(allcols)-1 do begin
inc=where(patchcols eq allcols(l))
pplot=plot(patch(1,inc),patch(2,inc),color=fix(ctab(2:4,allcols(l))),symbol='+',linestyle='none',margin=[0.05,0.05,0.3,0.1],name=reform(ctab(1,allcols(l))),/overplot,aspect_ratio=1.,dimension=[1200,1000],xtitle='x (mm)',ytitle='y (mm)',title=subcode+' flattened '+outputprefix+' patch '+hem)
end
leg=legend(vertical_alignment='top',horizontal_alignment='right',transparency=100)
picname=fsdir+'/'+subcode+'/surf/'+subcode+'_'+hem+'.'+outputprefix+'_flat.png'
print,'Writing '+picname
pplot.Save,picname,compression=1
print,'Done'
pplot.close
end
end
print,'Finished'
end
