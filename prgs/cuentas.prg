/*
 * $Id: cuentas.prg,v 1.0 2007/10/09 21:18:16 migsoft Exp $
 * Saldos Bancarios - Sistema de Control de Saldos
 * Copyright 2007-2009 Miguel Angel Juárez A. <fugaz_cl@yahoo.es>
 * MigSoft Sistemas - www.mig2soft.com
 * <http://sourceforge.net/projects/saldobanco>
 */

/*---------------------------------CUENTAS--------------------------------------*/
#include "minigui.ch"
/*12-----------------------------------------------------------------------------*/
Function IngresaCtas
    IF !IsWindowDefined(IngCtas)
        Load Window IngCtas
        if lNewCta
            IngCtas.Text_9.setfocus
        else
            IngCtas.Text_9.ReadOnly := .T.
            IngCtas.Text_10.setfocus
        endif
        CENTER WINDOW IngCtas
        ACTIVATE WINDOW IngCtas
    Endif
Return Nil
    /*13-----------------------------------------------------------------------------*/
Function IngCtasAceptar()
    AceptarCtas()
    CtasenMovi()
    Activa2()
Return
    /*14-----------------------------------------------------------------------------*/
Procedure VeriCtas(nCod)
    if BuscarCtas(nCod) .and. lNewCta
        MsgInfo("Cuenta ya está registrada")
        IngCtas.Text_9.value := 0
        IngCtas.Text_9.setfocus
    endif
Return
    /*15-----------------------------------------------------------------------------*/
Procedure OpcionCtas()
    if lNewCta
        VarIniCtas()
    else
        ActualCtas()
    endif
Return
    /*16-----------------------------------------------------------------------------*/
Procedure AceptarCtas()
    ReempCtas()
    ingCtas.release
Return
    /*17-----------------------------------------------------------------------------*/
Procedure MaestroCtas()
    Load Window NavegaCtas
    NavegaCtas.WIDTH           := MAX( 640 -  48, GetDesktopWidth()  - 60 )
    NavegaCtas.HEIGHT          := MAX( 480 - 108, GetDesktopHeight() -147 )
    NavegaCtas.Browse_1.WIDTH  := MAX( 640 -  88, GetDesktopWidth()  -110 )
    NavegaCtas.Browse_1.HEIGHT := MAX( 480 - 232, GetDesktopHeight() -290 )
    NavegaCtas.Frame_1.WIDTH   := MAX( 640 -  72, GetDesktopWidth()  - 90 )
    NavegaCtas.Frame_1.HEIGHT  := MAX( 480 - 208, GetDesktopHeight() -260 )

    NavegaCtas.Browse_1.SetFocus
    NavegaCtas.Title :="Maestro de Cuentas"
    CENTER   WINDOW NavegaCtas
    ACTIVATE WINDOW NavegaCtas
Return
    /*18-----------------------------------------------------------------------------*/
Procedure CtasenMovi()
    IF IsWindowDefined(NavegaMovi)
        Activa2()
    Endif
    IF IsWindowDefined(NavegaCtas)
        Activa2()
    Endif
Return
    /*19-----------------------------------------------------------------------------*/
Procedure NewCtas()
    nCReg := cuentas->(recno())
    lNewCta := .T.
    IngresaCtas()
    NavegaCtas.Browse_1.Refresh
    NavegaCtas.Browse_1.value := nCReg
    NavegaCtas.Browse_1.setfocus
    lNewCta := .F.
Return
    /*20-----------------------------------------------------------------------------*/
Function BuscarCtas(Buscar)
    if Buscar >= 0
        nResul := .F.
        sele cuentas
        Go Top
        seek str(Buscar,7)
        If  Found()
            nResul := .T.
        EndIf
    EndIf
Return(nResul)
    /*21-----------------------------------------------------------------------------*/
Function ReempCtas()
    If lNewCta == .T.
        cuentas->(DbAppend())
        lNewCta := .F.
    EndIf
    If cuentas->(RLock())
        cuentas->imputacion  := ingctas.Text_9.Value
        cuentas->nombre      := ingctas.Text_10.Value
        commit
        lNewCta := .F.
        cuentas->(DBUnlock())
    endif
    IF IsWindowDefined(NavegaCtas)
        NavegaCtas.Browse_1.Refresh
    Endif
    If lNewCta == .T.
        IF IsWindowDefined(NavegaCtas)
            NavegaCtas.Browse_1.value := cuentas->( RecNo() )
        endif
    endif
    Activa2()
Return
    /*22------------------------------------------------------------------------------*/
PROCEDURE VarIniCtas()
    ingctas.Text_9.Value        := 0
    ingctas.Text_10.Value       := ""
RETURN
    /*23------------------------------------------------------------------------------*/
PROCEDURE ActualCtas()
    ingctas.Text_9.Value        := cuentas->imputacion
    ingctas.Text_10.Value       := cuentas->nombre
Return
    /*24-----------------------------------------------------------------------------*/
Function DelCtas()
    If MsgYesNo ( 'Esta Seguro','Elimina Registro')
        If  cuentas->(RLock())
            cuentas->(dbdelete())
            cuentas->(dbgotop())
            NavegaCtas.Browse_1.Refresh
            NavegaCtas.Browse_1.Value := cuentas->(RecNo())
            NavegaCtas.Browse_1.Setfocus
        else
            MsgExclamation ('Registro Ocupado Por Reintente en unos Segundos')
        EndIf
    EndIf
Return
    /*25-----------------------------------------------------------------------------*/
Function BuscandoCtas()
    IF !IsWindowDefined(BusFormCtas)
        Load     Window BusFormCtas
        BusFormCtas.Text_1.setfocus
        CENTER   WINDOW BusFormCtas
        ACTIVATE WINDOW BusFormCtas
    Endif
Return
    /*26-----------------------------------------------------------------------------*/
Function SeleCuenta
    IF !IsWindowDefined(SeleCta)
        Load Window SeleCta
        CENTER WINDOW SeleCta
        ACTIVATE WINDOW SeleCta
    Endif
Return Nil
    /*27-----------------------------------------------------------------------------*/
Function BusCtas
    Local Buscar
    nImputa := BusFormCtas.Text_1.value
    cNombre := BusFormCtas.Text_2.value
    sele cuentas
    if !Empty(nImputa)
        set order to TAG imputacion
        Buscar := str(nImputa,7)
    else
        if !Empty( cNombre )
            set order to TAG nombre
            Buscar := Upper( Alltrim( cNombre ) )
        endif
    endif
    If .Not. Empty(Buscar)
        Go Top
        seek Buscar
        If  Found()
            IF IsWindowDefined(NavegaCtas)
                NavegaCtas.Browse_1.Value := cuentas->( RecNo() )
            endif
            IF IsWindowDefined(SeleCta)
                SeleCta.Browse_1.Value := cuentas->( RecNo() )
            Endif
        Else
            MsgExclamation('No se encontraron registros')
        EndIf
    EndIf
    set order to TAG imputacion
    IF IsWindowDefined(NavegaCtas)
        NavegaCtas.Browse_1.setfocus
    endif
    If IsWindowDefined(SeleCta)
        SeleCta.Browse_1.Value := cuentas->( RecNo() )
    Endif
Return
    /*28------------------------------------------------------------------------------*/
Procedure ImprimeCtas()
    Local RecCtas
    RecCtas := Cuentas->(RecNo())
    Sele Cuentas
    Go Top
    DO REPORT						       ;
        TITLE 'PLAN DE CUENTAS|Ingresos/Egresos'	       ;
        HEADERS  {'',''} , {'CODIGO','NOMBRE'}                 ;
        FIELDS   {'cuentas->imputacion','cuentas->Nombre'}     ;
        WIDTHS   {10,40} 				       ;
        TOTALS   {.F.,.F.}			               ;
        WORKAREA cuentas				       ;
        LPP 50						       ;
        CPL 80						       ;
        LMARGIN 5					       ;
        PREVIEW
    Select Cuentas
    Cuentas->(DbGoTo(RecCtas))
Return
    /*29-----------------------------------------------------------------------------*/
Procedure MigReport5()
    Local RecSaldos, RecCuentas
    RecSaldos  := m_bancos->(Recno())
    RecCuentas := cuentas->(Recno())
    Select m_bancos
    SET ORDER TO TAG IMPUTACION
*Set relation to imputacion into cuentas
    go top
    DO REPORT ;
        TITLE 'AGRUPACION POR CUENTAS|BANCO: '+left(rtrim(cNomb),10)+' '+ ;
        dtoc(fec_inicio)+' al '+dtoc(fec_final) ;
        HEADERS {'','','','','',''},{'F.Pago','Cheque','Detalle','Debe','Haber','Saldo'};
        FIELDS {'m_bancos->Fec_Pago','m_bancos->Cheque','m_bancos->Detalle';
        ,'m_bancos->Debe','m_bancos->Haber','m_bancos->Saldo'};
        WIDTHS {8,8,13,15,15,15};
        TOTALS {.F.,.F.,.F.,.T.,.T.,.F.};
        NFORMATS { ,'9999999' , ,'@E9999,999,999.99' , '@E9999,999,999.99','@E9999,999,999.99'};
        WORKAREA m_bancos ;
        LPP 50 ;
        CPL 120 ;
        LMARGIN 2;
        PREVIEW  ;
        GROUPED BY 'IMPUTACION' ;
        HEADRGRP 'CUENTA: '
    Sele m_bancos
*Set relation to
*Set filter to
    m_bancos->(DbGoTo(RecSaldos))
    cuentas->(DbGoTo(RecCuentas))
Return
    /*47-----------------------------------------------------------------------------*/
Function CtasHead(Col_n)
    sele cuentas
    if col_n = 1
        set order to TAG imputacion
    endif
    if col_n = 2
        set order to TAG nombre
    endif
    Navegactas.Browse_1.Value := cuentas->( RecNo() )
    Navegactas.Browse_1.refresh
return nil
