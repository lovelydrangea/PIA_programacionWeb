<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="modelos.Usuario" %>
<%@ page import="modelos.Publicacion" %>
<%@ page import="modelos.Prestamo" %>
<%@ page import="modelos.Libro" %>
<%@ page import="DAO.PublicacionDAO" %>
<%@ page import="DAO.PrestamoDAO" %>
<%@ page import="DAO.LibroDAO" %>
<%@ page import="java.util.List" %>
<%
    // ✅ SOLO OBTENEMOS DATOS, NO VERIFICAMOS
    HttpSession userSession = request.getSession(false);
    Usuario usuario = (Usuario) userSession.getAttribute("usuario");
    
    String nombreUsuario = usuario.getNombreUsuario();
    String fotoPerfil = "https://via.placeholder.com/30";
    String fotoPerfilGrande = "https://via.placeholder.com/150";
    
    if (usuario.getUrlFoto() != null && !usuario.getUrlFoto().trim().isEmpty()) {
        fotoPerfil = request.getContextPath() + "/uploads/" + usuario.getUrlFoto();
        fotoPerfilGrande = request.getContextPath() + "/uploads/" + usuario.getUrlFoto();
    }
    
    
    
        // ✅ OBTENER PRÉSTAMOS DEL USUARIO
    PrestamoDAO prestamoDAO = new PrestamoDAO();
    List<Prestamo> prestamosUsuario = prestamoDAO.obtenerPrestamosPorUsuario(usuario.getIdUsuario());
    // ✅ OBTENER PUBLICACIONES DEL USUARIO
    PublicacionDAO publicacionDAO = new PublicacionDAO();
    List<Publicacion> publicaciones = publicacionDAO.obtenerPublicacionesPorUsuario(usuario.getIdUsuario());
    

    
    // ✅ OBTENER LIBROS PARA MOSTRAR INFORMACIÓN
    LibroDAO libroDAO = new LibroDAO();
    List<Libro> todosLibros = libroDAO.obtenerTodosLibros();
    
     // ✅ OBTENER PARÁMETROS PARA MENSAJES
    String mensaje = request.getParameter("mensaje");
    String error = request.getParameter("error");
    
    // Procesar mensajes de éxito
    if (mensaje != null) {
        switch (mensaje) {
            case "perfil_actualizado":
                mensaje = "✅ Perfil actualizado exitosamente";
                break;
        }
    }
    
    // Procesar mensajes de error
    if (error != null) {
        switch (error) {
            case "campos_vacios":
                error = "❌ Por favor, completa todos los campos obligatorios";
                break;
            case "usuario_corto":
                error = "❌ El nombre de usuario debe tener al menos 3 caracteres";
                break;
            case "correo_invalido":
                error = "❌ Formato de correo electrónico inválido";
                break;
            case "password_corta":
                error = "❌ La contraseña debe tener al menos 6 caracteres";
                break;
            case "usuario_duplicado":
                error = "❌ Este nombre de usuario ya está en uso";
                break;
            case "correo_duplicado":
                error = "❌ Este correo electrónico ya está registrado";
                break;
            case "tipo_archivo_invalido":
                error = "❌ Solo se permiten imágenes JPG, PNG o GIF";
                break;
            case "archivo_demasiado_grande":
                error = "❌ La imagen es demasiado grande. Máximo 2MB";
                break;
            case "no_autorizado":
                error = "❌ No tienes permisos para editar este perfil";
                break;
            case "error_actualizacion":
                error = "❌ Error al actualizar el perfil";
                break;
            case "error_general":
                error = "❌ Error general al procesar la solicitud";
                break;
        }
    }



%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/node_modules/bootstrap/dist/css/bootstrap.css"/>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/Estilos/estilosPerfil.css">
        <link href="https://fonts.googleapis.com/css?family=Oranienbaum" rel="stylesheet">
        <title>Mi Perfil - Bibliotequero</title>
    </head>
    <body>
        <!-- Navbar igual al del catálogo -->
        <nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top">
            <div class="container-fluid">
                <a class="navbar-brand d-flex align-items-center" href="${pageContext.request.contextPath}/pantallas/CatalogoPaginaIncio.jsp">
                    <img src="${pageContext.request.contextPath}/Logo/Logito.png" alt="Logo Bibliotequero" width="40" height="40" class="me-2">
                    <span>Bibliotequero</span>
                </a>

                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#menuBibliotequero" aria-controls="menuBibliotequero" aria-expanded="false" aria-label="Toggle navigation">
                    <span class="navbar-toggler-icon"></span>
                </button>

                <div class="collapse navbar-collapse" id="menuBibliotequero">
                    <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                        <li class="nav-item">
                            <a class="nav-link" href="${pageContext.request.contextPath}/pantallas/CatalogoPaginaIncio.jsp">Catálogo</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="${pageContext.request.contextPath}/pantallas/feed.jsp">Mi Feed</a>
                        </li>
                    </ul>

                    <!-- Usuario con sesión -->
                    <div class="dropdown">
                        <a href="#" class="d-flex align-items-center text-white text-decoration-none dropdown-toggle" 
                           id="dropdownUser1" data-bs-toggle="dropdown" aria-expanded="false">
                            <img id="fotoNavbar" src="<%= fotoPerfil %>" 
                                 width="30" height="30" class="rounded-circle me-2">
                            <strong><%= nombreUsuario %></strong>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-dark dropdown-menu-end shadow" aria-labelledby="dropdownUser1">
                            <li><a class="dropdown-item" href="perfil.jsp">Mi Perfil</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/logout">Cerrar sesión</a></li>
                        </ul>
                    </div>
                </div>
            </div>
        </nav>

        <!-- Contenido principal -->
        <main class="container" style="margin-top: 100px;">
            <div class="row">
                <!-- Columna izquierda - Foto de perfil -->
                <div class="col-md-4">
                    <div class="card shadow-sm">
                        <div class="card-body text-center">
                            <img src="<%= fotoPerfilGrande %>" 
                                 alt="Foto de perfil" class="rounded-circle mb-3" width="150" height="150">
                            <h4><%= usuario.getNombre() %></h4>
                            <p class="text-muted">@<%= usuario.getNombreUsuario() %></p>
                            <p class="text-muted"><%= usuario.getCorreo() %></p>
                            <p class="text-muted"><strong><%= publicaciones.size() %></strong> publicaciones</p>
                            <%
                                // Contar préstamos activos
                                int prestamosActivosCount = 0;
                                for (Prestamo p : prestamosUsuario) {
                                    if ("activo".equals(p.getEstado())) {
                                        prestamosActivosCount++;
                                    }
                                }
                            %>
                            <p class="text-muted"><strong><%= prestamosActivosCount %></strong> préstamos activos</p>
                            <button class="btn btn-outline-primary btn-sm" data-bs-toggle="modal" data-bs-target="#modalEditarPerfil">✏️ Editar Perfil</button>
                            <!-- Mostrar mensajes -->
                            <% if (mensaje != null) { %>
                            <div class="alert alert-success alert-dismissible fade show" role="alert">
                                <%= mensaje %>
                                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                            </div>
                            <% } %>

                            <% if (error != null) { %>
                            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                <%= error %>
                                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                            </div>
                            <% } %>
                        </div>
                    </div>
                </div>

                <!-- Columna derecha - Información -->
                <div class="col-md-8">
                    <!-- Información personal -->
                    <div class="card shadow-sm">
                        <div class="card-header bg-dark text-white">
                            <h5 class="mb-0">Información Personal</h5>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <strong>Nombre completo:</strong>
                                    <p class="mt-1"><%= usuario.getNombre() %></p>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <strong>Usuario:</strong>
                                    <p class="mt-1">@<%= usuario.getNombreUsuario() %></p>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <strong>Correo electrónico:</strong>
                                    <p class="mt-1"><%= usuario.getCorreo() %></p>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <strong>Fecha de nacimiento:</strong>
                                    <p class="mt-1">
                                        <%= usuario.getFechaNacimiento() != null ? 
                                    usuario.getFechaNacimiento().toString() : "No especificada" %>
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                     <!-- Modal para editar perfil -->
                    <div class="modal fade" id="modalEditarPerfil" tabindex="-1" aria-labelledby="modalEditarPerfilLabel" aria-hidden="true">
                        <div class="modal-dialog modal-lg">
                            <div class="modal-content">
                                <div class="modal-header bg-dark text-white">
                                    <h5 class="modal-title" id="modalEditarPerfilLabel">✏️ Editar Perfil</h5>
                                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                                </div>
                                <div class="modal-body">
                                    <!-- Mensajes de error/success -->
                                    <div id="mensajeEdicion" class="alert d-none"></div>

                                    <form id="formEditarPerfil" action="${pageContext.request.contextPath}/editar-perfil" method="post" enctype="multipart/form-data">
                                        <input type="hidden" name="idUsuario" value="<%= usuario.getIdUsuario() %>">

                                        <div class="row">
                                            <!-- Columna izquierda - Foto de perfil -->
                                            <div class="col-md-4">
                                                <div class="card p-3 shadow text-center mb-4">
                                                    <label for="fotoPerfil" class="form-label fw-bold">Foto de perfil</label>
                                                    <img id="previewPerfil" src="<%= fotoPerfilGrande %>" 
                                                         alt="Foto de perfil" class="img-preview rounded-circle mb-3 mx-auto" 
                                                         width="150" height="150" style="object-fit: cover;">
                                                    <input class="form-control" type="file" id="fotoPerfil" name="fotoPerfil" 
                                                           accept="image/*" onchange="previsualizarFotoPerfil(event)">
                                                    <div class="form-text">Formatos: JPG, PNG, GIF. Máximo 2MB.</div>
                                                    <div id="errorFoto" class="text-danger small mt-1 d-none"></div>
                                                </div>
                                            </div>

                                            <!-- Columna derecha - Formulario -->
                                            <div class="col-md-8">
                                                <!-- Nombre -->
                                                <div class="mb-3">
                                                    <label for="nombre" class="form-label">Nombre completo *</label>
                                                    <input type="text" class="form-control" id="nombre" name="nombre" 
                                                           value="<%= usuario.getNombre() %>" required>
                                                    <div id="errorNombre" class="text-danger small mt-1 d-none"></div>
                                                </div>

                                                <!-- Usuario -->
                                                <div class="mb-3">
                                                    <label for="usuario" class="form-label">Nombre de usuario *</label>
                                                    <input type="text" class="form-control" id="usuario" name="usuario" 
                                                           value="<%= usuario.getNombreUsuario() %>" required
                                                           onblur="validarUsuarioExistente(this.value)">
                                                    <div id="usuarioHelp" class="form-text">Este es tu nombre público.</div>
                                                    <div id="errorUsuario" class="text-danger small mt-1 d-none"></div>
                                                    <div id="loadingUsuario" class="text-info small mt-1 d-none">⏳ Verificando...</div>
                                                </div>

                                                <!-- Correo -->
                                                <div class="mb-3">
                                                    <label for="correo" class="form-label">Correo electrónico *</label>
                                                    <input type="email" class="form-control" id="correo" name="correo" 
                                                           value="<%= usuario.getCorreo() %>" required
                                                           onblur="validarCorreoExistente(this.value)">
                                                    <div id="errorCorreo" class="text-danger small mt-1 d-none"></div>
                                                    <div id="loadingCorreo" class="text-info small mt-1 d-none">⏳ Verificando...</div>
                                                </div>

                                                <!-- Fecha de nacimiento -->
                                                <div class="mb-3">
                                                    <label for="fechaNacimiento" class="form-label">Fecha de nacimiento</label>
                                                    <input type="date" class="form-control" id="fechaNacimiento" name="fechaNacimiento" 
                                                           value="<%= usuario.getFechaNacimiento() != null ? usuario.getFechaNacimiento().toString() : "" %>">
                                                    <div id="errorFecha" class="text-danger small mt-1 d-none"></div>
                                                </div>

                                                <!-- Contraseña (opcional) -->
                                                <div class="mb-3">
                                                    <label for="password" class="form-label">Nueva contraseña</label>
                                                    <input type="password" class="form-control" id="password" name="password">
                                                    <div class="form-text">Dejar vacío para mantener la contraseña actual.</div>
                                                    <div id="errorPassword" class="text-danger small mt-1 d-none"></div>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                                            <button type="submit" class="btn btn-primary" id="btnGuardarPerfil" disabled>
                                                💾 Guardar Cambios
                                            </button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Préstamos activos -->
                    <div class="card shadow-sm mt-4">
                        <div class="card-header bg-dark text-white">
                            <h5 class="mb-0">Mis Préstamos Activos</h5>
                        </div>
                        <div class="card-body">
                            <div id="prestamosActivos">
                                <% 
                                    // Filtrar solo préstamos activos
                                    java.util.List<Prestamo> prestamosActivos = new java.util.ArrayList<>();
                                    for (Prestamo p : prestamosUsuario) {
                                        if ("activo".equals(p.getEstado())) {
                                            prestamosActivos.add(p);
                                        }
                                    }
                                %>

                                <% if (prestamosActivos.isEmpty()) { %>
                                    <p class="text-muted text-center py-3">No tienes préstamos activos en este momento.</p>
                                <% } else { %>
                                    <div class="row">
                                        <% for (Prestamo prestamo : prestamosActivos) { 
                                            // Buscar el libro correspondiente al préstamo
                                            Libro libroPrestamo = null;
                                            for (Libro libro : todosLibros) {
                                                if (libro.getId() == prestamo.getIdLibro()) {
                                                    libroPrestamo = libro;
                                                    break;
                                                }
                                            }
                                        %>
                                        <% if (libroPrestamo != null) { %>
                                        <div class="col-md-6 mb-3">
                                            <div class="card border-success">
                                                <div class="card-body">
                                                    <h6 class="card-title text-success"><%= libroPrestamo.getTitulo() %></h6>
                                                    <p class="card-text mb-1">
                                                        <small><strong>Autor:</strong> <%= libroPrestamo.getAutor() %></small>
                                                    </p>
                                                    <p class="card-text mb-1">
                                                        <small><strong>Fecha préstamo:</strong> 
                                                            <%= prestamo.getFechaPrestamo() != null ? 
                                                                new java.text.SimpleDateFormat("dd/MM/yyyy").format(prestamo.getFechaPrestamo()) : "N/A" %>
                                                        </small>
                                                    </p>
                                                    <p class="card-text mb-1">
                                                        <small><strong>Devolución estimada:</strong> 
                                                            <%= prestamo.getFechaDevolucionEstimada() != null ? 
                                                                new java.text.SimpleDateFormat("dd/MM/yyyy").format(prestamo.getFechaDevolucionEstimada()) : "N/A" %>
                                                        </small>
                                                    </p>
                                                    <p class="card-text mb-0">
                                                        <span class="badge bg-success">Activo</span>
                                                        <% if (prestamo.estaAtrasado()) { %>
                                                        <span class="badge bg-danger ms-1">⚠️ Atrasado</span>
                                                        <% } %>
                                                    </p>
                                                </div>
                                            </div>
                                        </div>
                                        <% } %>
                                        <% } %>
                                    </div>
                                <% } %>
                            </div>
                        </div>
                    </div>

                    <!-- Historial de publicaciones -->
                    <div class="card shadow-sm mt-4">
                        <div class="card-header bg-dark text-white">
                            <h5 class="mb-0">Mis Publicaciones Recientes</h5>
                        </div>
                        <div class="card-body">
                            <div id="publicacionesUsuario">
                                <% if (publicaciones.isEmpty()) { %>
                                <p class="text-muted text-center py-3">Aún no has realizado publicaciones.</p>
                                <% } else { %>
                                <div class="row">
                                    <% for (Publicacion pub : publicaciones) { %>
                                    <div class="col-md-6 mb-4">
                                        <div class="card h-100">
                                            <% if (pub.getImagenUrl() != null && !pub.getImagenUrl().isEmpty()) { %>
                                            <img src="${pageContext.request.contextPath}/uploads/<%= pub.getImagenUrl()%>" 
                                                 class="card-img-top" alt="Imagen de publicación" 
                                                 style="height: 200px; object-fit: cover;">
                                            <% } %>
                                            <div class="card-body">
                                                <h6 class="card-title"><%= pub.getTitulo() %></h6>
                                                <p class="card-text">
                                                    <%= pub.getContenido().length() > 100 ? 
                                                        pub.getContenido().substring(0, 100) + "..." : 
                                                        pub.getContenido() %>
                                                </p>
                                                <small class="text-muted">
                                                    Publicado el: <%= pub.getFechaPublicacion() != null ? 
                                                                new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(pub.getFechaPublicacion()) : "Fecha no disponible" %>
                                                </small>
                                            </div>
                                            <div class="card-footer bg-transparent">
                                                <div class="btn-group w-100" role="group">
                                                    <button type="button" class="btn btn-outline-primary btn-sm" 
                                                            onclick="verPublicacionCompleta(<%= pub.getId() %>)">
                                                        Ver completo
                                                    </button>
                                                    <button type="button" class="btn btn-outline-danger btn-sm" 
                                                            onclick="eliminarPublicacion(<%= pub.getId() %>)">
                                                        Eliminar
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <% } %>
                                </div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>

        <!-- Modal para ver publicación completa -->
        <div class="modal fade" id="modalPublicacionCompleta" tabindex="-1" aria-labelledby="modalPublicacionCompletaLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header bg-dark text-white">
                        <h5 class="modal-title text-white" id="modalPublicacionCompletaLabel">Publicación Completa</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body" id="contenidoPublicacionCompleta">
                        <!-- Aquí se cargará el contenido dinámicamente -->
                    </div>
                </div>
            </div>
        </div>

        <script src="${pageContext.request.contextPath}/node_modules/bootstrap/dist/js/bootstrap.bundle.js"></script>
        <script>
            // Función para ver publicación completa
            function verPublicacionCompleta(idPublicacion) {
                fetch('${pageContext.request.contextPath}/obtener-publicacion?id=' + idPublicacion)
                    .then(response => {
                        if (!response.ok) {
                            throw new Error('Error en la respuesta del servidor');
                        }
                        return response.json();
                    })
                    .then(data => {
                        const modalBody = document.getElementById('contenidoPublicacionCompleta');

                        if (!data || data.error) {
                            modalBody.innerHTML = '<div class="alert alert-danger">Error al cargar la publicación</div>';
                        } else {
                            let contenidoHTML = '';

                            // Título
                            if (data.titulo) {
                                contenidoHTML += '<h4 class="mb-3">' + escapeHtml(data.titulo) + '</h4>';
                            }

                            // Imagen
                            if (data.imagenUrl && data.imagenUrl !== 'null' && data.imagenUrl !== '') {
                                contenidoHTML += '<img src="${pageContext.request.contextPath}/uploads/' + escapeHtml(data.imagenUrl) + '" class="img-fluid mb-3 rounded" alt="Imagen de publicación" style="max-height: 400px; object-fit: cover;">';
                            }

                            // Contenido
                            if (data.contenido) {
                                contenidoHTML += '<div class="mb-3"><p style="white-space: pre-line;">' + escapeHtml(data.contenido) + '</p></div>';
                            }

                            // Fecha
                            if (data.fechaPublicacion) {
                                contenidoHTML += '<small class="text-muted">Publicado el: ' + escapeHtml(data.fechaPublicacion) + '</small>';
                            }

                            modalBody.innerHTML = contenidoHTML;
                        }

                        const modal = new bootstrap.Modal(document.getElementById('modalPublicacionCompleta'));
                        modal.show();
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        const modalBody = document.getElementById('contenidoPublicacionCompleta');
                        modalBody.innerHTML = '<div class="alert alert-danger">Error al cargar la publicación: ' + error.message + '</div>';

                        const modal = new bootstrap.Modal(document.getElementById('modalPublicacionCompleta'));
                        modal.show();
                    });
            }

            // Función auxiliar para escapar HTML (seguridad)
            function escapeHtml(text) {
                if (!text) return '';
                const div = document.createElement('div');
                div.textContent = text;
                return div.innerHTML;
            }

            // Función para eliminar publicación
            function eliminarPublicacion(idPublicacion) {
                if (confirm('¿Estás seguro de que quieres eliminar esta publicación?')) {
                    fetch('${pageContext.request.contextPath}/eliminar-publicacion?id=' + idPublicacion, {
                        method: 'DELETE'
                    })
                    .then(response => {
                        if (response.ok) {
                            alert('Publicación eliminada correctamente');
                            location.reload();
                        } else {
                            alert('Error al eliminar la publicación');
                        }
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        alert('Error al eliminar la publicación');
                    });
                }
            }
            
            // Variables para controlar validaciones
            let usuarioValido = true;
            let correoValido = true;

            // Función para previsualizar foto de perfil
            function previsualizarFotoPerfil(event) {
                const file = event.target.files[0];
                const preview = document.getElementById('previewPerfil');
                const errorFoto = document.getElementById('errorFoto');

                if (!file) return;

                // Validar tipo de archivo
                const tiposPermitidos = ['image/jpeg', 'image/png', 'image/gif'];
                if (!tiposPermitidos.includes(file.type)) {
                    mostrarError('errorFoto', 'Solo se permiten imágenes JPG, PNG o GIF');
                    event.target.value = '';
                    return;
                }

                // Validar tamaño (2MB máximo)
                if (file.size > 2 * 1024 * 1024) {
                    mostrarError('errorFoto', 'La imagen no debe pesar más de 2MB');
                    event.target.value = '';
                    return;
                }

                // Limpiar errores y mostrar preview
                ocultarError('errorFoto');

                const reader = new FileReader();
                reader.onload = function(e) {
                    preview.src = e.target.result;
                };
                reader.readAsDataURL(file);
            }

            // Función para validar usuario existente
            function validarUsuarioExistente(usuario) {
                const errorUsuario = document.getElementById('errorUsuario');
                const loadingUsuario = document.getElementById('loadingUsuario');
                const usuarioActual = '<%= usuario.getNombreUsuario() %>';

                // Si no cambió el usuario, es válido
                if (usuario === usuarioActual) {
                    usuarioValido = true;
                    ocultarError('errorUsuario');
                    actualizarBotonGuardar();
                    return;
                }

                // Validar longitud mínima
                if (usuario.length < 3) {
                    mostrarError('errorUsuario', 'El usuario debe tener al menos 3 caracteres');
                    usuarioValido = false;
                    actualizarBotonGuardar();
                    return;
                }

                // Mostrar loading
                loadingUsuario.classList.remove('d-none');
                ocultarError('errorUsuario');

                // Verificar si el usuario existe
                fetch('${pageContext.request.contextPath}/verificar-usuario?usuario=' + encodeURIComponent(usuario))
                    .then(response => response.json())
                    .then(data => {
                        loadingUsuario.classList.add('d-none');

                        if (data.existe) {
                            mostrarError('errorUsuario', '❌ Este nombre de usuario ya está en uso');
                            usuarioValido = false;
                        } else {
                            ocultarError('errorUsuario');
                            usuarioValido = true;
                        }
                        actualizarBotonGuardar();
                    })
                    .catch(error => {
                        loadingUsuario.classList.add('d-none');
                        console.error('Error al verificar usuario:', error);
                        usuarioValido = true; // Por seguridad permitimos continuar
                        actualizarBotonGuardar();
                    });
            }

            // Función para validar correo existente
            function validarCorreoExistente(correo) {
                const errorCorreo = document.getElementById('errorCorreo');
                const loadingCorreo = document.getElementById('loadingCorreo');
                const correoActual = '<%= usuario.getCorreo() %>';

                // Si no cambió el correo, es válido
                if (correo === correoActual) {
                    correoValido = true;
                    ocultarError('errorCorreo');
                    actualizarBotonGuardar();
                    return;
                }

                // Validar formato de correo
                const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if (!regex.test(correo)) {
                    mostrarError('errorCorreo', '❌ Formato de correo inválido');
                    correoValido = false;
                    actualizarBotonGuardar();
                    return;
                }

                // Mostrar loading
                loadingCorreo.classList.remove('d-none');
                ocultarError('errorCorreo');

                // Verificar si el correo existe
                fetch('${pageContext.request.contextPath}/verificar-correo?correo=' + encodeURIComponent(correo))
                    .then(response => response.json())
                    .then(data => {
                        loadingCorreo.classList.add('d-none');

                        if (data.existe) {
                            mostrarError('errorCorreo', '❌ Este correo electrónico ya está registrado');
                            correoValido = false;
                        } else {
                            ocultarError('errorCorreo');
                            correoValido = true;
                        }
                        actualizarBotonGuardar();
                    })
                    .catch(error => {
                        loadingCorreo.classList.add('d-none');
                        console.error('Error al verificar correo:', error);
                        correoValido = true; // Por seguridad permitimos continuar
                        actualizarBotonGuardar();
                    });
            }

            // Función para actualizar estado del botón guardar
            function actualizarBotonGuardar() {
                const btnGuardar = document.getElementById('btnGuardarPerfil');
                btnGuardar.disabled = !(usuarioValido && correoValido);
            }

            // Funciones auxiliares para mostrar/ocultar errores
            function mostrarError(elementId, mensaje) {
                const elemento = document.getElementById(elementId);
                elemento.textContent = mensaje;
                elemento.classList.remove('d-none');
            }

            function ocultarError(elementId) {
                const elemento = document.getElementById(elementId);
                elemento.classList.add('d-none');
            }

            // Validación del formulario al enviar
            document.getElementById('formEditarPerfil').addEventListener('submit', function(e) {
                const nombre = document.getElementById('nombre').value.trim();
                const usuario = document.getElementById('usuario').value.trim();
                const correo = document.getElementById('correo').value.trim();
                const password = document.getElementById('password').value;
                const fotoPerfil = document.getElementById('fotoPerfil').files[0];

                // Validaciones básicas
                if (!nombre || !usuario || !correo) {
                    e.preventDefault();
                    mostrarMensaje('Por favor, completa todos los campos obligatorios', 'danger');
                    return;
                }

                // Validar longitud de usuario
                if (usuario.length < 3) {
                    e.preventDefault();
                    mostrarError('errorUsuario', 'El usuario debe tener al menos 3 caracteres');
                    return;
                }

                // Validar formato de correo
                const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if (!regex.test(correo)) {
                    e.preventDefault();
                    mostrarError('errorCorreo', 'Formato de correo inválido');
                    return;
                }

                // Validar contraseña si se ingresó
                if (password && password.length < 6) {
                    e.preventDefault();
                    mostrarError('errorPassword', 'La contraseña debe tener al menos 6 caracteres');
                    return;
                }

                // Validar imagen si se seleccionó
                if (fotoPerfil) {
                    const tiposPermitidos = ['image/jpeg', 'image/png', 'image/gif'];
                    if (!tiposPermitidos.includes(fotoPerfil.type)) {
                        e.preventDefault();
                        mostrarError('errorFoto', 'Solo se permiten imágenes JPG, PNG o GIF');
                        return;
                    }

                    if (fotoPerfil.size > 2 * 1024 * 1024) {
                        e.preventDefault();
                        mostrarError('errorFoto', 'La imagen no debe pesar más de 2MB');
                        return;
                    }
                }

                // Si hay errores de duplicados, prevenir envío
                if (!usuarioValido || !correoValido) {
                    e.preventDefault();
                    mostrarMensaje('Por favor, corrige los errores antes de guardar', 'danger');
                    return;
                }
            });

            // Función para mostrar mensajes
            function mostrarMensaje(mensaje, tipo) {
                const mensajeDiv = document.getElementById('mensajeEdicion');
                mensajeDiv.textContent = mensaje;
                mensajeDiv.className = `alert alert-${tipo}`;
                mensajeDiv.classList.remove('d-none');

                // Auto-ocultar después de 5 segundos
                setTimeout(() => {
                    mensajeDiv.classList.add('d-none');
                }, 5000);
            }

            // Resetear validaciones cuando se abre el modal
            document.getElementById('modalEditarPerfil').addEventListener('show.bs.modal', function() {
                usuarioValido = true;
                correoValido = true;
                document.getElementById('btnGuardarPerfil').disabled = false;
                document.getElementById('mensajeEdicion').classList.add('d-none');
            });
            
            
            
        </script>
    </body>
</html>l>