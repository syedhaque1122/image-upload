

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

import 'add_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){

          Navigator.of(context).push(MaterialPageRoute(builder: (context)=> AddImage()));
        },
      ),
      body: StreamBuilder(stream: FirebaseFirestore.instance.collection('imageURLs').snapshots(),  builder: ( context,  snapshot) {

        return !snapshot.hasData
            ?Center(
          child: CircularProgressIndicator(),
        )
            :Container(
           child: GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount
             (crossAxisCount: 3),
               itemBuilder: (context,index)
               {
                 return Container(
                   margin:  EdgeInsets.all(4),
                   child: FadeInImage.memoryNetwork(
                       fit: BoxFit.cover,
                       placeholder: kTransparentImage, image: snapshot.data!.docs[index].get('url')),

                 );



               }),


        );

      },
      ),

    );

  }
}
