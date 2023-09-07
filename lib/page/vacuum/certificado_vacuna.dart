import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as Path;
import 'package:sepcon_salud/util/widget/pdf_container.dart';
import 'package:sepcon_salud/page/vacuum/carousel_vacuum.dart';
import 'package:sepcon_salud/resource/share_preferences/local_store.dart';
import 'package:sepcon_salud/util/constantes.dart';
import 'package:sepcon_salud/util/custom_permission.dart';
import 'package:sepcon_salud/util/general_color.dart';

class CertificadoVacuna extends StatefulWidget {
  final String urlPdf;
  const CertificadoVacuna({super.key,required this.urlPdf});

  @override
  State<CertificadoVacuna> createState() => _CertificadoVacunaState();
}

class _CertificadoVacunaState extends State<CertificadoVacuna> {
  final List<String> imgList = [
    'assets/vaccine/vacuna_1.png',
    'assets/document/document_frontal_4.png',
  ];
  final List<String> titleList = [
    '1. Posición correcta del documento',
    '2. Empezar a tomar la foto',
  ];

  late File file;

  bool isPermission = false;
  var checkAllPermissions = CheckPermission();
  bool dowloading = false;
  bool fileExists = false;
  double progress = 0;
  String fileName = "";
  late String filePath;
  late CancelToken cancelToken;
  var getPathFile = DirectoryPath();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkPermission();
    setState(() {
      fileName = Path.basename(widget.urlPdf);
      log("FILENAME : ${fileName}");
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.arrow_back_ios),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vista previa',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(height: 450,child:
              PdfContainer(
                urlPdf: widget.urlPdf,
                isLocal : false,
                titlePDF: "Certificados de vacunas",)),
              const Expanded(
                child: SizedBox(),
              ),

              GestureDetector(
                onTap: () {
                  //DateTime now = DateTime.now();
                  var fileName = "TV-${DateTime.now().millisecondsSinceEpoch}";
                  downloadFile(fileName);
                },
                child:Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Container(
                    padding: const EdgeInsets.only(top: 15, bottom: 15),
                    //margin: const EdgeInsets.symmetric(horizontal: 15),
                    //height: 50,
                    decoration: BoxDecoration(
                        color: GeneralColor.mainColor,
                        borderRadius: BorderRadius.circular(8)),
                    child: Center(
                        child:   dowloading
                            ? Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 3,
                              backgroundColor: Colors.white,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  GeneralColor.mainColor),
                            ),
                            Text(
                              "${(progress * 100).toStringAsFixed(2)}",
                              style: TextStyle(fontSize: 12,color: Colors.white),
                            )
                          ],
                        )
                            : Text(
                          'Descargar',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        )),
                  ),
                ),
              ),
              GestureDetector(
                onTap: (){
                  routePDFViewer();
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Container(
                    padding: const EdgeInsets.only(top: 15,bottom: 15),
                    //margin: const EdgeInsets.symmetric(horizontal: 15),
                    //height: 50,
                    decoration: BoxDecoration(
                        color: GeneralColor.mainColor,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Center(
                        child: Text(
                          'Actualizar documento',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  routePDFViewer() async {
    LocalStore localStore = LocalStore();
    bool result = await localStore.deleteKey(Constants.DOCUMENT_VACUUM);
    if(result){
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>CarouselVacuum(
                imgList: imgList,
                titleList: titleList,titlePage: "Certificado de vacunas",)));
    }
  }

  checkPermission() async {
    var permission = await checkAllPermissions.isStoragePermission();
    if (permission) {
      setState(() {
        isPermission = true;
      });
    }
  }

  downloadFile(String name){
    print(name.replaceAll(" ", ""));
    FileDownloader.downloadFile(
        url: widget.urlPdf,
        name: name,
        onProgress: (String? fileName, double progressInput) {
          setState(() {
            dowloading = true;
            progress = progressInput;
          });
        },
        onDownloadCompleted: (String path) {
          var splitMessage = path.split("/");
          var message = splitMessage[splitMessage.length-1];
          setState(() {
            dowloading = false;
            widgetDirectoryDialog(message);
          });
          print('FILE DOWNLOADED TO PATH: $path');
        },
        onDownloadError: (String error) {
          print('DOWNLOAD ERROR: $error');
        });

  }

  widgetDirectoryDialog(String message) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            height: 100,
            child: Column(
              children: [
                const Text(
                  "Verificar documento en la carpeta Descargados",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 10,),
                Text(
                  message,
                  style: TextStyle(
                      fontSize: 16,fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  openfile(String path) {
    OpenFile.open(path);
    print("fff $path");
  }

}
