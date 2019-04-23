function cgrid_polyfit,cubor,cdbor,clbor,crbor,porder,vstep,disp=disp,edisp=edisp,mse=mse,my=my
syntx=n_params()
if syntx lt 6 then begin
print,'Generates a matrix with polynomial estimates for cgrid'
print,'Syntax not right; parms are :'
print,'1: The upper border coordinates (2,nrcoords)'
print,'2: The lower border coordinates (2,nrcoords)'
print,'3: The left border coordinates (2,nrcoords)'
print,'4: The right border coordinates (2,nrcoords)'
print,'5: The polynomial order for fitting'
print,'6: The number of vertical tiles'
print,'Keyword disp shows the borders with etended parts'
print,'Keyword mse returns the root mean square of the errors of the fits'
print,'Keyword tmpporder gives the polynomial order that was used. Only relevant if porder is 0.'
print,'Keyword my (intarr(4)) allows to switch off order sorting with 2s'
return,0
endif
if not keyword_set(my) then my=[2,2,2,2]
plxrange=[min([min(crbor(0,*)),min(clbor(0,*)),min(cubor(0,*)),min(cdbor(0,*))]),max([max(crbor(0,*)),max(clbor(0,*)),max(cubor(0,*)),max(cdbor(0,*))])]
plyrange=[min([min(crbor(1,*)),min(clbor(1,*)),min(cubor(1,*)),min(cdbor(1,*))]),max([max(crbor(1,*)),max(clbor(1,*)),max(cubor(1,*)),max(cdbor(1,*))])]
tmpporder=porder
nubor=n_elements(cubor)/2-1
ndbor=n_elements(cdbor)/2-1
if nubor gt 10 then nubor=10
if ndbor gt 10 then ndbor=10
if not keyword_set(disp) then disp=''
nrlbor=n_elements(clbor)/2
nrrbor=n_elements(crbor)/2
if my(2) eq 2 then sclbor=clbor(*,sort(clbor(1,*))) else sclbor=clbor
if my(3) eq 2 then scrbor=crbor(*,sort(crbor(1,*))) else scrbor=crbor
fitexy,sclbor(0,0:nrlbor/2-1),sclbor(1,0:nrlbor/2-1),ald,bldo,x_sig=1,y_sig=1
fitexy,sclbor(0,nrlbor/2:*),sclbor(1,nrlbor/2:*),alu,bluo,x_sig=1,y_sig=1
fitexy,scrbor(0,0:nrrbor/2-1),scrbor(1,0:nrrbor/2-1),ard,brdo,x_sig=1,y_sig=1
fitexy,scrbor(0,nrrbor/2:*),scrbor(1,nrrbor/2:*),aru,bruo,x_sig=1,y_sig=1
blu=1/bluo
bld=1/bldo
bru=1/bruo*(-1)
brd=1/brdo*(-1)
if abs(blu) ge 5 then blu=blu/abs(blu)*5
if abs(bld) ge 5 then bld=bld/abs(bld)*5
if abs(bru) ge 5 then bru=bru/abs(bru)*5
if abs(brd) ge 5 then brd=brd/abs(brd)*5
xranges=[[min(cubor(0,*)),max(cubor(0,*))],[min(cdbor(0,*)),max(cdbor(0,*))]]
totbor=[[cubor],[cdbor],[clbor],[crbor]]
maxrange=[min(totbor(0,*)),max(totbor(0,*))]
uxdist=xranges(1,0)-xranges(0,0)
dxdist=xranges(1,1)-xranges(0,1)
udens=n_elements(cubor(0,*))/uxdist
ddens=n_elements(cdbor(0,*))/dxdist
if my(0) eq 2 then scubor=cubor(*,sort(cubor(0,*))) else scubor=cubor
if my(1) eq 2 then scdbor=cdbor(*,sort(cdbor(0,*))) else scdbor=cdbor
rotmax=20
if xranges(0,0) gt maxrange(0) then begin
ext=abs(maxrange(0)-xranges(0,0))
bins=ceil(ext*udens)
dircofs=fltarr(bins)
src=(scubor(1,0)-scubor(1,nubor))/(scubor(0,0)-scubor(0,nubor))*(-1)
if bins lt rotmax then rots=bins else rots=rotmax
for i=0,rots-1 do dircofs(i)=((rots-i)*src+i*blu)/rots/udens
if bins gt rotmax then dircofs(rots:*)=blu/udens
yvals=fltarr(bins)
for i=0,bins-1 do yvals(bins-i-1)=scubor(1,0)+total(dircofs(0:i))
xvals=findgen(bins)/udens+scubor(0,0)-ext
scubor=[[transpose([[xvals],[yvals]])],[scubor]]
end
if xranges(0,1) gt maxrange(0) then begin
ext=abs(maxrange(0)-xranges(0,1))
bins=ceil(ext*ddens)
dircofs=fltarr(bins)
src=(scdbor(1,0)-scdbor(1,ndbor))/(scdbor(0,0)-scdbor(0,ndbor))*(-1)
if bins lt rotmax then rots=bins else rots=rotmax
for i=0,rots-1 do dircofs(i)=((rots-i)*src+i*bld)/rots/ddens
if bins gt rotmax then dircofs(rots:*)=bld/ddens
yvals=fltarr(bins)
for i=0,bins-1 do yvals(bins-i-1)=scdbor(1,0)+total(dircofs(0:i))
xvals=findgen(bins)/ddens+scdbor(0,0)-ext
scdbor=[[transpose([[xvals],[yvals]])],[scdbor]]
end
if xranges(1,0) lt maxrange(1) then begin
ext=abs(maxrange(1)-xranges(1,0))
bins=ceil(ext*udens)
dircofs=fltarr(bins)
src=(scubor(1,-nubor)-scubor(1,-1))/(scubor(0,-nubor)-scubor(0,-1))
if bins lt rotmax then rots=bins else rots=rotmax
for i=0,rots-1 do dircofs(i)=((rots-i)*src+i*bru)/rots/udens
if bins gt rotmax then dircofs(rots:*)=bru/udens
yvals=fltarr(bins)
for i=0,bins-1 do yvals(i)=scubor(1,-1)+total(dircofs(0:i))
xvals=findgen(bins)/udens+scubor(0,-1)
scubor=[[transpose([[xvals],[yvals]])],[scubor]]
end
if xranges(1,1) lt maxrange(1) then begin
ext=abs(maxrange(1)-xranges(1,1))
bins=ceil(ext*ddens)
dircofs=fltarr(bins)
src=(scdbor(1,-ndbor)-scdbor(1,-1))/(scdbor(0,-ndbor)-scdbor(0,-1))
if bins lt rotmax then rots=bins else rots=rotmax
for i=0,rots-1 do dircofs(i)=((rots-i)*src+i*brd)/rots/ddens
if bins gt rotmax then dircofs(rots:*)=brd/ddens
yvals=fltarr(bins)
for i=0,bins-1 do yvals(i)=scdbor(1,-1)+total(dircofs(0:i))
xvals=findgen(bins)/ddens+scdbor(0,-1)
scdbor=[[transpose([[xvals],[yvals]])],[scdbor]]
end
if porder eq 0 then begin
optmatrix=fltarr(30)
maxdev=fltarr(30)
for i=1,30 do begin
fcubor=poly_fit(scubor(0,*),scubor(1,*),i,/double,yfit=ufit)
fcdbor=poly_fit(scdbor(0,*),scdbor(1,*),i,/double,yfit=dfit)
optmatrix(i-1)=sqrt(mean((scubor(1,*)-ufit)^2))+sqrt(mean((scdbor(1,*)-dfit)^2))
maxdev(i-1)=max(abs([reform(scubor(1,*)-ufit),reform(scdbor(1,*)-dfit)]))
end
mse=min(optmatrix)
tmpporder=where(optmatrix eq mse)+1
tmpporder=min(tmpporder)
mse=mse/2
mse=[mse,maxdev(tmpporder-1)]
end
fcubor=poly_fit(scubor(0,*),scubor(1,*),tmpporder,/double,yfit=ufit)
fcdbor=poly_fit(scdbor(0,*),scdbor(1,*),tmpporder,/double,yfit=dfit)
pmatrix=dblarr(tmpporder+1,vstep+1)
for i=0,vstep do pmatrix(*,i)=((vstep-i)*fcubor+i*fcdbor)/vstep
if keyword_set(edisp) then begin
plxrange=[min([min(scrbor(0,*)),min(sclbor(0,*)),min(scubor(0,*)),min(scdbor(0,*))]),max([max(scrbor(0,*)),max(sclbor(0,*)),max(scubor(0,*)),max(scdbor(0,*))])]
plyrange=[min([min(scrbor(1,*)),min(sclbor(1,*)),min(scubor(1,*)),min(scdbor(1,*))]),max([max(scrbor(1,*)),max(sclbor(1,*)),max(scubor(1,*)),max(scdbor(1,*))])]
bplot=plot(scubor(0,*),scubor(1,*),yrange=plyrange,xrange=plxrange,xtitle='x (mm)',ytitle='y (mm)',linestyle='none',symbol='+',name='Upper Border Extensions',color='red',margin=[0.05,0.05,0.3,0.1],dimension=[1200,1000],aspect_ratio=1,title='Border extensions '+disp)
bplot=plot(scdbor(0,*),scdbor(1,*),linestyle='none',symbol='+',name='Lower Border Extensions',color='green',/overplot)
bplot=plot(cubor(0,*),cubor(1,*),linestyle='none',symbol='o',/sym_filled,name='Upper Border',color='red',/overplot)
bplot=plot(cdbor(0,*),cdbor(1,*),linestyle='none',symbol='o',/sym_filled,name='Lower Border',color='green',/overplot)
bplot=plot(clbor(0,*),clbor(1,*),linestyle='none',symbol='o',/sym_filled,name='Left Border',color='blue',/overplot)
bplot=plot(crbor(0,*),crbor(1,*),linestyle='none',symbol='o',/sym_filled,name='Right Border',color='brown',/overplot)
bplot=plot(plxrange,plxrange*bldo+ald,/overplot,linestyle='dashed',name='Left&Right Border Fits')
leg=legend(vertical_alignment='top',horizontal_alignment='right',transparency=100)
bplot=plot(plxrange,plxrange*bluo+alu,/overplot,linestyle='dashed')
bplot=plot(plxrange,plxrange*brdo+ard,/overplot,linestyle='dashed')
bplot=plot(plxrange,plxrange*bruo+aru,/overplot,linestyle='dashed')
if trim(edisp) ne '1' then begin
print,'Writing '+edisp+'.png'
bplot.Save,edisp+'.png',compression=1
print,'Done'
end
bplot.close
end
return,pmatrix
end
