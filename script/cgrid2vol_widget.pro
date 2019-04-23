pro cgrid2vol_widget
spawn,'echo $SUBJECTS_DIR',fsdir
opfs=['.nii','.nii.gz','.mgh','.mgz','.brik','.img']
methods=['abs','frac']
method='frac'
parms=[0.,1.,0.1]
opdir=0
opf=0
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
nrgrids=n_elements(cgridfiles)
hems=strarr(nrgrids)
hems(where(strpos(file_basename(cgridfiles),'lh_') ne -1))='lh'
hems(where(strpos(file_basename(cgridfiles),'rh_') ne -1))='rh'
patchcode=replace(replace(replace(file_basename(cgridfiles(0)),'.cgrid',''),'lh_',''),'rh_','')
subcode=replace(replace(file_dirname(cgridfiles(0)),fsdir+'/',''),'/surf','')
base=widget_base(/row,title='Provide parameters for generating the output')
proceed=widget_button(base,value='Proceed')
procbatch=widget_button(base,value='Proceed to multiple subject selection')
opfsel=cw_bgroup(base,opfs,/column,/exclusive,label_top='Output format',set_value=opf)
methodsel=cw_bgroup(base,['Absolute(mm)','Fractional'],/column,/exclusive,label_top='Projection Method',set_value=1)
startsel=cw_field(base,title='Start',/all_events,/float,value=parms(0))
endsel=cw_field(base,title='Stop',/all_events,/float,value=parms(1))
deltasel=cw_field(base,title='Delta',/all_events,/float,value=parms(2))
dirsel=widget_button(base,value='Select output folder')
quit=widget_button(base,value='Quit')
ext=opfs(opf)
resp=widget_event(base,/nowait)
widget_control,base,/realize
while min(abs([proceed,procbatch]-resp.id)) ne 0 or parms(2) le 0 or parms(0) gt parms(1) do begin
resp=widget_event(base)
if resp.id eq dirsel then begin
opdir=dialog_pickfile(/read,title='Select a folder',/directory,dialog_parent=dirsel)
if opdir ne '' then if file_test(opdir) eq 0 then spawn,'mkdir '+opdir
print,'Output folder is '+opdir
end
if resp.id eq opfsel then ext=opfs(resp.select)
if resp.id eq methodsel then method=methods(resp.select)
if resp.id eq startsel then parms(0)=resp.value
if resp.id eq endsel then parms(1)=resp.value
if resp.id eq deltasel then parms(2)=resp.value
if min(abs([proceed,procbatch]-resp.id)) eq 0 then if parms(2) le 0 then print,'Delta should be larger than 0'
if min(abs([proceed,procbatch]-resp.id)) eq 0 then if parms(0) gt parms(1) then print,'Start must be larger or equal to stop''
if resp.id eq quit then begin
widget_control,base,/destroy
return
end
end
if resp.id eq procbatch then bstart=1 else bstart=0
widget_control,base,/destroy
if bstart eq 1 then begin
apfiles=''
print,'Searching for subjects with the same CGRIDs'
for i=0,nrgrids-1 do apfiles=[apfiles,file_search(fsdir,file_basename(cgridfiles(i)))]
print,'Done'
apfiles=apfiles(1:*)
apfiles=file_basename(file_dirname(file_dirname(apfiles)))
subs=''
for i=0,n_elements(apfiles)-1 do if n_elements(where(apfiles eq apfiles(i))) eq nrgrids then subs=[subs,apfiles(i)]
subs=subs(1:*)
subs=subs(sort(subs))
subs=subs(uniq(subs))
subtest=intarr(n_elements(subs))
subtest(where(subs eq subcode))=1
base=widget_base(/row,title='Select subjects to include')
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
subs=subcode
subtest=1
end
for i=0,n_elements(subs)-1 do if subtest(i) eq 1 then for j=0,nrgrids-1 do cgrid2vol,fsdir+'/'+subs(i)+'/surf/'+hems(j)+'_'+patchcode+'.cgrid',ext=ext,opdir=opdir,parms=parms,method=method
print,'Finished'
end
