package Servlets;

import DAO.PublicacionDAO;
import modelos.Publicacion;
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

@WebServlet("/publicacion")
@MultipartConfig(
    maxFileSize = 1024 * 1024 * 5,      // 5 MB
    maxRequestSize = 1024 * 1024 * 10,  // 10 MB
    fileSizeThreshold = 1024 * 1024     // 1 MB
)
public class PublicacionServlet extends HttpServlet {

    private String uploadPath;

    @Override
    public void init() throws ServletException {
        // Directorio para guardar imágenes de publicaciones
        uploadPath = getServletContext().getRealPath("") + "uploads/publicaciones/";
        
        // Crear el directorio si no existe
        try {
            Files.createDirectories(Paths.get(uploadPath));
            System.out.println("📁 Directorio de publicaciones creado en: " + uploadPath);
        } catch (IOException e) {
            throw new ServletException("No se pudo crear el directorio de publicaciones", e);
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

        try {
            // Obtener parámetros del formulario
            String titulo = request.getParameter("titulo");
            String contenido = request.getParameter("contenido");
            int autorId = Integer.parseInt(request.getParameter("autorId"));

            // Validaciones básicas
            if (titulo == null || contenido == null || 
                titulo.trim().isEmpty() || contenido.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/pantallas/CatalogoPaginaIncio.jsp?error=campos_vacios");
                return;
            }

            // Procesar la imagen de la publicación
            String imagenUrl = null;
            Part filePart = request.getPart("imagen");
            
            if (filePart != null && filePart.getSize() > 0 && filePart.getContentType().startsWith("image/")) {
                // Validar tipo de archivo
                String contentType = filePart.getContentType();
                if (!contentType.equals("image/jpeg") && !contentType.equals("image/png") && !contentType.equals("image/gif")) {
                    response.sendRedirect(request.getContextPath() + "/pantallas/CatalogoPaginaIncio.jsp?error=tipo_archivo_invalido");
                    return;
                }
                
                // Validar tamaño del archivo (máximo 3MB)
                if (filePart.getSize() > 3 * 1024 * 1024) {
                    response.sendRedirect(request.getContextPath() + "/pantallas/CatalogoPaginaIncio.jsp?error=archivo_demasiado_grande");
                    return;
                }
                
                // Generar nombre único para el archivo
                String fileName = "pub_" + System.currentTimeMillis() + "_" + autorId;
                String extension = "";
                
                if (contentType.equals("image/jpeg")) {
                    extension = ".jpg";
                } else if (contentType.equals("image/png")) {
                    extension = ".png";
                } else if (contentType.equals("image/gif")) {
                    extension = ".gif";
                }
                
                fileName += extension;
                
                // Guardar el archivo
                Path filePath = Paths.get(uploadPath, fileName);
                try (InputStream fileContent = filePart.getInputStream()) {
                    Files.copy(fileContent, filePath, StandardCopyOption.REPLACE_EXISTING);
                    System.out.println("✅ Imagen de publicación guardada en: " + filePath.toString());
                }
                
                imagenUrl = "publicaciones/" + fileName;
            }

            // Crear objeto Publicacion
            Publicacion nuevaPublicacion = new Publicacion();
            nuevaPublicacion.setTitulo(titulo.trim());
            nuevaPublicacion.setContenido(contenido.trim());
            nuevaPublicacion.setImagenUrl(imagenUrl);
            nuevaPublicacion.setIdUsuario(autorId);

            // Guardar en la base de datos
            PublicacionDAO dao = new PublicacionDAO();
            boolean exito = dao.crearPublicacion(nuevaPublicacion);

            if (exito) {
                response.sendRedirect(request.getContextPath() + "/pantallas/CatalogoPaginaIncio.jsp?publicacion=exitoso");
            } else {
                // Si falla, eliminar la imagen subida
                if (imagenUrl != null) {
                    try {
                        Files.deleteIfExists(Paths.get(uploadPath, imagenUrl.replace("publicaciones/", "")));
                    } catch (IOException e) {
                        System.out.println("No se pudo eliminar la imagen después de fallo: " + e.getMessage());
                    }
                }
                response.sendRedirect(request.getContextPath() + "/pantallas/CatalogoPaginaIncio.jsp?error=publicacion_fallida");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/pantallas/CatalogoPaginaIncio.jsp?error=general");
        }
    }
}