package Servlets;

import DAO.UsuarioDAO;
import modelos.Usuario;
import java.sql.Date;
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
import javax.servlet.http.Part;

@WebServlet("/registro")
@MultipartConfig(
    maxFileSize = 1024 * 1024 * 5,      // 5 MB
    maxRequestSize = 1024 * 1024 * 10,  // 10 MB
    fileSizeThreshold = 1024 * 1024     // 1 MB
)
public class RegistroServlet extends HttpServlet {

    private String uploadPath;

    @Override
    public void init() throws ServletException {
        // 🔥 CAMBIO IMPORTANTE: Guardar en web/uploads en lugar de build
        uploadPath = getServletContext().getRealPath("") + "uploads/";
        
        // Crear el directorio si no existe
        try {
            Files.createDirectories(Paths.get(uploadPath));
            System.out.println("📁 Directorio de uploads creado en: " + uploadPath);
        } catch (IOException e) {
            throw new ServletException("No se pudo crear el directorio de uploads", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // 1. Obtener parámetros del formulario
            String nombre = request.getParameter("nombre");
            String usuarioParam = request.getParameter("usuario");
            String fechaStr = request.getParameter("fechaNacimiento");
            String correo = request.getParameter("correo");
            String password = request.getParameter("password");

            // 2. Validaciones básicas
            if (nombre == null || usuarioParam == null || fechaStr == null || 
                correo == null || password == null ||
                nombre.trim().isEmpty() || usuarioParam.trim().isEmpty() || 
                fechaStr.trim().isEmpty() || correo.trim().isEmpty() || 
                password.trim().isEmpty()) {
                
                response.sendRedirect(request.getContextPath() + "/pantallas/registro-Sesion.jsp?error=campos_vacios");
                return;
            }

            // 3. Validar formato de correo básico
            if (!correo.contains("@") || !correo.contains(".")) {
                response.sendRedirect(request.getContextPath() + "/pantallas/registro-Sesion.jsp?error=correo_invalido");
                return;
            }

            // 4. Validar fecha (edad mínima 13 años)
            Date fechaNacimiento = Date.valueOf(fechaStr);
            java.util.Date fechaActual = new java.util.Date();
            java.util.Date fechaMinima = new java.util.Date(fechaActual.getTime() - (13L * 365 * 24 * 60 * 60 * 1000));
            
            if (fechaNacimiento.after(fechaMinima)) {
                response.sendRedirect(request.getContextPath() + "/pantallas/registro-Sesion.jsp?error=edad_insuficiente");
                return;
            }

            // 5. Procesar la imagen de perfil
            String urlFoto = null;
            Part filePart = request.getPart("fotoPerfil");
            
            if (filePart != null && filePart.getSize() > 0 && filePart.getContentType().startsWith("image/")) {
                // Validar tipo de archivo
                String contentType = filePart.getContentType();
                if (!contentType.equals("image/jpeg") && !contentType.equals("image/png") && !contentType.equals("image/gif")) {
                    response.sendRedirect(request.getContextPath() + "/pantallas/registro-Sesion.jsp?error=tipo_archivo_invalido");
                    return;
                }
                
                // Validar tamaño del archivo (máximo 2MB)
                if (filePart.getSize() > 2 * 1024 * 1024) {
                    response.sendRedirect(request.getContextPath() + "/pantallas/registro-Sesion.jsp?error=archivo_demasiado_grande");
                    return;
                }
                
                // Generar nombre único para el archivo
                String fileName = System.currentTimeMillis() + "_" + usuarioParam.replaceAll("[^a-zA-Z0-9]", "_");
                String extension = "";
                
                // Determinar extensión basada en el tipo MIME
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
                    System.out.println("✅ Imagen guardada en: " + filePath.toString());
                }
                
                // 🔥 CAMBIO IMPORTANTE: Guardar solo el nombre del archivo
                urlFoto = fileName;
            }

            // 6. Crear objeto Usuario
            Usuario nuevoUsuario = new Usuario(
                0,
                usuarioParam.trim(),
                nombre.trim(),
                fechaNacimiento,
                correo.trim().toLowerCase(),
                password,
                urlFoto  // Solo el nombre del archivo
            );

            // 7. Intentar registro
            UsuarioDAO dao = new UsuarioDAO();
            boolean exito = dao.registrar(nuevoUsuario);

            if (exito) {
                response.sendRedirect(request.getContextPath() + "/pantallas/Inicio-Sesion.jsp");
            } else {
                // Si falla el registro, eliminar la imagen subida
                if (urlFoto != null) {
                    try {
                        Files.deleteIfExists(Paths.get(uploadPath, urlFoto));
                    } catch (IOException e) {
                        System.out.println("No se pudo eliminar la imagen después de fallo de registro: " + e.getMessage());
                    }
                }
                response.sendRedirect(request.getContextPath() + "/pantallas/registro-Sesion.jsp?error=usuario_duplicado");
            }

        } catch (IllegalArgumentException e) {
            response.sendRedirect(request.getContextPath() + "/pantallas/registro-Sesion.jsp?error=fecha_invalida");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/pantallas/registro-Sesion.jsp?error=general");
        }
    }
}