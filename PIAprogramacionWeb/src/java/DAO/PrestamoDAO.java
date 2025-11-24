package DAO;

import modelos.Prestamo;
import clasesAtrabajar.ConexionBD;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PrestamoDAO {

    /**
     * Crea un nuevo préstamo en la base de datos
     * @param prestamo
     * @return 
     */
    public boolean crearPrestamo(Prestamo prestamo) {
        String sql = "INSERT INTO prestamo (id_libro, id_usuario, fecha_devolucion_estimada, " +
                    "observaciones, id_admin_aprobo) VALUES (?, ?, ?, ?, ?)";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return false;
        }

        try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, prestamo.getIdLibro());
            ps.setInt(2, prestamo.getIdUsuario());
            ps.setDate(3, prestamo.getFechaDevolucionEstimada());
            ps.setString(4, prestamo.getObservaciones());
            
            if (prestamo.getIdAdminAprobo() != null) {
                ps.setInt(5, prestamo.getIdAdminAprobo());
            } else {
                ps.setNull(5, Types.INTEGER);
            }

            int filas = ps.executeUpdate();

            if (filas > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        prestamo.setId(rs.getInt(1));
                    }
                }
                return true;
            }

        } catch (SQLException e) {
            System.out.println("⚠️ Error al crear préstamo: " + e.getMessage());
        }

        return false;
    }

    /**
     * Obtiene todos los préstamos de un usuario
     * @param idUsuario
     * @return 
     */
    public List<Prestamo> obtenerPrestamosPorUsuario(int idUsuario) {
        List<Prestamo> prestamos = new ArrayList<>();
        String sql = "SELECT p.*, l.titulo as libro_titulo, l.autor as libro_autor, " +
                    "u.nombre as usuario_nombre, u.usuario as usuario_usuario " +
                    "FROM prestamo p " +
                    "JOIN libro l ON p.id_libro = l.id " +
                    "JOIN usuario u ON p.id_usuario = u.id " +
                    "WHERE p.id_usuario = ? " +
                    "ORDER BY p.fecha_prestamo DESC";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return prestamos;
        }

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Prestamo prestamo = mapearPrestamoDesdeResultSet(rs);
                    prestamos.add(prestamo);
                }
            }

        } catch (SQLException e) {
            System.out.println("⚠️ Error al obtener préstamos por usuario: " + e.getMessage());
        }

        return prestamos;
    }

    /**
     * Obtiene todos los préstamos activos
     */
    public List<Prestamo> obtenerPrestamosActivos() {
        List<Prestamo> prestamos = new ArrayList<>();
        String sql = "SELECT p.*, l.titulo as libro_titulo, l.autor as libro_autor, " +
                    "u.nombre as usuario_nombre, u.usuario as usuario_usuario " +
                    "FROM prestamo p " +
                    "JOIN libro l ON p.id_libro = l.id " +
                    "JOIN usuario u ON p.id_usuario = u.id " +
                    "WHERE p.estado = 'activo' " +
                    "ORDER BY p.fecha_devolucion_estimada ASC";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return prestamos;
        }

        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Prestamo prestamo = mapearPrestamoDesdeResultSet(rs);
                prestamos.add(prestamo);
            }

        } catch (SQLException e) {
            System.out.println("⚠️ Error al obtener préstamos activos: " + e.getMessage());
        }

        return prestamos;
    }

    /**
     * Obtiene todos los préstamos (para administradores)
     * @return 
     */
    public List<Prestamo> obtenerTodosPrestamos() {
        List<Prestamo> prestamos = new ArrayList<>();
        String sql = "SELECT p.*, l.titulo as libro_titulo, l.autor as libro_autor, " +
                    "u.nombre as usuario_nombre, u.usuario as usuario_usuario, " +
                    "a.nombre as admin_nombre " +
                    "FROM prestamo p " +
                    "JOIN libro l ON p.id_libro = l.id " +
                    "JOIN usuario u ON p.id_usuario = u.id " +
                    "LEFT JOIN usuario a ON p.id_admin_aprobo = a.id " +
                    "ORDER BY p.fecha_prestamo DESC";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return prestamos;
        }

        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Prestamo prestamo = mapearPrestamoDesdeResultSet(rs);
                prestamos.add(prestamo);
            }

        } catch (SQLException e) {
            System.out.println("⚠️ Error al obtener todos los préstamos: " + e.getMessage());
        }

        return prestamos;
    }
    
    public int contarPrestamosActivos() {
        List<Prestamo> todosPrestamos = obtenerTodosPrestamos();
        return (int) todosPrestamos.stream()
                .filter(p -> "activo".equals(p.getEstado()))
                .count();
    }
     /**
     * Obtiene un préstamo por su ID
     */
    public Prestamo obtenerPrestamoPorId(int idPrestamo) {
        String sql = "SELECT p.*, l.titulo as libro_titulo, l.autor as libro_autor, " +
                    "u.nombre as usuario_nombre, u.usuario as usuario_usuario, " +
                    "a.nombre as admin_nombre " +
                    "FROM prestamo p " +
                    "JOIN libro l ON p.id_libro = l.id " +
                    "JOIN usuario u ON p.id_usuario = u.id " +
                    "LEFT JOIN usuario a ON p.id_admin_aprobo = a.id " +
                    "WHERE p.id = ?";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return null;
        }

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idPrestamo);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapearPrestamoDesdeResultSet(rs);
                }
            }

        } catch (SQLException e) {
            System.out.println("⚠️ Error al obtener préstamo por ID: " + e.getMessage());
        }

        return null;
    }

    /**
     * Actualiza el estado de un préstamo
     * @param idPrestamo
     * @param nuevoEstado
     * @param fechaDevolucionReal
     * @return 
     */
    public boolean actualizarEstadoPrestamo(int idPrestamo, String nuevoEstado, Date fechaDevolucionReal) {
        String sql = "UPDATE prestamo SET estado = ?, fecha_devolucion_real = ? WHERE id = ?";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return false;
        }

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, nuevoEstado);
            
            if (fechaDevolucionReal != null) {
                ps.setDate(2, fechaDevolucionReal);
            } else {
                ps.setNull(2, Types.DATE);
            }
            
            ps.setInt(3, idPrestamo);

            int filas = ps.executeUpdate();
            return filas > 0;

        } catch (SQLException e) {
            System.out.println("⚠️ Error al actualizar estado del préstamo: " + e.getMessage());
        }

        return false;
    }

    /**
     * Aprueba un préstamo (solo administradores)
     */
    public boolean aprobarPrestamo(int idPrestamo, int idAdmin) {
        String sql = "UPDATE prestamo SET id_admin_aprobo = ? WHERE id = ?";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return false;
        }

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idAdmin);
            ps.setInt(2, idPrestamo);

            int filas = ps.executeUpdate();
            return filas > 0;

        } catch (SQLException e) {
            System.out.println("⚠️ Error al aprobar préstamo: " + e.getMessage());
        }

        return false;
    }

    /**
     * Método auxiliar para mapear un ResultSet a un objeto Prestamo
     */
    private Prestamo mapearPrestamoDesdeResultSet(ResultSet rs) throws SQLException {
        Prestamo prestamo = new Prestamo();
        prestamo.setId(rs.getInt("id"));
        prestamo.setIdLibro(rs.getInt("id_libro"));
        prestamo.setIdUsuario(rs.getInt("id_usuario"));
        prestamo.setFechaPrestamo(rs.getTimestamp("fecha_prestamo"));
        prestamo.setFechaDevolucionEstimada(rs.getDate("fecha_devolucion_estimada"));
        prestamo.setFechaDevolucionReal(rs.getDate("fecha_devolucion_real"));
        prestamo.setEstado(rs.getString("estado"));
        prestamo.setObservaciones(rs.getString("observaciones"));
        
        Integer idAdmin = rs.getInt("id_admin_aprobo");
        if (!rs.wasNull()) {
            prestamo.setIdAdminAprobo(idAdmin);
        }

        return prestamo;
    }

    /**
     * Verifica si un usuario tiene préstamos activos
     * @param idUsuario
     * @return 
     */
    public boolean tienePrestamosActivos(int idUsuario) {
        String sql = "SELECT COUNT(*) FROM prestamo WHERE id_usuario = ? AND estado = 'activo'";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return false;
        }

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }

        } catch (SQLException e) {
            System.out.println("⚠️ Error al verificar préstamos activos: " + e.getMessage());
        }

        return false;
    }

    /**
     * Verifica si un libro está prestado actualmente
     * @param idLibro
     * @return 
     */
    public boolean estaLibroPrestado(int idLibro) {
        String sql = "SELECT COUNT(*) FROM prestamo WHERE id_libro = ? AND estado = 'activo'";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return false;
        }

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idLibro);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }

        } catch (SQLException e) {
            System.out.println("⚠️ Error al verificar si libro está prestado: " + e.getMessage());
        }

        return false;
    }
    /**
     * Método para actualizar préstamos atrasados
     */
    public int actualizarPrestamosAtrasados() {
        String sql = "UPDATE prestamo SET estado = 'atrasado' " +
                    "WHERE estado = 'activo' AND fecha_devolucion_estimada < CURDATE()";
        
        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula en actualizarPrestamosAtrasados");
            return 0;
        }
        
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            int filasActualizadas = ps.executeUpdate();
            System.out.println("✅ " + filasActualizadas + " préstamos actualizados a atrasados");
            return filasActualizadas;
        } catch (SQLException e) {
            System.out.println("❌ Error en actualizarPrestamosAtrasados: " + e.getMessage());
            return 0;
        }
    }
    /**
     * Cuenta préstamos atrasados (versión mejorada)
     * @return 
     */
    public int contarPrestamosAtrasados() {
        // Primero actualizamos los atrasados
        actualizarPrestamosAtrasados();
        
        // Luego contamos
        String sql = "SELECT COUNT(*) FROM prestamo WHERE estado = 'atrasado'";
        
        Connection con = ConexionBD.getConnection();
        if (con == null) return 0;
        
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                return rs.getInt(1);
            }
            
        } catch (SQLException e) {
            System.out.println("⚠️ Error al contar préstamos atrasados: " + e.getMessage());
        }
        
        return 0;
    }
}