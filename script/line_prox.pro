function line_prox,line1,line2,prox1=prox1,prox2=prox2
syntx=n_params()
if syntx lt 2 then begin
print,'Give the indices of the closests points of two lines.'
print,'Syntax not right; parms are :'
print,'1: Coordinates of the first line (2,nrcoords)'
print,'2: Coordinates of the second line (2,nrcoords)'
print,'Keyword prox1 returns the closest distance for each coordinate of line1'
print,'Keyword prox2 returns the closest distance for each coordinate of line2'
return,0
end
nrcoor1=n_elements(line1)/2
nrcoor2=n_elements(line2)/2
if nrcoor1 eq 1 then line1=reform(line1,2,1)
if nrcoor2 eq 1 then line2=reform(line2,2,1)
line1c=rebin(line1,2,nrcoor1,nrcoor2,/sample)
pmat=rebin(line2,2,nrcoor2,nrcoor1,/sample)
pmat=reform(pmat,2,nrcoor2,nrcoor1)
line2c=transpose(pmat,[0,2,1])
dists=reform(sqrt((line1c(0,*,*)-line2c(0,*,*))^2+(line1c(1,*,*)-line2c(1,*,*))^2))
dists=reform(dists,nrcoor1,nrcoor2)
prox1=min(dists,dimension=2)
prox2=min(dists,dimension=1)
mindist=min(dists,imin)
inds=array_indices(dists,imin)
return,inds
end
