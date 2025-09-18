
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