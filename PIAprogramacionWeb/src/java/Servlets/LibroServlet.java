package Servlets;

import DAO.LibroDAO;
import DAO.UsuarioDAO;
import modelos.Libro;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@WebServlet("/libro")
@MultipartConfig(
    maxFileSize = 1024 * 1024 * 5,      // 5 MB
    maxRequestSize = 1024 * 1024 * 10,  // 10 MB
    fileSizeThreshold = 1024 * 1024     // 1 MB
)
public class LibroServlet extends HttpServlet {

    private String uploadPath;

    @Override
    public void init() throws ServletException {
        // Directorio para guardar portadas de libros
        uploadPath = getServletContext().getRealPath("") + "uploads/libros/";
        
        // Crear el directorio si no existe
        try {
            Files.createDirectories(Paths.get(uploadPath));
            System.out.println("📁 Directorio de libros creado en: " + uploadPath);
        } catch (IOException e) {
            throw new ServletException("No se pudo crear el directorio de libros", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/pantallas/Inicio-Sesion.jsp");
            return;
        }

        String accion = request.getParameter("accion");
        
        if ("obtener".equals(accion)) {
            // Obtener libro por ID para editar
            try {
                int idLibro = Integer.parseInt(request.getParameter("id"));
                LibroDAO libroDAO = new LibroDAO();
                Libro libro = libroDAO.obtenerLibroPorId(idLibro);
                
                response.setContentType("application/json");
                if (libro != null) {
                    // Convertir libro a JSON
                    String json = String.format(
                        "{\"id\":%d,\"titulo\":\"%s\",\"autor\":\"%s\",\"isbn\":\"%s\",\"editorial\":\"%s\"," +
                        "\"anioPublicacion\":%d,\"genero\":\"%s\",\"descripcion\":\"%s\",\"portadaUrl\":\"%s\"," +
                        "\"ejemplaresDisponibles\":%d,\"ejemplaresTotales\":%d}",
                        libro.getId(), 
                        escapeJson(libro.getTitulo() != null ? libro.getTitulo() : ""),
                        escapeJson(libro.getAutor() != null ? libro.getAutor() : ""),
                        escapeJson(libro.getIsbn() != null ? libro.getIsbn() : ""),
                        escapeJson(libro.getEditorial() != null ? libro.getEditorial() : ""),
                        libro.getAnioPublicacion(),
                        escapeJson(libro.getGenero() != null ? libro.getGenero() : ""),
                        escapeJson(libro.getDescripcion() != null ? libro.getDescripcion() : ""),
                        escapeJson(libro.getPortadaUrl() != null ? libro.getPortadaUrl() : ""),
                        libro.getEjemplaresDisponibles(),
                        libro.getEjemplaresTotales()
                    );
                    response.getWriter().write(json);
                } else {
                    response.getWriter().write("{\"error\":\"Libro no encontrado\"}");
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.getWriter().write("{\"error\":\"Error al obtener libro\"}");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/pantallas/Inicio-Sesion.jsp");
            return;
        }

        // Verificar que el usuario es administrador
        UsuarioDAO usuarioDAO = new UsuarioDAO();
        Integer usuarioId = (Integer) session.getAttribute("usuarioId");
        boolean esAdmin = usuarioDAO.esAdministrador(usuarioId);
        
        if (!esAdmin) {
            response.sendRedirect(request.getContextPath() + "/pantallas/CatalogoPaginaIncio.jsp?error=acceso_denegado");
            return;
        }

        try {
            String accion = request.getParameter("accion");
            
            if ("crear".equals(accion)) {
                crearLibro(request, response, usuarioId);
            } else if ("editar".equals(accion)) {
                editarLibro(request, response, usuarioId);
            } else if ("eliminar".equals(accion)) {
                eliminarLibro(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/pantallas/CatalogoPaginaIncio.jsp?error=accion_no_valida");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/pantallas/CatalogoPaginaIncio.jsp?error=error_general");
        }
    }

    private void crearLibro(HttpServletRequest request, HttpServletResponse response, int usuarioId)
            throws ServletException, IOException {
        
        // Obtener parámetros del formulario
        String titulo = request.getParameter("titulo");
        String autor = request.getParameter("autor");
        String isbn = request.getParameter("isbn");
        String editorial = request.getParameter("editorial");
        String genero = request.getParameter("genero");
        String descripcion = request.getParameter("descripcion");
        int anioPublicacion = request.getParameter("anioPublicacion") != null ? 
            Integer.parseInt(request.getParameter("anioPublicacion")) : 0;
        int ejemplaresTotales = Integer.parseInt(request.getParameter("ejemplaresTotales"));

        // Validaciones básicas
        if (titulo == null || autor == null || titulo.trim().isEmpty() || autor.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/pantallas/CatalogoPaginaIncio.jsp?error=campos_obligatorios");
            return;
        }

        // Procesar la portada del libro
        String portadaUrl = procesarPortada(request, response, usuarioId);
        if (portadaUrl == null && request.getPart("portada") != null && request.getPart("portada").getSize() > 0) {
            // Hubo error al procesar la portada, ya se redirigió en procesarPortada
            return;
        }

        // Crear objeto Libro
        Libro nuevoLibro = new Libro();
        nuevoLibro.setTitulo(titulo.trim());
        nuevoLibro.setAutor(autor.trim());
        nuevoLibro.setIsbn(isbn != null ? isbn.trim() : null);
        nuevoLibro.setEditorial(editorial != null ? editorial.trim() : null);
        nuevoLibro.setGenero(genero != null ? genero.trim() : null);
        nuevoLibro.setDescripcion(descripcion != null ? descripcion.trim() : null);
        nuevoLibro.setAnioPublicacion(anioPublicacion);
        nuevoLibro.setPortadaUrl(portadaUrl);
        nuevoLibro.setEjemplaresDisponibles(ejemplaresTotales);
        nuevoLibro.setEjemplaresTotales(ejemplaresTotales);
        nuevoLibro.setIdUsuarioCreador(usuarioId);

        // Guardar en la base de datos
        LibroDAO libroDAO = new LibroDAO();
        boolean exito = libroDAO.crearLibro(nuevoLibro);

        if (exito) {
            response.sendRedirect(request.getContextPath() + "/pantallas/CatalogoPaginaIncio.jsp?mensaje=libro_creado_exitosamente");
        } else {
            // Si falla, eliminar la imagen subida
            if (portadaUrl != null) {
                eliminarArchivo(portadaUrl);
            }
            response.sendRedirect(request.getContextPath() + "/pantallas/CatalogoPaginaIncio.jsp?error=error_crear_libro");
        }
    }

    private void editarLibro(HttpServletRequest request, HttpServletResponse response, int usuarioId)
            throws ServletException, IOException {
        
        try {
            int idLibro = Integer.parseInt(request.getParameter("id"));
            String titulo = request.getParameter("titulo");
            String autor = request.getParameter("autor");
            String isbn = request.getParameter("isbn");
            String editorial = request.getParameter("editorial");
            String genero = request.getParameter("genero");
            String descripcion = request.getParameter("descripcion");
            int anioPublicacion = request.getParameter("anioPublicacion") != null ? 
                Integer.parseInt(request.getParameter("anioPublicacion")) : 0;
            int ejemplaresTotales = Integer.parseInt(request.getParameter("ejemplaresTotales"));
            int ejemplaresDisponibles = Integer.parseInt(request.getParameter("ejemplaresDisponibles"));

            // Validaciones básicas
            if (titulo == null || autor == null || titulo.trim().isEmpty() || autor.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/pantallas/CatalogoPaginaIncio.jsp?error=campos_obligatorios");
                return;
            }

            LibroDAO libroDAO = new LibroDAO();
            Libro libroActual = libroDAO.obtenerLibroPorId(idLibro);
            
            if (libroActual == null) {
                response.sendRedirect(request.getContextPath() + "/pantallas/CatalogoPaginaIncio.jsp?error=libro_no_encontrado");
                return;
            }

            // Procesar la portada del libro
            String portadaUrl = procesarPortada(request, response, usuarioId);
            if (portadaUrl == null && request.getPart("portada") != null && request.getPart("portada").getSize() > 0) {
                // Hubo error al procesar la portada, ya se redirigió en procesarPortada
                return;
            }

            // Si no se subió nueva portada, mantener la actual
            if (portadaUrl == null) {
                portadaUrl = libroActual.getPortadaUrl();
            }

            // Actualizar objeto Libro
            Libro libro = new Libro();
            libro.setId(idLibro);
            libro.setTitulo(titulo.trim());
            libro.setAutor(autor.trim());
            libro.setIsbn(isbn != null ? isbn.trim() : null);
            libro.setEditorial(editorial != null ? editorial.trim() : null);
            libro.setGenero(genero != null ? genero.trim() : null);
            libro.setDescripcion(descripcion != null ? descripcion.trim() : null);
            libro.setAnioPublicacion(anioPublicacion);
            libro.setPortadaUrl(portadaUrl);
            libro.setEjemplaresDisponibles(ejemplaresDisponibles);
            libro.setEjemplaresTotales(ejemplaresTotales);
            libro.setIdUsuarioCreador(usuarioId);

            boolean exito = libroDAO.actualizarLibro(libro);

            if (exito) {
                response.sendRedirect(request.getContextPath() + "/pantallas/CatalogoPaginaIncio.jsp?mensaje=libro_actualizado");
            } else {
                response.sendRedirect(request.getContextPath() + "/pantallas/CatalogoPaginaIncio.jsp?error=error_actualizar_libro");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/pantallas/CatalogoPaginaIncio.jsp?error=id_invalido");
        }
    }

    private void eliminarLibro(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            int idLibro = Integer.parseInt(request.getParameter("id"));
            LibroDAO libroDAO = new LibroDAO();
            
            boolean exito = libroDAO.eliminarLibro(idLibro);
            
            if (exito) {
                response.sendRedirect(request.getContextPath() + "/pantallas/CatalogoPaginaIncio.jsp?mensaje=libro_eliminado");
            } else {
                response.sendRedirect(request.getContextPath() + "/pantallas/CatalogoPaginaIncio.jsp?error=error_eliminar_libro");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/pantallas/CatalogoPaginaIncio.jsp?error=id_invalido");
        }
    }

    private String procesarPortada(HttpServletRequest request, HttpServletResponse response, int usuarioId) 
            throws ServletException, IOException {
        
        Part filePart = request.getPart("portada");
        
        if (filePart != null && filePart.getSize() > 0 && filePart.getContentType().startsWith("image/")) {
            // Validar tipo de archivo
            String contentType = filePart.getContentType();
            if (!contentType.equals("image/jpeg") && !contentType.equals("image/png")) {
                response.sendRedirect(request.getContextPath() + "/pantallas/CatalogoPaginaIncio.jsp?error=tipo_archivo_invalido");
                return null;
            }
            
            // Validar tamaño del archivo (máximo 2MB)
            if (filePart.getSize() > 2 * 1024 * 1024) {
                response.sendRedirect(request.getContextPath() + "/pantallas/CatalogoPaginaIncio.jsp?error=archivo_demasiado_grande");
                return null;
            }
            
            // Generar nombre único para el archivo
            String fileName = "libro_" + System.currentTimeMillis() + "_" + usuarioId;
            String extension = contentType.equals("image/jpeg") ? ".jpg" : ".png";
            fileName += extension;
            
            // Guardar el archivo
            Path filePath = Paths.get(uploadPath, fileName);
            try (InputStream fileContent = filePart.getInputStream()) {
                Files.copy(fileContent, filePath, StandardCopyOption.REPLACE_EXISTING);
                System.out.println("✅ Portada de libro guardada en: " + filePath.toString());
            }
            
            return "uploads/libros/" + fileName;
        }
        
        return null;
    }
private void eliminarArchivo(String fileUrl) {
    if (fileUrl != null) {
        try {
            // ✅ CORREGIDO: Quitar "uploads/" del path para encontrar el archivo físico
            String fileName = fileUrl.replace("uploads/libros/", "");
            Files.deleteIfExists(Paths.get(uploadPath, fileName));
        } catch (IOException e) {
            System.out.println("No se pudo eliminar el archivo: " + e.getMessage());
        }
    }
}

    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                 .replace("\"", "\\\"")
                 .replace("\n", "\\n")
                 .replace("\r", "\\r")
                 .replace("\t", "\\t");
    }
}