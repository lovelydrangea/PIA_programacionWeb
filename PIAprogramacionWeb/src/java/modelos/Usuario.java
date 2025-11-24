package modelos;

import java.sql.Date;

public class Usuario {

    private int idUsuario;
    private String nombreUsuario;
    private String nombre;
    private String correo;
    private Date fechaNacimiento;
    private String contrasena;
    private String urlFoto;

    public Usuario(){
    
    
    }
    // Constructor completo
    public Usuario(int idUsuario, String nombreUsuario, String nombre,
                   Date fechaNacimiento, String correo, String contrasena, String urlFoto) {
        this.idUsuario = idUsuario;
        this.nombreUsuario = nombreUsuario;
        this.nombre = nombre;
        this.fechaNacimiento = fechaNacimiento;
        this.correo = correo;
        this.contrasena = contrasena;
        this.urlFoto = urlFoto;
    }

    // Getters y setters
    public int getIdUsuario() { return idUsuario; }
    public void setIdUsuario(int idUsuario) { this.idUsuario = idUsuario; }

    public String getNombreUsuario() { return nombreUsuario; }
    public void setNombreUsuario(String nombreUsuario) { this.nombreUsuario = nombreUsuario; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getCorreo() { return correo; }
    public void setCorreo(String correo) {
        if (!correo.contains("@")) throw new IllegalArgumentException("Correo inválido");
        this.correo = correo;
    }

    public Date getFechaNacimiento() { return fechaNacimiento; }
    public void setFechaNacimiento(Date fechaNacimiento) { this.fechaNacimiento = fechaNacimiento; }

    public String getContrasena() { return contrasena; }
    public void setContrasena(String contrasena) { this.contrasena = contrasena; }

    public String getUrlFoto() { return urlFoto; }
    public void setUrlFoto(String urlFoto) { this.urlFoto = urlFoto; }

    @Override
    public String toString() {
        return "Usuario{" +
                "idUsuario=" + idUsuario +
                ", nombreUsuario='" + nombreUsuario + '\'' +
                ", nombre='" + nombre + '\'' +
                ", correo='" + correo + '\'' +
                ", fechaNacimiento=" + fechaNacimiento +
                ", urlFoto='" + urlFoto + '\'' +
                '}';
    }
}
