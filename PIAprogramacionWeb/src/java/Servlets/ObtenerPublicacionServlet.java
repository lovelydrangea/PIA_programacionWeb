/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package Servlets;

import DAO.PublicacionDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import modelos.Publicacion;

/**
 *
 * @author luis
 */
@WebServlet("/obtener-publicacion")
public class ObtenerPublicacionServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            PublicacionDAO dao = new PublicacionDAO();
            Publicacion publicacion = dao.obtenerPublicacionPorId(id);
            
            response.setContentType("application/json");
            if (publicacion != null) {
                String json = String.format(
                    "{\"id\": %d, \"titulo\": \"%s\", \"contenido\": \"%s\", \"imagenUrl\": \"%s\", \"fechaPublicacion\": \"%s\"}",
                    publicacion.getId(),
                    publicacion.getTitulo().replace("\"", "\\\""),
                    publicacion.getContenido().replace("\"", "\\\""),
                    publicacion.getImagenUrl() != null ? 
                        request.getContextPath() + "/uploads/" + publicacion.getImagenUrl() : "",
                    publicacion.getFechaPublicacion() != null ? 
                        publicacion.getFechaPublicacion().toString() : ""
                );
                response.getWriter().write(json);
            } else {
                response.getWriter().write("{\"error\": \"Publicación no encontrada\"}");
            }
        } catch (Exception e) {
            response.getWriter().write("{\"error\": \"Error al obtener publicación\"}");
        }
    }
}