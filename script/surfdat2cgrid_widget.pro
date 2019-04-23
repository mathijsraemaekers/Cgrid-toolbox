pro surfdat2cgrid_widget
spawn,'echo $SUBJECTS_DIR',fsdir
opdir=''
surfdats=['volume','thickness','sulc']
cgridfiles=''
homtest=1
tmpdir=fsdir
while min(strpos(cgridfiles,'.cgrid')) eq -1 or min(file_test(cgridfiles)) eq 0 or n_elements(cgridfiles) gt 2 or homtest eq 0 do begin
cgridfiles=dialog_pickfile(/read,filter='*.cgrid',path=tmpdir,/multiple_files,title='Select 1 or 2 (homologue) Cgrid-file(s)')
tmpdir=file_dirname(cgridfiles(0))
if cgridfiles(0) eq '' then return
if min(strpos(cgridfiles,'.cgrid')) eq -1 then print,'Not all selected files are valid cgrid files. Only select a file with a .cgrid extension.'
if min(file_test(cgridfiles)) eq 0 then print,'Not all selected files exist.'
if n_elements(cgridfiles) gt 2 then print,'You can select only 1 or 2 (homologue) cgrid-files.'
cgridcodes=replace(replace(replace(file_basename(cgridfiles),'.cgrid',''),'lh_',''),'rh_','')
if n_elements(cgridfiles) eq 2 then begin
homtest=1
if cgridcodes(0) ne cgridcodes(1) then begin
print,'Selected Cgrid-files are not homologue'
homtest=0
end
end
end
print,'Selected Cgrid-files are:'
print,transpose(cgridfiles)
nrcgridfiles=n_elements(cgridfiles)
hems=['lh','rh']
subcode=replace(replace(file_dirname(cgridfiles(0)),fsdir+'/',''),'/surf','')
patchcode=replace(replace(replace(file_basename(cgridfiles(0)),'.cgrid',''),'lh_',''),'rh_','')
surfdir=fsdir+'/'+subcode+'/surf/'
base=widget_base(/row,title='Select which data to map to Cgrid')
proceed=widget_button(base,value='Proceed')
procbatch=widget_button(base,value='Proceed to multiple subject selection')
surfdats=['vertices','thickness','sulc','curv','curv.pial','avg_curv','volume','area','area.mid','area.pial']
nsuft=n_elements(surfdats)
signrev=intarr(nsuft)
surftest=intarr(nsuft)
mval=[0,0]
surfsel=cw_bgroup(base,surfdats,column=2,/nonexclusive,label_top='Surface data type(s) to transform to Cgrid',/frame)
mvals=cw_bgroup(base,['Fill in missing values','Reverse sign for curv/sulc'],/nonexclusive,set_value=mval)
dirsel=widget_button(base,value='Select output folder')
quit=widget_button(base,value='Quit')
widget_control,base,/realize
resp=widget_event(base,/nowait)
while min(abs([proceed,procbatch]-resp.id)) ne 0 or total(surftest) eq 0 do begin
resp=widget_event(base)
if resp.id eq surfsel then surftest(resp.value)=resp.select
if resp.id eq mvals then mval(resp.value)=resp.select
if min(abs([proceed,procbatch]-resp.id)) eq 0 then if total(surftest) eq 0 then print,'No surface data type selected. Select at least one surface data type'
if resp.id eq quit then begin
widget_control,base,/destroy
return
end
if resp.id eq dirsel then begin
opdir=dialog_pickfile(/read,title='Select a folder',/directory,dialog_parent=dirsel)
if opdir ne '' then if file_test(opdir) eq 0 then spawn,'mkdir '+opdir
print,'Output folder is '+opdir
end
end
if resp.id eq procbatch then bstart=1 else bstart=0
if mval(1) eq 1 then signrev([2,3,4,5])=1
widget_control,base,/destroy
if bstart eq 1 then begin
apfiles=''
print,'Searching for subjects with the same Cgrids'
for i=0,nrcgridfiles-1 do apfiles=[apfiles,file_search(fsdir,file_basename(cgridfiles(i)))]
print,'Done'
apfiles=apfiles(1:*)
apfiles=file_basename(file_dirname(file_dirname(apfiles)))
subs=''
for i=0,n_elements(apfiles)-1 do if n_elements(where(apfiles eq apfiles(i))) eq nrcgridfiles then subs=[subs,apfiles(i)]
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
if resp.id eq proceed then if total(subtest) eq 0 then print,'No subjects selected. Select at least one subject'
if resp.id eq quit then begin
widget_control,base,/destroy
return
end
end 
widget_control,base,/destroy
end else begin
subtest=1
subs=subcode
end
for z=0,n_elements(subs)-1 do  if subtest(z) eq 1 then begin
subcode=subs(z)
surfdir=fsdir+'/'+subcode+'/surf/'
if opdir eq '' then ropdir=surfdir else ropdir=opdir
tmpcgridfiles=cgridfiles
tmpcgridfiles=fsdir(0)+'/'+subcode+'/surf/'+file_basename(cgridfiles)
tmpcgriddat=read_ascii(tmpcgridfiles(0))
tmpcgriddat=tmpcgriddat.(0)
xdim=max(tmpcgriddat(1,*))
ydim=max(tmpcgriddat(2,*))
cgrids=create_struct(patchcode+'_'+trim(1),tmpcgriddat)
areas=create_struct('lh',read_fs_surfdat(surfdir+'lh.area.mid'))
areas=create_struct(areas,'rh',read_fs_surfdat(surfdir+'rh.area.mid'))
if nrcgridfiles gt 1 then for i=1,nrcgridfiles-1 do begin
tmpcgriddat=read_ascii(tmpcgridfiles(i))
tmpcgriddat=tmpcgriddat.(0)
tmpxdim=max(tmpcgriddat(1,*))
tmpydim=max(tmpcgriddat(2,*))
if tmpxdim gt xdim then xdim=tmpxdim
if tmpydim gt ydim then ydim=tmpydim
cgrids=create_struct(cgrids,patchcode+'_'+trim(i+1),tmpcgriddat)
end
nrverts=intarr(xdim,ydim,2)
for j=0,nrcgridfiles-1 do begin
cgrid=cgrids.(j)
hem=strmid(file_basename(tmpcgridfiles(j)),0,2)
sind=where(hems eq hem)
for k=0,xdim-1 do for l=0,ydim-1 do begin
inc=where(cgrid(1,*) eq k+1 and cgrid(2,*) eq l+1,/NULL)
if inc ne !NULL then nrverts(k,l,sind)=n_elements(inc)
end
end
for i=1,nsuft-1 do if surftest(i) eq 1 then begin
opdat=fltarr(xdim,ydim,2)
for j=0,nrcgridfiles-1 do begin
cgrid=cgrids.(j)
hem=strmid(file_basename(tmpcgridfiles(j)),0,2)
sind=where(hems eq hem)
area=areas.(sind)
surfdat=read_fs_surfdat(surfdir+hem+'.'+surfdats(i))
if signrev(i) eq 1 then surfdat=surfdat*(-1)
for k=0,xdim-1 do for l=0,ydim-1 do begin
inc=where(cgrid(1,*) eq k+1 and cgrid(2,*) eq l+1,/NULL)
if inc ne !NULL then begin
if i lt 6 then opdat(k,l,sind)=total(surfdat(cgrid(0,inc))*area(cgrid(0,inc))/total(area((cgrid(0,inc)))))
if i ge 6 then opdat(k,l,sind)=mean(surfdat(cgrid(0,inc)))
end
end
end
if mval(0) eq 1 then if i lt 6 then begin
tmpdat=fltarr(xdim+2,ydim+2,2)+!VALUES.F_NAN
tmpdat(1:xdim,1:ydim,*)=opdat
ztest=where(tmpdat eq 0,/NULL)
while ztest ne !NULL do begin
nrbl=n_elements(ztest)
fillvals=fltarr(nrbl)
cors=array_indices(tmpdat,ztest)
for k=0,nrbl-1 do begin 
incvals=tmpdat([cors(0,k)-1,cors(0,k)+1,cors(0,k),cors(0,k)],[cors(1,k),cors(1,k),cors(1,k)-1,cors(1,k)+1],intarr(4)+cors(2,k))
inctest=where(incvals ne 0,/NULL)
if inctest ne !NULL then begin
incvals=incvals(inctest)
fillvals(k)=mean(incvals,/NAN)
end
end
tmpdat(ztest(where(fillvals ne 0)))=fillvals(where(fillvals ne 0))
ztest=where(tmpdat eq 0,/NULL)
end
opdat=tmpdat(1:xdim,1:ydim,*)
end
if i ge 6 then opdat=opdat*nrverts
print,'Writing file '+ropdir+subcode+'_cgrid_'+patchcode+'_'+surfdats(i)+'.nii'
niihdrtool,ropdir+subcode+'_cgrid_'+patchcode+'_'+surfdats(i)+'.nii',fdata=opdat,srow_x4=-xdim/2.+0.5,srow_y4=-ydim/2.+0.5,srow_z4=-0.5
print,'Done'
end
if surftest(0) eq 1 then begin
print,'Writing file '+ropdir+subcode+'_cgrid_'+patchcode+'_'+surfdats(0)+'.nii'
niihdrtool,ropdir+subcode+'_cgrid_'+patchcode+'_'+surfdats(0)+'.nii',fdata=nrverts,srow_x4=-xdim/2.+0.5,srow_y4=-ydim/2.+0.5,srow_z4=-0.5
print,'Done'
end
end
print,'Finished'
end
