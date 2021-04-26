import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

import 'cryptor.dart';
import 'rest.dart';

class ImPayForm extends StatefulWidget {

  final int _partnerId;
  final Function(String, String) _onCreatePay;
  final double _sumPay;
  ImPayForm(this._partnerId, this._sumPay, this._onCreatePay);

  @override
  _ImPayFormState createState() => _ImPayFormState();
}

class _ImPayFormState extends State<ImPayForm> {

  var _card = MaskedTextController(mask: '0000-0000-0000-000000');
  var _srok = MaskedTextController(mask: '00/00');
  var _cvv = MaskedTextController(mask: '000');
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
  String _token;
  int _tokenId = 0;

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
      var r = json.decode(res);
      res = String.fromCharCodes(base64.decode(r['key']));
      setState(() {
        _token = res;
        _tokenId = r['id'];
        //print(_token);
      });
    }
    setState(() {
      _loading = false;
    });
  }

  payCard() async {

    if (_token != null && _token.isNotEmpty) {
      var card = _getOnlyNumbers(_card.text);
      var srok = _getOnlyNumbers(_srok.text);
      var cvv = _getOnlyNumbers(_cvv.text);
      var email = _getOnlyNumbers(_email.text);

      var paytoken = await Cryptor.tokenize(card, srok, cvv, _token);

      if (widget._onCreatePay != null) {
        widget._onCreatePay(base64.encode(
            utf8.encode(json.encode({"id": _tokenId, "paytoken": paytoken}))),
            email);
      }
    }
    Navigator.pop(context, 1);
  }

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
              color: Color(0xFFF4F3F8),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              width: 1.0,
              color: Color(0xFFF4F3F8)
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              width: 1.0,
              color: Color(0xFFC4D0E9)
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
                    Color(0xFF027FC6),
                    Color(0xFF009DF5),
                  ]
              )
          ),
          child: Column(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.all(25.0),
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
                          style: TextStyle(color: Color(0xFF2E2E2E), fontSize: 14.0),
                          decoration: inputDecoration('Номер карты', 'Введите номер карты', _cardValidate)
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
                              style: TextStyle(color: Color(0xFF2E2E2E), fontSize: 14.0),
                              decoration: inputDecoration('ММ/ГГ', 'Неверный срок действия', _srokValidate)
                            )
                          ),
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 50) / 2 - 10.0,
                            height: 70.0,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              controller: _cvv,
                              focusNode: _focusCvv,
                              style: TextStyle(color: Color(0xFF2E2E2E), fontSize: 14.0),
                              decoration: inputDecoration('CVC', 'Код с обратной стороны карты', _cvvValidate)
                            )
                          ),
                        ]
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 50,
                        height: 70.0,
                        child: TextField(
                          keyboardType: TextInputType.emailAddress,
                          controller: _email,
                          focusNode: _focusEmail,
                          style: TextStyle(color: Color(0xFF2E2E2E), fontSize: 14.0),
                          decoration: inputDecoration('Email', 'Неверный адрес', _emailValidate)
                        )
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20.0, bottom: 15.0, left: 30.0, right: 30.0),
                        child: SizedBox(
                          height: 63,
                          child: TextButton(
                            onPressed: _isButtonDisabled || _loading ? null : () => payCard(),
                            style: TextButton.styleFrom(
                              backgroundColor: _isButtonDisabled || _loading ? Color(0xFF61C6FF) : Color(0xFF00A3FF),
                              minimumSize: Size(300, 63),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              ),
                              elevation: 5.0
                            ),
                            child: Text("Оплатить" + (widget._sumPay > 0 ? " " + widget._sumPay.toString() + " \u{20bd}" : ""),
                                style: TextStyle(fontSize: 17, color: Colors.white)
                            )
                          )
                        )
                      ),
                      Text('Нажимая кнопку оплатить Вы соглашаетесь с условиями сервиса ImPay', style: TextStyle(color: Color(0xFF8E8E8E), fontSize: 12.0))
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('+7 (8332) 25-54-44', style: TextStyle(color: Color(0xFFD2EFFF), fontSize: 12.0)),
                          Text('support@impay.ru', style: TextStyle(color: Color(0xFFD2EFFF), fontSize: 12.0)),
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