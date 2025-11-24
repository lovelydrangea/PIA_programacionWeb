package Servlets;

import DAO.LibroDAO;
import DAO.UsuarioDAO;
import modelos.Libro;
import modelos.Usuario;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/buscar-libros")
public class BuscarLibrosServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // ✅ OBTENER USUARIO DE LA SESIÓN Y PASAR AL JSP
        HttpSession session = request.getSession(false);
        if (session != null) {
            Usuario usuario = (Usuario) session.getAttribute("usuario");
            if (usuario != null) {
                // ✅ PASAR DATOS DEL USUARIO AL JSP
                request.setAttribute("usuario", usuario);
                request.setAttribute("usuarioId", usuario.getIdUsuario());
                
                // ✅ VERIFICAR SI ES ADMINISTRADOR
                UsuarioDAO usuarioDAO = new UsuarioDAO();
                boolean esAdmin = usuarioDAO.esAdministrador(usuario.getIdUsuario());
                request.setAttribute("esAdmin", esAdmin);
            }
        }
        
        String query = request.getParameter("q");
        
        if (query != null && !query.trim().isEmpty()) {
            LibroDAO libroDAO = new LibroDAO();
            
            // ✅ PARÁMETROS DE PAGINACIÓN PARA BÚSQUEDA
            int librosPorPagina = 10;
            int paginaActual = 1;
            
            // Obtener página actual del parámetro
            String paginaParam = request.getParameter("pagina");
            if (paginaParam != null && !paginaParam.trim().isEmpty()) {
                try {
                    paginaActual = Integer.parseInt(paginaParam);
                    if (paginaActual < 1) paginaActual = 1;
                } catch (NumberFormatException e) {
                    paginaActual = 1;
                }
            }
            
            // ✅ OBTENER LIBROS PAGINADOS DE BÚSQUEDA
            List<Libro> librosEncontrados = libroDAO.buscarLibrosPaginados(query.trim(), paginaActual, librosPorPagina);
            int totalResultados = libroDAO.contarLibrosBusqueda(query.trim());
            int totalPaginas = (int) Math.ceil((double) totalResultados / librosPorPagina);
            if (totalPaginas < 1) totalPaginas = 1;
            
            // Ajustar página actual si es mayor al total
            if (paginaActual > totalPaginas) {
                paginaActual = totalPaginas;
            }
            
            // ✅ SIEMPRE enviar los libros encontrados, aunque esté vacía la lista
            request.setAttribute("librosEncontrados", librosEncontrados);
            request.setAttribute("terminoBusqueda", query.trim());
            request.setAttribute("totalResultados", totalResultados);
            request.setAttribute("esBusqueda", true);
            
            // ✅ AGREGAR ATRIBUTOS DE PAGINACIÓN
            request.setAttribute("paginaActual", paginaActual);
            request.setAttribute("totalPaginas", totalPaginas);
            request.setAttribute("totalLibros", totalResultados);
            
        } else {
            // Si no hay término de búsqueda, redirigir al catálogo normal
            response.sendRedirect(request.getContextPath() + "/pantallas/CatalogoPaginaIncio.jsp");
            return;
        }
        
        request.getRequestDispatcher("/pantallas/CatalogoPaginaIncio.jsp").forward(request, response);
    }
}