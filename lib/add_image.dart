
import 'dart:io';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as Path;


class AddImage extends StatefulWidget {
  const AddImage({Key? key}) : super(key: key);

  @override
  State<AddImage> createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {

  bool uploading =false;
  double val=0;

  late CollectionReference imgRef;
   late firebase_storage.Reference ref;

  List<File> _image  =[];
  final picker =ImagePicker();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Image'),
          automaticallyImplyLeading: true,
           centerTitle: true,
        actions: [
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    uploading =true;
                  });
                  uploadFile().whenComplete(() => Navigator.of(context).pop());
                },
                child: Text("Upload",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,

                  ),
                ),
              ),
          ),


        ],





    ),

      body: Stack(
        children:[

          GridView.builder(

            itemCount: _image.length+1,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3), itemBuilder: (context,index)
            {
              return index ==0 ? Center(child: IconButton(
                icon: Icon(Icons.add),
                onPressed: (){
                  !uploading?  chooseImage(): null;

                },
              ),
              ):Container(margin: EdgeInsets.all(3),
              decoration: BoxDecoration(image: DecorationImage(
                image: FileImage(_image[index-1]),
                fit:BoxFit.cover,
              )) ,

              );


            }),
          uploading?Center(child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Container(
                child: Text('Uploading',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              SizedBox(height: 20,),
              CircularProgressIndicator(value: val,valueColor:  AlwaysStoppedAnimation<Color>(Colors.green)),
            ],
          ),
          ):Container(),
      ],
      ),







    );

  }
  chooseImage() async
  {

    final pickedFile= await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image.add(File(pickedFile!.path));
      
    });
    if(pickedFile?.path==null) retrievelLostData();



  }
  Future<void> retrievelLostData()
  async {
    final LostData response = await picker.getLostData();
    if(response.isEmpty)
    {

      return;
    }
    if(response.file!=null)
    {
      
      setState(() {
        _image.add(File(response.file!.path));
      });
    }
    else
    {

      print(response.file);
    }


  }

  Future uploadFile() async
  {
    int i=1;

    for(var img in _image)
    {
      setState(() {
        val =i / _image.length;

      });
      
      ref=firebase_storage.FirebaseStorage.instance
          .ref()
          .child('images/${Path.basename(img.path)}');
           await ref.putFile(img).whenComplete(() async{

        await ref.getDownloadURL().then((value)
        {
          imgRef.add({'url':value});
          i++;



          
        });

      } );


    }



  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imgRef=FirebaseFirestore.instance.collection('imageURLs');
  }


}
