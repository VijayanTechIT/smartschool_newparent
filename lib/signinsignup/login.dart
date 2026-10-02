import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_school_parent/internet_conn/internet_connection_bloc.dart';
import '../app_config.dart';
import '../no_internet_login.dart';
import '../signinsignup/loginpage.dart';


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(initialIndex: 0, length: 1, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InternetConnectionBloc, InternetConnectionState>(
      builder: (context, state) {

        if(state is InternetConnected){

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: const Color(0xFF2d4c9c),

          appBar: AppBar(
            backgroundColor: const Color(0xFF2d4c9c),
            title: Text(
              AppConfig.appName, style: TextStyle(fontSize:20,color: Colors.white),),
            centerTitle: true,
            leading: SizedBox.shrink(),
          ),
          body: Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(40), topLeft: Radius.circular(40))
            ),

            child: Column(
              children: [
                SizedBox(
                  height: 65,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF2d4c9c),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                    unselectedLabelColor: const Color(0xFFe71f2a),
                    tabs: const [
                      // Container(child: const Tab(text: 'ADMIN')),
                      // Container(child: const Tab(text: 'STAFF')),
                      Tab(text: 'PARENT'),

                    ],
                  ),),
                Expanded(
                  flex: 1,
                  child: TabBarView(
                    controller: _tabController,
                    children: const [

                      ParentLogin(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );}else{
          return NoInternetLoginScreen(shouldPopOnReconnect: false);
        }
      },
    );
  }
}
