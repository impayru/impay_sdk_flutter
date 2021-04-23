# ImPay SDK

Flutter plugin to ImPay SDK

## Installation

To use the plugin, add `impay_sdk` as a
[dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

## Usage

1. Open pay page

```
Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => ImPayForm(<Id>, <sum>, <callback>);
    )
);

```

2. Send pay data to server, and then send it from api 

```
callback(paytoken, email) {
    ...
}

```

## Example

```
import 'package:impay_sdk/impay_sdk.dart'; 

int IdPartner = 2;
double Sum = 200.00;

callback(paytoken, email) {
    //TODO: send pay data to your server
}

Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => ImPayForm(IdPartner, Sum, callback)
    )
);

```

### Contributions
[ImPay LLC](https://github.com/impayru) SDK pay.