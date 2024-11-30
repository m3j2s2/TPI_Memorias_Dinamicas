unit Umemoria;
{$codepage UTF8}

interface
Uses UlistaProcesos,crt,SysUtils;    

Type 
    Tlista=^Tnodo;
    Tnodo=record 
        sig,ant:Tlista;
        id,peso,dir_comienzo:integer;
        estado:boolean;
        proceso:ulistaProcesos.Tproceso;
    end;

    Tmemoria=record
        lista,ultimaAsignacion:Tlista;
        peso,
        memoria_Disponible,
        FE,
        tiempo_De_Liberacion,tiempo_de_seleccion,tiempo_de_carga,Num_Particiones:integer;
        procesosFinalizados:UlistaProcesos.Tlista;
    end;

procedure init(var memoria:Tmemoria);


function pushFF(var memoria: Tmemoria; proceso:Tproceso;var archivo:TextFile ): boolean;
function pushNF(var memoria: Tmemoria; proceso:Tproceso;var archivo:TextFile ): boolean;
function pushBF(var memoria: Tmemoria; proceso:Tproceso;var archivo:TextFile ): boolean;
function pushWF(var memoria: Tmemoria; proceso:Tproceso;var archivo:TextFile ): boolean;

function empty(memoria:Tmemoria):boolean;
procedure updateMemoria(var memoria:Tmemoria;tiempo:byte;Cantidad_De_Procesos:integer;var archivo:TextFile;var lista:UlistaProcesos.Tlista);
procedure print(memoria:Tmemoria);


implementation

procedure init(var memoria:Tmemoria);
var aux:Tlista;
begin
    new(aux);
    aux^.sig:=nil;
    aux^.ant:=nil;
    aux^.id:=0;
    aux^.dir_comienzo:=0;
    aux^.peso:=memoria.peso;
    aux^.estado:=true;
    memoria.fe:=0;
    memoria.lista:=aux;
    memoria.Num_Particiones:=0;
    memoria.ultimaAsignacion:=memoria.lista;
    UlistaProcesos.init(memoria.procesosFinalizados);
end;

function pushFF(var memoria: Tmemoria; proceso:Tproceso;var archivo:TextFile ):boolean;
var 
    aux, nuevaparticion: Tlista; nota:String; 
begin
    aux := memoria.lista; // Comenzamos desde el inicio de la lista

    // Buscamos una particion libre con suficiente espacio
    while (aux <> nil) and ((aux^.peso < proceso.peso) or (aux^.estado <> true)) do
        aux := aux^.sig;
    
    // Si encontramos una partición adecuada
    if aux <> nil then
    begin
        nota:=('El Proceso "'+ proceso.id+ '" de peso '+ IntToStr(proceso.peso)+ 
                ' se inserta en la particion "'+ IntToStr(aux^.id)+ '"');
        writeln('El Proceso "', proceso.id, '" de peso ', proceso.peso, 
                ' se inserta en la particion "', aux^.id, '"');
        writeln(archivo,nota);
        // Si hay espacio sobrante, creamos una nueva particion
        if aux^.peso > proceso.peso then
        begin
            new(nuevaparticion); // Creamos una nueva particion
            nuevaparticion^.sig := aux^.sig;
            nuevaparticion^.ant := aux;
            if aux^.sig <> nil then
                aux^.sig^.ant := nuevaparticion; // Actualizamos el anterior del siguiente nodo
            aux^.sig := nuevaparticion;
            nuevaparticion^.peso := aux^.peso - proceso.peso; // Espacio restante
            nuevaparticion^.estado := true; // Libre
            nuevaparticion^.id := memoria.Num_Particiones + 1; // Nuevo ID
            inc(memoria.Num_Particiones); // Incrementamos el contador de particiones
            nuevaparticion^.dir_comienzo:=aux^.dir_comienzo+aux^.peso+1;

            writeln('Se crea una nueva particion libre"', nuevaparticion^.id, 
                    '" con un tamaño de ', nuevaparticion^.peso);

            nota:=( 'Se crea una nueva particion libre"'+ IntToStr(nuevaparticion^.id)+ 
                    '" con un tamaño de '+ IntToStr(nuevaparticion^.peso));
            writeln(archivo,nota);
        end;

        // Asignamos el proceso a la particion encontrada
        aux^.proceso := proceso;
        aux^.peso := proceso.peso; // Ajustamos el tamaño de la particion
        aux^.estado := false; // La particion ahora está ocupada
        pushFF:=true;
    end
    else
    begin
        writeln('No se encontro espacio suficiente para el proceso "', proceso.id, '"');
        nota:=('No se encontró espacio suficiente para el proceso "'+ proceso.id+ '"');
        writeln(archivo,nota);
        pushFF:=false;
    end;
end;

function pushNF(var memoria: Tmemoria; proceso:Tproceso;var archivo:TextFile ): boolean;
var
    aux, nuevaparticion: Tlista;nota:String;
    pesoOriginal: integer; // Para guardar el peso original de la partición
    inicioBusqueda: Tlista; // Para detectar si completamos un ciclo
begin
    // Si no hay última asignación, comenzamos desde el inicio.
    if (memoria.ultimaAsignacion = nil) then
        memoria.ultimaAsignacion := memoria.lista;

    aux := memoria.ultimaAsignacion; // Comenzamos desde la última asignación realizada.
    inicioBusqueda := aux;           // Guardamos el punto de inicio para detectar un ciclo.

    // Recorremos la lista buscando una partición adecuada
    while (aux <> nil) and 
          ((aux^.peso < proceso.peso) or (aux^.estado = false)) do
    begin
        aux := aux^.sig; // Avanzamos al siguiente nodo

        // Si llegamos al final de la lista, volvemos al inicio
        if aux = nil then
            aux := memoria.lista;

        // Si completamos un ciclo sin encontrar espacio, salimos del bucle
        if aux = inicioBusqueda then
            break;
    end;

    // Si encontramos una partición adecuada
    if (aux <> nil) and (aux^.peso >= proceso.peso) and (aux^.estado = true) then
    begin
        writeln('El Proceso "', proceso.id, '" de peso ', proceso.peso, 
                ' se inserta en la partición "', aux^.id, '"');
        nota:=('El Proceso "'+ proceso.id+ '" de peso '+ IntToStr(proceso.peso)+ 
                ' se inserta en la particion "'+ IntToStr(aux^.id)+ '"');
        writeln(archivo,nota);
        // Guardamos el peso original antes de modificarlo
        pesoOriginal := aux^.peso;

        // Si hay espacio sobrante, creamos una nueva partición
        if pesoOriginal > proceso.peso then
        begin
            new(nuevaparticion); // Creamos una nueva partición
            nuevaparticion^.sig := aux^.sig;
            nuevaparticion^.ant := aux;
            if aux^.sig <> nil then
                aux^.sig^.ant := nuevaparticion; // Actualizamos el anterior del siguiente nodo
            aux^.sig := nuevaparticion;
            nuevaparticion^.peso := pesoOriginal - proceso.peso; // Espacio restante
            nuevaparticion^.estado := true; // Libre
            nuevaparticion^.id := memoria.Num_Particiones + 1; // Nuevo ID
            inc(memoria.Num_Particiones); // Incrementamos el contador de particiones
            nuevaparticion^.dir_comienzo := aux^.dir_comienzo + proceso.peso;

            writeln('Se crea una nueva partición libre "', nuevaparticion^.id, 
                    '" con un tamaño de ', nuevaparticion^.peso);
            nota:=( 'Se crea una nueva particion libre"'+ IntToStr(nuevaparticion^.id)+ 
                    '" con un tamaño de '+ IntToStr(nuevaparticion^.peso));
            writeln(archivo,nota);
        end;

        // Asignamos el proceso a la partición encontrada
        aux^.proceso := proceso;
        aux^.peso := proceso.peso; // Ajustamos el tamaño de la partición
        aux^.estado := false; // La partición ahora está ocupada

        // Actualizamos la última asignación realizada
        memoria.ultimaAsignacion := aux;

        pushNF := true;
    end
    else
    begin
        writeln('No se encontró espacio suficiente para el proceso "', proceso.id, '"');
        nota:=('No se encontró espacio suficiente para el proceso "'+ proceso.id+ '"');
        writeln(archivo,nota);
        pushNF := false;
    end;
end;

function pushBF(var memoria: Tmemoria; proceso:Tproceso;var archivo:TextFile ): boolean;
var 
    ParticionMasChica, aux, nuevaparticion: Tlista;nota:String;
begin
    aux := memoria.lista;
    new(ParticionMasChica);
    ParticionMasChica^.id:=-1;     
    ParticionMasChica^.peso:=10000;  
    // Buscamos una particion libre con suficiente espacio
    while (aux <> nil) do
    begin
        //Estado: Si esta libre u ocupado. {True = Libre// false = Ocupado}
        if (aux^.estado = true) and (aux^.peso >= proceso.peso) then
        begin
            if (aux^.peso < ParticionMasChica^.peso) then
                ParticionMasChica:=aux;
        end;
        aux := aux^.sig;
    end;
    aux:=ParticionMasChica;
    // Si encontramos una partición adecuada
    if aux^.id <> -1 then
    begin
        writeln('El Proceso "', proceso.id, '" de peso ', proceso.peso, 
                ' se inserta en la particion "', aux^.id, '"');
        nota:=('El Proceso "'+ proceso.id+ '" de peso '+ IntToStr(proceso.peso)+ 
                ' se inserta en la particion "'+ IntToStr(aux^.id)+ '"');
        writeln(archivo,nota);
        // Si hay espacio sobrante, creamos una nueva particion
        if aux^.peso > proceso.peso then
        begin
            new(nuevaparticion); // Creamos una nueva particion
            nuevaparticion^.sig := aux^.sig;
            nuevaparticion^.ant := aux;
            if aux^.sig <> nil then
                aux^.sig^.ant := nuevaparticion; // Actualizamos el anterior del siguiente nodo
            aux^.sig := nuevaparticion;
            nuevaparticion^.peso := aux^.peso - proceso.peso; // Espacio restante
            nuevaparticion^.estado := true; // Libre
            nuevaparticion^.id := memoria.Num_Particiones + 1; // Nuevo ID
            inc(memoria.Num_Particiones); // Incrementamos el contador de particiones
            nuevaparticion^.dir_comienzo:=aux^.dir_comienzo+aux^.peso+1;

            writeln('Se crea una nueva particion libre"', nuevaparticion^.id, 
                    '" con un tamaño de ', nuevaparticion^.peso);
            nota:=( 'Se crea una nueva particion libre"'+ IntToStr(nuevaparticion^.id)+ 
                    '" con un tamaño de '+ IntToStr(nuevaparticion^.peso));
            writeln(archivo,nota);
        end;

        // Asignamos el proceso a la particion encontrada
        aux^.proceso := proceso;
        aux^.peso := proceso.peso; // Ajustamos el tamaño de la particion
        aux^.estado := false; // La particion ahora está ocupada
        pushBF:=true;
    end
    else
    begin
        writeln('No se encontro espacio suficiente para el proceso "', proceso.id, '"');

        nota:= ('No se encontro espacio suficiente para el proceso "'+ proceso.id+ '"');
        pushBF:=false;
    end;
end;


function pushWF(var memoria: Tmemoria; proceso:Tproceso;var archivo:TextFile ):boolean;
var 
   boquita, aux, nuevaparticion: Tlista;nota:String;
begin
    aux := memoria.lista; // Comenzamos desde el inicio de la lista

    new(boquita);
    boquita^.id:=-1;
    boquita^.peso:=0;
    // Buscamos una particion libre con suficiente espacio
    while (aux <> nil) do
    begin
        if (aux^.estado = true) and (aux^.peso >= proceso.peso)and(aux^.peso > boquita^.peso) then
        begin
            boquita:=aux;
        end;
        aux := aux^.sig;
    end;
    aux:=boquita;
    // Si encontramos una partición adecuada
    if aux^.id <> -1 then
    begin
        writeln('El Proceso "', proceso.id, '" de peso ', proceso.peso, 
                ' se inserta en la particion "', aux^.id, '"');
        nota:=('El Proceso "'+ proceso.id+ '" de peso '+ IntToStr(proceso.peso)+ 
                ' se inserta en la particion "'+ IntToStr(aux^.id)+ '"');
        writeln(archivo,nota);
        // Si hay espacio sobrante, creamos una nueva particion
        if aux^.peso > proceso.peso then
        begin
            new(nuevaparticion); // Creamos una nueva particion
            nuevaparticion^.sig := aux^.sig;
            nuevaparticion^.ant := aux;
            if aux^.sig <> nil then
                aux^.sig^.ant := nuevaparticion; // Actualizamos el anterior del siguiente nodo
            aux^.sig := nuevaparticion;
            nuevaparticion^.peso := aux^.peso - proceso.peso; // Espacio restante
            nuevaparticion^.estado := true; // Libre
            nuevaparticion^.id := memoria.Num_Particiones + 1; // Nuevo ID
            inc(memoria.Num_Particiones); // Incrementamos el contador de particiones
            nuevaparticion^.dir_comienzo:=aux^.dir_comienzo+aux^.peso+1;

            writeln('Se crea una nueva particion libre"', nuevaparticion^.id, 
                    '" con un tamaño de ', nuevaparticion^.peso);
            nota:=( 'Se crea una nueva particion libre"'+ IntToStr(nuevaparticion^.id)+ 
                    '" con un tamaño de '+ IntToStr(nuevaparticion^.peso));

            writeln(archivo,nota);
        end;

        // Asignamos el proceso a la particion encontrada
        aux^.proceso := proceso;
        aux^.peso := proceso.peso; // Ajustamos el tamaño de la particion
        aux^.estado := false; // La particion ahora está ocupada
        pushWF:=true;
    end
    else
    begin
        writeln('No se encontro espacio suficiente para el proceso "', proceso.id, '"');
        nota:=('No se encontró espacio suficiente para el proceso "'+ proceso.id+ '"');
        writeln(archivo,nota);
        pushWF:=false;
    end;
end;



function empty(memoria:Tmemoria):boolean;
begin
    empty:= (memoria.lista <> nil) and 
            (memoria.lista^.estado = true) and 
            (memoria.lista^.sig = nil) and 
            (memoria.lista^.ant = nil);
end;

procedure liberarMemoria(var lista: Tlista; var Num_Particiones: integer;var memoria:Tmemoria;Cantidad_De_Procesos:integer;var archivo:TextFile);
var
    aux: Tlista;
    updateId: boolean;nota:String;
begin
    updateId := false;
    lista^.estado := true; // Marcamos la partición como libre
    writeln('Se libera la partición: ', lista^.id,'. Que albergaba al proceso: ',lista^.proceso.id);
    nota:=('Se libera la partición: '+ IntToStr(lista^.id)+'. Que albergaba al proceso: '+lista^.proceso.id);
    writeln(archivo,nota);

    // Verificar y unir con la siguiente partición si está libre
    if (lista^.sig <> nil) and (lista^.sig^.estado = true) then
    begin
        if Cantidad_De_Procesos>0 then
            begin

                
                
                memoria.fe+=lista^.sig^.peso;
                writeln(memoria.fe);
               
            end;
        
        
        writeln('La partición ', lista^.id, ' se une con la partición ', lista^.sig^.id);
        nota:=('La partición '+ IntToStr(lista^.id)+ ' se une con la partición '+ IntToStr(lista^.sig^.id));
        writeln(archivo,nota);
        
        updateId := true;
        aux := lista^.sig;
        lista^.peso += aux^.peso; // Incrementar el peso con la siguiente partición
        lista^.sig := aux^.sig;   // Saltar el nodo unido
        if aux^.sig <> nil then
            aux^.sig^.ant := lista; // Actualizar el puntero anterior del siguiente nodo
        dispose(aux); // Liberar el nodo unido
    end;

    // Verificar y unir con la anterior partición si está libre
    if (lista^.ant <> nil) and (lista^.ant^.estado = true) then
    begin
        writeln('La partición ', lista^.id, ' se une con la partición ', lista^.ant^.id);
        nota:=('La partición '+ IntToStr(lista^.id) +  ' se une con la partición ' + IntToStr(lista^.ant^.id));
        writeln(archivo,nota);

        updateId := true;
        aux := lista^.ant;
        aux^.peso += lista^.peso; // Incrementar el peso con la actual partición
        aux^.sig := lista^.sig;   // Saltar el nodo actual
        if lista^.sig <> nil then
            lista^.sig^.ant := aux; // Actualizar el puntero anterior del siguiente nodo
        dispose(lista); // Liberar el nodo actual
        lista := aux;   // Actualizar la referencia a la partición unida
    end;

    // Actualizar el ID de la partición si hubo uniones
    if updateId then
    begin
        lista^.id := Num_Particiones + 1; // Nuevo ID único para la partición unida
        writeln('Dadas las uniones entre particiones, se crea una nueva partición ', lista^.id, 
                ' de tamaño: ', lista^.peso);
        nota:=('Debido a las uniones entre las particiones, se crea una nueva partición '+ IntToStr(lista^.id)+' de tamaño: '+ IntToStr(lista^.peso));
        writeln(archivo,nota);
        Flush(archivo);
        inc(Num_Particiones); // Incrementamos el contador global de particiones
    end;
end;


procedure updateMemoria(var memoria:Tmemoria;tiempo:byte;Cantidad_De_Procesos:integer;var archivo:TextFile;var lista:UlistaProcesos.Tlista);
var aux:Tlista;nota:String;
begin
    aux:=memoria.lista;
    while aux<>nil do
    begin
        aux^.proceso.duracion-=1;
        if aux^.proceso.duracion-memoria.tiempo_De_Liberacion=0 then 
        begin
            
            writeln('El proceso ',aux^.proceso.id,' finalizo en el tiempo: ',tiempo,'. la particion ',aux^.id,' se liberara en ', memoria.tiempo_De_Liberacion,'ms');
            nota:=(('El proceso '+aux^.proceso.id+' finalizo en el tiempo: '+IntToStr(tiempo)+'. la particion '+IntToStr(aux^.id)+' se liberara en '+ IntToStr(memoria.tiempo_De_Liberacion)+'ms'));
            writeln(archivo,nota);
            aux^.proceso.retorno:=tiempo;
            UlistaProcesos.push2(lista,aux^.proceso);

        end;
        if (Cantidad_De_Procesos>0)and(aux^.estado=true) then
        begin
            memoria.fe+=aux^.peso; 
            writeln(memoria.fe);
        end;
        if aux^.proceso.duracion=0 then 
            liberarMemoria(aux,memoria.Num_Particiones,memoria,Cantidad_De_Procesos,archivo);
        aux:=aux^.sig;
    end;
end;

procedure print(memoria: Tmemoria);
var
  aux: Tlista; // Usamos un puntero auxiliar para no modificar la lista original
  estado: String;
begin
    aux := memoria.lista; // Guardamos la lista original en un auxiliar
    writeln('Estado actual de la memoria:');
    writeln('┌──────────────────────────────────────────────┐');
    while aux <> nil do
    begin
        // Determinar el estado en formato más claro
        if aux^.estado then
        estado := 'Libre'
        else
        estado := 'Ocupado';
        
        // Imprimir la partición con formato gráfico
        writeln('│ Partición ', aux^.id:3, ' │ Estado: ', estado:8, ' │ Tamaño: ', aux^.peso:4,' │');
        if aux^.sig <> nil then
        writeln('├───────────────────────────────────────────');
        
        aux := aux^.sig; // Avanzar al siguiente nodo
    end;
    writeln('└──────────────────────────────────────────────┘');
end;

    
end.