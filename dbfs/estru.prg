*-------------------------------------------------*
 PROCEDURE MAKE_DataBase()
*-------------------------------------------------*
 DBCREATE ("M", {;
	{ "BANCO",      "N",   4,  0 },;
	{ "FEC_PAGO",   "D",   8,  0 },;
	{ "FEC_COBRO",  "D",   8,  0 },;
	{ "CHEQUE",     "N",  10,  0 },;
	{ "DEBE",       "N",  15,  2 },;
	{ "HABER",      "N",  15,  2 },;
	{ "DETALLE",    "C",  40,  0 },;
	{ "IMPUTACION", "N",   7,  0 },;
	{ "SALDO",      "N",  15,  2 }}, "DBFCDX")
 RETURN
