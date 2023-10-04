--This script for automaticly calculate Min-Max rate for Irradiance Map in V-Ray by input image size. Because presets was made for image size 640*480, and if you enhance your image size you need decrease Min/Max rate (because render tame is enhance if it not make), and if you lessen your image size you need increase Min/Max rate
rollout Vray_IM_converter_rateRollout "V-ray Irradiance map converter min/max rate" width:146 height:344 (
	GroupBox 'Min/max_rate_input_grp' "Min/max rate input" pos:[2,4] width:140 height:116
	dropdownList 'Current_preset_ddl' "Current preset" pos:[7,24] width:116 height:40 items:#("Custom", "Very low", "Low", "Medium", "Medium - animation", "High", "High - animation", "Very high") selection:2
	spinner 'Min_rate_spnr' "Min rate " pos:[8,70] width:109 height:16 enabled:false range:[-16,16,-4] type:#integer scale:1 align:#left --range -16;16, because in MaxScript support bit shift maximum 32 bit. Made range -100;100 how in V-Ray Min/Max rate is not purport, because 3d Max support maximum image size 32768*32768 and with this size Min/Max value=-20
	spinner 'Max_rate_spnr' "Max rate" pos:[8,94] width:109 height:16 enabled:false range:[-16,16,-3] type:#integer scale:1 align:#left
	GroupBox 'Image_size_grp' "Image size" pos:[2,128] width:140 height:70
	spinner 'Width_img_spnr' "Width " pos:[8,145] width:119 height:16 range:[1,32768,renderWidth] type:#integer scale:1 align:#left --range 1;32768 how in output size Width and Height
	spinner 'Height_img_spnr' "Height" pos:[8,170] width:119 height:16 range:[1,32768,renderHeight] type:#integer scale:1 align:#left
	GroupBox 'Min/max_rate_output_grp' "Min/max rate output" pos:[2,202] width:140 height:138
	spinner 'Min_rate_output_spnr' "Min rate " pos:[8,220] width:110 height:16 range:[-100,100,-4] type:#integer scale:1 align:#left --range -100;100 how in V-Ray - Irradiance map - Min/max rate range
	spinner 'Max_rate_output_spnr' "Max rate" pos:[8,245] width:110 height:16 range:[-100,100,-3] type:#integer scale:1 align:#left
	checkbox 'Auto_edit_rate_chk' "Auto edit rate in V-Ray" pos:[8,270] width:130 height:16 checked:true
	button 'Calculate_btn' "Calculate" pos:[8,294] width:130 height:40
	
	on Vray_IM_converter_rateRollout open do (
		if ((findstring (renderers.current as string) "v_ray_adv") != undefined) then (
			vr=renderers.current
			Current_preset_ddl.selection=vr.gi_irradmap_preset+1
			if not vr.output_getsetsfrommax then (
				Width_img_spnr.value=vr.output_width
				Height_img_spnr.value=vr.output_height
			)
		)
	)
	
	on Calculate_btn pressed do ( --FORMULA:  Min_rate=log2 ((640*480*(2^Min_rate_input)^2)/(Width_img*Height_img) . In buttom use optimized version calculate for computer (use bit shifts instead power-function and use multiplication instead division). Optimized formula: (log ((640*480*Min_rate^2)/(Width*Height)) )/(2*log 2)
		a=307200/(Width_img_spnr.value*Height_img_spnr.value*1.0)
		divisor=1.0/(2*log 2)
		if Min_rate_spnr.value==0 then b_min=1
		else (
			if Min_rate_spnr.value<0 then b_min=1.0/(bit.shift 1 (bit.shift -Min_rate_spnr.value 1))
			else b_min=bit.shift 1 (bit.shift Min_rate_spnr.value 1)
		)
		if Max_rate_spnr.value==0 then b_max=1
		else (
			if Max_rate_spnr.value<0 then b_max=1.0/(bit.shift 1 (bit.shift -Max_rate_spnr.value 1))
			else b_max=bit.shift 1 (bit.shift Max_rate_spnr.value 1)
		)
		Min_rate_output_spnr.value=(log (a*b_min))*divisor
		Max_rate_output_spnr.value=(log (a*b_max))*divisor
		if Auto_edit_rate_chk.checked and ((findstring (renderers.current as string) "v_ray") != undefined) then ( --Automaticly edit parameters V-Ray in: Rendering - Render Setup... - GI - Irradiance map - Min/Max rate
			vr=renderers.current
			vr.gi_irradmap_minRate=Min_rate_output_spnr.value
			vr.gi_irradmap_maxRate=Max_rate_output_spnr.value
		)
	)
	
	on Current_preset_ddl selected sel do	(
		--IF CURRENT PRESET
		if Current_preset_ddl.selection==1 then (
			Min_rate_spnr.enabled=true
			Max_rate_spnr.enabled=true	
		)
		else (
			Min_rate_spnr.enabled=false
			Max_rate_spnr.enabled=false	
		)
		--IF VERY LOW PRESET
		if Current_preset_ddl.selection==2 then (
			Min_rate_spnr.value=-4
			Max_rate_spnr.value=-3	
		)
		--IF LOW PRESET
		if Current_preset_ddl.selection==3 then (
			Min_rate_spnr.value=-3
			Max_rate_spnr.value=-2	
		)
		--IF MEDIUM PRESET
		if Current_preset_ddl.selection==4 then (
			Min_rate_spnr.value=-3
			Max_rate_spnr.value=-1	
		)
		--IF MEDIUM-ANIMATION PRESET
		if Current_preset_ddl.selection==5 then (
			Min_rate_spnr.value=-3
			Max_rate_spnr.value=-1	
		)
		--IF HIGH PRESET
		if Current_preset_ddl.selection==6 then (
			Min_rate_spnr.value=-3
			Max_rate_spnr.value=0	
		)
		--IF HIGH-ANIMATION PRESET
		if Current_preset_ddl.selection==7 then (
			Min_rate_spnr.value=-3
			Max_rate_spnr.value=0	
		)
		--IF VERY HIGH PRESET
		if Current_preset_ddl.selection==8 then (
			Min_rate_spnr.value=-3
			Max_rate_spnr.value=1	
		)
	)
)
createDialog Vray_IM_converter_rateRollout style:#(#style_minimizebox, #style_titlebar, #style_border, #style_sysmenu)