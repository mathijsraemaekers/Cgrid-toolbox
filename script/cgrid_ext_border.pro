pro cgrid_ext_border,cubor,cdbor,clbor,crbor,scubor=scubor,scdbor=scdbor,my=my
if not keyword_set(my) then my=[2,2,2,2]
nubor=n_elements(cubor)/2-1
ndbor=n_elements(cdbor)/2-1
if nubor gt 10 then nubor=10
if ndbor gt 10 then ndbor=10
if not keyword_set(disp) then disp=''
nrlbor=n_elements(clbor)/2
nrrbor=n_elements(crbor)/2
if my(2) eq 2 then sclbor=clbor(*,sort(clbor(1,*))) else sclbor=clbor
if my(3) eq 2 then scrbor=crbor(*,sort(crbor(1,*))) else scrbor=crbor
fitexy,sclbor(0,0:nrlbor/2-1),sclbor(1,0:nrlbor/2-1),ald,bld,x_sig=1,y_sig=1
fitexy,sclbor(0,nrlbor/2:*),sclbor(1,nrlbor/2:*),alu,blu,x_sig=1,y_sig=1
fitexy,scrbor(0,0:nrrbor/2-1),scrbor(1,0:nrrbor/2-1),ard,brd,x_sig=1,y_sig=1
fitexy,scrbor(0,nrrbor/2:*),scrbor(1,nrrbor/2:*),aru,bru,x_sig=1,y_sig=1
blu=1/blu
bld=1/bld
bru=1/bru*(-1)
brd=1/brd*(-1)
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
end
