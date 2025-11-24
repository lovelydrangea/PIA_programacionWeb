<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="modelos.Usuario" %>
<%@ page import="modelos.Publicacion" %>
<%@ page import="DAO.PublicacionDAO" %>
<%@ page import="DAO.UsuarioDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
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
    
    Integer usuarioId = usuario.getIdUsuario();
    
    // ✅ OBTENER TODAS LAS PUBLICACIONES (FEED)
    PublicacionDAO publicacionDAO = new PublicacionDAO();
    List<Publicacion> publicacionesFeed = publicacionDAO.obtenerTodasPublicaciones();
    
    // ✅ OBTENER DATOS DE USUARIOS PARA MOSTRAR INFORMACIÓN
    UsuarioDAO usuarioDAO = new UsuarioDAO();
    
    // Formateador de fecha
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy 'a las' HH:mm");
    
    // ✅ PROCESAR MENSAJES DE PUBLICACIONES (AGREGADO)
    String mensaje = request.getParameter("mensaje");
    String error = request.getParameter("error");
    String publicacionParam = request.getParameter("publicacion");
    
    // Si viene mensaje de publicación exitosa
    if ("exitoso".equals(publicacionParam)) {
        mensaje = "✅ Publicación creada exitosamente";
    }
    
    // Si viene error de publicación
    if (error != null) {
        switch (error) {
            case "campos_vacios":
                error = "El título y contenido son obligatorios";
                break;
            case "tipo_archivo_invalido":
                error = "Solo se permiten imágenes JPG, PNG o GIF";
                break;
            case "archivo_demasiado_grande":
                error = "La imagen es demasiado grande. Máximo 3MB";
                break;
            case "publicacion_fallida":
                error = "Error al crear la publicacion";
                break;
            case "general":
                error = "Error general al procesar la publicación";
                break;
        }
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="../node_modules/bootstrap/dist/css/bootstrap.css"/>
        <link rel="stylesheet" href="../Estilos/estilosPerfil.css">
        <link rel="stylesheet" href="../Estilos/estilosfeed.css"/>
        <link href="https://fonts.googleapis.com/css?family=Oranienbaum" rel="stylesheet">
        <title>Mi Feed - Bibliotequero</title>

    </head>
    <body>
        <!-- Navbar -->
        <nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top">
            <div class="container-fluid">
                <a class="navbar-brand d-flex align-items-center" href="CatalogoPaginaIncio.jsp">
                    <img src="../Logo/Logito.png" alt="Logo Bibliotequero" width="40" height="40" class="me-2">
                    <span>Bibliotequero</span>
                </a>

                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#menuBibliotequero" aria-controls="menuBibliotequero" aria-expanded="false" aria-label="Toggle navigation">
                    <span class="navbar-toggler-icon"></span>
                </button>

                <div class="collapse navbar-collapse" id="menuBibliotequero">
                    <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                        <li class="nav-item">
                            <a class="nav-link" href="CatalogoPaginaIncio.jsp">Catálogo</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link active" href="feed.jsp">Mi Feed</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="#" data-bs-toggle="modal" data-bs-target="#modalPublicacion">Crear Publicación</a>
                        </li>
                    </ul>

                    <!-- Usuario con sesión -->
                    <div class="dropdown">
                        <a href="#" class="d-flex align-items-center text-white text-decoration-none dropdown-toggle" 
                           id="dropdownUser1" data-bs-toggle="dropdown" aria-expanded="false">
                            <img src="<%= fotoPerfil %>" 
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

        <!-- Contenido principal del Feed -->
        <main class="container" style="margin-top: 100px;">
            <div class="row justify-content-center">
                <div class="col-lg-8 col-md-10">
                    <!-- Header del Feed -->
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h1 class="mb-0 text-dark">Mi Feed</h1>
                        <div class="d-flex align-items-center gap-3">
                            <span class="badge badge-cantidad fs-6">
                                <%= publicacionesFeed.size() %> publicaciones
                            </span>
                            <!-- Botón para crear publicación en el feed -->
                        </div>
                    </div>

                    <!-- Mostrar mensajes (AGREGADO) -->
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

                    <!-- Campo oculto con el ID del usuario para usar en JavaScript -->
                    <input type="hidden" id="usuarioId" value="<%= usuarioId %>">

                    <!-- Lista de Publicaciones -->
                    <div id="feedPublicaciones">
                        <% if (publicacionesFeed.isEmpty()) { %>
                            <div class="card sin-publicaciones">
                                <div class="card-body text-center py-5">
                                    <h4 class="text-muted mb-3">📝 No hay publicaciones aún</h4>
                                    <p class="text-muted mb-4">Sé el primero en compartir algo con la comunidad de Bibliotequero</p>
                                    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#modalPublicacion">
                                        📢 Crear primera publicación
                                    </button>
                                </div>
                            </div>
                        <% } else { %>
                            <% for (Publicacion publicacion : publicacionesFeed) { 
                                // Obtener información del autor
                                Usuario autor = usuarioDAO.obtenerUsuarioPorId(publicacion.getIdUsuario());
                                String nombreAutor = autor != null ? autor.getNombre() : "Usuario desconocido";
                                String usuarioAutor = autor != null ? autor.getNombreUsuario() : "desconocido";
                                String fotoAutor = "https://via.placeholder.com/50";
                                if (autor != null && autor.getUrlFoto() != null && !autor.getUrlFoto().trim().isEmpty()) {
                                    fotoAutor = request.getContextPath() + "/uploads/" + autor.getUrlFoto();
                                }
                                
                                // Formatear fecha
                                String fechaFormateada = "Fecha no disponible";
                                if (publicacion.getFechaPublicacion() != null) {
                                    fechaFormateada = sdf.format(publicacion.getFechaPublicacion());
                                }
                            %>
                                <div class="card publicacion-card mb-4" id="publicacion-<%= publicacion.getId() %>">
                                    <!-- Header con información del usuario -->
                                    <div class="card-header bg-light d-flex align-items-center">
                                        <img src="<%= fotoAutor %>" 
                                             alt="Foto de <%= nombreAutor %>" 
                                             class="rounded-circle me-3"
                                             width="50" height="50"
                                             onerror="this.src='https://via.placeholder.com/50'">
                                        <div class="flex-grow-1">
                                            <h6 class="mb-0 fw-bold"><%= nombreAutor %></h6>
                                            <small class="text-muted">@<%= usuarioAutor %></small>
                                        </div>
                                        <small class="text-muted">
                                            📅 <%= fechaFormateada %>
                                        </small>
                                    </div>

                                    <!-- Contenido de la publicación -->
                                    <div class="card-body">
                                        <% if (publicacion.getTitulo() != null && !publicacion.getTitulo().trim().isEmpty()) { %>
                                            <h5 class="card-title"><%= publicacion.getTitulo() %></h5>
                                        <% } %>
                                        
                                        <div class="card-text">
                                            <%= publicacion.getContenido() %>
                                        </div>
                                        
                                        <% if (publicacion.getImagenUrl() != null && !publicacion.getImagenUrl().trim().isEmpty()) { %>
                                            <div class="mt-3">
                                                <img src="${pageContext.request.contextPath}/uploads/<%= publicacion.getImagenUrl() %>" 
                                                     class="img-fluid rounded" 
                                                     alt="Imagen de la publicación"
                                                     onerror="this.style.display='none'">
                                            </div>
                                        <% } %>
                                    </div>

                                    <!-- Acciones de la publicación -->
                                    <div class="card-footer bg-white">
                                        <div class="d-flex justify-content-between align-items-center">
                                            <div>
                                            </div>
                                            <% if (publicacion.getIdUsuario() == usuario.getIdUsuario()) { %>
                                                <div>
                                                    <button class="btn btn-outline-danger btn-sm" 
                                                            onclick="eliminarPublicacion(<%= publicacion.getId() %>)">
                                                        🗑️ Eliminar
                                                    </button>
                                                </div>
                                            <% } %>
                                        </div>
                                    </div>
                                </div>
                            <% } %>
                        <% } %>
                    </div>
                </div>
            </div>
        </main>

        <!-- Modal para crear publicaciones (MEJORADO) -->
        <div class="modal fade" id="modalPublicacion" tabindex="-1" aria-labelledby="modalPublicacionLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header bg-primary text-white">
                        <h5 class="modal-title">📝 Crear Nueva Publicación</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <form id="formPublicacion" action="${pageContext.request.contextPath}/publicacion" method="post" enctype="multipart/form-data">
                            <input type="hidden" name="autorId" value="<%= usuarioId %>">

                            <div class="mb-3">
                                <label for="titulo" class="form-label">Título de la Publicación *</label>
                                <input type="text" class="form-control" id="titulo" name="titulo" required 
                                       placeholder="Ej: Mi experiencia leyendo 'Cien años de soledad'">
                            </div>

                            <div class="mb-3">
                                <label for="contenido" class="form-label">Contenido *</label>
                                <textarea class="form-control" id="contenido" name="contenido" rows="5" required
                                          placeholder="Comparte tus pensamientos, reseña o experiencia..."></textarea>
                                <div class="form-text">Mínimo 10 caracteres</div>
                            </div>

                            <div class="mb-3">
                                <label for="imagen" class="form-label">Imagen (opcional)</label>
                                <input class="form-control" type="file" id="imagen" name="imagen" accept="image/jpeg,image/png,image/gif" onchange="previsualizarImagen(event)">

                                <!-- Preview de la imagen -->
                                <div class="mt-3 text-center">
                                    <img id="previewImagen" src="" alt="Vista previa de la imagen" 
                                         class="img-thumbnail d-none" style="max-height: 200px; max-width: 100%;">
                                </div>

                                <div class="form-text">
                                    Formatos permitidos: JPG, PNG, GIF. Máximo 3MB.
                                </div>
                            </div>

                            <div class="alert alert-info">
                                <small>📌 <strong>Tip:</strong> Comparte tus pensamientos honestos sobre los libros que has leído. 
                                Tu experiencia puede ayudar a otros lectores.</small>
                            </div>

                            <div class="text-end">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                                <button type="submit" class="btn btn-primary">Publicar</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <!-- Modal para ver publicación completa -->
        <div class="modal fade" id="modalPublicacionCompleta" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header bg-dark text-white">
                        <h5 class="modal-title">Publicación Completa</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body" id="contenidoPublicacionCompleta">
                        <!-- Contenido dinámico -->
                    </div>
                </div>
            </div>
        </div>

        <script src="../node_modules/bootstrap/dist/js/bootstrap.bundle.js"></script>
        <script>
            
            
            
            // Función para previsualizar imagen en el formulario de publicaciones
                function previsualizarImagen(event) {
                    const file = event.target.files[0];
                    if (!file) return;

                    const reader = new FileReader();
                    reader.onload = function(e) {
                        const preview = document.getElementById('previewImagen');
                        if (preview) {
                            preview.src = e.target.result;
                            preview.classList.remove('d-none');
                        }
                    };
                    reader.readAsDataURL(file);
                }

            // Función para mostrar preview de la foto y guardar en localStorage
            function previuWalafoto(event) {
                const file = event.target.files[0];
                if (!file)
                    return; // Si no hay archivo, salimos

                const reader = new FileReader();
                reader.onload = function () {
                    // Preview en el formulario
                    const preview = document.getElementById('preview');
                    if (preview) {
                        preview.src = reader.result;
                    }

                    // Guardar imagen en localStorage
                    localStorage.setItem("fotoPerfil", reader.result);

                    // Actualizar foto en navbar si existe
                    const fotoNavbar = document.getElementById('fotoNavbar');
                    if (fotoNavbar) {
                        fotoNavbar.src = reader.result;
                    }
                };
                reader.readAsDataURL(file);
            }

            // Al cargar la página, cargar foto guardada si existe
            document.addEventListener("DOMContentLoaded", () => {
                const fotoGuardada = localStorage.getItem("fotoPerfil");

                // Preview en formulario
                const preview = document.getElementById('preview');
                if (fotoGuardada && preview) {
                    preview.src = fotoGuardada;
                }

                // Foto en navbar
                const fotoNavbar = document.getElementById('fotoNavbar');
                if (fotoGuardada && fotoNavbar) {
                    fotoNavbar.src = fotoGuardada;
                }
            });

            const usuarioId = document.getElementById('usuarioId').value;

            // Validación del formulario de publicaciones (AGREGADO)
            document.getElementById('formPublicacion')?.addEventListener('submit', function (e) {
                const titulo = document.getElementById('titulo').value.trim();
                const contenido = document.getElementById('contenido').value.trim();
                
                // Validaciones básicas
                if (!titulo || !contenido) {
                    e.preventDefault();
                    alert('Por favor, completa el título y contenido de la publicación');
                    return;
                }
                
                if (titulo.length < 3) {
                    e.preventDefault();
                    alert('El título debe tener al menos 3 caracteres');
                    return;
                }
                
                if (contenido.length < 10) {
                    e.preventDefault();
                    alert('El contenido debe tener al menos 10 caracteres');
                    return;
                }
                
                // Validar imagen si se seleccionó
                const imagenInput = document.getElementById('imagen');
                if (imagenInput.files.length > 0) {
                    const file = imagenInput.files[0];
                    const maxSize = 3 * 1024 * 1024; // 3MB
                    
                    // Validar tamaño
                    if (file.size > maxSize) {
                        e.preventDefault();
                        alert('La imagen es demasiado grande. Máximo 3MB permitido.');
                        return;
                    }
                    
                    // Validar tipo de archivo
                    const allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
                    if (!allowedTypes.includes(file.type)) {
                        e.preventDefault();
                        alert('Solo se permiten imágenes JPG, PNG o GIF.');
                        return;
                    }
                }
            });

            // Función para manejar "Me gusta"
            function toggleMeGusta(idPublicacion) {
                const btn = document.querySelector(`#publicacion-${idPublicacion} .btn-outline-danger`);
                btn.classList.toggle('btn-outline-danger');
                btn.classList.toggle('btn-danger');
                
                // Aquí podrías hacer una petición AJAX para guardar el like
                console.log('Me gusta toggleado para publicación:', idPublicacion);
            }

            // Función para comentar
            function comentarPublicacion(idPublicacion) {
                const comentario = prompt('Escribe tu comentario:');
                if (comentario && comentario.trim() !== '') {
                    // Aquí podrías hacer una petición AJAX para guardar el comentario
                    console.log('Comentario para publicación', idPublicacion, ':', comentario);
                    alert('Comentario agregado (funcionalidad en desarrollo)');
                }
            }

            // Función para eliminar publicación
            function eliminarPublicacion(idPublicacion) {
                if (confirm('¿Estás seguro de que quieres eliminar esta publicación?')) {
                    // Aquí podrías hacer una petición AJAX para eliminar
                    fetch('${pageContext.request.contextPath}/eliminar-publicacion?id=' + idPublicacion, {
                        method: 'DELETE'
                    })
                    .then(response => {
                        if (response.ok) {
                            document.getElementById('publicacion-' + idPublicacion).remove();
                            actualizarContadorPublicaciones();
                            alert('Publicación eliminada correctamente');
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

            // Función para editar publicación
            function editarPublicacion(idPublicacion) {
                // Aquí podrías implementar la edición
                alert('Funcionalidad de edición en desarrollo para publicación: ' + idPublicacion);
            }

            // Función para actualizar el contador de publicaciones
            function actualizarContadorPublicaciones() {
                const publicaciones = document.querySelectorAll('.publicacion-card');
                const contador = document.querySelector('.badge');
                if (contador) {
                    contador.textContent = publicaciones.length + ' publicaciones';
                }
                
                // Si no hay publicaciones, mostrar el mensaje de "no hay publicaciones"
                if (publicaciones.length === 0) {
                    const feedPublicaciones = document.getElementById('feedPublicaciones');
                    feedPublicaciones.innerHTML = `
                        <div class="card sin-publicaciones">
                            <div class="card-body text-center py-5">
                                <h4 class="text-muted mb-3">📝 No hay publicaciones aún</h4>
                                <p class="text-muted mb-4">Sé el primero en compartir algo con la comunidad de Bibliotequero</p>
                                <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#modalPublicacion">
                                    📢 Crear primera publicación
                                </button>
                            </div>
                        </div>
                    `;
                }
            }

            // Cerrar modal después de publicación exitosa si hay parámetro de éxito
            window.addEventListener('load', function() {
                const urlParams = new URLSearchParams(window.location.search);
                if (urlParams.get('publicacion') === 'exitoso') {
                    const modal = bootstrap.Modal.getInstance(document.getElementById('modalPublicacion'));
                    if (modal) {
                        modal.hide();
                    }
                }
            });
        </script>
    </body>
</html>