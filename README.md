# Instrucciones: Monitor de Batería Remoto para KDE Plasma

Este sistema te permite ver el nivel de batería de tu laptop en otra PC o VM(ambas con Kubuntu/KDE Plasma).

## 🚀 Instalación Rápida (Recomendado)

He creado un script para automatizar la instalación del widget y la configuración del servidor receptor.

1. Abre una terminal en la carpeta del proyecto.
2. Ejecuta el instalador:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

El script se encargará de:
- Verificar dependencias (`python3`, `kpackagetool`).
- Abrir el puerto 5555 en el firewall (UFW).
- Instalar el widget de KDE.
- (Opcional) Configurar un servicio de sistema para que el receptor se inicie solo.

---

## 🛠️ Configuración Manual (Si el script falla)

### Paso A: Obtener la IP de la PC Receptora
Para que la laptop sepa a dónde enviar los datos, necesitas la IP de esta PC. Ejecuta:
```bash
hostname -I
```
(Usa la primera dirección que aparezca, ej: `192.168.1.15`)

### Paso B: Instalar el Widget de KDE
En la carpeta donde tengas los archivos del widget (donde está `metadata.json`), ejecuta:
```bash
kpackagetool6 -i .
```
(O `kpackagetool5` si usas Plasma 5).

Luego, haz clic derecho en tu panel de KDE -> "Añadir Widgets" -> busca "Remote Battery Monitor" y arrástralo a tu panel. 

**Nota: El servidor receptor se iniciará automáticamente cuando el widget esté en el panel.**

---

## 2. Configuración de la Laptop (la que envía los datos)

Ejecuta el script `battery_sender.py` pasando la IP de tu PC receptora que obtuviste en el Paso B:
```bash
python3 battery_sender.py [IP_DE_TU_PC]
```
Si quieres cambiar la frecuencia de actualización (por ejemplo, cada 10 segundos):
```bash
python3 battery_sender.py [IP_DE_TU_PC] --interval 10
```

---

## 3. Persistencia (Para que sobreviva a reinicios)

Para que no tengas que ejecutar los scripts manualmente cada vez:



### En la Laptop Real (Remitente)
Puedes crear un alias o añadirlo al crontab (@reboot), pero lo más importante es la IP.

---

## 4. Estabilidad de la IP (¡Importante!)

Como es una VM, su IP (`192.168.122.111`) podría cambiar si la apagas y la prendes. Tienes dos opciones:

1.  **IP Estática en la VM**: Configura la red de la VM para que siempre pida la misma IP.
2.  **Verificar antes de conectar**: Si notas que deja de recibir datos, verifica la IP de la VM con `hostname -I` y actualiza el comando en la laptop.

---

## Solución de Problemas
- **Firewall**: Asegúrate de que el puerto UDP 5555 esté abierto en el firewall de tu PC (`sudo ufw allow 5555/udp`).
- **IP**: Ambas deben estar en la red de VirtIO (`192.168.122.x`).
