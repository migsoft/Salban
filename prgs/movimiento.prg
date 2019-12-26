/*
 * $Id: movimiento.prg,v 1.0 2007/10/09 21:18:16 migsoft Exp $
 * Saldos Bancarios - Sistema de Control de Saldos
 * Copyright 2007-2009 Miguel Angel Juárez A. <fugaz_cl@yahoo.es>
 * MigSoft Sistemas - www.mig2soft.com
 * <http://sourceforge.net/projects/saldobanco>
 *
 */

/*----------------------------------MOVIMIENTO-----------------------------------*/
#include "minigui.ch"
#include "miniprint.ch"
/*24-----------------------------------------------------------------------------*/
Function IngresaMovi
    IF !IsWindowDefined(IngMovi)
        Load Window IngMovi
        If !Nuevo == .T.
            DesactivaVarios()
        else
            IngMovi.imprimir.enabled := .F.
        Endif
        IngMovi.Text_4.setfocus
        CENTER WINDOW IngMovi
        ACTIVATE WINDOW IngMovi
    Endif
Return Nil
    /*9-----------------------------------------------------------------------------*/
Procedure OpcionMovi()
    if Nuevo
        VarIniMovi()
    else
        ActualMovi()
    endif
Return
    /*9-----------------------------------------------------------------------------*/
Procedure DesactivaVarios()
    IngMovi.Varios.enabled := .F.
Return
    /*9-----------------------------------------------------------------------------*/
Procedure DesactivaAceptar()
    IngMovi.Aceptar.enabled := .F.
Return
    /*9-----------------------------------------------------------------------------*/
Procedure AceptarMovi()
    ReempMovi()
    ingMovi.release
Return
    /*9-----------------------------------------------------------------------------*/
Procedure VariosMovi()
    Nuevo := .T.
    ReempMovi()
    VarIniMovi()
Return
    /*9-----------------------------------------------------------------------------*/
Procedure VeriMovi(nCod)
    if !BuscarCtas(nCod)
        lNewCta :=.T.
        IngresaCtas()
    endif
Return
    /*9-----------------------------------------------------------------------------*/
Procedure VeriMoviGraph(nCod)
    nValSel := ingmovi.Text_8.value
    SeleCuenta()
    ingmovi.text_8.value:= nValSel
Return
    /*22-----------------------------------------------------------------------------*/
Function FiltraTables(nReg)
    if !empty(nReg)
        if !nReg = 0
            sele mae_bcos
            go nReg
            TraBco  := Banco
            cNomb   := Nombre
            nSalIni := Saldini
            sele m_bancos
            dbSetFilter( { || banco==trabco })
            go top
            SaldoBanco()
        Endif
    endif
Return Nil
    /*23-----------------------------------------------------------------------------*/
Procedure Movi(nOp)
    lNext  := .F.
    nRegb  := mae_bcos->(Reccount())
    if nOP = 1
        if !empty(nRegb) .and. ! mae_bcos->( eof() )
            SeleBanco()
            if lNext
                MaestroMovi()
                lNext := .F.
            endif
        else
            MsgInfo("No Hay Bancos Creados")
        endif
    Endif
    if nOP = 2
        if !empty(nRegb) .and. ! mae_bcos->( eof() )
            SeleBanco()
            if lNext
                FiltraFechas()
                FiltrodeFechas()
                if !empty(fec_inicio) .and. !empty(fec_Final) .and. lNext
                    MPrintlib()
                    set filter to
                endif
                lNext := .F.
            endif
        else
            MsgInfo("No Hay Bancos Creados")
        endif
    Endif
    if nOP = 3
        if !empty(nRegb) .and. ! mae_bcos->( eof() )
            SeleBanco()
            if lNext
                FiltraFechas()
                FiltrodeFechas()
                if !empty(fec_inicio) .and. !empty(fec_Final) .and. lNext
                    MigReport()
                    set filter to
                endif
                lNext := .F.
            endif
        else
            MsgInfo("No Hay Bancos Creados")
        endif
    Endif
    if nOP = 4
        if !empty(nRegb) .and. ! mae_bcos->( eof() )
            SeleBanco()
            if !empty(trabco)
                if lNext
                    FiltraFechas()
                    FiltraCheques()
                    if !empty(fec_inicio) .and. !empty(fec_Final).and. lNext
                        MaestroMovi()
                        set filter to
                    endif
                    lNext := .F.
                endif
            endif
        else
            MsgInfo("No Hay Bancos Creados")
        endif
    Endif
    if nOP = 5
        if !empty(nRegb) .and. ! mae_bcos->( eof() )
            SeleBanco()
            set order to TAG dfec_pago
            if lNext
                FiltraFechas()
                FiltrodeFechas()
                if !empty(fec_inicio) .and. !empty(fec_Final) .and. lNext
                    MPrintlib()
                    set filter to
                endif
                lNext := .F.
            endif
        else
            MsgInfo("No Hay Bancos Creados")
        endif
    Endif
Return
    /*25-----------------------------------------------------------------------------*/
Function esCheque(nCheque)
    if empty(nCheque)
        ingmovi.Text_6.enabled := .T.
    else
        ingmovi.Text_6.enabled := .F.
        ingmovi.Text_6.value   :=  0
    endif
Return
    /*26-----------------------------------------------------------------------------*/
Function esDebe(nDebe)
    if empty(nDebe)
        ingmovi.Text_7.enabled := .T.
    else
        ingmovi.Text_7.enabled := .F.
        ingmovi.Text_7.value   :=  0
    endif
Return
    /*27-----------------------------------------------------------------------------*/
Function esHaber(nHaber)
    if empty(nHaber)
        ingmovi.Text_6.enabled := .T.
    else
        ingmovi.Text_6.enabled := .F.
        ingmovi.Text_6.value   :=  0
    endif
Return
    /*28-----------------------------------------------------------------------------*/
Procedure SaldoBanco
    tArea := alias()
    tReg  := Recno()
    nSaldIni := RetSalIni()
    sele m_bancos
    go top
    do while ! eof()
        If m_bancos->(RLock())
            m_bancos->Saldo := nSaldIni + debe - haber
            m_bancos->(DBUnlock())
        endif
        nSaldIni :=  nSaldIni + debe  - haber
        skip
    enddo
    sele &tArea
    go tReg
Return
    /*64-----------------------------------------------------------------------------*/
Function RetSalIni()
    tArea := alias()
    tReg  := Recno()
    sele mae_bcos
    set order to TAG BANCO
    seek TraBco
    if found()
        nSaldoIni := mae_bcos->saldini
    else
        nSaldoIni := 0
    endif
    sele &tArea
    go tReg
Return(nSaldoIni)
    /*64-----------------------------------------------------------------------------*/
Function SaldoHasta()
    aactiva  := select()
    RetSaldo := RetSalIni()
    sele m_bancos
    do while !eof()
        if fec_pago < fec_inicio
            RetSaldo := RetSaldo + debe - haber
            skip
        endif
    enddo
    select(aactiva)
Return(RetSaldo)
    /*29-----------------------------------------------------------------------------*/
Function MaestroMovi()
    Load Window NavegaMovi
    NavegaMovi.WIDTH           := MAX( 640 -  48, GetDesktopWidth()  - 60 )
    NavegaMovi.HEIGHT          := MAX( 480 - 108, GetDesktopHeight() -147 )
    NavegaMovi.Browse_1.WIDTH  := MAX( 640 -  88, GetDesktopWidth()  -110 )
    NavegaMovi.Browse_1.HEIGHT := MAX( 480 - 232, GetDesktopHeight() -290 )
    NavegaMovi.Frame_1.WIDTH   := MAX( 640 -  72, GetDesktopWidth()  - 90 )
    NavegaMovi.Frame_1.HEIGHT  := MAX( 480 - 208, GetDesktopHeight() -260 )

    NavegaMovi.Browse_1.SetFocus
    if !eof()
        NavegaMovi.Title :="BANCO "+cNomb+space(80);
            +"SALDO INICIAL : "+TRANSFORM(nSalIni,'@E999,999,999.99')
    endif
    do events
    CENTER WINDOW NavegaMovi
    ACTIVATE WINDOW NavegaMovi
Return
    /*30-----------------------------------------------------------------------------*/
Procedure NewMovi()
    nPuntReg := m_bancos->(recno())
    Nuevo := .T.
    IngresaMovi()
    Saldobanco()
    NavegaMovi.Browse_1.Refresh
    NavegaMovi.Browse_1.value := nPuntReg
    NavegaMovi.Browse_1.setfocus
    Nuevo := .F.
Return
    /*31-----------------------------------------------------------------------------*/
Procedure ReempMovi()
    nBanco := TraBco
    If Nuevo == .T.
        m_bancos->(DbAppend())
        Nuevo := .F.
    EndIf
    If m_bancos->(RLock())
        m_bancos->banco      := nBanco
        m_bancos->cheque     := ingmovi.Text_4.Value
        m_bancos->detalle    := ingmovi.Text_5.Value
        m_bancos->imputacion := ingmovi.Text_8.Value
        m_bancos->debe       := ingmovi.Text_6.Value
        m_bancos->haber      := ingmovi.Text_7.Value
        m_bancos->fec_pago   := ingmovi.datepicker_1.Value
        m_bancos->fec_cobro  := ingmovi.datepicker_2.Value
        commit
        Nuevo := .F.
        m_bancos->(DBUnlock())
    endif
    NavegaMovi.Browse_1.value := Recno()
    NavegaMovi.Browse_1.Refresh
    Activa3()
    m_bancos->(DbGotop())
    SaldoBanco()
Return
    /*32------------------------------------------------------------------------------*/
PROCEDURE VarIniMovi()
    ingmovi.Text_6.Value       := 0.00
    ingmovi.Text_7.Value       := 0.00
    ingmovi.Text_8.Value       := 0
    ingmovi.Text_4.Value       := 0
    ingmovi.Text_5.Value       := ''
    ingmovi.datepicker_1.Value := ctod(' / / ')
    ingmovi.datepicker_2.Value := ctod(' / / ')
RETURN
    /*33------------------------------------------------------------------------------*/
PROCEDURE ActualMovi()
    ingmovi.Text_6.Value       := m_bancos->debe
    ingmovi.Text_7.Value       := m_bancos->haber
    ingmovi.Text_8.Value       := m_bancos->imputacion
    ingmovi.Text_4.Value       := m_bancos->cheque
    ingmovi.Text_5.Value       := m_bancos->detalle
    ingmovi.datepicker_1.Value := m_bancos->fec_pago
    ingmovi.datepicker_2.Value := m_bancos->fec_cobro
Return
    /*34-----------------------------------------------------------------------------*/
Function DelMovi
    If MsgYesNo ( 'Esta Seguro','Elimina Registro')
        If  m_bancos->(RLock())
            m_bancos->(dbdelete())
            m_bancos->(dbgotop())
            NavegaMovi.Browse_1.Refresh
            NavegaMovi.Browse_1.Value := m_bancos->(RecNo())
            NavegaMovi.Browse_1.Setfocus
            SaldoBanco()
        else
            MsgExclamation ('Registro Ocupado Reintente en unos Segundos')
        EndIf
    EndIf
Return
    /*35-----------------------------------------------------------------------------*/
Function BuscandoMovi()
    Load Window BusFormMovi
    CENTER WINDOW BusFormMovi
    ACTIVATE WINDOW BusFormMovi
Return
    /*36-----------------------------------------------------------------------------*/
Function BusMovi
    Local Buscar
    nCheque  := BusFormMovi.Text_1.value
    fFechap  := BusFormMovi.DatePicker_1.value
    cDetalle := BusFormMovi.Text_2.value
    sele m_bancos
    if !Empty(nCheque)
        set order to TAG CHEQUE
        Buscar := nCheque
    else
        if !Empty(fFechap)
            set order to TAG FEC_PAGO
            Buscar := fFechap
        endif
    endif
    if !Empty(cDetalle)
        set order to TAG DETALLE
        Buscar := Upper ( AllTrim ( cDetalle ) )
    endif
    If .Not. Empty(Buscar)
        Go Top
        seek Buscar
        If  Found()
            NavegaMovi.Browse_1.Value := (RecNo())
        Else
            MsgExclamation('No se encontraron registros')
        EndIf
    EndIf
    set order to TAG BANCO
    NavegaMovi.Browse_1.setfocus
Return
    /*40------------------------------------------------------------------------------*/
Function BloqueaReg()
    Local RetVal
    If mae_bcos->(RLock())
        RetVal := .t.
    Else
        MsgExclamation ('Registro Ocupado Reintente Mas Tarde')
        RetVal := .f.
    EndIf
Return RetVal
    /*41-----------------------------------------------------------------------------*/
Procedure Imprimir()
    Local RecSaldos, RecMaestro
    RecSaldos  := m_bancos->(Recno())
    RecMaestro := mae_bcos->(Recno())
    Select m_bancos
    Set relation to banco into mae_bcos
    go top
    SalInicial := iif((fec_pago < fec_inicio), SaldoHasta(), RetSalIni())
    DO REPORT ;
        TITLE 'LIBRO BANCO: '+left(alltrim(mae_bcos->nombre),10)+' '   ;
        +dtoc(fec_inicio)+' al '+dtoc(fec_final)+'|'+'SALDO INICIAL : ';
        +TRANSFORM(SalInicial,'@E999,999,999.99')                      ;
        HEADERS {'','','','','',''},{'F.Pago','Cheque','Detalle','Debe','Haber','Saldo'};
        FIELDS {'m_bancos->Fec_Pago','m_bancos->Cheque','m_bancos->Detalle';
        ,'m_bancos->Debe','m_bancos->Haber','m_bancos->Saldo'};
        WIDTHS {8,8,13,15,15,15};
        TOTALS {.F.,.F.,.F.,.T.,.T.,.F.};
        NFORMATS { ,'9999999' , ,'@E999,999,999.99' , '@E999,999,999.99','@E9999,999,999.99'};
        WORKAREA m_bancos ;
        LPP 50 ;
        CPL 110 ;
        LMARGIN 2;
        PREVIEW
    Select m_bancos
    Set relation to
    Set filter to
    m_bancos->(DbGoTo(RecSaldos))
    mae_bcos->(DbGoTo(RecMaestro))
Return
    /*49-----------------------------------------------------------------------------*/
Function MigAyuda
    cFilHelp := CurDir()+"SalBan.txt"
    cArquivo := Iif(File(cFilHelp),MemoRead(cFilHelp),"No exite Archivo de Ayuda")
    Load Window Form_3
    Center Window Form_3
    Activate Window Form_3
Return
    /*291-----------------------------------------------------------------------------*/
Function Activa1()
    mae_bcos->( dbGotop())
    IF IsWindowDefined(NavegaBcos)
        if !empty( mae_bcos->( reccount()) ) .and. ! mae_bcos->( eof() )
            SetProperty("NavegaBcos","Modificar","enabled",.T.)
            SetProperty("NavegaBcos","Eliminar","enabled",.T.)
            SetProperty("NavegaBcos","Buscar","enabled",.T.)
            SetProperty("NavegaBcos","Imprimir","enabled",.T.)
        else
            SetProperty("NavegaBcos","Modificar","enabled",.F.)
            SetProperty("NavegaBcos","Eliminar","enabled",.F.)
            SetProperty("NavegaBcos","Buscar","enabled",.F.)
            SetProperty("NavegaBcos","Imprimir","enabled",.F.)
        endif
    endif
Return
    /*291-----------------------------------------------------------------------------*/
Function Activa2()
    cuentas->( dbGotop())
    IF IsWindowDefined(NavegaCtas)
        if !empty( cuentas->( reccount()) ) .and. ! cuentas->( eof() )
            SetProperty("NavegaCtas","Modificar","enabled",.T.)
            SetProperty("NavegaCtas","Eliminar","enabled" ,.T.)
            SetProperty("NavegaCtas","Buscar","enabled"   ,.T.)
            SetProperty("NavegaCtas","Imprimir","enabled" ,.T.)
        else
            SetProperty("NavegaCtas","Modificar","enabled" ,.F.)
            SetProperty("NavegaCtas","Eliminar","enabled"  ,.F.)
            SetProperty("NavegaCtas","Buscar","enabled"    ,.F.)
            SetProperty("NavegaCtas","Imprimir","enabled"  ,.F.)
        endif
    endif
Return
    /*291-----------------------------------------------------------------------------*/
Function Activa3()
    m_bancos->( dbGotop())
    IF IsWindowDefined(NavegaMovi)
        if !empty( m_bancos->( reccount()) ) .and. ! m_bancos->( eof() )
            SetProperty("NavegaMovi","Modificar","enabled",.T.)
            SetProperty("NavegaMovi","Eliminar","enabled",.T.)
            SetProperty("NavegaMovi","Buscar","enabled",.T.)
            SetProperty("NavegaMovi","Imprimir","enabled",.T.)
        else
            SetProperty("NavegaMovi","Modificar","enabled" ,.F.)
            SetProperty("NavegaMovi","Eliminar","enabled"  ,.F.)
            SetProperty("NavegaMovi","Buscar","enabled"    ,.F.)
            SetProperty("NavegaMovi","Imprimir","enabled"  ,.F.)
        endif
    endif
Return
    /*64-----------------------------------------------------------------------------*/
Function MPrintLib()
    local lbien_
    Select printer dialog to lbien_ preview
    if lbien_
        Mimprime()
    endif
Return
    /*65-----------------------------------------------------------------------------*/
Function Mimprime()
    Local RecSaldos, RecMaestro
    RecSaldos  := m_bancos->(Recno())
    RecMaestro := mae_bcos->(Recno())
    SalInicial := mae_bcos->(SaldIni)
    Select m_bancos
    nFinal := Reccount()
    paginas := int(nFinal /50)
    Set relation to banco into mae_bcos
    go top
    nDeb := 0
    nHab := 0
    nAcuDeb := 0
    nAcuHab := 0
    fl_ := 4
    n := 1
    nLin := 0
    start printdoc
    Do while !  m_bancos->( Eof() )
        start printpage
        Titulo()
        Do while nLin < 50 .and. ! m_bancos->( Eof() )
            @ (12+nLin)*fl_,10 print padr(dtoc(fec_pago),8);
                +' '+padr(dtoc(fec_cobro),8)+' '+padr(TRANSFORM( detalle, "@!" ),30);
                +' '+padl(TRANSFORM( cheque, "99999999" ),8);
                +' '+padl(TRANSFORM( debe, "@E 9,999,999,999.99" ),16);
                +' '+padl(TRANSFORM( haber, "@E 9,999,999,999.99" ),16);
                +' '+padl(TRANSFORM( saldo, "@E 9,999,999,999.99" ),16);
                FONT "Courier New" size 8 color BLACK
            nDeb := nDeb + debe
            nHab := nHab + haber
            Skip
            nLin := nLin + 1
        enddo
        @ (12+nLin+1)*fl_,10 print "SUB TOTAL PAGINA"+space(42);
            +padl(TRANSFORM( nDeb, "@E 9,999,999,999.99" ),16);
            +' '+padl(TRANSFORM( nHab, "@E 9,999,999,999.99" ),16);
            FONT "Courier New" size 8 color BLACK
        nAcuDeb := nAcuDeb + nDeb
        nAcuHab := nAcuHab + nHab
        nDeb := 0
        nHab := 0
        if m_bancos->( Eof() )
            @ (12+nLin+3)*fl_,10 print "TOTAL GENERAL"+space(45);
                +padl(TRANSFORM( nAcuDeb, "@E 9,999,999,999.99" ),16);
                +' '+padl(TRANSFORM( nAcuHab, "@E 9,999,999,999.99" ),16);
                FONT "Courier New" size 8 Bold color BLACK
        endif
        end printpage
        nLin := 0
        n    := n + 1
    Enddo
    end printdoc
    Select m_bancos
    Set relation to
    m_bancos->(DbGoTo(RecSaldos))
    mae_bcos->(DbGoTo(RecMaestro))
Return
    /*66-----------------------------------------------------------------------------*/
Procedure Titulo
    @ 10 , 147 print PROGRAM+VERSION+DEVELOPER FONT "Arial" size 8 color BLACK
    @ 10 , 10 print "Pág. "+str(n) FONT "Timen New Roman" size 9 color BLACK
    @ 16 , 85 print "LIBRO BANCOS"  FONT "Times New Roman" SIZE 12 BOLD color BLACK
    @ 20 , 75 print "SALDO INICIAL : ";
        +padl(TRANSFORM( mae_bcos->saldini, "@E 9,999,999,999.99" ),16);
        FONT "Times New Roman" SIZE 10 BOLD color BLACK
    @ 24 , 10 print "BANCO : "       FONT "Times New Roman" SIZE 9 BOLD color BLACK
    @ 24 , 30 print mae_bcos->nombre FONT "Courier New"     size 9 color BLACK
    @ 24 , 87 print dtoc(fec_inicio)+"  al  "+dtoc(fec_final)FONT "Times New Roman" SIZE 9 BOLD color BLACK
    @ 28, 10 print "CUENTA : "       FONT "Times New Roman" SIZE 9 BOLD color BLACK
    @ 28, 30 print mae_bcos->cuenta FONT "Courier New"     size 9 color BLACK
    @ 24, 176 print dtoc( date())  FONT "Courier New"     size 9 color BLACK
    @ 28, 176 print time()         FONT "Courier New"     size 9 color BLACK
    @ 35, 8 PRINT RECTANGLE to 9*fl_+9, 194 PENWIDTH 0.2 COLOR BLACK
    @ 36,11 print padr("FECHA",9)+padr("FECHA",9)+padc("DETALLE",50);
        +' '+padr("CHEQUE",14)+' '+padc("DEBE",25)+' '+padc("HABER",25)+space(9)+"SALDO";
        FONT "Times New Roman" SIZE 9 BOLD color BLACK
    @ 40,11 print padr("PAGO ",9)+padr("COBRO",9);
        FONT "Times New Roman" SIZE 9 BOLD color BLACK
Return
    /*47-----------------------------------------------------------------------------*/
Function MoviHead(Col_n)
    sele m_bancos
    if col_n = 1
        set order to TAG fec_pago
    endif
    if col_n = 2

    endif
    if col_n = 3
        set order to TAG cheque
    endif
    if col_n = 4
        set order to TAG detalle
    endif
    NavegaMovi.Browse_1.Value := m_bancos->( RecNo() )
    NavegaMovi.Browse_1.refresh
return nil