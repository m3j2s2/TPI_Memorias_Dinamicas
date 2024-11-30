unit Uarchivo;
interface
    uses UlistaProcesos,SysUtils,classes;
    type  Tarchivo = file of UlistaProcesos.Tproceso;

  procedure CrearArchivo(var archivo:Tarchivo;ruta:String);
    
  procedure CrearArchivoIncremental(var archivo:Tarchivo);

  procedure CrearAuditoria(var archivo:TextFile;var Procesos:Tarchivo);

implementation
procedure CrearArchivo(var archivo:Tarchivo;ruta:String);
var proceso:UlistaProcesos.Tproceso;
begin
    Assign(archivo, Ruta);
    Rewrite(archivo);
    seek(archivo,0);
    //1. ============
  proceso.id:='p1';
  proceso.arribo:=0;
  proceso.Duracion:=6;
  proceso.peso:=30;
  write(archivo,proceso);
  //2. ============
  proceso.id:='p2';
  proceso.arribo:=1;
  proceso.Duracion:=15;
  proceso.peso:=20;
  write(archivo,proceso);
  //3. ============
  proceso.id:='p3';
  proceso.arribo:=2;
  proceso.Duracion:=4;
  proceso.peso:=20;
  write(archivo,proceso);
  //4. ============
  proceso.id:='p4';
  proceso.arribo:=3;
  proceso.Duracion:=10;
  proceso.peso:=20;
  write(archivo,proceso);
  //5. ============
  proceso.id:='p5';
  proceso.arribo:=4;
  proceso.Duracion:=2;
  proceso.peso:=30;
  write(archivo,proceso);
  //6. ============
  proceso.id:='p6';
  proceso.arribo:=5;
  proceso.Duracion:=8;
  proceso.peso:=20;
  write(archivo,proceso);
  //7. ============
  proceso.id:='p7';
  proceso.arribo:=6;
  proceso.Duracion:=10;
  proceso.peso:=30;
  write(archivo,proceso);
  //8. ============
  proceso.id:='p8';
  proceso.arribo:=7;
  proceso.Duracion:=3;
  proceso.peso:=10;
  write(archivo,proceso);
  //9. ============
  proceso.id:='p9';
  proceso.arribo:=8;
  proceso.Duracion:=5;
  proceso.peso:=10;
  write(archivo,proceso);
  //10. ============
  proceso.id:='p10';
  proceso.arribo:=9;
  proceso.Duracion:=8;
  proceso.peso:=20;
  write(archivo,proceso);
end;

procedure CrearArchivoIncremental(var archivo: Tarchivo);
var
  RutaBase, nombreArchivo: String;
  sr: TSearchRec;  // Variable para buscar archivos en el directorio
  maxNumero, i: LongInt;
  archivoNumero: String;
begin
  maxNumero := 0;
  RutaBase := GetCurrentDir + '\tpi'; // Definir la ruta base

  // Verificar que la carpeta exista
  if not DirectoryExists(RutaBase) then
  begin
    writeln('La carpeta "tpi" no existe. Creándola en: ', RutaBase);
    if not CreateDir(RutaBase) then
    begin
      writeln('Error: No se pudo crear la carpeta "tpi".');
      Exit;
    end;
  end;

  // Buscar archivos en la carpeta con el patrón "p<i>.dat"
  if FindFirst(RutaBase + '\p*.dat', faAnyFile, sr) = 0 then
  begin
    repeat
      // Extraer el número "i" del nombre del archivo
      if (Length(sr.Name) > 1) and (sr.Name[1] = 'p') then
      begin
        archivoNumero := Copy(sr.Name, 2, Pos('.dat', sr.Name) - 2); // Extraer número entre 'p' y '.dat'
        if TryStrToInt(archivoNumero, i) then
          if i > maxNumero then
            maxNumero := i;
      end;
    until FindNext(sr) <> 0;
    FindClose(sr); // Cerrar el directorio
  end;

  // Incrementar el número más alto encontrado para generar un nuevo archivo
  i := maxNumero + 1;
  nombreArchivo := RutaBase + '\p' + IntToStr(i) + '.dat';

  // Crear el archivo
  Assign(archivo, nombreArchivo);
  {$I-}  // Desactivar control de errores de E/S
  Rewrite(archivo);
  {$I+}  // Reactivar control de errores de E/S
  if IOResult <> 0 then
  begin
    writeln('Error: No se pudo crear el archivo en la ruta: ', nombreArchivo);
    Exit;
  end;

  writeln('Archivo creado exitosamente: ', nombreArchivo);
  Close(archivo);
end;

procedure CrearAuditoria(var archivo:TextFile;var Procesos:Tarchivo);
var
  RutaBase, nombreArchivo: String;
  sr: TSearchRec;  // Variable para buscar archivos en el directorio
  maxNumero, i: LongInt;
  archivoNumero,evento: String;
  proceso:UlistaProcesos.Tproceso;
  begin
  maxNumero := 0;
  RutaBase := GetCurrentDir + '\auditoria'; // Definir la ruta base
  
  // Verificar que la carpeta exista
  if not DirectoryExists(RutaBase) then
  begin
    writeln('La carpeta "auditoria" no existe. Creándola en: ', RutaBase);
    if not CreateDir(RutaBase) then
    begin
      writeln('Error: No se pudo crear la carpeta "auditoria".');
      Exit;
    end;
  end;

  // Buscar archivos en la carpeta con el patrón "p<i>.dat"
  if FindFirst(RutaBase + '\p*.txt', faAnyFile, sr) = 0 then
  begin
    repeat
      // Extraer el número "i" del nombre del archivo
      if (Length(sr.Name) > 1) and (sr.Name[1] = 'p') then
      begin
        archivoNumero := Copy(sr.Name, 2, Pos('.txt', sr.Name) - 2); // Extraer número entre 'p' y '.dat'
        if TryStrToInt(archivoNumero, i) then
          if i > maxNumero then
            maxNumero := i;
      end;
    until FindNext(sr) <> 0;
    FindClose(sr); // Cerrar el directorio
  end;

  // Incrementar el número más alto encontrado para generar un nuevo archivo
  i := maxNumero + 1;
  nombreArchivo := RutaBase + '\p' + IntToStr(i) + '.txt';

  // Crear el archivo
  Assign(archivo, nombreArchivo);
  {$I-}  // Desactivar control de errores de E/S
  Rewrite(archivo);
  {$I+}  // Reactivar control de errores de E/S
  if IOResult <> 0 then
  begin
    writeln('Error: No se pudo crear el archivo en la ruta: ', nombreArchivo);
    Exit;
  end;

  writeln('Archivo creado exitosamente: ', nombreArchivo);
  
  write(archivo,'Procesos: ');
  reset(procesos);
  while not eof(procesos)do
  begin
    read(procesos,proceso);
    
    evento := 'id de proceso: ' + proceso.id + 
          ', Arribo: ' + IntToStr(proceso.arribo) + 
          ', Duracion: ' + IntToStr(proceso.Duracion) + 
          ', peso: ' + IntToStr(proceso.peso);
    writeln(archivo,'');
    writeln(archivo,evento);      

  end;
  //Close(archivo);
end;

end.