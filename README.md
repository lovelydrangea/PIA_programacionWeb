#  Bibliotequero  
**Proyecto de Programación Web – Backend en Java + Frontend Web**

Bibliotequero es una aplicación web diseñada como un sistema de **biblioteca digital con funciones de foro**, donde los usuarios pueden registrarse, iniciar sesión, consultar un catálogo de libros, publicar mensajes y solicitar préstamos.  
El sistema incluye un **usuario administrador**, encargado de gestionar los préstamos: aprobarlos, rechazarlos y marcar devoluciones.

---

## 🚀 Tecnologías utilizadas

### **Backend**
- Java (JDK 17 recomendado)
- Apache Tomcat 9
- MySQL 8.x
- JDBC
- Servlets y JSP
- Apache NetBeans IDE 28 (Ubuntu Linux)

### **Frontend**
- HTML5  
- CSS3  
- JavaScript  
- JSP como motor de vistas  

---

## 🧩 Funcionalidades principales

### 👤 Usuario estándar
- Crear cuenta  
- Iniciar sesión  
- Ver catálogo de libros  
- Publicar mensajes en el feed  
- Solicitar préstamos de libros  

### 🔐 Usuario administrador
- Aprobar solicitudes de préstamo  
- Rechazar solicitudes  
- Marcar préstamos como devueltos  
- Supervisar actividad y publicaciones  

---

## 🗄️ Base de datos (MySQL)

El sistema utiliza las siguientes tablas principales:

| Tabla | Descripción |
|-------|-------------|
| **usuarios** | Información de los usuarios (normales y administrador). |
| **libros** | Catálogo de libros disponibles. |
| **publicaciones** | Mensajes publicados por los usuarios en el feed. |
| **prestamos** | Solicitudes de préstamo y su estado (aprobado, rechazado, devuelto). |

El script SQL del proyecto se encuentra en la carpeta `/PIA_programacionWeb/`.

---

## 🛠️ Requisitos del sistema

### Sistema operativo
- Ubuntu Linux (probado en versión 22.04+) (Puede ser cualquier SO)

### Dependencias necesarias
| Software | Versión recomendada |
|---------|----------------------|
| Java JDK | 17 o 21 |
| Apache Tomcat | 9.x |
| MySQL Server | 8.x |
| NetBeans IDE | 28 |

### Librerías
- MySQL Connector/J (`mysql-connector-j-8.x.jar`)  
- Servlet API (incluida con Tomcat)

---

## ⚙️ Instalación y ejecución

### 1️⃣ Instalar dependencias
```bash
sudo apt install default-jdk
sudo apt install tomcat9 tomcat9-admin
sudo apt install mysql-server
