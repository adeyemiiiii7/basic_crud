import 'package:basic_crud/models/data_model.dart';
import 'package:flutter/material.dart';

typedef OnCompose = void Function(String firstName, String lastName);

  final _firsNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  
Future<bool> showDeleteDialog(BuildContext context){
  return showDialog(
    context: context, 
  builder: (context){
    return  AlertDialog(
      content:  const Text('Are you sure you want to delete this item'),
      actions: [
        TextButton(
          onPressed:(){ Navigator.of(context).pop(false);
          },
          child: const Text('NO')
          ),
          TextButton(onPressed: (){
            Navigator.of(context).pop(true);
          },
          child: const Text('Yes'))
      ]
    );
  },
  ).then((value) {
    if(value is bool){
      return value;
    
  } else {
     return false;

  }
  });
}
Future <Person?> showUpdatedDialog(BuildContext context, Person person){
  return showDialog(context: context, builder: (context){
    _firsNameController.text = person.FirstName;
_lastNameController.text = person.LastName;
    return AlertDialog(
     content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
       const Text('Enter your Updated values: '),
             TextField(controller: _firsNameController,
           decoration: const InputDecoration(
              hintText: 'First Name',
            ),),
          TextField(controller: _lastNameController,
           decoration: const InputDecoration(
              hintText: 'First Name',
            ),),
     ],),
     actions: [
      TextButton(onPressed: (){ Navigator.of(context).pop(null);
      
      },
      child: const Text('Cancel'),
      ),
      TextButton(onPressed: (){
        final editedPerson = Person(
          id: person.id, 
          FirstName: _firsNameController.text,
         LastName: _lastNameController.text);
         Navigator.of(context).pop(editedPerson);

      }, child: const Text('Save'),
      )
     ],
  
    );

  },
  ).then((value) {
    if(value is Person){
      return value;
    
  } else {
     return null;

  }
});

}

class ComposeWidget extends StatefulWidget {
  final OnCompose onCompose;

  const ComposeWidget({Key? key, required this.onCompose}) : super(key: key);

  @override
  _ComposeWidgetState createState() => _ComposeWidgetState();
}

class _ComposeWidgetState extends State<ComposeWidget> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;

  @override
  void initState() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: _firstNameController,
            decoration: const InputDecoration(
              hintText: 'First Name',
            ),
          ),
          TextField(
            controller: _lastNameController,
            decoration: const InputDecoration(
              hintText: 'Last Name',
            ),
          ),
          TextButton.icon(
            onPressed: () {
              final firstName = _firstNameController.text;
              final lastName = _lastNameController.text;
              widget.onCompose(firstName, lastName);
              _firstNameController.clear();
              _lastNameController.clear();
            },
            icon: const Icon(
              Icons.arrow_forward_rounded,
            ),
            label: const Text('Add To List'),
          ),
        ],
      ),
    );
  }
}
