function align_borders,bor1,bor2,patch,dim,my=my
syntx=n_params()
if syntx lt 3 then begin
print,'Topologically sorts bor1 with the point closest to bor2 as the base if possible. Otherwise use coordinate sorting'
print,'Syntax not right; parms are :'
print,'1: Vertice numbers forming the edges of the to be sorted border (2,nrcoors)'
print,'2: Vertice numbers forming the edges of the border forming the baseline (2,nrcoors)'
print,'3: The patch (3,nrcoors)'
print,'4: The dimension used for sorting when topological sorting is impossible'
print,'Keyword my returns a keyword reflecting the method used 1=topological, 2=coordinate'
return,0
endif
tpatch=dblarr(2,max(patch(0,*))+1)
tpatch(*,patch(0,*))=patch(1:2,*)
nrbor2=n_elements(bor2)/2
tmp=sort_border_main(bor1)
if max(tmp(0,*)) eq 1 then begin
opbor=bor1(*,sort(tmp(1,*)))
coor1=(tpatch(*,opbor(0,0))+tpatch(*,opbor(1,0)))/2
coor2=(tpatch(*,opbor(0,-1))+tpatch(*,opbor(1,-1)))/2
cbor2=(tpatch(*,bor2(0,*))+tpatch(*,bor2(1,*)))/2
proxcoor1=min(sqrt((cbor2(0,*)-(fltarr(nrbor2)+coor1(0)))^2+(cbor2(1,*)-(fltarr(nrbor2)+coor1(1)))^2))
proxcoor2=min(sqrt((cbor2(0,*)-(fltarr(nrbor2)+coor2(0)))^2+(cbor2(1,*)-(fltarr(nrbor2)+coor2(1)))^2))
my=1
if proxcoor1 gt proxcoor2 then opbor=reverse(opbor,2)
end else begin
cbor1=(tpatch(*,bor1(0,*))+tpatch(*,bor1(1,*)))/2
opbor=bor1(*,sort(cbor1(dim,*)))
my=2
end
return,opbor
end

