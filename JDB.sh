#!/bin/bash

# Verificar si se proporciona un directorio
if [ -z "$1" ]; then
  echo "Por favor, proporciona un directorio."
  exit 1
fi

# Comprobar si el directorio existe
if [ ! -d "$1" ]; then
  echo "El directorio $1 no existe."
  exit 1
fi

# Variable para controlar el reordenamiento
REORDER=false
FIX=false

# Verificar si se pasó el argumento "--reorder" o "--fix"
if [ "$2" == "--reorder" ]; then
  if ! command -v jq &> /dev/null; then
    echo "El comando 'jq' no está instalado. Instálalo con 'apt install jq'."
    exit 1
  fi
  REORDER=true
fi

if [ "$2" == "--fix" ]; then
  FIX=true
fi

# Función para intentar corregir un archivo JSON
fix_json() {
  local file="$1"
  
  # Intentar usar jq para reescribir el JSON en formato válido
  if ! jq '.' "$file" > "${file}.fixed" 2>/dev/null; then
    echo "Corrigiendo errores en $file..."
    
    # Eliminar caracteres no válidos y estructuras incompletas
    sed -i 's/[^,:{}0-9.\-+eE\"a-zA-Z_\s]//g' "$file"    # Quita caracteres no válidos
    sed -i '/^[[:space:]]*$/d' "$file"                      # Elimina líneas vacías
    
    # Intentar nuevamente reordenar con jq
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

# Procesar los archivos .json en el directorio
find "$1" -type f -name "*.json" | while read file; do
  # Eliminar comentarios y espacios sobrantes
  sed -i 's/^\s*\/\/.*$//' "$file"
  sed -i 's/\s*$//' "$file"
  sed -i 's/\/\*[^*]*\*\///g' "$file"
  
  # Desencriptar Unicode (\uXXXX)
  perl -pi -e 's/\\u([0-9A-Fa-f]{4})/chr(hex($1))/ge' "$file"
  
  # Si se requiere arreglar el archivo JSON
  if [ "$FIX" = true ]; then
    fix_json "$file"
  fi

  # Si se requiere reordenar, hacerlo
  if [ "$REORDER" = true ]; then
    jq '.' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file" || echo "Error al reordenar $file"
  fi
done

echo "Proceso completado."
