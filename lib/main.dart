// ignore_for_file: unnecessary_import

import 'package:flutter/material.dart'; // Importa el paquete de Flutter para usar widgets y temas.
import 'package:english_words/english_words.dart'; // Importa un paquete para generar pares de palabras en inglés.
import 'package:flutter/rendering.dart'; // Importa el paquete para manipulación avanzada de renderizado.
import 'package:provider/provider.dart'; // Importa el paquete Provider para la gestión del estado.

void main() {  
  runApp(const MyApp()); // Ejecuta la aplicación MyApp.
}

class MyApp extends StatelessWidget { // Define una clase MyApp que no cambia (StatelessWidget).
  const MyApp({super.key}); // Constructor de MyApp.

  @override
  Widget build(BuildContext context) {
    // Crea y configura el widget principal de la app.
    return ChangeNotifierProvider( // Proveedor de estado que notifica a sus widgets descendientes.
      create: (context) => MyAppState(), // Crea una instancia del estado de la aplicación.
      child: MaterialApp( // Widget que envuelve la aplicación y define su estructura y tema.
        title: 'Mi Primera App', // Título de la aplicación.
        theme: ThemeData( // Define el tema de la aplicación.
          useMaterial3: true, // Usa Material 3.
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 12, 150, 127)), // Establece un esquema de color basado en una semilla.
        ),
        home: MyHomePage(), // Define la página inicial de la aplicación.
      ),
    );
  }
}

class MyAppState extends ChangeNotifier { // Clase que maneja el estado de la aplicación.
  var current = WordPair.random(); // Variable que almacena un par de palabras aleatorio.

  void getNext() { // Función para obtener el siguiente par de palabras.
    current = WordPair.random(); // Genera un nuevo par de palabras aleatorio.
    notifyListeners(); // Notifica a los widgets que están escuchando los cambios.
  }

  var favorites = <WordPair>[]; // Lista que almacena los pares de palabras favoritos.

  void toggleFavorite() { // Función para agregar o quitar el par actual de favoritos.
    if (favorites.contains(current)) { // Verifica si el par actual está en la lista de favoritos.
      favorites.remove(current); // Si está, lo elimina.
    } else {
      favorites.add(current); // Si no está, lo agrega.
    }
    notifyListeners(); // Notifica a los widgets que están escuchando los cambios.
  }
}

class MyHomePage extends StatefulWidget { // Define una clase MyHomePage que puede cambiar (StatefulWidget).
  @override
  State<MyHomePage> createState() => _MyHomePageState(); // Crea el estado asociado a MyHomePage.
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0; // Variable que almacena el índice del botón de navegación seleccionado.

  @override
  Widget build(BuildContext context) {
    Widget page; // Variable para almacenar el widget de la página actual.
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage(); // Si el índice es 0, muestra el valor de GeneratorPage.
        break;
      case 1:
        page = FavoritesPage(); // Si el índice es 1, muestra el valor de FavoritesPage.
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex'); // Error si el índice no es válido.
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold( // Widget que proporciona la estructura visual básica.
          body: Row( // Organiza los widgets en una fila.
            children: [
              SafeArea( // Asegura que los widgets no se superpongan con áreas del sistema.
                child: NavigationRail( // Barra de navegación lateral.
                  extended: constraints.maxWidth >= 600, // Extiende la barra si el ancho es suficiente.
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home), // Ícono para la pestaña Home.
                      label: Text('Principal'), // Etiqueta para la pestaña Home.
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite), // Ícono para la pestaña Favoritos.
                      label: Text('Favoritos'), // Etiqueta para la pestaña Favoritos.
                    ),
                  ],
                  selectedIndex: selectedIndex, // Establece el índice seleccionado.
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value; // Cambia el índice seleccionado cuando se selecciona una nueva pestaña.
                    });
                  },
                ),
              ),
              Expanded( // Expande el widget para ocupar todo el espacio disponible.
                child: Container( // Contenedor para la página actual.
                  color: Theme.of(context).colorScheme.primaryContainer, // Establece el color de fondo.
                  child: page, // Muestra la página actual.
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class GeneratorPage extends StatelessWidget { // Define una clase GeneratorPage que no cambia (StatelessWidget).
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Obtiene el estado de la aplicación.
    var pair = appState.current; // Obtiene el par de palabras actual.

    IconData icon;
    if (appState.favorites.contains(pair)) { 
      icon = Icons.favorite; // Si el par está en favoritos, muestra el ícono de favorito lleno.
    } else {
      icon = Icons.favorite_border; // Si no está en favoritos, muestra el ícono de favorito vacío.
    }

    return Center( // Centra los widgets hijos.
      child: Column( // Organiza los widgets en una columna.
        mainAxisAlignment: MainAxisAlignment.center, // Centra los widgets en el eje principal.
        children: [
          BigCard(pair: pair), // Muestra una tarjeta grande con el par de palabras.
          SizedBox(height: 10), // Añade un espacio de 10 píxeles.
          Row( // Organiza los widgets en una fila.
            mainAxisSize: MainAxisSize.min, // Ajusta el tamaño mínimo en el eje principal.
            children: [
              ElevatedButton.icon( // Botón con ícono.
                onPressed: () {
                  appState.toggleFavorite(); // Alterna el estado de favorito del par de palabras.
                },
                icon: Icon(icon), // Muestra el ícono correspondiente.
                label: Text('Me Gusta'), // Etiqueta del botón.
              ),
              SizedBox(width: 10), // Añade un espacio de 10 píxeles.
              ElevatedButton( // Botón normal.
                onPressed: () {
                  appState.getNext(); // Genera el siguiente par de palabras.
                },
                child: Text('Siguiente'), // Etiqueta del botón.
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget { // Define una clase FavoritesPage que no cambia (StatelessWidget).
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Obtiene el estado de la aplicación.

    if (appState.favorites.isEmpty) {
      return Center( // Centra los widgets hijos.
        child: Text('No tienes favoritos.'), // Muestra un mensaje si no hay favoritos.
      );
    }

    return ListView( // Lista de desplazamiento vertical.
      children: [
        Padding( // Añade espacio alrededor del texto.
          padding: const EdgeInsets.all(20), // Padding de 20 píxeles.
          child: Text('Tienes '
              '${appState.favorites.length} Favoritos:'), // Muestra el número de favoritos.
        ),
        for (var pair in appState.favorites)
          ListTile( // Elemento de lista.
            leading: Icon(Icons.favorite), // Ícono de favorito.
            title: Text(pair.asLowerCase), // Texto del par de palabras en minúsculas.
          ),
      ],
    );
  }
}

class BigCard extends StatelessWidget { // Define una clase BigCard que no cambia (StatelessWidget).
  const BigCard({
    super.key,
    required this.pair, // Requiere un par de palabras.
  });

  final WordPair pair; // Variable para almacenar el par de palabras.

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Obtiene el tema de la aplicación.
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary, // Establece el color del texto.
    );
    return Card( // Tarjeta.
      color: theme.colorScheme.primary, // Establece el color de la tarjeta.
      child: Padding( // Añade espacio dentro de la tarjeta.
        padding: const EdgeInsets.all(20), // Padding de 20 píxeles.
        child: Text(
          pair.asLowerCase, // Muestra el par de palabras en minúsculas.
          style: style, // Aplica el estilo de texto.
          semanticsLabel: "${pair.first} ${pair.second}", // Etiqueta semántica.
        ),
      ),
    );
  }
}