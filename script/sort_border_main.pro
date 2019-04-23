function sort_border_main,edges
syntx=n_params()
if syntx lt 1 then begin
print,'Returns index of cluster and of order (2,number of edges)'
print,'Syntax not right; parms are :'
print,'1: The matrix containing the (2,number of edges)'
return,0
endif
finres=sort_border_sub(edges)
nrclus=max(finres(0,*))
for i=0,nrclus-1 do begin
clusinc=where(finres(0,*) eq i+1)
tmpedges=edges(*,clusinc)
maxloc=where(finres(1,clusinc) eq max(finres(1,clusinc)))
maxloc=maxloc(0)
tmpres=sort_border_sub(tmpedges,seed=maxloc)
finres(1,clusinc)=tmpres(1,*)
end
return,finres
end

