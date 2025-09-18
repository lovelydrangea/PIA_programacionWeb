
// Vista previa de la imagen seleccionada, que es solo para verla a ver si se ve xd
function previuWalafoto(event) {
  const reader = new FileReader(); //para leer los archivos necesitamos de este objeto que se llama leetearchivos y con la funcion del reader que ya creamos
  // sera que que podremos llamar al elemento preview y output pues sera la salida de, osea que se muestra la imagen que es el resulado
  reader.onload = function(){
    const output = document.getElementById('preview');
    output.src = reader.result;
  };
  reader.readAsDataURL(event.target.files[0]);
}

/* global bootstrap: false */
(function () {
  'use strict'
  var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
  tooltipTriggerList.forEach(function (tooltipTriggerEl) {
    new bootstrap.Tooltip(tooltipTriggerEl)
  })
})()

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
              <p class="card-text">${libro.authors ? 'by ' + libro.authors[0].name : 'Autor desconocido'}</p>
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
