package DAO;

import java.sql.*;
import modelos.Usuario;
import clasesAtrabajar.ConexionBD;

public class UsuarioDAO {
       
    
    /**
     * Verifica si ya existe un usuario con el mismo nombre de usuario (excluyendo al usuario actual)
     */
    public boolean existeUsuarioPorNombre(String nombreUsuario) {
        String sql = "SELECT COUNT(*) FROM usuario WHERE usuario = ?";

        Connection con = ConexionBD.getConnection();
        if (con == null) return true;

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, nombreUsuario);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.out.println("Error al verificar usuario por nombre: " + e.getMessage());
        }
        return true;
    }

    /**
     * Verifica si ya existe un usuario con el mismo correo (excluyendo al usuario actual)
     */
    public boolean existeUsuarioPorCorreo(String correo) {
        String sql = "SELECT COUNT(*) FROM usuario WHERE correo = ?";

        Connection con = ConexionBD.getConnection();
        if (con == null) return true;

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, correo);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.out.println("Error al verificar usuario por correo: " + e.getMessage());
        }
        return true;
    }
    /**
     * Actualiza un usuario en la base de datos
     */
    public boolean actualizarUsuario(Usuario usuario) {
        // Verificar si se está actualizando la contraseña
        boolean actualizarPassword = usuario.getContrasena() != null && !usuario.getContrasena().isEmpty();

        String sql;
        if (actualizarPassword) {
            sql = "UPDATE usuario SET nombre = ?, usuario = ?, fecha_nacimiento = ?, correo = ?, password = ?, url_foto = ? WHERE id = ?";
        } else {
            sql = "UPDATE usuario SET nombre = ?, usuario = ?, fecha_nacimiento = ?, correo = ?, url_foto = ? WHERE id = ?";
        }

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return false;
        }

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, usuario.getNombre());
            ps.setString(2, usuario.getNombreUsuario());

            if (usuario.getFechaNacimiento() != null) {
                ps.setDate(3, usuario.getFechaNacimiento());
            } else {
                ps.setNull(3, java.sql.Types.DATE);
            }

            ps.setString(4, usuario.getCorreo());

            if (actualizarPassword) {
                ps.setString(5, usuario.getContrasena());
                ps.setString(6, usuario.getUrlFoto());
                ps.setInt(7, usuario.getIdUsuario());
            } else {
                ps.setString(5, usuario.getUrlFoto());
                ps.setInt(6, usuario.getIdUsuario());
            }

            int filasAfectadas = ps.executeUpdate();
            return filasAfectadas > 0;

        } catch (SQLException e) {
            System.out.println("⚠️ Error al actualizar usuario: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }
    
     /**
     * Cuenta el total de usuarios registrados
     * @return Número total de usuarios
     */
    public int contarTotalUsuarios() {
        String sql = "SELECT COUNT(*) FROM usuario";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return 0;
        }

        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (SQLException e) {
            System.out.println("⚠️ Error al contar usuarios: " + e.getMessage());
        }

        return 0;
    }

    /**
     * Verifica si ya existe un usuario con el mismo correo o nombre de usuario
     */
    public boolean existeUsuario(String correo, String nombreUsuario) {
        String sql = "SELECT COUNT(*) FROM usuario WHERE correo = ? OR usuario = ?";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return true; // Por seguridad, asumimos que existe
        }

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, correo);
            ps.setString(2, nombreUsuario);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.out.println("⚠️ Error al verificar usuario existente: " + e.getMessage());
        }

        return true; // Por seguridad en caso de error
    }

    /**
     * Registra un usuario en la base de datos.
     * @param usuario
     * @return 
     */
    public boolean registrar(Usuario usuario) {
        // Primero verificar si ya existe
        if (existeUsuario(usuario.getCorreo(), usuario.getNombreUsuario())) {
            System.out.println("⚠️ Usuario o correo ya registrado");
            return false;
        }

        String sql = "INSERT INTO usuario (nombre, usuario, fecha_nacimiento, correo, password, url_foto) VALUES (?, ?, ?, ?, ?, ?)";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return false;
        }

        try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, usuario.getNombre());
            ps.setString(2, usuario.getNombreUsuario());
            ps.setDate(3, usuario.getFechaNacimiento());
            ps.setString(4, usuario.getCorreo());
            ps.setString(5, usuario.getContrasena());
            ps.setString(6, usuario.getUrlFoto());

            int filas = ps.executeUpdate();

            if (filas > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        usuario.setIdUsuario(rs.getInt(1));
                    }
                }
                return true;
            }

        } catch (SQLException e) {
            if (e.getErrorCode() == 1062) { // Duplicate entry
                System.out.println("⚠️ Usuario o correo ya registrado: " + e.getMessage());
            } else {
                System.out.println("⚠️ Error al registrar usuario: " + e.getMessage());
            }
        }

        return false;
    }

    /**
     * Inicia sesión con correo y contraseña.
     */
    public Usuario iniciarSesion(String correo, String password) {
        String sql = "SELECT * FROM usuario WHERE correo=? AND password=?";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return null;
        }

        try (PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, correo);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Usuario u = new Usuario(
                            rs.getInt("id"),
                            rs.getString("usuario"),
                            rs.getString("nombre"),
                            rs.getDate("fecha_nacimiento"),
                            rs.getString("correo"),
                            rs.getString("password"),
                            rs.getString("url_foto")
                    );
                    return u;
                }
            }

        } catch (SQLException e) {
            System.out.println("⚠️ Error al iniciar sesión: " + e.getMessage());
        }

        return null;
    }

    /**
     * Obtiene un usuario por su ID
     */
    public Usuario obtenerUsuarioPorId(int id) {
        String sql = "SELECT * FROM usuario WHERE id = ?";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return null;
        }

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Usuario(
                            rs.getInt("id"),
                            rs.getString("usuario"),
                            rs.getString("nombre"),
                            rs.getDate("fecha_nacimiento"),
                            rs.getString("correo"),
                            rs.getString("password"),
                            rs.getString("url_foto")
                    );
                }
            }
        } catch (SQLException e) {
            System.out.println("⚠️ Error al obtener usuario por ID: " + e.getMessage());
        }

        return null;
    }

    /**
     * Verifica si un usuario es administrador
     */
    public boolean esAdministrador(int idUsuario) {
        String sql = "SELECT rol FROM usuario WHERE id = ?";

        Connection con = ConexionBD.getConnection();
        if (con == null) {
            System.out.println("❌ Conexión nula. No se pudo conectar a la base de datos.");
            return false;
        }

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idUsuario);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return "administrador".equals(rs.getString("rol"));
                }
            }
        } catch (SQLException e) {
            System.out.println("⚠️ Error al verificar rol: " + e.getMessage());
        }

        return false;
    }
}
