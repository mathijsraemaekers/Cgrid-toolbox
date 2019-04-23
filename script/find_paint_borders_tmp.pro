function find_paint_borders_tmp,subcode,hem,pfext,patchfile=patchfile
syntx=n_params()
if syntx lt 3 then begin
print,'Generates a structure containing the edges at the borders of different Freesurfer parcellations.'
print,'Syntax not right; parms are :'
print,'1: The Freesurfer subject code'
print,'2: The hemisphere, should be lh or rh.'
print,'3: The paintfile type (e.g. aparc,aparc_a2009s etc)'
print,'Keyword patchfile sets the name of the patchfile you want to use for limiting the border search'
return,0
endif
spawn,'echo $SUBJECTS_DIR',fsdir
surfdir=fsdir+'/'+subcode+'/surf/'
paint=read_fs_annotation(subcode,hem,pfext,plegend=tpnames)
tpnames=reform(tpnames(1,*))
paint=reform(paint(1,*))
surf=read_fs_surface(surfdir+hem+'.inflated')
tpnames=replace(tpnames,'-','_')
topo=surf.TOPOLOGY
if keyword_set(patchfile) then begin 
patch=read_fs_patch(patchfile)
pverts=reform(patch(0,*))
psel=intarr(max(topo)+1)
psel(pverts)=1
tsel=where(total(psel(topo),1) eq 3)
topo=topo(*,tsel)
end
topo=[[topo(0:1,*)],[topo(1:2,*)],[topo([0,2],*)]]
borinfo=create_struct('border','edges')
ptopo=where(paint(topo(0,*))-paint(topo(1,*)) ne 0)
tmptopo=topo(*,ptopo)
ptmptopo=paint(tmptopo)
revs=where(ptmptopo(0,*)-ptmptopo(1,*) gt 0)
tmptopo(*,revs)=reverse(tmptopo(*,revs))
stmptopo=string(tmptopo(0,*),format='(i08)')+string(tmptopo(1,*),format='(i08)')
ri=sort(stmptopo)
stmptopo=stmptopo(ri)
tmptopo=tmptopo(*,ri)
tmptopo=tmptopo(*,uniq(stmptopo))
ptmptopo=paint(tmptopo)
ptmptopo=string(ptmptopo(0,*),format='(i04)')+string(ptmptopo(1,*),format='(i04)')
s=sort(ptmptopo)
ptmptopo=ptmptopo(s)
tmptopo=tmptopo(*,s)
bors=uniq(ptmptopo)
bors=[0,bors,n_elements(ptmptopo)-1]
nrbor=n_elements(bors)
for j=0,nrbor-3 do if bors(j)+1-bors(j+1) lt 0 then begin
borname=tpnames(fix(strmid(ptmptopo(bors(j+1)),0,4)))+'_'+tpnames(fix(strmid(ptmptopo(bors(j+1)),4,4)))
borinfo=create_struct(borinfo,borname,tmptopo(*,bors(j)+1:bors(j+1)))
end
return,borinfo
end

