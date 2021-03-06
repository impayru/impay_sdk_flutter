import 'dart:convert';
//import 'package:card_scanner/card_scanner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:extended_masked_text/extended_masked_text.dart';

import 'cryptor.dart';
import 'rest.dart';

class ImPayForm extends StatefulWidget {

  final int _partnerId;
  final Function(String, String) _onCreatePay;
  final double _sumPay;
  final Color colorBgTop;
  final Color colorBgButtom;
  final Color colorButton;
  final Color colorButtonDisabled;
  final Color colorText;
  final Color colorTextLight;
  final Color colorInputBorder;
  final Color colorInputBorderActive;
  final bool isRegCard;
  ImPayForm(this._partnerId, this._sumPay, this._onCreatePay, {
    this.colorBgTop = const Color(0xFF009DF5),
    this.colorBgButtom = const Color(0xFF027FC6),
    this.colorButton = const Color(0xFF00A3FF),
    this.colorButtonDisabled = const Color(0xFF61C6FF),
    this.colorText = const Color(0xFF2E2E2E),
    this.colorTextLight = const Color(0xFFD2EFFF),
    this.colorInputBorder = const Color(0xFFF4F3F8),
    this.colorInputBorderActive = const Color(0xFFC4D0E9),
    this.isRegCard = false
  });

  @override
  _ImPayFormState createState() => _ImPayFormState();
}

class _ImPayFormState extends State<ImPayForm> {

  var _card = MaskedTextController(mask: '0000 0000 0000 000000', cursorBehavior: CursorBehaviour.end);
  var _srok = MaskedTextController(mask: '00/00', cursorBehavior: CursorBehaviour.end);
  var _cvv = MaskedTextController(mask: '000', cursorBehavior: CursorBehaviour.end);
  var _email = TextEditingController();

  var _focusCard = new FocusNode();
  var _focusSrok = new FocusNode();
  var _focusCvv = new FocusNode();
  var _focusEmail = new FocusNode();

  bool _cardValidate = true;
  bool _srokValidate = true;
  bool _cvvValidate = true;
  bool _emailValidate = true;

  bool _isButtonDisabled = true;
  bool _loading = false;
  String? _token;
  int _tokenId = 0;
  String _sumInfo = '';
  double comisPc = 0.00;
  double comisMin = 0.00;

  @override
  void initState() {
    super.initState();
    _card.addListener(onInputTexts);
    _srok.addListener(onInputTexts);
    _cvv.addListener(onInputTexts);
    _email.addListener(onInputTexts);
    _focusCard.addListener(onChangefocus);
    _focusSrok.addListener(onChangefocus);
    _focusCvv.addListener(onChangefocus);
    _focusEmail.addListener(onChangefocus);
    createToken();
  }

  @override
  void dispose() {
    _card.dispose();
    _srok.dispose();
    _cvv.dispose();
    _email.dispose();
    _focusCard.dispose();
    _focusSrok.dispose();
    _focusCvv.dispose();
    _focusEmail.dispose();
    super.dispose();
  }

  void onInputTexts() async {
    var card = _card.text;
    var srok = _srok.text;
    var cvv = _cvv.text;
    if (card.length < 19 || srok.length < 5 || cvv.length < 3) {
      _isButtonDisabled = true;
    } else if (_isButtonDisabled == true) {
      _isButtonDisabled = false;
    }
    setState(() {});
  }

  calcSumInfo() async {
    double summ = widget._sumPay;
    double comis = summ * comisPc / 100.0;
    if (comis < comisMin) {
      comis = comisMin;
    }
    setState(() {
      _sumInfo = widget._sumPay > 0 ? " " + (summ + comis).toStringAsFixed(2) + " ??????" : "";
    });
  }

  void onChangefocus() async {
    var card = _card.text;
    var srok = _srok.text;
    var cvv = _cvv.text;
    var email = _email.text;
    if (!_focusCard.hasFocus && card.isNotEmpty && card.length < 19) {
      _cardValidate = false;
    } else {
      _cardValidate = true;
    }
    if (!_focusSrok.hasFocus && srok.isNotEmpty && srok.length < 5) {
      _srokValidate = false;
    } else {
      _srokValidate = true;
    }
    if (!_focusCvv.hasFocus && cvv.isNotEmpty && cvv.length < 3) {
      _cvvValidate = false;
    } else {
      _cvvValidate = true;
    }
    if (!_focusEmail.hasFocus && email.isNotEmpty && !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
      _emailValidate = false;
    } else {
      _emailValidate = true;
    }
    setState(() {});
  }

  createToken() async {
    setState(() {
      _loading = true;
    });
    var res = await Rest.getToken(widget._partnerId);
    if (res != null) {
      var r = json.decode(res['token']);
      var k = String.fromCharCodes(base64.decode(r['key']));
      setState(() {
        _token = k;
        _tokenId = r['id'];
        comisPc = res['comispc'].toDouble();
        comisMin = res['comismin'].toDouble();
        //print(_token);
      });
      calcSumInfo();
    }
    setState(() {
      _loading = false;
    });
  }

  _payCard() async {

    if (_token != null && _token!.isNotEmpty) {
      var card = _getOnlyNumbers(_card.text);
      var srok = _getOnlyNumbers(_srok.text);
      var cvv = _getOnlyNumbers(_cvv.text);
      var email = _getOnlyNumbers(_email.text);

      var paytoken = await Cryptor.tokenize(card, srok, cvv, _token!);

      if (widget._onCreatePay != null) {
        widget._onCreatePay(base64.encode(
            utf8.encode(json.encode({"id": _tokenId, "paytoken": paytoken}))),
            email);
      }
    }
    Navigator.pop(context, 1);
  }

  /*_scanCard() async {
    var cardDetails = await CardScanner.scanCard();
    if (cardDetails != null && cardDetails.cardNumber.isNotEmpty) {
      setState(() {
        _card.text = cardDetails.cardNumber;
        _srok.text = cardDetails.expiryDate;
      });
    }
  }*/

  String _getOnlyNumbers(String text) {
    String cleanedText = text;
    var onlyNumbersRegex = new RegExp(r'[^\d]');
    cleanedText = cleanedText.replaceAll(onlyNumbersRegex, '');
    return cleanedText;
  }

  inputDecoration(String hint, String errorText, bool isValidate) {
    return InputDecoration(
        counterText: "",
        contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
        errorText: !isValidate ? errorText : null,
        errorStyle: TextStyle(fontSize: 10.0),
        border: OutlineInputBorder(
          borderSide: BorderSide(
              width: 1.0,
              color: widget.colorInputBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              width: 1.0,
              color: widget.colorInputBorder
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              width: 1.0,
              color: widget.colorInputBorderActive
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
              width: 1.0,
              color: Color(0xFFFF4949)
          ),
        ),
        filled: true,
        fillColor: Color(0xFFF4F3F8),
        hintText: hint,
        hintStyle: TextStyle(color: Color(0xFF8E9198)),
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(body:ListView(children: <Widget>[Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    widget.colorBgButtom,
                    widget.colorBgTop,
                  ]
              )
          ),
          child: Column(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 20.0, bottom: 10.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Image.asset('imgs/logo_white.png', scale: 4.0, package: 'impay_sdk'),
                          TextButton(
                            child: Image.asset('imgs/close.png', scale: 4.0, package: 'impay_sdk'),
                            style: TextButton.styleFrom(
                              minimumSize: Size(40, 40),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(90.0)),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            }
                          )
                        ]
                    )
                ),
                widget.isRegCard ? Padding(
                  padding: EdgeInsets.only(left: 25.0, right: 25.0, bottom: 10.0),
                  child: Text('?????????? ???????????????????? ?? ???????????????? ?? ?????????????????????? ???????? ?????????? ???? ???????????? ?? ?????? ?????????????????? ?????????? ?? ?????????? ?????????? ????????????', style: TextStyle(color: Color(0xFF8E8E8E), fontSize: 12.0))
                ) : SizedBox(width: 1.0),
                Container(
                  width: MediaQuery.of(context).size.width - 10.0,
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 50,
                        height: 70.0,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: _card,
                          focusNode: _focusCard,
                          style: TextStyle(color: widget.colorText, fontSize: 14.0),
                          decoration: inputDecoration('?????????? ??????????', '?????????????? ?????????? ??????????', _cardValidate)
                        )
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 50) / 2 - 10.0,
                            height: 70.0,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              controller: _srok,
                              focusNode: _focusSrok,
                              style: TextStyle(color: widget.colorText, fontSize: 14.0),
                              decoration: inputDecoration('????/????', '???????????????? ???????? ????????????????', _srokValidate)
                            )
                          ),
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 50) / 2 - 10.0,
                            height: 70.0,
                            child: TextField(
                              obscureText: true,
                              enableSuggestions: false,
                              autocorrect: false,
                              keyboardType: TextInputType.number,
                              controller: _cvv,
                              focusNode: _focusCvv,
                              style: TextStyle(color: widget.colorText, fontSize: 14.0),
                              decoration: inputDecoration('CVC', '?????? ?? ???????????????? ?????????????? ??????????', _cvvValidate)
                            )
                          ),
                        ]
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20.0, bottom: 15.0, left: 30.0, right: 30.0),
                        child: SizedBox(
                          height: 63,
                          child: TextButton(
                            onPressed: _isButtonDisabled || _loading ? null : () => _payCard(),
                            style: TextButton.styleFrom(
                              backgroundColor: _isButtonDisabled || _loading ? widget.colorButtonDisabled : widget.colorButton,
                              minimumSize: Size(300, 63),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              ),
                              elevation: 5.0
                            ),
                            child: Text("????????????????" + _sumInfo,
                                style: TextStyle(fontSize: 17, color: Colors.white)
                            )
                          )
                        )
                      ),
                      Text('?????????????? ???????????? ???????????????? ???? ???????????????????????? ?? ?????????????????? ?????????????? ImPay', style: TextStyle(color: Color(0xFF8E8E8E), fontSize: 12.0))
                    ]
                  ),
                ),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Image.asset('imgs/pci.png', scale: 4.0, package: 'impay_sdk'),
                          Image.asset('imgs/visa.png', scale: 4.0, package: 'impay_sdk'),
                          Image.asset('imgs/mastercard.png', scale: 4.0, package: 'impay_sdk'),
                          Image.asset('imgs/mir.png', scale: 4.0, package: 'impay_sdk')
                        ]
                      )
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 50.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('www.impay.ru', style: TextStyle(color: widget.colorTextLight, fontSize: 12.0)),
                        ]
                      )
                    )
                  ]
                )
              ]
          )
      )]));
    }
}