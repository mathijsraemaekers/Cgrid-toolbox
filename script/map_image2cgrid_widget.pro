pro map_image2cgrid_widget
spawn,'echo $SUBJECTS_DIR',fsdir
cgridfile=''
imgfile=''
tmpdir=fsdir
imgfilt=['.jpg', '.tif', '.png']
mins=1
maxs=10
while strpos(cgridfile,'.cgrid') eq -1 or file_test(cgridfile) eq 0 do begin
cgridfile=dialog_pickfile(/read,filter='*.cgrid',path=tmpdir,title='Select a Cgrid-file')
tmpdir=file_dirname(cgridfile)
if cgridfile eq '' then return
if strpos(cgridfile,'.cgrid') eq -1 then print,'The selected file is not a valid cgrid file. Only select a file with a .cgrid extension.'
if file_test(cgridfile) eq 0 then print,'The file does not exist.'
end
print,'Selected Cgrid-file is '+cgridfile
cgridcode=replace(replace(replace(file_basename(cgridfile),'.cgrid',''),'lh_',''),'rh_','')
hemcode=strmid(file_basename(cgridfile),0,2)
while strpos(imgfile,imgfilt(0))+strpos(imgfile,imgfilt(1))+strpos(imgfile,imgfilt(2)) eq -3 or file_test(imgfile) eq 0 do begin
imgfile=dialog_pickfile(/read,path=tmpdir,title='Select a jpg/tif/png file')
tmpdir=file_dirname(imgfile)
if imgfile eq '' then return
if strpos(imgfile,imgfilt(0))+strpos(imgfile,imgfilt(1))+strpos(imgfile,imgfilt(2)) eq -3 then print,'The selected file is not a valid image file. Only select a file with a jpg/tif/png extension.'
if file_test(imgfile) eq 0 then print,'The file does not exist.'
end
erlog=intarr(1)
ermes=strarr(n_elements(erlog))
ermes(0)='The minimum should be smaller than the maximum'
base=widget_base(/row,title='Image scaling')
quit=widget_button(base,value='Quit')
tbase=widget_base(base,/column)
minss=cw_field(tbase,title='Minimum',/all_events,/float,value=mins)
maxss=cw_field(tbase,title='Maximum',/all_events,/float,value=maxs)
proceed=widget_button(base,value='Proceed')
widget_control,base,/realize
resp=widget_event(base,/nowait)
while resp.id ne proceed or max(erlog) ne 0 do begin
resp=widget_event(base)
if resp.id eq quit then begin
widget_control,base,/destroy
return
end
if resp.id eq minss then mins=resp.value
if resp.id eq maxss then maxs=resp.value
erlog(*)=0
if mins ge maxs then erlog(0)=1
if resp.id eq proceed then if total(erlog) ne 0 then print,transpose(['Error:',ermes(where(erlog eq 1))])
end
widget_control,base,/destroy
print,'Selected image-file is '+imgfile
outputfile=''
while outputfile eq '' or strpos(outputfile,'.mgh') eq -1 do begin
outputfile=dialog_pickfile(/write,file=hemcode+'_'+strmid(file_basename(imgfile),0,strlen(file_basename(imgfile))-4)+'_'+cgridcode+'.mgh',filter='*.mgh',path=file_dirname(imgfile),title='Define name of the output file',default_extension='.mgh')
if strpos(outputfile,'.mgh') eq -1 then print,'Not a valid name for the output file.'
if outputfile(0) eq '' then return
end
print,'Name of the output mgh-file is '+outputfile
print,'The output file is '+outputfile
map_image2cgrid,cgridfile,imgfile,outputfile,mins,maxs
end
