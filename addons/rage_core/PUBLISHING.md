# Publicar Rage Core en el Asset Library de Godot

## ðŸ“¦ PreparaciÃ³n para PublicaciÃ³n

### 1. Estructura del Addon

El addon debe tener esta estructura:
\\\
rage_core/
â”œâ”€â”€ plugin.cfg          âœ… Ya existe
â”œâ”€â”€ plugin.gd           âœ… Ya existe
â”œâ”€â”€ README.md           âœ… Ya existe
â”œâ”€â”€ LICENSE             âœ… Creado
â”œâ”€â”€ icon.png            âš ï¸ Opcional pero recomendado
â””â”€â”€ [cÃ³digo del addon]
\\\

### 2. Archivos Requeridos

#### plugin.cfg
Ya estÃ¡ configurado correctamente con descripciÃ³n mejorada.

#### LICENSE
Archivo MIT License creado en la raÃ­z del addon.

### 3. Verificaciones Antes de Publicar

- [x] No hay referencias a rutas especÃ­ficas del proyecto
- [x] Todos los archivos \.uid\ estÃ¡n incluidos (necesarios para Godot)
- [x] README.md es claro y completo
- [x] LICENSE estÃ¡ presente
- [x] plugin.cfg tiene informaciÃ³n correcta
- [ ] El addon funciona en un proyecto nuevo (verificar manualmente)

### 4. Limpieza de Archivos

**Incluir:**
- âœ… Todos los \.gd\ y \.gd.uid\
- âœ… Todos los \.tscn\ y \.tscn.uid\
- âœ… \plugin.cfg\
- âœ… \README.md\
- âœ… \LICENSE\
- âœ… \docs/\ (documentaciÃ³n)
- âœ… \mod_packs/\ (ejemplos)

**Excluir (si existen):**
- âŒ Archivos de prueba temporales
- âŒ Archivos de configuraciÃ³n del IDE
- âŒ \.git/\ y \.gitignore\
- âŒ Archivos de build

## ðŸš€ Proceso de PublicaciÃ³n

### Paso 1: Crear el ZIP

1. Navegar a la carpeta del proyecto
2. Seleccionar SOLO la carpeta \ddons/rage_core/\
3. Comprimir en ZIP (mantener estructura de carpetas)
4. Nombre sugerido: \age_core_v1.0.0.zip\

**Estructura del ZIP:**
\\\
rage_core_v1.0.0.zip
â””â”€â”€ rage_core/
    â”œâ”€â”€ plugin.cfg
    â”œâ”€â”€ plugin.gd
    â”œâ”€â”€ README.md
    â”œâ”€â”€ LICENSE
    â””â”€â”€ [resto de archivos]
\\\

### Paso 2: Subir al Asset Library

1. Ir a https://godotengine.org/asset-library/
2. Iniciar sesiÃ³n con tu cuenta de Godot
3. Click en "Submit a Project"
4. Completar el formulario:

**InformaciÃ³n BÃ¡sica:**
- **Title**: \Rage Core\
- **Category**: \Framework\
- **Version**: \1.0.0\
- **Godot Version**: \4.x\
- **License**: \MIT\

**DescripciÃ³n Corta** (mÃ¡x 200 caracteres):
\\\
Layered 2D gameplay framework with mods, content packs, and deterministic replay system. Engine-agnostic core with Godot integration.
\\\

**DescripciÃ³n Completa**:
Usar el contenido de \README.md\ o una versiÃ³n resumida.

**Tags**:
- \ramework\
- \game-engine\
- \modding\
- \deterministic\
- \2d\
- \eplay\
- \rchitecture\

**Archivo Principal**:
- Subir el ZIP creado en el Paso 1

### Paso 3: RevisiÃ³n

El Asset Library revisarÃ¡ tu addon. Esto puede tomar algunos dÃ­as.

## ðŸ“ Notas Importantes

1. **Versiones**: Usa versionado semÃ¡ntico (1.0.0, 1.1.0, 2.0.0)
2. **Compatibilidad**: Especifica claramente quÃ© versiÃ³n de Godot requiere
3. **Dependencias**: Rage Toolkit es opcional, menciÃ³nalo
4. **DocumentaciÃ³n**: AsegÃºrate de que el README sea claro para nuevos usuarios

## ðŸ”„ Actualizaciones Futuras

Para actualizar el addon:
1. Incrementa la versiÃ³n en \plugin.cfg\
2. Actualiza el CHANGELOG
3. Crea nuevo ZIP
4. Sube como nueva versiÃ³n en el Asset Library
