function sort_border_sub,edges,seed=seed
syntx=n_params()
if syntx lt 1 then begin
print,'Returns index of cluster and of order (2,number of edges)'
print,'Syntax not right; parms are :'
print,'1: The matrix containing the (2,number of edges)'
print,'Keyword provides the index of the seed-edge used for the first round of sorting'
return,0
endif
nredges=n_elements(edges)/2
ucoor=edges(sort(edges))
ucoor=ucoor(uniq(ucoor))
nrcoor=n_elements(ucoor)
redges=lonarr(2,nredges)
finres=lonarr(2,nredges)
for i=0,nrcoor-1 do redges(where(edges eq ucoor(i)))=i
redges=[[redges],[redges([1,0],*)]]
clusts=lonarr(nrcoor,nrcoor)
orders=lonarr(nrcoor,nrcoor)
stest=1
z=1
fintest=1
while fintest ne !NULL do begin
ematrix=lonarr(nrcoor,nrcoor)
ematrix(redges(0,*),redges(1,*))=1
pseeds=array_indices(ematrix,where(ematrix eq 1 and clusts eq 0))
if keyword_set(seed) then if z eq 1 then pseeds=reform([redges(0,seed),redges(1,seed)],2,1)
ematrix(pseeds(0,0),pseeds(1,0))=2
ematrix(pseeds(1,0),pseeds(0,0))=2
for i=0,nrcoor-1 do if stest ne !NULL then begin
stest=where(ematrix eq i+2,/NULL)
if stest ne !NULL then begin
seeds=array_indices(ematrix,stest)
nrseeds=n_elements(seeds)/2
for j=0,nrseeds-1 do begin
tmp=bytarr(nrcoor,nrcoor)
tmp(seeds(0,j),*)=1
tmp(*,seeds(1,j))=1
sinc=where(tmp eq 1 and ematrix eq 1,/NULL)
if sinc ne !NULL then ematrix(where(tmp eq 1 and ematrix eq 1))=i+3
end
end
end
reps=where(ematrix gt 1,/NULL)
clusts(reps)=z
orders(reps)=ematrix(reps)-1
fintest=where(ematrix eq 1 and clusts eq 0,/NULL)
z=z+1
end
finres(0,*)=clusts(redges(0,0:nredges-1),redges(1,0:nredges-1))
finres(1,*)=orders(redges(0,0:nredges-1),redges(1,0:nredges-1))
return,finres
end

