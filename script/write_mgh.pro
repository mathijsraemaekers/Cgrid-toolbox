pro write_mgh,data,filename,hdr=hdr,parms=parms
  syntx=n_params()
  if syntx lt 2 then begin
    print,'Syntax not right; parms are :'
    print,'1: Data matrix to be saved (3d or 4d)'
    print,'2: full filename of the to be saved mgh- or mgz-file'
    print,'3: (optional) filename of mgh/mgz file to copy header info (RAS)'
    print,'4: (optional) parm array [TR(ms),FA(rad),TE(ms),TI(ms)]'
    goto, EINDE
  ENDIF
  
  sizevol=size(data)
  hdata1=make_array(7,type=13)
  hdata1[0]=1
  hdata1[1]=sizevol[1]
  if sizevol[0] eq 1 then hdata1[2:4]=1
  if sizevol[0] eq 2 then begin
    hdata1[2:3]=1
    hdata1[4]=sizevol[2]
  endif
  if sizevol[0] eq 3 then begin
    hdata1[2:3]=sizevol[2:3]
    hdata1[4]=1
  endif
  if sizevol[0] eq 4 then hdata1[2:4]=sizevol[2:4]
  if size(data,/type) eq 1 then hdata1[5]=0
  if size(data,/type) eq 2 then hdata1[5]=4
  if size(data,/type) eq 4 then hdata1[5]=3
  if size(data,/type) eq 13 then hdata1[5]=1
  hdata1[6]=0
  hdata2=intarr(1)
  hdata2[0]=1
  if keyword_set(hdr) then begin
    if strmatch(hdr,'*.mgz',/fold_case) eq 1 then begin
      tmp=strsplit(hdr,'.',/extract)
      newfile=strjoin([tmp[0],'.mgh'])
      file_gunzip,hdr,newfile
      hdr=newfile
    endif
    hdata3=read_binary(hdr,data_start=30,data_type=4,data_dims=[15],endian='big')
  endif else begin 
    hdata3=fltarr(15)
    hdata3[0:2]=1
    hdata3[3]=-1
    hdata3[4:7]=0
    hdata3[8]=-1
    hdata3[9]=0
    hdata3[10]=1
    hdata3[11:*]=0
  endelse
  hdata4=bytarr(194)
  if keyword_set(parms) then parms=float(parms) else parms=fltarr(4)
  
  if strmatch(filename,'*.mgz',/fold_case) eq 1 then begin
    tmp=strsplit(filename,'.',/extract)
    gzfilename=filename
    filename=strjoin(tmp[0:-2])+'.mgh'
  endif
  
  ;print,'filename='+filename
  ;print,'gzfilename='+gzfilename
  
  OpenW, unit, filename, /Get_Lun, /SWAP_IF_LITTLE_ENDIAN
  writeu,unit,hdata1
  writeu,unit,hdata2
  writeu,unit,hdata3
  writeu,unit,hdata4
  writeu,unit,data
  writeu,unit,parms
  close,unit
  free_lun,unit
  
  if isa(gzfilename,/string) eq 1 then file_gzip,filename,gzfilename,/delete

  EINDE:
end
