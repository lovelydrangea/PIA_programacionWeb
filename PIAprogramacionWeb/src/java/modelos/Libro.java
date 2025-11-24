package modelos;

import java.sql.Timestamp;

public class Libro {
    private int id;
    private String isbn;
    private String titulo;
    private String autor;
    private String editorial;
    private int anioPublicacion;
    private String genero;
    private String descripcion;
    private String portadaUrl;
    private int ejemplaresDisponibles;
    private int ejemplaresTotales;
    private Timestamp fechaCreacion;
    private int idUsuarioCreador;
    private boolean activo;

    // Constructores
    public Libro() {}

    public Libro(int id, String isbn, String titulo, String autor, String editorial, 
                 int anioPublicacion, String genero, String descripcion, String portadaUrl,
                 int ejemplaresDisponibles, int ejemplaresTotales, int idUsuarioCreador) {
        this.id = id;
        this.isbn = isbn;
        this.titulo = titulo;
        this.autor = autor;
        this.editorial = editorial;
        this.anioPublicacion = anioPublicacion;
        this.genero = genero;
        this.descripcion = descripcion;
        this.portadaUrl = portadaUrl;
        this.ejemplaresDisponibles = ejemplaresDisponibles;
        this.ejemplaresTotales = ejemplaresTotales;
        this.idUsuarioCreador = idUsuarioCreador;
    }

    // Getters y Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getIsbn() { return isbn; }
    public void setIsbn(String isbn) { this.isbn = isbn; }

    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }

    public String getAutor() { return autor; }
    public void setAutor(String autor) { this.autor = autor; }

    public String getEditorial() { return editorial; }
    public void setEditorial(String editorial) { this.editorial = editorial; }

    public int getAnioPublicacion() { return anioPublicacion; }
    public void setAnioPublicacion(int anioPublicacion) { this.anioPublicacion = anioPublicacion; }

    public String getGenero() { return genero; }
    public void setGenero(String genero) { this.genero = genero; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public String getPortadaUrl() { return portadaUrl; }
    public void setPortadaUrl(String portadaUrl) { this.portadaUrl = portadaUrl; }

    public int getEjemplaresDisponibles() { return ejemplaresDisponibles; }
    public void setEjemplaresDisponibles(int ejemplaresDisponibles) { this.ejemplaresDisponibles = ejemplaresDisponibles; }

    public int getEjemplaresTotales() { return ejemplaresTotales; }
    public void setEjemplaresTotales(int ejemplaresTotales) { this.ejemplaresTotales = ejemplaresTotales; }

    public Timestamp getFechaCreacion() { return fechaCreacion; }
    public void setFechaCreacion(Timestamp fechaCreacion) { this.fechaCreacion = fechaCreacion; }

    public int getIdUsuarioCreador() { return idUsuarioCreador; }
    public void setIdUsuarioCreador(int idUsuarioCreador) { this.idUsuarioCreador = idUsuarioCreador; }

    public boolean isActivo() { return activo; }
    public void setActivo(boolean activo) { this.activo = activo; }

    @Override
    public String toString() {
        return "Libro{" +
                "id=" + id +
                ", titulo='" + titulo + '\'' +
                ", autor='" + autor + '\'' +
                ", ejemplaresDisponibles=" + ejemplaresDisponibles +
                '}';
    }
}