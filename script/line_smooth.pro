function line_smooth,line,fwhm,sps=sps
syntx=n_params()
if syntx lt 2 then begin
print,'Smoothes a line'
print,'1:Input line (2,nrcoordinates)'
print,'2:The FWHM (in mm) used for smoothing'
print,'Keyword sps sets coordinate numbers that should remain static'
return,0
end
sigma=10*fwhm/2.355
distmatrix=distance_measure(line,/matrix)*10
kernel=gaussian_function(sigma,width=max(distmatrix)*2,/normalize)
distmatrix=distmatrix+max(distmatrix)
nrcoor=n_elements(line(0,*))
sline=fltarr(2,nrcoor)
for i=0,nrcoor-1 do for j=0,1 do begin
mp=kernel(round(distmatrix(i,*)))
mp=mp/total(mp)
sline(j,i)=total(line(j,*)*mp)
end
if keyword_set(sps) then sline(*,sps)=line(*,sps)
return,sline
end



