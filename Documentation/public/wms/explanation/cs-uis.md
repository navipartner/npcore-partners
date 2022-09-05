# Capture service UIs

The Capture Service user interfaces (CS UI) are used for defining the look and feel of WMS mobile device app. You can see the list of all available CS UIs in the **CS UIs** administrative section. You can view and edit the existing CS UIs or [create new ones](../howto/set-up-cs-uis.md). 

To see the current UI layout and hierarchy of UIs in the mobile app, navigate to the [**CS UI Structure**](./cs_ui_structure.md) administrative section. You can add or remove some segments from the current app layout if needed. 

> [!Note]
> For the mobile app to work correctly, it's necessary to define the **Start UI**, which is the first screen that the user sees when opening the mobile app. By default, this is the login screen. You can pick the start UI either from the **CS UI Structure**, or an individual **CS UI** card.

## General

There are several customizable **Form Types** that exist in NP WMS. These UI types are listed below along with the screenshots depicting the necessary setup in Business Central on the left side, and on right - the corresponding mobile app UI. If you wish to apply one of these UI layouts in your app, use the options presented in the Business Central segment of each screenshot. 

- **Card** (e.g. Login)     
  The **Card** type is used only for the Login screen, in which user input is required.

    ![example](../images/Logging.jpg)

- **Selection List** (e.g. main menu)

    ![example](../images/menu-type-ui.jpg)   

> [!Tip]
> Selection lists don't have the **Next UI** link like the **Card** pages, as they typically give users the option of navigating to multiple pages in no specific order. To specify which UIs users can navigate to from the selection list, provide the UI IDs in the **Call UI** column of the **CS UI Subform**. 

- **Data List** (a dynamic list of information that relies on the documents created in Business Central e.g. Inventory pick list)

    ![example](../images/datalist-type-ui.png)

- **Data List Input** (these types of UIs determine what happens at the end of the process, i.e. when the barcode is scanned e.g. Warehouse Pick document)

    ![example](../images/datainput-type.jpg)


> [!Note]
> NaviPartner provides standard UIs which can be implemented and modified as per requirements of the users.

## UI Subform

In the **UI Subform** section of each CS UI, you can add the actual content of each mobile UI, and designate where the page elements you create will be placed. The available areas are **Header**, **Body**, and **Footer**.

> [!Note]
> In the **NP WMS** app you can click the header of each page to see which **UI Code**, **Handling Codeunit**, and **Next UI** were used. 


## Data pattern code

Data pattern code is the code assigned to a certain product. It consists of some of the product's main characteristics, such as ingredients, year of production, expiration date, and so on. Each of these characteristics has its own ID, and the combination of all of them provides a unique ID for all goods which are placed inside the warehouse. 

## Handling codeunit

Each UI can be associated with one handling codeunit. Codeunits govern the back-end processes associated with each UI. 

### Related links

- [Set up UIs](../howto/set-up-cs-uis.md)
- [Set up CS UIs - video walkthrough](https://www.youtube.com/watch?v=TV-fvUlQ8Ik)
- [Set up Data Pattern Code](../howto/set-up-datapatterncode.md)
- [CS setup](../reference/cs-setup.md)