/*
 * $Id: grafico.prg,v 1.0 2007/10/09 21:18:16 migsoft Exp $
 * Saldos Bancarios - Sistema de Control de Saldos
 * Copyright 2007-2009 Miguel Angel Juárez A. <fugaz_cl@yahoo.es>
 * MigSoft Sistemas - www.mig2soft.com
 * <http://sourceforge.net/projects/saldobanco>
 */
#include "rev.ch"

/*-----------------------------------GRAFICO-------------------------------------*/
#include "minigui.ch"
/*17-----------------------------------------------------------------------------*/
Function VentanaPie()

    Public aColor, aSeries, aSerie1, aSeriesNames, aColores
    Public aYvalues := { "Miles de Pesos" }

    IF !IsWindowDefined(Imagen)
        Load Window Imagen
        center window Imagen
        Activate Window Imagen
    Endif
Return
    /*18-----------------------------------------------------------------------------*/
Function MigSeries()
    Local aClr := {RED, YELLOW, AZUL, CAFE, VERDE, BLUE, GREEN, ORANGE, ;
        FUCHSIA, BROWN, GRAY, PINK, PURPLE, BLACK, WHITE}

    n := 1
    sele Resal
    if reccount() = 0
        ResumenSaldos()
    endif

    nCantReg     := IF( Reccount()>15, 15, Reccount() )
    aSeries      := array(nCantReg,1)
    aSerie1      := array(nCantReg,1)
    aSeriesNames := array(nCantReg)
    aColores     := array(nCantReg)

    dbgotop()
    do while ! resal->(eof()) .and. n <= 15
        nSaldo          := If( resal->saldo < 0, 0 , resal->saldo )
        cNombre         := resal->Nombre
        aSeries[n,1]    := nSaldo / 1000
        aSerie1[n]      := nSaldo / 1000
        aSeriesNames[n] := left(cNombre,1)+Right(lower(cNombre),Len(cNombre)-1)
        aColores[n]     := aClr[n]
        skip
        n++
    enddo

return Nil
    /*19-----------------------------------------------------------------------------*/
Function MuestraPie(nTipo)
    do Case
    Case nTipo = 1
        IF !IsWindowDefined(Ecram)
            Load Window Ecram
            Ecram.Title := PROGRAM+VERSION+DEVELOPER
            Torta(aSerie1,aSeriesNames,aColores)
            center window Ecram
            Activate Window Ecram
        Endif
    Case nTipo = 2
        IF !IsWindowDefined(Ecram)
            Load Window Ecram
            Ecram.Title := PROGRAM+VERSION+DEVELOPER
            Barras(aSeries,aSeriesNames,aColores)
            center window Ecram
            Activate Window Ecram
        Endif
    Case nTipo = 3
        IF !IsWindowDefined(Ecram)
            Load Window Ecram
            Ecram.Title := PROGRAM+VERSION+DEVELOPER
            Lineas(aSeries,aSeriesNames,aColores)
            center window Ecram
            Activate Window Ecram
        Endif
    Case nTipo = 4
        IF !IsWindowDefined(Ecram)
            Load Window Ecram
            Ecram.Title := PROGRAM+VERSION+DEVELOPER
            Puntos(aSeries,aSeriesNames,aColores)
            center window Ecram
            Activate Window Ecram
        Endif
    EndCase
Return(Nil)
    /*20-----------------------------------------------------------------------------*/
Procedure InitGraf(nTipo)
    Do Case
    Case nTipo = 1
        Torta(aSerie1,aSeriesNames,aColores)
    Case nTipo = 2
        Barras(aSeries,aSeriesNames,aColores)
    Case nTipo = 3
        Lineas(aSeries,aSeriesNames,aColores)
    Case nTipo = 4
        Puntos(aSeries,aSeriesNames,aColores)
    EndCase
Return
    /*21-----------------------------------------------------------------------------*/
Procedure Torta(aSeries,aSeriesNames,aColores)
    if !empty(aSeries)
        ERASE Window Ecram
        DRAW GRAPH IN WINDOW Ecram AT 20,20 TO 450,500;
            TITLE "Saldos por Banco" TYPE PIE;
            SERIES aSeries                   ;
            DEPTH 15                         ;
            SERIENAMES aSeriesNames          ;
            COLORS aColores                  ;
            3DVIEW                           ;
            SHOWXVALUES                      ;
            SHOWLEGENDS
    endif
Return
    /*22-----------------------------------------------------------------------------*/
Procedure Barras(aSer1,aSerN1,aCol1)
    if !empty(aSer1)

        ERASE WINDOW Ecram

        DRAW GRAPH IN WINDOW Ecram            ;
            AT 20,20                      ;
            TO 450,500                    ;
            TITLE "Saldos por Banco"      ;
            TYPE BARS                     ;
            SERIES aSer1                  ;
            YVALUES {"Saldo en $"}       ;
            DEPTH 12                      ;
            BARWIDTH 12                   ;
            HVALUES 10                    ;
            SERIENAMES aSerN1             ;
            COLORS aCol1                  ;
            3DVIEW                        ;
            SHOWGRID                      ;
            SHOWXVALUES                   ;
            SHOWYVALUES                   ;
            SHOWLEGENDS

    endif
Return
    /*23-----------------------------------------------------------------------------*/
Procedure Lineas(aSeries,aSeriesNames,aColores)
    if !empty(aSeries)
        ERASE WINDOW Ecram
        DRAW GRAPH							;
            IN WINDOW Ecram					;
            AT 20,20						;
            TO 450,500						;
            TITLE "Saldos por Banco"				;
            TYPE LINES						;
            SERIES aSeries						;
            YVALUES {"Saldo en $"}       ;
            DEPTH 15						;
            BARWIDTH 15						;
            HVALUES 5						;
            SERIENAMES aSeriesNames		                        ;
            COLORS aColores	                                        ;
            3DVIEW    						;
            SHOWGRID                        			;
            SHOWXVALUES                     			;
            SHOWYVALUES                     			;
            SHOWLEGENDS
    Endif
Return
    /*24-----------------------------------------------------------------------------*/
Procedure Puntos(aSeries,aSeriesNames,aColores)
    if !empty(aSeries)
        ERASE WINDOW Ecram
        DRAW GRAPH							;
            IN WINDOW Ecram					;
            AT 20,20						;
            TO 450,500						;
            TITLE "Saldos por Banco"				;
            TYPE POINTS						;
            SERIES aSeries					        ;
            YVALUES {"Saldo en $"}       ;
            DEPTH 15						;
            BARWIDTH 15						;
            HVALUES 5						;
            SERIENAMES aSeriesNames		                        ;
            COLORS aColores	                                        ;
            3DVIEW    						;
            SHOWGRID                        			;
            SHOWXVALUES                     			;
            SHOWLEGENDS
    endif
    Return