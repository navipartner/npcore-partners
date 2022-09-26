# Introduction to Softpay
Softpay is an app-based terminal solution that can be integrated into POS systems. This solution is integrated into NaviPartner's Retail app-based solution.

> [!NOTE]
> Softpay only works for the Android systems, and is limited to Android devices that are compliant with the security requirements. See  [devices](#devices).

NaviPartner handles the entire integration, but you need information from Softpay as well. To use this solution you need to contact Softpay to get merchant credentials consisting of a merchant ID/username and a password. You can also discuss your business needs for multiple accounts with Softpay, if you need different types of merchants.
Merchants can be configured to work for specific stores and with several privileges. See [devices](#devices) on how to configure Softpay in Retail as a part of the EFT flow. 

## Terms
Refer to the list of terms associated with the Softpay integration if you need any help understanding them:
**Merchant** - a term that describes an account for Softpay that is tied to your business.

**Merchant ID** - this ID can also be seen as a username, it is one of two pieces of information needed to login via the Softpay app.

**Enviroment** - specifies whether you operate in a Sandbox i.e. testing environment, or if you are using a Production environment.
Both environments have their own respective apps, the Sandbox app is distributed via Firebase, and you need to contact Softpay to get access. The Production app is distributed via Google Play. If the app is not available on your Android device the most probable reason is that your device is not supported by Softpay.
> [!WARNING]
> Remember to use test cards in the Sandbox environment, otherwise confidential credit card data might be leaked.

**Whitelisted**: Devices that are guaranteed to work.

**Blacklisted**: Devices not supported by Softpay.

## Devices
Softpay has lists of whitelisted and blacklisted devices. Devices not listed will have a probability to work, but there are no guarantees. Here's a list of requirements that devices need to meet to have a chance to work with Softpay:
- Has at least Android 8.0.
- Is equipped with hardware NFC.
- Online WiFi or Internet connection.
- Has a security patch that is less than 12 months old.
- Google Mobile Services enabled.

### Blacklisted devices
| Manufacturer  | Models        | Notes                                           |
|---------------|---------------|-------------------------------------------------|
| Huawei 	    | All devices   | Security issues behind Huawei & NFC read issues |
| Sunmi 	    | V2 	        | Does not have Google Mobile Service             |

### Whitelisted devices
| Manufacturer  | Models        |
|---------------|---------------|
| Samsung 	    | S22 (+, Ultra), S21 (+, + 5G, 5G, FE, FE 5G, Ultra 5G), S20 (+ 5G, 5G, FE, FE 5G, Ultra 5G), S10 (+, e, 5G, Lite) S9 and (+), S8 (+, Active), Xcover (Field pro, 4S,5, Pro), A52, A52 5G, A32, A32 5G |
| OnePlus 	    | OnePlus 7T Pro, OnePlus 8 pro, OnePlus 9 5G, OnePlus 9 Pro 5G| 	
| Point Mobile 	| PM45, PM85 |
| Sunmi 	    | V2s, V2s plus|
| Unitech 	    | EA630|
| Honeywell 	| CT40|
| Motorola 	    | G9 power, G9 plus, G31|
| Nokia 	    | 6.2, G20|
| Google 	    | Pixel 4, Pixel 6, Pixel 6 Pro, Pixel 3 (*)|