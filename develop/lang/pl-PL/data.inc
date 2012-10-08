  
  ;#-------------------------------------------------ß
  ;|          lang MPL 2.0 License                   |
  ;|   Copyright (c) 2011-2012, Marc Rainer Kranz.   |
  ;|            All rights reserved.                 |   
  ;|                                                 |
  ;|   Polish language extention by Tomasz Ziajko    |
  ;|                First draft                      |
  ;ö-------------------------------------------------ä

  ;#-------------------------------------------------ß
  ;| uft-8 encoded üäößąćęłńśóźż
  ;| update: 29-09-2012 13:11
  ;| filename:lang_pl.inc
  ;ö-------------------------------------------------ä

	
	@make_lang "pl-PL",0415h
	@make_uz \
		UZ_ERR_NOFILE,0,U8+UR,db "Nie można odnaleźć wybranego pliku",\
		UZ_HOME,0,U8+UR,db "http://sites.google.com/site/x64lab/",\
		UZ_CONS_WIN,0,U8+UR,db "Konsola",\
    UZ_EDIT_PANE,0,U8+UR,db "Panel Edycji",\
    UZ_EDIT_UNTL,0,U8+UR,db "00_buffer.untitled",\
    UZ_ERR_NODIR,0,U8+UR,db "Lokalizacja nie istnieje",\
    UZ_WSPACE,0,U8+UR,db "x64lab Przestrzeń Robocza",\
    UZ_CURDIR,0,U8+UR,db "Aktualna lokalizacja",\
    UZ_FSAVE,0,U8+UR,db "Zapisz plik ",\
    UZ_MPWIN,0,U8+UR,db "Uniwersalny",\
		UZ_CPPROCS,0,U8+UR,db "Działający Proces",\
    UZ_CPDIRS,0,U8+UR,db "Pliki i foldery",\
    UZ_CPNOSEL,0,U8+UR,db "Brak zaznaczenia",\
		UZ_INFO_UTF8,0,U8+UR,db ";--- Uwaga!! utf8 bez BOM'u äöüßąćęłńśóźż",\
		UZ_INFO_TOP,0,U8+UR,db ";--- TOP format file for x64lab",\
		UZ_INFO_COPYR,0,U8+UR,db ";--- Copyright Marc Rainer Kranz 2009-2012",\
		UZ_INFO_CDATE,0,U8+UR,db "Cstamp",\
		UZ_INFO_SIZE,0,U8+UR,db "Rozmiar",\
		UZ_INFO_TYPE,0,U8+UR,db "Typ",\
		UZ_INFO_BUF,0,U8+UR,db "Nazwa",\
		UZ_INFO_SELITEM,0,U8+UR,<db \
			"Proszę wybrać pozycję z drzewa w Przestrzeni Roboczej,",13,10,\
			"nowe komponenty zostaną dodane.">,\
		UZ_OK,0,U8+UR,db "Ok",\
		UZ_NO,0,U8+UR,db "Nie",\
		UZ_CANCEL,0,U8+UR,db "Anuluj",\
		UZ_IO_SELDPF,0,U8+UR,db "Wybierz miejsce przeznaczenia oraz nazwę pliku",\
		UZ_IO_DPATH,0,U8+UR,db "Dest. path",\
		UZ_IO_KDIR,0,U8+UR,db "Znane ścieżki",\
		UZ_IO_DFNAME,0,U8+UR,db "Dest. filename",\
		UZ_IO_EXT,0,U8+UR,db "nazwapliku.ext",\
		UZ_WSP_EXT,0,U8+UR,db "nazwapliku.x64lab",\
		UZ_OVERWFILE,0,U8+UR,db "Plik o wybranej nazwie już istnieje. Nadpisać ?",\
		UZ_COURNEW,0,U8+UR,db "Courier New",\
		UZ_IO_NEWWSP,0,U8+UR,db "Stwórz nową Przestrzeń Roboczą",\
		UZ_IO_SAVEWSP,0,U8+UR,db "Zapisz aktualną Przestrzeń Roboczą",\
		UZ_TOOLCMD,0,U8+UR,db "Komendy Narzędzi",\
		UZ_TOOLDESCR,0,U8+UR,db "Wybierz plik wykonywalny/wsadowy/pomoc itp.",\
		UZ_TOOLBYG,0,U8+UR,db "[Narzędzia według Grup]",\
		UZ_TOOLPICK,0,U8+UR,db "Wybierz Narzędzie",\
		MP_WSPACE,0,U8+UR,db "Work&space",\
			MI_WS_LOAD,0,U8+UR,db "&Wczytaj",\
			MI_WS_NEW,0,U8+UR,db "&Nowy",\
			MI_WS_ADD,0,U8+UR,db "Add &Project",\
			MI_WS_BACK,0,U8+UR,db "&Backup",\
			MI_WS_EXP,0,U8+UR,db "E&xport to archive",\
			MI_WS_SAVE,0,U8+UR,db "Zapisz wszystko",\
			MI_WS_SAVET,0,U8+UR,db "Zapisz jako szablon",\
			MI_WS_RECODE,0,U8+UR,db "Encode...",\
			MP_WS_REC,0,U8+UR,db "Ostatnia Przestrzeń Robocza",\
			MI_WS_EXIT,0,U8+UR,db "Wyjdź",\
		MP_FILE,0,U8+UR,db "&File",\
			MI_FI_OPEN,0,U8+UR,db "Otwórz dokumenty",\
			MI_FI_NEWB,0,U8+UR,db "Nowy pusty dokument",\
			MI_FI_NEWF,0,U8+UR,db "Nowy plik",\
			MI_FI_IMP,0,U8+UR,db "Zaimportuj do przestrzeni roboczej",\
			MI_FI_CLOSE,0,U8+UR,db "Zamknij dokument",\
			MI_FI_CCOPY,0,U8+UR,db "Stwórz kopię",\
			MI_FI_SAVE,0,U8+UR,db "Zapisz aktualny plik",\
			MI_FI_SAVEAS,0,U8+UR,db "Zapisz jako",\
			MI_FI_ENCO,0,U8+UR,db "Zakoduj aktualny",\
			MI_FI_BACK,0,U8+UR,db "Kopia zapasowa jako",\
		MP_EDIT,0,U8+UR,db "Edytuj",\
			MI_ED_LNK,0,U8+UR,db "Wstaw nowe inteligente łącze",\
			MI_ED_REMITEM,0,U8+UR,db "Usuń obiekt z Przestrzeni Roboczej",\
			MI_ED_RELSCICLS,0,U8+UR,db "Reload Scintilla classes",\
		MP_CONF,0,U8+UR,db "C&onfigure",\
		MI_CONF_KEY,0,U8+UR,db "Przypisanie klawiszy",\
			MP_LANG,0,U8+UR,db "Language",\
		MP_DEVT,0,U8+UR,db "Narzędzia Programisty",\
			MI_DEVT_ADD,0,U8+UR,db "Przeglądaj aby dodać nowe narzędzie",\
			MI_DEVT_REM,0,U8+UR,db "Usuń narzędzie",\
			MI_DEVT_ADDG,0,U8+UR,db "Dodaj nową etykietę GRUPA",\
			MI_DEVT_REMG,0,U8+UR,db "Usuń GRUPĘ",\
			MI_DEVT_MAN,0,U8+UR,db "Zarządzanie plikiem narzędzi (dla zaawansowanych Urzytkowników)",\
			MI_DEVT_REL,0,U8+UR,db "Przeładuj Narzędzia",\
		MP_SCI,0,U8+UR,db "Scintilla",\
			MI_SCI_COMML,0,U8+UR,db "Zakomentuj linie",\
			MI_SCI_COMMB,0,U8+UR,db "Zakomentuj bloki",\
			MI_SCI_UNCOMML,0,U8+UR,db "Usuń komentarze w liniach",\
			MI_SCI_UNCOMMB,0,U8+UR,db "Usuń komentarze w blokach",\
		MP_UPD,0,U8+UR,db "(no transl) Update",\
			MI_UPD_LANG,0,U8+UR,db "(no transl) Language update (script)",\
		MP_PATH,0,U8+UR,db "[?]",\
			MI_PA_CONS,0,U8+UR,db "Otwórz konsolę tutaj",\
			MI_PA_BROWSE,0,U8+UR,db "Przeglądaj",\
			MI_PA_FIND,0,U8+UR,db "Szukaj tutaj",\
			MI_PA_COPY,0,U8+UR,db "Skopiuj tą ścieżkę",\
			MI_PA_SETPROP,0,U8+UR,db "Włącz przeglądanie",\
			BB_NULL,0,U8+UR,db "Przeglądaj według kategorii",\
			BB_WSP,0,U8+UR,db "Przestrzeń robocza i pliki",\
			BB_FOLDER,0,U8+UR,db "Folder",\
			BB_CODE,0,U8+UR,db "Kod",\
			BB_CALL,0,U8+UR,db "Wywołanie",\
			BB_COMMENT,0,U8+UR,db "Komentarze",\
			BB_DATA,0,U8+UR,db "Ilości danych",\
			BB_EXPORT,0,U8+UR,db "Wyeksportowane funkcje",\
			BB_FLOW,0,U8+UR,db "Przepływ",\
			BB_IMM,0,U8+UR,db "Zmienne bezpośrednie",\
			BB_IMPORT,0,U8+UR,db "Zaimportowane funkcje",\
			BB_LABEL,0,U8+UR,db "Etykiety",\
			BB_MACRO,0,U8+UR,db "Makro",\
			BB_PROC,0,U8+UR,db "Procs and Calleé",\
			BB_PROCESS,0,U8+UR,db "Procesy",\
			BB_REG,0,U8+UR,db "Rejestry",\
			BB_RET,0,U8+UR,db "Powroty",\
			BB_SYS,0,U8+UR,db "System",\
			UZ_DESCR,0,U8+UR,db "Opis",\
			UZ_INFO_LNK,0,U8+UR,db "Stwórz nowe Inteligentne Łącze",\
			UZ_LNK_NAME,0,U8+UR,db "Nazwa Inteligentnego Łącza",\
			UZ_LNK_MAP,0,U8+UR,db "mapped by",\
			UZ_LNK_DESC,0,U8+UR,db "Wybierz lokalizację jako odniesienie",\
			UZ_DATEFRM,0,U8+UR,db "dddd','dd'.'MMMM'.'rrrr",\
			UZ_TIMEFRM,0,U8+UR,db "gg':'mm':'ss",\
			UZ_DEFUSER,0,U8+UR,db "Mr.Biberkopf",\
			UZ_TOOLGEN,0,U8+UR,db "Narzędzia wszystkich zastosowań",\
			UZ_INFO_TREL,0,U8+UR,<db \
				"Po edycji pliku [config\devtool.utf8], nie zapomnij",13,10,\
				"załadować ponownie narzędzi wybierając z menu pozycję [Przeładuj Narzędzia]">,\
			UZ_MSG_U_TGREM,0,U8+UR,<db \
				"Usunięcie grupy [%ls] jest nieodwracalne. ",13,10,\
				"Narzędzia, które zawiera, również zostaną usunięte !",13,10,\
				"Usunąć trwale ?">,\
			UZ_MSG_TADDG,0,U8+UR,<db \
				"- Wybierz 'Narzędzia programisty' w Oknie 'Uniwerslany'",13,10,\
				"- Wpisz coś do wspólnej edycji wymienionych grup",13,10,\
				"- Wciśnij <Enter> aby zaakceptować tą etykietę jako nazwę Grupy">,\
			UZ_MSG_SCIREL,0,U8+UR,<db \
				"Po zapisaniu plików klas Scintilli, proszę zamknąć i otworzyć ponownie",13,10,\
        "aktualny edytor również otwiera pliki w kolejności",13,10,\
        "aby wybrać zmiany koloru składni">,\
			UZ_MSG_REMITEM,0,U8+UR,<db \
				"Uwaga: Pozycja w Przestrzeni Roboczej zawiera sub-pozycje. Usunięcie jej",13,10,\
        "spowoduje również usunięcie zawieranych przez nią sub-pozycji. Jest to nieodwracalne.",13,10,\
        "Usunąć pozycję oraz jej sub-pozycje?">,\
			UZ_REBUILD,0,U8+UR,db "Przebuduj",\
			UZ_SET,0,U8+UR,db " Ustaw",\
			\;--- Courier New doesent have glyphs for the 3 circ. encl. c,a,s
			\;--- http://en.wikipedia.org/wiki/Enclosed_alphanumerics
			UZ_CTRL,0,U8+UR,db "(ⓒ) Ctrl",\
			UZ_ALT,0,U8+UR,db "(ⓐ) Alt",\
			UZ_SHIFT,0,U8+UR,db "(ⓢ) Shift",\
			\;---------------------------------------------------------------------
			UZ_NOINV,0,U8+UR,db "Nie ma odwrócenia",\
			UZ_NOTASS,0,U8+UR,db "Nie ma wyznaczonego zadania",\
			UZ_WZERO,0,U8+UR,db "0000",\
			UZ_RESTART,0,U8+UR,db "Please restart x64lab to apply change. Close it now ?",\
			UZ_MSG_LNK,0,U8+UR,<db "(no transl.) The selected treeitem is empty.",13,10,\
				"Add this smartlink as its first child item ?">


