pro readmgh,filename,data
syntx=n_params()
if syntx lt 2 then begin
print,'Syntax not right; parms are :'
print,'1: full filename of the to be (single) loaded mgh- or mgz-file'
print,'2: matrix in which the file will be stored'
return
ENDIF

if strmatch(filename,'*.mgz',/fold_case) eq 1 then begin
  tmp=strsplit(filename,'.',/extract)
  newfile=strjoin([tmp[0],'.mgh'])
  file_gunzip,filename,newfile
  filename=newfile
endif

hdata=read_binary(filename,data_start=0,data_type=13,data_dims=[7],endian='big')
hdata2=read_binary(filename,data_start=28,data_type=2,data_dims=[1],endian='big')
hdata3=read_binary(filename,data_start=30,data_type=4,data_dims=[15],endian='big')

;if hdata(5) eq 0 then data=read_binary(filename,data_start=284,data_type=7,data_dims=[hdata(1),hdata(2),hdata(3),hdata(4)],endian='big')
if hdata(5) eq 0 then data=fix(read_binary(filename,data_start=284,data_type=1,data_dims=[hdata(1),hdata(2),hdata(3),hdata(4)],endian='big'))
if hdata(5) eq 1 then data=read_binary(filename,data_start=284,data_type=13,data_dims=[hdata(1),hdata(2),hdata(3),hdata(4)],endian='big')
if hdata(5) eq 3 then data=read_binary(filename,data_start=284,data_type=4,data_dims=[hdata(1),hdata(2),hdata(3),hdata(4)],endian='big')
if hdata(5) eq 4 then data=read_binary(filename,data_start=284,data_type=2,data_dims=[hdata(1),hdata(2),hdata(3),hdata(4)],endian='big')
end
