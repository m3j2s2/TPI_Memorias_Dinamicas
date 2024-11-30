program main;
{$codepage UTF8}
uses UlistaProcesos,Umemoria,crt,Uarchivo,SysUtils;
type  Tarchivo = Uarchivo.Tarchivo;

procedure CargarProcesos (var archivo:Tarchivo; var procesos:UlistaProcesos.Tlista; memoria:Tmemoria);
var n,i:integer;proceso:UlistaProcesos.TProceso;
begin
    writeln('Ingrese el tamañon de la memoria');
    readln(memoria.peso);
    writeln('Ingrese el tiempo De Liberacion de las particiones');
    readln(memoria.tiempo_De_Liberacion);
    writeln('Ingrese el tiempo de seleccion de particiones');
    readln(memoria.tiempo_de_seleccion);
    Writeln('Ingrese el tiempo de tiempo de carga de un proceso desde la memoria secundaria a la principal');
    readln(memoria.tiempo_de_carga);
    Umemoria.init(memoria);
    writeln('Cuantos procesos quiere ingresar? ');
    readln(n);
    Uarchivo.CrearArchivoIncremental(archivo);
    reset(archivo);
    seek(archivo,0);
    for i:=1 to n do
    begin
        proceso.id := 'p' + IntToStr(i);
        writeln('Ingrese el tamaño en KB del proceso',proceso.id);
        readln (proceso.peso);
        writeln('Ingrese la duracion del proceso');
        ReadLn(proceso.duracion);
        writeln('Ingrese el tiempo de arribo del proceso');
        ReadLn(proceso.arribo);
        read(archivo,proceso);
    end;

end;

procedure cargarArchivoTanda(var archivo: Tarchivo; var procesos: ulistaProcesos.Tlista; var memoria: Tmemoria;var Cantidad_De_Procesos:integer);
var 
    proceso: ulistaProcesos.Tproceso;Ruta,RutaBase, RutaArchivo: String;
begin
    writeln('Ejercicio TP4 Punto 8');
    writeln('Tamalo de la memoria: 130');
    memoria.peso:=130;
    writeln('Tiempo de seleccion: 0');
    memoria.tiempo_de_seleccion:=0;
    writeln('Tiempo de carga: 0');
    memoria.tiempo_de_carga:=0;
    writeln('Tiempo de liberacion de particion: 0');
    memoria.tiempo_De_Liberacion:=0;
    Umemoria.init(memoria);
    // Definir la ruta del archivo
    RutaBase := GetCurrentDir + '\files';

    // Asegurarse de que la carpeta "files" exista
    if not DirectoryExists(RutaBase) then
    begin
        writeln('La carpeta "files" no existe. Creándola en: ', RutaBase);
        if not CreateDir(RutaBase) then
        begin
            writeln('Error: No se pudo crear la carpeta "files".');
            Exit;
        end;
    end;

    // Construir la ruta completa al archivo
    RutaArchivo := RutaBase + '\archivoTP4EJ8.dat';
    Assign(archivo, RutaArchivo);
    // Intentar abrir el archivo
    {$I-}  // Desactivar control de errores de E/S
    Reset(archivo);
    {$I+}  // Reactivar control de errores de E/S
    // Si el archivo no existe, crearlo
    if IOResult <> 0 then
    begin
        writeln('El archivo no existe. Creándolo automáticamente en la ruta: ', RutaArchivo);
        Uarchivo.crearArchivo(archivo, RutaArchivo); // Llamar a tu función para crear el archivo
        Reset(archivo); // Volver a abrir el archivo recién creado
    end;
    // Inicializar la lista de procesos
    UlistaProcesos.init(procesos);
    seek(archivo, 0);
    // Leer procesos del archivo y cargarlos en la lista
    while not eof(archivo) do
    begin
        Read(archivo, proceso);

        // Ajustar la duración del proceso con los tiempos de memoria
        proceso.duracion += memoria.tiempo_de_carga +
                            memoria.tiempo_De_Liberacion +
                            memoria.tiempo_de_seleccion;
        proceso.retorno := 0;
        // Agregar el proceso a la lista
        UlistaProcesos.push(procesos, proceso);
    end;
    Cantidad_De_Procesos:=filesize(archivo);
    // Cerrar el archivo al finalizar
    Close(archivo);
    // Mostrar la lista de procesos cargados
    clrscr;
    UlistaProcesos.print(procesos);
    writeln('Procesos cargados exitosamente. Presione Enter para continuar.');
    readln();
end;


procedure MENU(var archivo:Tarchivo;var opcion:byte;var procesos:UlistaProcesos.Tlista;var memoria:Umemoria.Tmemoria;var Cantidad_De_Procesos:integer);
begin
    writeln('BIENVENIDO A LA SIMULACION DE ASIGNACION DE MEMORIA DINAMICA');
    writeln('Que desea hacer?');
    Writeln('1- Cargar tanda de procesos de prueba( ya viene con sus propia configuracion de memoria) ');
    writeln('2- Cargar Simulaciones');
    Writeln('3- Crear tanda de procesos');
    writeln('4- ver utlima simulacion');
    readln(opcion);
    repeat
        case opcion of
            1:cargarArchivoTanda(archivo,procesos,memoria,Cantidad_De_Procesos);
            2:CargarProcesos(archivo,procesos,memoria);
            //3:;
            end;
    until (opcion>0) and (opcion<4);
    repeat
    begin
        writeln('Ingrese el modo de asignacion de particiones que deseea emplear en esta simulacion');
        writeln('1_ First-Fit');
        writeln('2_ Next-Fit');
        writeln('3_ Best-Fit');
        writeln('4_ Worst-fit');
        readln(opcion);
    end;
    until (opcion>0) and (opcion<5);
end;

var
archivo:Tarchivo; memoria:Umemoria.Tmemoria; procesos:ulistaProcesos.Tlista; opcion:byte;
tiempo,Cantidad_De_Procesos,total:integer;desbloqueado:boolean; proceso:UlistaProcesos.Tproceso;pepe:string;
auditoria:TextFile; Ruta:String;
ListaFinal:UlistaProcesos.Tlista;
begin
    clrscr;
    MENU(archivo,opcion,procesos,memoria,Cantidad_De_Procesos);
    Uarchivo.CrearAuditoria(auditoria,archivo);
    UlistaProcesos.init(ListaFinal);
    case opcion of
        1:writeln(auditoria,'se elegio FF');
        2:writeln(auditoria,'se elegio NF');
        3:writeln(auditoria,'se elegio BF');
        4:writeln(auditoria,'se elegio NF');
    end;
    //inicio de la simulacion
    tiempo:=0;
    desbloqueado:=true;
    writeln(auditoria,'comienza la simulacion');
    writeln(auditoria,'');
    while (Cantidad_De_Procesos>0) or not (Umemoria.empty(memoria)) do
    begin
        writeln('Tiempo: ', tiempo);
        writeln(auditoria,'Tiempo: '+IntToStr(tiempo));
        // Si hay procesos por leer y no hay uno bloqueado actualmente
        if (Desbloqueado = true)  then
            UlistaProcesos.pop(procesos, proceso); // Sacamos un nuevo proceso de la lista

        // Verifica si el proceso es mayor a la memoria total
        if proceso.peso > memoria.peso  then
        begin
            writeln('Esta simulación fue detenida. El proceso es mayor a la memoria total.');
            writeln('Peso de la memoria: ', memoria.peso);
            writeln('Peso del proceso: ', proceso.peso);
            writeln(auditoria,'Esta simulación fue detenida. El proceso es mayor a la memoria total.');
            writeln(auditoria,'Peso de la memoria: ', IntToStr(memoria.peso));
            writeln(auditoria,'Peso del proceso: ', IntToStr(proceso.peso));
            break;
        end;
        // Si el tiempo actual coincide con el tiempo de arribo del proceso
        if (tiempo >= proceso.arribo)and(Cantidad_De_Procesos>0) then
        begin
            case opcion of
                1: Desbloqueado := Umemoria.pushFF(memoria, proceso,auditoria);
                2: Desbloqueado := Umemoria.pushNF(memoria, proceso,auditoria);
                3: Desbloqueado := Umemoria.pushBF(memoria, proceso,auditoria);
                4: Desbloqueado := Umemoria.pushWF(memoria,proceso,auditoria);
            end;
        end;
        if desbloqueado then Cantidad_De_Procesos-=1;
        // Actualiza el estado de la memoria
        Umemoria.updateMemoria(memoria,tiempo,Cantidad_De_Procesos,auditoria,ListaFinal);
        // Incrementa el tiempo
        tiempo += 1;
        Umemoria.print(memoria);
        readln();
    end;
    Flush(auditoria);
    writeln('fragmentacion externa (FE): ',memoria.fe);
    writeln('Finalizacion de la tanda: ',tiempo-memoria.tiempo_De_Liberacion-1);
    writeln(auditoria,'fragmentacion externa (FE): '+IntToStr(memoria.fe));
    Flush(auditoria);
    writeln(auditoria,'Finalizacion de la tanda: '+IntToStr(tiempo-memoria.tiempo_De_Liberacion-1));
    Flush(auditoria);
    while not UlistaProcesos.empty(ListaFinal)  do
    begin
        pop(ListaFinal,proceso);
        writeln(auditoria,'El proceso '+proceso.id+' volvio en el tiempo: '+IntToStr(proceso.retorno));
        Flush(auditoria);
        total+=proceso.retorno;
    end;
    total:=total div filesize(archivo);
    writeln(auditoria,'tiempo de retorno normalizado: '+IntToStr(total));
    Flush(auditoria);
    writeln(auditoria,'Fin de la simulacion');
    Flush(auditoria);

end.