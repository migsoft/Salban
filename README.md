

		SISTEMA DE SALDOS BANCARIOS
		============================

DESCRIPCION GENERAL:
-------------------------------------

El sistema soporta la carga de hasta 9999 cuentas bancarias.
La capacidad de los archivos está limitada por la capacidad libre
del disco duro.

Opciones:

         1.- Archivo
	1.- Maestro de Bancos
		 a) Carga de datos de los bancos
		 b) Consulta archivo
		 c) Borrar un banco
		 d) Listados
	2.- Plan de cuentas
		 a) Carga de imputaciones y bajas
		 b) Consulta archivo
		 c) Listados

         2.- Transacciones
                a) Carga de movimientos del libro banco.
                b) Consultas varias
                c) Listados:
                    1.- Listado de cheques diferidos.
                          Lista los movimientos bancarios ordenados por fecha de cobro
                          o acreditación.
                    2.- Listado del libro bancos.
                          Lista los movimientos del libro bancos ordenado por fecha y
                          cheque.

         3.- Reportes
             1.- Listado por cuentas contables.
                   Lista por cuentas contables con totales por cada una de
                   ellas, por un banco o todos.
             2.- Listado por cuentas contables (resúmen).
                   Lista totales de cuentas contables para un banco o todos.
             3.- Resúmen de saldos de todos los bancos.
                   Un renglón por cada banco.

         4.- Herramientas
             1.- Reindexar (Reordenamiento de archivos)
                   Sirve para eliminar los registros borrados ahorrando
                   espacio en el disco r¡gido, y reordena las claves (¡ndices).
                   Es recomendable su uso regularmente, o después de algún
                   corte de energ¡a.
             2.- Respaldo y Restauración
                   Este sistema cuenta con un módulo de backup de archivos y
                   restauración de los mismos.



COMO INICIO ?
---------------------

En la barra superior de la pantalla, podrá  observar lo siguiente:

   ----------        ----------------------      -------------        ------------------
   Archivo         Transacciones       Reportes        Herramientas
   ----------        ----------------------      -------------        ------------------

Esto es el menú principal del sistema, con el cual puede elegir las opciones.

Supongamos que está  situado en la celda de ARCHIVO.
Se mostrará un sub-menú para que pueda seleccionar otras funciones.

Ejemplo:

En ARCHIVO:

   ----------        ----------------------      -------------        ------------------
   Archivo         Transacciones       Reportes        Herramientas
   ----------        ----------------------      -------------        ------------------

   Maestro de Bancos
   Plan de Cuentas Contables


En TRANSACCIONES:

   ----------        ----------------------      -------------        ------------------
   Archivo         Transacciones       Reportes        Herramientas
   ----------        ----------------------      -------------        ------------------

                        Movimiento Bancario
                        Conciliación Bancaria


en REPORTES:
   ----------        ----------------------      -------------        ------------------
   Archivo         Transacciones       Reportes        Herramientas
   ----------        ----------------------      -------------        ------------------

                                                            Libro Bancos
                                                            Listado por Cuentas
                                                            Resumen de Saldos
                                                            Gráfico de Saldos


en HERRAMIENTAS:
   ----------        ----------------------      -------------        ------------------
   Archivo         Transacciones       Reportes        Herramientas
   ----------        ----------------------      -------------        ------------------

                                                                                     Reindexar
                                                                                     Respaldo
                                                                                     Restaurar Respaldo



--------------------------------------------------------------------------------------------------
    SUGERENCIAS PARA COMENZAR LA CARGA ORDENADAMENTE
--------------------------------------------------------------------------------------------------

   ----------        ----------------------      -------------        ------------------
   Archivo         Transacciones       Reportes        Herramientas
   ----------        ----------------------      -------------        ------------------

1 --> Maestro de Bancos
2 --> Plan de Cuentas Contables



Como primera medida debe entrar en ARCHIVO, y seleccionar la opción MAESTRO
DE BANCOS, para numerar (a su criterio) las cuentas bancarias que va a utilizar,
esto es asignar un número a cada banco.

Segundo; seleccionar PLAN DE CUENTAS CONTABLES, para que cuando cargue los
movimientos bancarios pueda asignarles una imputación o código, para que luego
un listado pueda agruparlas por cuentas.

Nota: Las cuentas contables no son imprescindibles para el funcionamiento del
sistema, pero recomiendo su utilización para poder discriminar las erogaciones
o destino de dinero.


Esta es una visión general del sistema.

Nota: Para compilar se necesita incluir las librerías hbmzip y minizip
