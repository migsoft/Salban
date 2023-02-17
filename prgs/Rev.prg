/*
 * $Id: Rev.prg,v 1.1 2012/06/06 11:58:16 migsoft Exp $
 * Saldos Bancarios - Sistema de Control de Saldos
 * Copyright 2007-2012 Miguel Angel Juárez A. <fugaz_cl@yahoo.es>
 * MigSoft Sistemas - www.mig2soft.com
 * <http://sourceforge.net/projects/saldobanco>
 */

/*-------------------------------PRINCIPAL--------------------------------------*/

#include "minigui.ch"
#include "miniprint.ch"
#include "rev.ch"

#define cSalBuild      VERSION
#define cNameBuild     COPYRIGHT+PROGRAM
#define cCred          COPYRIGHT
#define Proj           WEBSOURCE
#define aAZUL          {   0 , 128 , 192   }
#define aCELESTE       {   0 , 128 , 255   }
#define aVERDE         {   0 , 128 , 128   }
#define aCAFE          { 128 , 64  ,   0   }

/*1-----------------------------------------------------------------------------*/
Function Main()

    Iniciales()
    Load Window Inicio
    Ajusta()
    Center Window Inicio
    Win_Splash()
    ACTIVATE WINDOW Inicio

Return(Nil)

Procedure Ajusta()
    Inicio.WIDTH             := GetDesktopWidth()  - GetDesktopWidth() * 0.10
    Inicio.HEIGHT            := GetDesktopHeight() - GetDesktopHeight()* 0.10
    Inicio.Image_1.Row       := GetDesktopHeight()* 0.5 - 131
    Inicio.Image_1.Col       := GetDesktopWidth() * 0.5 - 122
    Inicio.HyperLink_1.Row   := GetDesktopHeight()* 0.5 + 94
    Inicio.HyperLink_1.Col   := GetDesktopWidth() * 0.5 - 110
Return
    /*1a----------------------------------------------------------------------------*/
Procedure Win_Splash()
    If !IsWindowDefined(MT_Splash)
        DEFINE WINDOW MT_Splash ;
            AT 0, 0 ;
            WIDTH 438 HEIGHT 291 ;
            TOPMOST NOCAPTION ;
            ON INIT SplashDelay() MODAL

            @ -4, -4 IMAGE img_1 ;
                PICTURE 'FONDO' ;
                WIDTH 438 ;
                HEIGHT 291
        END WINDOW
    Endif
    CENTER WINDOW MT_Splash
    ACTIVATE WINDOW MT_Splash
Return
    /*2-----------------------------------------------------------------------------*/
STATIC FUNCTION SplashDelay
    LOCAL iTime
    iTime := Seconds()
    While Seconds() - iTime < 2
    EndDo
    MT_Splash.Release
    Inicio.Maximize
RETURN NIL
    /*3-----------------------------------------------------------------------------*/
Procedure Iniciales
    Declare window Imagen
    Declare window Resumen
    Declare window IngMovi
    Declare window IngCtas
    Declare window IngBcos
    Declare window NavegaMovi
    Declare window NavegaCtas
    Declare window NavegaBcos

    Public Nuevo,lNext,TraBco,cNomb,nSalIni,nRegb,nValSel,SalBuild,cproj
    Public lNewCta,lNewBco,lNewSal,Fec_Inicio,Fec_Final,NameBuild,azul,celeste,verde,cafe
    Public SaldoFolder := GetStartupFolder()+"\dbfs"

    REQUEST HB_LANG_ES
    HB_LANGSELECT( "ES" )
    Set Navigation Extended
    Set Delete on
    Set Date Brit                         //  dd/mm/aa
    Set Softseek on
    Set BrowseSync on
    NameBuild  := cNameBuild
    AZUL       := aAZUL
    CELESTE    := aCELESTE
    VERDE      := aVERDE
    CAFE       := aCAFE
    SalBuild   := cSalBuild
    cProj      := Proj
    una        := .T.
    fec_inicio := ctod("01/01/2007")
    fec_final  := date()
    Request DBFCDX , DBFFPT
    Rddsetdefault( "DBFCDX" )
Return
    /*4-----------------------------------------------------------------------------*/
Procedure SinProblem()
    IF !IsWindowDefined(Vip)
        Load Window Vip
        Center Window Vip
        Activate Window Vip
    EndIf
Return
    /*5-----------------------------------------------------------------------------*/
Procedure OpenTables()
    ImageCenter()
    DBCloseAll()

    If !HB_DirExists( SaldoFolder + hb_osPathSeparator() )
        DirMake( SaldoFolder + hb_osPathSeparator() )
    Endif

    if file(SaldoFolder+'\mae_bcos.dbf')
        use &(SaldoFolder+'\mae_bcos') shared
        if !FCOUNT() = 5
            close mae_bcos
            copy file &(SaldoFolder+'\mae_bcos.dbf') to &(SaldoFolder+'\temp_.dbf')
            ferase(SaldoFolder+'\mae_bcos.dbf')
            creabcos()
            use &(SaldoFolder+'\mae_bcos')
            appe from &(SaldoFolder+'\temp_.dbf')
            Ferase(SaldoFolder+'\temp_.dbf')
            close mae_bcos
        endif
        close mae_bcos
    else
        creabcos()
        appe blank
        FIELDPUT(1, 0 )
        FIELDPUT(2,"CAJA")
        close mae_bcos
    endif
    if file(SaldoFolder+'\'+"m_bancos.dbf")
        use &(SaldoFolder+'\m_bancos') shared
        if !FCOUNT() = 9
            close m_bancos
            copy file &(SaldoFolder+'\'+"m_bancos.dbf") to &(SaldoFolder+'\'+"temp_.dbf")
            ferase(SaldoFolder+'\'+"m_bancos.dbf")
            creamovi()
            use &(SaldoFolder+'\'+m_bancos)
            appe from &(SaldoFolder+'\'+"temp_.dbf")
            Ferase(&(SaldoFolder+'\'+"temp_.dbf"))
            close m_bancos
        endif
        close m_bancos
    else
        creamovi()
        close m_bancos
    endif
    If !File( SaldoFolder+'\'+"cuentas.dbf" )
        creactas()
        use &(SaldoFolder+'\cuentas')
        appe blank
        FIELDPUT(1, 0 )
        FIELDPUT(2,"SIN IMPUTACION")
        close cuentas
    EndIf
    If !File( SaldoFolder+'\'+"resal.dbf" )
        crearesumen()
        close resal
    Endif
    SinProblem()
Return Nil

Procedure ImageCenter()
    nDer := ( ( Inicio.Width - GetBorderWidth() ) / 2 )
    nImg := ( Inicio.Image_1.width / 2)
    nArr := ( ( Inicio.Height - GetTitleHeight() - GetBorderHeight() ) / 2 )
    nIma := ( Inicio.Image_1.height / 2)
    Inicio.Image_1.col := nDer - nImg
    Inicio.Image_1.row := nArr - nIma

    Inicio.HyperLink_1.Row   := Inicio.Image_1.row + 250
    Inicio.HyperLink_1.Col   := Inicio.Image_1.col
Return
    /*6-----------------------------------------------------------------------------*/
Procedure Creamovi
    local aStruct:= { { 'BANCO'      , 'N' ,  4 , 0 }, ;
        { 'FEC_PAGO'   , 'D' ,  8 , 0 }, ;
        { 'FEC_COBRO'  , 'D' ,  8 , 0 }, ;
        { 'CHEQUE'     , 'N' , 10 , 0 }, ;
        { 'DEBE'	  , 'N' , 15 , 2 }, ;
        { 'HABER'      , 'N' , 15 , 2 }, ;
        { 'DETALLE'    , 'C' , 40 , 0 }, ;
        { 'IMPUTACION' , 'N' ,  7 , 0 }, ;
        { 'SALDO'      , 'N' , 15 , 2 } }
    REQUEST DBFCDX
    DBCreate( SaldoFolder+'\m_bancos', aStruct, "DBFCDX",.T.,"m_bancos" )
Return
    /*7-----------------------------------------------------------------------------*/
Procedure Creactas
    local aStruct:= { { 'IMPUTACION' , 'N' ,  7  , 0 }, ;
        { 'NOMBRE'     , 'C' ,  30 , 0 } }
    REQUEST DBFCDX
    DBCreate( SaldoFolder+'\cuentas', aStruct, "DBFCDX",.T.,"cuentas" )
Return
    /*8-----------------------------------------------------------------------------*/
Procedure Creabcos
    local aStruct:= { { 'BANCO'    , 'N' ,  4  , 0 }, ;
        { 'NOMBRE'   , 'C' ,  30 , 0 }, ;
        { 'CUENTA'   , 'C' ,  20 , 0 }, ;
        { 'LOGOBCO'  , 'C' , 200 , 0 }, ;
        { 'SALDINI'  , 'N' ,  15 , 2 } }
    REQUEST DBFCDX
    DBCreate( SaldoFolder+'\mae_bcos', aStruct, "DBFCDX",.T.,"mae_bcos" )
Return
    /*9-----------------------------------------------------------------------------*/
Procedure CreaResumen
    local aStruct:= { { 'BANCO'      , 'N' ,  4 , 0 }, ;
        { 'NOMBRE'     , 'C' , 30 , 0 }, ;
        { 'ERA'        , 'N' ,  4 , 0 }, ;
        { 'SALDO'      , 'N' , 15 , 2 }  }
    REQUEST DBFCDX
    DBCreate( SaldoFolder+'\resal', aStruct, "DBFCDX",.T.,"resal" )
Return
    /*-----------------------------------SISTEMA-------------------------------------*/

    /*12-----------------------------------------------------------------------------*/
Static Function CPUName()
    Local cName := ""

    IF IsWinNT()
        cName := GetRegVar(HKEY_LOCAL_MACHINE,"HARDWARE\DESCRIPTION\System\CentralProcessor\0","Identifier")
        cName2 := GetRegVar(HKEY_LOCAL_MACHINE,"HARDWARE\DESCRIPTION\System\CentralProcessor\0","VendorIdentifier")
    ENDIF

return( cName2+' '+cName )
    /*13-----------------------------------------------------------------------------*/
Static Function BiosName()
    Local cName

    IF IsWinNT()
        cName := Token( GetRegVar( HKEY_LOCAL_MACHINE, "HARDWARE\DESCRIPTION\System";
            ,"SystemBiosVersion")," " )+ ", " + ;
            GetRegVar( HKEY_LOCAL_MACHINE, "HARDWARE\DESCRIPTION\System","SystemBiosDate" )
    ELSE
        cName := Token( GetRegVar( HKEY_LOCAL_MACHINE, "Enum\Root\*PNP0C01\0000",;
            "BIOSVersion" ), " " ) + ", " + GetRegVar( HKEY_LOCAL_MACHINE,;
            "Enum\Root\*PNP0C01\0000", "BIOSDate" )
    ENDIF

return cName
    /*14-----------------------------------------------------------------------------*/
Static Function GetRegVar(nKey, cRegKey, cSubKey, uValue)
    Local oReg, cValue

    nKey     := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
    uValue   := IF(uValue == NIL, "", uValue)
    oReg     := TReg32():Create(nKey, cRegKey)
    cValue   := oReg:Get(cSubKey, uValue)
    oReg:Close()

RETURN cValue
    /*15-----------------------------------------------------------------------------*/
Static Function IsWinNT()                           // Detect NT/2000/XP
return GetE("OS") == "Windows_NT"
    /*16-----------------------------------------------------------------------------*/
Static Function InfoSystem()
    ShellAbout( NameBuild,cCred+chr(10)+chr(13)+cProj )
return nil
    /*17-----------------------------------------------------------------------------*/

    /*18-----------------------------------------------------------------------------*/
Static Function cFilePath( cPathMask )

    LOCAL n := RAt( "\", cPathMask )

return If( n > 0, Upper( Left( cPathMask, n - 1) ), ;
        If( At( ":", cPathMask ) == 2, ;
        Upper( Left( cPathMask, 2 ) ), "" ) )
    /*19-----------------------------------------------------------------------------*/
Procedure LectoFiles()
    Local aFile , i
    aFile := Putfile ( { {'All Files','*.*'} } , 'Open File' , 'c:\' , .t. , .t. )
    For i := 1 To len (aFile)
        msginfo (aFile [i])
    Next x
Return
    /*10-----------------------------------------------------------------------------*/
Procedure ReindexaTables()
    CloseTables()
    BorraCdx()
    OpenTables()
Return

Procedure BorraCdx()
    Aeval( Directory(SaldoFolder+'\*.cdx'), { |aFile| FErase(SaldoFolder+'\'+aFile[1]) } )
Return
    /*11-----------------------------------------------------------------------------*/
Procedure CloseTables()
    DBCLOSEALL()
Return
    /*20-----------------------------------------------------------------------------*/
Function Indexando()
    CloseTables()
    Abrirbase()
Return
    /*21-----------------------------------------------------------------------------*/
Function Abrirbase()
    NombreP = 'Bancos    '
    ferase(SaldoFolder+'\'+"*.cdx")
    USE &(SaldoFolder+'\MAE_BCOS.dbf') NEW SHARED
    if !file(SaldoFolder+'\'+"mae_bcos.cdx")
        nRegb := Reccount()
        Vip.ProgressBar_1.Rangemax := 100           //Lastrec()
        Vip.Title := NombreP
        INDEX on BANCO  TAG BANCO   TO &(SaldoFolder+'\mae_bcos') EVAL Encurso() EVERY LASTREC()/10
        Vip.ProgressBar_1.Value := 0
        INDEX on NOMBRE TAG NOMBRE  TO &(SaldoFolder+'\mae_bcos') EVAL Encurso() EVERY LASTREC()/10
        Vip.ProgressBar_1.Value := 0
        INDEX on CUENTA TAG CUENTA  TO &(SaldoFolder+'\mae_bcos') EVAL Encurso() EVERY LASTREC()/10
        Vip.ProgressBar_1.Value := 0
    endif
    SET INDEX TO &(SaldoFolder+'\mae_bcos')

    NombreP = 'Cuentas   '
    USE &(SaldoFolder+'\CUENTAS.dbf')  NEW SHARED
    if !file(SaldoFolder+'\'+"cuentas.cdx")
        Vip.ProgressBar_1.Rangemax := 100           //Lastrec()
        Vip.Title := NombreP
        INDEX on STR(IMPUTACION,7) TAG IMPUTACION TO &(SaldoFolder+'\cuentas') EVAL Encurso() EVERY LASTREC()/10
        Vip.ProgressBar_1.Value := 0
        INDEX on NOMBRE     TAG NOMBRE     TO &(SaldoFolder+'\cuentas') EVAL Encurso() EVERY LASTREC()/10
        Vip.ProgressBar_1.Value := 0
    endif
    SET INDEX TO &(SaldoFolder+'\cuentas')

    NombreP = 'Movimiento'
    USE &(SaldoFolder+'\M_BANCOS.dbf') NEW SHARED
    if !file(SaldoFolder+'\'+"m_bancos.cdx")
        Vip.ProgressBar_1.Rangemax := 100           //Lastrec()
        Vip.Title := NombreP
        INDEX on BANCO             TAG banco     TO &(SaldoFolder+'\m_bancos') EVAL Encurso() EVERY LASTREC()/10
        Vip.ProgressBar_1.Value := 0
        INDEX on FEC_PAGO          TAG fec_pago  TO &(SaldoFolder+'\m_bancos') EVAL Encurso() EVERY LASTREC()/10
        Vip.ProgressBar_1.Value := 0
        INDEX on CHEQUE            TAG cheque    TO &(SaldoFolder+'\m_bancos') EVAL Encurso() EVERY LASTREC()/10
        Vip.ProgressBar_1.Value := 0
        INDEX on DETALLE           TAG detalle   TO &(SaldoFolder+'\m_bancos') EVAL Encurso() EVERY LASTREC()/10
        Vip.ProgressBar_1.Value := 0
        INDEX on STR(IMPUTACION,7) TAG imputmov  TO &(SaldoFolder+'\m_bancos') EVAL Encurso() EVERY LASTREC()/10
        Vip.ProgressBar_1.Value := 0
        INDEX on DTOS(FEC_PAGO)    TAG dfec_pago TO &(SaldoFolder+'\m_bancos') EVAL Encurso() EVERY LASTREC()/10
        Vip.ProgressBar_1.Value := 0
        INDEX on DTOS(FEC_COBRO)   TAG dfec_pago TO &(SaldoFolder+'\m_bancos') EVAL Encurso() EVERY LASTREC()/10
        Vip.ProgressBar_1.Value := 0
        INDEX on STR(BANCO,4)+DTOS(FEC_COBRO) TAG bco_fecc TO &(SaldoFolder+'\m_bancos') EVAL Encurso() EVERY LASTREC()/10
        Vip.ProgressBar_1.Value := 0
        INDEX on STR(BANCO,4)+DTOS(FEC_PAGO)+STR(CHEQUE,10) TAG bco_fecpch TO &(SaldoFolder+'\m_bancos') EVAL Encurso() EVERY LASTREC()/10
        Vip.ProgressBar_1.Value := 0
        INDEX on STR(BANCO,4)+STR(CHEQUE,10) TAG bco_ch TO &(SaldoFolder+'\m_bancos') EVAL Encurso() EVERY LASTREC()/10
        Vip.ProgressBar_1.Value := 0
    endif
    SET INDEX TO &(SaldoFolder+'\m_bancos')

    NombreP = 'Resumen   '
    USE &(SaldoFolder+'\RESAL.dbf')  NEW SHARED
    if !file(SaldoFolder+'\'+"resal.cdx")
        Vip.ProgressBar_1.Rangemax := 100           //Lastrec()
        Vip.Title := NombreP
        INDEX on BANCO          TAG resban  TO &(SaldoFolder+'\resal') EVAL Encurso() EVERY LASTREC()/10
        Vip.ProgressBar_1.Value := 0
        INDEX on ERA            TAG era     TO &(SaldoFolder+'\resal') EVAL Encurso() EVERY LASTREC()/10
    Endif
    SET INDEX TO &(SaldoFolder+'\resal')

Return(.T.)
    /*22-----------------------------------------------------------------------------*/
Function Encurso()
    Local completo := ( RECNO()/ LASTREC())  * 100
    IF IsWindowDefined(Vip)
        Vip.ProgressBar_1.Value := completo
        Vip.ProgressBar_1.Refresh
    ENDIF
Return .T.
    /*23-----------------------------------------------------------------------------*/
Procedure FiltraFechas()
    IF !IsWindowDefined(Limite)
        Load Window Limite
        Center Window Limite
        Activate Window Limite
    EndIf
Return
    /*24-----------------------------------------------------------------------------*/
Function LimiteFechas()
    fec_inicio := Limite.DatePicker_1.value
    fec_final  := Limite.DatePicker_2.value
    Limite.release
Return
    /*25-----------------------------------------------------------------------------*/
function Filtrodefechas
    sele m_bancos
    set filter to
    Set Filter to m_bancos->(banco)=trabco .and. m_bancos->(fec_pago) >= fec_inicio ;
        .and. m_bancos->(fec_pago) <= fec_final
    go top
    SaldoBanco()
return
    /*26-----------------------------------------------------------------------------*/
function FiltraCheques
    sele m_bancos
    set filter to
    set filter to m_bancos->(banco)=trabco .and. m_bancos->(fec_pago) >= fec_inicio ;
        .and. m_bancos->(fec_pago) <= fec_final .and. m_bancos->(debe) = 0 ;
        .and. empty(m_bancos->(fec_cobro))
    go top
    SaldoBanco()
return
    /*27-----------------------------------------------------------------------------*/
Procedure MuestraRecCta()
    IF !IsWindowDefined(NavegaCtas)
        DEFINE WINDOW NavegaCtas
    Endif
    NavegaCtas.StatusBar.Item(1) := 'Reg: '                   ;
            +padl(Alltrim(Str(NavegaCtas.Browse_1.Value)),5)  ;
            +'/'+padl(Alltrim(Str(cuentas->(lastrec()))),5)
Return
        /*28-----------------------------------------------------------------------------*/
Procedure MuestraRecMovi()
    IF !IsWindowDefined(NavegaMovi)
        DEFINE WINDOW NavegaMovi
    Endif
    NavegaMovi.StatusBar.Item(1) := 'Reg: '                   ;
            +padl(Alltrim(Str(NavegaMovi.Browse_1.Value)),5)  ;
            +'/'+padl(Alltrim(Str(m_bancos->(lastrec()))),5)
Return
        /*29-----------------------------------------------------------------------------*/
Procedure MuestraRecBco()
    IF !IsWindowDefined(NavegaBcos)
        DEFINE WINDOW NavegaBcos
        Endif
        NavegaBcos.StatusBar.Item(1) := 'Reg: ' ;
            +padl(Alltrim(Str(NavegaBcos.Browse_1.Value)),5)     ;
            +'/'+padl(Alltrim(Str(mae_bcos->(lastrec()))),5)
Return
        /*30-----------------------------------------------------------------------------*/
Function MuestraFoto()
    If !IsWindowDefined(IngBcos)
        DEFINE WINDOW IngBcos
    Endif
    IngBcos.Image_1.Picture := alltrim(IngBcos.Text_5.value)
    If File( alltrim(IngBcos.Text_5.value) )
       IngBcos.Image_1.Picture := alltrim(IngBcos.Text_5.value)
    Else
       IngBcos.Image_1.Picture := "0.bmp"
    Endif
    IngBcos.Image_1.refresh
Return
        /*31-----------------------------------------------------------------------------*/
    /*32-----------------------------------------------------------------------------*/
Function ImprimeMovi()
    FiltraFechas()
    if lNext
        filtrodefechas()
        MPrintlib()
    endif
    lNext := .F.
Return
    /*33-----------------------------------------------------------------------------*/
Function ChequesNoCob()
    SeleBanco()
    FiltraFechas()
    if lNext
        filtraCheques()
        MPrintlib()
    endif
    lNext := .F.
Return
    /*34-----------------------------------------------------------------------------*/
Function OpcRespaldo()
    ComprimeBases()
    OpenTables()
Return
    /*35-----------------------------------------------------------------------------*/
Function OpcRestaurar()
    RestauraBases()
    OpenTables()
Return

    /*36-----------------------------------------------------------------------------*/
Function PrintVoucher()
    local lbien_
    Select printer dialog to lbien_ preview
    if lbien_
        ImprimeVoucher()
    endif
Return
    /*37-----------------------------------------------------------------------------*/
Function ImprimeVoucher()
    start printdoc
    start printpage
    @  10 ,160 print NameBuild FONT "Arial" size 9 ITALIC color BLACK
    @  20 , 85 print "COMPROBANTE" FONT "Times New Roman" size 14 BOLD color BLACK
    @  30 , 25 print "BANCO :" FONT "Times New Roman" size 10 BOLD color BLACK
    @  30 , 45 print mae_bcos->nombre FONT "Courier New" size 10 color BLACK
    @  30 ,160 print "Nro   :" FONT "Times New Roman" size 10 BOLD color BLACK
    @  30 ,175 print padl(TRANSFORM( recno(), "9999999" ),7) FONT "Courier New" size 10 color BLACK
    @  40 , 20 PRINT RECTANGLE to 115, 195 PENWIDTH 0.2 COLOR BLACK
    @  40 , 20 PRINT RECTANGLE to 50 , 105 PENWIDTH 0.2 COLOR BLACK
    @  43 , 25 print "CHEQUE :" FONT "Times New Roman" size 12 BOLD color BLACK
    @  43 , 75 print padl(TRANSFORM( m_bancos->cheque, "99999999" ),8) FONT "courier New" size 12 color BLACK
    @  43 ,120 print "FECHA EMISION:" FONT "Times New Roman" size 10 BOLD color BLACK
    @  43 ,170 print padr(dtoc(fec_pago),8) FONT "Courier New" size 10 color BLACK
    @  50 ,120 print "FECHA A PAGAR:" FONT "Times New Roman" size 10 BOLD color BLACK
    @  50 ,170 print padr(dtoc(fec_cobro),8) FONT "Courier New" size 10 color BLACK
    @  55 , 25 print "DETALLE :" FONT "Times New Roman" size 10 BOLD color BLACK
    @  55 , 48 print padr(TRANSFORM( detalle, "@!" ),30) FONT "Courier New" size 10 color BLACK
    @  65 , 25 print "NOTA :" FONT "Times New Roman" size 10 BOLD color BLACK
    @  70 , 48 PRINT LINE to 70, 195 PENWIDTH 0.2 COLOR BLACK
    @  80 , 48 PRINT LINE to 80, 195 PENWIDTH 0.2 COLOR BLACK
    @  90 , 20 PRINT RECTANGLE to 115, 195 PENWIDTH 0.2 COLOR BLACK
    @  105,110 PRINT RECTANGLE to 115, 195 PENWIDTH 0.2 COLOR BLACK
    @  100, 25 print "CUENTA:" FONT "Times New Roman" size 10 BOLD color BLACK
    @  100, 45 print padr(TRANSFORM(NombreCta(imputacion),"@!"),30) FONT "Courier New" size 9 color BLACK
    @  105, 25 print "CODIGO:" FONT "Times New Roman" size 10 BOLD color BLACK
    @  105, 45 print padl(TRANSFORM(imputacion, "9999999"),7) FONT "Courier New" size 10 color BLACK
    @  108,115 print "MONTO :" FONT "Times New Roman" size 12 BOLD color BLACK
    @  108,145 print iif(empty(haber),padl(TRANSFORM(debe, "@E 9,999,999,999.99" ),16),padl(TRANSFORM(haber, "@E 9,999,999,999.99" ),16)) FONT "Courier New" size 12 color BLACK
    @  128, 43 PRINT LINE to 128,  83 PENWIDTH 0.2 COLOR BLACK
    @  128,130 PRINT LINE to 128, 170 PENWIDTH 0.2 COLOR BLACK
    @  130, 50 print "RESPONSABLE" FONT "Times New Roman" size 10 BOLD color BLACK
    @  130,145 print "V°. B°." FONT "Times New Roman" size 10 BOLD color BLACK

    @150  , 85 print "COMPROBANTE" FONT "Times New Roman" size 14 BOLD color BLACK
    @160  , 25 print "BANCO :" FONT "Times New Roman" size 10 BOLD color BLACK
    @160  , 45 print mae_bcos->nombre FONT "Courier New" size 10 color BLACK
    @160  ,160 print "Nro   :" FONT "Times New Roman" size 10 BOLD color BLACK
    @160  ,175 print padl(TRANSFORM( recno(), "9999999" ),7) FONT "Courier New" size 10 color BLACK
    @170  , 20 PRINT RECTANGLE to 245, 195 PENWIDTH 0.2 COLOR BLACK
    @170  , 20 PRINT RECTANGLE to 180, 105 PENWIDTH 0.2 COLOR BLACK
    @173  , 25 print "CHEQUE :" FONT "Times New Roman" size 12 BOLD color BLACK
    @173  , 75 print padl(TRANSFORM( m_bancos->cheque, "99999999" ),8) FONT "courier New" size 12 color BLACK
    @173  ,120 print "FECHA EMISION:" FONT "Times New Roman" size 10 BOLD color BLACK
    @173  ,170 print padr(dtoc(fec_pago),8) FONT "Courier New" size 10 color BLACK
    @180  ,120 print "FECHA A PAGAR:" FONT "Times New Roman" size 10 BOLD color BLACK
    @180  ,170 print padr(dtoc(fec_cobro),8) FONT "Courier New" size 10 color BLACK
    @185  , 25 print "DETALLE :" FONT "Times New Roman" size 10 BOLD color BLACK
    @185  , 48 print padr(TRANSFORM( detalle, "@!" ),30) FONT "Courier New" size 10 color BLACK
    @195  , 25 print "NOTA :" FONT "Times New Roman" size 10 BOLD color BLACK
    @200  , 48 PRINT LINE to 200, 195 PENWIDTH 0.2 COLOR BLACK
    @210  , 48 PRINT LINE to 210, 195 PENWIDTH 0.2 COLOR BLACK
    @220  , 20 PRINT RECTANGLE to 245, 195 PENWIDTH 0.2 COLOR BLACK
    @235  ,110 PRINT RECTANGLE to 245, 195 PENWIDTH 0.2 COLOR BLACK
    @230  , 25 print "CUENTA:" FONT "Times New Roman" size 10 BOLD color BLACK
    @230  , 45 print padr(TRANSFORM(NombreCta(imputacion),"@!"),30) FONT "Courier New" size 9 color BLACK
    @235  , 25 print "CODIGO:" FONT "Times New Roman" size 10 BOLD color BLACK
    @235  , 45 print padl(TRANSFORM(imputacion, "9999999"),7) FONT "Courier New" size 10 color BLACK
    @238  ,115 print "MONTO :" FONT "Times New Roman" size 12 BOLD color BLACK
    @238  ,145 print iif(empty(haber),padl(TRANSFORM(debe, "@E 9,999,999,999.99" ),16),padl(TRANSFORM(haber, "@E 9,999,999,999.99" ),16)) FONT "Courier New" size 12 color BLACK
    @258  , 43 PRINT LINE to 258,  83 PENWIDTH 0.2 COLOR BLACK
    @258  ,130 PRINT LINE to 258, 170 PENWIDTH 0.2 COLOR BLACK
    @260  , 50 print "RESPONSABLE" FONT "Times New Roman" size 10 BOLD color BLACK
    @260  ,145 print "V°. B°." FONT "Times New Roman" size 10 BOLD color BLACK
    end printpage
    end printdoc
Return
    /*38-----------------------------------------------------------------------------*/
Function NombreCta(nCod)
    aactiva := select()
    sele cuentas
    seek str(nCod,7)
    if found()
        RetName := cuentas->nombre
    else
        RetName := " "
    endif
    select(aactiva)
Return(RetName)
    /*39-----------------------------------------------------------------------------*/
Function MigReport()
    local lbien_
    Select printer dialog to lbien_ preview
    if lbien_
        Cimprime()
    endif
Return
    /*40-----------------------------------------------------------------------------*/
Function Cimprime()
    Local RecSaldos, RecMaestro
    RecSaldos  := m_bancos->(Recno())
    RecMaestro := mae_bcos->(Recno())
    RecCuentas := cuentas->(Recno())
    SalInicial := mae_bcos->(SaldIni)

    Sele Cuentas
    set order to TAG imputacion
    go top

    Sele m_bancos
    set order to TAG imputmov
    go top
    t_cuenta := imputacion

    nDeb := 0
    nHab := 0
    nAcuDeb := 0
    nAcuHab := 0
    fl_ := 4
    n := 1
    nLin := 50

    start printdoc
    Do while ! Eof()
        start printpage
        Titulo1()
        DO WHILE nLin <= 255                        // tamaño de hoja en milimetros menos encabezado
            t_nombre:=IF( cuentas->(DBSeek( str(t_cuenta,7) )), cuentas->nombre,"Cuenta no registrada")
            @ nLin , 10 print "CÓDIGO : "       FONT "Courier New"     size 8      color BLACK
            @ nLin , 30 print str(imputacion,7) FONT "Times New Roman" SIZE 9 BOLD color BLACK
            @ nLin , 50 print t_nombre          FONT "Times New Roman" SIZE 9 BOLD color BLACK
            nLin:=nLin + 10                         // incremento en milimetros = 1 renglon
            Do while t_cuenta = imputacion
                @ nLin,10 print padr(dtoc(fec_pago),8);
                    +' '+padr(dtoc(fec_cobro),8)+' '+padr(TRANSFORM( detalle, "@!" ),30);
                    +' '+padl(TRANSFORM( cheque, "99999999" ),8);
                    +' '+padl(TRANSFORM( debe, "@E 9,999,999,999.99" ),16);
                    +' '+padl(TRANSFORM( haber, "@E 9,999,999,999.99" ),16);
                    FONT "Courier New" size 8 color BLACK

                nDeb := nDeb + debe
                nHab := nHab + haber
                nLin := nLin + 4
                Skip
                IF Eof() .OR. nLin > 255
                    EXIT
                ENDIF
            enddo
            nAcuDeb := nAcuDeb + nDeb
            nAcuHab := nAcuHab + nHab
            IF t_cuenta <> imputacion
                nLin:=nLin + 4
                //
                IF nLin > 255
                    EXIT
                ENDIF
                @ nLin ,10 print "TOTAL CUENTA "+space(45);
                    +padl(TRANSFORM( nDeb, "@E 9,999,999,999.99" ),16);
                    +' '+padl(TRANSFORM( nHab, "@E 9,999,999,999.99" ),16);
                    +' '+padl(TRANSFORM( nDeb-nHab, "@E 9,999,999,999.99" ),16);
                    FONT "Courier New" size 8 color BLACK
                nLin:=nLin + 8
                nDeb := 0
                nHab := 0
            ENDIF
            t_cuenta := imputacion
            IF Eof() .OR. nLin > 255
                EXIT
            ENDIF
        ENDDO
        IF Eof()
            @ nLin,10 print "TOTAL GENERAL"+space(45);
                +padl(TRANSFORM( nAcuDeb, "@E 9,999,999,999.99" ),16);
                +' '+padl(TRANSFORM( nAcuHab, "@E 9,999,999,999.99" ),16);
                FONT "Courier New" size 8 Bold color BLACK
        ENDIF
        end printpage
        nLin := 50
        n++
    Enddo
    end printdoc

    Sele cuentas
    Set order to tag imputacion
    Sele m_bancos
    Set order to tag banco

    m_bancos->(DbGoTo(RecSaldos))
    mae_bcos->(DbGoTo(RecMaestro))
    cuentas->(DbGoTo(RecCuentas))
Return
    /*41-----------------------------------------------------------------------------*/
Procedure Titulo1
    @ 10 , 147 print PROGRAM+VERSION+DEVELOPER  FONT "Arial" size 8 color BLACK
    @ 10 ,  10 print "Pág. "+str(n) FONT "Timen New Roman" size 9 color BLACK
    @ 16 ,  60 print "LISTADO AGRUPADO POR IMPUTACION"  FONT "Times New Roman" SIZE 12 BOLD color BLACK
    @ 20 ,  75 print "SALDO INICIAL : " +padl(TRANSFORM( mae_bcos->saldini, "@E 9,999,999,999.99" ),16);
        FONT "Times New Roman" SIZE 10 BOLD color BLACK
    @ 24 ,  10 print "BANCO : "       FONT "Times New Roman" SIZE 9 BOLD color BLACK
    @ 24 ,  30 print mae_bcos->nombre FONT "Courier New"     size 9 color BLACK
    @ 28 ,  10 print "CUENTA : "       FONT "Times New Roman" SIZE 9 BOLD color BLACK
    @ 28 ,  30 print mae_bcos->cuenta FONT "Courier New"     size 9 color BLACK
    @ 24 ,  87 print dtoc(fec_inicio)+"  al  "+dtoc(fec_final)FONT "Times New Roman" SIZE 9 BOLD color BLACK
    @ 24 , 176 print dtoc( date())  FONT "Courier New"     size 9 color BLACK
    @ 28 , 176 print time()         FONT "Courier New"     size 9 color BLACK
    @ 35 ,   8 PRINT RECTANGLE to 9*fl_+9, 194 PENWIDTH 0.2 COLOR BLACK
    @ 36 ,  11 print padr("FECHA",9)+padr("FECHA",9)+padc("DETALLE",50);
        +' '+padr("CHEQUE",14)+' '+padc("DEBE",25)+' '+padc("HABER",25)+space(9)+"SALDO";
        FONT "Times New Roman" SIZE 9 BOLD color BLACK
    @ 40,   11 print padr("PAGO ",9)+padr("COBRO",9) FONT "Times New Roman" SIZE 9 BOLD color BLACK
Return
    /*42-----------------------------------------------------------------------------*/
PROCEDURE Difuminado( wnd, nX, nY, nAng, nCol, lSep )  //Difuminado( "inicio", 640, 480, 90, 3, .F. )
    Local nYY:=nY/255, i1, nSep
    nSep:=IF(lSep,1,4)
    FOR i1 := 0 TO 255
        DO CASE
        CASE nCol = 1
            DRAWLINE(wnd, INT(nYY*i1), 0, INT(nYY*(i1+nAng)), nX, {i1,0,0}  , nSep)
        CASE nCol = 2
            DRAWLINE(wnd, INT(nYY*i1), 0, INT(nYY*(i1+nAng)), nX, {0,i1,0}  , nSep)
        CASE nCol = 3
            DRAWLINE(wnd, INT(nYY*i1), 0, INT(nYY*(i1+nAng)), nX, {0,0,i1}  , nSep)
        CASE nCol = 4
            DRAWLINE(wnd, INT(nYY*i1), 0, INT(nYY*(i1+nAng)), nX, {i1,0,i1} , nSep)
        CASE nCol = 5
            DRAWLINE(wnd, INT(nYY*i1), 0, INT(nYY*(i1+nAng)), nX, {0,i1,i1} , nSep)
        CASE nCol = 6
            DRAWLINE(wnd, INT(nYY*i1), 0, INT(nYY*(i1+nAng)), nX, {i1,i1,0} , nSep)
        CASE nCol = 7
            DRAWLINE(wnd, INT(nYY*i1), 0, INT(nYY*(i1+nAng)), nX, {i1,i1,i1}, nSep)
        ENDCASE
    NEXT
RETURN
    /*44-----------------------------------------------------------------------------*/
Procedure SelListadoL()
    IF !IsWindowDefined(ListadoL)
        Load Window ListadoL
        Center Window ListadoL
        Activate Window ListadoL
    EndIf
Return
