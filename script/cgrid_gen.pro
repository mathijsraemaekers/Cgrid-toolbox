function cgrid_gen,patchfile,ubor,dbor,lbor,rbor,hstep,vstep,porder=porder,disp=disp,de=de,idisp=idisp,edisp=edisp,ptitle=ptitle,mse=mse,dptres=dptres,sk=sk
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
print,'Keyword mse returns the rms of the fits of the two borders'
print,'Kewyord dptres sets the distance threshold for removal of (clusters of) coordinates from the border'
print,'Keyword sk sets the smoothing kernel for the left and right border (for 2-polynomial approach)'
return,0
endif
if not keyword_set(ptitle) then ptitle=''
if not keyword_set(porder) then porder=0
if not keyword_set(dptres) then dptres=10.
patch=read_fs_patch(patchfile)
ubor=align_borders(ubor,lbor,patch,1,my=umy)
dbor=align_borders(dbor,lbor,patch,1,my=dmy)
lbor=align_borders(lbor,dbor,patch,0,my=lmy)
rbor=align_borders(rbor,dbor,patch,0,my=rmy)
patch=rotate_fs_patch(patch,ubor,dbor,lbor,rbor,my=[umy,dmy,lmy,rmy])
nrcor=n_elements(patch)/4
tpatch=dblarr(2,max(patch(0,*))+1)
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
bplot=plot(cubor(0,*),cubor(1,*),dimension=[1200,1000],yrange=plyrange,xrange=plxrange,margin=[0.05,0.05,0.3,0.1],xtitle='x (mm)',ytitle='y (mm)',symbol='+',linestyle='none',color='red',name='Upper Border',aspect_ratio=1.,title='Border configuration '+ptitle)
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
if not keyword_set(edisp) then pmatrix=cgrid_polyfit(cubor,cdbor,clbor,crbor,porder,vstep,mse=mse) else pmatrix=cgrid_polyfit(cubor,cdbor,clbor,crbor,porder,vstep,edisp=edisp,disp=ptitle,mse=mse)
if where(finite(pmatrix) eq 0,/NULL) ne !NULL then return,0
tmpporder=n_elements(pmatrix(*,0))-1
pxrange=round([min(patch(1,*)),max(patch(1,*))]*10.)
nrxcor=pxrange(1)-pxrange(0)+1
pxcors=double(findgen(nrxcor)/10.+pxrange(0)/10.)
plines=dblarr(vstep+1,nrxcor)
for i=0,vstep do for j=0,tmpporder do plines(i,*)=plines(i,*)+pxcors^j*pmatrix(j,i)
dists=dblarr(vstep+1,nrxcor-1)
for i=0,vstep do dists(i,*)=sqrt((plines(i,0:nrxcor-2)-plines(i,1:nrxcor-1))^2+(pxcors(0:nrxcor-2)-pxcors(1:nrxcor-1))^2)
seps=intarr(vstep+1,2,2)
if keyword_set(sk) then begin
lbore1=line_prox(transpose([[pxcors],[reform(plines(0,*))]]),clbor)
lbore2=line_prox(transpose([[pxcors],[reform(plines(vstep,*))]]),clbor)
rbore1=line_prox(transpose([[pxcors],[reform(plines(0,*))]]),crbor)
rbore2=line_prox(transpose([[pxcors],[reform(plines(vstep,*))]]),crbor)
clbor=line_smooth(clbor,sk,sps=[lbore1(1),lbore2(1)])
crbor=line_smooth(crbor,sk,sps=[rbore1(1),rbore2(1)])
end
for i=0,vstep do begin
seps(i,0,*)=line_prox(transpose([[pxcors],[reform(plines(i,*))]]),clbor)
seps(i,1,*)=line_prox(transpose([[pxcors],[reform(plines(i,*))]]),crbor)
end
seps=reform(seps(*,*,0))
gcors=fltarr(hstep+1,vstep+1,2)
for i=0,vstep do begin
arels=seps(i,1)-seps(i,0)
if arels lt 3 then return,0
inc=lindgen(arels)+seps(i,0)
tmpdist=total(dists(i,inc),/cumulative)
bps=where(deriv(tmpdist mod (max(tmpdist)/(hstep))) lt 0)
bps=inc([0,bps(indgen(hstep-1)*2),n_elements(inc)-1])
gcors(*,i,0)=pxcors(bps)
gcors(*,i,1)=plines(i,bps)
end
xbound=fltarr(vstep,2)
for i=0,vstep-1 do xbound(i,*)=[min(gcors(0,i:i+1)),max(gcors(hstep,i:i+1))]
xbound=reverse(xbound,1)
cgrid=dblarr(3,nrcor)
cgrid(0,*)=patch(0,*)
ytest=dblarr(2,nrcor)
for i=0,1 do for j=0,tmpporder do ytest(i,*)=ytest(i,*)+patch(1,*)^j*pmatrix(j,i*vstep)
ytest=(patch(2,*)-ytest(1,*))/(ytest(0,*)-ytest(1,*))
cginc=where(ytest ge 0 and ytest le 1)
ytest=ytest*vstep
cgrid(2,cginc)=ytest(cginc)
rcs=(gcors(*,1:*,1)-gcors(*,0:vstep-1,1))/(gcors(*,1:*,0)-gcors(*,0:vstep-1,0))
rcs(where(finite(rcs) eq 0))=100000.
bs=gcors(*,0:vstep-1,1)-rcs*gcors(*,0:vstep-1,0)
xtest=fltarr(hstep+1,nrcor)
for j=0,vstep-1 do begin
inc=where(ceil(cgrid(2,*)) eq vstep-j)
for i=0,hstep do begin
xtest(i,inc)=patch(1,inc)-(patch(2,inc)-bs(i,j))/rcs(i,j)
end
end
xtest(where(xtest lt 0 or finite(xtest) eq 0))=!VALUES.F_NAN
xmv=min(xtest,xmin,dimension=1,/NAN)
tmp=array_indices(xtest,xmin)
tmp=tmp(0,*)
tmpgcors=reverse(gcors,2)
rat1=min_dists(patch(1,*),patch(2,*),tmpgcors(tmp,floor(ytest),intarr(nrcor)),tmpgcors(tmp,floor(ytest)+1,intarr(nrcor)),tmpgcors(tmp,floor(ytest),intarr(nrcor)+1),tmpgcors(tmp,floor(ytest)+1,intarr(nrcor)+1))
rat2=min_dists(patch(1,*),patch(2,*),tmpgcors(tmp+1,floor(ytest),intarr(nrcor)),tmpgcors(tmp+1,floor(ytest)+1,intarr(nrcor)),tmpgcors(tmp+1,floor(ytest),intarr(nrcor)+1),tmpgcors(tmp+1,floor(ytest)+1,intarr(nrcor)+1))
tmp=double(tmp)+rat1/(rat1+rat2)
cginc=where(finite(xmv) eq 1 and tmp le hstep)
cgrid(1,cginc)=tmp(cginc)
cgrid(1,where(patch(1,*)-xbound(cgrid(2,*)-1,0) le 0 or patch(1,*)-xbound(cgrid(2,*)-1,1) ge 0))=0
cgridinc=where(cgrid(1,*)*cgrid(2,*) ne 0)
cgridinc=where(cgrid(1,*)*cgrid(2,*) ne 0)
cgrid=cgrid(*,cgridinc)
patch=patch(*,cgridinc)
if keyword_set(disp) then begin
bplot=plot(patch(1,*),patch(2,*),margin=[0.05,0.05,0.3,0.1],yrange=plyrange,xrange=plxrange,xtitle='x (mm)',ytitle='y (mm)',linestyle='none',symbol='.',aspect_ratio=1.,name='Patch vertices',dimension=[1200,1000],title='Grid configuration '+ptitle)
bplot=plot(cubor(0,*),cubor(1,*),symbol='+',linestyle='none',/overplot,color='red',name='Upper Border')
bplot=plot(cdbor(0,*),cdbor(1,*),symbol='+',linestyle='none',/overplot,color='green',name='Lower Border')
bplot=plot(clbor(0,*),clbor(1,*),symbol='+',linestyle='none',/overplot,color='blue',name='Left Border')
bplot=plot(crbor(0,*),crbor(1,*),symbol='+',linestyle='none',/overplot,color='brown',name='Right Border')
leg=legend(vertical_alignment='top',horizontal_alignment='right',transparency=100)
for i=0,vstep do bplot=plot(pxcors,plines(i,*),/overplot,thick=2)
for i=0,hstep do bplot=plot(gcors(i,*,0),gcors(i,*,1),thick=2,/overplot)
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
for i=0,vstep do bplot=plot(pxcors,plines(i,*),/overplot,thick=2)
for i=0,hstep do bplot=plot(gcors(i,*,0),gcors(i,*,1),thick=2,/overplot)
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
for i=0,vstep do bplot=plot(pxcors,plines(i,*),/overplot,thick=2)
for i=0,hstep do bplot=plot(gcors(i,*,0),gcors(i,*,1),thick=2,/overplot)
if trim(de) ne '1' then begin
print,'Writing '+de+'_xclass.png'
bplot.Save,de+'_xclass.png',compression=1
print,'Done'
end
bplot.close
end
return,cgrid
end
