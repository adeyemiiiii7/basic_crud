import 'package:basic_crud/models/data_model.dart';
import 'package:basic_crud/widgets/compose_widgets.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
late final PersonDB _crudStorage ;
@override
  void initState() {
    _crudStorage = PersonDB(dbName: 'db.sqlite');
    _crudStorage.open();
    super.initState();
  }
  @override
  void dispose() {
    _crudStorage.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Crud',
        ),
        centerTitle: true,
        
      ),
      body: StreamBuilder(
        stream: _crudStorage.all(),
         builder:(context, snapshot){
          switch (snapshot.connectionState){
            case ConnectionState.active:
            case ConnectionState.waiting:
            //print(snapshot);
            if(snapshot.data == null){
              return const Center(child: CircularProgressIndicator(),);
            }
            final people = snapshot.data as List<Person>;
           // print(people);
           return Column(
             children: [
              ComposeWidget (onCompose: (String FirstName, String LastName) async {  
           await _crudStorage.create (FirstName, LastName);
              },),
               Expanded(
                 child: ListView.builder
                 (itemCount: people.length,
                  itemBuilder: (context, index){
                    final person = people[index];
                   return ListTile(
                   onTap: () async {
                    final editedPerson =await showUpdatedDialog(context, person); 
                    if(editedPerson != null) {
                      await _crudStorage.update(editedPerson);

                    }
                   },
                  title: Text(person.fullName),
                  subtitle: Text('ID: ${person.id}'),
                  trailing: TextButton(
                    child: const Icon(Icons.disabled_by_default_outlined),
                    onPressed: ()async {
                      final shouldDelete = await showDeleteDialog(context);
                    //  print(shouldDelete);
                    if(shouldDelete){
                      await _crudStorage.delete(person);
                    }

                    },
                    ),
                   );
                  }
                  ),
               ),
             ],
           );
           default:
           return const CircularProgressIndicator();
          }
          
         }
        )
    );
  }
}