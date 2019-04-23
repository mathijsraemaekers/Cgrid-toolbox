function read_ctab,ctabfile
syntx=n_params()
if syntx lt 1 then begin
print,'Reads freesurfer ctab file'
print,'Syntax not right; parms are :'
print,'1: The name of the ctab file'
return,0
endif
read_ascii_string,ctabfile,ctab
ctab=reform(ctab)
nrlines=n_elements(ctab)
for i=0,nrlines-1 do begin
bstring=byte(ctab(i))
jumps=uniq(bstring)
jumps=[jumps(where(bstring(jumps) eq 32)),n_elements(bstring)]
nrjumps=n_elements(jumps)
opstring=strarr(nrjumps)
for j=0,nrjumps-2 do opstring(j)=string(bstring(jumps(j):jumps(j+1)-1))
opstring=replace(opstring,' ','')
opstring=opstring(where(opstring ne '')) 
if i eq 0 then op=strarr(n_elements(opstring),nrlines)
op(*,i)=opstring
end
return,op
end
