<!-- # Juego de la Vida - Tarea Programada 1
##  CI-0118 Lenguaje Ensamblador
***Profesor: Ing. Sleyter Angulo Chavarría***

### Integrantes:
- Mauricio Artavia Monge
- Joaquin Donzon

### Instrucciones:
1. make run
2. Ingrese el tamaño del grid (mínimo 5, máximo 20).
3. Se mostrará el patrón inicial en un cuadrado n × n.

#### Notas:
- Si el tamaño es menor a 5, se muestra una sola celda viva.
- Para tamaños mayores, se muestra un pequeño glider en la esquina.-->

<div id="header" align="center">
  <img src="https://media.giphy.com/media/M9gbBd9nbDrOTu1Mqx/giphy.gif" width="100"/>
</div>

<div id="badges" align="center">
  <a href="https://github.com/C10743-ArtaviaM">
    <img src="https://img.shields.io/badge/GitHub-000000?style=for-the-badge&logo=github&logoColor=white" alt="GitHub Badge"/>
  </a>
</div>

<div align="center">
  <img src="https://media.giphy.com/media/dWesBcTLavkZuG35MI/giphy.gif" width="600" height="300"/>
</div>

---

<div align="center">
  <h1>Juego de la Vida</h1>
  <h3>CI-0118 Lenguaje Ensamblador - Tarea Programada 1</h3>
  <p><b>Profesor:</b> Ing. Sleyter Angulo Chavarría</p>
</div>

## 👥 Integrantes
- Mauricio Artavia Monge
- Joaquin Donzon

---

## 📦 Instrucciones de Uso

1. Compilar y ejecutar:
   ```bash
   make run
   ```
2. Ingresar el tamaño del tablero (mínimo 5, máximo 20).
3. Se mostrará el patrón inicial en un tablero de tamaño `n × n`.

---

## ⚙️ Detalles del Juego

- Si el tamaño ingresado es menor a 5, se visualizará una sola celda viva.
- Para tamaños de 5 o más, se inicializa con un pequeño glider en la esquina superior izquierda.

---

## 🧠 Sobre el Proyecto

Esta implementación del [Juego de la Vida](https://es.wikipedia.org/wiki/Juego_de_la_vida) de Conway fue desarrollada completamente en lenguaje ensamblador NASM para sistemas Linux de 64 bits. El proyecto tiene fines educativos y forma parte del curso **CI-0118 Lenguaje Ensamblador** de la Universidad de Costa Rica.

---

## 🛠️ Tecnologías Utilizadas

- **NASM**: Netwide Assembler
- **GNU Make**
- **Linux x86_64**
- **Terminal ANSI**

---

## 📁 Estructura del Proyecto

```
.
├── game.asm          # Código principal en NASM
├── Makefile          # Script de compilación y ejecución
├── README.md         # Este archivo
└── ...               # Otros posibles archivos auxiliares
```

---

## 💡 Consideraciones

- Este proyecto fue realizado completamente por los autores, sin el uso de herramientas de Inteligencia Artificial.
- El código puede expandirse fácilmente para agregar nuevas reglas o patrones iniciales más complejos.
- Se recomienda ejecutar el programa desde una terminal que soporte ANSI para una mejor visualización del tablero.

---

## 🧑‍🏫 Evaluación

Este trabajo fue realizado como parte de la primera tarea programada y cumple con los requisitos básicos de entrada, visualización y comportamiento del juego. Las optimizaciones y mejoras visuales están en desarrollo para versiones futuras.

---

<div align="center">
  <img src="https://media.giphy.com/media/f9k1tV7HyORcngKF8v/giphy.gif" width="400"/>
</div>