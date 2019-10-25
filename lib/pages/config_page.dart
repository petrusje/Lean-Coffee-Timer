import 'dart:wasm';

import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:lean_coffee_timer/widgets/myform_builder_slider.dart';

class ConfigPage extends StatefulWidget {
  @override
  ConfigPageState createState() {
    return ConfigPageState();
  }
}

class ConfigPageState extends State<ConfigPage> {
  String name = GlobalConfiguration().getString("name") ?? "";
  double points = GlobalConfiguration().getDouble("points") ?? 1.0;

  final GlobalKey<FormBuilderState> _cfgKey = GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            FormBuilder(
              key: _cfgKey,
              initialValue: {
                'owner': name,
                'points': points,
              },
              autovalidate: true,
              child: Column(
                children: <Widget>[
                  FormBuilderTextField(
                    attribute: "owner",
                    decoration: InputDecoration(labelText: "Nome"),
                    validators: [
                      FormBuilderValidators.max(25),
                    ],
                  ),
                  FormBuilderSliderExt(
                    showValueLabels: false,
                    attribute: "points",
                    validators: [FormBuilderValidators.min(1)],
                    min: 1.0,
                    max: 10.0,
                    divisions: 10,
                    label: "Pontos",
                    decoration: InputDecoration(
                      labelText: "Número de Pontos",
                    ), 
                    initialValue: points,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.all(
                        20.0), //EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
                    child: Material(
                        //Wrap with Material
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22.0)),
                        elevation: 18.0,
                        color: Colors.white70,
                        clipBehavior: Clip.antiAlias, // Add This
                        child: MaterialButton(
                          child: Text("Salvar"),
                          onPressed: () {
                            if (_cfgKey.currentState.saveAndValidate()) {
                              print(_cfgKey.currentState.value);
                              GlobalConfiguration().updateValue(
                                  "name", _cfgKey.currentState.value["owner"]);
                              GlobalConfiguration().updateValue("points",
                                  _cfgKey.currentState.value["points"]);
                            }
                          },
                        ))),
                Padding(
                    padding: EdgeInsets.all(
                        20.0), //EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
                    child: Material(
                      //Wrap with Material
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22.0)),
                      elevation: 18.0,
                      color: Colors.white70,
                      clipBehavior: Clip.antiAlias, // Add This
                      child: MaterialButton(
                        child: Text("Resetar"),
                        onPressed: () {
                          _cfgKey.currentState.reset();
                        },
                      ),
                    ))
              ],
            )
          ],
        ));
  }
}
