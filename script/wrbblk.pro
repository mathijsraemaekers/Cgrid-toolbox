pro wrbblk, filename, image_array

;HaHo 26 sept 2000: call to mir2rembrant added for keeping REMBRANT format
;
; file =  /home/common/sobering/lib/wrbblk.pro
;
;  190789  GSS  First writing, no header comments
;

get_lun,unit          ;get logical unit number
openw,unit,filename        ;open file

;dum_image=image_array
;mir2rembrant,dum_image
writeu, unit, image_array

close,unit          ;close file
free_lun,unit          ;free logical unit number

return
end
