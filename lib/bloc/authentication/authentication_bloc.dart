import 'package:bloc/bloc.dart';
import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/repository/auth_repository.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthRepository authRepository;

  AuthenticationBloc({this.authRepository}) : assert(authRepository != null);
  @override
  AuthenticationState get initialState => AuthenticationInitial();

  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationEvent event) async* {
    if (event is AuthenticationStarted) {
      yield* _mapAuthenticationStartedToState();
    } else if (event is AuthenticationLoggedIn) {
      yield* _mapAuthenticationLoggedInToState();
    } else if (event is AuthenticationLoggedOut) {
      yield* _mapAuthenticationLoggedOutToState();
    }
  }

  Stream<AuthenticationState> _mapAuthenticationStartedToState() async* {
    final signedIn = await this.authRepository.isSignedIn();
    if (signedIn) {
      User user = await this.authRepository.getLoggedUser();
      yield AuthenticationSuccess(user);
    } else {
      yield AuthenticationFailure();
    }
  }

  Stream<AuthenticationState> _mapAuthenticationLoggedInToState() async* {
    yield AuthenticationSuccess(await this.authRepository.getLoggedUser());
  }

  Stream<AuthenticationState> _mapAuthenticationLoggedOutToState() async* {
    yield AuthenticationFailure();
    this.authRepository.signOut();
  }
}
