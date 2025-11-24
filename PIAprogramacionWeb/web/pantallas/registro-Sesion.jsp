<!DOCTYPE html>
<!-- registro-Sesion.jsp -->
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Bibliotequero - Registro</title>
        <link rel="stylesheet" href="../node_modules/bootstrap/dist/css/bootstrap.min.css"/>
        <link href="https://fonts.googleapis.com/css?family=Oranienbaum" rel="stylesheet">
        <link rel="stylesheet" href="../Estilos/estilos.css">
    </head>
    <body>
        <!-- Navbar -->
        <nav class="navbar fixed-top">
            <div class="container-fluid">
                <a class="navbar-brand d-flex align-items-center text-white" href="WelcomeIn.jsp">
                    <img src="../Logo/Logito.png" alt="Logo" width="30" height="30" class="me-2">
                    Bibliotequero
                </a>
                <button class="navbar-toggler bg-light border-black-50" type="button" data-bs-toggle="offcanvas" 
                        data-bs-target="#offcanvasNavbar" aria-controls="offcanvasNavbar" aria-label="Toggle navigation">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <div class="offcanvas offcanvas-end" tabindex="-1" id="offcanvasNavbar" aria-labelledby="offcanvasNavbarLabel">
                    <div class="offcanvas-header">
                        <h5 class="offcanvas-title text-black" id="offcanvasNavbarLabel">Bibliotequero</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="offcanvas" aria-label="Close"></button>
                    </div>
                    <div class="offcanvas-body">
                        <ul class="navbar-nav justify-content-end flex-grow-1 pe-3">
                            <li class="nav-item">
                                <a class="nav-link active" aria-current="page" href="../pantallas/WelcomeIn.jsp">Bienvenida</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link active" aria-current="page" href="../pantallas/Inicio-Sesion.jsp">Iniciar Sesion</a>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
        </nav>

        <!-- Contenido principal -->
        <div class="container mt-4">
            <div class="row justify-content-center">
                <!-- Columna del formulario -->
                <div class="col-md-5 mb-4">
                    <div class="card p-4 shadow">
                        <!-- Mostrar mensajes de error -->
                        <%
                            String error = request.getParameter("error");
                            String registro = request.getParameter("registro");
                    
                            if (registro != null && registro.equals("exitoso")) {
                        %>
                        <div class="alert alert-success" role="alert">
                            ? ¡Registro exitoso! Ahora puedes iniciar sesión.
                        </div>
                        <%
                            }
                    
                            if (error != null) {
                                String mensaje = "";
                                String tipo = "danger";
                        
                                switch (error) {
                                    case "campos_vacios":
                                        mensaje = "?? Por favor, completa todos los campos.";
                                        break;
                                    case "usuario_duplicado":
                                        mensaje = "?? El correo electrónico o nombre de usuario ya está registrado.";
                                        break;
                                    case "correo_invalido":
                                        mensaje = "?? Por favor, ingresa un correo electrónico válido.";
                                        break;
                                    case "fecha_invalida":
                                        mensaje = "?? La fecha de nacimiento no es válida.";
                                        break;
                                    case "edad_insuficiente":
                                        mensaje = "?? Debes tener al menos 13 años para registrarte.";
                                        break;
                                    case "general":
                                        mensaje = "?? Error en el registro. Por favor, intenta nuevamente.";
                                        break;
                                    default:
                                        mensaje = "?? Error en el registro.";
                                }
                        %>
                        <div class="alert alert-<%= tipo %>" role="alert">
                            <%= mensaje %>
                        </div>
                        <%
                            }
                        %>

                        <!-- Formulario con soporte para archivos -->
                        <form action="${pageContext.request.contextPath}/registro" method="post" 
                              class="form-floating" enctype="multipart/form-data">

                            <!-- Nombre -->
                            <div class="mb-3">
                                <label for="nombre" class="form-label">Nombre completo</label>
                                <input type="text" class="form-control" id="nombre" name="nombre" 
                                       placeholder="Escribe tu nombre" 
                                       value="<%= request.getParameter("nombre") != null ? request.getParameter("nombre") : "" %>" 
                                       required>
                            </div>

                            <!-- Usuario -->
                            <div class="mb-3">
                                <label for="usuario" class="form-label">Nombre de usuario</label>
                                <input type="text" class="form-control" id="usuario" name="usuario" 
                                       placeholder="Escribe tu usuario" 
                                       value="<%= request.getParameter("usuario") != null ? request.getParameter("usuario") : "" %>" 
                                       required>
                            </div>

                            <!-- Fecha de nacimiento -->
                            <div class="mb-3">
                                <label for="fechaNacimiento" class="form-label">Fecha de nacimiento</label>
                                <input type="date" class="form-control" id="fechaNacimiento" name="fechaNacimiento" 
                                       value="<%= request.getParameter("fechaNacimiento") != null ? request.getParameter("fechaNacimiento") : "" %>" 
                                       required>
                            </div>

                            <!-- Correo -->
                            <div class="mb-3">
                                <label for="correo" class="form-label">Correo electrónico</label>
                                <input type="email" class="form-control" id="correo" name="correo" 
                                       value="<%= request.getParameter("correo") != null ? request.getParameter("correo") : "" %>" 
                                       required>
                                <div id="emailHelp" class="form-text">Nunca compartiremos tu correo con nadie más.</div>
                            </div>

                            <!-- Contraseña -->
                            <div class="mb-3">
                                <label for="password" class="form-label">Contraseña</label>
                                <input type="password" class="form-control" id="password" name="password" required>
                                <div class="form-text">Mínimo 6 caracteres.</div>
                            </div>

                            <!-- Foto de perfil -->
                            <div class="mb-3">
                                <div class="card p-4 shadow text-center">
                                    <label for="fotoPerfil" class="form-label">Foto de perfil</label>
                                    <img id="preview" src="https://via.placeholder.com/150" alt="Foto de perfil" class="img-preview rounded-circle mb-3">
                                    <input class="form-control" type="file" id="fotoPerfil" name="fotoPerfil" accept="image/*" onchange="previuWalafoto(event)">
                                    <div class="form-text">Opcional</div>
                                </div>
                            </div>

                            <!-- Botón -->
                            <button id="button" type="submit" class="btn btn-primary w-100">Crear cuenta</button>

                            <div class="text-center mt-3">
                                <a href="Inicio-Sesion.jsp" class="text-decoration-none">¿Ya tienes cuenta? Inicia sesión</a>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Columna de frases -->
                <div class="col-md-3">
                    <div id="frasesSlider" class="carousel slide carousel-fade" data-bs-ride="carousel" data-bs-interval="4000">
                        <div class="carousel-inner">
                            <!-- Frase 1 -->
                            <div class="carousel-item active">
                                <blockquote class="blockquote text-white p-3">
                                    <p>"Vale la pena volver a empezar, una y mil veces, mientras uno esta vivo. Porque incluso en las manos mas pequeñas y cansadas, late una esperanza invencible".</p>
                                    <footer class="blockquote-footer text-white mt-2">Gabriel Garcia Marquez</footer>
                                </blockquote>
                            </div>

                            <!-- Frase 2 -->
                            <div class="carousel-item">
                                <blockquote class="blockquote text-white p-3">
                                    <p>"El escritor escribe su libro para explicarse a si mismo lo que no se puede explicar".</p>
                                    <footer class="blockquote-footer text-white mt-2">Jorge Luis Borges</footer>
                                </blockquote>
                            </div>

                            <!-- Frase 3 -->
                            <div class="carousel-item">
                                <blockquote class="blockquote text-white p-3">
                                    <p>Si el conocimiento puede crear problemas, no es con la ignorancia con lo que podremos resolverlos.</p>
                                    <footer class="blockquote-footer text-white mt-2">Isaac Asimov</footer>
                                </blockquote>
                            </div>

                            <!-- Frase 4 -->
                            <div class="carousel-item">
                                <blockquote class="blockquote text-white p-3">
                                    <p>Los libros se respetan usandolos, no dejandolos en paz.</p>
                                    <footer class="blockquote-footer text-white mt-2">Umberto Eco</footer>
                                </blockquote>
                            </div>

                            <!-- Frase 5 -->
                            <div class="carousel-item">
                                <blockquote class="blockquote text-white p-3">
                                    <p>"Hay que dormir con los ojos abiertos, hay que soñar con las manos hay que soñar en voz alta, hay que cantar hasta que el canto eche raices, troncos, ramas, ramas, pajaros, astros"</p>
                                    <footer class="blockquote-footer text-white mt-2">Octavio Paz</footer>
                                </blockquote>
                            </div>

                            <!-- Frase 6 -->
                            <div class="carousel-item">
                                <blockquote class="blockquote text-white p-3">
                                    <p>"Todo escritor que crea es un mentiroso; la literatura es mentira, pero de esa mentira sale una recreacion de la realidad; recrear la realidad es, pues, uno de los principios fundamentales de la creacion."</p>
                                    <footer class="blockquote-footer text-white mt-2">Juan Rulfo</footer>
                                </blockquote>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script src="../node_modules/bootstrap/dist/js/bootstrap.bundle.min.js"></script>
        <script>
                                        // Validación adicional en el cliente
                                        document.querySelector('form').addEventListener('submit', function (e) {
                                            const password = document.getElementById('password').value;
                                            const fechaNacimiento = document.getElementById('fechaNacimiento').value;
                                            const fotoPerfil = document.getElementById('fotoPerfil').files[0];

                                            // Validar longitud de contraseña
                                            if (password.length < 6) {
                                                e.preventDefault();
                                                alert('La contraseña debe tener al menos 6 caracteres.');
                                                return;
                                            }

                                            // Validar fecha (edad mínima 13 años)
                                            if (fechaNacimiento) {
                                                const fechaNac = new Date(fechaNacimiento);
                                                const fechaMinima = new Date();
                                                fechaMinima.setFullYear(fechaMinima.getFullYear() - 13);

                                                if (fechaNac > fechaMinima) {
                                                    e.preventDefault();
                                                    alert('Debes tener al menos 13 años para registrarte.');
                                                    return;
                                                }
                                            }

                                            // Validar imagen si se seleccionó alguna
                                            if (fotoPerfil) {
                                                // Validar tipo de archivo
                                                const tiposPermitidos = ['image/jpeg', 'image/png', 'image/gif'];
                                                if (!tiposPermitidos.includes(fotoPerfil.type)) {
                                                    e.preventDefault();
                                                    alert('Solo se permiten imágenes JPEG, PNG o GIF.');
                                                    return;
                                                }

                                                // Validar tamaño (2MB máximo)
                                                if (fotoPerfil.size > 2 * 1024 * 1024) {
                                                    e.preventDefault();
                                                    alert('La imagen no debe pesar más de 2MB.');
                                                    return;
                                                }
                                            }
                                        });

                                        function previuWalafoto(event) {
                                            const input = event.target;
                                            const preview = document.getElementById('preview');

                                            if (input.files && input.files[0]) {
                                                const file = input.files[0];

                                                // Validar que sea una imagen
                                                if (!file.type.startsWith('image/')) {
                                                    alert('Por favor, selecciona un archivo de imagen.');
                                                    input.value = '';
                                                    return;
                                                }

                                                // Validar tamaño
                                                if (file.size > 2 * 1024 * 1024) {
                                                    alert('La imagen es demasiado grande. Máximo 2MB.');
                                                    input.value = '';
                                                    return;
                                                }

                                                const reader = new FileReader();
                                                reader.onload = function (e) {
                                                    preview.src = e.target.result;
                                                    preview.style.display = 'block';
                                                }
                                                reader.readAsDataURL(file);
                                            } else {
                                                preview.src = 'https://via.placeholder.com/150';
                                            }
                                        }

                                        // Validación en tiempo real para correo y usuario
                                        document.getElementById('correo').addEventListener('blur', function () {
                                            validarCorreo(this.value);
                                        });

                                        document.getElementById('usuario').addEventListener('blur', function () {
                                            validarUsuario(this.value);
                                        });

                                        function validarCorreo(correo) {
                                            const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                                            if (!regex.test(correo)) {
                                                mostrarError('correo', 'Correo electrónico inválido');
                                            } else {
                                                limpiarError('correo');
                                            }
                                        }

                                        function validarUsuario(usuario) {
                                            if (usuario.length < 3) {
                                                mostrarError('usuario', 'El usuario debe tener al menos 3 caracteres');
                                            } else {
                                                limpiarError('usuario');
                                            }
                                        }

                                        function mostrarError(campo, mensaje) {
                                            limpiarError(campo);
                                            const input = document.getElementById(campo);
                                            const divError = document.createElement('div');
                                            divError.className = 'text-danger small mt-1';
                                            divError.id = campo + '-error';
                                            divError.textContent = mensaje;
                                            input.parentNode.appendChild(divError);
                                            input.classList.add('is-invalid');
                                        }

                                        function limpiarError(campo) {
                                            const errorDiv = document.getElementById(campo + '-error');
                                            if (errorDiv) {
                                                errorDiv.remove();
                                            }
                                            document.getElementById(campo).classList.remove('is-invalid');
                                        }
        </script>
    </body>
</html>