/*
 * $Id: bancos.prg,v 1.0 2007/10/09 21:18:16 migsoft Exp $
 *
 * Saldos Bancarios - Sistema de Control de Saldos
 *
 * Copyright 2007-2009 Miguel Angel Juárez A. <fugaz_cl@yahoo.es>
 *
 * MigSoft Sistemas - www.mig2soft.com
 *
 * <http://sourceforge.net/projects/saldobanco>
 *
 */

/*----------------------------------BANCOS--------------------------------------*/
#include "minigui.ch"
/*30-----------------------------------------------------------------------------*/
Procedure MaestroBcos()
    IF !IsWindowDefined(NavegaBcos)
        Load Window NavegaBcos
        NavegaBcos.WIDTH           := MAX( 640 -  48, GetDesktopWidth()  - 60 )
        NavegaBcos.HEIGHT          := MAX( 480 - 108, GetDesktopHeight() -147 )
        NavegaBcos.Browse_1.WIDTH  := MAX( 640 -  88, GetDesktopWidth()  -110 )
        NavegaBcos.Browse_1.HEIGHT := MAX( 480 - 232, GetDesktopHeight() -290 )
        NavegaBcos.Frame_1.WIDTH   := MAX( 640 -  72, GetDesktopWidth()  - 90 )
        NavegaBcos.Frame_1.HEIGHT  := MAX( 480 - 208, GetDesktopHeight() -260 )

        NavegaBcos.Browse_1.SetFocus
        NavegaBcos.Title :="Maestro de Bancos"
        CENTER   WINDOW NavegaBcos
        ACTIVATE WINDOW NavegaBcos
    Endif
Return
    /*31-----------------------------------------------------------------------------*/
Function IngresaBcos
    IF !IsWindowDefined(IngBcos)
        Load Window IngBcos
        if lNewBco
            IngBcos.Text_1.setfocus
        else
            IngBcos.Text_1.ReadOnly := .T.
            IngBcos.Text_2.setfocus
        endif
        CENTER WINDOW IngBcos
        ACTIVATE WINDOW IngBcos
    Endif
Return Nil

Function CapturaBmp()
    cImage := Getfile ( {{'BMP Files','*.bmp'}}, 'Selecciona un Logo para el Banco', CurDir() )
    if empty(cImage)
        IngBcos.Image_1.Picture := "BANCOINI"
    else
        IngBcos.Text_5.value := cImage
    endif
Return

    /*32-----------------------------------------------------------------------------*/
Procedure OpcionBcos()
    if lNewBco
        VarIniBcos()
    else
        ActualBcos()
    endif
Return
    /*33-----------------------------------------------------------------------------*/
Procedure AceptarBcos()
    ReempBcos()
    ingbcos.release
Return
    /*34-----------------------------------------------------------------------------*/
Procedure NewBcos()
    nBReg := mae_bcos->(recno())
    lNewBco := .T.
    IngresaBcos()
    NavegaBcos.Browse_1.Refresh
    NavegaBcos.Browse_1.value := nBReg
    NavegaBcos.Browse_1.setfocus
    lNewBco := .F.
Return
    /*35-----------------------------------------------------------------------------*/
Static Function BuscarBcos(Buscar)
    if Buscar >= 0
        nResul := .F.
        sele mae_bcos
        Go Top
        seek Buscar
        If  Found()
            nResul := .T.
        EndIf
    EndIf
Return(nResul)
    /*36-----------------------------------------------------------------------------*/
Function IngBcosAceptar()
    AceptarBcos()
    Activa1()
Return
    /*37-----------------------------------------------------------------------------*/
Procedure VeriBcos(nCod)
    if BuscarBcos(nCod) .and. lNewBco
        MsgInfo("Banco ya está registrado")
        IngBcos.Text_1.value := 0
        IngBcos.Text_1.setfocus
    endif
Return
    /*38-----------------------------------------------------------------------------*/
Function SeleBanco
    IF !IsWindowDefined(SeleBco)
        Load Window SeleBco
        CENTER WINDOW SeleBco
        ACTIVATE WINDOW SeleBco
    Endif
Return Nil
    /*39n-----------------------------------------------------------------------------*/
Function EditaBcos()
    Load Window IngBcos
    CENTER WINDOW IngBcos
    ACTIVATE WINDOW IngBcos
Return
    /*40-----------------------------------------------------------------------------*/
Procedure ReempBcos()
    If lNewBco == .T.
        mae_bcos->(DbAppend())
        lNewBco := .F.
    EndIf
    If mae_bcos->(RLock())
        mae_bcos->banco   := ingbcos.Text_1.Value
        mae_bcos->Nombre  := ingbcos.Text_2.Value
        mae_bcos->Cuenta  := ingbcos.Text_3.Value
        mae_bcos->logobco := ingbcos.Text_5.Value
        If File( alltrim(ingbcos.Text_5.Value) )
            mae_bcos->LogoBco := IngBcos.Text_5.Value
        Else
*      mae_bcos->LogoBco := "0.bmp"
            mae_bcos->LogoBco := "BANCOINI"
        Endif
        mae_bcos->Saldini := ingbcos.Text_4.Value
        commit
        lNewBco := .F.
        NavegaBcos.Browse_1.Refresh
        mae_bcos->(DBUnlock())
    Endif
    If lNewBco == .T.
        NavegaBcos.Browse_1.value := mae_bcos->( RecNo() )
        NavegaBcos.Browse_1.Refresh
    endif
    Activa1()
Return
    /*38------------------------------------------------------------------------------*/
PROCEDURE VarIniBcos()
    ingbcos.Text_1.Value := 0
    ingbcos.Text_2.Value := ''
    ingbcos.Text_3.Value := ''
    ingbcos.Text_4.Value := 0.00
*   ingbcos.Text_5.Value := '0.bmp'
    ingbcos.Text_5.Value := 'BANCOINI'
RETURN
    /*39------------------------------------------------------------------------------*/
PROCEDURE ActualBcos()
    ingbcos.Text_1.Value	:= mae_bcos->Banco
    ingbcos.Text_2.Value	:= mae_bcos->Nombre
    ingbcos.Text_3.Value	:= mae_bcos->Cuenta
    ingbcos.Text_4.Value	:= mae_bcos->Saldini
    ingbcos.Text_5.Value	:= mae_bcos->LogoBco
    If File( alltrim(mae_bcos->LogoBco) )
        IngBcos.Image_1.Picture := alltrim(mae_bcos->LogoBco)
    Else
*      IngBcos.Image_1.Picture := "0.bmp"
        IngBcos.Image_1.Picture := "BANCOINI"
    End
Return
    /*34-----------------------------------------------------------------------------*/
Function DelBcos
    If MsgYesNo ( 'Esta Seguro','Elimina Registro')
        If  mae_bcos->(RLock())
            mae_bcos->(dbdelete())
            mae_bcos->(dbgotop())
            NavegaBcos.Browse_1.Refresh
            NavegaBcos.Browse_1.Value := mae_bcos->(RecNo())
            NavegaBcos.Browse_1.Setfocus
        else
            MsgExclamation ('Registro Ocupado Reintente en unos Segundos')
        EndIf
    EndIf
Return
    /*35-----------------------------------------------------------------------------*/
Function BuscandoBcos()
    IF !IsWindowDefined(BusFormBcos)
        Load     Window BusFormBcos
        BusFormBcos.Text_1.setfocus
        CENTER   WINDOW BusFormBcos
        ACTIVATE WINDOW BusFormBcos
    Endif
Return
    /*36-----------------------------------------------------------------------------*/
Function BusBcos()
    Local Buscar
    nBanco  := BusFormBcos.Text_1.value
    cNombre := BusFormBcos.Text_3.value
    cCuenta := BusFormBcos.Text_2.value
    sele mae_bcos
    if !Empty(nBanco)
        set order to TAG banco
        Buscar := nBanco
    else
        if !Empty( cNombre )
            set order to TAG NOMBRE
            Buscar := Upper( Alltrim( cNombre ) )
        else
            if !Empty( cCuenta )
                set order to TAG CUENTA
                Buscar := Upper( Alltrim( cCuenta ) )
            endif
        endif
    endif
    If .Not. Empty(Buscar)
        Go Top
        seek Buscar
        If  Found()
            NavegaBcos.Browse_1.Value := mae_bcos->( RecNo() )
        Else
            MsgExclamation('No se encontraron registros')
        EndIf
    EndIf
    set order to TAG BANCO
    NavegaBcos.Browse_1.setfocus
Return
    /*42------------------------------------------------------------------------------*/
Procedure ImprimeBcos()
    Local RecBcos
    RecBcos := mae_bcos->(RecNo())
    Select mae_bcos
    Go Top
    DO REPORT						                  ;
        TITLE 'LISTADO DE BANCOS'	  				  ;
        HEADERS {'','','',''},{'BANCO','NOMBRE','CUENTA','SALDO INICIAL'} ;
        FIELDS   {'mae_bcos->banco','mae_bcos->Nombre','mae_bcos->Cuenta',;
        'mae_bcos->Saldini'};
        WIDTHS   {10,20,20,20} 					          ;
        TOTALS   {.F.,.F.,.F.,.F.}					  ;
        NFORMATS { '9999','','','@E9999,999,999.99' }                     ;
        WORKAREA mae_bcos						  ;
        LPP 50								  ;
        CPL 80								  ;
        LMARGIN 3							  ;
        PREVIEW
    Select mae_bcos
    Mae_bcos->(DbGoTo(RecBcos))
Return

Function BcoHead(Col_n)
    sele mae_bcos
    if col_n = 1
        set order to TAG banco
    endif
    if col_n = 2
        set order to TAG nombre
    endif
    if col_n = 3
        set order to TAG cuenta
    endif
    if col_n = 4
    endif
    IF IsWindowDefined(NavegaBcos)
        Navegabcos.Browse_1.Value := mae_bcos->( RecNo() )
        Navegabcos.Browse_1.refresh
    Endif
    IF IsWindowDefined(SeleBco)
        Selebco.Browse_1.Value := mae_bcos->( RecNo() )
        Selebco.Browse_1.refresh
    Endif
return nil
