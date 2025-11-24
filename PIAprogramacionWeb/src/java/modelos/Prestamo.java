package modelos;

import java.sql.Date;
import java.sql.Timestamp;

public class Prestamo {
    private int id;
    private int idLibro;
    private int idUsuario;
    private Timestamp fechaPrestamo;
    private Date fechaDevolucionEstimada;
    private Date fechaDevolucionReal;
    private String estado;
    private String observaciones;
    private Integer idAdminAprobo;
    
    // Objetos relacionados (para joins)
    private Libro libro;
    private Usuario usuario;
    private Usuario adminAprobo;

    // Constructores
    public Prestamo() {}

    public Prestamo(int id, int idLibro, int idUsuario, Timestamp fechaPrestamo, 
                   Date fechaDevolucionEstimada, Date fechaDevolucionReal, 
                   String estado, String observaciones, Integer idAdminAprobo) {
        this.id = id;
        this.idLibro = idLibro;
        this.idUsuario = idUsuario;
        this.fechaPrestamo = fechaPrestamo;
        this.fechaDevolucionEstimada = fechaDevolucionEstimada;
        this.fechaDevolucionReal = fechaDevolucionReal;
        this.estado = estado;
        this.observaciones = observaciones;
        this.idAdminAprobo = idAdminAprobo;
    }

    // Getters y Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getIdLibro() { return idLibro; }
    public void setIdLibro(int idLibro) { this.idLibro = idLibro; }

    public int getIdUsuario() { return idUsuario; }
    public void setIdUsuario(int idUsuario) { this.idUsuario = idUsuario; }

    public Timestamp getFechaPrestamo() { return fechaPrestamo; }
    public void setFechaPrestamo(Timestamp fechaPrestamo) { this.fechaPrestamo = fechaPrestamo; }

    public Date getFechaDevolucionEstimada() { return fechaDevolucionEstimada; }
    public void setFechaDevolucionEstimada(Date fechaDevolucionEstimada) { this.fechaDevolucionEstimada = fechaDevolucionEstimada; }

    public Date getFechaDevolucionReal() { return fechaDevolucionReal; }
    public void setFechaDevolucionReal(Date fechaDevolucionReal) { this.fechaDevolucionReal = fechaDevolucionReal; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public String getObservaciones() { return observaciones; }
    public void setObservaciones(String observaciones) { this.observaciones = observaciones; }

    public Integer getIdAdminAprobo() { return idAdminAprobo; }
    public void setIdAdminAprobo(Integer idAdminAprobo) { this.idAdminAprobo = idAdminAprobo; }

    // Getters y Setters para objetos relacionados
    public Libro getLibro() { return libro; }
    public void setLibro(Libro libro) { this.libro = libro; }

    public Usuario getUsuario() { return usuario; }
    public void setUsuario(Usuario usuario) { this.usuario = usuario; }

    public Usuario getAdminAprobo() { return adminAprobo; }
    public void setAdminAprobo(Usuario adminAprobo) { this.adminAprobo = adminAprobo; }

    // Métodos utilitarios
    public boolean estaActivo() {
        return "activo".equals(estado);
    }

    public boolean estaDevuelto() {
        return "devuelto".equals(estado);
    }

    public boolean estaAtrasado() {
        // Si ya está marcado como atrasado en la BD, retornar true
        if ("atrasado".equals(this.estado)) {
            return true;
        }

        // Si está activo y la fecha ya pasó, también considerar atrasado
        if ("activo".equals(this.estado) && this.fechaDevolucionEstimada != null) {
            java.util.Date fechaActual = new java.util.Date();
            return this.fechaDevolucionEstimada.before(fechaActual);
        }

        return false;
    }

    public boolean fueAprobadoPorAdmin() {
        return idAdminAprobo != null && idAdminAprobo > 0;
    }

    @Override
    public String toString() {
        return "Prestamo{" +
                "id=" + id +
                ", idLibro=" + idLibro +
                ", idUsuario=" + idUsuario +
                ", fechaPrestamo=" + fechaPrestamo +
                ", fechaDevolucionEstimada=" + fechaDevolucionEstimada +
                ", estado='" + estado + '\'' +
                '}';
    }
}