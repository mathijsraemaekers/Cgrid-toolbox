function remove_islands,edges,tres=tres
syntx=n_params()
if syntx lt 1 then begin
print,'Removes edges not part of the main cluster'
print,'Syntax not right; parms are :'
print,'1: The matrix containing the (2,number of edges)'
print,'Keyword tres only performs the action of the main cluster size exceeds a particular proportion of all edges'
return,0
endif
if not keyword_set(tres) then tres=0.
finres=sort_border_main(edges)
hist=histogram(finres(0,*),min=0)
maxclus=where(hist eq max(hist))
inc=where(finres(0,*) eq maxclus(0))
if keyword_set(tres) then ratio=float(n_elements(inc))/n_elements(edges(0,*)) else ratio=1
if ratio gt tres then opedges=edges(*,inc) else opedges=edges
return,opedges
end

