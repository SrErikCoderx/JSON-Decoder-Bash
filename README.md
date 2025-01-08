# JSON-Decoder-Bash
  <h3 align="center">JDB</h3>
  JDB es un script de bash el cual cree con el motivo de decodificar los archivos JSON formateados en Unicode a su formato original UTF-8 para permitir la visualizacion de estos.
  
# Funcionamiento
* JQ
verifica el archivo e acomoda la estructura si es que esta minificada

* Perl
convierte los caracteres unicode en caracteres normales de formato UTF-8 decodificando de esta manera el archivo por completo.



# Instalacion
```sh
git clone https://github.com/SrErikCoderx/JSON-Decoder-Bash.git
```
```sh
cd JSON-Decoder-Bash
```
```sh
chmod +x JDB.sh
```
```sh
./JDB.sh <directory> <argument>
```
_`El argumento no es obligatorio.`_

# Argumentos
* "_`--fxo`_": Este acomoda la estructura si el archivo esta minificado, al igual que borra comentarios normales (//) y tambien comentarios multilinea (/**/).

# Requerimientos
* GIT
```sh
pkg install git
```
* JQ
```sh
pkg install jq
```

# Codigo

```sh
#!/bin/bash

if [ -z "$1" ]; then
  echo "Por favor, proporciona un directorio."
  exit 1
fi

if [ ! -d "$1" ]; then
  echo "El directorio $1 no existe."
  exit 1
fi

FXO=false

if [ "$2" == "--fxo" ]; then
  FXO=true
fi

fix_json() {
  local file="$1"
  
  sed -i 's/\/\/.*$//' "$file"
  sed -i '/\/\*/,/\*\//d' "$file"

  sed -i 's/\s*$//' "$file"

  if ! jq '.' "$file" > "${file}.fixed" 2>/dev/null; then
    echo "Corrigiendo errores en $file..."
    
    sed -i 's/[^,:{}0-9.\-+eE\"a-zA-Z_\s]//g' "$file"   
    sed -i '/^[[:space:]]*$/d' "$file"                  
    
    if jq '.' "$file" > "${file}.fixed" 2>/dev/null; then
      mv "${file}.fixed" "$file"
      echo "Archivo $file corregido exitosamente."
    else
      echo "No se pudo corregir $file automáticamente."
      rm -f "${file}.fixed"
    fi
  else
    mv "${file}.fixed" "$file"
    echo "Archivo $file validado y corregido."
  fi
}

find "$1" -type f -name "*.json" | while read file; do
  sed -i 's/\/\*[^*]*\*\///g' "$file"

  sed -i 's/\s*$//' "$file"
  
  perl -pi -e 's/\\u([0-9A-Fa-f]{4})/chr(hex($1))/ge' "$file"
  
  if [ "$FXO" = true ]; then
    fix_json "$file"
  fi
done

echo "Proceso completado."
```
