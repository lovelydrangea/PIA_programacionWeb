package Servlets;

import DAO.PrestamoDAO;
import DAO.LibroDAO;
import DAO.UsuarioDAO;
import modelos.Prestamo;
import java.io.IOException;
import java.sql.Date;
import java.util.Calendar;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.net.URLEncoder;

@WebServlet("/prestamo")
public class PrestamoServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/pantallas/Inicio-Sesion.jsp");
            return;
        }

        try {
            // Obtener parámetros del préstamo
            int idLibro = Integer.parseInt(request.getParameter("idLibro"));
            int idUsuario = Integer.parseInt(request.getParameter("idUsuario"));
            String observaciones = request.getParameter("observaciones");

            // ✅ OBTENER PARÁMETROS DE CONTEXTO DE BÚSQUEDA
            String terminoBusqueda = request.getParameter("terminoBusqueda");
            String pagina = request.getParameter("pagina");
            String esBusqueda = request.getParameter("esBusqueda");
            boolean modoBusqueda = "true".equals(esBusqueda) && terminoBusqueda != null && !terminoBusqueda.trim().isEmpty();

            // Validar que el libro existe
            LibroDAO libroDAO = new LibroDAO();
            var libro = libroDAO.obtenerTodosLibros().stream()
                    .filter(l -> l.getId() == idLibro)
                    .findFirst();

            if (libro.isEmpty()) {
                redirectConContexto(request, response, modoBusqueda, terminoBusqueda, pagina, "error=libro_no_encontrado");
                return;
            }

            // Validar disponibilidad
            if (libro.get().getEjemplaresDisponibles() <= 0) {
                redirectConContexto(request, response, modoBusqueda, terminoBusqueda, pagina, "error=libro_no_disponible");
                return;
            }

            // Validar que el usuario no tiene préstamos activos del mismo libro
            PrestamoDAO prestamoDAO = new PrestamoDAO();
            boolean tienePrestamoActivo = prestamoDAO.obtenerPrestamosPorUsuario(idUsuario).stream()
                    .anyMatch(p -> p.getIdLibro() == idLibro && p.estaActivo());

            if (tienePrestamoActivo) {
                redirectConContexto(request, response, modoBusqueda, terminoBusqueda, pagina, "error=ya_tiene_prestamo");
                return;
            }

            // Calcular fecha de devolución (15 días desde hoy)
            Calendar calendar = Calendar.getInstance();
            calendar.add(Calendar.DAY_OF_YEAR, 15);
            Date fechaDevolucionEstimada = new Date(calendar.getTimeInMillis());

            // Crear objeto préstamo (estado PENDIENTE inicialmente)
            Prestamo prestamo = new Prestamo();
            prestamo.setIdLibro(idLibro);
            prestamo.setIdUsuario(idUsuario);
            prestamo.setFechaDevolucionEstimada(fechaDevolucionEstimada);
            prestamo.setObservaciones(observaciones);
            prestamo.setEstado("pendiente"); // Estado inicial

            // Guardar préstamo
            boolean exito = prestamoDAO.crearPrestamo(prestamo);

            if (exito) {
                redirectConContexto(request, response, modoBusqueda, terminoBusqueda, pagina, "mensaje=prestamo_solicitado_pendiente");
            } else {
                redirectConContexto(request, response, modoBusqueda, terminoBusqueda, pagina, "error=error_solicitar_prestamo");
            }

        } catch (NumberFormatException e) {
            e.printStackTrace();
            // Obtener parámetros de contexto para el error también
            String terminoBusqueda = request.getParameter("terminoBusqueda");
            String pagina = request.getParameter("pagina");
            String esBusqueda = request.getParameter("esBusqueda");
            boolean modoBusqueda = "true".equals(esBusqueda) && terminoBusqueda != null && !terminoBusqueda.trim().isEmpty();
            
            redirectConContexto(request, response, modoBusqueda, terminoBusqueda, pagina, "error=datos_invalidos");
        } catch (Exception e) {
            e.printStackTrace();
            // Obtener parámetros de contexto para el error también
            String terminoBusqueda = request.getParameter("terminoBusqueda");
            String pagina = request.getParameter("pagina");
            String esBusqueda = request.getParameter("esBusqueda");
            boolean modoBusqueda = "true".equals(esBusqueda) && terminoBusqueda != null && !terminoBusqueda.trim().isEmpty();
            
            redirectConContexto(request, response, modoBusqueda, terminoBusqueda, pagina, "error=error_general");
        }
    }

    /**
     * ✅ MÉTODO AUXILIAR PARA REDIRIGIR MANTENIENDO EL CONTEXTO DE BÚSQUEDA
     */
    private void redirectConContexto(HttpServletRequest request, HttpServletResponse response, 
                                   boolean modoBusqueda, String terminoBusqueda, String pagina, 
                                   String parametroMensaje) throws IOException {
        
        String redirectURL;
        
        if (modoBusqueda && terminoBusqueda != null && !terminoBusqueda.trim().isEmpty()) {
            // ✅ Redirigir al servlet de búsqueda manteniendo los parámetros
            redirectURL = request.getContextPath() + "/buscar-libros?q=" + 
                URLEncoder.encode(terminoBusqueda.trim(), "UTF-8");
            
            // Agregar página si existe
            if (pagina != null && !pagina.trim().isEmpty()) {
                redirectURL += "&pagina=" + pagina;
            }
            
            // Agregar mensaje o error
            redirectURL += "&" + parametroMensaje;
            
        } else {
            // ✅ Redirigir al catálogo normal
            redirectURL = request.getContextPath() + "/pantallas/CatalogoPaginaIncio.jsp";
            
            // Agregar página si existe
            if (pagina != null && !pagina.trim().isEmpty()) {
                redirectURL += "?pagina=" + pagina;
                // Agregar mensaje o error
                redirectURL += "&" + parametroMensaje;
            } else {
                // Agregar mensaje o error
                redirectURL += "?" + parametroMensaje;
            }
        }
        
        response.sendRedirect(redirectURL);
    }
}