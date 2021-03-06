; TODO: rewrite the whole documentation of MenuItem
class CMenuItem
{
  controlType := "MenuItem"
	; Instance properties
	; Menu item name
	name := ""
  ; Menu item text
  text := ""
	; Menu name
	menu := ""
	; Label
	label := ""
  ; Action
  action := ""
	; Created flag
	created := false
  ; Position
  position := 0
  ; Checked
  checked := false
  ; enabled
  enabled := true
  ;hotkey
  hk := ""
	
;
; Function: __New
; Description:
;		Creates an instance of MenuItemBase.
; Syntax: __New(name, menu [, subMenu])
; Parameters:
;		menu - A menu containing this menu item
; 		name - Menu item name (as used in Menu, Tray, add, [b]name[/b]...)
;		label - (Optional) A label or submenu for this menu item
; Return Value:
;		Returns an instance of MenuItemBase
; Remarks:
;		If the submenu is empty, a regular menu item is created.
;		If the submenu is not empty, a menu item with a submenu is created.
;		If the name is empty, a separator is created.
; Example:
; 		mTray := new MenuBase()
;		mi := new MenuItemBase("MyMenuItem1", mTray)
;
	__New(menu, name="", label="")
	{
		this.name := name
    this.text := _t(this.name)
		this.menu := menu
    if(name <> "")
      this.label := label
;     OutputDebug % "MenuItem.__New(" menu.name ", " name ", " label ") result text = " this.text
	}
  
  GetName()
  {
    return this.name
  }
	
;
; Function: Create
; Description:
;		Creates a menu item. If this.menuName is blank, a separator is created.
; Syntax: Object.Create()
; Example:
;		mi := new MenuItemBase("Item1")
;		mi.Create()
;
	Create()
	{
;     OutputDebug MenuItem.Create()
    
		if(this.created)
			return
    
;     OutputDebug  % "Menu, " this.menu.name ", add, " this.text ",  " this.label
		Menu, % this.menu.name, add, % this.GetFullText(), % this.label
		if(!this.enabled)
      this.disable()
    if(this.checked)
      this.check()
		this.created := true
	}
   
  GetFullText()
  {
    text := this.text
    if(!IsEmpty(this.hk))
    {
      text .= "`t" this.hk.ToString()
    }
    return text
  }

;
; Function: Delete
; Description:
; 		Deletes MenuItemName from the menu.If this item was default, the effect will be similar to having used the NoDefault option. 
; Syntax: Object.Create()
; Example:
;		mi.Delete()
;
	Delete()
	{
		if(not this.created)
			return
		
		Menu, % this.menu.name, Delete, % this.GetFullText()
		this.created := false
	}
	
;
; Function: Rename
; Description:
; 		Changes menu item name to newName (if newName is blank, the menu item will be converted into a separator line). newName must not be the same as any existing custom menu item. The menu item's current target label or submenu is unchanged.
; Syntax: Object.Rename(newText)
; Parameters:
; 		newText - The new text (and the name) of a menu item (must be unique in the parent menu).
; Remarks:
;		This menu item will not be renamed if the parent menu has an item with the same name as specified in the newName parameter.
; Example:
;		mi.Rename("newText")
;
	Rename(newText)
	{
;     OutputDebug in Rename(%newText%)
		if(this.menu.itemsByNames.haskey(newText))
			return
    
    oldText := % this.GetFullText()
    this.text := newText
;     OutputDebug % "Rename " oldText " => " this.GetFullText()
		Menu, % this.menu.name, Rename, %oldText%, % this.GetFullText()
		
	}
	
;
; Function: Check
; Description:
; 		Adds a visible checkmark in the menu next to MenuItemName (if there isn't one already).
; Syntax: Object.Check()
; Example:
;		mi.Check()
;
	Check()
	{
		Menu, % this.menu.name, Check, % this.GetFullText()
    this.checked := true
	}
	
;
; Function: Uncheck
; Description:
; 		Removes the checkmark (if there is one) from MenuItemName.
; Syntax: Object.Uncheck()
; Example:
;		mi.Uncheck()
;
	Uncheck()
	{
		Menu, % this.menu.name, Uncheck, % this.GetFullText()
    this.checked := false
	}
	
;
; Function: ToggleCheck
; Description:
; 		Adds a checkmark if there wasn't one; otherwise, removes it.
; Syntax: Object.ToggleCheck()
; Example:
;		mi.ToggleCheck()
;
	ToggleCheck(update = false)
	{
		Menu, % this.menu.name, ToggleCheck, % this.GetFullText()
    this.checked := !this.checked
	}

;
; Function: Enable
; Description:
; 		Allows the user to once again select the menu item if was previously disabled (grayed).
; Syntax: Object.Enable()
; Example:
;		mi.Enable()
;
	Enable()
	{
		Menu, % this.text, Enable, % this.GetFullText()
	}

;
; Function: Disable
; Description:
; 		Changes the menu item to a gray color to indicate that the user cannot select it.
; Syntax: Object.Disable()
; Example:
;		mi.Disable()
;
	Disable()
	{
		Menu, % this.menu.name, Disable, % this.GetFullText()
	}

;
; Function: ToggleEnable
; Description:
; 		Disables the menu item if it was previously enabled; otherwise, enables it.
; Syntax: Object.ToggleEnable()
; Example:
;		mi.ToggleEnable()
;
	ToggleEnable()
	{
		Menu, % this.menu.name, ToggleEnable, % this.GetFullText()
	}

;
; Function: Default
; Description:
; 		Changes the menu's default item to be this item and makes that item's font bold (setting a default item in menus other than TRAY is currently purely cosmetic). When the user double-clicks the tray icon, its default menu item is launched. If there is no default, double-clicking has no effect.
; Syntax: Object.Default()
; Example:
;		mi.Default()
;
	Default()
	{
		Menu, % this.menu.name, Default, % this.GetFullText()
	}

;
; Function: Icon
; Description:
;		Sets the menu item's icon. FileName can either be an icon file or any image in a format supported by AutoHotkey. To use an icon group other than the first one in the file, specify its number for IconNumber (if omitted, it defaults to 1). Additionally, negative numbers can be used as resource identifiers. Specify the desired width of the icon in IconWidth. If the icon group indicated by IconNumber contains multiple icon sizes, the closest match is used and the icon is scaled to the specified size.
; Currently it is necessary to specify "actual size" when setting the icon to preserve transparency on Windows Vista and later.
; Example:
;		mi.Icon("icon.ico")
;
	Icon(FileName, IconNumber = 1, IconWidth = 16)
	{
		Menu, % this.menu.name, Icon, % this.GetFullText(), FileName, IconNumber, IconWidth
	}

;
; Function: NoIcon
; Description:
; 		Removes MenuItemName's icon, if any. 
; Example:
;		mi.NoIcon()
;
	NoIcon()
	{
		Menu, % this.menu.name, NoIcon, % this.GetFullText()
	}
  
  Localize()
  {
    if(!this.name)
      return
;     OutputDebug % "Localizing "  this.name " to " _t(this.name)
    this.Rename(_t(this.name))
  }
  
  ReplaceHotkey(newHk)
  {
;     OutputDebug % "In ReplaceHotkey(" newHk.hk ")"
		
    oldText := % this.GetFullText()
    this.hk := newHk
		Menu, % this.menu.name, Rename, %oldText%, % this.GetFullText()
  }
}