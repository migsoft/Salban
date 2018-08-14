/*
 * $Id: resumen.prg,v 1.0 2007/10/09 21:18:16 migsoft Exp $
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

/*----------------------------------RESUMEN-------------------------------------*/
#include "minigui.ch"
/*56-----------------------------------------------------------------------------*/
Function LimpiarResumen()
    Close RESAL
    USE &(SaldoFolder+'\RESAL.dbf')  NEW
    dele all
    pack
    Close RESAL
    USE &(SaldoFolder+'\RESAL.dbf')  NEW SHARED
    INDEX on BANCO to &(SaldoFolder+'\resban')
    INDEX on ERA   to &(SaldoFolder+'\era')
    SET INDEX TO &(SaldoFolder+'\resban'), &(SaldoFolder+'\era')
Return Nil
    /*55-----------------------------------------------------------------------------*/
Function ResumenSaldos()
    LimpiarResumen()
    sele mae_bcos
    go top
    do while !mae_bcos->( eof() )
        nBancoFilt := banco
        cBancoName := nombre
        nSalInicio := saldini
        sele m_bancos
        set filter to m_bancos->(banco) = nBancoFilt
        go top
        nEra       := Year(fec_pago)
        sum m_bancos->(debe),m_bancos->(haber) to nDebe,nHaber
        nSaldo := ( nSalInicio + nDebe - nHaber )
        sele Resal
        lNewSal := .T.
        ReempRes(nBancoFilt,cBancoName,nSaldo,nEra)
        sele mae_bcos
        nSaldo := 0
        mae_bcos->( DBSkip() )
    enddo
    sele m_bancos
    set filter to
    go top
    sele mae_bcos
    go top
    AbrirResumen()
Return nil
    /*56-----------------------------------------------------------------------------*/
Function AbrirResumen
    sele resal
    go top
    load window Resumen
    center window Resumen
    activate window Resumen
Return
    /*57-----------------------------------------------------------------------------*/
Function ReempRes(nBk,cBkname,nSald,nYear)
    If lNewSal == .T.
        resal->(DbAppend())
        lNewSal := .F.
    EndIf
    If resal->(RLock())
        resal->banco   := nBk
        resal->Nombre  := cBkname
        resal->era     := nYear
        resal->Saldo   := nSald
        commit
        lNewSal := .F.
        resal->(DBUnlock())
    endif
Return Nil
    /*42------------------------------------------------------------------------------*/
Procedure PrintRes()
    Local RecRes
    RecSal := resal->(RecNo())
    Select resal
    Go Top
    DO REPORT						                  ;
        TITLE 'RESUMEN DE SALDOS'	  				          ;
        HEADERS {'','','',''},{'BANCO','NOMBRE','PERIODO','SALDO'}             ;
        FIELDS {'resal->banco','resal->nombre','resal->era','resal->Saldo'}    ;
        WIDTHS   {10,20,20,20} 					          ;
        TOTALS   {.F.,.F.,.F.,.F.}					          ;
        NFORMATS { '9999','','9999','@E9999,999,999.99' }                      ;
        WORKAREA resal						          ;
        LPP 50								  ;
        CPL 80								  ;
        LMARGIN 3							          ;
        PREVIEW
    Select resal
    GoTo RecSal
    Return