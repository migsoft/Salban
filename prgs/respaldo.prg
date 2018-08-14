/*
 * $Id: respaldo.prg,v 1.1 2012/06/15 10:45:20 migsoft Exp $
 *
 * Saldos Bancarios - Sistema de Control de Saldos
 *
 * Copyright 2007-2012 Miguel Angel Juárez A. <fugaz_cl@yahoo.es>
 *
 * MigSoft Sistemas - www.mig2soft.com
 *
 * <http://sourceforge.net/projects/saldobanco>
 *
 */

/*----------------------------------RESPALDO-------------------------------------*/
#include "minigui.ch"
/*45-----------------------------------------------------------------------------*/
Procedure ComprimeBases()
    local aDir   := Directory(SaldoFolder+"\*.dbf")
    local afiles := {} , x

    DBcloseall()

    For x := 1 to Len( aDir )
        Aadd( aFiles, aDir[x,1] )
    Next

    cSalBan  := 'salban'+Right(DtoC(Date()),2)+SubStr(DtoC(Date()),4,2)+Left(DtoC(Date()),2)+'.zip'

    If Len( aFiles ) > 0
        SetCurrentFolder( SaldoFolder )
        COMPRESSFILES( cSalBan, aFiles, { ||EnCurso() }, .T. )
        okCopy(cSalban)
        FErase(SaldoFolder+'\'+cSalban)
    Endif

Return
    /*46-----------------------------------------------------------------------------*/
Function okCopy(cFileZip)
    cSalBan  := cFileZip
    cOrigen  := SaldoFolder+'\'+cFileZip
    cCarpeta := ( GetFolder( "Guardar Respaldo en:" ) )
    if !empty(cCarpeta)
        cDestino := cCarpeta+cSalBan
        if !file(cOrigen)
            MsgInfo('Archivo '+cOrigen+' no encontrado','Precaución!!!')
        else
            if lUnidadLista( hb_CurDrive() + ":\" )
                copy file &(cOrigen) to &(cDestino)
                if file(cDestino)
                    MsgInfo("Respaldo guardado como: "+cDestino,"Exito!!!")
                endif
            else
                MsgInfo('Error de Lectura en Drive',"Precaución!!!")
            endif
        endif
    endif
Return Nil
    /*47-----------------------------------------------------------------------------*/
Procedure RestauraBases()
    cCamino  := SaldoFolder
    cFile    := GetFile( { {'ZIP Files','*.zip'} } , 'Recuperar Respaldo de: ', CurDir() )
    DBcloseall()
    If !empty(cFile)
        If Upper(Left(GetName(cFile),6)) == Upper('salban')
           BorraCdx()
           If !file(cFile)
              msginfo('Archivo '+cFile+' no encontrado')
           Else
              If lUnidadLista(hb_CurDrive() + ":\")
                 SetCurrentFolder( (cCamino) )
                 UNCOMPRESSFILES( cFile , Nil )
                 MsgInfo("Se ha Recuperado Respaldo","Exito!!!")
              Else
                 MsgInfo('Error de Lectura en Drive',"Precaución!!!")
              Endif
           Endif
        Else
           MsgInfo('No es un respaldo de Saldos Bancarios','Cuidado!!!')
        Endif
    Endif
Return
    /*48--------------------------------------------------------*/
Static Function lUnidadLista( cUnid )
    Local lchequeo := .f., n
    FOR n := 1 TO 3
        lchequeo := ( DirChange(cUnid) == 0 )
        INKEY(.02)
    NEXT
Return(lchequeo)

*------------------------------------------------------------*
PROCEDURE COMPRESSFILES ( cFileName , aDir , bBlock , lOvr )
*------------------------------------------------------------*
* Based on HBMZIP Harbour contribution library samples.
    LOCAL hZip , i , cPassword

    if valtype (lOvr) == 'L'
        if lOvr == .t.
            if file (cFileName)
                delete file (cFileName)
            endif
        endif
    endif

    hZip := HB_ZIPOPEN( cFileName )
    IF ! EMPTY( hZip )
        FOR i := 1 To Len (aDir)
            if valtype (bBlock) == 'B'
                Eval ( bBlock , aDir [i] , i )
            endif
            HB_ZipStoreFile( hZip, aDir [ i ], aDir [ i ] , cPassword )
        NEXT
    ENDIF

    HB_ZIPCLOSE( hZip )

RETURN

*------------------------------------------------------------*
PROCEDURE UNCOMPRESSFILES ( cFileName , bBlock )
*------------------------------------------------------------*
* Based on HBMZIP Harbour contribution library samples.
    Local i := 0 , hUnzip , nErr, cFile, dDate, cTime, nSize, nCompSize , f

    hUnzip := HB_UNZIPOPEN( cFileName )

    nErr := HB_UNZIPFILEFIRST( hUnzip )

    DO WHILE nErr == 0

        HB_UnzipFileInfo( hUnzip, @cFile, @dDate, @cTime,,,, @nSize, @nCompSize )

        i++
        if valtype (bBlock) = 'B'
            Eval ( bBlock , cFile , i )
        endif

        HB_UnzipExtractCurrentFile( hUnzip, NIL, NIL )

        nErr := HB_UNZIPFILENEXT( hUnzip )

    ENDDO

    HB_UNZIPCLOSE( hUnzip )

RETURN

*---------------------------------------------------------------------*
FUNCTION GetName(cFileName)
*---------------------------------------------------------------------*
  LOCAL cTrim  := ALLTRIM(cFileName)
  LOCAL nSlash := MAX(RAT('\', cTrim), AT(':', cTrim))
  LOCAL cName  := IF(EMPTY(nSlash), cTrim, SUBSTR(cTrim, nSlash + 1))
RETURN( cName )
