package Filters;

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;

@WebFilter({
    "/pantallas/CatalogoPaginaIncio.jsp",
    "/pantallas/perfil.jsp", 
    "/pantallas/configuracion.jsp",
    "/check-session"
})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        // 🚫 CACHE CONTROL AGGRESIVO - IMPIDE GUARDAR EN CACHÉ
        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate, private, max-age=0");
        res.setHeader("Pragma", "no-cache");
        res.setDateHeader("Expires", -1);
        res.setHeader("X-Content-Type-Options", "nosniff");
        res.setHeader("X-Frame-Options", "DENY");

        boolean loggedIn = (session != null && session.getAttribute("usuario") != null);

        if (loggedIn) {
            // Usuario válido, permitir acceso
            chain.doFilter(request, response);
        } else {
            // 🚨 Usuario NO logueado - Redirigir AL INSTANTE al login
            // Usar replace para que no quede en el historial
            res.sendRedirect(req.getContextPath() + "/pantallas/Inicio-Sesion.jsp?session=expired");
        }
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void destroy() {}
}