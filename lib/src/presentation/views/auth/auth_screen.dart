import 'package:flutter/material.dart';
import 'package:flutter_amazon_clone_bloc/src/config/router/app_route_constants.dart';
import 'package:flutter_amazon_clone_bloc/src/logic/blocs/auth_bloc/auth_bloc.dart';
import 'package:flutter_amazon_clone_bloc/src/logic/blocs/user_cubit/user_cubit.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/widgets/common_widgets/custom_elevated_button.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/widgets/common_widgets/custom_textfield.dart';
import 'package:flutter_amazon_clone_bloc/src/utils/constants/constants.dart';
import 'package:flutter_amazon_clone_bloc/src/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

enum Auth { signIn, signUp }

class AuthScreen extends StatefulWidget {
  static const String routeName = 'auth-screen';

  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  Auth _auth = Auth.signUp;
  final _signUpFormKey = GlobalKey<FormState>();
  final _signInFormKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.greyBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/images/amazon_in.png',
                  height: 40,
                  width: 50,
                ),
                const SizedBox.square(
                  dimension: 12,
                ),
                const Text(
                  'Welcome',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
                ),
                const SizedBox.square(
                  dimension: 12,
                ),

                // Sign Up Section
                Container(
                  padding: const EdgeInsets.only(bottom: 10, right: 8, left: 8),
                  decoration: BoxDecoration(
                    color: _auth == Auth.signUp
                        ? Constants.backgroundColor
                        : Constants.greyBackgroundColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        minLeadingWidth: 2,
                        leading: SizedBox.square(
                          dimension: 12,
                          child: Radio(
                              value: Auth.signUp,
                              groupValue: _auth,
                              onChanged: (Auth? val) {
                                setState(() {
                                  _auth = val!;
                                });
                              }),
                        ),
                        title: RichText(
                          text: const TextSpan(children: [
                            TextSpan(
                              text: 'Create account. ',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                  color: Colors.black),
                            ),
                            TextSpan(
                              text: 'New to Amazon?',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black87),
                            )
                          ]),
                        ),
                        onTap: () {
                          setState(() {
                            _auth = Auth.signUp;
                          });
                        },
                      ),
                      if (_auth == Auth.signUp)
                        Form(
                          key: _signUpFormKey,
                          child: Column(
                            children: [
                              CustomTextfield(
                                controller: _nameController,
                                hintText: 'First and last name',
                                onChanged: (value) {
                                  context.read<AuthBloc>().add(
                                      TextFieldChangedEvent(
                                          _nameController.text,
                                          _emailController.text,
                                          _passwordController.text));
                                },
                              ),
                              CustomTextfield(
                                controller: _emailController,
                                hintText: 'Email',
                                onChanged: (value) {
                                  context.read<AuthBloc>().add(
                                      TextFieldChangedEvent(
                                          _nameController.text,
                                          _emailController.text,
                                          _passwordController.text));
                                },
                              ),
                              CustomTextfield(
                                controller: _passwordController,
                                hintText: 'Set password',
                                onChanged: (value) {
                                  context.read<AuthBloc>().add(
                                      TextFieldChangedEvent(
                                          _nameController.text,
                                          _emailController.text,
                                          _passwordController.text));
                                },
                              ),
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  if (state is TextFieldErrorState) {
                                    return Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/info_icon.png',
                                          height: 15,
                                          width: 15,
                                        ),
                                        Text('  ${state.errorString}')
                                      ],
                                    );
                                  } else {
                                    if (_nameController.text == '' ||
                                        _emailController.text == '' ||
                                        _passwordController.text == '') {
                                      return Row(
                                        children: [
                                          Image.asset(
                                            'assets/images/info_icon.png',
                                            height: 15,
                                            width: 15,
                                          ),
                                          const Text(
                                              '  All fields are required.'),
                                        ],
                                      );
                                    }
                                    return const SizedBox();
                                  }
                                },
                              ),
                              const SizedBox.square(
                                dimension: 15,
                              ),
                              BlocConsumer<AuthBloc, AuthState>(
                                listener: (context, state) {
                                  if (state is AuthErrorState) {
                                    debugPrint(state.errorString);
                                    showSnackBar(context, state.errorString);
                                  }
                                  if (state is CreateUserSuccessState) {
                                    showSnackBar(
                                        context, state.userCreatedString);
                                  }
                                  if (state is CreateUserErrorState) {
                                    showSnackBar(context, state.errorString);
                                  }
                                },
                                builder: (context, state) {
                                  if (state is AuthLoadingState) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else {
                                    return CustomElevatedButton(
                                      buttonText: 'Create account',
                                      onPressed: () {
                                        if (_signUpFormKey.currentState!
                                            .validate()) {
                                          // signUpUser();
                                          BlocProvider.of<AuthBloc>(context)
                                              .add(CreateAccountPressedEvent(
                                                  _nameController.text,
                                                  _emailController.text,
                                                  _passwordController.text));
                                        }
                                      },
                                    );
                                  }
                                },
                              )
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Sign In Section
                Container(
                  padding: const EdgeInsets.only(bottom: 10, right: 8, left: 8),
                  decoration: BoxDecoration(
                      color: _auth == Auth.signIn
                          ? Constants.backgroundColor
                          : Constants.greyBackgroundColor,
                      borderRadius: BorderRadius.circular(6)),
                  child: Column(
                    children: [
                      ListTile(
                        minLeadingWidth: 2,
                        leading: SizedBox.square(
                          dimension: 12,
                          child: Radio(
                              value: Auth.signIn,
                              groupValue: _auth,
                              onChanged: (Auth? val) {
                                setState(() {
                                  _auth = val!;
                                });
                              }),
                        ),
                        title: RichText(
                          text: const TextSpan(children: [
                            TextSpan(
                              text: 'Sign in. ',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 17,
                                  color: Colors.black),
                            ),
                            TextSpan(
                              text: 'Already a customer?',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black87),
                            ),
                          ]),
                        ),
                        onTap: () {
                          setState(() {
                            _auth = Auth.signIn;
                          });
                        },
                      ),
                      if (_auth == Auth.signIn)
                        Form(
                          key: _signInFormKey,
                          child: Column(
                            children: [
                              CustomTextfield(
                                  controller: _emailController,
                                  hintText: 'Email'),
                              CustomTextfield(
                                  controller: _passwordController,
                                  hintText: 'Password'),
                              const SizedBox.square(
                                dimension: 6,
                              ),
                              BlocConsumer<AuthBloc, AuthState>(
                                listener: (context, state) {
                                  if (state is AuthErrorState) {
                                    showSnackBar(context, state.errorString);
                                  }
                                  if (state is SignInSuccessState) {
                                    context.goNamed(
                                        AppRouteConstants.bottomBarRoute.name);
                                  }
                                  if (state is UpdateUserData) {
                                    debugPrint('ran through update user');
                                    BlocProvider.of<UserCubit>(context)
                                        .setUser(state.user);
                                  }
                                },
                                builder: (context, state) {
                                  if (state is AuthLoadingState) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else {
                                    return CustomElevatedButton(
                                      buttonText: 'Continue',
                                      onPressed: () {
                                        if (_signInFormKey.currentState!
                                            .validate()) {
                                          BlocProvider.of<AuthBloc>(context)
                                              .add(SignInPressedEvent(
                                                  _emailController.text,
                                                  _passwordController.text));
                                        }
                                      },
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox.square(
                  dimension: 20,
                ),
                Divider(
                  color: Colors.grey.shade300,
                  indent: 20,
                  endIndent: 20,
                  thickness: 0.5,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      customTextButton(buttonText: 'Conditions of Use'),
                      customTextButton(buttonText: 'Privacy Notice'),
                      customTextButton(buttonText: 'Help'),
                    ]),
                const Center(
                  child: Text(
                    '© 1996-2023, Amazon.com, Inc. or its affiliates',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox.square(
                  dimension: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextButton customTextButton({String? buttonText}) {
    return TextButton(
      onPressed: () {},
      child: Text(
        buttonText!,
        style: const TextStyle(color: Color(0xff1F72C5), fontSize: 15),
      ),
    );
  }
}
