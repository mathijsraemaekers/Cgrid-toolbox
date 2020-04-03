pro write_metric,filename,tmpdata,metrictags=metrictags
syntx=n_params()
if syntx lt 2 then begin
print,'Syntax not right; parms are :'
print,'1:Filename of the metric file'
print,'2:Metric data in format nrnodes,nrcolumns'
print,'Keyword metrictags is a string matrix with the tagnames'
goto, EINDE
end
data=tmpdata
tmp=size(data)
nrnodes=tmp(1)
if tmp(0) eq 2 then nrcolumns=tmp(2) else nrcolumns=1

r=string(byte(10))
header='BeginHeader'+r+'Caret-Version 5.61'+r+'comment '+r+'date '+systime()+r+'encoding BINARY'+r+'pubmed_id '+r+'EndHeader'+r+'tag-version 2'+r
header=header+'tag-number-of-nodes '+strcompress(string(nrnodes),/remove_all)+r
header=header+'tag-number-of-columns '+strcompress(string(nrcolumns),/remove_all)+r
header=header+'tag-title '+r
if keyword_set(metrictags) then for i=0,nrcolumns-1 do header=header+'tag-column-name '+strcompress(string(i),/remove_all)+' '+metrictags(i)+r
if not keyword_set(metrictags) then for i=0,nrcolumns-1 do header=header+'tag-column-name '+strcompress(string(i),/remove_all)+' Volume '+strcompress(string(i),/remove_all)+r
for i=0,nrcolumns-1 do header=header+'tag-column-comment '+strcompress(string(i),/remove_all)+' Made with IDL'+r
for i=0,nrcolumns-1 do header=header+'tag-column-study-meta-data '+strcompress(string(i),/remove_all)+r
for i=0,nrcolumns-1 do header=header+'tag-column-color-mapping '+strcompress(string(i),/remove_all)+' -1.000000 1.000000'+r
for i=0,nrcolumns-1 do header=header+'tag-column-threshold '+strcompress(string(i),/remove_all)+' 0.000000 0.000000'+r
for i=0,nrcolumns-1 do header=header+'tag-column-average-threshold '+strcompress(string(i),/remove_all)+' 0.000000 0.000000'+r
header=header+'tag-BEGIN-DATA'+r
byteorder,data,/htonl
get_lun,unit
openw,unit,filename
writeu,unit,header
writeu,unit,transpose(data)
close,unit
free_lun,unit
EINDE:
end
