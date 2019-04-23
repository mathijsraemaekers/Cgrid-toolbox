function replace,ostrdat,old,new
syntx=n_params()
if syntx lt 3 then begin
print,'IDL function to replace string-parts like in word'
print,'Parameters:'
print,'1: The string matrix'
print,'2: The string to find and replace'
print,'3: The replacement string'
return,0
end
nstrdat=ostrdat
posinfo=strpos(ostrdat,old)
while max(posinfo) ne -1 do begin
for i=0,n_elements(posinfo)-1 do if posinfo(i) ne -1 then nstrdat(i)=strmid(nstrdat(i),0,posinfo(i))+new+strmid(nstrdat(i),posinfo(i)+strlen(old),strlen(nstrdat(i))-posinfo(i)-strlen(old))
posinfo=strpos(nstrdat,old)
end
return,nstrdat
end
