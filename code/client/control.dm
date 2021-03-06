/client
	var/view_x = 0
	var/view_y = 0
	var/interface/interface
	var/list/key_binds

/client/New()

	// Apply main window styling.
	winset(src, "chatoutput", {"style=\"
		BODY {font: 0.5em : 'Courier New', sans-serif; font-size: 5%; margin-left: 0.2em; color: [PALE_GREY]}
		.warning {color: [PALE_RED]}
		.danger {color: [DARK_RED]}
		.notice {color: [PALE_BLUE]}
		.speech {color: [BRIGHT_BLUE]}
		.alert {color: [BRIGHT_ORANGE]}
		\""})

	winset(src, "output", {"style=\"
		BODY {font: 1em : 'Courier New', sans-serif; margin-left: 0.2em}
		.warning {color: [PALE_RED]}
		.danger {color: [DARK_RED]}
		.notice {color: [DARK_BLUE]}
		.speech {color: [DARK_BLUE]}
		.alert {color: [BRIGHT_ORANGE]}
		\""})

	view_x = round(world.view/2)
	view_y = round(world.view/2)
	. = ..()
	LoadData()
	if(!key_binds)
		ResetKeybinds()
	interface = new(src)

/client/verb/KeyPress(key as text)
	set instant = 1
	set hidden = 1
	interface.OnKeyPress(key)

/client/verb/KeyRelease(key as text)
	set instant = 1
	set hidden = 1
	interface.OnKeyRelease(key)

/client/verb/RebindKey()
	set name = "Rebind Key"

	var/selection = input("Select a command to rebind:") as null|anything in __keylist
	if(!selection)
		return

	var/interface/rebind/R = new(src)
	R.SetRebind(key2bind(selection))
	interface = R
	alert("Press OK, then the button you want to rebind \"[selection]\" to.")

/client/verb/KeyRebindReset()
	set name = "Reset Keybinds"
	ResetKeybinds()

/client/proc/ResetKeybinds()
	key_binds = list("W" = KEY_UP,"S" = KEY_DOWN,"D" = KEY_RIGHT,"A" = KEY_LEFT, "Shift" = KEY_RUN, "Escape" = KEY_MENU, "Tab" = KEY_CHAT, "F8" = KEY_DEV, "F7" = KEY_VARS, "E" = KEY_DROP_R, "Q" = KEY_DROP_L, "R" = KEY_INTENT, "X" = KEY_STAIRS)

/client/proc/Rebind(key, bind)
	set waitfor = 0
	if(key && bind)
		var/old_bind = FindListAssociation(key_binds, bind)
		var/curbind = key_binds[key]
		if(curbind)
			var/response = alert("\"[key]\" is already bound to \"[bind2key(curbind)]\". Do you want to overwrite this?", null, "Yes", "No")
			if(response == "Yes")
				key_binds[key] = bind
				if(old_bind)
					key_binds[old_bind] = null
		else
			key_binds[key] = bind
			if(old_bind)
				key_binds[old_bind] = null
	interface = new(src)

/client/verb/OnResize()
	set hidden = 1

	var/string = winget(src, "map", "size")

	view_x = round(text2num(string) / 64)
	view_y = round(text2num(copytext(string,findtext(string,"x")+1,0)) / 64)
	view = "[view_x]x[view_y]"
	mob.OnWindowResize()

	// Workaround for a strange bug
	perspective = MOB_PERSPECTIVE
	eye = mob

/mob/proc/OnWindowResize()
	for(var/obj/ui/ui_element in ui_screen)
		ui_element.Center(client.view_x, client.view_y)

/mob
	var/tmp/key_x
	var/tmp/key_y
	var/tmp/walk_dir

/mob/proc/OnKeyPress(bind)
	switch(bind)
		if(KEY_UP, KEY_DOWN)
			if(key_y)	//to prevent pressing opposite directions
				return 0
			walk_dir = key_y = bind2dir(bind)
		if(KEY_LEFT, KEY_RIGHT)
			if(key_x)	//as above
				return 0
			walk_dir = key_x = bind2dir(bind)

/mob/proc/OnKeyRelease(bind)
	switch(bind)
		if(KEY_UP, KEY_DOWN)
			if(key_y != bind2dir(bind))	//ignore any ignored opposite key releases
				return 0
			key_y = 0
			walk_dir = key_x ? key_x : 0
		if(KEY_LEFT, KEY_RIGHT)
			if(key_x != bind2dir(bind))	//as above
				return 0
			key_x = 0
			walk_dir = key_y ? key_y : 0

//Click macro disable
/mob/verb/DisClick(argu = null as anything, sec = "" as text, number1 = 0 as num  , number2 = 0 as num)
	set name = ".click"
	set category = null
	return

/mob/verb/DisDblClick(argu = null as anything, sec = "" as text, number1 = 0 as num  , number2 = 0 as num)
	set name = ".dblclick"
	set category = null
	return
