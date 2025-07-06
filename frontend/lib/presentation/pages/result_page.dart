import 'package:flutter/material.dart';
import 'package:inno_test/domain/model/test.dart';
import 'package:inno_test/presentation/providers/test_provider.dart';
import 'package:inno_test/presentation/widgets/appbars/appbar_with_text.dart';
import 'package:provider/provider.dart';

import '../widgets/test_diagram.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final testProvider = Provider.of<TestProvider>(context);
    final results = testProvider.results;
    int successTests = 0;

    for (TestResult tr in results) {
      if (tr.result == true) {
        successTests++;
      }
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppbarWithText(text: "Back to Home page"),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 50),
        color: Theme.of(context).scaffoldBackgroundColor,
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Testing Results",
                style: TextStyle(
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w500,
                    fontSize: 30),
              ),
              SizedBox(
                height: 20,
              ),
              TestDiagram(
                overallTest: results.length,
                successTest: successTests,
              ),
              SizedBox(
                height: 70,
              ),
              Container(
                width: 540,
                alignment: Alignment.center,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: results.length,
                  itemBuilder: (_, index) {
                    final r = results[index];
                    final bool isSuccess = r.result == true;

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      height: 70,
                      decoration: BoxDecoration(
                        color:
                            isSuccess ? Color(0xFFB9E8BC) : Color(0xFFFFC4C4),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Text(
                              overflow: TextOverflow.ellipsis,
                              r.test,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            width: 100,
                            height: 40,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSuccess
                                  ? Color(0xFF4AD968)
                                  : Color(0xFFFF383C),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isSuccess ? "Complete" : "Failed",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
