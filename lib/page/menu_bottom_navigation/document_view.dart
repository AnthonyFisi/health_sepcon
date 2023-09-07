import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sepcon_salud/page/covid/home_covid_page.dart';
import 'package:sepcon_salud/page/covid/init_covid_page.dart';
import 'package:sepcon_salud/page/document_identidad/document_home_page.dart';
import 'package:sepcon_salud/page/pase_medico/init_pase_medico_page.dart';
import 'package:sepcon_salud/page/vacuum/home_vacuum.dart';
import 'package:sepcon_salud/page/vacuum/init_vacuum.dart';
import 'package:sepcon_salud/resource/model/document_vacuna_model.dart';
import 'package:sepcon_salud/resource/model/login_response.dart';
import 'package:sepcon_salud/resource/model/vacuna_costos_model.dart';
import 'package:sepcon_salud/resource/model/vacuna_model.dart';
import 'package:sepcon_salud/resource/share_preferences/local_store.dart';
import 'package:sepcon_salud/util/animation/circular_animation.dart';
import 'package:sepcon_salud/util/animation/progress_bar.dart';
import 'package:sepcon_salud/util/general_color.dart';
import 'package:sepcon_salud/util/general_words.dart';
import 'package:sepcon_salud/util/route.dart';

class DocumentView extends StatefulWidget {
  const DocumentView({super.key});

  @override
  State<DocumentView> createState() => _DocumentViewState();
}

class _DocumentViewState extends State<DocumentView>  with SingleTickerProviderStateMixin{
  
  late AnimationController progressController;
  late Animation animation;
  late LocalStore localStore;
  late DocumentVacunaModel? documentVacuumModel;
  late VacunaCostosModel? vacuumCostosModel;
  late LoginResponse? loginResponse;
  late String path, urlCovid;
  late bool showHome;
  late double porcentaje;
  late int documentosCompletos , totalDocumentos;
  var stateDcumentMap, stateFlowMap;

  bool STATE_DOCUMENTO_IDENTIDAD = false;
  bool STATE_VACUNA = false;
  bool STATE_EMO = false;
  bool STATE_PASE_MEDICO = false;
  bool STATE_COVID19 = false;

  String KEY_DOCUMENTO_IDENTIDAD = "DOCUMENTO_IDENTIDAD";
  String KEY_VACUNA = "VACUNA";
  String KEY_EMO = "EMO";
  String KEY_PASE_MEDICO = "PASE_MEDICO";
  String KEY_COVID19 = "COVID19";

  bool FLOW_DOCUMENTO_IDENTIDAD = false;
  bool FLOW_VACUNA = false;
  bool FLOW_EMO = false;
  bool FLOW_PASE_MEDICO = false;
  bool FLOW_COVID19 = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initVariable();
    findUserAndDocumentAndCostosLocalStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
            child: !showHome ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [getLoadEffect()],
              ),
            ) : Padding(
              padding: const EdgeInsets.only(left: 25, right: 25),
              child: Column(
                children: [
                  // HEADER
                  const SizedBox(
                    height: 50,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        GeneralWord.welcomeMessageHome,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Icon(
                        Icons.notifications_none,
                        color: Colors.black,
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loginResponse!.nombres!.split(" ")[0],
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  // INDICATOR
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: GeneralColor.mainColor,
                    ),
                    height: 120,
                    child: Padding(
                      padding:const EdgeInsets.only(left: 15,right: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 150,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(GeneralWord.titleIndicatorHome
                                  ,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16),),
                                SizedBox(height: 10,),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.book,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                    Text('${documentosCompletos.toString()} / ${totalDocumentos.toString()}',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w300),),
                                  ],
                                )
                              ],
                            ),
                          ),
                          CustomPaint(
                            foregroundPainter: CircleProgress(animation.value.toDouble()),
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: Center(child: Text(
                                "${animation.value.toInt()}%",style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // DOCUMENTS
                  const SizedBox(
                    height: 20,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        GeneralWord.titleDocumentHome,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20,),

                  Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: GeneralColor.grayBoldColor,
                      ),
                      child: ListTile(
                        onTap: (){
                          FLOW_DOCUMENTO_IDENTIDAD ?
                          routeDocumentoIdentidadHomePage()
                          :routeDocumentoIdentidadInitPage();
                        },
                        leading: STATE_DOCUMENTO_IDENTIDAD ?
                        const Icon(Icons.check_circle,color: GeneralColor.greenColor,)
                            : const Icon(Icons.warning_amber,color: Colors.amber,),
                        title: const  Text(GeneralWord.identityDocumentHome),
                        trailing: const Icon(Icons.arrow_forward_ios,color: Colors.black54,),
                      )
                  ),

                  const SizedBox(height: 10,),

                  Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: GeneralColor.grayBoldColor,
                      ),
                      child: ListTile(
                          onTap: (){
                            FLOW_VACUNA ?
                            routeHomeVacuumPage()
                            :routeVacuumInitPage();
                          },
                        leading: STATE_VACUNA ?
                        const Icon(Icons.check_circle,color: GeneralColor.greenColor,)
                            : const Icon(Icons.warning_amber,color: Colors.amber,),
                        title: const   Text(GeneralWord.vacuumHome),
                        trailing: const Icon(Icons.arrow_forward_ios,color: Colors.black54,),
                      )
                  ),

                  const SizedBox(height: 10,),

                  Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: GeneralColor.grayBoldColor,
                      ),
                      child: ListTile(
                          onTap: (){
                            routeHomePaseMedicoPage();
                          },
                          leading: STATE_PASE_MEDICO ?
                          const Icon(Icons.check_circle,color: GeneralColor.greenColor,)
                              : const Icon(Icons.warning_amber,color: Colors.amber,),
                          title: const  Text(GeneralWord.passMedicHome),
                        trailing: const Icon(Icons.arrow_forward_ios,color: Colors.black54,),
                      )
                  ),

                  const SizedBox(height: 10,),

                  Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: GeneralColor.grayBoldColor,
                      ),
                      child: ListTile(
                          onTap: (){
                            print(GeneralWord.controlMedicHome);
                          },
                        leading: STATE_EMO ?
                        const Icon(Icons.check_circle,color: GeneralColor.greenColor,)
                            : const Icon(Icons.warning_amber,color: Colors.amber,),
                        title: const Text(GeneralWord.controlMedicHome),
                        trailing: const Icon(Icons.arrow_forward_ios,color: Colors.black54,),

                      )
                  ),

                  const SizedBox(height: 10,),

                  Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: GeneralColor.grayBoldColor,
                      ),
                      child: ListTile(
                        onTap: (){
                          FLOW_COVID19 ? routeHomeCovidPage()
                              : routeInitCovidPage();
                        },
                        leading:  STATE_COVID19 ?
                        const Icon(Icons.check_circle,color: GeneralColor.greenColor,)
                            : const Icon(Icons.warning_amber,color: Colors.amber,),
                        title: const Text(GeneralWord.covidHome),
                        trailing: const Icon(Icons.arrow_forward_ios,color: Colors.black54,),
                      )
                  ),

                ],
              ),
            ),
          )),
    );
  }

  initVariable(){
    localStore = LocalStore();
    showHome = false;
    porcentaje = 0.0;
    documentosCompletos = 0;
    totalDocumentos = 0;
    stateDcumentMap = <String,bool?>{};
    stateFlowMap = <String,bool?>{};
    urlCovid = "";
  }

  findUserAndDocumentAndCostosLocalStorage() async {
    documentVacuumModel = await localStore.fetchVacunaGeneral();
    loginResponse = await localStore.fetchUser();
    vacuumCostosModel = await localStore.fetchVacunaCostos();

    if(documentVacuumModel != null && loginResponse != null
        && vacuumCostosModel != null){
      animatePorcentaje(validatePorcentaje());
      setState(() {
        showHome = true;
        validateStateDocument();
        validateFlowDocument();
      });
    }
  }

 double validatePorcentaje(){
    var porcentajeMap = <String,bool?>{};

    porcentajeMap[KEY_DOCUMENTO_IDENTIDAD] =
        documentVacuumModel!.documentoIdentidadModel.validated!;
    porcentajeMap[KEY_EMO] = false;
    porcentajeMap[KEY_PASE_MEDICO] =
        documentVacuumModel!.paseMedicoModel!.validated;

    for(VacunaModel vacunaModel in documentVacuumModel!.vacunaGeneralModel!.tiposVacunas!){
      for(String vacuna in vacuumCostosModel!.vacunas){
        if(vacuna == vacunaModel.nombre){
            porcentajeMap[vacunaModel.nombre!] = vacunaModel.validated;
        }
      }

      if(vacunaModel.nombre == "Covid19"){
        porcentajeMap[KEY_COVID19] =
        vacunaModel.validated!;
      }
    }
    
    porcentajeMap.forEach((key, value) {
      if(value!){
        documentosCompletos++;
      }
      totalDocumentos++;
    });

    porcentaje = (documentosCompletos.toDouble() / totalDocumentos.toDouble())*100.0;
    
    return porcentaje;
  }

  animatePorcentaje(double porcentaje){
    progressController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    animation = Tween(begin: 0.0, end: porcentaje).animate(progressController)
      ..addListener(() {
        setState(() {});
      });
    progressController.forward();
  }

  validateStateDocument(){

    int tempTotal = vacuumCostosModel!.vacunas.length;
    int tempComplete = 0;
    double tempPorcentaje = 0;

    STATE_DOCUMENTO_IDENTIDAD =
    documentVacuumModel!.documentoIdentidadModel.validated!;

    STATE_EMO = false;
    STATE_PASE_MEDICO =
        documentVacuumModel!.paseMedicoModel!.validated!;

    for(VacunaModel vacunaModel in documentVacuumModel!.vacunaGeneralModel!.tiposVacunas!){
      for(String vacuna in vacuumCostosModel!.vacunas){
        if(vacuna == vacunaModel.nombre){
          if(vacunaModel.validated!){
            tempComplete++;
          }
        }
      }

      if(vacunaModel.nombre == "Covid19"){
        STATE_COVID19 =
            vacunaModel.validated!;
      }
    }

    tempPorcentaje = (tempComplete.toDouble() / tempTotal.toDouble()) * 100.0;

    if(tempPorcentaje == 100.0){
      STATE_VACUNA = true;
    }
  }

  validateFlowDocument(){
    FLOW_DOCUMENTO_IDENTIDAD =
    documentVacuumModel!.documentoIdentidadModel.adjunto!.isNotEmpty
        ? true : false;

    STATE_EMO = false;

    FLOW_PASE_MEDICO =
    documentVacuumModel!.paseMedicoModel!.adjunto!.isNotEmpty
        ? true : false;

    FLOW_VACUNA =
    documentVacuumModel!.vacunaGeneralModel!.tiposVacunas![0].adjunto!.isNotEmpty
        ? true : false;

    for(VacunaModel vacunaModel in documentVacuumModel!.vacunaGeneralModel!.tiposVacunas!){

      if(vacunaModel.nombre == "Covid19"){
        urlCovid = vacunaModel.adjunto!;
        FLOW_COVID19 =
        vacunaModel.adjunto!.isNotEmpty ? true : false;
      }
    }
  }

  routeDocumentoIdentidadInitPage(){
    Navigator.push(
        context, RouteGenerator.generateRoute(
        const RouteSettings(name: '/documentoIdentidadInit')));
  }

  routeDocumentoIdentidadHomePage(){
    Navigator.push(
        context, MaterialPageRoute(
        builder: (context) => DocumentHomePage(
            urlPdf: documentVacuumModel!.documentoIdentidadModel.adjunto!)));
  }

  routeVacuumInitPage(){
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const InitVacuum()));
  }

  routeVacuumHomePage(){
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const HomeVacuum()));
  }

  routeHomeVacuumPage(){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomeVacuum()));
  }

  routeHomePaseMedicoPage(){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const InitPaseMedicoPage()));
  }

  routeInitCovidPage(){
    Navigator.push(
        context, MaterialPageRoute(
        builder: (context) => const InitCovidHome()));
  }

  routeHomeCovidPage(){
    Navigator.push(
        context, MaterialPageRoute(
        builder: (context) =>  CovidHomePage(urlPdf: urlCovid,)));
  }
}