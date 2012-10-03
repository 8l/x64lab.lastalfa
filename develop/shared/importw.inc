  
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



	section '.idata' import data readable writeable

	define status 0
	match =0 items,status APIIMPORT {
	library ADVAPI32,"ADVAPI32",\
		GDI32,"GDI32",\
		COMCTL32,"COMCTL32",\
		USER32,"USER32",\
		KERNEL32,"KERNEL32",\
		OLE32,"OLE32",\
		SHELL32,"SHELL32",\
		SHLWAPI,"SHLWAPI",\
		WININET,"WININET",\
		UXTHEME,"UXTHEME",\
		MSVCRT,"MSVCRT",items
		define status 1
		include "uxtheme.inc"
		}

	match =0,status {
	library  ADVAPI32,"ADVAPI32",\
		GDI32,"GDI32",\
		COMCTL32,"COMCTL32",\
		USER32,"USER32",\
		KERNEL32,"KERNEL32",\
		OLE32,"OLE32",\
		SHELL32,"SHELL32",\
		SHLWAPI,"SHLWAPI",\
		WININET,"WININET",\
		MSVCRT, "MSVCRT",\
		UXTHEME,"UXTHEME"
		define status 1
	include "uxtheme.inc"
	}

	import ADVAPI32,\
		GetUserNameW,"GetUserNameW"
	
	import GDI32,\
		BitBlt,"BitBlt",\
		CombineRgn,"CombineRgn",\
		CreateCompatibleBitmap,"CreateCompatibleBitmap",\
		CreateCompatibleDC,"CreateCompatibleDC",\
		CreateBitmap,"CreateBitmap",\
		CreateFontIndirectW,"CreateFontIndirectW",\
		CreatePatternBrush,"CreatePatternBrush",\
		CreateRectRgn,"CreateRectRgn",\
		CreateSolidBrush,"CreateSolidBrush",\
		CreateRoundRectRgn,"CreateRoundRectRgn",\
		DeleteEnhMetaFile,"DeleteEnhMetaFile",\
		DeleteObject,"DeleteObject",\
		ExcludeClipRect,"ExcludeClipRect",\
		FillRgn,"FillRgn",\
		FrameRgn,"FrameRgn",\
		GetClipBox,"GetClipBox",\
		GetDeviceCaps,"GetDeviceCaps",\
		GetEnhMetaFileW,"GetEnhMetaFileW",\
		GetPixel,"GetPixel",\
		GetRegionData,"GetRegionData",\
		GetTextExtentPoint32W,"GetTextExtentPoint32W",\
		GetTextMetricsW,"GetTextMetricsW",\
		GetStockObject,"GetStockObject",\
		InvertRgn,"InvertRgn",\
		LPtoDP,"LPtoDP",\
		PatBlt,"PatBlt",\
		PtInRegion,"PtInRegion",\
		PlayEnhMetaFile,"PlayEnhMetaFile",\
		RoundRect,"RoundRect",\
		SelectObject,"SelectObject",\
		SelectClipRgn,"SelectClipRgn",\
		SetBkColor,"SetBkColor",\
		SetBkMode,"SetBkMode",\
		SetTextColor,"SetTextColor"
	
	import	COMCTL32,\
		DrawStatusTextW,"DrawStatusTextW",\
		ImageList_AddMasked,"ImageList_AddMasked",\
		ImageList_Create,"ImageList_Create",\
		ImageList_Destroy,"ImageList_Destroy",\
		ImageList_Draw,"ImageList_Draw",\
		ImageList_GetImageCount,"ImageList_GetImageCount",\
		ImageList_LoadImageW,"ImageList_LoadImageW",\
		ImageList_SetBkColor,"ImageList_SetBkColor",\
		InitCommonControlsEx,"InitCommonControlsEx"

	import OLE32,\
		CoCreateInstance,"CoCreateInstance",\
		CoGetClassObject,"CoGetClassObject",\
		CoInitialize,"CoInitialize",\
		CoInitializeEx,"CoInitializeEx",\
		CoTaskMemAlloc,"CoTaskMemAlloc",\
		CoTaskMemFree,"CoTaskMemFree",\
		CoUninitialize,"CoUninitialize"

	import USER32,\
		AnimateWindow,"AnimateWindow",\
		AppendMenuW,"AppendMenuW",\
		BeginDeferWindowPos,"BeginDeferWindowPos",\
		BeginPaint,"BeginPaint",\
		BringWindowToTop,"BringWindowToTop",\
		CallWindowProcW,"CallWindowProcW",\
		CheckMenuItem,"CheckMenuItem",\
		ChildWindowFromPoint,"ChildWindowFromPoint",\
		ChildWindowFromPointEx,"ChildWindowFromPointEx",\
		ClientToScreen,"ClientToScreen",\
		CreateAcceleratorTableW,"CreateAcceleratorTableW",\
		CreateDialogParamW,"CreateDialogParamW",\
		CreateMenu,"CreateMenu",\
		CreatePopupMenu,"CreatePopupMenu",\
		CreateWindowExW,"CreateWindowExW",\
		DeferWindowPos,"DeferWindowPos",\
		DefFrameProcW,"DefFrameProcW",\
		DefMDIChildProcW,"DefMDIChildProcW",\
		DefWindowProcW,"DefWindowProcW",\
		DeleteMenu,"DeleteMenu",\
		DestroyAcceleratorTable,"DestroyAcceleratorTable",\
		DestroyIcon,"DestroyIcon",\
		DestroyMenu,"DestroyMenu",\
		DestroyWindow,"DestroyWindow",\
		DialogBoxParamW,"DialogBoxParamW",\
		DispatchMessageW,"DispatchMessageW",\
		DragDetect,"DragDetect",\
		DrawFrameControl,"DrawFrameControl",\
		DrawCaption,"DrawCaption",\
		DrawEdge,"DrawEdge",\
		DrawMenuBar,"DrawMenuBar",\
		DrawText,"DrawTextA",\
		DrawTextW,"DrawTextW",\
		EnableWindow,"EnableWindow",\
		EndDeferWindowPos,"EndDeferWindowPos",\
		EndDialog,"EndDialog",\
		EndPaint,"EndPaint",\
		EnumChildWindows,"EnumChildWindows",\
		FillRect,"FillRect",\
		GetActiveWindow,"GetActiveWindow",\
		GetCapture,"GetCapture",\
		GetClientRect,"GetClientRect",\
		GetCursor,"GetCursor",\
		GetCursorPos,"GetCursorPos",\
		GetDesktopWindow,"GetDesktopWindow",\
		GetDialogBaseUnits,"GetDialogBaseUnits",\
		GetDC,"GetDC",\
		GetDCEx,"GetDCEx",\
		GetDlgItem,"GetDlgItem",\
		GetFocus,"GetFocus",\
		GetKeyNameTextW,"GetKeyNameTextW",\
		GetMenuInfo,"GetMenuInfo",\
		GetMenuItemCount,"GetMenuItemCount",\
		GetMenuItemInfoW,"GetMenuItemInfoW",\
		GetMessagePos,"GetMessagePos",\
		GetMessageW,"GetMessageW",\
		GetMouseMovePointsEx,"GetMouseMovePointsEx",\
		GetParent,"GetParent",\
		GetSubMenu,"GetSubMenu",\
		GetSysColor,"GetSysColor",\
		GetSysColorBrush,"GetSysColorBrush",\
		GetSystemMetrics,"GetSystemMetrics",\
		GetUpdateRect,"GetUpdateRect",\
		GetWindow,"GetWindow",\
		GetWindowLongPtrW,"GetWindowLongPtrW",\
		GetWindowPlacement,"GetWindowPlacement",\
		GetWindowRect,"GetWindowRect",\
		GetWindowTextW,"GetWindowTextW",\
		InsertMenuItemW,"InsertMenuItemW",\
		IntersectRect,"IntersectRect",\
		InvalidateRect,"InvalidateRect",\
		IsWindow,"IsWindow",\
		LoadAcceleratorsW,"LoadAcceleratorsW",\
		LoadBitmapW,"LoadBitmapW",\
		LoadCursorW,"LoadCursorW",\
		LoadIconW,"LoadIconW",\
		LoadImageW,"LoadImageW",\
		LoadMenuIndirectW,"LoadMenuIndirectW",\
		LoadMenuW,"LoadMenuW",\
		LoadStringW,"LoadStringW",\
		LockWindowUpdate,"LockWindowUpdate",\
		MapDialogRect,"MapDialogRect",\
		MapWindowPoints,"MapWindowPoints",\
		MapVirtualKeyW,"MapVirtualKeyW",\
		MessageBoxW,"MessageBoxW",\
		MessageBoxExW,"MessageBoxExW",\
		MoveWindow,"MoveWindow",\
		PostMessageW,"PostMessageW",\
		PostQuitMessage,"PostQuitMessage",\
		PtInRect,"PtInRect",\
		RedrawWindow,"RedrawWindow",\
		RealChildWindowFromPoint,"RealChildWindowFromPoint",\
		RegisterClassExW,"RegisterClassExW",\
		ReleaseCapture,"ReleaseCapture",\
		ReleaseDC,"ReleaseDC",\
		ScreenToClient,"ScreenToClient",\
		SendNotifyMessageW,"SendNotifyMessageW",\
		SendMessageW,"SendMessageW",\
		SetActiveWindow,"SetActiveWindow",\
		SetCapture,"SetCapture",\
		SetClassLongPtrW,"SetClassLongPtrW",\
		SetCursor,"SetCursor",\
		SetCursorPos,"SetCursorPos",\
		SetFocus,"SetFocus",\
		SetForegroundWindow,"SetForegroundWindow",\
		SetLayeredWindowAttributes,"SetLayeredWindowAttributes",\
		SetMenu,"SetMenu",\
		SetMenuInfo,"SetMenuInfo",\
		SetMenuItemInfoW,"SetMenuItemInfoW",\
		SetParent,"SetParent",\
		SetWindowLongPtrW,"SetWindowLongPtrW",\
		SetWindowPos,"SetWindowPos",\
		SetWindowRgn,"SetWindowRgn",\
		ShowWindow,"ShowWindow",\
		SubtractRect,"SubtractRect",\
		SystemParametersInfoW,"SystemParametersInfoW",\
		TrackPopupMenu,"TrackPopupMenu",\
		TranslateAcceleratorW,"TranslateAcceleratorW",\
		TranslateMessage,"TranslateMessage",\
		TranslateMDISysAccel,"TranslateMDISysAccel",\
		UnionRect,"UnionRect",\
		UnregisterClassW,"UnregisterClassW",\
		UpdateWindow,"UpdateWindow",\
		ValidateRect,"ValidateRect",\
		WindowFromDC,"WindowFromDC",\
		WindowFromPoint,"WindowFromPoint",\
		wsprintfW,"wsprintfW"

	import KERNEL32,\
		AllocConsole,"AllocConsole",\
		AttachConsole,"AttachConsole",\
		CloseHandle,"CloseHandle",\
		CopyFileW,"CopyFileW",\
		CreateDirectoryW,"CreateDirectoryW",\
		CreateFileW,"CreateFileW",\
		CreateProcessW,"CreateProcessW",\
		DeleteFileW,"DeleteFileW",\
		ExitProcess,"ExitProcess",\
		ExitThread,"ExitThread",\
		ExpandEnvironmentStringsW,"ExpandEnvironmentStringsW",\
		FindClose,"FindClose",\
		FindFirstFileW,"FindFirstFileW",\
		FindNextFileW,"FindNextFileW",\
		FileTimeToSystemTime,"FileTimeToSystemTime",\
		FindResourceW,"FindResourceW",\
		FindResourceExW,"FindResourceExW",\
		FreeConsole,"FreeConsole",\
		FreeLibrary,"FreeLibrary",\
		FreeLibraryAndExitThread,"FreeLibraryAndExitThread",\
		GetConsoleProcessList,"GetConsoleProcessList",\
		GetConsoleWindow,"GetConsoleWindow",\
		GetCommandLineW,"GetCommandLineW",\
		GetCurrentDirectoryW,"GetCurrentDirectoryW",\
		GetCurrentProcess,"GetCurrentProcess",\
		GetCurrentProcessId,"GetCurrentProcessId",\
		GetEnvironmentVariableW,"GetEnvironmentVariableW",\
		GetFileAttributesW,"GetFileAttributesW",\
		GetFileSize,"GetFileSize",\
		GetFileSizeEx,"GetFileSizeEx",\
		GetLastError,"GetLastError",\
		GetLocaleInfoEx,"GetLocaleInfoEx",\
		GetLocalTime,"GetLocalTime",\
		GetModuleFileNameW,"GetModuleFileNameW",\
		GetModuleHandleW,"GetModuleHandleW",\
		GetStdHandle,"GetStdHandle",\
		GetSystemDefaultLocaleName,"GetSystemDefaultLocaleName",\
		GetSystemTime,"GetSystemTime",\
		GetVersionExW,"GetVersionExW",\
		IsValidLocaleName,"IsValidLocaleName",\
		LCIDToLocaleName,"LCIDToLocaleName",\
		LoadLibraryExW,"LoadLibraryExW",\
		LoadResource,"LoadResource",\
		LocaleNameToLCID,"LocaleNameToLCID",\
		QueryPerformanceCounter,"QueryPerformanceCounter",\
		QueryPerformanceFrequency,"QueryPerformanceFrequency",\
		ReadFile,"ReadFile",\
		SetCurrentDirectoryW,"SetCurrentDirectoryW",\
		SetEndOfFile,"SetEndOfFile",\
		SetEnvironmentVariableW,"SetEnvironmentVariableW",\
		SetFilePointer,"SetFilePointer",\
		Sleep,"Sleep",\
		SystemTimeToFileTime,"SystemTimeToFileTime",\
		UnmapViewOfFile,"UnmapViewOfFile",\
		VirtualAlloc,"VirtualAlloc",\
		VirtualFree,"VirtualFree",\
		WaitForSingleObject,"WaitForSingleObject",\
		WriteFile,"WriteFile"

	import SHELL32,\
		CommandLineToArgvW,"CommandLineToArgvW",\
		SHCreateItemFromParsingName,"SHCreateItemFromParsingName",\
		SHGetFileInfoW,"SHGetFileInfoW",\
		SHGetKnownFolderPath,"SHGetKnownFolderPath",\
		Shell_GetImageLists,"Shell_GetImageLists",\
		ShellExecuteExW,"ShellExecuteExW"

	import SHLWAPI,\
		IUnknown_QueryService,"IUnknown_QueryService"

	import WININET,\
		CommitUrlCacheEntryW,'CommitUrlCacheEntryW',\
		CreateUrlCacheContainerW,'CreateUrlCacheContainerW',\
		CreateUrlCacheEntryW,'CreateUrlCacheEntryW',\
		CreateUrlCacheGroup,'CreateUrlCacheGroup',\
		DeleteIE3Cache,'DeleteIE3Cache',\
		DeleteUrlCacheContainerW,'DeleteUrlCacheContainerW',\
		DeleteUrlCacheEntryW,'DeleteUrlCacheEntryW',\
		DeleteUrlCacheGroup,'DeleteUrlCacheGroup',\
		DoConnectoidsExist,'DoConnectoidsExist',\
		ExportCookieFileW,'ExportCookieFileW',\
		FindCloseUrlCache,'FindCloseUrlCache',\
		FindFirstUrlCacheContainerW,'FindFirstUrlCacheContainerW',\
		FindFirstUrlCacheEntryW,'FindFirstUrlCacheEntryW',\
		FindFirstUrlCacheEntryExW,'FindFirstUrlCacheEntryExW',\
		FindFirstUrlCacheGroup,'FindFirstUrlCacheGroup',\
		FindNextUrlCacheContainerW,'FindNextUrlCacheContainerW',\
		FindNextUrlCacheEntryW,'FindNextUrlCacheEntryW',\
		FindNextUrlCacheEntryExW,'FindNextUrlCacheEntryExW',\
		FindNextUrlCacheGroup,'FindNextUrlCacheGroup',\
		FreeUrlCacheSpaceW,'FreeUrlCacheSpaceW',\
		FtpCommandW,'FtpCommandW',\
		FtpCreateDirectoryW,'FtpCreateDirectoryW',\
		FtpDeleteFileW,'FtpDeleteFileW',\
		FtpFindFirstFileW,'FtpFindFirstFileW',\
		FtpGetCurrentDirectoryW,'FtpGetCurrentDirectoryW',\
		FtpGetFileW,'FtpGetFileW',\
		FtpGetFileEx,'FtpGetFileEx',\
		FtpGetFileSize,'FtpGetFileSize',\
		FtpOpenFileW,'FtpOpenFileW',\
		FtpPutFileEx,'FtpPutFileEx',\
		FtpPutFileW,'FtpPutFileW',\
		FtpRemoveDirectoryW,'FtpRemoveDirectoryW',\
		FtpRenameFileW,'FtpRenameFileW',\
		FtpSetCurrentDirectoryW,'FtpSetCurrentDirectoryW',\
		GetUrlCacheConfigInfoW,'GetUrlCacheConfigInfoW',\
		GetUrlCacheEntryInfoW,'GetUrlCacheEntryInfoW',\
		GetUrlCacheEntryInfoExW,'GetUrlCacheEntryInfoExW',\
		GetUrlCacheGroupAttributeW,'GetUrlCacheGroupAttributeW',\
		GetUrlCacheHeaderData,'GetUrlCacheHeaderData',\
		GopherCreateLocatorW,'GopherCreateLocatorW',\
		GopherFindFirstFileW,'GopherFindFirstFileW',\
		GopherGetAttributeW,'GopherGetAttributeW',\
		GopherGetLocatorTypeW,'GopherGetLocatorTypeW',\
		GopherOpenFileW,'GopherOpenFileW',\
		HttpAddRequestHeadersW,'HttpAddRequestHeadersW',\
		HttpCheckDavComplianceW,'HttpCheckDavComplianceW',\
		HttpEndRequestW,'HttpEndRequestW',\
		HttpOpenRequestW,'HttpOpenRequestW',\
		HttpQueryInfoW,'HttpQueryInfoW',\
		HttpSendRequestW,'HttpSendRequestW',\
		HttpSendRequestExW,'HttpSendRequestExW',\
		ImportCookieFileW,'ImportCookieFileW',\
		IncrementUrlCacheHeaderData,'IncrementUrlCacheHeaderData',\
		InternetAlgIdToStringW,'InternetAlgIdToStringW',\
		InternetAttemptConnect,'InternetAttemptConnect',\
		InternetAutodial,'InternetAutodial',\
		InternetAutodialCallback,'InternetAutodialCallback',\
		InternetAutodialHangup,'InternetAutodialHangup',\
		InternetCanonicalizeUrlW,'InternetCanonicalizeUrlW',\
		InternetCheckConnectionW,'InternetCheckConnectionW',\
		InternetCloseHandle,'InternetCloseHandle',\
		InternetCombineUrlW,'InternetCombineUrlW',\
		InternetConfirmZoneCrossingW,'InternetConfirmZoneCrossingW',\
		InternetConnectW,'InternetConnectW',\
		InternetCrackUrlW,'InternetCrackUrlW',\
		InternetCreateUrlW,'InternetCreateUrlW',\
		InternetDialW,'InternetDialW',\
		InternetErrorDlg,'InternetErrorDlg',\
		InternetFindNextFileW,'InternetFindNextFileW',\
		InternetFortezzaCommand,'InternetFortezzaCommand',\
		InternetGetConnectedState,'InternetGetConnectedState',\
		InternetGetConnectedStateExW,'InternetGetConnectedStateExW',\
		InternetGetCookieW,'InternetGetCookieW',\
		InternetGetLastResponseInfoW,'InternetGetLastResponseInfoW',\
		InternetGoOnlineW,'InternetGoOnlineW',\
		InternetHangUp,'InternetHangUp',\
		InternetLockRequestFile,'InternetLockRequestFile',\
		InternetOpenUrlW,'InternetOpenUrlW',\
		InternetOpenW,'InternetOpenW',\
		InternetQueryDataAvailable,'InternetQueryDataAvailable',\
		InternetQueryFortezzaStatus,'InternetQueryFortezzaStatus',\
		InternetQueryOptionW,'InternetQueryOptionW',\
		InternetReadFile,'InternetReadFile',\
		InternetReadFileExW,'InternetReadFileExW',\
		InternetSecurityProtocolToStringW,'InternetSecurityProtocolToStringW',\
		InternetSetCookieW,'InternetSetCookieW',\
		InternetSetDialStateW,'InternetSetDialStateW',\
		InternetSetFilePointer,'InternetSetFilePointer',\
		InternetSetOptionW,'InternetSetOptionW',\
		InternetSetOptionExW,'InternetSetOptionExW',\
		InternetSetStatusCallbackW,'InternetSetStatusCallbackW',\
		InternetShowSecurityInfoByURLW,'InternetShowSecurityInfoByURLW',\
		InternetTimeFromSystemTimeW,'InternetTimeFromSystemTimeW',\
		InternetTimeToSystemTimeW,'InternetTimeToSystemTimeW',\
		InternetUnlockRequestFile,'InternetUnlockRequestFile',\
		InternetWriteFile,'InternetWriteFile',\
		InternetWriteFileExW,'InternetWriteFileExW',\
		IsHostInProxyBypassList,'IsHostInProxyBypassList',\
		IsUrlCacheEntryExpiredW,'IsUrlCacheEntryExpiredW',\
		LoadUrlCacheContent,'LoadUrlCacheContent',\
		ParseX509EncodedCertificateForListBoxEntry,'ParseX509EncodedCertificateForListBoxEntry',\
		PerformOperationOverUrlCacheW,'PerformOperationOverUrlCacheW',\
		ReadUrlCacheEntryStream,'ReadUrlCacheEntryStream',\
		RegisterUrlCacheNotification,'RegisterUrlCacheNotification',\
		ResumeSuspendedDownload,'ResumeSuspendedDownload',\
		RetrieveUrlCacheEntryFileW,'RetrieveUrlCacheEntryFileW',\
		RetrieveUrlCacheEntryStreamW,'RetrieveUrlCacheEntryStreamW',\
		RunOnceUrlCache,'RunOnceUrlCache',\
		SetUrlCacheConfigInfoW,'SetUrlCacheConfigInfoW',\
		SetUrlCacheEntryGroupW,'SetUrlCacheEntryGroupW',\
		SetUrlCacheEntryInfoW,'SetUrlCacheEntryInfoW',\
		SetUrlCacheGroupAttributeW,'SetUrlCacheGroupAttributeW',\
		SetUrlCacheHeaderData,'SetUrlCacheHeaderData',\
		ShowClientAuthCerts,'ShowClientAuthCerts',\
		ShowSecurityInfo,'ShowSecurityInfo',\
		ShowX509EncodedCertificate,'ShowX509EncodedCertificate',\
		UnlockUrlCacheEntryFileW,'UnlockUrlCacheEntryFileW',\
		UnlockUrlCacheEntryStream,'UnlockUrlCacheEntryStream',\
		UpdateUrlCacheContentPath,'UpdateUrlCacheContentPath'

	
	import MSVCRT,\
		__iob_func,"__iob_func",\
		_aligned_free,"_aligned_free",\
		_aligned_malloc,"_aligned_malloc",\
		_beginthread,"_beginthread",\
		_getwch,"_getwch",\
		_mbschr,"_mbschr",\
		_wsystem,"_wsystem",\
		free,"free",\
		freopen,"freopen",\
		gets,"gets",\
		malloc,"malloc",\
		printf,"printf",\
		rand,"rand",\
		scanf,"scanf",\
		scanf_s,"scanf_s",\
		strchr,"strchr",\
		swprintf,"swprintf",\
		swprintf_s,"swprintf_s",\
		wprintf, "wprintf",\
		wcschr,"wcschr",\		;find first occurrence of cp in a string
		wscanf_s,"wscanf_s"
