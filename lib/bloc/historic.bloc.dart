import 'package:bloc/bloc.dart';

abstract class HistoricEvent {}

class SearchHistoricEvent extends HistoricEvent {
  final String keyword;
  SearchHistoricEvent({
    required this.keyword,
  });
}

abstract class HistoricState {}

class SearchHistoricSucessState extends HistoricState {
  final List<dynamic> historic;

  SearchHistoricSucessState({required this.historic});
}

class SearchHistoricLoadingState extends HistoricState {}

class SearchHistoricErrorState extends HistoricState {
  final String errorMessage;
  SearchHistoricErrorState({required this.errorMessage});
}

class HistoricInitialState extends HistoricState {}

class HistoricBloc extends Bloc<HistoricEvent, HistoricState> {
  HistoricBloc() : super(HistoricInitialState()) {
    on((SearchHistoricEvent event, emit) {
      emit(SearchHistoricLoadingState());
      try {
        emit(SearchHistoricSucessState(historic: []));
      } catch (e) {
        emit(SearchHistoricErrorState(errorMessage: e.toString()));
      }
      /* just for testing bloc
       print("*****Bloc event processing");
      print(event);
      print(event.keyword);
      print("xxxxxxxxxxxxxxxxxxxxx");*/
    });
  }
}
