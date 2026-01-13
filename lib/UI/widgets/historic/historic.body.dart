import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:senticket_front/UI/widgets/research.dart/research.listview.dart';
import 'package:senticket_front/bloc/historic.bloc.dart';
import 'package:senticket_front/constants.dart';
import 'package:intl/intl.dart';

class HistoricBody extends StatefulWidget {
  const HistoricBody({super.key});

  @override
  State<HistoricBody> createState() => _HistoricBodyState();
}

class _HistoricBodyState extends State<HistoricBody> {
  TextEditingController dateController1 = TextEditingController();
  TextEditingController dateController2 = TextEditingController();
  TextEditingController searchTransactionController = TextEditingController();
  String _selectedItem = 'Toutes les transactions';
  var items = [
    'Toutes les transactions',
    'Achat ticket',
    'Créditer compte',
    'Transfert ticket',
    'Transfert crédit',
    'Débiter compte',
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 10.0),
          child: DropdownButtonFormField<String>(
            value: _selectedItem,
            onChanged: (String? value) {
              setState(() {
                _selectedItem = value!;
                if (_selectedItem == true) {
                  print(_selectedItem);
                  String kw = _selectedItem;
                  context
                      .read<HistoricBloc>()
                      .add(SearchHistoricEvent(keyword: kw));
                }
              });
            },
            decoration: const InputDecoration(
              labelText: 'Selectionner une option',
              border: OutlineInputBorder(),
            ),
            items: items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(
                  children: [
                    Text(value),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 160,
                height: 50,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                    color: kSecondColor,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: greyBorderColor, width: 1)),
                child: TextField(
                    keyboardType: TextInputType.datetime,
                    controller: dateController1,
                    readOnly: true,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 8.0),
                        prefixIcon: Icon(
                          Icons.calendar_month,
                          color: dateColor,
                          size: 15,
                        ),
                        hintText: 'Choisir date de début',
                        hintStyle: TextStyle(
                          color: dateColor,
                          fontSize: 10,
                        )),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1997),
                          lastDate: DateTime(2050));

                      if (pickedDate != null) {
                        String formattedDate =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                        setState(() {
                          dateController1.text = formattedDate.toString();
                        });
                      } else {
                        print("Date is not selected");
                      }
                    }),
              ),
              Container(
                width: 160,
                height: 50,
                decoration: BoxDecoration(
                    color: kSecondColor,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: greyBorderColor, width: 1)),
                child: TextField(
                    keyboardType: TextInputType.datetime,
                    controller: dateController2,
                    readOnly: true,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 8.0),
                        prefixIcon: Icon(
                          Icons.calendar_month,
                          color: dateColor,
                          size: 15,
                        ),
                        hintText: 'Choisir date de fin',
                        hintStyle: TextStyle(
                          color: dateColor,
                          fontSize: 10,
                        )),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1997),
                          lastDate: DateTime(2050));

                      if (pickedDate != null) {
                        String formattedDate =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                        setState(() {
                          dateController2.text = formattedDate.toString();
                        });
                      } else {
                        print("Date is not selected");
                      }
                    }),
              ),
            ],
          ),
        ),

        //blocBuilder
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 4.0),
          child: BlocBuilder<HistoricBloc, HistoricState>(
            builder: (context, state) {
              if (state is SearchHistoricLoadingState) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is SearchHistoricErrorState) {
                return Column(children: [
                  Text(state.errorMessage,
                      style: const TextStyle(color: redErrorColor)),
                  ElevatedButton(onPressed: () {}, child: const Text('Retry'))
                ]);
              } else if (state is SearchHistoricSucessState &&
                      searchTransactionController.selection.isValid
                  //contains('services')
                  ) {
                return const Expanded(child: ResearchListView());
              } else {
                return Container();
              }
            },
          ),
        ),
      ],
    );
  }
}
