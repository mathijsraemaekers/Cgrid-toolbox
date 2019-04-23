pro vol2cgrid_widget
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
base=widget_base(/row,title='Select mapping algorithm',xsize=250)
proceed=widget_button(base,value='Proceed')
methods=['projfrac','projfrac-avg','projfrac-max','projdist','projdist-avg','projdist-max']
mapsel=cw_bgroup(base,methods,/column,/exclusive,label_top='Mapping Algorithm',set_value=0)
quit=widget_button(base,value='Quit')
resp=widget_event(base,/nowait)
widget_control,base,/realize
method=0
val2=''
val3=''
while resp.id ne proceed do begin
resp=widget_event(base)
if resp.id eq mapsel then method=resp.value
if resp.id eq quit then begin
widget_control,base,/destroy
return
end
end
widget_control,base,/destroy
if method eq 0 then begin
val1=' '+trim(0.5)
base=widget_base(/row,title='Provide algorithm details')
proceed=widget_button(base,value='Proceed')
a=cw_field(base,title='Fraction',/all_events,/float,value=0.5)
quit=widget_button(base,value='Quit')
resp=widget_event(base,/nowait)
widget_control,base,/realize
while resp.id ne proceed do begin
resp=widget_event(base)
if resp.id eq a then val1=trim(resp.value)
if resp.id eq quit then begin
widget_control,base,/destroy
return
end
end
widget_control,base,/destroy
end
if method eq 1 or method eq 2 then begin
val1=trim(0.0)
val2=' '+trim(1.0)
val3=' '+trim(0.1)
base=widget_base(/row,title='Provide algorithm details')
proceed=widget_button(base,value='Proceed')
a=cw_field(base,title='Min frac',/all_events,/float,value=0.0)
b=cw_field(base,title='Max frac',/all_events,/float,value=1.0)
c=cw_field(base,title='Stepsize',/all_events,/float,value=0.1)
quit=widget_button(base,value='Quit')
resp=widget_event(base,/nowait)
widget_control,base,/realize
while resp.id ne proceed or float(trim(val3)) le 0 do begin
resp=widget_event(base)
if resp.id eq a then val1=trim(resp.value)
if resp.id eq b then val2=' '+trim(resp.value)
if resp.id eq c then val3=' '+trim(resp.value)
if resp.id eq proceed then if float(trim(val3)) le 0 then print,'The stepsize should be bigger than 0.'
if resp.id eq quit then begin
widget_control,base,/destroy
return
end
end
widget_control,base,/destroy
end
if method eq 3 then begin
val1=trim(1.5)
base=widget_base(/row,title='Provide algorithm details')
proceed=widget_button(base,value='Proceed')
a=cw_field(base,title='Distance(mm)',/all_events,/float,value=1.5)
quit=widget_button(base,value='Quit')
resp=widget_event(base,/nowait)
widget_control,base,/realize
while resp.id ne proceed do begin
resp=widget_event(base)
if resp.id eq a then val1=trim(resp.value)
if resp.id eq quit then begin
widget_control,base,/destroy
return
end
end
widget_control,base,/destroy
end
if method eq 4 or method eq 5 then begin
val1=trim(0.0)
val2=' '+trim(3.0)
val3=' '+trim(10)
base=widget_base(/row,title='Provide algorithm details')
proceed=widget_button(base,value='Proceed')
a=cw_field(base,title='Min dist(mm)',/all_events,/float,value=0.0)
b=cw_field(base,title='Max dist(mm)',/all_events,/float,value=3.0)
c=cw_field(base,title='Stepsize(mm)',/all_events,/integer,value=0.3)
quit=widget_button(base,value='Quit')
resp=widget_event(base,/nowait)
widget_control,base,/realize
while resp.id ne proceed or float(trim(val3)) le 0 do begin
resp=widget_event(base)
if resp.id eq a then val1=trim(resp.value)
if resp.id eq b then val2=' '+trim(resp.value)
if resp.id eq c then val3=' '+trim(resp.value)
if resp.id eq proceed then if float(trim(val3)) le 0 then print,'The stepsize should be bigger than 0.'
if resp.id eq quit then begin
widget_control,base,/destroy
return
end
end
widget_control,base,/destroy
end
sk=6.
base=widget_base(/row,title='Additional settings for mapping')
proceed=widget_button(base,value='Proceed')
procbatch=widget_button(base,value='Proceed to multiple subject selection')
smsel=cw_field(base,title='Smoothing kernel',/all_events,/float,value=sk)
mvals=cw_bgroup(base,'Fill in missing values',/nonexclusive,set_value=mval)
quit=widget_button(base,value='Quit')
resp=widget_event(base,/nowait)
widget_control,base,/realize
while min(abs([proceed,procbatch]-resp.id)) ne 0 or sk lt 0 do begin
resp=widget_event(base)
if resp.id eq smsel then sk=resp.value
if min(abs([proceed,procbatch]-resp.id)) eq 0 then if sk lt 0 then print,'Smoothing kernel must be bigger than 0'
if resp.id eq mvals then mval=resp.select
if resp.id eq procbatch then bstart=1 else bstart=0
if resp.id eq quit then begin
widget_control,base,/destroy
return
end
end
widget_control,base,/destroy
flag='--'+methods(method)+' '+val1+val2+val3
if sk ne 0 then flag=flag+' --surf-fwhm '+trim(sk)
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
while min(strpos(file_basename(niifile),'.nii')) eq -1 or min(file_test(niifile)) eq 0 do begin
niifile=dialog_pickfile(/read,filter='*.nii',path=curdir(0),/multiple_files,title='Please select the nifti file(s) '+trim(i+1)+'/'+trim(nrfiles(subnr)))
if min(file_test(niifile)) eq 0 then print,'Not all selected files exist.'
if min(strpos(file_basename(niifile),'.nii')) eq -1 then print,'Not all selected files are nifti files.'
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
vol2cgrid,filestruct.(i),tmpcgridfiles,flag=flag,mval=mval
end
print,'Finished'
end
