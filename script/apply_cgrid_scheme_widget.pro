pro apply_cgrid_scheme_widget
spawn,'echo $SUBJECTS_DIR',fsdir
spawn,'echo $CGRID_SCHEMEDIR',schemedir
if schemedir(0) eq '' then schemedir=fsdir
schemefile=''
patchfiles=''
homtest=1
while strpos(schemefile,'.scheme') eq -1 or file_test(schemefile) eq 0 do begin
schemefile=dialog_pickfile(/read,filter='*.scheme',path=schemedir,title='Select a Cgrid scheme file')
if schemefile eq '' then return
if strpos(schemefile,'.scheme') eq -1 then print,'No valid schemefile selected. Select a file with a .scheme extension.'
if file_test(schemefile) eq 0 then print,'The selected file does not exist.'
end
read_ascii_string,schemefile,scheme
print,'Selected patches should include '+scheme(5)+' of the '+scheme(3)+' annotation.'
seldir=fsdir
while max(strpos(patchfiles,'_flat.3d')) eq -1 or min(file_test(patchfiles)) eq 0 or n_elements(patchfiles) gt 2 or homtest eq 0 do begin
patchfiles=dialog_pickfile(/read,filter='*_flat.3d',path=seldir,/multiple_files,title='Select 1 patch or 2 (homologue) patchfile(s) for Cgrid input')
if patchfiles(0) eq '' then return
if max(strpos(patchfiles,'_flat.3d')) eq -1 then print,'Selected file is not a patchfile. Select a file with a _flat.3d extension.'
if min(file_test(patchfiles)) eq 0 then print,'At least one of the selected patchfiles does not exist.'
if n_elements(patchfiles) gt 2 then print,'You can only select 1 or 2 (homologue) patchfiles.'
patchcodes=replace(replace(replace(file_basename(patchfiles),'_flat.3d',''),'lh.',''),'rh.','')
if n_elements(patchfiles) eq 2 then begin
homtest=1
if patchcodes(0) ne patchcodes(1) then begin
print,'Selected patchfiles are not homologue'
homtest=0
end
end
if file_dirname(patchfiles(0)) ne '' then seldir=file_dirname(patchfiles(0))
end
print,'Selected patchfiles are:'
print,transpose(patchfiles)
patchcode=replace(replace(replace(file_basename(patchfiles(0)),'_flat.3d',''),'lh.',''),'rh.','')
subcode=replace(replace(file_dirname(patchfiles(0)),fsdir+'/',''),'/surf','')
disptypes=['Pict tiles per subgrid','Pict vertex classification per subgrid','Pict subgrid borders','Pict subgrid border extensions','Pict Cgrid on surface','Pict Cgrid vertex classification on surface','Fit quality report']
surfview=['top','bottem','medial','lateral','front','back']
hems=['lh','rh']
veqs=strarr(2,6)
veqs(0,*)=['top','bottem','right','left','front','back']
veqs(1,*)=['top','bottem','left','right','front','back']
surftype=['pial','white','inflated']
dispsel=intarr(7)
viewinc=intarr(6)
surfinc=intarr(3)
viewinc(3)=1
surfinc(2)=1
drtres=10.
clustres=.8
opdir=''
poltype=0
sk=2
base=widget_base(/row,title='Options for Cgrid generation')
proceed=widget_button(base,value='Proceed')
procbatch=widget_button(base,value='Proceed to multiple subject selection')
polsel=cw_bgroup(base,['2 polynomials','4 polynomials'],/column,/exclusive,label_top='Type of fitting',set_value=poltype)
sbase=widget_base(base,/column)
drtress=cw_field(sbase,title='Distance threshold      ',/all_events,/float,value=drtres)
clustress=cw_field(sbase,title='Min main cluster size(p)',/all_events,/float,value=clustres)
sks=cw_field(sbase,title='L/R border smoothing    ',/all_events,/float,value=sk)
disps=cw_bgroup(base,disptypes,/column,/nonexclusive,label_top='Things to store for inspection of results')
surfvsel=cw_bgroup(base,surfview,/column,/nonexclusive,label_top='View direction(s)',/frame,set_value=viewinc)
surftsel=cw_bgroup(base,surftype,/column,/nonexclusive,label_top='Surface type(s)',/frame,set_value=surfinc)
dirsel=widget_button(base,value='Select report output folder')
quit=widget_button(base,value='Quit')
vsel=3
ssel=2
resp=widget_event(base,/nowait)
widget_control,base,/realize
while min(abs([resp.id-proceed,resp.id-procbatch])) ne 0 or drtres le 0 or sk lt 0 or clustres lt 0 or clustres gt 1 do begin
resp=widget_event(base)
if resp.id eq disps then dispsel(resp.value)=resp.select
if resp.id eq surfvsel then viewinc(resp.value)=resp.select
if resp.id eq surftsel then surfinc(resp.value)=resp.select
if resp.id eq polsel then poltype=resp.select
if resp.id eq drtress then drtres=resp.value
if resp.id eq clustress then clustres=resp.value
if resp.id eq sks then sk=resp.value
if min(abs([resp.id-proceed,resp.id-procbatch])) eq 0 then if drtres le 0 then print,'The distance threshold should be larger than 0'
if min(abs([resp.id-proceed,resp.id-procbatch])) eq 0 then if sk lt 0 then print,'The smoothing kernel should be bigger than or equal to 0'
if min(abs([resp.id-proceed,resp.id-procbatch])) eq 0 then if clustres lt 0 then print,'The proportional minumum cluster size should be bigger than 0'
if min(abs([resp.id-proceed,resp.id-procbatch])) eq 0 then if clustres gt 1 then print,'The proportional minumum cluster size should be smaller than 0'
if resp.id eq quit then begin
widget_control,base,/destroy
return
end
if resp.id eq dirsel then begin
opdir=dialog_pickfile(/read,title='Select a folder',/directory,dialog_parent=dirsel)
if opdir ne '' then if file_test(opdir) eq 0 then spawn,'mkdir '+opdir
print,'Report output folder is '+opdir
end
end
if resp.id eq procbatch then bstart=1 else bstart=0
widget_control,base,/destroy
if bstart eq 1 then begin
apfiles=''
print,'Searching for subjects with the same patches'
for i=0,n_elements(patchfiles)-1 do apfiles=[apfiles,file_search(fsdir,file_basename(patchfiles(i)))]
print,'Done'
apfiles=apfiles(1:*)
apfiles=file_basename(file_dirname(file_dirname(apfiles)))
subs=''
for i=0,n_elements(apfiles)-1 do if n_elements(where(apfiles eq apfiles(i))) eq n_elements(patchfiles) then subs=[subs,apfiles(i)]
subs=subs(1:*)
subs=subs(sort(subs))
subs=subs(uniq(subs))
subtest=intarr(n_elements(subs))
subtest(where(subs eq subcode))=1
base=widget_base(/row)
proceed=widget_button(base,value='Proceed')
subsel=cw_bgroup(base,subs,column=8,/nonexclusive,label_top='Subjects to include',/frame,set_value=subtest)
quit=widget_button(base,value='Quit')
resp=widget_event(base,/nowait)
widget_control,base,/realize
while resp.id ne proceed or total(subtest) eq 0 do begin
resp=widget_event(base)
if resp.id eq subsel then subtest(resp.value)=resp.select
if resp.id eq proceed then if total(subtest) eq 0 then print,'No subjects selected. Choose at least one subject.'
if resp.id eq quit then begin
widget_control,base,/destroy
return
end
end 
widget_control,base,/destroy
end else begin
subs=subcode
subtest=1
end
scheme=[[scheme],[transpose(strarr(1)+':')]]
nrgrids=fix(scheme(1))
annot=scheme(3)
xdim=fix(scheme(7))
ydim=stringdiv(scheme(9))
if n_elements(ydim) eq 1 then ydim=intarr(nrgrids)+ydim(0)
yadds=intarr(nrgrids)
for i=1,nrgrids-1 do yadds(i)=total(ydim(0:i-1))
porder=fix(scheme(11))
xinv=scheme(13)
transax=scheme(15)
if transax eq 'no' then wrax=['y','x']
if transax eq 'yes' then wrax=['x','y']
ind=where(strpos(scheme,':') ne -1)
ind=ind(8:*)+1
for z=0,n_elements(subs)-1 do if subtest(z) eq 1 then begin 
treport=''
treport=[treport,'Method: '+trim((poltype+1)*2)+' polynomial approach']
if poltype eq 0 then treport=[treport,'LR-border smoothing kernel: '+trim(sk)]
treport=[treport,'Min main cluster size(p): '+trim(clustres)]
treport=[treport,'Distance threshold: '+trim(drtres)]
for k=0,n_elements(patchfiles)-1 do begin
subcode=subs(z)
surfdir=fsdir+'/'+subcode+'/surf/'
if opdir eq '' then ropdir=surfdir else ropdir=opdir
patchfile=surfdir+file_basename(patchfiles(k))
cgrid=lonarr(3)
hem=strmid(file_basename(patchfile),0,2)
heminc=where(hems eq hem)
borinfo=find_paint_borders_tmp(subcode,hem,annot,patchfile=patchfile)
btags=tag_names(borinfo)
tmpscheme=scheme
for i=0,n_elements(btags)-1 do tmpscheme(where(scheme eq btags(i),/NULL))=trim(i)
for i=0,nrgrids-1 do begin
uborp=tmpscheme(ind(i*4+0):ind(i*4+1)-2)
dborp=tmpscheme(ind(i*4+1):ind(i*4+2)-2)
lborp=tmpscheme(ind(i*4+2):ind(i*4+3)-2)
rborp=tmpscheme(ind(i*4+3):ind(i*4+4)-2)
uborp=uborp(where(strlen(uborp) lt 4,/NULL))
dborp=dborp(where(strlen(dborp) lt 4,/NULL))
lborp=lborp(where(strlen(lborp) lt 4,/NULL))
rborp=rborp(where(strlen(rborp) lt 4,/NULL))
if uborp eq !NULL or dborp eq !NULL or lborp eq !NULL or rborp eq !NULL then begin
print,'Not all relevant borders detected, skipping subgrid-'+trim(i+1)
treport=[treport,'subgrid-'+trim(i+1)+'-'+hem+' mean fit quality: subgrid failed as not all borders were detected']
treport=[treport,'subgrid-'+trim(i+1)+'-'+hem+' worst fit quality: subgrid failed as not all borders were detected']
end else begin
ubor=lonarr(2)
for j=0,n_elements(uborp)-1 do ubor=[[ubor],[remove_islands(borinfo.(uborp(j)),tres=clustres)]]
ubor=ubor(*,1:*)
dbor=lonarr(2)
for j=0,n_elements(dborp)-1 do dbor=[[dbor],[remove_islands(borinfo.(dborp(j)),tres=clustres)]]
dbor=dbor(*,1:*)
lbor=lonarr(2)
for j=0,n_elements(lborp)-1 do lbor=[[lbor],[remove_islands(borinfo.(lborp(j)),tres=clustres)]]
lbor=lbor(*,1:*)
rbor=lonarr(2)
for j=0,n_elements(rborp)-1 do rbor=[[rbor],[remove_islands(borinfo.(rborp(j)),tres=clustres)]]
rbor=rbor(*,1:*)
if hem eq 'rh' then begin
tmplbor=lbor
lbor=rbor
rbor=tmplbor
end
if min([n_elements(lbor),n_elements(rbor),n_elements(ubor),n_elements(dbor)]) lt 6 then begin
print,'Too few coordinates detected in one of the borders (<3), skipping subgrid-'+trim(i+1)
treport=[treport,'subgrid-'+trim(i+1)+'-'+hem+' mean fit quality: subgrid failed as one border had too few coordinates']
treport=[treport,'subgrid-'+trim(i+1)+'-'+hem+' worst fit quality: subgrid failed as one border had too few coordinates']
end else begin
if dispsel(0) eq 1 then disp=ropdir+subcode+'_'+hem+'_'+patchcode+'_subgrid'+trim(i+1) else disp=0
if dispsel(1) eq 1 then de=ropdir+subcode+'_'+hem+'_'+patchcode+'_subgrid'+trim(i+1) else de=0
if dispsel(2) eq 1 then idisp=ropdir+subcode+'_'+hem+'_'+patchcode+'_subgrid'+trim(i+1)+'_border_configuration' else idisp=0
if dispsel(3) eq 1 then edisp=ropdir+subcode+'_'+hem+'_'+patchcode+'_subgrid'+trim(i+1)+'_border_extensions' else edisp=0
if poltype eq 0 then tmpcgrid=cgrid_gen(patchfile,ubor,dbor,lbor,rbor,xdim,ydim(i),porder=porder,disp=disp,de=de,idisp=idisp,edisp=edisp,ptitle='subgrid-'+trim(i+1)+' '+patchcode,mse=qual,dptres=drtres,sk=sk)
if poltype eq 1 then tmpcgrid=cgrid_gen_4pol(patchfile,ubor,dbor,lbor,rbor,xdim,ydim(i),porder=porder,disp=disp,de=de,idisp=idisp,edisp=edisp,ptitle='subgrid-'+trim(i+1)+' '+patchcode,mset=qual,dptres=drtres)
treport=[treport,'subgrid-'+trim(i+1)+'-'+hem+' mean fit quality:'+trim(qual(0))]
treport=[treport,'subgrid-'+trim(i+1)+'-'+hem+' worst fit quality:'+trim(qual(1))]
if max(tmpcgrid) ne 0 then begin
tmpcgrid(2,*)=tmpcgrid(2,*)+yadds(i)
if xinv eq 'no' then if hem eq 'rh' then tmpcgrid(1,*)=tmpcgrid(1,*)*(-1)+xdim
if xinv eq 'yes' then if hem eq 'lh' then tmpcgrid(1,*)=tmpcgrid(1,*)*(-1)+xdim
cgrid=[[cgrid],[tmpcgrid]]
end
end
end
end
if n_elements(cgrid) ne 3 then begin
cgrid=cgrid(*,1:*)
if max(dispsel(4:5)) eq 1 then for q=0,2 do if surfinc(q) eq 1 then begin
surfdat=read_fs_surface(surfdir+hem+'.'+surftype(q))
if dispsel(4) eq 1 then begin
vmap=intarr(n_elements(surfdat.COORDINATES)/4)
for l=0,total(ydim)-1 do for n=0,xdim-1 do if stddev([l,n] mod 2) eq 0 then vmap(cgrid(0,where(cgrid(1,*) eq n+1 and cgrid(2,*) eq l+1,/NULL)))=2 else vmap(cgrid(0,where(cgrid(1,*) eq n+1 and cgrid(2,*) eq l+1,/NULL)))=3
load_surface_ct
for r=0,5 do if viewinc(r) eq 1 then begin
disp_surface,surfdat.COORDINATES,surfdat.TOPOLOGY,view=veqs(heminc(0),r),vmap=vmap,size=800,winnr=k
picname=ropdir+subcode+'_'+hem+'_'+patchcode+'_cgrid_surface_'+surftype(q)+'_'+surfview(r)+'.png'
print,'Writing '+picname
write_png,picname,tvrd(/true)
print,'Done'
wdelete,k
end
loadct,0
end
if dispsel(5) eq 1 then begin
vmap=fltarr(n_elements(surfdat.COORDINATES)/4)
for l=0,total(ydim)-1 do vmap(cgrid(0,where(cgrid(2,*) eq l+1,/NULL)))=l+1
for r=0,5 do if viewinc(r) eq 1 then begin
disp_surface,surfdat.COORDINATES,surfdat.TOPOLOGY,view=veqs(heminc(0),r),overlay=vmap,size=800,winnr=k+2,thresshold=0.5
picname=ropdir+subcode+'_'+hem+'_'+patchcode+'_cgrid_surface_'+surftype(q)+'_'+surfview(r)+'_'+wrax(0)+'class.png'
print,'Writing '+picname
write_png,picname,tvrd(/true)
print,'Done'
wdelete,k+2
end
vmap=fltarr(n_elements(surfdat.COORDINATES)/4)
for l=0,xdim-1 do vmap(cgrid(0,where(cgrid(1,*) eq l+1,/NULL)))=l+1
for r=0,5 do if viewinc(r) eq 1 then begin
disp_surface,surfdat.COORDINATES,surfdat.TOPOLOGY,view=veqs(heminc(0),r),overlay=vmap,size=800,winnr=k+4,thresshold=0.5
picname=ropdir+subcode+'_'+hem+'_'+patchcode+'_cgrid_surface_'+surftype(q)+'_'+surfview(r)+'_'+wrax(1)+'class.png'
print,'Writing '+picname
write_png,picname,tvrd(/true)
print,'Done'
wdelete,k+4
end
end
end
if transax eq 'yes' then cgrid=cgrid([0,2,1],*)
wrfile=file_dirname(patchfile)+'/'+hem+'_'+patchcode+'.cgrid'
print,'Writing '+wrfile
write_ascii,wrfile,trim(cgrid)
print,'Done'
end else print,'Print no Cgrid file stored for '+patchfile+' as no valid borders could be detected for any of the subgrids'
end
if dispsel(6) eq 1 then if n_elements(treport) gt 1 then begin
write_ascii,ropdir+subcode+'_'+patchcode+'_cgrid_report.txt',transpose(treport(1:*))
end
end
print,'Finished'
end
