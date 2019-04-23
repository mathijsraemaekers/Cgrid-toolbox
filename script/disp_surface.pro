pro disp_surface,coordata,topodat,view=view,overlay=overlay,size=size,thresshold=thresshold,winnr=winnr,vmap=vmap,magfact=magfact,retmap=retmap,leavewin=leavewin,pic=pic
syntx=n_params()
if syntx lt 2 then begin
print,'Syntax not right; parms are :'
print,'1: Coordinate data in format 4,nrcoordinates '
print,'2: Topology data in format 3,nrvertices '
print,'Keyword "view" sets the viewing direction:'
print,'left,right,top,bottem,front,back'
print,'Keyword "winnr" sets window number'
print,'Keyword "overlay" for an overlay'
print,'Keyword "thresshold" for thresshold of the overlay'
print,'Keyword "size" for the size of the image'
print,'Keyword "vmap for a roi underlap'
print,'Keyword "magfact" for the magnification factor'
print,'Keyword "/retmap" for using polar angle color palette'
print,'Keyword "/leavewin" to plot in existing window'
return
ENDIF
if not keyword_set(size) then size=500.
if not keyword_set(view) then view='back'
if not keyword_set(winnr) then winnr=0
if not keyword_set(magfact) then magfact=1.0
if not keyword_set(thresshold) then thresshold=0
nrtopol=n_elements(topodat)/3
tmptopo=lonarr(4,nrtopol)
tmptopo(0,*)=3
tmptopo(1:*,*)=topodat
tmptopo=reform(tmptopo,4*nrtopol)
viewc=['front','back','left','right','top','bottem']
viewsx=[0,0,0,0,90,270]
viewsz=[180,0,90,270,90,90]
ax=viewsx(where(viewc eq view))
az=viewsz(where(viewc eq view))
fov=[[min(coordata(1,*)),max(coordata(1,*))],[min(coordata(2,*)),max(coordata(2,*))],[min(coordata(3,*)),max(coordata(3,*))]]/float(magfact)
sizes=fov(1,*)-fov(0,*)
if view eq 'front' or view eq 'back' then ratio=sizes(0)/sizes(2)
if view eq 'top' or view eq 'bottem' then ratio=sizes(1)/sizes(0)
if view eq 'left' or view eq 'right' then ratio=sizes(1)/sizes(2)
if not keyword_set(leavewin) then window,winnr,xsize=size*ratio,ysize=size
SCALE3,XRANGE=[fov(0,0),fov(1,0)],YRANGE=[fov(0,1),fov(1,1)],ZRANGE=[fov(0,2),fov(1,2)],ax=ax,az=az
background=(polyshade(coordata(1:*,*),tmptopo,/t3d,xsize=size*ratio,ysize=size))/2
if keyword_set(vmap) then begin
if max(vmap) gt 8 then print,'Too many areas for color table, only the first 8 are displayed correctly'
vmapoverlay=polyshade(coordata(1:*,*),tmptopo,shades=vmap,/t3d,xsize=size*ratio,ysize=size)
pixover=where(vmapoverlay ne 0)
if max(pixover) ne -1 then background(pixover)=vmapoverlay(pixover)+127
end
if keyword_set(overlay) then begin 
load_surface_ct
posvox=where(overlay ge thresshold)
negvox=where(overlay le -thresshold)
if max(posvox) ne -1 then begin
posoverlay=fltarr(n_elements(overlay))
posoverlay(posvox)=(float(overlay(posvox))-min(overlay(posvox)))/max(overlay(posvox))*58.+1;+136
pospic=polyshade(coordata(1:*,*),tmptopo,shades=posoverlay,/t3d,xsize=size*ratio,ysize=size)
end
if max(negvox) ne -1 then begin 
negoverlay=fltarr(n_elements(overlay))
negoverlay(negvox)=(-overlay(negvox)+max(overlay(negvox)))/(max(-overlay(negvox)))*58.+1;+196
negpic=polyshade(coordata(1:*,*),tmptopo,shades=negoverlay,/t3d,xsize=size*ratio,ysize=size)
end
end
if keyword_set(overlay) then if max(negvox) ne -1 then begin
negover=where(negpic ne 0)
if max(negover) ne -1 then background(negover)=negpic(negover)+196
end
if keyword_set(overlay) then if max(posvox) ne -1 then begin
posover=where(pospic ne 0)
if max(posover) ne -1 then background(posover)=pospic(posover)+136
end
if keyword_set(retmap) then load_retmap_ct
if keyword_set(overlay) then background(70:169,50:59)=fix(congrid(rebin(indgen(58)+136,58,2,/sample),100,10))
tv,background
if keyword_set(overlay) then xyouts,50,50,[trim(min(overlay(where(overlay gt thresshold))))+'                       '+trim(max(overlay))],/device,color=126
pic=background
end
congrid(indgen(58)+136,50,10)
