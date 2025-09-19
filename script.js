///////////////////////////////////////////////////////////////////////
//funciones para la toma y carga de la foto de perfil

function previuWalafoto(event) {
  const reader = new FileReader();
  reader.onload = function() {
    const output = document.getElementById('preview');
    output.src = reader.result;

    // 👇 Guardamos la imagen en localStorage
    localStorage.setItem("fotoPerfil", reader.result);
  };
  reader.readAsDataURL(event.target.files[0]);
}

// 👇 Al cargar la página, revisamos si hay foto guardada
document.addEventListener("DOMContentLoaded", () => {
  const fotoGuardada = localStorage.getItem("fotoPerfil");
  if (fotoGuardada) {
    document.getElementById("fotoNavbar").src = fotoGuardada;
  }
});

/////////////////////////////////////////////////////////////////////////////////////////////////////////


/* global bootstrap: false */
(function () {
  'use strict'
  var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
  tooltipTriggerList.forEach(function (tooltipTriggerEl) {
    new bootstrap.Tooltip(tooltipTriggerEl)
  })
})()

//funcion para que la imagen de la previuWalafoto se vea en el circulo del la pagina de CatalogoPaginaIncio.html
/////////////////////////////////////////////////////////////////////////////////////////////////////////
//llamada de una api para obtener libros 
function llamadaApi() {
  fetch('https://openlibrary.org/people/mekBot/books/currently-reading.json')
    .then(response => response.json())
    .then(data => {
      console.log(data);
      const libros = data.reading_log_entries; // la API devuelve reading_log_entries
      let html = '';

      libros.forEach(entry => {
        const libro = entry.work; // cada entrada tiene un objeto work
        const coverId = libro.cover_id 
          ? `https://covers.openlibrary.org/b/id/${libro.cover_id}-M.jpg` 
          : 'https://via.placeholder.com/150x200?text=Sin+Portada';

        html += `
        <div class="col">
          <div class="card h-100 shadow-sm">
            <img src="${coverId}" class="card-img-top" alt="${libro.title}">
            <div class="card-body">
              <h5 class="card-title">${libro.title}</h5>
              <p class="card-text">${libro.author_names ? 'by ' + libro.author_names[0] : 'Autor desconocido'}</p>
              <a href="https://openlibrary.org${libro.key}" 
                 class="btn btn-primary" target="_blank">Ver libro</a>
            </div>
          </div>
        </div>
        `;
      });

      document.getElementById('libros').innerHTML = html;
    })
    .catch(error => console.error('Error:', error));
}

// Ejecutar cuando cargue la página
document.addEventListener("DOMContentLoaded", llamadaApi);
///////////////////
//y creo que seria todo

function llamadaApi2() {
  fetch('https://openlibrary.org/people/mekBot/books/currently-reading.json')
    .then(response => response.json())
    .then(data => {
      console.log(data);
      const libros = data.reading_log_entries.slice(0, 3); // solo 3 libros
      let html = '';

      libros.forEach(entry => {
        const libro = entry.work;
        const coverId = libro.cover_id
          ? `https://covers.openlibrary.org/b/id/${libro.cover_id}-M.jpg`
          : 'https://via.placeholder.com/150x200?text=Sin+Portada';

        html += `
        <div class="col">
          <div class="card h-100 shadow-sm">
            <img src="${coverId}" class="card-img-top" alt="${libro.title}">
            <div class="card-body">
              <h5 class="card-title">${libro.title}</h5>
              <p class="card-text">${libro.author_names ? 'by ' + libro.author_names[0] : 'Autor desconocido'}</p>
            </div>
          </div>
        </div>
        `;
      });

      document.getElementById('libros1').innerHTML = html;
    })
    .catch(error => console.error('Error:', error));
}

document.addEventListener("DOMContentLoaded", llamadaApi2);