package Servlets;

import DAO.UsuarioDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/verificar-correo")
public class VerificarCorreoServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String correo = request.getParameter("correo");
        UsuarioDAO usuarioDAO = new UsuarioDAO();
        
        boolean existe = usuarioDAO.existeUsuarioPorCorreo(correo);
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write("{\"existe\": " + existe + "}");
    }
}