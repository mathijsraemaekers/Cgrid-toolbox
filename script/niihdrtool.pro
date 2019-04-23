pro niihdrtool,filename,disp_hdr=disp_hdr,fdata=fdata,hdrfile=hdrfile,hdrdat=hdrdat,sizeof_hdr=sizeof_hdr,dim_info=dim_info,dim1=dim1,dim2=dim2,dim3=dim3,dim4=dim4,dim5=dim5,dim6=dim6,dim7=dim7,dim8=dim8,intent_p1=intent_p1,intent_p2=intent_p2,intent_p3=intent_p3,intent_code=intent_code,datatype=datatype,bitpix=bitpix,slice_start=slice_start,pixdim1=pixdim1,pixdim2=pixdim2,pixdim3=pixdim3,pixdim4=pixdim4,pixdim5=pixdim5,pixdim6=pixdim6,pixdim7=pixdim7,pixdim8=pixdim8,vox_offset=vox_offset,scl_slope=scl_slope,scl_inter=scl_inter,slice_end=slice_end,slice_code=slice_code,xyzt_units=xyzt_units,cal_max=cal_max,cal_min=cal_min,slice_duration=slice_duration,toffset=toffset,descrip=descrip,aux_file=aux_file,qform_code=qform_code,sform_code=sform_code,quatern_b=quatern_b,quatern_c=quatern_c,quatern_d=quatern_d,qoffset_x=qoffset_x,qoffset_y=qoffset_y,qoffset_z=qoffset_z,srow_x1=srow_x1,srow_x2=srow_x2,srow_x3=srow_x3,srow_x4=srow_x4,srow_y1=srow_y1,srow_y2=srow_y2,srow_y3=srow_y3,srow_y4=srow_y4,srow_z1=srow_z1,srow_z2=srow_z2,srow_z3=srow_z3,srow_z4=srow_z4,intent_name=intent_name,magic=magic
syntx=n_params()
if syntx lt 1 then begin
print,'Usage:'
print,'Tool to alter and write nifti files:'
print,'Enter a filename to indicate the file you want to generate or change'
print,'If the file does not exist a new nifti file will be written
print,'Keyword /disp_hdr shows the header information.'
print,'Set keyword fdata to spicify the data you want to write.'
print,'Set keyword hdrfile if you want to use the header of another nifti file when writing the data,' 
print,'otherwise a standard nifti header template will be used.'
print,'Set keyword hdrdat to the name of the variable in which you want to store the header values'
print,'The title of every nifti field you see when using /disp_hdr can be set as keyword to change the header.'
return
end
if keyword_set(fdata) then nwdata=1 else nwdata=0

fileinfo=file_info(filename)
filesize=fileinfo.size
if filesize eq 0 then if keyword_set(hdrfile) eq 0 then tmpfilename='test'
if keyword_set(hdrfile) then tmpfilename=hdrfile
if filesize gt 0 then if keyword_set(hdrfile) eq 0 then tmpfilename=filename

if strpos(tmpfilename,'.gz') eq -1 then begin
if filesize ne 0 or keyword_set(hdrfile) then begin
filedat=bytarr(348)
rdbblk,tmpfilename,filedat
hdr=bytarr(float(filedat,108,1))
rdbblk,tmpfilename,hdr
tmphdr=hdr
end else begin
hdr=bytarr(352)
hdr(*)=[92,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,114,0,3,0,91,0,109,0,91,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,8,0,0,0,0,0,128,63,0,0,128,63,0,0,128,63,0,0,128,63,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,176,67,0,0,128,63,0,0,0,0,0,0,0,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,180,66,0,0,252,194,0,0,144,194,0,0,128,63,0,0,0,0,0,0,0,0,0,0,180,66,0,0,0,0,0,0,128,63,0,0,0,0,0,0,252,194,0,0,0,0,0,0,0,0,0,0,128,63,0,0,144,194,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,110,43,49,0,0,0,0,0]
tmphdr=hdr
end
end else begin
file_gunzip,tmpfilename,buffer=alldat
hdr=alldat(0:float(alldat,108,1))
tmphdr=hdr
end

if keyword_set(fdata) then begin
datinfo=size(fdata,/dimensions)
dim1=n_elements(datinfo)
if dim1 ge 1 then dim2=datinfo(0) else dim2=1
if dim1 ge 2 then dim3=datinfo(1) else dim3=1
if dim1 ge 3 then dim4=datinfo(2) else dim4=1
if dim1 ge 4 then dim5=datinfo(3) else dim5=1
if dim1 ge 5 then dim6=datinfo(4) else dim6=1
if dim1 ge 6 then dim7=datinfo(5) else dim7=1
if dim1 ge 7 then dim8=datinfo(6) else dim8=1
type=size(fdata,/type)
typetrans=[0,2,4,8,16,64,32,2,0,1792,0,0,512,768,1024,1280]
typebits=[0,8,16,32,32,64,64,8,0,128,0,0,16,32,64,64]
datatype=typetrans(type)
bitpix=typebits(type)
end
if keyword_set(fdata) eq 0 then begin
if filesize eq 0 then begin
print,'Filename does not exist: Need to set data keyword'
return
end
if filesize gt 0 then if strpos(filename,'.gz') eq -1 then begin
fdata=bytarr(filesize)
rdbblk,filename,fdata
fdata=fdata(float(fdata,108,1):*)
end
if filesize gt 0 then if strpos(filename,'.gz') ne -1 then fdata=alldat(float(alldat,108,1):*)
end
hdrinfo=strarr(4,59)
hdrinfo(*,0)=['sizeof_hdr','int','0','2']
hdrinfo(*,1)=['dim_info','byte','39','1']
hdrinfo(*,2)=['dim1','int','40','2']
hdrinfo(*,3)=['dim2','int','42','2']
hdrinfo(*,4)=['dim3','int','44','2']
hdrinfo(*,5)=['dim4','int','46','2']
hdrinfo(*,6)=['dim5','int','48','2']
hdrinfo(*,7)=['dim6','int','50','2']
hdrinfo(*,8)=['dim7','int','52','2']
hdrinfo(*,9)=['dim8','int','54','2']
hdrinfo(*,10)=['intent_p1','float','56','4']
hdrinfo(*,11)=['intent_p2','float','60','4']
hdrinfo(*,12)=['intent_p3','float','64','4']
hdrinfo(*,13)=['intent_code','int','68','2']
hdrinfo(*,14)=['datatype','int','70','2']
hdrinfo(*,15)=['bitpix','int','72','2']
hdrinfo(*,16)=['slice_start','int','74','2']
hdrinfo(*,17)=['pixdim1','float','76','4']
hdrinfo(*,18)=['pixdim2','float','80','4']
hdrinfo(*,19)=['pixdim3','float','84','4']
hdrinfo(*,20)=['pixdim4','float','88','4']
hdrinfo(*,21)=['pixdim5','float','92','4']
hdrinfo(*,22)=['pixdim6','float','96','4']
hdrinfo(*,23)=['pixdim7','float','100','4']
hdrinfo(*,24)=['pixdim8','float','104','4']
hdrinfo(*,25)=['vox_offset','float','108','4']
hdrinfo(*,26)=['scl_slope','float','112','4']
hdrinfo(*,27)=['scl_inter','float','116','4']
hdrinfo(*,28)=['slice_end','int','120','2']
hdrinfo(*,29)=['slice_code','byte','122','1']
hdrinfo(*,30)=['xyzt_units','byte','123','1']
hdrinfo(*,31)=['cal_max','float','124','4']
hdrinfo(*,32)=['cal_min','float','128','4']
hdrinfo(*,33)=['slice_duration','float','132','4']
hdrinfo(*,34)=['toffset','float','136','4']
hdrinfo(*,35)=['descrip','char','148','80']
hdrinfo(*,36)=['aux_file','char','228','24']
hdrinfo(*,37)=['qform_code','int','252','2']
hdrinfo(*,38)=['sform_code','int','254','2']
hdrinfo(*,39)=['quatern_b','float','256','4']
hdrinfo(*,40)=['quatern_c','float','260','4']
hdrinfo(*,41)=['quatern_d','float','264','4']
hdrinfo(*,42)=['qoffset_x','float','268','4']
hdrinfo(*,43)=['qoffset_y','float','272','4']
hdrinfo(*,44)=['qoffset_z','float','276','4']
hdrinfo(*,45)=['srow_x1','float','280','4']
hdrinfo(*,46)=['srow_x2','float','284','4']
hdrinfo(*,47)=['srow_x3','float','288','4']
hdrinfo(*,48)=['srow_x4','float','292','4']
hdrinfo(*,49)=['srow_y1','float','296','4']
hdrinfo(*,50)=['srow_y2','float','300','4']
hdrinfo(*,51)=['srow_y3','float','304','4']
hdrinfo(*,52)=['srow_y4','float','308','4']
hdrinfo(*,53)=['srow_z1','float','312','4']
hdrinfo(*,54)=['srow_z2','float','316','4']
hdrinfo(*,55)=['srow_z3','float','320','4']
hdrinfo(*,56)=['srow_z4','float','324','4']
hdrinfo(*,57)=['intent_name','char','328','16']
hdrinfo(*,58)=['magic','char','344','4']
hdrinfovals=intarr(size(hdrinfo,/dimensions))
hdrinfovals(2:3,*)=hdrinfo(2:3,*)
if n_elements(sizeof_hdr) ne 0 then hdr(hdrinfovals(2,0):hdrinfovals(2,0)+hdrinfovals(3,0)-1)=byte(fix(sizeof_hdr),0,2)
if n_elements(dim_info) ne 0 then hdr(hdrinfovals(2,1):hdrinfovals(2,1)+hdrinfovals(3,1)-1)=byte(dim_info)
if n_elements(dim1) ne 0 then hdr(hdrinfovals(2,2):hdrinfovals(2,2)+hdrinfovals(3,2)-1)=byte(fix(dim1),0,2)
if n_elements(dim2) ne 0 then hdr(hdrinfovals(2,3):hdrinfovals(2,3)+hdrinfovals(3,3)-1)=byte(fix(dim2),0,2)
if n_elements(dim3) ne 0 then hdr(hdrinfovals(2,4):hdrinfovals(2,4)+hdrinfovals(3,4)-1)=byte(fix(dim3),0,2)
if n_elements(dim4) ne 0 then hdr(hdrinfovals(2,5):hdrinfovals(2,5)+hdrinfovals(3,5)-1)=byte(fix(dim4),0,2)
if n_elements(dim5) ne 0 then hdr(hdrinfovals(2,6):hdrinfovals(2,6)+hdrinfovals(3,6)-1)=byte(fix(dim5),0,2)
if n_elements(dim6) ne 0 then hdr(hdrinfovals(2,7):hdrinfovals(2,7)+hdrinfovals(3,7)-1)=byte(fix(dim6),0,2)
if n_elements(dim7) ne 0 then hdr(hdrinfovals(2,8):hdrinfovals(2,8)+hdrinfovals(3,8)-1)=byte(fix(dim7),0,2)
if n_elements(dim8) ne 0 then hdr(hdrinfovals(2,9):hdrinfovals(2,9)+hdrinfovals(3,9)-1)=byte(fix(dim8),0,2)
if n_elements(intent_p1) ne 0 then hdr(hdrinfovals(2,10):hdrinfovals(2,10)+hdrinfovals(3,10)-1)=byte(float(intent_p1),0,4)
if n_elements(intent_p2) ne 0 then hdr(hdrinfovals(2,11):hdrinfovals(2,11)+hdrinfovals(3,11)-1)=byte(float(intent_p2),0,4)
if n_elements(intent_p3) ne 0 then hdr(hdrinfovals(2,12):hdrinfovals(2,12)+hdrinfovals(3,12)-1)=byte(float(intent_p3),0,4)
if n_elements(intent_code) ne 0 then hdr(hdrinfovals(2,13):hdrinfovals(2,13)+hdrinfovals(3,13)-1)=byte(fix(intent_code),0,2)
if n_elements(datatype) ne 0 then hdr(hdrinfovals(2,14):hdrinfovals(2,14)+hdrinfovals(3,14)-1)=byte(fix(datatype),0,2)
if n_elements(bitpix) ne 0 then hdr(hdrinfovals(2,15):hdrinfovals(2,15)+hdrinfovals(3,15)-1)=byte(fix(bitpix),0,2)
if n_elements(slice_start) ne 0 then hdr(hdrinfovals(2,16):hdrinfovals(2,16)+hdrinfovals(3,16)-1)=byte(fix(slice_start),0,2)
if n_elements(pixdim1) ne 0 then hdr(hdrinfovals(2,17):hdrinfovals(2,17)+hdrinfovals(3,17)-1)=byte(float(pixdim1),0,4)
if n_elements(pixdim2) ne 0 then hdr(hdrinfovals(2,18):hdrinfovals(2,18)+hdrinfovals(3,18)-1)=byte(float(pixdim2),0,4)
if n_elements(pixdim3) ne 0 then hdr(hdrinfovals(2,19):hdrinfovals(2,19)+hdrinfovals(3,19)-1)=byte(float(pixdim3),0,4)
if n_elements(pixdim4) ne 0 then hdr(hdrinfovals(2,20):hdrinfovals(2,20)+hdrinfovals(3,20)-1)=byte(float(pixdim4),0,4)
if n_elements(pixdim5) ne 0 then hdr(hdrinfovals(2,21):hdrinfovals(2,21)+hdrinfovals(3,21)-1)=byte(float(pixdim5),0,4)
if n_elements(pixdim6) ne 0 then hdr(hdrinfovals(2,22):hdrinfovals(2,22)+hdrinfovals(3,22)-1)=byte(float(pixdim6),0,4)
if n_elements(pixdim7) ne 0 then hdr(hdrinfovals(2,23):hdrinfovals(2,23)+hdrinfovals(3,23)-1)=byte(float(pixdim7),0,4)
if n_elements(pixdim8) ne 0 then hdr(hdrinfovals(2,24):hdrinfovals(2,24)+hdrinfovals(3,24)-1)=byte(float(pixdim8),0,4)
if n_elements(vox_offset) ne 0 then hdr(hdrinfovals(2,25):hdrinfovals(2,25)+hdrinfovals(3,25)-1)=byte(float(vox_offset),0,4)
if n_elements(scl_slope) ne 0 then hdr(hdrinfovals(2,26):hdrinfovals(2,26)+hdrinfovals(3,26)-1)=byte(float(scl_slope),0,4)
if n_elements(scl_inter) ne 0 then hdr(hdrinfovals(2,27):hdrinfovals(2,27)+hdrinfovals(3,27)-1)=byte(float(scl_inter),0,4)
if n_elements(slice_end) ne 0 then hdr(hdrinfovals(2,28):hdrinfovals(2,28)+hdrinfovals(3,28)-1)=byte(fix(slice_end),0,2)
if n_elements(slice_code) ne 0 then hdr(hdrinfovals(2,29):hdrinfovals(2,29)+hdrinfovals(3,29)-1)=byte(slice_code)
if n_elements(xyzt_units) ne 0 then hdr(hdrinfovals(2,30):hdrinfovals(2,30)+hdrinfovals(3,30)-1)=byte(slice_code)
if n_elements(cal_max) ne 0 then hdr(hdrinfovals(2,31):hdrinfovals(2,31)+hdrinfovals(3,31)-1)=byte(float(cal_max),0,4)
if n_elements(cal_min) ne 0 then hdr(hdrinfovals(2,32):hdrinfovals(2,32)+hdrinfovals(3,32)-1)=byte(float(cal_min),0,4)
if n_elements(slice_duration) ne 0 then hdr(hdrinfovals(2,33):hdrinfovals(2,33)+hdrinfovals(3,33)-1)=byte(float(slice_duration),0,4)
if n_elements(toffset) ne 0 then hdr(hdrinfovals(2,34):hdrinfovals(2,34)+hdrinfovals(3,34)-1)=byte(float(toffset),0,4)
if n_elements(descrip) ne 0 then descrip=[byte(descrip),bytarr(hdrinfovals(3,35))]
if n_elements(descrip) ne 0 then hdr(hdrinfovals(2,35):hdrinfovals(2,35)+hdrinfovals(3,35)-1)=descrip(0:hdrinfovals(3,35)-1)
if n_elements(aux_file) ne 0 then aux_file=[byte(aux_file),bytarr(hdrinfovals(3,36))]
if n_elements(aux_file) ne 0 then hdr(hdrinfovals(2,36):hdrinfovals(2,36)+hdrinfovals(3,36)-1)=aux_file(0:hdrinfovals(3,36)-1)
if n_elements(qform_code) ne 0 then hdr(hdrinfovals(2,37):hdrinfovals(2,37)+hdrinfovals(3,37)-1)=byte(fix(qform_code),0,2)
if n_elements(sform_code) ne 0 then hdr(hdrinfovals(2,38):hdrinfovals(2,38)+hdrinfovals(3,38)-1)=byte(fix(sform_code),0,2)
if n_elements(quatern_b) ne 0 then hdr(hdrinfovals(2,39):hdrinfovals(2,39)+hdrinfovals(3,39)-1)=byte(float(quatern_b),0,4)
if n_elements(quatern_c) ne 0 then hdr(hdrinfovals(2,40):hdrinfovals(2,40)+hdrinfovals(3,40)-1)=byte(float(quatern_c),0,4)
if n_elements(quatern_d) ne 0 then hdr(hdrinfovals(2,41):hdrinfovals(2,41)+hdrinfovals(3,41)-1)=byte(float(quatern_d),0,4)
if n_elements(qoffset_x) ne 0 then hdr(hdrinfovals(2,42):hdrinfovals(2,42)+hdrinfovals(3,42)-1)=byte(float(qoffset_x),0,4)
if n_elements(qoffset_y) ne 0 then hdr(hdrinfovals(2,43):hdrinfovals(2,43)+hdrinfovals(3,43)-1)=byte(float(qoffset_y),0,4)
if n_elements(qoffset_z) ne 0 then hdr(hdrinfovals(2,44):hdrinfovals(2,44)+hdrinfovals(3,44)-1)=byte(float(qoffset_z),0,4)
if n_elements(srow_x1) ne 0 then hdr(hdrinfovals(2,45):hdrinfovals(2,45)+hdrinfovals(3,45)-1)=byte(float(srow_x1),0,4)
if n_elements(srow_x2) ne 0 then hdr(hdrinfovals(2,46):hdrinfovals(2,46)+hdrinfovals(3,46)-1)=byte(float(srow_x2),0,4)
if n_elements(srow_x3) ne 0 then hdr(hdrinfovals(2,47):hdrinfovals(2,47)+hdrinfovals(3,47)-1)=byte(float(srow_x3),0,4)
if n_elements(srow_x4) ne 0 then hdr(hdrinfovals(2,48):hdrinfovals(2,48)+hdrinfovals(3,48)-1)=byte(float(srow_x4),0,4)
if n_elements(srow_y1) ne 0 then hdr(hdrinfovals(2,49):hdrinfovals(2,49)+hdrinfovals(3,49)-1)=byte(float(srow_y1),0,4)
if n_elements(srow_y2) ne 0 then hdr(hdrinfovals(2,50):hdrinfovals(2,50)+hdrinfovals(3,50)-1)=byte(float(srow_y2),0,4)
if n_elements(srow_y3) ne 0 then hdr(hdrinfovals(2,51):hdrinfovals(2,51)+hdrinfovals(3,51)-1)=byte(float(srow_y3),0,4)
if n_elements(srow_y4) ne 0 then hdr(hdrinfovals(2,52):hdrinfovals(2,52)+hdrinfovals(3,52)-1)=byte(float(srow_y4),0,4)
if n_elements(srow_z1) ne 0 then hdr(hdrinfovals(2,53):hdrinfovals(2,53)+hdrinfovals(3,53)-1)=byte(float(srow_z1),0,4)
if n_elements(srow_z2) ne 0 then hdr(hdrinfovals(2,54):hdrinfovals(2,54)+hdrinfovals(3,54)-1)=byte(float(srow_z2),0,4)
if n_elements(srow_z3) ne 0 then hdr(hdrinfovals(2,55):hdrinfovals(2,55)+hdrinfovals(3,55)-1)=byte(float(srow_z3),0,4)
if n_elements(srow_z4) ne 0 then hdr(hdrinfovals(2,56):hdrinfovals(2,56)+hdrinfovals(3,56)-1)=byte(float(srow_z4),0,4)
if n_elements(intent_name) ne 0 then intent_name=[byte(intent_name),bytarr(hdrinfovals(3,57))]
if n_elements(intent_name) ne 0 then hdr(hdrinfovals(2,57):hdrinfovals(2,57)+hdrinfovals(3,57)-1)=intent_name(0:hdrinfovals(3,57)-1)
if n_elements(magic) ne 0 then magic=[byte(magic),bytarr(hdrinfovals(3,58))]
if n_elements(magic) ne 0 then hdr(hdrinfovals(2,58):hdrinfovals(2,58)+hdrinfovals(3,58)-1)=magic(0:hdrinfovals(3,58)-1)

ints=where(hdrinfo(1,*) eq 'int')
floats=where(hdrinfo(1,*) eq 'float')
chars=where(hdrinfo(1,*) eq 'char')
bytes=where(hdrinfo(1,*) eq 'byte')
intvals=intarr(n_elements(ints))
floatvals=fltarr(n_elements(floats))
charvals=strarr(n_elements(chars))
for i=0,n_elements(ints)-1 do intvals(i)=fix(hdr,hdrinfo(2,ints(i)),1)
for i=0,n_elements(floats)-1 do floatvals(i)=float(hdr,hdrinfo(2,floats(i)),1)
for i=0,n_elements(chars)-1 do charvals(i)=string(hdr(hdrinfo(2,chars(i)):fix(hdrinfo(2,chars(i)))+fix(hdrinfo(3,chars(i)))-1))
bytevals=hdr(hdrinfo(2,bytes))
info=strarr(59)
info(ints)=strcompress(string(intvals),/remove_all)
info(floats)=strcompress(string(floatvals),/remove_all)
info(bytes)=strcompress(string(fix(bytevals)),/remove_all)
info(chars)=charvals
hdrdat=info
if keyword_set(disp_hdr) then begin
dattypes=strarr(2,18)
dattypes(*,0)=['DT_UNKNOWN','0']
dattypes(*,1)=['DT_BINARY','1']
dattypes(*,2)=['DT_UNSIGNED_CHAR','2']
dattypes(*,3)=['DT_SIGNED_SHORT','4']
dattypes(*,4)=['DT_SIGNED_INT','8']
dattypes(*,5)=['DT_FLOAT','16']
dattypes(*,6)=['DT_COMPLEX','32']
dattypes(*,7)=['DT_DOUBLE','64']
dattypes(*,8)=['DT_RGB','128']
dattypes(*,9)=['DT_ALL','255']
dattypes(*,10)=['INT8','256']
dattypes(*,11)=['UINT16','512']
dattypes(*,12)=['DT_UINT32','768']
dattypes(*,13)=['DT_INT64','1024']
dattypes(*,14)=['DT_UINT64','1280']
dattypes(*,15)=['DT_FLOAT128','1536']
dattypes(*,16)=['DT_COMPLEX128','1792']
dattypes(*,17)=['DT_COMPLEX256','2048']
intcodes=strarr(2,37)
intcodes(*,0)=['NIFTI_INTENT_NONE','0']
intcodes(*,1)=['NIFTI_INTENT_CORREL','2']
intcodes(*,2)=['NIFTI_INTENT_TTEST','3']
intcodes(*,3)=['NIFTI_INTENT_FTEST','4']
intcodes(*,4)=['NIFTI_INTENT_ZSCORE','5']
intcodes(*,5)=['NIFTI_INTENT_CHISQ','6']
intcodes(*,6)=['NIFTI_INTENT_BETA','7']
intcodes(*,7)=['NIFTI_INTENT_BINOM','8']
intcodes(*,8)=['NIFTI_INTENT_GAMMA','9']
intcodes(*,9)=['NIFTI_INTENT_POISSON','10']
intcodes(*,10)=['NIFTI_INTENT_NORMAL','11']
intcodes(*,11)=['NIFTI_INTENT_FTEST_NONC','12']
intcodes(*,12)=['NIFTI_INTENT_CHISQ_NONC','13']
intcodes(*,13)=['NIFTI_INTENT_LOGISTIC','14']
intcodes(*,14)=['NIFTI_INTENT_LAPLACE','15']
intcodes(*,15)=['NIFTI_INTENT_UNIFORM','16']
intcodes(*,16)=['NIFTI_INTENT_TTEST_NONC','17']
intcodes(*,17)=['NIFTI_INTENT_WEIBULL','18']
intcodes(*,18)=['NIFTI_INTENT_CHI','19']
intcodes(*,19)=['NIFTI_INTENT_INVGAUSS','20']
intcodes(*,20)=['NIFTI_INTENT_EXTVAL','21']
intcodes(*,21)=['NIFTI_INTENT_PVAL','22']
intcodes(*,22)=['NIFTI_INTENT_LOGPVAL','23']
intcodes(*,23)=['NIFTI_INTENT_LOG10PVAL','24']
intcodes(*,24)=['NIFTI_FIRST_STATCODE','2']
intcodes(*,25)=['NIFTI_LAST_STATCODE','24']
intcodes(*,26)=['NIFTI_INTENT_ESTIMATE','1001']
intcodes(*,27)=['NIFTI_INTENT_LABEL','1002']
intcodes(*,28)=['NIFTI_INTENT_NEURONAME','1003']
intcodes(*,29)=['NIFTI_INTENT_GENMATRIX','1004']
intcodes(*,30)=['NIFTI_INTENT_SYMMATRIX','1005']
intcodes(*,31)=['NIFTI_INTENT_DISPVECT','1006']
intcodes(*,32)=['NIFTI_INTENT_VECTOR','1007']
intcodes(*,33)=['NIFTI_INTENT_POINTSET','1008']
intcodes(*,34)=['NIFTI_INTENT_TRIANGLE','1009']
intcodes(*,35)=['NIFTI_INTENT_QUATERNION','1010']
intcodes(*,36)=['NIFTI_INTENT_DIMLESS','1011']
xformcodes=strarr(2,5)
xformcodes(*,0)=['NIFTI_XFORM_UNKNOWN','0']
xformcodes(*,1)=['NIFTI_XFORM_SCANNER_ANAT','1']
xformcodes(*,2)=['NIFTI_XFORM_ALIGNED_ANAT','2']
xformcodes(*,3)=['NIFTI_XFORM_TALAIRACH','3']
xformcodes(*,4)=['NIFTI_XFORM_MNI_152','4']
units=strarr(3,28)
units(*,0)=['NIFTI_UNITS_UNKNOWN','NIFTI_UNITS_UNKNOWN','0']
units(*,1)=['NIFTI_UNITS_METER','NIFTI_UNITS_UNKNOWN','1']
units(*,2)=['NIFTI_UNITS_MM','NIFTI_UNITS_UNKNOWN','2']
units(*,3)=['NIFTI_UNITS_MICRON','NIFTI_UNITS_UNKNOWN','3']
units(*,4)=['NIFTI_UNITS_UNKNOWN','NIFTI_UNITS_SEC','8']
units(*,5)=['NIFTI_UNITS_METER','NIFTI_UNITS_SEC','9']
units(*,6)=['NIFTI_UNITS_MM','NIFTI_UNITS_SEC','10']
units(*,7)=['NIFTI_UNITS_MICRON','NIFTI_UNITS_SEC','11']
units(*,8)=['NIFTI_UNITS_UNKNOWN','NIFTI_UNITS_MSEC','16']
units(*,9)=['NIFTI_UNITS_METER','NIFTI_UNITS_MSEC','17']
units(*,10)=['NIFTI_UNITS_MM','NIFTI_UNITS_MSEC','18']
units(*,11)=['NIFTI_UNITS_MICRON','NIFTI_UNITS_MSEC','19']
units(*,12)=['NIFTI_UNITS_UNKNOWN','NIFTI_UNITS_USEC','24']
units(*,13)=['NIFTI_UNITS_METER','NIFTI_UNITS_USEC','25']
units(*,14)=['NIFTI_UNITS_MM','NIFTI_UNITS_USEC','26']
units(*,15)=['NIFTI_UNITS_MICRON','NIFTI_UNITS_USEC','27']
units(*,16)=['NIFTI_UNITS_UNKNOWN','NIFTI_UNITS_HZ','32']
units(*,17)=['NIFTI_UNITS_METER','NIFTI_UNITS_HZ','33']
units(*,18)=['NIFTI_UNITS_MM','NIFTI_UNITS_HZ','34']
units(*,19)=['NIFTI_UNITS_MICRON','NIFTI_UNITS_HZ','35']
units(*,20)=['NIFTI_UNITS_UNKNOWN','NIFTI_UNITS_PPM','40']
units(*,21)=['NIFTI_UNITS_METER','NIFTI_UNITS_PPM','41']
units(*,22)=['NIFTI_UNITS_MM','NIFTI_UNITS_PPM','42']
units(*,23)=['NIFTI_UNITS_MICRON','NIFTI_UNITS_PPM','43']
units(*,24)=['NIFTI_UNITS_UNKNOWN','NIFTI_UNITS_RADS','48']
units(*,25)=['NIFTI_UNITS_METER','NIFTI_UNITS_RADS','49']
units(*,26)=['NIFTI_UNITS_MM','NIFTI_UNITS_RADS','50']
units(*,27)=['NIFTI_UNITS_MICRON','NIFTI_UNITS_RADS','51']
slice=strarr(2,7)
slice(*,0)=['NIFTI_SLICE_UNKNOWN','0']
slice(*,1)=['NIFTI_SLICE_SEQ_INC','1']
slice(*,2)=['NIFTI_SLICE_SEQ_DEC','2']
slice(*,3)=['NIFTI_SLICE_ALT_INC','3']
slice(*,4)=['NIFTI_SLICE_ALT_DEC','4']
slice(*,5)=['NIFTI_SLICE_ALT_INC2','5']
slice(*,6)=['NIFTI_SLICE_ALT_DEC2','6']
dimcodes=strarr(4,64)
dimcodes(*,0)=['0','FREQ_DIM=UNKNOWN','PHASE_DIM=UNKNOWN','SLICE_DIM=UNKNOWN']
dimcodes(*,1)=['1','FREQ_DIM=1','PHASE_DIM=UNKNOWN','SLICE_DIM=UNKNOWN']
dimcodes(*,2)=['2','FREQ_DIM=2','PHASE_DIM=UNKNOWN','SLICE_DIM=UNKNOWN']
dimcodes(*,3)=['3','FREQ_DIM=3','PHASE_DIM=UNKNOWN','SLICE_DIM=UNKNOWN']
dimcodes(*,4)=['4','FREQ_DIM=UNKNOWN','PHASE_DIM=1','SLICE_DIM=UNKNOWN']
dimcodes(*,5)=['5','FREQ_DIM=1','PHASE_DIM=1','SLICE_DIM=UNKNOWN']
dimcodes(*,6)=['6','FREQ_DIM=2','PHASE_DIM=1','SLICE_DIM=UNKNOWN']
dimcodes(*,7)=['7','FREQ_DIM=3','PHASE_DIM=1','SLICE_DIM=UNKNOWN']
dimcodes(*,8)=['8','FREQ_DIM=UNKNOWN','PHASE_DIM=2','SLICE_DIM=UNKNOWN']
dimcodes(*,9)=['9','FREQ_DIM=1','PHASE_DIM=2','SLICE_DIM=UNKNOWN']
dimcodes(*,10)=['10','FREQ_DIM=2','PHASE_DIM=2','SLICE_DIM=UNKNOWN']
dimcodes(*,11)=['11','FREQ_DIM=3','PHASE_DIM=2','SLICE_DIM=UNKNOWN']
dimcodes(*,12)=['12','FREQ_DIM=UNKNOWN','PHASE_DIM=3','SLICE_DIM=UNKNOWN']
dimcodes(*,13)=['13','FREQ_DIM=1','PHASE_DIM=3','SLICE_DIM=UNKNOWN']
dimcodes(*,14)=['14','FREQ_DIM=2','PHASE_DIM=3','SLICE_DIM=UNKNOWN']
dimcodes(*,15)=['15','FREQ_DIM=3','PHASE_DIM=3','SLICE_DIM=UNKNOWN']
dimcodes(*,16)=['16','FREQ_DIM=UNKNOWN','PHASE_DIM=UNKNOWN','SLICE_DIM=1']
dimcodes(*,17)=['17','FREQ_DIM=1','PHASE_DIM=UNKNOWN','SLICE_DIM=1']
dimcodes(*,18)=['18','FREQ_DIM=2','PHASE_DIM=UNKNOWN','SLICE_DIM=1']
dimcodes(*,19)=['19','FREQ_DIM=3','PHASE_DIM=UNKNOWN','SLICE_DIM=1']
dimcodes(*,20)=['20','FREQ_DIM=UNKNOWN','PHASE_DIM=1','SLICE_DIM=1']
dimcodes(*,21)=['21','FREQ_DIM=1','PHASE_DIM=1','SLICE_DIM=1']
dimcodes(*,22)=['22','FREQ_DIM=2','PHASE_DIM=1','SLICE_DIM=1']
dimcodes(*,23)=['23','FREQ_DIM=3','PHASE_DIM=1','SLICE_DIM=1']
dimcodes(*,24)=['24','FREQ_DIM=UNKNOWN','PHASE_DIM=2','SLICE_DIM=1']
dimcodes(*,25)=['25','FREQ_DIM=1','PHASE_DIM=2','SLICE_DIM=1']
dimcodes(*,26)=['26','FREQ_DIM=2','PHASE_DIM=2','SLICE_DIM=1']
dimcodes(*,27)=['27','FREQ_DIM=3','PHASE_DIM=2','SLICE_DIM=1']
dimcodes(*,28)=['28','FREQ_DIM=UNKNOWN','PHASE_DIM=3','SLICE_DIM=1']
dimcodes(*,29)=['29','FREQ_DIM=1','PHASE_DIM=3','SLICE_DIM=1']
dimcodes(*,30)=['30','FREQ_DIM=2','PHASE_DIM=3','SLICE_DIM=1']
dimcodes(*,31)=['31','FREQ_DIM=3','PHASE_DIM=3','SLICE_DIM=1']
dimcodes(*,32)=['32','FREQ_DIM=UNKNOWN','PHASE_DIM=UNKNOWN','SLICE_DIM=2']
dimcodes(*,33)=['33','FREQ_DIM=1','PHASE_DIM=UNKNOWN','SLICE_DIM=2']
dimcodes(*,34)=['34','FREQ_DIM=2','PHASE_DIM=UNKNOWN','SLICE_DIM=2']
dimcodes(*,35)=['35','FREQ_DIM=3','PHASE_DIM=UNKNOWN','SLICE_DIM=2']
dimcodes(*,36)=['36','FREQ_DIM=UNKNOWN','PHASE_DIM=1','SLICE_DIM=2']
dimcodes(*,37)=['37','FREQ_DIM=1','PHASE_DIM=1','SLICE_DIM=2']
dimcodes(*,38)=['38','FREQ_DIM=2','PHASE_DIM=1','SLICE_DIM=2']
dimcodes(*,39)=['39','FREQ_DIM=3','PHASE_DIM=1','SLICE_DIM=2']
dimcodes(*,40)=['40','FREQ_DIM=UNKNOWN','PHASE_DIM=2','SLICE_DIM=2']
dimcodes(*,41)=['41','FREQ_DIM=1','PHASE_DIM=2','SLICE_DIM=2']
dimcodes(*,42)=['42','FREQ_DIM=2','PHASE_DIM=2','SLICE_DIM=2']
dimcodes(*,43)=['43','FREQ_DIM=3','PHASE_DIM=2','SLICE_DIM=2']
dimcodes(*,44)=['44','FREQ_DIM=UNKNOWN','PHASE_DIM=3','SLICE_DIM=2']
dimcodes(*,45)=['45','FREQ_DIM=1','PHASE_DIM=3','SLICE_DIM=2']
dimcodes(*,46)=['46','FREQ_DIM=2','PHASE_DIM=3','SLICE_DIM=2']
dimcodes(*,47)=['47','FREQ_DIM=3','PHASE_DIM=3','SLICE_DIM=2']
dimcodes(*,48)=['48','FREQ_DIM=UNKNOWN','PHASE_DIM=UNKNOWN','SLICE_DIM=3']
dimcodes(*,49)=['49','FREQ_DIM=1','PHASE_DIM=UNKNOWN','SLICE_DIM=3']
dimcodes(*,50)=['50','FREQ_DIM=2','PHASE_DIM=UNKNOWN','SLICE_DIM=3']
dimcodes(*,51)=['51','FREQ_DIM=3','PHASE_DIM=UNKNOWN','SLICE_DIM=3']
dimcodes(*,52)=['52','FREQ_DIM=UNKNOWN','PHASE_DIM=1','SLICE_DIM=3']
dimcodes(*,53)=['53','FREQ_DIM=1','PHASE_DIM=1','SLICE_DIM=3']
dimcodes(*,54)=['54','FREQ_DIM=2','PHASE_DIM=1','SLICE_DIM=3']
dimcodes(*,55)=['55','FREQ_DIM=3','PHASE_DIM=1','SLICE_DIM=3']
dimcodes(*,56)=['56','FREQ_DIM=UNKNOWN','PHASE_DIM=2','SLICE_DIM=3']
dimcodes(*,57)=['57','FREQ_DIM=1','PHASE_DIM=2','SLICE_DIM=3']
dimcodes(*,58)=['58','FREQ_DIM=2','PHASE_DIM=2','SLICE_DIM=3']
dimcodes(*,59)=['59','FREQ_DIM=3','PHASE_DIM=2','SLICE_DIM=3']
dimcodes(*,60)=['60','FREQ_DIM=UNKNOWN','PHASE_DIM=3','SLICE_DIM=3']
dimcodes(*,61)=['61','FREQ_DIM=1','PHASE_DIM=3','SLICE_DIM=3']
dimcodes(*,62)=['62','FREQ_DIM=2','PHASE_DIM=3','SLICE_DIM=3']
dimcodes(*,63)=['63','FREQ_DIM=3','PHASE_DIM=3','SLICE_DIM=3']
info(chars)='"'+charvals+'"'
if max(where(fix(dattypes(1,*)) eq fix(info(14)))) ne -1 then info(14)=info(14)+'('+dattypes(0,where(fix(dattypes(1,*)) eq fix(info(14))))+')'
if max(where(fix(intcodes(1,*)) eq fix(info(13)))) ne -1 then info(13)=info(13)+'('+intcodes(0,where(fix(intcodes(1,*)) eq fix(info(13))))+')'
if max(where(fix(xformcodes(1,*)) eq fix(info(37)))) ne -1 then info(37)=info(37)+'('+xformcodes(0,where(fix(xformcodes(1,*)) eq fix(info(37))))+')'
if max(where(fix(xformcodes(1,*)) eq fix(info(38)))) ne -1 then info(38)=info(38)+'('+xformcodes(0,where(fix(xformcodes(1,*)) eq fix(info(38))))+')'
if max(where(fix(units(2,*)) eq fix(info(30)))) ne -1 then info(30)=info(30)+'('+units(0,where(fix(units(2,*)) eq fix(info(30))))+','+units(1,where(fix(units(2,*)) eq fix(info(30))))+')'
if max(where(fix(slice(1,*)) eq fix(info(29)))) ne -1 then info(29)=info(29)+'('+slice(0,where(fix(slice(1,*)) eq fix(info(29))))+')'
if max(where(fix(dimcodes(0,*)) eq fix(info(1)))) ne -1 then info(1)=info(1)+'('+dimcodes(1,where(fix(dimcodes(0,*)) eq fix(info(1))))+','+dimcodes(2,where(fix(dimcodes(0,*)) eq fix(info(1))))+','+dimcodes(3,where(fix(dimcodes(0,*)) eq fix(info(1))))+')'
print,transpose(strcompress(string(indgen(59)),/remove_all))+':  '+hdrinfo(0,*)+'    =  '+info
end
get_lun,unit
if strpos(filename,'.gz') eq -1 then begin
if nwdata eq 1 then begin
openw,unit,filename
writeu,unit,hdr,fdata
end
if nwdata eq 0 then if max(abs(tmphdr-hdr)) ne 0 then begin
openu,unit,filename
writeu,unit,hdr
end
end else begin


end
close,unit
free_lun,unit
end


