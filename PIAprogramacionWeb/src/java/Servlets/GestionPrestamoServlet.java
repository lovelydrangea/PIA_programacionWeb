package Servlets;

import DAO.PrestamoDAO;
import DAO.LibroDAO;
import DAO.UsuarioDAO;
import java.io.IOException;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import modelos.Libro;
import modelos.Prestamo;

@WebServlet("/gestion-prestamo")
public class GestionPrestamoServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/pantallas/Inicio-Sesion.jsp");
            return;
        }

        // Verificar que es administrador
        UsuarioDAO usuarioDAO = new UsuarioDAO();
        int idAdmin = (Integer) session.getAttribute("usuarioId");
        if (!usuarioDAO.esAdministrador(idAdmin)) {
            response.sendRedirect(request.getContextPath() + "/pantallas/CatalogoPaginaIncio.jsp?error=acceso_denegado");
            return;
        }

        try {
            String accion = request.getParameter("accion");
            int idPrestamo = Integer.parseInt(request.getParameter("idPrestamo"));

            PrestamoDAO prestamoDAO = new PrestamoDAO();
            LibroDAO libroDAO = new LibroDAO();

            boolean exito = false;

        if ("aprobar".equals(accion)) {
            // Aprobar préstamo
            exito = prestamoDAO.aprobarPrestamo(idPrestamo, idAdmin);

            if (exito) {
                // Actualizar estado a activo
                prestamoDAO.actualizarEstadoPrestamo(idPrestamo, "activo", null);

                // Reducir ejemplares disponibles (USANDO EL MÉTODO ESPECÍFICO)
                Prestamo prestamo = prestamoDAO.obtenerPrestamoPorId(idPrestamo);

                if (prestamo != null) {
                    Libro libro = libroDAO.obtenerLibroPorId(prestamo.getIdLibro());

                    if (libro != null) {
                        int nuevosEjemplares = libro.getEjemplaresDisponibles() - 1;
                        exito = libroDAO.actualizarEjemplaresDisponibles(libro.getId(), nuevosEjemplares);

                        if (!exito) {
                            System.out.println("❌ Error al actualizar ejemplares al aprobar préstamo");
                        }
                    } else {
                        System.out.println("❌ Libro no encontrado al aprobar préstamo ID: " + idPrestamo);
                        exito = false;
                    }
                } else {
                    System.out.println("❌ Préstamo no encontrado al aprobar ID: " + idPrestamo);
                    exito = false;
                }
            }

        } else if ("rechazar".equals(accion)) {
            // Rechazar préstamo
            exito = prestamoDAO.actualizarEstadoPrestamo(idPrestamo, "rechazado", null);

        } else if ("devolver".equals(accion)) {
            // Marcar como devuelto
            exito = prestamoDAO.actualizarEstadoPrestamo(idPrestamo, "devuelto", new java.sql.Date(System.currentTimeMillis()));

            if (exito) {
                // Obtener información del préstamo
                Prestamo prestamo = prestamoDAO.obtenerPrestamoPorId(idPrestamo);

                if (prestamo != null) {
                    // Aumentar ejemplares disponibles usando el método específico
                    Libro libro = libroDAO.obtenerLibroPorId(prestamo.getIdLibro());
                    if (libro != null) {
                        int nuevosEjemplares = libro.getEjemplaresDisponibles() + 1;
                        exito = libroDAO.actualizarEjemplaresDisponibles(libro.getId(), nuevosEjemplares);

                        if (!exito) {
                            System.out.println("❌ Error al actualizar ejemplares al devolver préstamo");
                        }
                    } else {
                        System.out.println("❌ Libro no encontrado al devolver préstamo ID: " + idPrestamo);
                        exito = false;
                    }
                } else {
                    System.out.println("❌ Préstamo no encontrado al devolver ID: " + idPrestamo);
                    exito = false;
                }
            }
        }
            if (exito) {
                response.sendRedirect(request.getContextPath() + "/pantallas/CatalogoPaginaIncio.jsp?mensaje=prestamo_" + accion + "ado");
            } else {
                response.sendRedirect(request.getContextPath() + "/pantallas/CatalogoPaginaIncio.jsp?error=error_" + accion + "_prestamo");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/pantallas/CatalogoPaginaIncio.jsp?error=error_general");
        }
    }
}
