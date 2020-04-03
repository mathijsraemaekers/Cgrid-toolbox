pro cgrid_menu
device,decomposed=0
base=widget_base(/column,title='Cgrid menu')
but1=widget_button(base,value='Generate patches')
but2=widget_button(base,value='Generate schemes')
but3=widget_button(base,value='Generate Cgrids')
but4=widget_button(base,value='Map volumes to Cgrids')
but5=widget_button(base,value='Map surface data to Cgrids')
but6=widget_button(base,value='Map Cgrids to volume')
but7=widget_button(base,value='Map coordinates to Cgrids')
but8=widget_button(base,value='Map images to Cgrids')
but9=widget_button(base,value='Map metrics to Cgrid')
but10=widget_button(base,value='Quit')
resp=widget_event(base,/nowait)
widget_control,base,/realize
while resp.id ne but10 do begin
resp=widget_event(base)
if resp.id eq but1 then gen_fs_patch_widget
if resp.id eq but2 then gen_cgrid_scheme_widget
if resp.id eq but3 then apply_cgrid_scheme_widget
if resp.id eq but4 then vol2cgrid_widget
if resp.id eq but5 then surfdat2cgrid_widget
if resp.id eq but6 then cgrid2vol_widget
if resp.id eq but7 then coor_report_widget
if resp.id eq but8 then map_image2cgrid_widget
if resp.id eq but9 then mgh2cgrid_widget
end 
widget_control,base,/destroy
print,'Exiting Cgrid-toolbox'
end
