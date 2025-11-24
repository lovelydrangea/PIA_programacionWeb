package Servlets;

import DAO.UsuarioDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/verificar-usuario")
public class VerificarUsuarioServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String usuario = request.getParameter("usuario");
        UsuarioDAO usuarioDAO = new UsuarioDAO();
        
        boolean existe = usuarioDAO.existeUsuarioPorNombre(usuario);
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write("{\"existe\": " + existe + "}");
    }
}