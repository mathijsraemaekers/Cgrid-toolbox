pro struct_delete_field, struct, tag
;Delete an existing field from a structure.
;
;Inputs:
; tag (string) Case insensitive tag name describing structure field to
;  delete. Leading and trailing spaces will be ignored. If the requested
;  field does not exist, the structure is returned unchanged and without
;  error.
;
;Input/Output:
; struct (structure) structure to be modified.
;
;Examples:
;
; Delete sme.wave from structure:
;
;   IDL> struct_delete_field, sme, 'wave'
;
;History:
; 2003-Jul-26 Valenti  Adapted from struct_replace_field.pro.

if n_params() lt 2 then begin
  print, 'syntax: struct_delete_field, struct, tag'
  return
endif

;Check that input is a structure.
  if size(struct, /tname) ne 'STRUCT' then begin
    message, 'first argument is not a structure'
  endif

;Get list of structure tags.
  tags = tag_names(struct)
  ntags = n_elements(tags)

;Check whether the requested field exists in input structure.
  ctag = strupcase(strtrim(tag, 2))		;canoncial form of tag
  itag = where(tags eq ctag, nmatch)
  if nmatch eq 0 then return
  itag = itag[0]				;convert to scalar

;Copy any fields that precede target field.
  if itag gt 0 then begin			;target field occurs first
    new = create_struct(tags[0], struct.(0))	;initialize structure
    for i=1, itag-1 do begin			;insert leading unchange
      new = create_struct(new, tags[i], struct.(i))
    endfor
  endif

;Replicate remainder of structure after desired tag.
  for i=itag+1, ntags-1 do begin
    new = create_struct(new, tags[i], struct.(i))
  endfor

;Replace input structure with new structure.
  struct = new

end