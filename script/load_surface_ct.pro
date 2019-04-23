pro load_surface_ct
ct=fltarr(3,256)
for i=0,2 do ct(i,0:127)=findgen(128)/127.*255
ct(0,136:195)=255
ct(2,196:*)=255
for i=1,2 do ct(i,136:195)=findgen(60)/59.*255
for i=0,1 do ct(i,196:*)=findgen(60)/59.*255
ct=fix(ct)
ct(*,128)=[255,255,255];white
ct(*,129)=[0,255,0];green
ct(*,130)=[255,255,0];yellow
ct(*,131)=[128,0,128];purple
ct(*,132)=[255,192,203];pink
ct(*,133)=[165,42,42];brown
ct(*,134)=[255,165,0];orange
ct(*,135)=[0,255,255];cyan
tvlct,ct(0,*),ct(1,*),ct(2,*)
end