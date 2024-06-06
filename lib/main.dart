// ignore_for_file: unnecessary_import

import 'package:flutter/material.dart';  // Importa el paquete de Flutter para usar widgets y temas.
import 'package:english_words/english_words.dart';  // Importa el paquete para generar pares de palabras en inglés.
import 'package:flutter/rendering.dart';  // Importa el paquete para manipulación avanzada de renderizado.
import 'package:provider/provider.dart';  // Importa el paquete Provider para gestión de estado.

void main() {  
  runApp(const MyApp());  // Ejecuta la aplicación MyApp.
}

class MyApp extends StatelessWidget {  // Define una clase StatelessWidget llamada MyApp.
  const MyApp({super.key});  // Constructor de MyApp.

  @override
  Widget build(BuildContext context) {  
    return ChangeNotifierProvider(  // Proporciona un ChangeNotifier a los widgets descendientes.
      create: (context) => MyAppState(),  // Crea una instancia de MyAppState.
      child: MaterialApp(  // Envuelve la aplicación en un MaterialApp.
        title: 'Namer App',  // Título de la aplicación.
        theme: ThemeData(  // Define el tema de la aplicación.
          useMaterial3: true,  // Activa el uso de Material 3.
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 18, 101, 5)),  // Establece un esquema de color basado en una semilla.
        ),
        home: MyHomePage(),  // Define la página inicial de la aplicación.
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {  // Clase para manejar el estado de la aplicación.
  var current = WordPair.random();  // Variable que almacena un par de palabras aleatorio.
  
  void getNext() {  
    current = WordPair.random();  // Genera un nuevo par de palabras aleatorio.
    notifyListeners();  // Notifica a los oyentes sobre el cambio.
  }
  
  var favorites = <WordPair>[];  // Lista que almacena los pares de palabras favoritos.

  void toggleFavorite() {  
    if (favorites.contains(current)) {  // Verifica si el par actual está en la lista de favoritos.
      favorites.remove(current);  // Si está, lo elimina.
    } else {
      favorites.add(current);  // Si no está, lo agrega.
    }
    notifyListeners();  // Notifica a los oyentes sobre el cambio.
  }
}

class MyHomePage extends StatefulWidget {  // Define una clase StatefulWidget llamada MyHomePage.
  @override
  State<MyHomePage> createState() => _MyHomePageState();  // Crea el estado asociado a MyHomePage.
}

class _MyHomePageState extends State<MyHomePage> {  
  var selectedIndex = 0;  // Variable que almacena el índice del botón de navegación seleccionado.
  
  @override
  Widget build(BuildContext context) {  
    Widget page;  // Variable para almacenar el widget de la página actual.
    switch (selectedIndex) {  
      case 0:
        page = GeneratorPage();  // Si el índice es 0, muestra GeneratorPage.
        break;
      case 1:
        page = Placeholder();  // Si el índice es 1, muestra un Placeholder.
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');  // Lanza un error si el índice no es válido.
    }
    return LayoutBuilder(  
      builder: (context, constraints) {  
        return Scaffold(  
          body: Row(  
            children: [
              SafeArea(  
                child: NavigationRail(  
                  extended: constraints.maxWidth >= 600,  // Extiende el rail de navegación si el ancho es suficiente.
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),  // Ícono para la pestaña Home.
                      label: Text('Home'),  // Etiqueta para la pestaña Home.
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),  // Ícono para la pestaña Favorites.
                      label: Text('Favorites'),  // Etiqueta para la pestaña Favorites.
                    ),
                  ],
                  selectedIndex: selectedIndex,  // Establece el índice seleccionado.
                  onDestinationSelected: (value) {  
                    setState(() {
                      selectedIndex = value;  // Cambia el índice seleccionado cuando se selecciona una nueva pestaña.
                    });
                  },
                ),
              ),
              Expanded(  
                child: Container(  
                  color: Theme.of(context).colorScheme.primaryContainer,  // Establece el color del fondo del contenedor.
                  child: page,  // Muestra la página actual.
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class GeneratorPage extends StatelessWidget {  // Define una clase StatelessWidget llamada GeneratorPage.
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();  // Obtiene el estado de la aplicación.
    var pair = appState.current;  // Obtiene el par de palabras actual.
    
    IconData icon;  
    if (appState.favorites.contains(pair)) {  
      icon = Icons.favorite;  // Si el par está en favoritos, usa el ícono de favorito lleno.
    } else {
      icon = Icons.favorite_border;  // Si no está en favoritos, usa el ícono de favorito vacío.
    }
    
    return Center(  
      child: Column(  
        mainAxisAlignment: MainAxisAlignment.center,  // Centra los hijos en el eje principal.
        children: [
          BigCard(pair: pair),  // Muestra una tarjeta grande con el par de palabras.
          SizedBox(height: 10),  // Añade un espacio de 10 píxeles.
          Row(  
            mainAxisSize: MainAxisSize.min,  // Ajusta el tamaño mínimo en el eje principal.
            children: [
              ElevatedButton.icon(  
                onPressed: () {  
                  appState.toggleFavorite();  // Alterna el estado de favorito del par de palabras.
                },
                icon: Icon(icon),  // Muestra el ícono correspondiente.
                label: Text('Like'),  // Etiqueta del botón.
              ),
              SizedBox(width: 10),  // Añade un espacio de 10 píxeles.
              ElevatedButton(  
                onPressed: () {  
                  appState.getNext();  // Genera el siguiente par de palabras.
                },
                child: Text('Next'),  // Etiqueta del botón.
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {  // Define una clase StatelessWidget llamada FavoritesPage.
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();  // Obtiene el estado de la aplicación.

    if (appState.favorites.isEmpty) {  
      return Center(  
        child: Text('No favorites yet.'),  // Muestra un mensaje si no hay favoritos.
      );
    }

    return ListView(  
      children: [
        Padding(  
          padding: const EdgeInsets.all(20),  // Añade padding de 20 píxeles.
          child: Text('You have '
              '${appState.favorites.length} favorites:'),  // Muestra el número de favoritos.
        ),
        for (var pair in appState.favorites)  
          ListTile(  
            leading: Icon(Icons.favorite),  // Ícono de favorito.
            title: Text(pair.asLowerCase),  // Texto del par de palabras en minúsculas.
          ),
      ],
    );
  }
}

class BigCard extends StatelessWidget {  // Define una clase StatelessWidget llamada BigCard.
  const BigCard({
    super.key,
    required this.pair,  // Requiere un par de palabras.
  });

  final WordPair pair;  // Variable para almacenar el par de palabras.

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);  // Obtiene el tema de la aplicación.
    final style = theme.textTheme.displayMedium!.copyWith(  
      color: theme.colorScheme.onPrimary,  // Establece el color del texto.
    );
    return Card(  
      color: theme.colorScheme.primary,  // Establece el color de la tarjeta.
      child: Padding(  
        padding: const EdgeInsets.all(20),  // Añade padding de 20 píxeles.
        child: Text(
          pair.asLowerCase,  // Muestra el par de palabras en minúsculas.
          style: style,  // Aplica el estilo de texto.
          semanticsLabel: "${pair.first} ${pair.second}",  // Etiqueta semántica.
        ),
      ),
    );
  }
}

/* class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

        IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Text('Mi Primer Boton en Flutter:'),
            BigCard(pair: pair),
            SizedBox(height: 20),
            //Text(appState.current.asLowerCase),
        
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                 ElevatedButton.icon(
                  onPressed: () {
                    appState.toggleFavorite();
                  },
                  icon: Icon(icon),
                  label: Text('Like'),
                ),
                 SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    appState.getNext(); 
                   // print('button pressed!');
                     
                  },
                  child: Text('Siguiente'),
                ),
              ],
            ),
        
          ],
        ),
      ),
    );

  }
}
 */
