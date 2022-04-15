
#define PROGRAM        'Saldos Bancarios '
#define VERSION        " v."+substr(__DATE__,3,2)+"."+right(__DATE__,4)+" "
#define COPYRIGHT      ' (c)2019-2022 '
#define DEVELOPER      ' by MigSoft '
#define WEBSOURCE      ' http://sourceforge.net/projects/saldobanco '

#ifndef __HARBOUR__
   #xtranslate hb_MemoWrit(<a>,<b>) => Memowrit(<a>,<b>,.N.)
   #xtranslate Hb_CurDrive() => Curdrive()
#else
   #xtranslate MemoWrit(<a>,<b>,<c>) => hb_MemoWrit(<a>,<b>)
   #xtranslate CurDrive() => Hb_Curdrive()
#endif
