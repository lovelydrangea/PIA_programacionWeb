package Servlets;

import DAO.UsuarioDAO;
import modelos.Usuario;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.annotation.WebServlet;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1️⃣ Obtener datos del formulario
        String correo = request.getParameter("correo");
        String password = request.getParameter("password");

        // 2️⃣ Validar datos básicos
        if (correo == null || password == null || correo.trim().isEmpty() || password.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/pantallas/Inicio-Sesion.jsp?error=campos_vacios");
            return;
        }

        // 3️⃣ Consultar usuario en la base de datos
        UsuarioDAO dao = new UsuarioDAO();
        Usuario usuario = dao.iniciarSesion(correo.trim(), password.trim());

        // 4️⃣ Manejar respuesta
        if (usuario != null) {
            // Iniciar sesión
            HttpSession sesion = request.getSession();
            sesion.setAttribute("usuario", usuario);
            sesion.setAttribute("usuarioId", usuario.getIdUsuario());
            sesion.setAttribute("nombreUsuario", usuario.getNombreUsuario());
            sesion.setAttribute("correo", usuario.getCorreo());
            sesion.setAttribute("fotoPerfil", usuario.getUrlFoto());
            
            // Configurar tiempo de sesión (30 minutos)
            sesion.setMaxInactiveInterval(30 * 60);

            // Redirigir al catálogo
            response.sendRedirect(request.getContextPath() + "/pantallas/CatalogoPaginaIncio.jsp");

        } else {
            response.sendRedirect(request.getContextPath() + "/pantallas/Inicio-Sesion.jsp?error=credenciales_invalidas");
        }
    }
}