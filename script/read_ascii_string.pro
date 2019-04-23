pro read_ascii_string,filename,data,lineskip=lineskip,delimiter=delimiter
syntx=n_params()
if syntx lt 2 then begin
print,'Script for reading ascii file as string array'
print,'The filename'
print,'The array to store the data'
print,'Keyword lineskip sets the number of lines to skip before reading'
print,'Keyword delimiter sets the ascii code of the sign for separating columns (default is 9/tab) '
print,'The scan name'
return
end
if not keyword_set(delimiter) then delimiter=9
close,1
openr,1,filename
temp=fstat(1)
filesize=temp.size
temp=bytarr(filesize)
rdbblk,filename,temp
while temp(n_elements(temp)-1) eq 10 do temp=temp(0:n_elements(temp)-2)
temp3=where(temp eq 10)
if keyword_set(lineskip) then temp=temp(temp3(lineskip-1)+1:*)
temp3=where(temp eq 10)
temp2=where(temp eq delimiter(0))
temp4=n_elements(temp2)
temp5=n_elements(temp3)
rows=temp4/temp5+1
columns=temp5
data=strarr(rows,columns+1)
j=0
k=0
;for i=0L,filesize-1 do begin
for i=0L,n_elements(temp)-1 do begin
if temp(i) eq delimiter then j=j+1
if temp(i) eq 10 then k=k+1
if temp(i) eq 10 then j=0
if temp(i) ne delimiter and temp(i) ne 10 then data(j,k)=data(j,k)+string(temp(i))
end
data=replace(data,string(byte(13)),'')
end
