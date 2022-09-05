# Create QR codes

A QR code is a machine-readable optical label that can contain information about the entity it's attached to. Each of the existing users has their own unique QR code. To create a QR code in NP WMS:


1. Click the ![Lightbulb that opens the Tell Me feature](../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **NPRW CS QR Code List** and choose the related link.        
   The list of configured users is displayed.              
   You can find the QR code in the **NPRW CS QR Code FactBox** section for configured users.
2. Click **New** located in the ribbon in the top part of the screen if you wish to create a new user and QR code.
3. Fill out the necessary fields with the following information:

   | Field Name      | Description |
   | ----------- | ----------- |
   |  **User ID**   | Specifies the ID used for identifying the active user.   |
   |  **Password**  | Specifies the password the active user can use to log in.   |
   |  **Company**  |   Specifies the name of the company the user is associated with.   |
   |  **Tenant**  |  Specifies the ID of the default tenant associated with the active user. |
   |  **URL**  | Specifies the URL used for establishing connection with the database. |
   |  **Webservice URL**  | Specifies the webservice endpoint where the database can be accessed by the client application. |

> [!NOTE]
> The **URL** and the **WebService URL** can be defaulted by clicking **Set Defaults** in the ribbon.

1. Click **Create QR Code**.         
   The QR code is displayed in the **NPRW CS QR Code FactBox** section of the page.    

### Related links

- [Fetch setup data](./fetch-setup-data.md)
- [CS setup](../reference/cs-setup.md)
- [CS users](set-up-cs-users.md)