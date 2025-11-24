package modelos;

import java.sql.Date;

public class Publicacion {
    private int id;
    private String titulo;
    private String contenido;
    private String imagenUrl;
    private Date fechaPublicacion;
    private int idUsuario; // relación con Usuario

    public Publicacion(int id, String titulo, String contenido, String imagenUrl,
                       Date fechaPublicacion, int idUsuario) {
        this.id = id;
        this.titulo = titulo;
        this.contenido = contenido;
        this.imagenUrl = imagenUrl;
        this.fechaPublicacion = fechaPublicacion;
        this.idUsuario = idUsuario;
    }

    public Publicacion() {}

    // Getters y Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }

    public String getContenido() { return contenido; }
    public void setContenido(String contenido) { this.contenido = contenido; }

    public String getImagenUrl() { return imagenUrl; }
    public void setImagenUrl(String imagenUrl) { this.imagenUrl = imagenUrl; }

    public Date getFechaPublicacion() { return fechaPublicacion; }
    public void setFechaPublicacion(Date fechaPublicacion) { this.fechaPublicacion = fechaPublicacion; }

    public int getIdUsuario() { return idUsuario; }
    public void setIdUsuario(int idUsuario) { this.idUsuario = idUsuario; }

    @Override
    public String toString() {
        return "Publicacion{" +
                "id=" + id +
                ", titulo='" + titulo + '\'' +
                ", idUsuario=" + idUsuario +
                ", fechaPublicacion=" + fechaPublicacion +
                '}';
    }
}
