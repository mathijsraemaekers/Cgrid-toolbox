function devpoint_remove,border,tres
syntx=n_params()
if syntx lt 2 then begin
print,'Routine for returning the indices of data points belonging to the main cluster'
print,'The data points (dim,nrpoints)'
print,'The thresshold for exlusion'
return,0
end
maxval=999999.
nrbor=n_elements(border(0,*))
distmatrix=distance_measure(border,/matrix)
class=intarr(nrbor)
distmatrix(indgen(nrbor),indgen(nrbor))=maxval
classnr=0
while(min(distmatrix)) ne maxval do begin
classnr=classnr+1
testmatrix=intarr(nrbor,nrbor)
seed=min(distmatrix,wmin)
testmatrix(wmin)=1
for j=0,nrbor-1 do begin
testx=total(testmatrix,1)
testy=total(testmatrix,2)
for i=0,nrbor-1 do if testx(i) ne 0 then begin
inc=where(distmatrix(*,i) lt tres,/NULL)
if inc ne !NULL then testmatrix(inc,i)=1
end
for i=0,nrbor-1 do if testy(i) ne 0 then begin
inc=where(distmatrix(i,*) lt tres,/NULL)
if inc ne !NULL then testmatrix(i,inc)=1
end
end
distmatrix(where(testx ne 0 or testy ne 0,/NULL),*)=maxval
distmatrix(*,where(testy ne 0 or testx ne 0,/NULL))=maxval
class(where(testx ne 0 or testy ne 0))=classnr
end
tmp=max(histogram(class,min=1,binsize=1),wmax)
return,where(class eq wmax+1)
end

