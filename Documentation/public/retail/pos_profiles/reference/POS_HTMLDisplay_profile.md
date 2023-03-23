# POS HTML Display Profile (reference guide)

Each POS unit can have a different display view. The following fields can be set up in each **POS HTML Display Profile**:


| Field Name      | Description |
| ----------- | ----------- |
| **Code**       | Specifies the unique code of the profile.     |
| **Description**   | Specifies the short description of a profile.        |
| **HTML File**  |  This field shows if there is an uploaded HTML file, which is sent to the [Hardware Connector](../../gettingstarted/hw_connector.md). |
| **Price ex. VAT** | Specifies whether the prices are visible without the VAT on the POS. |
| **Receipt Item Description** | Specifies which description is used on the second display. It can be either **Item Description 1** or **Item Description 2** from the **Items** list. |  
| **Display Content Code** | Specifies the **Display Content Code** group that will be used for this POS HTML Display Profile. Display content codes are groupings of either images, videos, or URLs. This is where the media displayed on the customer display is uploaded or linked to. |
| **Customer Input Option: Money Back** | Specifies the input method for ending a sale with a negative total i.e. returning money to the costumer. It can be **None** or **Phone & Signature**. |

> [!Note]
> If need be, the second POS display should be updated to latest version of [Microsoft Edge](https://developer.microsoft.com/en-us/microsoft-edge/webview2/)Evergreen Bootstrapper.

![POS_display](../images/html_profile_new_filled.png)
### Related links

- [Set up the POS HTML Display](../howto/POS_HTMLDisplay_profile.md)