import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';

import '../user_repository.dart';
import 'authentication_event.dart';
import 'bloc.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  //final UserRepository _userRepository;

  /*AuthenticationBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;
*/
  var _firebaseAuth = FirebaseAuth.instance;

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/contacts.readonly'],
  );

  @override
  AuthenticationState get initialState => Uninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationEvent event,) async* {
    if (event is AppStarted) {
      yield* _mapLoggedInToState();
      //yield* _mapAppStartedToState();
    } else if (event is GoogleLogin) {
      yield* _mapGoogleLoginToState();
  } if (event is LoggedIn) {
      yield* _mapLoggedInToState();
    } else if (event is LoggedOut) {
      yield* _mapLoggedOutToState();
    }
  }

  Stream<AuthenticationState> _mapAppStartedToState() async* {
    yield AuthenticatingState();
/*
    try {
      if(_firebaseAuth.currentUser() != null){
        yield Authenticated();
      }else {
        yield Unauthenticated();
      }
      /*final isSignedIn = await _userRepository.isSignedIn();
      if (isSignedIn) {
        //final name = await _userRepository.getUser();
        yield Authenticated(name);
      } else {
        yield Unauthenticated();
      }
    } catch (_) {
      yield Unauthenticated();

       */
    }catch(error){
      yield Unauthenticated();
      print("error _mapAppStartedToState :${error.toString()}");
    }

 */
  }

  Stream<AuthenticationState> _mapGoogleLoginToState() async* {
    yield AuthenticatingState();

    try {
      FirebaseUser user = await _googleSignIn.signIn().then((value) async {
        if (value != null) {
          final GoogleSignInAuthentication googleAuth =
          await value.authentication;
          var firebase = await _firebaseAuth
              .signInWithCredential(GoogleAuthProvider.getCredential(
              idToken: googleAuth.idToken,
              accessToken: googleAuth.accessToken))
              .then((onvalue) {
            var users = onvalue.user;
            return users;
          }).catchError((error) {
            print("A1 : ${error.toString()}");
            return null;
          });
          return firebase;
        } else {
          print("A2");
          return null;
        }
      }).catchError((error) {
        print("A3 : ${error.toString()}");
        return null;
      });
      if (user != null) {
        yield Authenticated(user);
      } else {
        yield Unauthenticated();
      }
    } catch (error) {
      print("A4 : ${error.toString()}");
      yield Unauthenticated();
    }
  }

  Stream<AuthenticationState> _mapLoggedInToState() async* {
    yield AuthenticatingState();

    try {
      FirebaseUser firebaseUser = await _firebaseAuth.currentUser().then((_user){
        return _user;
      }).catchError((error){
        print("A5 : ${error.toString()}");
      });

      if(firebaseUser != null){
        yield Authenticated(firebaseUser);
      }else {
        yield Unauthenticated();
      }

    }catch(error){
      yield Unauthenticated();
      print("error _mapAppStartedToState :${error.toString()}");
    }
  }

  Stream<AuthenticationState> _mapLoggedOutToState() async* {

    yield Unauthenticated();
  }
}
