function cgrid_gen_4pol,patchfile,ubor,dbor,lbor,rbor,hstep,vstep,porder=porder,disp=disp,de=de,idisp=idisp,edisp=edisp,ptitle=ptitle,mset=mset,dptres=dptres
syntx=n_params()
if syntx lt 7 then begin
print,'Returns the CGRID classification for the vertices in the patch.'
print,'Syntax not right; parms are :'
print,'1: The name of the Freesurfer patchfile'
print,'2: Vertice numbers forming the edges of the upper border (2,nrcoors)'
print,'3: Vertice numbers forming the edges of the lower border (2,nrcoors)'
print,'4: Vertice numbers forming the edges of the left border (2,nrcoors)'
print,'5: Vertice numbers forming the edges of the right border (2,nrcoors)'
print,'6: The number of horizontal steps in the cgrid'
print,'7: The number of vertical steps in the cgrid'
print,'Keyword porder sets the number of polynomials for fitting. If not set the optimal order is established iteratively'
print,'Keyword disp displays the resulting cgrid, of set to string, then stores as picture under filename defined by string'
print,'Keyword de displays the classification of the cgrid, of set to string, then stores as picture under filename defined by string'
print,'Keyword idisp shows the initial configuration of the borders, of set to string, then stores as picture under filename defined by string'
print,'Keyword edisp shows the border extensions'
print,'Keyword ptitle provides tile names for the plots'
print,'Keyword mset returns the rms of the fits of the four borders'
print,'Kewyord dptres sets the distance threshold for removal of (clusters of) coordinates from the border'
return,0
endif
if not keyword_set(ptitle) then ptitle=''
if not keyword_set(porder) then porder=0
if not keyword_set(dptres) then dptres=10.
opatch=read_fs_patch(patchfile)
ubor=align_borders(ubor,lbor,opatch,1,my=umy)
dbor=align_borders(dbor,lbor,opatch,1,my=dmy)
lbor=align_borders(lbor,dbor,opatch,0,my=lmy)
rbor=align_borders(rbor,dbor,opatch,0,my=rmy)
patch=rotate_fs_patch(opatch,ubor,dbor,lbor,rbor,rotmat=rotmat1,my=[umy,dmy,lmy,rmy])
nrcor=n_elements(patch)/4
tpatch=dblarr(2,max(opatch(0,*))+1)
tpatch(*,patch(0,*))=patch(1:2,*)
cubor=(tpatch(*,ubor(0,*))+tpatch(*,ubor(1,*)))/2
cdbor=(tpatch(*,dbor(0,*))+tpatch(*,dbor(1,*)))/2
clbor=(tpatch(*,lbor(0,*))+tpatch(*,lbor(1,*)))/2
crbor=(tpatch(*,rbor(0,*))+tpatch(*,rbor(1,*)))/2
cubor=cubor(*,devpoint_remove(cubor,dptres))
cdbor=cdbor(*,devpoint_remove(cdbor,dptres))
clbor=clbor(*,devpoint_remove(clbor,dptres))
crbor=crbor(*,devpoint_remove(crbor,dptres))
plxrange=[min([min(crbor(0,*)),min(clbor(0,*)),min(cubor(0,*)),min(cdbor(0,*))]),max([max(crbor(0,*)),max(clbor(0,*)),max(cubor(0,*)),max(cdbor(0,*))])]
plyrange=[min([min(crbor(1,*)),min(clbor(1,*)),min(cubor(1,*)),min(cdbor(1,*))]),max([max(crbor(1,*)),max(clbor(1,*)),max(cubor(1,*)),max(cdbor(1,*))])]
if keyword_set(idisp) then begin
bplot=plot(cubor(0,*),yrange=plyrange,xrange=plxrange,margin=[0.05,0.05,0.3,0.1],dimension=[1200,1000],xtitle='x (mm)',ytitle='y (mm)',cubor(1,*),symbol='+',linestyle='none',color='red',name='Upper Border',aspect_ratio=1.,title='Border configuration '+ptitle)
bplot=plot(cdbor(0,*),cdbor(1,*),symbol='+',linestyle='none',/overplot,color='green',name='Lower Border')
bplot=plot(clbor(0,*),clbor(1,*),symbol='+',linestyle='none',/overplot,color='blue',name='Left Border')
bplot=plot(crbor(0,*),crbor(1,*),symbol='+',linestyle='none',/overplot,color='brown',name='Right Border')
leg=legend(vertical_alignment='top',horizontal_alignment='right',transparency=100)
if trim(idisp) ne '1' then begin
print,'Writing '+idisp+'.png'
bplot.Save,idisp+'.png',compression=1
print,'Done'
end
bplot.close
end
if not keyword_set(edisp) then pmatrix1=cgrid_polyfit(cubor,cdbor,clbor,crbor,porder,vstep,mse=mse1) else pmatrix1=cgrid_polyfit(cubor,cdbor,clbor,crbor,porder,vstep,edisp=edisp+'_ud',disp=ptitle,mse=mse1)
txrange=[min([min(crbor(0,*)),min(clbor(0,*)),min(cubor(0,*)),min(cdbor(0,*))]),max([max(crbor(0,*)),max(clbor(0,*)),max(cubor(0,*)),max(cdbor(0,*))])]
if where(finite(pmatrix1) eq 0,/NULL) ne !NULL then return,0
tmpporder=n_elements(pmatrix1(*,0))-1
pxrange=round(txrange*10.)
nrxcor=pxrange(1)-pxrange(0)+1
pxcors=double(findgen(nrxcor)/10.+pxrange(0)/10.)
pxlines=dblarr(vstep+1,nrxcor)
for i=0,vstep do for j=0,tmpporder do pxlines(i,*)=pxlines(i,*)+pxcors^j*pmatrix1(j,i)
cgrid=lonarr(3,nrcor)
cgrid(0,*)=patch(0,*)
ytest=dblarr(vstep+1,nrcor)
for i=0,vstep do for j=0,tmpporder do ytest(i,*)=ytest(i,*)+patch(1,*)^j*pmatrix1(j,i)
for i=0,vstep do ytest(i,*)=patch(2,*)-ytest(i,*)
ytest=reverse(ytest,1)
ytest(where(ytest lt 0))=!VALUES.F_NAN
ymv=min(ytest,ymin,dimension=1,/NAN)
tmp=array_indices(ytest,ymin)
tmp=tmp(0,*)
cginc=where(finite(ymv) eq 1 and tmp ne vstep)
cgrid(2,cginc)=tmp(cginc)+1 
cgrid(2,where(tpatch(0,opatch(0,*)) lt txrange(0)))=0
cgrid(2,where(tpatch(0,opatch(0,*)) gt txrange(1)))=0
ypatch=rotate_fs_patch(opatch,rbor,lbor,ubor,dbor,rotmat=rotmat2,my=[rmy,lmy,umy,dmy])
tpatch=dblarr(2,max(opatch(0,*))+1)
tpatch(*,ypatch(0,*))=ypatch(1:2,*)
cubory=(tpatch(*,ubor(0,*))+tpatch(*,ubor(1,*)))/2
cdbory=(tpatch(*,dbor(0,*))+tpatch(*,dbor(1,*)))/2
clbory=(tpatch(*,lbor(0,*))+tpatch(*,lbor(1,*)))/2
crbory=(tpatch(*,rbor(0,*))+tpatch(*,rbor(1,*)))/2
cubory=cubory(*,devpoint_remove(cubor,dptres))
cdbory=cdbory(*,devpoint_remove(cdbor,dptres))
clbory=clbory(*,devpoint_remove(clbor,dptres))
crbory=crbory(*,devpoint_remove(crbor,dptres))
if not keyword_set(edisp) then pmatrix2=cgrid_polyfit(crbory,clbory,cubory,cdbory,porder,hstep,mse=mse2) else pmatrix2=cgrid_polyfit(crbory,clbory,cubory,cdbory,porder,hstep,edisp=edisp+'_lr',disp=ptitle,mse=mse2)
mset=[(mse1(0)+mse2(0))/2,max([mse1(1),mse2(1)])]
txrange=[min([min(crbory(0,*)),min(clbory(0,*)),min(cubory(0,*)),min(cdbory(0,*))]),max([max(crbory(0,*)),max(clbory(0,*)),max(cubory(0,*)),max(cdbory(0,*))])]
if where(finite(pmatrix2) eq 0,/NULL) ne !NULL then return,0
tmpporder=n_elements(pmatrix2(*,0))-1
pyrange=round(txrange*10.)
nrycor=pyrange(1)-pyrange(0)+1
pycors=double(findgen(nrycor)/10.+pyrange(0)/10.)
pylines=dblarr(hstep+1,nrycor)
for i=0,hstep do for j=0,tmpporder do pylines(i,*)=pylines(i,*)+pycors^j*pmatrix2(j,i)
tmplines=dblarr(2*hstep+2,nrycor)
for i=0,hstep do tmplines(i,*)=pycors
tmplines(hstep+1:*,*)=pylines
for i=0,hstep do tmplines([i,i+hstep+1],*)=transpose(transpose(tmplines([i,i+hstep+1],*))#invert(rotmat2)#rotmat1)
pycors=tmplines(0:hstep,*)
pylines=tmplines(hstep+1:*,*)
xtest=dblarr(hstep+1,nrcor)
for i=0,hstep do for j=0,tmpporder do xtest(i,*)=xtest(i,*)+ypatch(1,*)^j*pmatrix2(j,i)
for i=0,hstep do xtest(i,*)=ypatch(2,*)-xtest(i,*)
xtest=reverse(xtest,1)
xtest(where(xtest lt 0))=!VALUES.F_NAN
xmv=min(xtest,xmin,dimension=1,/NAN)
tmp=array_indices(xtest,xmin)
tmp=tmp(0,*)
cginc=where(finite(xmv) eq 1 and tmp ne hstep)
cgrid(1,cginc)=tmp(cginc)+1 
cgrid(1,where(tpatch(0,opatch(0,*)) lt txrange(0)))=0
cgrid(1,where(tpatch(0,opatch(0,*)) gt txrange(1)))=0
cgridinc=where(cgrid(1,*)*cgrid(2,*) ne 0)
cgrid=cgrid(*,cgridinc)
patch=patch(*,cgridinc)
if keyword_set(disp) then begin
bplot=plot(patch(1,*),margin=[0.05,0.05,0.3,0.1],yrange=plyrange,xrange=plxrange,xtitle='x (mm)',ytitle='y (mm)',patch(2,*),linestyle='none',symbol='.',aspect_ratio=1.,name='Patch vertices',dimension=[1200,1000],title='Grid configuration '+ptitle)
bplot=plot(cubor(0,*),cubor(1,*),symbol='+',linestyle='none',/overplot,color='red',name='Upper Border')
bplot=plot(cdbor(0,*),cdbor(1,*),symbol='+',linestyle='none',/overplot,color='green',name='Lower Border')
bplot=plot(clbor(0,*),clbor(1,*),symbol='+',linestyle='none',/overplot,color='blue',name='Left Border')
bplot=plot(crbor(0,*),crbor(1,*),symbol='+',linestyle='none',/overplot,color='brown',name='Right Border')
leg=legend(vertical_alignment='top',horizontal_alignment='right',transparency=100)
for i=0,vstep do bplot=plot(pxcors,pxlines(i,*),/overplot,thick=2)
for i=0,hstep do bplot=plot(pycors(i,*),pylines(i,*),/overplot,thick=2)
if trim(disp) ne '1' then begin
print,'Writing '+disp+'.png'
bplot.Save,disp+'.png',compression=1
print,'Done'
end
bplot.close
end
if keyword_set(de) then begin
bplot=plot(patch(1,*),patch(2,*),margin=[0.05,0.05,0.3,0.1],yrange=plyrange,xrange=plxrange,xtitle='x (mm)',ytitle='y (mm)',linestyle='none',symbol='.',aspect_ratio=1.,name='Patch vertices',dimension=[1200,1000],title='y-coordinate per vertex '+ptitle)
for i=1,vstep do vtest=plot(patch(1,where(cgrid(2,*) eq i)),patch(2,where(cgrid(2,*) eq i)),linestyle='none',symbol='+',color=intarr(3)+floor(240/vstep)*i,/overplot,aspect_ratio=1,name='Subgrid y-coordinate '+trim(i))
bplot=plot(cubor(0,*),cubor(1,*),symbol='+',linestyle='none',/overplot,color='red',name='Upper Border')
bplot=plot(cdbor(0,*),cdbor(1,*),symbol='+',linestyle='none',/overplot,color='green',name='Lower Border')
bplot=plot(clbor(0,*),clbor(1,*),symbol='+',linestyle='none',/overplot,color='blue',name='Left Border')
bplot=plot(crbor(0,*),crbor(1,*),symbol='+',linestyle='none',/overplot,color='brown',name='Right Border')
leg=legend(vertical_alignment='top',horizontal_alignment='right',transparency=100,vertical_spacing=0.001)
for i=0,vstep do bplot=plot(pxcors,pxlines(i,*),/overplot,thick=2)
for i=0,hstep do bplot=plot(pycors(i,*),pylines(i,*),/overplot,thick=2)
if trim(de) ne '1' then begin
print,'Writing '+de+'_yclass.png'
bplot.Save,de+'_yclass.png',compression=1
print,'Done'
end
bplot.close
bplot=plot(patch(1,*),patch(2,*),margin=[0.05,0.05,0.3,0.1],yrange=plyrange,xrange=plxrange,xtitle='x (mm)',ytitle='y (mm)',linestyle='none',symbol='.',aspect_ratio=1.,name='Patch vertices',dimension=[1200,1000],title='x-coordinate per vertex '+ptitle)
for i=1,hstep do vtest=plot(patch(1,where(cgrid(1,*) eq i)),patch(2,where(cgrid(1,*) eq i)),thick=4,linestyle='none',symbol='+',color=intarr(3)+floor(240/hstep)*i,/overplot,aspect_ratio=1,name='Subgrid x-coordinate '+trim(i))
bplot=plot(cubor(0,*),cubor(1,*),symbol='+',linestyle='none',/overplot,color='red',name='Upper Border')
bplot=plot(cdbor(0,*),cdbor(1,*),symbol='+',linestyle='none',/overplot,color='green',name='Lower Border')
bplot=plot(clbor(0,*),clbor(1,*),symbol='+',linestyle='none',/overplot,color='blue',name='Left Border')
bplot=plot(crbor(0,*),crbor(1,*),symbol='+',linestyle='none',/overplot,color='brown',name='Right Border')
leg=legend(vertical_alignment='top',horizontal_alignment='right',transparency=100,vertical_spacing=0.001)
for i=0,vstep do bplot=plot(pxcors,pxlines(i,*),/overplot,thick=2)
for i=0,hstep do bplot=plot(pycors(i,*),pylines(i,*),/overplot,thick=2)
if trim(de) ne '1' then begin
print,'Writing '+de+'_xclass.png'
bplot.Save,de+'_xclass.png',compression=1
print,'Done'
end
bplot.close
end
return,cgrid
end
