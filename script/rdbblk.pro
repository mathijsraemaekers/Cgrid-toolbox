pro rdbblk, filename, image_array,int_in=int_in

;HaHo 26 sept 2000: call to mir2rembrant added for keeping REMBRANT format
;
;  890719  GSS  First writing, no header comments
;  981103  GSS  Adapted early function to procedure.
;

get_lun,unit          ;get logical unit number
openr,unit,filename        ;open file
;print,'reading file '+filename+' .....'
IF KEYWORD_SET(int_in) THEN  BEGIN
 print,'FILE assumed to contain INT data. Is converted to FLOAT'
 tmp=fix(image_array)
 readu, unit, tmp
 image_array=float(tmp)
END ELSE readu,unit,image_array

close,unit          ;close file
free_lun,unit          ;free logical unit number

;mir2rembrant,image_array

;print,'done.'
return
end
