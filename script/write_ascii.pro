pro write_ascii,filename,stringdata,delim=delim
syntx=n_params()
if syntx lt 2 then begin
print,'Syntax not right; parms are :'
print,'1:Filename'
print,'2:String data'
print,'delim: string that is used as delimiter. Default is tab'
return
goto,einde
ENDIF
if not keyword_set(delim) then delim=string(9B)
data=stringdata
temp=size(data)
if temp(0) gt 2 then print,'Can only write 1D or 2D data'
if temp(0) eq 1 then for i=0,temp(1)-2 do data(i)=data(i)+delim else begin
for i=0,temp(1)-1 do for j=0,temp(2)-1 do begin
if i ne temp(1)-1 then data(i,j)=data(i,j)+delim
if i eq temp(1)-1 and j ne temp(2)-1 then data(i,j)=data(i,j)+string(10B)
end
end
wrbblk,filename,data
einde:
end
