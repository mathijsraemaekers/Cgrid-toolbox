function rotate_fs_patch,patchdat,ubor,dbor,lbor,rbor,rotmat=rotmat,my=my
syntx=n_params()
if syntx lt 1 then begin
print,'Rotates Freesurfer patch data so that the long sides of the patch run parallel to the x-axis'
print,'Syntax not right; parms are :'
print,'1: The patch data'
print,'2: Vertice numbers forming the edges of the upper border (2,nrcoors)'
print,'3: Vertice numbers forming the edges of the lower border (2,nrcoors)'
print,'4: Vertice numbers forming the edges of the upper border (2,nrcoors)'
print,'5: Vertice numbers forming the edges of the lower border (2,nrcoors)'
print,'Keyword rotmat returns the rotation matrix'
print,'Keyword my (intarr(4)) allows to switch off order sorting with 2s'
return,0
endif
if not keyword_set(my) then my=[2,2,2,2]
tpatch=dblarr(2,max(patchdat(0,*))+1)
tpatch(*,patchdat(0,*))=patchdat(1:2,*)
cubor=(tpatch(*,ubor(0,*))+tpatch(*,ubor(1,*)))/2
cdbor=(tpatch(*,dbor(0,*))+tpatch(*,dbor(1,*)))/2
clbor=(tpatch(*,lbor(0,*))+tpatch(*,lbor(1,*)))/2
crbor=(tpatch(*,rbor(0,*))+tpatch(*,rbor(1,*)))/2
nwpatchdat=patchdat
fitexy,cubor(0,*),cubor(1,*),a,bu,x_sig=1,y_sig=1
angle=atan(bu)
rmatrix1=transpose([[cos(angle),-sin(angle)],[sin(angle),cos(angle)]])
cubor=transpose(transpose(cubor)#rmatrix1)
cdbor=transpose(transpose(cdbor)#rmatrix1)
clbor=transpose(transpose(clbor)#rmatrix1)
crbor=transpose(transpose(crbor)#rmatrix1)
nwpatchdat(1:2,*)=transpose(transpose(patchdat(1:2,*))#rmatrix1)
fitexy,cubor(0,*),cubor(1,*),a,bu,x_sig=1,y_sig=1
fitexy,cdbor(0,*),cdbor(1,*),a,bd,x_sig=1,y_sig=1
angle=(atan(bu)+atan(bd))/2
rmatrix2=transpose([[cos(angle),-sin(angle)],[sin(angle),cos(angle)]])
rcubor=transpose(transpose(cubor)#rmatrix2)
rcdbor=transpose(transpose(cdbor)#rmatrix2)
rottest=mean(rcubor(1,*))-mean(rcdbor(1,*))
if rottest lt 0 then begin 
angle=angle+!PI
rmatrix2=transpose([[cos(angle),-sin(angle)],[sin(angle),cos(angle)]])
end
nwpatchdat(1:2,*)=transpose(transpose(nwpatchdat(1:2,*))#rmatrix2)
rcubor=transpose(transpose(cubor)#rmatrix2)
rcdbor=transpose(transpose(cdbor)#rmatrix2)
rclbor=transpose(transpose(clbor)#rmatrix2)
rcrbor=transpose(transpose(crbor)#rmatrix2)
optmatrix=fltarr(91,30)
for i=-45,45 do begin
angle=float(i)/360*2*!PI
tmprmatrix=transpose([[cos(angle),-sin(angle)],[sin(angle),cos(angle)]])
tmpcubor=transpose(transpose(rcubor)#tmprmatrix)
tmpcdbor=transpose(transpose(rcdbor)#tmprmatrix)
tmpclbor=transpose(transpose(rclbor)#tmprmatrix)
tmpcrbor=transpose(transpose(rcrbor)#tmprmatrix)
cgrid_ext_border,tmpcubor,tmpcdbor,tmpclbor,tmpcrbor,scubor=exttmpcubor,scdbor=exttmpcdbor,my=my
for j=1,30 do begin
fcubor=poly_fit(exttmpcubor(0,*),exttmpcubor(1,*),j,/double,yfit=ufit)
fcdbor=poly_fit(exttmpcdbor(0,*),exttmpcdbor(1,*),j,/double,yfit=dfit)
optmatrix(i+45,j-1)=sqrt(mean((exttmpcubor(1,*)-ufit)^2))+sqrt(mean((exttmpcdbor(1,*)-dfit)^2))
end
end
tmp=array_indices(optmatrix,where(optmatrix eq min(optmatrix)))
angle=(float(tmp(0))-45)/360*2*!PI
rmatrix3=transpose([[cos(angle),-sin(angle)],[sin(angle),cos(angle)]])
nwpatchdat(1:2,*)=transpose(transpose(nwpatchdat(1:2,*))#rmatrix3)
rotmat=rmatrix1#rmatrix2#rmatrix3
return,nwpatchdat
end
