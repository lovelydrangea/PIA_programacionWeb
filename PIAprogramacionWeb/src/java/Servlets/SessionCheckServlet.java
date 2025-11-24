package Servlets;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/check-session")
public class SessionCheckServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        boolean sessionValid = (session != null && session.getAttribute("usuario") != null);
        
        // Headers anti-cache
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        if (sessionValid) {
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write("{\"valid\": true}");
        } else {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"valid\": false}");
        }
    }
}