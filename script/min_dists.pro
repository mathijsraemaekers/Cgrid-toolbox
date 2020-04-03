function min_dists,x,y,x1,x2,y1,y2
syntx=n_params()
if syntx lt 6 then begin
print,'Returns the minimum distances between points and line segments'
print,'Syntax not right; parms are :'
print,'1: The x-coordinate(s) of the points'
print,'2: The y-coordinate(s) of the points'
print,'3: The first x-coordinate(s) of the line segments'
print,'4: The second x-coordinate(s) of the line segments'
print,'5: The first y-coordinate(s) of the line segments'
print,'6: The second y-coordinate(s) of the line segments'
return,0
endif
px=x2-x1
py=y2-y1
nor=px^2+py^2
u=((x-x1)*px+(y-y1)*py)/nor
u(where(u gt 1,/NULL))=1
u(where(u lt 0,/NULL))=0
ox=x1+u*px
oy=y1+u*py
dx=ox-x
dy=oy-y
d=sqrt(dx^2+dy^2)
return,d
end
