pro mgh2cgrid_widget
spawn,'echo $SUBJECTS_DIR',fsdir
spawn,'pwd',curdir
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
mval=0
nrgrids=n_elements(cgridfiles)
subcode=replace(replace(file_dirname(cgridfiles(0)),fsdir+'/',''),'/surf','')
base=widget_base(/row,title='Additional settings for mapping')
proceed=widget_button(base,value='Proceed')
procbatch=widget_button(base,value='Proceed to multiple subject selection')
mvals=cw_bgroup(base,'Fill in missing values',/nonexclusive,set_value=mval)
quit=widget_button(base,value='Quit')
resp=widget_event(base,/nowait)
widget_control,base,/realize
while min(abs([proceed,procbatch]-resp.id)) ne 0 do begin
resp=widget_event(base)
if resp.id eq mvals then mval=resp.select
if resp.id eq procbatch then bstart=1 else bstart=0
if resp.id eq quit then begin
widget_control,base,/destroy
return
end
end
widget_control,base,/destroy
if bstart eq 1 then begin
apfiles=''
print,'Searching for subjects with the same Cgrid-files'
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
base=widget_base(/row,title='Choose subjects to include')
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
subs=subs(where(subtest eq 1))
end else subs=subcode
nrsub=n_elements(subs)
subtags='field'+trim(indgen(nrsub))
nrfiles=intarr(nrsub)+1
filestruct=create_struct('subject','files')
base=widget_base(/row,title='Choose files to map to Cgrid')
proceed=widget_button(base,value='Proceed')
form1=cw_form(base,trim(intarr(nrsub))+',INTEGER,1,LABEL_LEFT=Number of file folders '+subs,/column,title='Number of folders per subject')
form2=cw_form(base,trim(intarr(nrsub))+',BUTTON,Select files '+subs,/column,title='Number of folders per subject')
quit=widget_button(base,value='Quit')
resp=widget_event(base,/nowait)
widget_control,base,/realize
while resp.id ne proceed do begin
resp=widget_event(base)
if resp.id eq quit then begin
widget_control,base,/destroy
return
end
if resp.id-base eq form1-base then nrfiles(fix(replace(resp.TAG,'TAG','')))=resp.value
if resp.id-base eq form2-base then if nrfiles(fix(replace(resp.TAG,'TAG',''))) lt 1 then print,'Number of files should be 1 or more.'
if resp.id-base eq form2-base then if nrfiles(fix(replace(resp.TAG,'TAG',''))) ge 1 then begin
subnr=fix(replace(resp.TAG,'TAG',''))
if tag_exist(filestruct,strupcase(subtags(subnr))) then struct_delete_field,filestruct,strupcase(subtags(subnr))
for i=0,nrfiles(subnr)-1 do begin
if i eq 0 then niifiles=''
niifile=''
while min(strpos(file_basename(niifile),'.mgh')) eq -1 or min(file_test(niifile)) eq 0 do begin
niifile=dialog_pickfile(/read,filter='*.mgh',path=curdir(0),/multiple_files,title='Please select the nifti file(s) '+trim(i+1)+'/'+trim(nrfiles(subnr)))
if min(file_test(niifile)) eq 0 then print,'Not all selected files exist.'
if min(strpos(file_basename(niifile),'.mgh')) eq -1 then print,'Not all selected files are mgh files.'
end
curdir=file_dirname(niifile)
niifiles=[niifiles,niifile]
end
niifiles=niifiles(1:*)
filestruct=create_struct(filestruct,subtags(subnr),niifiles)
end
end
widget_control,base,/destroy
tags=tag_names(filestruct)
nrtags=n_elements(tags)
if nrtags ne 1 then for i=1,nrtags-1 do begin
subcode=subs(where(strupcase(subtags) eq tags(i)))
tmpcgridfiles=strarr(nrgrids)+fsdir(0)+'/'+subcode(0)+'/surf/'+file_basename(cgridfiles)
mgh2cgrid,filestruct.(i),tmpcgridfiles,mval=mval
end
print,'Finished'
end
