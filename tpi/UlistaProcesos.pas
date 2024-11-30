unit UlistaProcesos;
interface
    type 
    
    Tproceso=record
        id:string;
        arribo,retorno:byte;
        Duracion:byte;
        peso:integer; //tamanio
    end;

    Tlista=^Tnodo;
    Tnodo=record 
        info:Tproceso;
        sig:Tlista;
    end;

    procedure init(var lista:Tlista);
    function empty(lista:Tlista):boolean;
    procedure push(var lista:Tlista; proceso:Tproceso);
    procedure push2(var lista: Tlista; proceso: Tproceso);

    procedure pop(var lista:Tlista;var proceso:Tproceso);
    procedure print(lista:Tlista);

implementation

procedure init(var lista:Tlista);
begin
    lista:=nil;
end;

function empty(lista:Tlista):boolean;
begin
    empty:=lista=nil; 
end;

procedure push(var lista:Tlista; proceso:Tproceso);
var aux,actual,anterior:Tlista; 
begin
    new(aux);
    aux^.info:=proceso;
    aux^.sig:=nil;
    if (lista = nil) or (lista^.info.Arribo > proceso.Arribo) then  //inserto al principio si es el unico o si llega antes
        begin
            aux^.sig := lista;
            lista := aux;
        end
    else                //busco su posicion
        begin
            anterior := nil;
            actual := lista;
            while (actual <> nil) and (actual^.info.Arribo <= proceso.Arribo) do
            begin
                anterior := actual;
                actual := actual^.sig;
            end;
            anterior^.sig := aux;
            aux^.sig := actual;
        end;
end;

procedure pop(var lista:Tlista;var proceso:Tproceso);
var aux:Tlista;
begin
    if lista<>nil then 
    begin
        aux:=lista;
        proceso:=lista^.info;
        lista:=lista^.sig;
        dispose(aux);
    end
end;

procedure print(lista:Tlista);
begin
    writeln();
    while lista <> nil do
    begin
        writeln('id de proceso: ', lista^.info.id, ', Arribo: ', lista^.info.Arribo,
                ', Duracion: ', lista^.info.Duracion, ', peso: ', lista^.info.peso);
        lista := lista^.sig;
    end;
end;

procedure push2(var lista: Tlista; proceso: Tproceso);
var
  aux, aux2: Tlista;
begin
  // Crear un nuevo nodo
  new(aux);
  aux^.info := proceso;
  aux^.sig := nil;

  // Verificar si la lista está vacía
  if lista = nil then
    lista := aux
  else
  begin
    // Recorrer hasta el último nodo
    aux2 := lista;
    while aux2^.sig <> nil do
      aux2 := aux2^.sig;

    // Insertar el nuevo nodo al final
    aux2^.sig := aux;
  end;
end;

end.