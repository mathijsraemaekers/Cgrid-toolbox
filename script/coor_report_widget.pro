pro coor_report_widget
niioutput=0
outputfile='/test/.txt'
spawn,'echo $SUBJECTS_DIR',fsdir
coorfile=''
while file_test(coorfile,/regular) eq 0 or strpos(coorfile,'.txt') eq -1 do begin
coorfile=dialog_pickfile(/read,filter='*.txt',path=fsdir,title='Please select ascii file with coordinates')
if coorfile eq '' then return
if file_test(coorfile,/regular) eq 0 then print,'The file does not exist exist.'
if file_test(coorfile,/regular) eq 1 then if strpos(coorfile,'.txt') eq -1 then print,'The selected file is not an ascii (txt) file.'
end
print,'The chosen coordinate file is '+coorfile
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
cgridcode=replace(replace(replace(file_basename(cgridfiles(0)),'.cgrid',''),'lh_',''),'rh_','')
print,'Selected Cgrid-files are:'
print,transpose(cgridfiles)
subcode=replace(replace(file_dirname(cgridfiles(0)),fsdir+'/',''),'/surf','')
labeldir=fsdir+'/'+subcode+'/label/'
surfdir=fsdir+'/'+subcode+'/surf/'
annots=replace(replace(file_basename(file_search(labeldir+'lh.*.annot')),'lh.',''),'.annot','')
atest=intarr(n_elements(annots))
if atest eq !NULL then atest=0
base=widget_base(/row,title='Select additional data to store')
proceed=widget_button(base,value='Proceed')
niisel=cw_bgroup(base,'Store Cgrid nifti',/nonexclusive,set_value=niihoutput)
annotsel=cw_bgroup(base,annots,/nonexclusive,/column,label_top='Annotation scheme',set_value=atest)
quit=widget_button(base,value='Quit')
resp=widget_event(base,/nowait)
widget_control,base,/realize
while resp.id ne proceed do begin
resp=widget_event(base)
if resp.id eq annotsel then atest(resp.value)=resp.select
if resp.id eq niisel then niioutput=resp.select
if resp.id eq quit then begin
widget_control,base,/destroy
return
end
end
widget_control,base,/destroy
annotinc=where(atest ne 0,/NULL)
if annotinc ne !NULL then annots=annots(annotinc) else annots=0
outputfile=''
while outputfile eq '' or strpos(outputfile,'.txt') eq -1 do begin
outputfile=dialog_pickfile(/write,file=replace(file_basename(coorfile),'.txt','')+'_'+cgridcode+'.txt',filter='*.txt',path=file_dirname(coorfile),title='Define name of the output file',default_extension='.txt')
if strpos(outputfile,'.txt') eq -1 then print,'Not a valid name for the output file.'
if outputfile(0) eq '' then return
end
print,'The output file is '+coorfile
coor_report,coorfile,cgridfiles,outputfile,annots=annots,niioutput=niioutput
end
