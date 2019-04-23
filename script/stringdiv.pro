function stringdiv,instr
syntx=n_params()
if syntx lt 1 then begin $
& print,'Usage:' $
& print,'String containing space separated numbers' $
& end
tmp=byte(instr)
if tmp(n_elements(tmp)-1) ne 32 then tmp=[tmp,byte(32)]
if tmp(0) ne 32 then tmp=[byte(32),tmp]
shifts=uniq(tmp)
spaces=shifts(where(tmp(shifts) eq 32))
spaces=[spaces,n_elements(tmp)-1]
nrspaces=n_elements(spaces)
numbers=strarr(nrspaces-1)
for i=0,nrspaces-2 do numbers(i)=string(tmp(spaces(i):spaces(i+1)))
if strpos(instr,'.') ne -1 then numbers=float(numbers) else numbers=long(numbers)
return,numbers
end
