import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:senticket_front/UI/widgets/research.dart/research.listview.dart';
import 'package:senticket_front/bloc/services.bloc.dart';
import 'package:senticket_front/constants.dart';

class ServiceResearchBody extends StatefulWidget {
  const ServiceResearchBody({super.key});

  @override
  State<ServiceResearchBody> createState() => _ServiceResearchBodyState();
}

class _ServiceResearchBodyState extends State<ServiceResearchBody> {
  @override
  Widget build(BuildContext context) {
    TextEditingController textEditingController = TextEditingController();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                  child: TextFormField(
                controller: textEditingController,
                decoration: InputDecoration(
                    hintText: 'Rechercher',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          width: 2,
                        ))),
              )),
              IconButton(
                  onPressed: () {
                    String kw = textEditingController.text;
                    context
                        .read<ServicesBloc>()
                        .add(SearchServicesEvent(keyword: kw));
                    /*   print("*************");
                    print(textEditingController.text);
                    print("*************");
                    textEditingController.text = "";*/
                  },
                  icon: const Icon(
                    Icons.search,
                    color: kPrimaryColor,
                  )),
            ],
          ),
        ),
        //  const Expanded(child: ResearchListView()),
        BlocBuilder<ServicesBloc, ServicesState>(
          builder: (context, state) {
            if (state is SearchServicesLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SearchServicesErrorState) {
              return Column(children: [
                Text(state.errorMessage,
                    style: const TextStyle(color: redErrorColor)),
                ElevatedButton(onPressed: () {}, child: const Text('Retry'))
              ]);
            } else if (state is SearchServicesSucessState &&
                    textEditingController.text.isNotEmpty
                //contains('services')
                ) {
              return const Expanded(child: ResearchListView());
            } else {
              return Container();
            }
          },
        )
      ],
    );
  }
}
