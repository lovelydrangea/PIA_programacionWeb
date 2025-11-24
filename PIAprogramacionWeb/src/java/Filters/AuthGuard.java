package Filters;

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;

@WebFilter("/*")
public class AuthGuard implements Filter {
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);
        
        String contextPath = req.getContextPath();
        String requestURI = req.getRequestURI();
        
        // 🚫 Headers anti-cache para todas las páginas
        res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        res.setHeader("Pragma", "no-cache");
        res.setDateHeader("Expires", 0);
        
        // ✅ URLs públicas (no requieren autenticación)
        boolean isPublicResource = isPublicResource(requestURI, contextPath);
        
        // ✅ Verificar si el usuario está autenticado
        boolean isAuthenticated = (session != null && session.getAttribute("usuario") != null);
        
        // 🔒 Lógica de protección de rutas
        if (isPublicResource) {
            // Si es un recurso público y el usuario YA está autenticado, redirigir al catálogo
            if (isAuthenticated && isAuthPage(requestURI, contextPath)) {
                res.sendRedirect(contextPath + "/pantallas/CatalogoPaginaIncio.jsp");
                return;
            }
            chain.doFilter(request, response);
        } else {
            // Si es una ruta protegida y NO está autenticado, redirigir al login
            if (!isAuthenticated) {
                res.sendRedirect(contextPath + "/pantallas/Inicio-Sesion.jsp?error=access_denied");
                return;
            }
            chain.doFilter(request, response);
        }
    }
    
    /**
     * Define qué recursos son públicos
     */
    private boolean isPublicResource(String requestURI, String contextPath) {
        String uriWithoutContext = requestURI.substring(contextPath.length());
        
        return uriWithoutContext.startsWith("/pantallas/Inicio-Sesion.jsp") ||
               uriWithoutContext.startsWith("/pantallas/registro-Sesion.jsp") ||
               uriWithoutContext.startsWith("/pantallas/WelcomeIn.jsp") ||
               uriWithoutContext.equals("/login") ||
               uriWithoutContext.equals("/registro") ||
               uriWithoutContext.equals("/check-session") ||
               uriWithoutContext.startsWith("/css/") ||
               uriWithoutContext.startsWith("/js/") ||
               uriWithoutContext.startsWith("/node_modules/") ||
               uriWithoutContext.startsWith("/uploads/") ||
               uriWithoutContext.startsWith("/Estilos/") ||
               uriWithoutContext.startsWith("/Logo/") ||
               uriWithoutContext.equals("/") ||
               uriWithoutContext.equals("");
    }
    
    /**
     * Define qué páginas son de autenticación (login/registro)
     */
    private boolean isAuthPage(String requestURI, String contextPath) {
        String uriWithoutContext = requestURI.substring(contextPath.length());
        
        return uriWithoutContext.startsWith("/pantallas/Inicio-Sesion.jsp") ||
               uriWithoutContext.equals("/login");
               
    }
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}
    
    @Override
    public void destroy() {}
}