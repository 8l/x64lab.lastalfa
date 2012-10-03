  
  ;#-------------------------------------------------ß
  ;|          x64lab  MPL 2.0 License                |
  ;|   Copyright (c) 2009-2012, Marc Rainer Kranz.   |
  ;|            All rights reserved.                 |
  ;ö-------------------------------------------------ä

  ;#-------------------------------------------------ß
  ;| uft-8 encoded üäöß
  ;| update:
  ;| filename:
  ;ö-------------------------------------------------ä

   COINIT_APARTMENTTHREADED    = 0x2
   COINIT_MULTITHREADED        = 0x0
   COINIT_DISABLE_OLE1DDE      = 0x4
   COINIT_SPEED_OVER_MEMORY    = 0x8


	FOS_OVERWRITEPROMPT			= 0x2
	FOS_STRICTFILETYPES			= 0x4
	FOS_NOCHANGEDIR					= 0x8
	FOS_PICKFOLDERS					= 0x20
	FOS_FORCEFILESYSTEM			= 0x40
	FOS_ALLNONSTORAGEITEMS	= 0x80
	FOS_NOVALIDATE					= 0x100
	FOS_ALLOWMULTISELECT		= 0x200
	FOS_PATHMUSTEXIST				= 0x800
	FOS_FILEMUSTEXIST				= 0x1000
	FOS_CREATEPROMPT				= 0x2000
	FOS_SHAREAWARE					= 0x4000
	FOS_NOREADONLYRETURN		= 0x8000
	FOS_NOTESTFILECREATE		= 0x10000
	FOS_HIDEMRUPLACES				= 0x20000
	FOS_HIDEPINNEDPLACES		= 0x40000
	FOS_NODEREFERENCELINKS	= 0x100000
	FOS_DONTADDTORECENT			= 0x2000000
	FOS_FORCESHOWHIDDEN			= 0x10000000
	FOS_DEFAULTNOMINIMODE		= 0x20000000
	FOS_FORCEPREVIEWPANEON	= 0x40000000

	struct COMDLG_FILTERSPEC
		pszName	dq 0
		pszSpec	dq 0
	ends

	SIGDN_NORMALDISPLAY	= 0
	SIGDN_PARENTRELATIVEPARSING	= 0x80018001
	SIGDN_DESKTOPABSOLUTEPARSING	= 0x80028000
	SIGDN_PARENTRELATIVEEDITING	= 0x80031001
	SIGDN_DESKTOPABSOLUTEEDITING	= 0x8004c000
	SIGDN_FILESYSPATH	= 0x80058000
	SIGDN_URL	= 0x80068000
	SIGDN_PARENTRELATIVEFORADDRESSBAR	= 0x8007c001
	SIGDN_PARENTRELATIVE	= 0x80080001

	SHGDN_INFOLDER	= 0x1
	SHGDN_FOREDITING	= 0x1000
	SHGDN_FORADDRESSBAR	= 0x4000
	SHGDN_FORPARSING	= 0x8000

	SHCONTF_CHECKING_FOR_CHILDREN	= 0x10
	SHCONTF_FOLDERS	= 0x20
	SHCONTF_NONFOLDERS	= 0x40
	SHCONTF_INCLUDEHIDDEN	= 0x80
	SHCONTF_INIT_ON_FIRST_NEXT	= 0x100
	SHCONTF_NETPRINTERSRCH	= 0x200
	SHCONTF_SHAREABLE	= 0x400
	SHCONTF_STORAGE	= 0x800
	SHCONTF_NAVIGATION_ENUM	= 0x1000
	SHCONTF_FASTITEMS	= 0x2000
	SHCONTF_FLATLIST	= 0x4000
	SHCONTF_ENABLE_ASYNC	= 0x8000
	SHCONTF_INCLUDESUPERHIDDEN	= 0x10000

	DROPEFFECT_COPY equ 0x1 ;// Objects can be copied  
	DROPEFFECT_MOVE equ 0x2	;// Objects can be moved     
	DROPEFFECT_LINK equ 0x4	;// Objects can be linked    

	define SHCIDS_ALLFIELDS        0x80000000
	define SHCIDS_CANONICALONLY    0x10000000
	define SHCIDS_BITMASK          0xFFFF0000
	define SHCIDS_COLUMNMASK       0x0000FFFF
	define SFGAO_CANCOPY           DROPEFFECT_COPY
	define SFGAO_CANMOVE           DROPEFFECT_MOVE
	define SFGAO_CANLINK           DROPEFFECT_LINK
	define SFGAO_STORAGE           0x00000008    ;// supports BindToObject(IID_IStorage)
	define SFGAO_CANRENAME         0x00000010    ;// Objects can be renamed
	define SFGAO_CANDELETE         0x00000020    ;// Objects can be deleted
	define SFGAO_HASPROPSHEET      0x00000040    ; // Objects have property sheets
	define SFGAO_DROPTARGET        0x00000100    ; // Objects are drop target
	define SFGAO_CAPABILITYMASK    0x00000177    ;
	define SFGAO_SYSTEM            0x00001000    ; // System object
	define SFGAO_ENCRYPTED         0x00002000    ; // Object is encrypted (use alt color)
	define SFGAO_ISSLOW            0x00004000    ; // 'Slow' object
	define SFGAO_GHOSTED           0x00008000    ; // Ghosted icon
	define SFGAO_LINK              0x00010000    ; // Shortcut (link)
	define SFGAO_SHARE             0x00020000    ; // Shared
	define SFGAO_READONLY          0x00040000    ; // Read-only
	define SFGAO_HIDDEN            0x00080000    ; // Hidden object
	define SFGAO_DISPLAYATTRMASK   0x000FC000    ;
	define SFGAO_FILESYSANCESTOR   0x10000000    ; // May contain children with SFGAO_FILESYSTEM
	define SFGAO_FOLDER            0x20000000    ; // Support BindToObject(IID_IShellFolder)
	define SFGAO_FILESYSTEM        0x40000000    ; // Is a win32 file system object (file/folder/root)
	define SFGAO_HASSUBFOLDER      0x80000000    ; // May contain children with SFGAO_FOLDER (may be slow)
	define SFGAO_CONTENTSMASK      0x80000000    ;
	define SFGAO_VALIDATE          0x01000000    ; // Invalidate cached information (may be slow)
	define SFGAO_REMOVABLE         0x02000000    ; // Is this removeable media?
	define SFGAO_COMPRESSED        0x04000000    ; // Object is compressed (use alt color)
	define SFGAO_BROWSABLE         0x08000000    ; // Supports IShellFolder, but only implements CreateViewObject() (non-folder view)
	define SFGAO_NONENUMERATED     0x00100000    ; // Is a non-enumerated object (should be hidden)
	define SFGAO_NEWCONTENT        0x00200000    ; // Should show bold in explorer tree
	define SFGAO_CANMONIKER        0x00400000    ; // Obsolete
	define SFGAO_HASSTORAGE        0x00400000    ; // Obsolete
	define SFGAO_STREAM            0x00400000    ; // Supports BindToObject(IID_IStream)
	define SFGAO_STORAGEANCESTOR   0x00800000    ; // May contain children with SFGAO_STORAGE or SFGAO_STREAM
	define SFGAO_STORAGECAPMASK    0x70C50008    ; // For determining storage capabilities, ie for open/save semantics
	define SFGAO_PKEYSFGAOMASK     0x81044000    ; // Attributes that are masked out for PKEY_SFGAOFlags because they are considered to cause slow calculations or lack context (SFGAO_VALIDATE | SFGAO_ISSLOW | SFGAO_HASSUBFOLDER and others)
																							

	define STR_BIND_FORCE_FOLDER_SHORTCUT_RESOLVE "Force Folder Shortcut Resolve"
	define STR_AVOID_DRIVE_RESTRICTION_POLICY			"Avoid Drive Restriction Policy"
	define STR_AVOID_DRIVE_RESTRICTION_POLICY			"Avoid Drive Restriction Policy"
	define STR_SKIP_BINDING_CLSID  								"Skip Binding CLSID"
	define STR_PARSE_PREFER_FOLDER_BROWSING     	"Parse Prefer Folder Browsing"
	define STR_DONT_PARSE_RELATIVE              	"Don't Parse Relative"
	define STR_PARSE_TRANSLATE_ALIASES          	"Parse Translate Aliases"
	define STR_PARSE_SKIP_NET_CACHE             "Skip Net Resource Cache"
	define STR_PARSE_SHELL_PROTOCOL_TO_FILE_OBJECTS    "Parse Shell Protocol To File Objects"
	define STR_TRACK_CLSID                      "Track the CLSID"
	define STR_INTERNAL_NAVIGATE                "Internal Navigation"
	define STR_PARSE_PROPERTYSTORE							"DelegateNamedProperties"
	define STR_NO_VALIDATE_FILENAME_CHARS      	"NoValidateFilenameChars"
	define STR_BIND_DELEGATE_CREATE_OBJECT 			"Delegate Object Creation"
	define STR_PARSE_ALLOW_INTERNET_SHELL_FOLDERS "Allow binding to Internet shell folder handlers and negate STR_PARSE_PREFER_WEB_BROWSING"
	define STR_PARSE_PREFER_WEB_BROWSING   				"Do not bind to Internet shell folder handlers"
	define STR_PARSE_SHOW_NET_DIAGNOSTICS_UI  		"Show network diagnostics UI"
	define STR_PARSE_DONT_REQUIRE_VALIDATED_URLS  "Do not require validated URLs"
	define STR_INTERNETFOLDER_PARSE_ONLY_URLMON_BINDABLE  "Validate URL"
	define STR_BIND_FOLDERS_READ_ONLY 	"Folders As Read Only"
	define STR_BIND_FOLDER_ENUM_MODE 		"Folder Enum Mode"

	SIATTRIBFLAGS_AND 			equ 0x00000001 ;If there are multiple items in the array, use a bitwise AND to combine the attributes across items. For instance, if the array contains two items where one item can be moved (SFGAO_CANMOVE) and a second item cannot, the method returns (1 & 0) or 0 for that attribute bit.
	SIATTRIBFLAGS_OR 				equ 0x00000002 ;If there are multiple items in the array, use a bitwise OR to combine the attributes across items. For instance, if the array contains two items where one item can be moved (SFGAO_CANMOVE) and a second item cannot, the method returns (1 | 0) or 1 for that attribute bit.
	SIATTRIBFLAGS_APPCOMPAT equ 0x00000003 ;Retrieve the attributes directly from the Shell data source. To use this value, the Shell item array must have been initialized as an IShellFolder with its contents specified as an array of child PIDLs.
	SIATTRIBFLAGS_MASK 			equ 0x00000003 ; A mask for SIATTRIBFLAGS_AND, SIATTRIBFLAGS_OR, and SIATTRIBFLAGS_APPCOMPAT. Callers normally do not use this value.
	SIATTRIBFLAGS_ALLITEMS	equ 0x00004000

	FEM_VIEWRESULT	= 0
	FEM_NAVIGATION	= 1

	;--- CLSID/IID
	@using iid_FileDE
		iid_FileDE GUID 973510DB-7D7F-452B-8975-74A85828D354
	@endusing

	@using iid_UNK
		iid_UNK GUID 00000000-0000-0000-C000-000000000046
	@endusing

	@using iid_FileOD
		iid_FileOD GUID D57C7288-D4AD-4768-BE02-9D969532D960
	@endusing

	@using iid_Shi
		iid_Shi	GUID 43826D1E-E718-42EE-BC55-A1E261C37BFE
	@endusing

	@using clsid_FileOD
		clsid_FileOD 	GUID DC1C5A9C-E88A-4DDE-A5A1-60F82A20AEF7
	@endusing

	@using clsid_FileD
		clsid_FileD GUID 42F85136-DB7E-439C-85F1-E4075D135FC8
	@endusing

	@using 	clsid_CFACT
	 clsid_CFACT GUID 00000001-0000-0000-C000-000000000046
	@endusing

	@using iid_FolderView2
		iid_FolderView2 GUID 1AF3A467-214F-4298-908E-06B03E0B39F9
	@endusing

	@using clsid_FolderView
		clsid_FolderView	GUID CDE725B0-CCC9-4519-917E-325D72FAB4CE
	@endusing


	virtual at 0
	struc iUnknown {
		.QueryInterface dq ?
		.AddRef dq ?
		.Release dq ?
	} iUnknown iUnknown
	sizeof.iUnknown = $-iUnknown
	end virtual
 
	virtual at 0
	struc iClassFactory {
		.iUnknown iUnknown
    .CreateInstance dq ?
    .LockServer			dq ?
	} iClassFactory\
		iClassFactory
	end virtual
	sizeof.iClassFactory\
	= $-iClassFactory

	virtual at 0
	struc iFileDialogEvents{
		.iUnknown iUnknown
		.OnFileOk						dq ?
		.OnFolderChanging   dq ?
		.OnFolderChange   	dq ?
		.OnSelectionChange  dq ?
		.OnShareViolation   dq ?
		.OnTypeChange   		dq ?
		.OnOverwrite   			dq ?
	}	iFileDialogEvents\
		iFileDialogEvents
	sizeof.iFileDialogEvents\
	= $-iFileDialogEvents
	end virtual

	;--- interfaces -----------------------
	virtual at 0
		struc iShellItemArray {
		.iUnknown iUnknown
		.BindToHandler  		dq ?
		.GetPropertyStore  	dq ?
		.GetPropertyDescriptionList dq ?
		.GetAttributes  		dq ?
		.GetCount		dq ?
		.GetItemAt	dq ?
		.EnumItems	dq ?
	} iShellItemArray\
	iShellItemArray
	end virtual
	sizeof.iShellItemArray\
	= $-iShellItemArray

	virtual at 0
		struc iShellItem {
		.iUnknown iUnknown
		.BindToHandler  dq ?
		.GetParent  		dq ?
		.GetDisplayName dq ?
		.GetAttributes  dq ?
		.Compare  			dq ?
	} iShellItem\
	iShellItem
	end virtual
	sizeof.iShellItem\
	= $-iShellItem

	;---  iFileOpenDialog --------
	virtual at 0
		struc iFileOpenDialog {
		.iUnknown iUnknown
		.Show							dq ?
		.SetFileTypes			dq ?
		.SetFileTypeIndex	dq ?
		.GetFileTypeIndex	dq ?
		.Advise   	dq ?
		.Unadvise		dq ?
		.SetOptions	dq ?
		.GetOptions	dq ?
		.SetDefaultFolder	dq ?
		.SetFolder   dq ?
		.GetFolder   dq ?
		.GetCurrentSelection  dq ?
		.SetFileName   	dq ?
		.GetFileName   	dq ?
		.SetTitle   		dq ?
		.SetOkButtonLabel dq ?
		.SetFileNameLabel dq ?
		.GetResult   		dq ?
		.AddPlace   		dq ?
		.SetDefaultExtension dq ?
		.Close   					dq ?
		.SetClientGuid   	dq ?
		.ClearClientData  dq ?
		.SetFilter   			dq ?
		.GetResults   		dq ?
		.GetSelectedItems dq ?
	} iFileOpenDialog\
	iFileOpenDialog
	end virtual
	sizeof.iFileOpenDialog\
	= $-iFileOpenDialog

	;--- iFolderView
	virtual at 0
		struc iFolderView {
		 .iUnk iUnknown
		 .GetCurrentViewMode	dq 0
		 .SetCurrentViewMode	dq 0
		 .GetFolder	dq 0
		 .Item	dq 0
		 .ItemCount	dq 0
		 .Items	dq 0
		 .GetSelectionMarkedItem	dq 0
		 .GetFocusedItem	dq 0
		 .GetItemPosition	dq 0
		 .GetSpacing	dq 0
		 .GetDefaultSpacing	dq 0
		 .GetAutoArrange	dq 0
		 .SelectItem	dq 0
		 .SelectAndPositionItems	dq 0
	} iFolderView\
	iFolderView 
	end virtual
	sizeof.iFolderView \
	= $-iFolderView 

	;--- iFolderView2
	virtual at 0
		struc iFolderView2 {
		.iFV iFolderView
    .SetGroupBy	dq 0
    .GetGroupBy	dq 0
    .SetViewProperty	dq 0
    .GetViewProperty	dq 0
    .SetTileViewProperties	dq 0
    .SetExtendedTileViewProperties	dq 0
    .SetText	dq 0
    .SetCurrentFolderFlags	dq 0
    .GetCurrentFolderFlags	dq 0
    .GetSortColumnCount	dq 0
    .SetSortColumns	dq 0
    .GetSortColumns	dq 0
    .GetItem	dq 0
    .GetVisibleItem	dq 0
    .GetSelectedItem	dq 0
    .GetSelection	dq 0
    .GetSelectionState	dq 0
    .InvokeVerbOnSelection	dq 0
    .SetViewModeAndIconSize	dq 0
    .GetViewModeAndIconSize	dq 0
    .SetGroupSubsetCount	dq 0
    .GetGroupSubsetCount	dq 0
    .SetRedraw	dq 0
    .IsMoveInSameFolder	dq 0
    .DoRename	dq 0
	} iFolderView2\
	iFolderView2 
	end virtual
	sizeof.iFolderView2\
	= $-iFolderView2



;	;--- set com pointer at address
;	;--- @comptr .pUnk,at rsp+8,iUnknown
;	macro @comptr [name,atarg,arginter]{
;		forward
;		local ..tmp
;		virtual atarg
;		..tmp arginter
;		name equ ..tmp
;		end virtual
;	}	

;	;--- set static com pointer 
;	;--- @comsta pUnk,iUnknown
;	macro @comsta argcall,arginter {
;		virtual at $
;			argcall arginter
;		end virtual
;		dq 0
;	}

;	;--- call com method 
;	;--- .pUnk->QueryInterface
;	macro @comcall argmeth{
;		match p->meth,argmeth\{
;			mov rcx,[p]
;			mov rax,[rcx]
;			call [rax+p\#.\#meth-p]
;		\} 
;	}


