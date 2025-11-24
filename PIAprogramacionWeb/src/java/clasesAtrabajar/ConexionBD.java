package clasesAtrabajar;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexionBD {

    // Configuración de la conexión
    private static final String URL = "jdbc:mysql://localhost:3306/bibliotequero?useSSL=false&serverTimezone=UTC";
    private static final String USER = "root";
    private static final String PASSWORD = "2405";

    /**
     * Obtiene una conexión a la base de datos MySQL.
     * @return Connection si todo funciona, null si ocurre un error.
     */
    public static Connection getConnection() {
        try {
            // Registrar el driver de MySQL
            Class.forName("com.mysql.cj.jdbc.Driver");
            // Retornar la conexión
            return DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (ClassNotFoundException e) {
            System.out.println("❌ Error: Driver de MySQL no encontrado.");
            e.printStackTrace();
        } catch (SQLException e) {
            System.out.println("❌ Error: No se pudo conectar a la base de datos.");
            e.printStackTrace();
        }
        return null;
    }

    // Para probar la conexión
    public static void main(String[] args) {
        Connection con = getConnection();
        if (con != null) {
            System.out.println("✅ Conexión exitosa a MySQL!");
        } else {
            System.out.println("❌ Conexión fallida.");
        }
    }
}

