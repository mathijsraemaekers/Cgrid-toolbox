funtion angular_distortion posmatrix

sposmatrix=size(posmatrix,/dimensions)
vecmat=fltarr([size(posmatrix,/dimensions),4])
op=fltarr([sposmatrix(0:2),4])
vecmat(*,*,*,*,0)=shift(posmatrix,1,0,0,0)-posmatrix
vecmat(*,*,*,*,1)=shift(posmatrix,-1,0,0,0)-posmatrix
vecmat(*,*,*,*,2)=shift(posmatrix,0,1,0,0)-posmatrix
vecmat(*,*,*,*,3)=shift(posmatrix,0,-1,0,0)-posmatrix
vecmat(sposmatrix(0)-1,*,*,*,1)=!VALUES.F_NAN
vecmat(0,*,*,*,0)=!VALUES.F_NAN
vecmat(*,sposmatrix(1)-1,*,*,3)=!VALUES.F_NAN
vecmat(*,0,*,*,2)=!VALUES.F_NAN
vecs1=transpose(reform(vecmat(*,*,*,*,0),product(sposmatrix(0:2)),3))
vecs2=transpose(reform(vecmat(*,*,*,*,1),product(sposmatrix(0:2)),3))
vecs3=transpose(reform(vecmat(*,*,*,*,2),product(sposmatrix(0:2)),3))
vecs4=transpose(reform(vecmat(*,*,*,*,3),product(sposmatrix(0:2)),3))
op(*,*,*,0)=abs(angle_between_two_vectors(vecs1,vecs3)/(2*!PI)*360.-90)
op(*,*,*,1)=abs(angle_between_two_vectors(vecs1,vecs4)/(2*!PI)*360.-90)
op(*,*,*,2)=abs(angle_between_two_vectors(vecs2,vecs3)/(2*!PI)*360.-90)
op(*,*,*,3)=abs(angle_between_two_vectors(vecs2,vecs4)/(2*!PI)*360.-90)
mop=mean(op,dimension=4,/NAN)
return,mop
end

