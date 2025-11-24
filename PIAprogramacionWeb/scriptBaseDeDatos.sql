DROP DATABASE IF EXISTS bibliotequero;

-- Crear base de datos
CREATE DATABASE bibliotequero CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bibliotequero;

-- Tabla de usuarios
CREATE TABLE usuario (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100),
  usuario VARCHAR(50) UNIQUE,
  fecha_nacimiento DATE,
  correo VARCHAR(100) UNIQUE,
  password VARCHAR(255),
  url_foto VARCHAR(255)
);
-- Sencillez de las publicaciones
CREATE TABLE publicaciones (
  id INT AUTO_INCREMENT PRIMARY KEY,
  titulo VARCHAR(150) NOT NULL,
  contenido TEXT,
  imagen_url VARCHAR(255),
  fecha_publicacion DATE,  
  idUsuario INT,
  FOREIGN KEY (idUsuario) REFERENCES usuario(id)
);
select * from usuario;  
select * from bibliotequero.publicaciones;


-- Agregar columna de rol a la tabla usuario
ALTER TABLE usuario ADD COLUMN rol ENUM('usuario', 'administrador') DEFAULT 'usuario';

-- Insertar usuario administrador (cambia la contraseña por una segura)
INSERT INTO usuario (nombre, usuario, fecha_nacimiento, correo, password, url_foto, rol) 
VALUES (
    'Administrador Principal', 
    'admin', 
    '1990-01-01', 
    'admin@bibliotequero.com', 
    -- Contraseña: admin123 (debes encriptarla en tu aplicación)
    'admin123', 
    NULL, 
    'administrador'
);


CREATE TABLE libro (
    id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) UNIQUE,
    titulo VARCHAR(255) NOT NULL,
    autor VARCHAR(255) NOT NULL,
    editorial VARCHAR(255),
    anio_publicacion INT,
    genero VARCHAR(100),
    descripcion TEXT,
    portada_url VARCHAR(500),
    ejemplares_disponibles INT DEFAULT 1,
    ejemplares_totales INT DEFAULT 1,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_usuario_creador INT,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_usuario_creador) REFERENCES usuario(id)
);
CREATE TABLE categoria (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    descripcion TEXT
);

-- Insertar categorías comunes
INSERT INTO categoria (nombre, descripcion) VALUES 
('Ficción', 'Novelas y obras de ficción literaria'),
('Ciencia Ficción', 'Obras de ciencia ficción y fantasía'),
('Terror', 'Novelas y cuentos de terror'),
('Romance', 'Novelas románticas'),
('Biografía', 'Biografías y autobiografías'),
('Historia', 'Libros de historia y eventos históricos'),
('Ciencia', 'Libros de divulgación científica'),
('Tecnología', 'Libros sobre tecnología y programación'),
('Autoayuda', 'Libros de desarrollo personal'),
('Infantil', 'Libros para niños y jóvenes');
-- Eliminar tabla préstamo si existe

select * from bibliotequero.libro;
select * from bibliotequero.usuario;
select * from bibliotequero.publicaciones;
select * from bibliotequero.prestamo;
-- Crear tabla préstamo mejorada porque la anterior estaba mal
CREATE TABLE prestamo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_libro INT NOT NULL,
    id_usuario INT NOT NULL,
    fecha_prestamo TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_devolucion_estimada DATE NOT NULL,
    fecha_devolucion_real DATE NULL,
    estado ENUM('activo', 'devuelto', 'atrasado') DEFAULT 'activo',
    observaciones TEXT,
    id_admin_aprobo INT NULL,
    FOREIGN KEY (id_libro) REFERENCES libro(id) ON DELETE CASCADE,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id) ON DELETE CASCADE,
    FOREIGN KEY (id_admin_aprobo) REFERENCES usuario(id) ON DELETE SET NULL
);

-- Actualizar la tabla préstamo
ALTER TABLE prestamo MODIFY estado ENUM('pendiente', 'activo', 'devuelto', 'atrasado', 'rechazado') DEFAULT 'pendiente';