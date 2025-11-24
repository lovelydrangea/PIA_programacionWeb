package DAO;

import modelos.Publicacion;
import clasesAtrabajar.ConexionBD;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PublicacionDAO {

    /**
     * Crea una nueva publicación en la base de datos
     *
     * @param publicacion
     */
    public boolean crearPublicacion(Publicacion publicacion) {
        String sql = "INSERT INTO publicaciones (titulo, contenido, imagen_url, fecha_publicacion, idUsuario) VALUES (?, ?, ?, ?, ?)";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return false;
        }

        try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, publicacion.getTitulo());
            ps.setString(2, publicacion.getContenido());
            ps.setString(3, publicacion.getImagenUrl());
            ps.setDate(4, new Date(System.currentTimeMillis())); // Fecha actual
            ps.setInt(5, publicacion.getIdUsuario());

            int filas = ps.executeUpdate();

            if (filas > 0) {
                // Obtener el id autogenerado
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        publicacion.setId(rs.getInt(1));
                    }
                }
                return true;
            }

        } catch (SQLException e) {
            System.out.println("⚠️ Error al crear publicación: " + e.getMessage());
        }

        return false;
    }

    /**
     * Obtiene todas las publicaciones de un usuario
     *
     * @param idUsuario
     * @return
     */
    public List<Publicacion> obtenerPublicacionesPorUsuario(int idUsuario) {
        List<Publicacion> publicaciones = new ArrayList<>();
        String sql = "SELECT * FROM publicaciones WHERE idUsuario = ? ORDER BY fecha_publicacion DESC";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return publicaciones;
        }

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Publicacion pub = new Publicacion(
                            rs.getInt("id"),
                            rs.getString("titulo"),
                            rs.getString("contenido"),
                            rs.getString("imagen_url"),
                            rs.getDate("fecha_publicacion"),
                            rs.getInt("idUsuario")
                    );
                    publicaciones.add(pub);
                }
            }

        } catch (SQLException e) {
            System.out.println("⚠️ Error al obtener publicaciones: " + e.getMessage());
        }

        return publicaciones;
    }

    /**
     * Obtiene todas las publicaciones (para el feed)
     *
     * @return
     */
    public List<Publicacion> obtenerTodasPublicaciones() {
        List<Publicacion> publicaciones = new ArrayList<>();
        String sql = "SELECT p.*, u.usuario, u.url_foto FROM publicaciones p "
                + "JOIN usuario u ON p.idUsuario = u.id "
                + "ORDER BY p.fecha_publicacion DESC";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return publicaciones;
        }

        try (PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Publicacion pub = new Publicacion(
                        rs.getInt("id"),
                        rs.getString("titulo"),
                        rs.getString("contenido"),
                        rs.getString("imagen_url"),
                        rs.getDate("fecha_publicacion"),
                        rs.getInt("idUsuario")
                );
                publicaciones.add(pub);
            }

        } catch (SQLException e) {
            System.out.println("⚠️ Error al obtener todas las publicaciones: " + e.getMessage());
        }

        return publicaciones;
    }

    /**
     * Obtiene una publicación específica por ID
     */
    public Publicacion obtenerPublicacionPorId(int id) {
        String sql = "SELECT * FROM publicaciones WHERE id = ?";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return null;
        }

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Publicacion(
                            rs.getInt("id"),
                            rs.getString("titulo"),
                            rs.getString("contenido"),
                            rs.getString("imagen_url"),
                            rs.getDate("fecha_publicacion"),
                            rs.getInt("idUsuario")
                    );
                }
            }
        } catch (SQLException e) {
            System.out.println("⚠️ Error al obtener publicación por ID: " + e.getMessage());
        }

        return null;
    }

    /**
     * Elimina una publicación por ID
     */
    public boolean eliminarPublicacion(int id) {
        String sql = "DELETE FROM publicaciones WHERE id = ?";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return false;
        }

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);

            int filas = ps.executeUpdate();
            return filas > 0;

        } catch (SQLException e) {
            System.out.println("⚠️ Error al eliminar publicación: " + e.getMessage());
        }

        return false;
    }
}
