package Servlets;

import DAO.UsuarioDAO;
import modelos.Usuario;
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@WebServlet("/editar-perfil")
@MultipartConfig(
    maxFileSize = 2 * 1024 * 1024, // 2MB
    maxRequestSize = 5 * 1024 * 1024 // 5MB
)
public class EditarPerfilServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/pantallas/Inicio-Sesion.jsp");
            return;
        }

        Usuario usuarioSesion = (Usuario) session.getAttribute("usuario");
        String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
        
        // Crear directorio si no existe
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        try {
            // Obtener parámetros del formulario
            int idUsuario = Integer.parseInt(request.getParameter("idUsuario"));
            String nombre = request.getParameter("nombre");
            String usuario = request.getParameter("usuario");
            String correo = request.getParameter("correo");
            String fechaNacimientoStr = request.getParameter("fechaNacimiento");
            String password = request.getParameter("password");
            
            // Validar que el usuario edite solo su propio perfil
            if (idUsuario != usuarioSesion.getIdUsuario()) {
                response.sendRedirect(request.getContextPath() + "/pantallas/perfil.jsp?error=no_autorizado");
                return;
            }

            // Validaciones básicas
            if (nombre == null || nombre.trim().isEmpty() || 
                usuario == null || usuario.trim().isEmpty() || 
                correo == null || correo.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/pantallas/perfil.jsp?error=campos_vacios");
                return;
            }

            // Validar longitud de usuario
            if (usuario.trim().length() < 3) {
                response.sendRedirect(request.getContextPath() + "/pantallas/perfil.jsp?error=usuario_corto");
                return;
            }

            // Validar formato de correo
            if (!correo.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
                response.sendRedirect(request.getContextPath() + "/pantallas/perfil.jsp?error=correo_invalido");
                return;
            }

            // Validar contraseña si se proporcionó
            if (password != null && !password.trim().isEmpty() && password.trim().length() < 6) {
                response.sendRedirect(request.getContextPath() + "/pantallas/perfil.jsp?error=password_corta");
                return;
            }

            UsuarioDAO usuarioDAO = new UsuarioDAO();
            
            // Verificar si el usuario ya existe (excluyendo al usuario actual)
            if (!usuario.equals(usuarioSesion.getNombreUsuario()) && 
                usuarioDAO.existeUsuarioPorNombre(usuario)) {
                response.sendRedirect(request.getContextPath() + "/pantallas/perfil.jsp?error=usuario_duplicado");
                return;
            }

            // Verificar si el correo ya existe (excluyendo al usuario actual)
            if (!correo.equals(usuarioSesion.getCorreo()) && 
                usuarioDAO.existeUsuarioPorCorreo(correo)) {
                response.sendRedirect(request.getContextPath() + "/pantallas/perfil.jsp?error=correo_duplicado");
                return;
            }

            // Procesar archivo de imagen
            String nombreArchivo = null;
            Part filePart = request.getPart("fotoPerfil");
            
            if (filePart != null && filePart.getSize() > 0) {
                // Validar tipo de archivo
                String contentType = filePart.getContentType();
                if (!contentType.startsWith("image/")) {
                    response.sendRedirect(request.getContextPath() + "/pantallas/perfil.jsp?error=tipo_archivo_invalido");
                    return;
                }

                // Validar tamaño
                if (filePart.getSize() > 2 * 1024 * 1024) {
                    response.sendRedirect(request.getContextPath() + "/pantallas/perfil.jsp?error=archivo_demasiado_grande");
                    return;
                }

                // Generar nombre único para el archivo
                String extension = "";
                if (contentType.equals("image/jpeg")) {
                    extension = ".jpg";
                } else if (contentType.equals("image/png")) {
                    extension = ".png";
                } else if (contentType.equals("image/gif")) {
                    extension = ".gif";
                }

                nombreArchivo = "perfil_" + idUsuario + "_" + System.currentTimeMillis() + extension;
                
                // Guardar archivo
                String filePath = uploadPath + File.separator + nombreArchivo;
                filePart.write(filePath);
            }

            // Crear objeto usuario actualizado
            Usuario usuarioActualizado = new Usuario();
            usuarioActualizado.setIdUsuario(idUsuario);
            usuarioActualizado.setNombre(nombre.trim());
            usuarioActualizado.setNombreUsuario(usuario.trim());
            usuarioActualizado.setCorreo(correo.trim());
            
            // Manejar fecha de nacimiento
            if (fechaNacimientoStr != null && !fechaNacimientoStr.trim().isEmpty()) {
                java.sql.Date fechaNacimiento = java.sql.Date.valueOf(fechaNacimientoStr);
                usuarioActualizado.setFechaNacimiento(fechaNacimiento);
            } else {
                usuarioActualizado.setFechaNacimiento(usuarioSesion.getFechaNacimiento());
            }
            
            // Manejar contraseña
            if (password != null && !password.trim().isEmpty()) {
                usuarioActualizado.setContrasena(password.trim());
            } else {
                // Mantener la contraseña actual
                usuarioActualizado.setContrasena(usuarioSesion.getContrasena());
            }
            
            // Manejar foto de perfil
            if (nombreArchivo != null) {
                usuarioActualizado.setUrlFoto(nombreArchivo);
            } else {
                // Mantener la foto actual
                usuarioActualizado.setUrlFoto(usuarioSesion.getUrlFoto());
            }

            // Actualizar en la base de datos
            boolean exito = usuarioDAO.actualizarUsuario(usuarioActualizado);
            
            if (exito) {
                // Actualizar usuario en sesión
                Usuario usuarioCompleto = usuarioDAO.obtenerUsuarioPorId(idUsuario);
                session.setAttribute("usuario", usuarioCompleto);
                
                response.sendRedirect(request.getContextPath() + "/pantallas/perfil.jsp?mensaje=perfil_actualizado");
            } else {
                response.sendRedirect(request.getContextPath() + "/pantallas/perfil.jsp?error=error_actualizacion");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/pantallas/perfil.jsp?error=error_general");
        }
    }
}