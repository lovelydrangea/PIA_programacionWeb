<!DOCTYPE html>
<!-- WelcomeIn.jsp -->
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Bienvenido a Bibliotequero</title>
        <link rel="stylesheet" href="../node_modules/bootstrap/dist/css/bootstrap.css"/>
        <link rel="stylesheet" href="../Estilos/welcome.css">
    </head>
    <body>
        <main class="scroll-container">

            <!-- Hero -->
            <section class="section hero text-center text-white d-flex flex-column justify-content-center align-items-center">
                <div class="overlay"></div>
                <div class="content">
                    <h1 class="display-2 fw-bold"> Bienvenido a <span>Bibliotequero</span></h1>
                    <p class="lead fs-4">Tu catalogo digital de libros, facil de explorar y siempre disponible.</p>
                    <div class="mt-4">
                        <a href="Inicio-Sesion.jsp" class="btn btn-lg me-3 btn-contrast">Iniciar Sesion</a>
                        <a href="registro-Sesion.jsp" class="btn btn-lg btn-light">Registrarse</a>
                    </div>
                </div>
            </section>

            <!-- Seccion 1: Sobre nosotros -->
            <section class="section d-flex align-items-center justify-content-center text-center">
                <div class="container">
                    <h2 class="fs-1">Sobre nosotros</h2>
                    <p class="fs-4">
                        Bibliotequero es un espacio libre donde cada usuario puede compartir sus publicaciones,
                        descubrir nuevas lecturas y acceder a la compra de libros de manera sencilla.
                    </p>
                </div>
            </section>

            <!-- Seccion 2: Catalogo -->
            <section class="section d-flex align-items-center justify-content-center text-center">
                <div class="container">
                    <h2 class="fs-1">Catalogo destacado</h2>
                    <p class="fs-4">Un vistazo a los primeros ti­tulos de nuestra coleccion:</p>
                    <div id="libros1" class="row row-cols-1 row-cols-md-3 g-4 mt-4">
                        <!-- AquÃ­ se insertan los 3 libros con llamadaApi() -->
                    </div>
                </div>
            </section>

            <!-- Seccion 3: Lo que encontraras -->
            <section class="section d-flex align-items-center justify-content-center text-center">
                <div class="container">
                    <h2 class="fs-1">Lo que encontraras aqui!­</h2>
                    <p class="fs-4">
                        Un espacio libre y seguro para todos los lectores, con un catalogo diverso, 
                        recomendaciones personalizadas y la oportunidad de interactuar con otros amantes de la lectura.
                    </p>
                </div>
            </section>

            <!-- Footer -->
            <footer class="section d-flex align-items-center justify-content-center text-center text-white">
                <p class="fs-5">&copy; 2025 Bibliotequero | Tu biblioteca digital</p>
            </footer>


        </main>

        <script src="node_modules/bootstrap/dist/js/bootstrap.bundle.js"></script>
        <script src="../pantallas/script.js"></script>
    </body>
</html>
