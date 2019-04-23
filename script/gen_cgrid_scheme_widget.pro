pro gen_cgrid_scheme_widget
spawn,'echo $SUBJECTS_DIR',fsdir
nrgrids=1
porder=0
xdim=5
ydim='5'
xinv=0
yn=['no','yes']
axprocs=intarr(2)
patchfile=''
while strpos(patchfile,'_flat.3d') eq -1 or file_test(patchfile) eq 0 do begin
patchfile=dialog_pickfile(/read,filter='*_flat.3d',path=fsdir,title='Select flattened patch file')
if patchfile eq '' then return
if strpos(patchfile,'_flat.3d') eq -1 then print,'Selected file is not a patchfile. Choose a file with a _flat.3d extension.'
if file_test(patchfile) eq 0 then print,'The selected patchfile does not exist.'
end
subcode=replace(replace(file_dirname(patchfile),fsdir+'/',''),'/surf','')
patchcode=replace(replace(replace(file_basename(patchfile),'_flat.3d',''),'lh.',''),'rh.','')
hem=strmid(file_basename(patchfile),0,2)
labeldir=fsdir+'/'+subcode+'/label/'
surfdir=fsdir+'/'+subcode+'/surf/'
annots=replace(replace(file_basename(file_search(labeldir+hem+'.*.annot')),hem+'.',''),'.annot','')
ans=where(annots eq 'aparc',/NULL)
if ans eq !NULL then ans=0
pvolume=annots(ans)
base=widget_base(/row,title='Specify Cgrid properties')
proceed=widget_button(base,value='Proceed')
sbase=widget_base(base,/column)
ncgrid=cw_field(sbase,title='Number of subgrids         ',/all_events,/integer,value=nrgrids)
xdims=cw_field(sbase,title='x-dimension                ',/all_events,/integer,value=xdim)
ydims=cw_field(sbase,title='y-dimension(s) per subgrid ',/all_events,/string,value=ydim,xsize=20)
porders=cw_field(sbase,title='Polynomial order           ',/all_events,/integer,value=porder)
axproc=cw_bgroup(base,['Invert x-axis','Transpose axes'],/nonexclusive,set_value=axprocs)
annotsel=cw_bgroup(base,annots,/column,/exclusive,label_top='Annotation scheme',set_value=ans)
quit=widget_button(base,value='Quit')
resp=widget_event(base,/nowait)
widget_control,base,/realize
while resp.id ne proceed or min([xdim,ydim]) lt 2 or nrgrids lt 1 or porder lt 0 do begin
resp=widget_event(base)
if resp.id eq proceed then if min([xdim,ydim]) lt 2 then print,'x and y dimensions should be at least 2'
if resp.id eq proceed then if nrgrids lt 1 then print,'The number of subgrids should be at least 1'
if resp.id eq proceed then if porder lt 0 then print,'The polynomial order should be at least 0'
if resp.id eq ncgrid then nrgrids=resp.value
if resp.id eq xdims then xdim=resp.value
if resp.id eq ydims then ydim=resp.value
if resp.id eq porders then porder=resp.value
if resp.id eq axproc then axprocs(resp.value)=resp.select
if resp.id eq annotsel then pvolume=annots(resp.value)
if resp.id eq quit then begin
widget_control,base,/destroy
return
end
end
widget_control,base,/destroy
incrois=find_areas(subcode,hem,pvolume,patchfile=patchfile)
incroiss=intarr(n_elements(incrois))+1
base=widget_base(/row,title='ROIs to include')
proceed=widget_button(base,value='Proceed')
roisel=cw_bgroup(base,incrois,column=3,/nonexclusive,label_top='ROI(s) to suggest to include in patch',/frame,set_value=incroiss)
quit=widget_button(base,value='Quit')
resp=widget_event(base,/nowait)
widget_control,base,/realize
while resp.id ne proceed or total(incroiss) eq 0 do begin
resp=widget_event(base)
if resp.id eq proceed then if total(incroiss) eq 0 then print,'No ROIs included. Choose at least one ROI.'
if resp.id eq roisel then incroiss(resp.value)=resp.select
if resp.id eq quit then begin
widget_control,base,/destroy
return
end
end
widget_control,base,/destroy
incrois=incrois(where(incroiss eq 1))
wrrois=incrois(0)
if n_elements(incrois) gt 1 then for i=1,n_elements(incrois)-1 do wrrois=wrrois+','+incrois(i)
borinfo=find_paint_borders_tmp(subcode,hem,pvolume,patchfile=patchfile)
borders=tag_names(borinfo)
borders=borders(1:*)
nrbor=n_elements(borders)
ubors=intarr(nrbor,nrgrids)
dbors=intarr(nrbor,nrgrids)
lbors=intarr(nrbor,nrgrids)
rbors=intarr(nrbor,nrgrids)
prestest=0
novtest=1
for i=0,nrgrids-1 do begin
base=widget_base(column=4,title='Define borders for subgrid-'+trim(i+1))
tabbase=widget_tab(base,multiline=4,xsize=1000)
tab1=widget_base(tabbase,title='Upper Border',/row)
proc1=widget_button(tab1,value='Proceed')
quit1=widget_button(tab1,value='Quit')
tabs1=cw_bgroup(tab1,borders,column=3,/nonexclusive,label_top='Select Upper Borders')
tab2=widget_base(tabbase,title='Lower Border',/row)
proc2=widget_button(tab2,value='Proceed')
quit2=widget_button(tab2,value='Quit')
tabs2=cw_bgroup(tab2,borders,column=3,/nonexclusive,label_top='Select Lower Borders')
tab3=widget_base(tabbase,title='Left Border',/row)
proc3=widget_button(tab3,value='Proceed')
quit3=widget_button(tab3,value='Quit')
tabs3=cw_bgroup(tab3,borders,column=3,/nonexclusive,label_top='Select Right Borders')
tab4=widget_base(tabbase,title='Right Border',/row)
proc4=widget_button(tab4,value='Proceed')
quit4=widget_button(tab4,value='Quit')
tabs4=cw_bgroup(tab4,borders,column=3,/nonexclusive,label_top='Select Left Borders')
widget_control,base,/realize
resp1=widget_event(base,/nowait)
while min(abs([proc1,proc2,proc3,proc4]-resp.id)) ne 0 or prestest ne 1 or novtest ne 1 do begin
if min(abs([proc1,proc2,proc3,proc4]-resp.id)) eq 0 then if prestest eq 0 then print,'Not all subgrid borders defined'
if min(abs([proc1,proc2,proc3,proc4]-resp.id)) eq 0 then if novtest eq 0 then print,'An ROI border is defined multiple times in a single subgrid. Select each ROI border only once at most per subgrid.'
resp=widget_event(base)
if min(abs([quit1,quit2,quit3,quit4]-resp.id)) eq 0 then begin
widget_control,base,/destroy
return
end
if resp.id eq tabs1 then ubors(resp.value,i)=resp.select
if resp.id eq tabs2 then dbors(resp.value,i)=resp.select
if resp.id eq tabs3 then lbors(resp.value,i)=resp.select
if resp.id eq tabs4 then rbors(resp.value,i)=resp.select
if total(ubors(*,i)) ne 0 then if total(dbors(*,i)) ne 0 then if total(lbors(*,i)) ne 0 then if total(rbors(*,i)) ne 0 then prestest=1 else prestest=0
if max(ubors(*,i)+dbors(*,i)+lbors(*,i)+rbors(*,i)) le 1 then novtest=1 else novtest=0
end
widget_control,base,/destroy
end
schemedat=['Number of subgrids:',trim(nrgrids),'Annotation scheme:',pvolume,'ROIs to include:',wrrois,'x-dimension:',trim(xdim),'y-dimension(s):',ydim,'Polynomial order:',trim(porder),'Invert x-axis:',yn(axprocs(0)),'Transpose axes:',yn(axprocs(1))]
for i=0,nrgrids-1 do begin
schemedat=[schemedat,'subgrid-'+trim(i+1)+' upper border:',borders(where(ubors(*,i) eq 1))]
schemedat=[schemedat,'subgrid-'+trim(i+1)+' lower border:',borders(where(dbors(*,i) eq 1))]
schemedat=[schemedat,'subgrid-'+trim(i+1)+' left border:',borders(where(lbors(*,i) eq 1))]
schemedat=[schemedat,'subgrid-'+trim(i+1)+' right border:',borders(where(rbors(*,i) eq 1))]
end
schemefile='/test/.scheme'
spawn,'echo $CGRID_SCHEMEDIR',schemedir
if schemedir(0) eq '' then schemedir=surfdir
while file_basename(schemefile) eq '.scheme' do begin
schemefile=dialog_pickfile(/write,filter='*.scheme',path=schemedir,file='cgrid_'+patchcode+'.scheme',default_extension='scheme')
if schemefile eq '' then return
if file_basename(schemefile) eq '.scheme' then print,'Not a valid name for a schemefile.'
end
if file_test(file_dirname(schemefile)) eq 0 then spawn,'mkdir '+file_dirname(schemefile)
print,'Writing '+schemefile
write_ascii,schemefile,transpose(schemedat)
print,'Done'
print,'Finished'
end
