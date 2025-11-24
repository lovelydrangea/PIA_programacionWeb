<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="modelos.Usuario" %>
<%@ page import="modelos.Libro" %>
<%@ page import="modelos.Prestamo" %>
<%@ page import="DAO.LibroDAO" %>
<%@ page import="DAO.UsuarioDAO" %>
<%@ page import="DAO.PrestamoDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%
    // ✅ EL AUTHGUARD YA SE ENCARGA DE LA SEGURIDAD
    // Solo obtenemos el usuario de la sesión para mostrar datos
    HttpSession userSession = request.getSession(false);
    Usuario usuario = (Usuario) userSession.getAttribute("usuario");
    
    // Variables para la vista
    String nombreUsuario = usuario.getNombreUsuario();
    String fotoPerfil = "https://via.placeholder.com/30";
    if (usuario.getUrlFoto() != null && !usuario.getUrlFoto().trim().isEmpty()) {
        fotoPerfil = request.getContextPath() + "/uploads/" + usuario.getUrlFoto();
    }
    Integer usuarioId = usuario.getIdUsuario();
    
    // ✅ VERIFICAR SI ES ADMINISTRADOR
    UsuarioDAO usuarioDAO = new UsuarioDAO();
    boolean esAdmin = usuarioDAO.esAdministrador(usuarioId);
    
    // ✅ OBTENER RESULTADOS DE BÚSQUEDA SI EXISTEN (DEBE ESTAR AL INICIO)
    List<Libro> librosEncontrados = (List<Libro>) request.getAttribute("librosEncontrados");
    String terminoBusqueda = (String) request.getAttribute("terminoBusqueda");
    Integer totalResultados = (Integer) request.getAttribute("totalResultados");
    Boolean esBusqueda = (Boolean) request.getAttribute("esBusqueda");
    if (esBusqueda == null) esBusqueda = false;
    
    // ✅ PARÁMETROS DE PAGINACIÓN
    int librosPorPagina = 10;
    int paginaActual = 1;
    int totalLibros = 0;
    int totalPaginas = 0;
    
    // Obtener página actual del parámetro
    String paginaParam = request.getParameter("pagina");
    if (paginaParam != null && !paginaParam.trim().isEmpty()) {
        try {
            paginaActual = Integer.parseInt(paginaParam);
            if (paginaActual < 1) paginaActual = 1;
        } catch (NumberFormatException e) {
            paginaActual = 1;
        }
    }
    
    // ✅ OBTENER LIBROS DEL CATÁLOGO CON PAGINACIÓN
    LibroDAO libroDAO = new LibroDAO();
    List<Libro> libros = new ArrayList<>();
    
    // ✅ OBTENER PRÉSTAMOS PARA ADMIN
    List<Prestamo> prestamosPendientes = new ArrayList<>();
    List<Prestamo> prestamosActivos = new ArrayList<>();
    
    // ✅ INICIALIZAR VARIABLES DE ESTADÍSTICAS
    int prestamosAtrasados = 0;
    int prestamosActivosNUM = 0;
    int librosPorReponer = 0;
    
    // ✅ ACTUALIZAR PRÉSTAMOS ATRASADOS SOLO PARA ADMIN
    if (esAdmin) {
        PrestamoDAO prestamoDAO = new PrestamoDAO();
        prestamoDAO.actualizarPrestamosAtrasados();
        
        List<Prestamo> todosPrestamos = prestamoDAO.obtenerTodosPrestamos();
        
        // Reemplazar streams por bucles tradicionales para compatibilidad con JSP
        for (Prestamo p : todosPrestamos) {
            if ("pendiente".equals(p.getEstado())) {
                prestamosPendientes.add(p);
            }
            if ("activo".equals(p.getEstado())) {
                prestamosActivos.add(p);
            }
        }
        
        // Actualizar las variables con los valores reales
        prestamosAtrasados = prestamoDAO.contarPrestamosAtrasados();
        prestamosActivosNUM = prestamoDAO.contarPrestamosActivos();
        if (prestamosActivosNUM > 0 || prestamosAtrasados > 0) {
            librosPorReponer = (prestamosActivosNUM + prestamosAtrasados);
        } else {
            librosPorReponer = 0;
        }
    }
 
    int totalUsuarios = usuarioDAO.contarTotalUsuarios(); //se elimina al admin
    
    // ✅ OBTENER PARÁMETROS PARA MENSAJES
    String mensaje = request.getParameter("mensaje");
    String error = request.getParameter("error");
    
    // ✅ AGREGAR ESTO: PROCESAR MENSAJES DE PUBLICACIONES
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
    
    // ✅ OBTENER LIBROS PAGINADOS SEGÚN BÚSQUEDA O CATÁLOGO COMPLETO - CORREGIDO
    if (esBusqueda && terminoBusqueda != null && !terminoBusqueda.isEmpty()) {
        // Para búsquedas, usar SIEMPRE los libros del servlet
        Integer paginaActualBusqueda = (Integer) request.getAttribute("paginaActual");
        Integer totalPaginasBusqueda = (Integer) request.getAttribute("totalPaginas");
        Integer totalLibrosBusqueda = (Integer) request.getAttribute("totalLibros");
        
        // Usar los datos del servlet si están disponibles
        if (paginaActualBusqueda != null) paginaActual = paginaActualBusqueda;
        if (totalPaginasBusqueda != null) totalPaginas = totalPaginasBusqueda;
        if (totalLibrosBusqueda != null) {
            totalLibros = totalLibrosBusqueda;
        }
        
        // ✅ CRÍTICO: Para búsquedas, usar SIEMPRE librosEncontrados
        if (librosEncontrados != null) {
            libros = librosEncontrados;
        } else {
            // Fallback: si no hay librosEncontrados, obtener del DAO
            libros = libroDAO.buscarLibrosPaginados(terminoBusqueda, paginaActual, librosPorPagina);
            if (totalLibrosBusqueda == null) {
                totalLibros = libroDAO.contarLibrosBusqueda(terminoBusqueda);
            }
        }
        
    } else {
        // Catálogo completo paginado
        libros = libroDAO.obtenerLibrosPaginados(paginaActual, librosPorPagina);
        totalLibros = libroDAO.contarTotalLibros();
        
        // Calcular total de páginas
        totalPaginas = (int) Math.ceil((double) totalLibros / librosPorPagina);
        if (totalPaginas < 1) totalPaginas = 1;
    }
    
    // Ajustar página actual si es mayor al total (para ambos casos)
    if (paginaActual > totalPaginas) {
        paginaActual = totalPaginas;
    }
    
    // ✅ DETERMINAR QUÉ LIBROS MOSTRAR - USAR SIEMPRE LA LISTA 'libros'
    // Ahora 'libros' contiene los libros correctos tanto para búsqueda como para catálogo
    List<Libro> librosAMostrar = libros;
    
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/node_modules/bootstrap/dist/css/bootstrap.css"/>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/Estilos/estilosCatalogo.css">
        <link href="https://fonts.googleapis.com/css?family=Oranienbaum" rel="stylesheet">
        <title>Bibliotequero - Catálogo</title>
        <script>
            // EL MISMO SCRIPT ANTI-RETROCESO QUE EN CATÁLOGO
            window.addEventListener('load', function () {
                checkSessionValidity();
            });
            window.addEventListener('pageshow', function (event) {
                if (event.persisted) {
                    checkSessionValidity();
                }
            });
            function checkSessionValidity() {
                fetch('${pageContext.request.contextPath}/check-session', {
                    method: 'GET',
                    headers: {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'},
                    credentials: 'include'
                })
                        .then(response => {
                            if (!response.ok)
                                throw new Error('Sesión inválida');
                            return response.json();
                        })
                        .then(data => {
                            if (!data.valid)
                                throw new Error('Sesión no válida');
                        })
                        .catch(error => {
                            window.location.replace('${pageContext.request.contextPath}/pantallas/Inicio-Sesion.jsp?session=expired');
                        });
            }
        </script>
    </head>
    <body>
        <!-- Navbar superior -->
        <nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top">
            <div class="container-fluid">
                <!-- Logo + nombre -->
                <a class="navbar-brand d-flex align-items-center" href="${pageContext.request.contextPath}/pantallas/CatalogoPaginaIncio.jsp">
                    <img src="${pageContext.request.contextPath}/Logo/Logito.png" alt="Logo Bibliotequero" width="40" height="40" class="me-2">
                    <span>Bibliotequero</span>
                </a>
                <!-- Boton responsive -->
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#menuBibliotequero" aria-controls="menuBibliotequero" aria-expanded="false" aria-label="Toggle navigation">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <!-- Menu -->
                <div class="collapse navbar-collapse" id="menuBibliotequero">
                    <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                        <li class="nav-item">
                            <a class="nav-link active" aria-current="page" href="${pageContext.request.contextPath}/pantallas/CatalogoPaginaIncio.jsp">Catálogo</a>
                        </li>
                        <% if (!esAdmin) { %>
                        <li class="nav-item">
                            <a class="nav-link" href="${pageContext.request.contextPath}/pantallas/feed.jsp">Mi Feed</a>
                        </li>
                        <% } %>
                        <% if (!esAdmin) { %>
                        <li class="nav-item">
                            <a class="nav-link" href="#" data-bs-toggle="modal" data-bs-target="#modalPublicacion">Crear Publicaciones</a>
                        </li>
                        <% } %>
                        <% if (esAdmin) { %>
                        <li class="nav-item">
                            <a class="nav-link" href="#" data-bs-toggle="modal" data-bs-target="#modalLibro">Agregar Libro</a>
                        </li>
                        <% } %>
                        <li class="nav-item">
                            <form class="d-flex" role="search" action="${pageContext.request.contextPath}/buscar-libros" method="get">
                                <input class="form-control me-2" type="search" name="q" placeholder="Buscar por título, autor..." aria-label="Search" 
                                       value="<%= terminoBusqueda != null ? terminoBusqueda : (request.getParameter("q") != null ? request.getParameter("q") : "") %>">
                                <button class="btn btn-outline-light" type="submit">Buscar</button>
                                <% if (terminoBusqueda != null && !terminoBusqueda.isEmpty()) { %>
                                <a href="${pageContext.request.contextPath}/pantallas/CatalogoPaginaIncio.jsp" class="btn btn-outline-secondary ms-2" title="Limpiar búsqueda">
                                    ✕
                                </a>
                                <% } %>

                                <!-- Campo oculto para mantener la búsqueda en préstamos -->
                                <input type="hidden" name="mantenerBusqueda" value="true">
                            </form>
                        </li>
                    </ul>
                    <!-- Usuario con sesión - IMAGEN CORREGIDA -->
                    <div class="dropdown">
                        <a href="#" class="d-flex align-items-center text-white text-decoration-none dropdown-toggle" 
                           id="dropdownUser1" data-bs-toggle="dropdown" aria-expanded="false">
                            <img id="fotoNavbar" src="<%= fotoPerfil %>" 
                                 width="30" height="30" class="rounded-circle me-2">
                            <strong><%= nombreUsuario %></strong>
                            <% if (esAdmin) { %>
                            <span class="badge bg-warning ms-2">Admin</span>
                            <% } %>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-dark dropdown-menu-end shadow" aria-labelledby="dropdownUser1">
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/pantallas/perfil.jsp">Mi Perfil</a></li>
                            
                                <% if (esAdmin) { %>
                            <li><a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#modalAdmin">Panel Admin</a></li>
                                <% } %>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/logout">Cerrar sesión</a></li>
                        </ul>
                    </div>
                </div>
            </div>
        </nav>

        <!-- Contenido principal -->
        <main class="container" style="margin-top: 80px;">
                 <!-- Campo oculto con el ID del usuario para usar en JavaScript -->
                <input type="hidden" id="usuarioId" value="<%= usuarioId %>">
                <input type="hidden" id="esAdmin" value="<%= esAdmin %>">

            <!-- Header diferente para búsqueda vs vista normal -->
            <% if (esBusqueda && terminoBusqueda != null && !terminoBusqueda.isEmpty()) { %>
                <!-- HEADER PARA BÚSQUEDA -->
                <div class="row mb-4">
                    <div class="col-12">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <h1 class="mb-2">🔍 Resultados de Búsqueda</h1>
                                <p class="text-muted mb-0">
                                    Se encontraron <strong><%= totalLibros %></strong> 
                                    libro(s) para "<strong><%= terminoBusqueda %></strong>"
                                    <% if (totalPaginas > 1) { %>
                                    | Página <%= paginaActual %> de <%= totalPaginas %>
                                    <% } %>
                                </p>
                            </div>
                            <a href="${pageContext.request.contextPath}/pantallas/CatalogoPaginaIncio.jsp" class="btn btn-outline-primary">
                                ← Volver al catálogo completo
                            </a>
                        </div>
                    </div>
                </div>
            <% } else { %>
                <!-- HEADER PARA VISTA NORMAL -->
                <h1 class="mb-4">Catálogo de Libros</h1>
                <p class="text-muted">
                    Bienvenido, <strong><%= usuario.getNombre() %></strong>
                    <% if (esAdmin) { %> - <span class="text-warning">Modo Administrador</span><% } %>
                    <% if (totalPaginas > 1) { %>
                    | Página <%= paginaActual %> de <%= totalPaginas %> | Total: <strong><%= totalLibros %></strong> libros
                    <% } %>
                </p>

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

                <!-- Campo oculto con el ID del usuario para usar en JavaScript -->
                <input type="hidden" id="usuarioId" value="<%= usuarioId %>">
                <input type="hidden" id="esAdmin" value="<%= esAdmin %>">

                <!-- Estadísticas rápidas para admin -->
                <% if (esAdmin && !esBusqueda) { %>
                <div class="row mb-4">
                    <div class="col-12">
                        <div class="card bg-light">
                            <div class="card-body py-3">
                                <div class="row text-center">
                                    <div class="col-md-3">
                                        <h5 class="mb-0"><%= totalLibros %></h5>
                                        <small class="text-muted">Libros en Catálogo</small>
                                    </div>
                                    <div class="col-md-3">
                                        <h5 class="mb-0"><%= prestamosActivos.size() %></h5>
                                        <small class="text-muted">Préstamos Activos</small>
                                    </div>
                                    <div class="col-md-3">
                                        <h5 class="mb-0"><%= prestamosPendientes.size() %></h5>
                                        <small class="text-muted">Préstamos Pendientes</small>
                                    </div>
                                    <div class="col-md-3">
                                        <h5 class="mb-0"><%= librosPorReponer%></h5>
                                        <small class="text-muted">Libros Por Reponer</small>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <% } %>
            <% } %>

            <!-- Aquí se insertarán las cards dinámicamente -->
            <div id="libros" class="row row-cols-1 row-cols-md-3 g-4">
                <%
                    if (librosAMostrar.isEmpty()) {
                %>
                <div class="col-12">
                    <div class="card text-center py-5">
                        <div class="card-body">
                            <% if (esBusqueda && terminoBusqueda != null && !terminoBusqueda.isEmpty()) { %>
                            <h4 class="text-muted">🔍 No se encontraron libros</h4>
                            <p class="text-muted">No hay resultados para "<strong><%= terminoBusqueda %></strong>"</p>
                            <p class="text-muted mb-3">Intenta con otros términos de búsqueda como título, autor o género.</p>
                            <a href="${pageContext.request.contextPath}/pantallas/CatalogoPaginaIncio.jsp" class="btn btn-primary">Ver todos los libros</a>
                            <% } else { %>
                            <h4 class="text-muted">📚 No hay libros en el catálogo</h4>
                            <p class="text-muted">El catálogo está vacío por el momento.</p>
                            <% if (esAdmin) { %>
                            <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#modalLibro">
                                Agregar Primer Libro
                            </button>
                            <% } %>
                            <% } %>
                        </div>
                    </div>
                </div>
                <% } else { 
                    for (Libro libro : librosAMostrar) { 
                        // Variables para esta iteración
                        String badgeClass = libro.getEjemplaresDisponibles() > 0 ? "bg-success" : "bg-danger";
                        String editorial = libro.getEditorial() != null ? libro.getEditorial() : "N/A";
                        String genero = libro.getGenero() != null ? libro.getGenero() : "General";
                %>
                <div class="col">
                    <div class="card h-100 libro-card">
                        <% if (libro.getPortadaUrl() != null && !libro.getPortadaUrl().isEmpty()) { %>
                        <img src="${pageContext.request.contextPath}/<%= libro.getPortadaUrl() %>" 
                             class="card-img-top" alt="Portada de <%= libro.getTitulo() %>"
                             style="height: 250px; object-fit: cover;">
                        <% } else { %>
                        <div class="card-img-top bg-light d-flex align-items-center justify-content-center" 
                             style="height: 250px;">
                            <span class="text-muted">📖 Sin portada</span>
                        </div>
                        <% } %>
                        <div class="card-body">
                            <h5 class="card-title"><%= libro.getTitulo() %></h5>
                            <p class="card-text">
                                <strong>Autor:</strong> <%= libro.getAutor() %><br>
                                <strong>Editorial:</strong> <%= editorial %><br>
                                <strong>Género:</strong> <%= genero %><br>
                                <strong>Disponibles:</strong> 
                                <span class="badge <%= badgeClass %>">
                                    <%= libro.getEjemplaresDisponibles() %>/<%= libro.getEjemplaresTotales() %>
                                </span>
                            </p>
                            <% if (libro.getDescripcion() != null && !libro.getDescripcion().isEmpty()) { 
                                String descripcion = libro.getDescripcion();
                                if (descripcion.length() > 100) {
                                    descripcion = descripcion.substring(0, 100) + "...";
                                }
                            %>
                            <p class="card-text"><small class="text-muted">
                                    <%= descripcion %>
                                </small></p>
                                <% } %>
                        </div>
                            <div class="card-footer">
                                <div class="d-flex justify-content-between">
                                    <% 
                                        // ✅ VERIFICAR DISPONIBILIDAD CORRECTAMENTE - CORREGIDO
                                        boolean disponible = false;

                                        if (esBusqueda && terminoBusqueda != null && !terminoBusqueda.isEmpty()) {
                                            // Para búsquedas, buscar el libro actual en la lista de libros encontrados
                                            Libro libroActual = null;
                                            if (librosEncontrados != null) {
                                                for (Libro l : librosEncontrados) {
                                                    if (l.getId() == libro.getId()) {
                                                        libroActual = l;
                                                        break;
                                                    }
                                                }
                                            }
                                            disponible = libroActual != null && libroActual.getEjemplaresDisponibles() > 0;
                                        } else {
                                            // Para catálogo normal, usar el libro actual
                                            disponible = libro.getEjemplaresDisponibles() > 0;
                                        }
                                    %>

                                    <% if (disponible) { %>
                                    <button class="btn btn-primary btn-sm" 
                                            onclick="solicitarPrestamo(<%= libro.getId() %>)"
                                            data-libro-id="<%= libro.getId() %>"
                                            data-libro-titulo="<%= libro.getTitulo() %>">
                                        Solicitar Préstamo
                                    </button>
                                    <% } else { %>
                                    <button class="btn btn-secondary btn-sm" disabled>
                                        No Disponible
                                    </button>
                                    <% } %>

                                    <% if (esAdmin) { %>
                                    <div>
                                        <button class="btn btn-warning btn-sm" 
                                                onclick="editarLibro(<%= libro.getId() %>)">
                                            Editar
                                        </button>
                                        <button class="btn btn-danger btn-sm" 
                                                onclick="eliminarLibro(<%= libro.getId() %>)">
                                            Eliminar
                                        </button>
                                    </div>
                                    <% } %>
                                </div>
                            </div>
                    </div>
                </div>
                <% } 
                } %>
            </div>

            <!-- PAGINACIÓN -->
            <% if (totalPaginas > 1) { %>
            <div class="row mt-5">
                <div class="col-12">
                    <nav aria-label="Paginación de libros">
                        <ul class="pagination justify-content-center">
                            <!-- Botón Anterior -->
                            <li class="page-item <%= paginaActual <= 1 ? "disabled" : "" %>">
                                <% if (paginaActual > 1) { %>
                                    <a class="page-link" href="?pagina=<%= paginaActual - 1 %><%= esBusqueda && terminoBusqueda != null ? "&q=" + java.net.URLEncoder.encode(terminoBusqueda, "UTF-8") : "" %>" aria-label="Anterior">
                                        <span aria-hidden="true">&laquo;</span>
                                    </a>
                                <% } else { %>
                                    <span class="page-link" aria-hidden="true">&laquo;</span>
                                <% } %>
                            </li>
                            
                            <!-- Números de página -->
                            <%
                                int inicio = Math.max(1, paginaActual - 2);
                                int fin = Math.min(totalPaginas, paginaActual + 2);
                                
                                // Mostrar primera página si no está en el rango
                                if (inicio > 1) {
                            %>
                            <li class="page-item">
                                <a class="page-link" href="?pagina=1<%= esBusqueda && terminoBusqueda != null ? "&q=" + java.net.URLEncoder.encode(terminoBusqueda, "UTF-8") : "" %>">1</a>
                            </li>
                            <% if (inicio > 2) { %>
                            <li class="page-item disabled">
                                <span class="page-link">...</span>
                            </li>
                            <% } } %>
                            
                            <% for (int i = inicio; i <= fin; i++) { %>
                            <li class="page-item <%= i == paginaActual ? "active" : "" %>">
                                <a class="page-link" href="?pagina=<%= i %><%= esBusqueda && terminoBusqueda != null ? "&q=" + java.net.URLEncoder.encode(terminoBusqueda, "UTF-8") : "" %>">
                                    <%= i %>
                                </a>
                            </li>
                            <% } %>
                            
                            <!-- Mostrar última página si no está en el rango -->
                            <% if (fin < totalPaginas) { %>
                            <% if (fin < totalPaginas - 1) { %>
                            <li class="page-item disabled">
                                <span class="page-link">...</span>
                            </li>
                            <% } %>
                            <li class="page-item">
                                <a class="page-link" href="?pagina=<%= totalPaginas %><%= esBusqueda && terminoBusqueda != null ? "&q=" + java.net.URLEncoder.encode(terminoBusqueda, "UTF-8") : "" %>">
                                    <%= totalPaginas %>
                                </a>
                            </li>
                            <% } %>
                            
                            <!-- Botón Siguiente -->
                            <li class="page-item <%= paginaActual >= totalPaginas ? "disabled" : "" %>">
                                <% if (paginaActual < totalPaginas) { %>
                                    <a class="page-link" href="?pagina=<%= paginaActual + 1 %><%= esBusqueda && terminoBusqueda != null ? "&q=" + java.net.URLEncoder.encode(terminoBusqueda, "UTF-8") : "" %>" aria-label="Siguiente">
                                        <span aria-hidden="true">&raquo;</span>
                                    </a>
                                <% } else { %>
                                    <span class="page-link" aria-hidden="true">&raquo;</span>
                                <% } %>
                            </li>
                        </ul>
                    </nav>
                    
                    <!-- Información de la página actual -->
                    <div class="text-center mt-2">
                        <p class="text-muted">
                            Mostrando página <%= paginaActual %> de <%= totalPaginas %> 
                            | Total de libros: <strong><%= totalLibros %></strong>
                            <% if (esBusqueda && terminoBusqueda != null) { %>
                            | Búsqueda: "<strong><%= terminoBusqueda %></strong>"
                            <% } %>
                        </p>
                    </div>
                </div>
            </div>
            <% } %>

            <!-- SECCIÓN DE GESTIÓN DE PRÉSTAMOS PARA ADMIN (SOLO EN VISTA NORMAL) -->
            <% if (esAdmin && !esBusqueda) { %>
            <div class="row mt-5">
                <div class="col-12">
                    <h2 class="mb-4">📋 Gestión de Préstamos</h2>

                    <!-- Préstamos Pendientes -->
                    <div class="card mb-4">
                        <div class="card-header bg-warning text-dark">
                            <h5 class="mb-0">⏳ Préstamos Pendientes (<%= prestamosPendientes.size() %>)</h5>
                        </div>
                        <div class="card-body">
                            <% if (prestamosPendientes.isEmpty()) { %>
                            <p class="text-muted mb-0">No hay préstamos pendientes por aprobar.</p>
                            <% } else { %>
                            <div class="table-responsive">
                                <table class="table table-hover">
                                    <thead>
                                        <tr>
                                            <th>Usuario</th>
                                            <th>Libro</th>
                                            <th>Fecha Solicitud</th>
                                            <th>Devolución Estimada</th>
                                            <th>Observaciones</th>
                                            <th>Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (Prestamo prestamo : prestamosPendientes) { 
                                            // Obtener datos del libro y usuario
                                            Libro libroPrestamo = null;
                                            for (Libro l : libroDAO.obtenerTodosLibros()) {
                                                if (l.getId() == prestamo.getIdLibro()) {
                                                    libroPrestamo = l;
                                                    break;
                                                }
                                            }
                                            Usuario usuarioPrestamo = usuarioDAO.obtenerUsuarioPorId(prestamo.getIdUsuario());
                                        %>
                                        <tr>
                                            <td>
                                                <% if (usuarioPrestamo != null) { %>
                                                <strong><%= usuarioPrestamo.getNombre() %></strong><br>
                                                <small class="text-muted"><%= usuarioPrestamo.getCorreo() %></small>
                                                <% } else { %>
                                                Usuario no encontrado
                                                <% } %>
                                            </td>
                                            <td>
                                                <% if (libroPrestamo != null) { %>
                                                <strong><%= libroPrestamo.getTitulo() %></strong><br>
                                                <small class="text-muted"><%= libroPrestamo.getAutor() %></small>
                                                <% } else { %>
                                                Libro no encontrado
                                                <% } %>
                                            </td>
                                            <td>
                                                <%= prestamo.getFechaPrestamo() != null ? 
                                                        new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(prestamo.getFechaPrestamo()) : "N/A" %>
                                            </td>
                                            <td>
                                                <%= prestamo.getFechaDevolucionEstimada() != null ? 
                                                        prestamo.getFechaDevolucionEstimada().toString() : "N/A" %>
                                            </td>
                                            <td>
                                                <%= prestamo.getObservaciones() != null ? prestamo.getObservaciones() : "Sin observaciones" %>
                                            </td>
                                            <td>
                                                <div class="btn-group btn-group-sm">
                                                    <form action="${pageContext.request.contextPath}/gestion-prestamo" method="post" class="d-inline">
                                                        <input type="hidden" name="accion" value="aprobar">
                                                        <input type="hidden" name="idPrestamo" value="<%= prestamo.getId() %>">
                                                        <button type="submit" class="btn btn-success" 
                                                                onclick="return confirm('¿Aprobar préstamo de este libro?')">
                                                            ✅ Aprobar
                                                        </button>
                                                    </form>
                                                    <form action="${pageContext.request.contextPath}/gestion-prestamo" method="post" class="d-inline">
                                                        <input type="hidden" name="accion" value="rechazar">
                                                        <input type="hidden" name="idPrestamo" value="<%= prestamo.getId() %>">
                                                        <button type="submit" class="btn btn-danger" 
                                                                onclick="return confirm('¿Rechazar este préstamo?')">
                                                            ❌ Rechazar
                                                        </button>
                                                    </form>
                                                </div>
                                            </td>
                                        </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                            <% } %>
                        </div>
                    </div>
                    <!-- Préstamos Activos -->
                    <div class="card">
                        <div class="card-header bg-success text-white">
                            <h5 class="mb-0">✅ Préstamos Activos (<%= prestamosActivos.size() %>)</h5>
                        </div>
                        <div class="card-body">
                            <% if (prestamosActivos.isEmpty()) { %>
                            <p class="text-muted mb-0">No hay préstamos activos en este momento.</p>
                            <% } else { %>
                            <div class="table-responsive">
                                <table class="table table-hover">
                                    <thead>
                                        <tr>
                                            <th>Usuario</th>
                                            <th>Libro</th>
                                            <th>Fecha Préstamo</th>
                                            <th>Devolución Estimada</th>
                                            <th>Admin que Aprobó</th>
                                            <th>Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (Prestamo prestamo : prestamosActivos) { 
                                            Libro libroPrestamo = null;
                                            for (Libro l : libroDAO.obtenerTodosLibros()) {
                                                if (l.getId() == prestamo.getIdLibro()) {
                                                    libroPrestamo = l;
                                                    break;
                                                }
                                            }
                                            Usuario usuarioPrestamo = usuarioDAO.obtenerUsuarioPorId(prestamo.getIdUsuario());
                                            Usuario adminAprobo = prestamo.getIdAdminAprobo() != null ? 
                                                usuarioDAO.obtenerUsuarioPorId(prestamo.getIdAdminAprobo()) : null;
                                        %>
                                        <tr>
                                            <td>
                                                <% if (usuarioPrestamo != null) { %>
                                                <%= usuarioPrestamo.getNombre() %>
                                                <% } else { %>
                                                Usuario no encontrado
                                                <% } %>
                                            </td>
                                            <td>
                                                <% if (libroPrestamo != null) { %>
                                                <%= libroPrestamo.getTitulo() %>
                                                <% } else { %>
                                                Libro no encontrado
                                                <% } %>
                                            </td>
                                            <td>
                                                <%= prestamo.getFechaPrestamo() != null ? 
                                                        new java.text.SimpleDateFormat("dd/MM/yyyy").format(prestamo.getFechaPrestamo()) : "N/A" %>
                                            </td>                       
                                            <td>
                                                <span class="<%= prestamo.estaAtrasado() ? "text-danger fw-bold" : "" %>">
                                                    <%= prestamo.getFechaDevolucionEstimada() != null ? 
                                                            prestamo.getFechaDevolucionEstimada().toString() : "N/A" %>
                                                    <% if (prestamo.estaAtrasado()) { %> ⚠️<% } %>
                                                </span>
                                            </td>
                                            <td>
                                                <% if (adminAprobo != null) { %>
                                                <%= adminAprobo.getNombre() %>
                                                <% } else { %>
                                                Sistema
                                                <% } %>
                                            </td>
                                            <td>
                                                <form action="${pageContext.request.contextPath}/gestion-prestamo" method="post" class="d-inline">
                                                    <input type="hidden" name="accion" value="devolver">
                                                    <input type="hidden" name="idPrestamo" value="<%= prestamo.getId() %>">
                                                    <button type="submit" class="btn btn-info btn-sm" 
                                                            onclick="return confirm('¿Marcar como devuelto?')">
                                                        📖 Devolver
                                                    </button>
                                                </form>
                                            </td>
                                        </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
            <% } %>
        </main>

        <!-- Modal para crear publicaciones -->
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

        <!-- Modal para agregar libro (NUEVO - solo para admin) -->
        <div class="modal fade" id="modalLibro" tabindex="-1" aria-labelledby="modalLibroLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="card shadow-lg">
                        <div class="card-header bg-primary text-white">
                            <h5 class="mb-0">📚 Agregar Nuevo Libro</h5>
                        </div>
                        <div class="card-body">
                            <form id="formLibro" action="${pageContext.request.contextPath}/libro" method="post" enctype="multipart/form-data">
                                <input type="hidden" name="accion" value="crear">
                                <input type="hidden" name="idUsuarioCreador" value="<%= usuarioId %>">

                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="tituloLibro" class="form-label">Titulo *</label>
                                            <input type="text" class="form-control" id="tituloLibro" name="titulo" required>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="autorLibro" class="form-label">Autor *</label>
                                            <input type="text" class="form-control" id="autorLibro" name="autor" required>
                                        </div>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="isbnLibro" class="form-label">ISBN</label>
                                            <input type="text" class="form-control" id="isbnLibro" name="isbn">
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="editorialLibro" class="form-label">Editorial</label>
                                            <input type="text" class="form-control" id="editorialLibro" name="editorial">
                                        </div>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="anioLibro" class="form-label">Año de Publicación</label>
                                            <input type="number" class="form-control" id="anioLibro" name="anioPublicacion" min="1000" max="2030">
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="generoLibro" class="form-label">Genero</label>
                                            <select class="form-control" id="generoLibro" name="genero">
                                                <option value="">Seleccionar genero...</option>
                                                <option value="Ficcion">Ficcion</option>
                                                <option value="Ciencia Ficcion">Ciencia Ficcion</option>
                                                <option value="Terror">Terror</option>
                                                <option value="Romance">Romance</option>
                                                <option value="Biografia">Biografia</option>
                                                <option value="Historia">Historia</option>
                                                <option value="Ciencia">Ciencia</option>
                                                <option value="Tecnologia">Tecnologia</option>
                                                <option value="Autoayuda">Autoayuda</option>
                                                <option value="Infantil">Infantil</option>
                                            </select>
                                        </div>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label for="descripcionLibro" class="form-label">Descripcion</label>
                                    <textarea class="form-control" id="descripcionLibro" name="descripcion" rows="3"></textarea>
                                </div>

                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="ejemplaresTotales" class="form-label">Ejemplares Totales *</label>
                                            <input type="number" class="form-control" id="ejemplaresTotales" name="ejemplaresTotales" value="1" min="1" required>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="portadaLibro" class="form-label">Portada del Libro</label>
                                            <input class="form-control" type="file" id="portadaLibro" name="portada" accept="image/*" onchange="previsualizarImagen(event)">

                                            <!-- Preview de la imagen -->
                                            <div class="mt-3 text-center">
                                                <img id="previewImagen" src="" alt="Vista previa de la imagen" 
                                                     class="img-thumbnail d-none" style="max-height: 200px; max-width: 100%;">
                                            </div>
                                            <div class="form-text">Formatos: JPG, PNG. Máximo 2MB.</div>
                                        </div>
                                    </div>
                                </div>

                                <div class="text-end">
                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                                    <button type="submit" class="btn btn-primary">Guardar Libro</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Modal de administración (NUEVO) -->
        <div class="modal fade" id="modalAdmin" tabindex="-1" aria-labelledby="modalAdminLabel" aria-hidden="true">
            <div class="modal-dialog modal-xl">
                <div class="modal-content">
                    <div class="card">
                        <div class="card-header bg-warning text-dark">
                            <h5 class="mb-0">⚙️ Panel de Administración</h5>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="card mb-3">
                                        <div class="card-body text-center">
                                            <h5>📊 Estadísticas</h5>
                                            <p>Libros: <%= totalLibros %></p>
                                            <p>Usuarios: <%= totalUsuarios %></p>
                                            <p>Préstamos: <%= prestamosActivosNUM%></p>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="card mb-3">
                                        <div class="card-body text-center">
                                            <h5>🚨 Alertas</h5>
                                            <p>Préstamos atrasados: <%= prestamosAtrasados %></p>
                                            <p>Libros por reponer: <%= librosPorReponer %> </p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Modal para editar libro -->
        <div class="modal fade" id="modalEditarLibro" tabindex="-1" aria-labelledby="modalEditarLibroLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="card shadow-lg">
                        <div class="card-header bg-warning text-dark">
                            <h5 class="mb-0">✏️ Editar Libro</h5>
                        </div>
                        <div class="card-body">
                            <form id="formEditarLibro" action="${pageContext.request.contextPath}/libro" method="post" enctype="multipart/form-data">
                                <input type="hidden" name="accion" value="editar">
                                <input type="hidden" id="editarIdLibro" name="id">
                                <input type="hidden" name="idUsuarioCreador" value="<%= usuarioId %>">

                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="editarTituloLibro" class="form-label">Titulo *</label>
                                            <input type="text" class="form-control" id="editarTituloLibro" name="titulo" required>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="editarAutorLibro" class="form-label">Autor *</label>
                                            <input type="text" class="form-control" id="editarAutorLibro" name="autor" required>
                                        </div>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="editarIsbnLibro" class="form-label">ISBN</label>
                                            <input type="text" class="form-control" id="editarIsbnLibro" name="isbn">
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="editarEditorialLibro" class="form-label">Editorial</label>
                                            <input type="text" class="form-control" id="editarEditorialLibro" name="editorial">
                                        </div>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="editarAnioLibro" class="form-label">Año de Publicacion</label>
                                            <input type="number" class="form-control" id="editarAnioLibro" name="anioPublicacion" min="1000" max="2030">
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="editarGeneroLibro" class="form-label">Genero</label>
                                            <select class="form-control" id="editarGeneroLibro" name="genero">
                                                <option value="">Seleccionar genero...</option>
                                                <option value="Ficcion">Ficcion</option>
                                                <option value="Ciencia Ficcion">Ciencia Ficcion</option>
                                                <option value="Terror">Terror</option>
                                                <option value="Romance">Romance</option>
                                                <option value="Biografia">Biografia</option>
                                                <option value="Historia">Historia</option>
                                                <option value="Ciencia">Ciencia</option>
                                                <option value="Tecnologia">Tecnologia</option>
                                                <option value="Autoayuda">Autoayuda</option>
                                                <option value="Infantil">Infantil</option>
                                            </select>
                                        </div>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label for="editarDescripcionLibro" class="form-label">Descripción</label>
                                    <textarea class="form-control" id="editarDescripcionLibro" name="descripcion" rows="3"></textarea>
                                </div>

                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="editarEjemplaresTotales" class="form-label">Ejemplares Totales *</label>
                                            <input type="number" class="form-control" id="editarEjemplaresTotales" name="ejemplaresTotales" min="1" required>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="editarEjemplaresDisponibles" class="form-label">Ejemplares Disponibles *</label>
                                            <input type="number" class="form-control" id="editarEjemplaresDisponibles" name="ejemplaresDisponibles" min="0" required>
                                        </div>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label for="editarPortadaLibro" class="form-label">Portada del Libro</label>
                                    <input class="form-control" type="file" id="editarPortadaLibro" name="portada" accept="image/*" onchange="previsualizarImagenEditar(event)">

                                    <!-- Preview de la imagen para editar -->
                                    <div class="mt-3 text-center">
                                        <img id="previewImagenEditar" src="" alt="Vista previa de la portada" 
                                             class="img-thumbnail d-none" style="max-height: 200px; max-width: 100%;">
                                    </div>

                                    <div class="form-text">Dejar vacío para mantener la portada actual.</div>
                                    <div id="portadaActual" class="mt-2"></div>
                                </div>

                                <div class="text-end">
                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                                    <button type="submit" class="btn btn-warning">Actualizar Libro</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script src="${pageContext.request.contextPath}/node_modules/bootstrap/dist/js/bootstrap.bundle.js"></script>
        <script>
            
            //no se puede utilizar las variables como usuarioId 
        const usuarioId = document.getElementById('usuarioId')?.value || '';
        const esAdmin = document.getElementById('esAdmin')?.value === 'true';

            // Mejorar UX de búsqueda
            document.addEventListener('DOMContentLoaded', function() {
                const searchInput = document.querySelector('input[name="q"]');

                // Mantener el foco en el input después de buscar
                const currentSearch = new URLSearchParams(window.location.search).get('q');
                if (currentSearch && searchInput) {
                    searchInput.focus();
                    // Seleccionar todo el texto para facilitar nueva búsqueda
                    searchInput.select();
                }

                // Búsqueda en tiempo real opcional (puedes implementar después)
                if (searchInput) {
                    let timeoutId;
                    searchInput.addEventListener('input', function(e) {
                        clearTimeout(timeoutId);
                        timeoutId = setTimeout(() => {
                            const query = e.target.value.trim();
                            if (query.length >= 2) {
                                console.log('Buscando:', query);
                                // Aquí puedes agregar búsqueda en tiempo real con AJAX si quieres
                            }
                        }, 500);
                    });
                }
            });
           // Función para previsualizar imagen en el formulario de publicaciones y agregar libro
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

           // Función para previsualizar imagen en el formulario de editar libro
           function previsualizarImagenEditar(event) {
               const file = event.target.files[0];
               if (!file) return;

               const reader = new FileReader();
               reader.onload = function(e) {
                   const preview = document.getElementById('previewImagenEditar');
                   if (preview) {
                       preview.src = e.target.result;
                       preview.classList.remove('d-none');
                   }
               };
               reader.readAsDataURL(file);
           }


            
            // Función para solicitar préstamo - CORREGIDA para funcionar con búsquedas
            // Función para solicitar préstamo - SOLUCIÓN COMPLETA
            function solicitarPrestamo(libroId) {
                if (!usuarioId) {
                    alert('Debes iniciar sesión para solicitar préstamos');
                    return;
                }

                const observaciones = prompt('¿Alguna observación o comentario para el préstamo? (opcional)');

                // Si el usuario cancela el prompt
                if (observaciones === null) {
                    return; // Usuario canceló la operación
                }

                // Crear formulario dinámico
                const form = document.createElement('form');
                form.method = 'post';
                form.action = '${pageContext.request.contextPath}/prestamo';

                // Campos básicos del préstamo
                const inputLibro = document.createElement('input');
                inputLibro.type = 'hidden';
                inputLibro.name = 'idLibro';
                inputLibro.value = libroId;

                const inputUsuario = document.createElement('input');
                inputUsuario.type = 'hidden';
                inputUsuario.name = 'idUsuario';
                inputUsuario.value = usuarioId;

                const inputObservaciones = document.createElement('input');
                inputObservaciones.type = 'hidden';
                inputObservaciones.name = 'observaciones';
                inputObservaciones.value = observaciones || '';

                // ✅ PARÁMETROS CRÍTICOS PARA MANTENER EL CONTEXTO
                const urlParams = new URLSearchParams(window.location.search);
                const busquedaParam = urlParams.get('q');
                const paginaParam = urlParams.get('pagina');

                // Si estamos en modo búsqueda, agregar parámetros especiales
                if (busquedaParam) {
                    const inputBusqueda = document.createElement('input');
                    inputBusqueda.type = 'hidden';
                    inputBusqueda.name = 'terminoBusqueda';
                    inputBusqueda.value = busquedaParam;
                    form.appendChild(inputBusqueda);

                    const inputEsBusqueda = document.createElement('input');
                    inputEsBusqueda.type = 'hidden';
                    inputEsBusqueda.name = 'esBusqueda';
                    inputEsBusqueda.value = 'true';
                    form.appendChild(inputEsBusqueda);
                }

                if (paginaParam) {
                    const inputPagina = document.createElement('input');
                    inputPagina.type = 'hidden';
                    inputPagina.name = 'pagina';
                    inputPagina.value = paginaParam;
                    form.appendChild(inputPagina);
                }

                // Agregar todos los campos al formulario
                form.appendChild(inputLibro);
                form.appendChild(inputUsuario);
                form.appendChild(inputObservaciones);

                document.body.appendChild(form);
                form.submit();
            }
            
            // Funciones para administrador
            function editarLibro(libroId) {
                // Cargar datos del libro via AJAX
                fetch('${pageContext.request.contextPath}/libro?accion=obtener&id=' + libroId)
                    .then(response => response.json())
                    .then(libro => {
                        // Llenar el formulario con los datos del libro
                        document.getElementById('editarIdLibro').value = libro.id;
                        document.getElementById('editarTituloLibro').value = libro.titulo;
                        document.getElementById('editarAutorLibro').value = libro.autor;
                        document.getElementById('editarIsbnLibro').value = libro.isbn || '';
                        document.getElementById('editarEditorialLibro').value = libro.editorial || '';
                        document.getElementById('editarAnioLibro').value = libro.anioPublicacion || '';
                        document.getElementById('editarGeneroLibro').value = libro.genero || '';
                        document.getElementById('editarDescripcionLibro').value = libro.descripcion || '';
                        document.getElementById('editarEjemplaresTotales').value = libro.ejemplaresTotales;
                        document.getElementById('editarEjemplaresDisponibles').value = libro.ejemplaresDisponibles;
                        
                        // Mostrar portada actual
                        if (libro.portadaUrl) {
                            const portadaActual = document.getElementById('portadaActual');
                            portadaActual.innerHTML = `
                                <strong>Portada actual:</strong><br>
                                <img src="${pageContext.request.contextPath}/${libro.portadaUrl}" 
                                     style="max-height: 100px; max-width: 100px;" 
                                     class="img-thumbnail mt-1">
                            `;
                            
                            // También mostrar en el preview de edición
                            const previewEditar = document.getElementById('previewImagenEditar');
                            if (previewEditar) {
                                previewEditar.src = "${pageContext.request.contextPath}/" + libro.portadaUrl;
                                previewEditar.classList.remove('d-none');
                            }
                        }
                        
                        // Mostrar el modal
                        const modal = new bootstrap.Modal(document.getElementById('modalEditarLibro'));
                        modal.show();
                    })
                    .catch(error => {
                        console.error('Error al cargar libro:', error);
                        alert('Error al cargar los datos del libro');
                    });
            }
            
            function eliminarLibro(libroId) {
                if (confirm('¿Estás seguro de eliminar este libro? Esta acción no se puede deshacer.')) {
                    // Crear formulario para eliminar
                    const form = document.createElement('form');
                    form.method = 'post';
                    form.action = '${pageContext.request.contextPath}/libro';

                    const inputAccion = document.createElement('input');
                    inputAccion.type = 'hidden';
                    inputAccion.name = 'accion';
                    inputAccion.value = 'eliminar';

                    const inputId = document.createElement('input');
                    inputId.type = 'hidden';
                    inputId.name = 'id';
                    inputId.value = libroId;

                    form.appendChild(inputAccion);
                    form.appendChild(inputId);
                    document.body.appendChild(form);

                    form.submit();
                }
            }
            
            // Validación del formulario de libro
            document.getElementById('formLibro')?.addEventListener('submit', function (e) {
                const titulo = document.getElementById('tituloLibro').value.trim();
                const autor = document.getElementById('autorLibro').value.trim();

                if (!titulo || !autor) {
                    e.preventDefault();
                    alert('Por favor, completa los campos obligatorios (Título y Autor)');
                }
            });
            
            // Validación del formulario de publicaciones
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
                    const maxSize = 3 * 1024 * 1024; // 3MB como en tu servlet
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
        </script>
    </body>
</html>