import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ServicesEvent {}

class SearchServicesEvent extends ServicesEvent {
  final String keyword;
  SearchServicesEvent({
    required this.keyword,
  });
}

abstract class ServicesState {}

class SearchServicesSucessState extends ServicesState {
  final List<dynamic> services;

  SearchServicesSucessState({required this.services});
}

class SearchServicesLoadingState extends ServicesState {}

class SearchServicesErrorState extends ServicesState {
  final String errorMessage;
  SearchServicesErrorState({required this.errorMessage});
}

class ServicesInitialState extends ServicesState {}

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  ServicesBloc() : super(ServicesInitialState()) {
    on((SearchServicesEvent event, emit) {
      emit(SearchServicesLoadingState());
      try {
        emit(SearchServicesSucessState(services: []));
      } catch (e) {
        emit(SearchServicesErrorState(errorMessage: e.toString()));
      }
    });
  }
}
