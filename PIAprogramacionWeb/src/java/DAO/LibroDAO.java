package DAO;

import modelos.Libro;
import clasesAtrabajar.ConexionBD;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LibroDAO {

    /**
     * Crea un nuevo libro en la base de datos (solo administradores)
     *
     * @param libro
     * @return
     */
    public boolean crearLibro(Libro libro) {
        String sql = "INSERT INTO libro (isbn, titulo, autor, editorial, anio_publicacion, "
                + "genero, descripcion, portada_url, ejemplares_disponibles, "
                + "ejemplares_totales, id_usuario_creador) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return false;
        }

        try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, libro.getIsbn());
            ps.setString(2, libro.getTitulo());
            ps.setString(3, libro.getAutor());
            ps.setString(4, libro.getEditorial());
            ps.setInt(5, libro.getAnioPublicacion());
            ps.setString(6, libro.getGenero());
            ps.setString(7, libro.getDescripcion());
            ps.setString(8, libro.getPortadaUrl());
            ps.setInt(9, libro.getEjemplaresDisponibles());
            ps.setInt(10, libro.getEjemplaresTotales());
            ps.setInt(11, libro.getIdUsuarioCreador());

            int filas = ps.executeUpdate();

            if (filas > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        libro.setId(rs.getInt(1));
                    }
                }
                return true;
            }

        } catch (SQLException e) {
            System.out.println("⚠️ Error al crear libro: " + e.getMessage());
        }

        return false;
    }

    /**
     * Obtiene todos los libros
     *
     * @return
     */
    public List<Libro> obtenerTodosLibros() {
        List<Libro> libros = new ArrayList<>();
        String sql = "SELECT l.*, u.usuario as creador FROM libro l "
                + "LEFT JOIN usuario u ON l.id_usuario_creador = u.id "
                + "WHERE l.activo = TRUE ORDER BY l.titulo";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return libros;
        }

        try (PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Libro libro = new Libro();
                libro.setId(rs.getInt("id"));
                libro.setIsbn(rs.getString("isbn"));
                libro.setTitulo(rs.getString("titulo"));
                libro.setAutor(rs.getString("autor"));
                libro.setEditorial(rs.getString("editorial"));
                libro.setAnioPublicacion(rs.getInt("anio_publicacion"));
                libro.setGenero(rs.getString("genero"));
                libro.setDescripcion(rs.getString("descripcion"));
                libro.setPortadaUrl(rs.getString("portada_url"));
                libro.setEjemplaresDisponibles(rs.getInt("ejemplares_disponibles"));
                libro.setEjemplaresTotales(rs.getInt("ejemplares_totales"));
                libro.setIdUsuarioCreador(rs.getInt("id_usuario_creador"));
                libro.setFechaCreacion(rs.getTimestamp("fecha_creacion"));
                libro.setActivo(rs.getBoolean("activo"));

                libros.add(libro);
            }

        } catch (SQLException e) {
            System.out.println("⚠️ Error al obtener libros: " + e.getMessage());
        }

        return libros;
    }

    /**
     * Busca libros por título, autor, género o editorial
     */
    public List<Libro> buscarLibros(String busqueda) {
        List<Libro> libros = new ArrayList<>();

        // ✅ MEJORADO: Búsqueda más completa en múltiples campos
        String sql = "SELECT l.*, u.usuario as creador FROM libro l "
                + "LEFT JOIN usuario u ON l.id_usuario_creador = u.id "
                + "WHERE l.activo = TRUE AND "
                + "(LOWER(l.titulo) LIKE LOWER(?) OR "
                + "LOWER(l.autor) LIKE LOWER(?) OR "
                + "LOWER(l.genero) LIKE LOWER(?) OR "
                + "LOWER(l.editorial) LIKE LOWER(?) OR "
                + "LOWER(l.isbn) LIKE LOWER(?)) "
                + "ORDER BY "
                + "CASE WHEN LOWER(l.titulo) LIKE LOWER(?) THEN 1 "
                + "     WHEN LOWER(l.autor) LIKE LOWER(?) THEN 2 "
                + "     ELSE 3 END, l.titulo";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return libros;
        }

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            String likeBusqueda = "%" + busqueda + "%";

            // Setear parámetros para la búsqueda
            ps.setString(1, likeBusqueda); // título
            ps.setString(2, likeBusqueda); // autor
            ps.setString(3, likeBusqueda); // género
            ps.setString(4, likeBusqueda); // editorial
            ps.setString(5, likeBusqueda); // ISBN
            ps.setString(6, likeBusqueda); // ordenamiento - título
            ps.setString(7, likeBusqueda); // ordenamiento - autor

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Libro libro = new Libro();
                    libro.setId(rs.getInt("id"));
                    libro.setIsbn(rs.getString("isbn"));
                    libro.setTitulo(rs.getString("titulo"));
                    libro.setAutor(rs.getString("autor"));
                    libro.setEditorial(rs.getString("editorial"));
                    libro.setAnioPublicacion(rs.getInt("anio_publicacion"));
                    libro.setGenero(rs.getString("genero"));
                    libro.setDescripcion(rs.getString("descripcion"));
                    libro.setPortadaUrl(rs.getString("portada_url"));
                    libro.setEjemplaresDisponibles(rs.getInt("ejemplares_disponibles"));
                    libro.setEjemplaresTotales(rs.getInt("ejemplares_totales"));
                    libro.setIdUsuarioCreador(rs.getInt("id_usuario_creador"));
                    libro.setFechaCreacion(rs.getTimestamp("fecha_creacion"));
                    libro.setActivo(rs.getBoolean("activo"));

                    libros.add(libro);
                }
            }

        } catch (SQLException e) {
            System.out.println("⚠️ Error al buscar libros: " + e.getMessage());
            e.printStackTrace();
        }

        return libros;
    }

    /**
     * Actualiza solo los ejemplares disponibles de un libro
     *
     * @param idLibro
     * @param nuevosEjemplaresDisponibles
     * @return
     */
    public boolean actualizarEjemplaresDisponibles(int idLibro, int nuevosEjemplaresDisponibles) {
        String sql = "UPDATE libro SET ejemplares_disponibles = ? WHERE id = ?";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return false;
        }

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, nuevosEjemplaresDisponibles);
            ps.setInt(2, idLibro);

            int filas = ps.executeUpdate();
            return filas > 0;

        } catch (SQLException e) {
            System.out.println("⚠️ Error al actualizar ejemplares disponibles: " + e.getMessage());
        }

        return false;
    }

    /**
     * Actualiza la información de un libro
     *
     * @param libro
     * @return
     */
    public boolean actualizarLibro(Libro libro) {
        String sql = "UPDATE libro SET titulo=?, autor=?, editorial=?, anio_publicacion=?, "
                + "genero=?, descripcion=?, portada_url=?, ejemplares_disponibles=?, "
                + "ejemplares_totales=? WHERE id=?";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return false;
        }

        try (PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, libro.getTitulo());
            ps.setString(2, libro.getAutor());
            ps.setString(3, libro.getEditorial());
            ps.setInt(4, libro.getAnioPublicacion());
            ps.setString(5, libro.getGenero());
            ps.setString(6, libro.getDescripcion());
            ps.setString(7, libro.getPortadaUrl());
            ps.setInt(8, libro.getEjemplaresDisponibles());
            ps.setInt(9, libro.getEjemplaresTotales());
            ps.setInt(10, libro.getId());

            int filas = ps.executeUpdate();
            return filas > 0;

        } catch (SQLException e) {
            System.out.println("⚠️ Error al actualizar libro: " + e.getMessage());
        }

        return false;
    }

    /**
     * Elimina (desactiva) un libro
     *
     * @param idLibro
     * @return
     */
    public boolean eliminarLibro(int idLibro) {
        String sql = "UPDATE libro SET activo = FALSE WHERE id = ?";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return false;
        }

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idLibro);
            int filas = ps.executeUpdate();
            return filas > 0;

        } catch (SQLException e) {
            System.out.println("⚠️ Error al eliminar libro: " + e.getMessage());
        }

        return false;
    }

    /**
     * Obtiene un libro por su ID
     */
    public Libro obtenerLibroPorId(int idLibro) {
        String sql = "SELECT * FROM libro WHERE id = ?";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return null;
        }

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idLibro);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Libro libro = new Libro();
                    libro.setId(rs.getInt("id"));
                    libro.setTitulo(rs.getString("titulo"));
                    libro.setAutor(rs.getString("autor"));
                    libro.setEditorial(rs.getString("editorial"));
                    libro.setAnioPublicacion(rs.getInt("anio_publicacion"));
                    libro.setGenero(rs.getString("genero"));
                    libro.setDescripcion(rs.getString("descripcion"));
                    libro.setPortadaUrl(rs.getString("portada_url"));
                    libro.setEjemplaresDisponibles(rs.getInt("ejemplares_disponibles"));
                    libro.setEjemplaresTotales(rs.getInt("ejemplares_totales"));
                    libro.setIdUsuarioCreador(rs.getInt("id_usuario_creador"));
                    libro.setFechaCreacion(rs.getTimestamp("fecha_creacion"));
                    libro.setActivo(rs.getBoolean("activo"));
                    return libro;
                }
            }
        } catch (SQLException e) {
            System.out.println("⚠️ Error al obtener libro por ID: " + e.getMessage());
        }

        return null;
    }

    // En tu LibroDAO, agrega estos métodos:
    /**
     * Obtiene libros paginados
     */
    public List<Libro> obtenerLibrosPaginados(int pagina, int librosPorPagina) {
        List<Libro> libros = new ArrayList<>();
        int offset = (pagina - 1) * librosPorPagina;

        String sql = "SELECT l.*, u.usuario as creador FROM libro l "
                + "LEFT JOIN usuario u ON l.id_usuario_creador = u.id "
                + "WHERE l.activo = TRUE ORDER BY l.titulo LIMIT ? OFFSET ?";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return libros;
        }

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, librosPorPagina);
            ps.setInt(2, offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Libro libro = new Libro();
                    libro.setId(rs.getInt("id"));
                    libro.setIsbn(rs.getString("isbn"));
                    libro.setTitulo(rs.getString("titulo"));
                    libro.setAutor(rs.getString("autor"));
                    libro.setEditorial(rs.getString("editorial"));
                    libro.setAnioPublicacion(rs.getInt("anio_publicacion"));
                    libro.setGenero(rs.getString("genero"));
                    libro.setDescripcion(rs.getString("descripcion"));
                    libro.setPortadaUrl(rs.getString("portada_url"));
                    libro.setEjemplaresDisponibles(rs.getInt("ejemplares_disponibles"));
                    libro.setEjemplaresTotales(rs.getInt("ejemplares_totales"));
                    libro.setIdUsuarioCreador(rs.getInt("id_usuario_creador"));
                    libro.setFechaCreacion(rs.getTimestamp("fecha_creacion"));
                    libro.setActivo(rs.getBoolean("activo"));

                    libros.add(libro);
                }
            }

        } catch (SQLException e) {
            System.out.println("⚠️ Error al obtener libros paginados: " + e.getMessage());
        }

        return libros;
    }

    /**
     * Cuenta el total de libros activos
     */
    public int contarTotalLibros() {
        String sql = "SELECT COUNT(*) as total FROM libro WHERE activo = TRUE";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return 0;
        }

        try (PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt("total");
            }

        } catch (SQLException e) {
            System.out.println("⚠️ Error al contar libros: " + e.getMessage());
        }

        return 0;
    }

    /**
     * Busca libros paginados
     */
    public List<Libro> buscarLibrosPaginados(String busqueda, int pagina, int librosPorPagina) {
        List<Libro> libros = new ArrayList<>();
        int offset = (pagina - 1) * librosPorPagina;

        String sql = "SELECT l.*, u.usuario as creador FROM libro l "
                + "LEFT JOIN usuario u ON l.id_usuario_creador = u.id "
                + "WHERE l.activo = TRUE AND "
                + "(LOWER(l.titulo) LIKE LOWER(?) OR "
                + "LOWER(l.autor) LIKE LOWER(?) OR "
                + "LOWER(l.genero) LIKE LOWER(?) OR "
                + "LOWER(l.editorial) LIKE LOWER(?) OR "
                + "LOWER(l.isbn) LIKE LOWER(?)) "
                + "ORDER BY "
                + "CASE WHEN LOWER(l.titulo) LIKE LOWER(?) THEN 1 "
                + "     WHEN LOWER(l.autor) LIKE LOWER(?) THEN 2 "
                + "     ELSE 3 END, l.titulo "
                + "LIMIT ? OFFSET ?";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return libros;
        }

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            String likeBusqueda = "%" + busqueda + "%";

            ps.setString(1, likeBusqueda);
            ps.setString(2, likeBusqueda);
            ps.setString(3, likeBusqueda);
            ps.setString(4, likeBusqueda);
            ps.setString(5, likeBusqueda);
            ps.setString(6, likeBusqueda);
            ps.setString(7, likeBusqueda);
            ps.setInt(8, librosPorPagina);
            ps.setInt(9, offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Libro libro = new Libro();
                    libro.setId(rs.getInt("id"));
                    libro.setIsbn(rs.getString("isbn"));
                    libro.setTitulo(rs.getString("titulo"));
                    libro.setAutor(rs.getString("autor"));
                    libro.setEditorial(rs.getString("editorial"));
                    libro.setAnioPublicacion(rs.getInt("anio_publicacion"));
                    libro.setGenero(rs.getString("genero"));
                    libro.setDescripcion(rs.getString("descripcion"));
                    libro.setPortadaUrl(rs.getString("portada_url"));
                    libro.setEjemplaresDisponibles(rs.getInt("ejemplares_disponibles"));
                    libro.setEjemplaresTotales(rs.getInt("ejemplares_totales"));
                    libro.setIdUsuarioCreador(rs.getInt("id_usuario_creador"));
                    libro.setFechaCreacion(rs.getTimestamp("fecha_creacion"));
                    libro.setActivo(rs.getBoolean("activo"));

                    libros.add(libro);
                }
            }

        } catch (SQLException e) {
            System.out.println("⚠️ Error al buscar libros paginados: " + e.getMessage());
            e.printStackTrace();
        }

        return libros;
    }

    /**
     * Cuenta resultados de búsqueda
     */
    public int contarLibrosBusqueda(String busqueda) {
        String sql = "SELECT COUNT(*) as total FROM libro l "
                + "WHERE l.activo = TRUE AND "
                + "(LOWER(l.titulo) LIKE LOWER(?) OR "
                + "LOWER(l.autor) LIKE LOWER(?) OR "
                + "LOWER(l.genero) LIKE LOWER(?) OR "
                + "LOWER(l.editorial) LIKE LOWER(?) OR "
                + "LOWER(l.isbn) LIKE LOWER(?))";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return 0;
        }

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            String likeBusqueda = "%" + busqueda + "%";

            ps.setString(1, likeBusqueda);
            ps.setString(2, likeBusqueda);
            ps.setString(3, likeBusqueda);
            ps.setString(4, likeBusqueda);
            ps.setString(5, likeBusqueda);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total");
                }
            }

        } catch (SQLException e) {
            System.out.println("⚠️ Error al contar libros de búsqueda: " + e.getMessage());
        }

        return 0;
    }


}
