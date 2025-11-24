<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <!-- Headers meta para prevenir cache -->
        <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
        <meta http-equiv="Pragma" content="no-cache">
        <meta http-equiv="Expires" content="0">
        <title>Bibliotequero - Iniciar Sesión</title>
        <link rel="stylesheet" href="../node_modules/bootstrap/dist/css/bootstrap.css"/>
        <link rel="stylesheet" href="../Estilos/estilos.css">
        <link href="https://fonts.googleapis.com/css?family=Oranienbaum" rel="stylesheet">
    </head>

    <body>
        <!-- Navbar --> 
        <nav class="navbar fixed-top">
            <div class="container-fluid">
                <a class="navbar-brand d-flex align-items-center text-black" href="WelcomeIn.jsp">
                    <img src="../Logo/Logito.png" alt="Logo" width="30" height="30" class="me-2">
                    <span>Bibliotequero</span>
                </a>
                <!-- Botón hamburguesa --> 
                <button class="navbar-toggler bg-light border-black" type="button" data-bs-toggle="offcanvas" data-bs-target="#offcanvasNavbar" aria-controls="offcanvasNavbar" aria-label="Toggle navigation">
                    <span class="navbar-toggler-icon">

                    </span>
                </button>
                <!-- Menú desplegable lateral --> 
                <div class="offcanvas offcanvas-end" tabindex="-1" id="offcanvasNavbar" aria-labelledby="offcanvasNavbarLabel">
                    <div class="offcanvas-header">
                        <h5 class="offcanvas-title" id="offcanvasNavbarLabel">Bibliotequero</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="offcanvas" aria-label="Close"></button>
                    </div>
                    <div class="offcanvas-body">
                        <ul class="navbar-nav justify-content-end flex-grow-1 pe-3">
                            <li class="nav-item"> 
                                <a class="nav-link active" aria-current="page" href="WelcomeIn.jsp">Bienvenida</a> 
                            </li>
                            <li class="nav-item">
                                <a class="nav-link active" aria-current="page" href="registro-Sesion.jsp"> Registrarse </a>
                            </li>
                        </ul> 
                    </div> 
                </div> 
            </div> 
        </nav> 


    <!-- Contenido principal -->
    <div class="row mt-5 offset-1">
        <!-- Columna del formulario -->
        <div class="col-4">
            <div class="card p-4 shadow">
                <h4 class="mb-3 text-center">Iniciar Sesión</h4>

                <!-- Mostrar mensajes de error -->
                <%
                    String error = request.getParameter("error");
                    if (error != null) {
                        if (error.equals("credenciales_invalidas")) {
                %>
                <div class="alert alert-danger" role="alert">
                    ⚠️ Correo o contraseña incorrectos.
                </div>
                <%
                        } else if (error.equals("campos_vacios")) {
                %>
                <div class="alert alert-warning" role="alert">
                    ⚠️ Por favor, completa todos los campos.
                </div>
                <%
                        }
                    }
                %>

                <!-- Formulario de login -->
                <form action="${pageContext.request.contextPath}/login" method="post">
                    <div class="mb-3">
                        <label for="correo" class="form-label">Correo Electrónico</label>
                        <input type="email" class="form-control" id="correo" name="correo" placeholder="correo@ejemplo.com" required>
                        <div class="form-text">Nunca compartiremos tu correo con nadie más.</div>
                    </div>

                    <div class="mb-3">
                        <label for="password" class="form-label">Contraseña</label>
                        <input type="password" class="form-control" id="password" name="password" placeholder="••••••••" required>
                    </div>

                    <div class="mb-3 form-check">
                        <!-- Esto asi dejalo para que luego se comporte el card con espacion, asi se ve mejor -->
                    </div>

                    <button type="submit" class="btn btn-primary w-100" id="button">Iniciar Sesión</button>
                </form>
            </div>
        </div>

        <!-- Columna del carrusel de frases -->
        <div class="col-8">
            <div id="frasesSlider" class="carousel slide carousel-fade" data-bs-ride="carousel" data-bs-interval="5000">
                <div class="carousel-inner">

                    <div class="carousel-item active">
                        <blockquote class="blockquote text-white p-3">
                            <p>"Hay que dormir con los ojos abiertos, hay que soñar con las manos..."</p>
                            <footer class="blockquote-footer text-white">Octavio Paz</footer>
                        </blockquote>
                    </div>

                    <div class="carousel-item">
                        <blockquote class="blockquote text-white p-3">
                            <p>"Todo escritor que crea es un mentiroso; la literatura es mentira..."</p>
                            <footer class="blockquote-footer text-white">Juan Rulfo</footer>
                        </blockquote>
                    </div>

                    <div class="carousel-item">
                        <blockquote class="blockquote text-white p-3">
                            <p>"Al trato de amor, hallo diamante y soy diamante al que de amor me trata."</p>
                            <footer class="blockquote-footer text-white">Sor Juana Inés de la Cruz</footer>
                        </blockquote>
                    </div>

                    <div class="carousel-item">
                        <blockquote class="blockquote text-white p-3">
                            <p>"Viajar, dormir, enamorarse son tres invitaciones a lo mismo..."</p>
                            <footer class="blockquote-footer text-white">Ángeles Mastretta</footer>
                        </blockquote>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="../node_modules/bootstrap/dist/js/bootstrap.bundle.js"></script>
</body>
</html>
