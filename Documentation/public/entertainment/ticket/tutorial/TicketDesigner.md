# Ticket Designer

This article lists the **Ticket Designer** functionalities and provides the instructions for designing, duplicating, and deleting tickets.

## Shortcut Keys and Tools  
  

| Shortcut    | Tools                                          |Description                     |
| ----------- | -----------                                    |-----------                     |
| Alt + T     | ![Text tool](../images/text.png)               |Toggle **Custom text toolbox**  |
| Alt + F     | ![Field tool](../images/field.png)             |Toggle **Field** Toolbox        |
| Alt + Q     | ![QRcode tool](../images/QRCode.png)           |Toggle **QRcode** Toolbox       |
| Alt + B     | ![barcode tool](../images/barcode.png)         |Toggle **Barcode** Toolbox      |
| Alt + I     | ![Image tool](../images/Image.png)             |Toggle **Image** windows        |
| Alt + M     | ![Measure tool](../images/measure.png)         |Toggle **Measure** Toolbox      |
| Alt + G     | ![Guidelines tool](../images/guidelines.png)   |Add / Remove **Guideline**      | 
| Alt + L     | ![Layers tool](../images/Layers.png)           |Show / Hide **Layers** box      |
| Alt + Z     | ![Zoom tool](../images/zoom.png)               |**Zoom** in / **Zoom** out      |
| Alt + P     | ![Preview tool](../images/preview.png)         |Toggle **preview** window       |
| Alt + H     | ![CenterHoriz tool](../images/centerhoriz.png) |Center **horizontally**         |
| Alt + V     | ![CenterVert tool](../images/centervert.png)   |Center **vertically**           |
| Alt + C     | ![Contain tool](../images/contain.png)         |**Contain** within page         |
| Alt + O     | ![Overflow tool](../images/overflow.png)       |Show **Overflow** elements      |
| Alt + A     | ![GIF tool](../images/GIF.png)                 |Toggle **.gif** window *(only for mobile ticket)*|


## The Admin

When having logged into the **Ticket Designer admin** you have different options. You can either:

- Create a new ticket.
- Duplicate / Delete / Design / create a mobile ticket.      
![admin](../images/admin.png)

## Duplicating a Ticket

Duplicating an existing ticket might be the easiest available operation. Most of the time you might want to keep the existing layout but alter a couple of things, maybe some text, or an image, so duplicating is definitely the way to go. This course of action also implies that you do not have to set a completely new design manually every time.

1. Click **Duplicate** ![duplicate](../images/dublicate.png).    
   You will then be prompted to define the ticket parameters:    
   ![duplicate](../images/dublicatepromp.png)

- **Ticket Code Type** - The code that the ticketing system will use to match the design from the actual ticket being sold.
- **Language** - The language for which this ticket will be used - Danish or English.

>[!NOTE]
>More languages can be added upon request.

2. Click **Save**.


If you create a new ticket design from scratch you will also have to set the actual print size of the final ticket; This can be either A4 or A5. This also defines the canvas on the ticket designer.    

![new ticket](../images/newticketlayout.png)


## Deleting a ticket

If you want to delete a created ticket click ![delete](../images/deleteticket.png).   
Once clicked, you will be prompted if you want to proceed. Clicking **OK** will result in ticket deletion.

## Designing a ticket

1. Click ![design](../images/design.png) to start designing a ticket.    
   If you have duplicated a ticket you will be presented by a complete copy of the duplicated ticket that you can edit as you please. If you have created an entirely new ticket you will be presented by a blank page.  
2. In the ticket designer you can easily add elements and move them around your page (canvas) by clicking and dragging. Together with a lot of intuitive tools you can position your items to pixel point accuracy.  

>[!NOTE]
>You can always right-click on the existing elements and choose to **Edit** or **Delete** the element.  

### Design Toolbar

The design toolbar contains all the design options.       
![toolbar](../images/toolbar.png)      
Please refer to the shortcut keys section in the beginning of the article for a full list of shortcut keys to use within the ticket designer.

### Text

The **Text** tool allows you to customize the text **Font Size**, **Font (Type)**, and the **Font Color**.  


### Field

The **Field** tool allows you to add fields that will be dynamically replaced with the actual content when the ticket is generated (E.g. Customer name, Ticket price, visit date, etc.).  
This tool also allows you to define the **Font Size**, **Font (Type)**, and **Font Color** of the fields that are displayed on the ticket.

### QrCode

Using the **QRCode** tool you can add QR Codes on your ticket. You can chose from 4 different sizes for the QRCode: *Small**, **Medium**, **Large**, and **X-Large**.

### Bar Code

Using the **Bar Code** tool you can add and customize Bar Codes on your ticket. You can chose from 2 different sizes; **Small** and **Medium**.

### Image

The **Image** tool allows you to upload images from your computer to the ticket. It also allows you to reuse a picture that you have uploaded in the past for any previously designed ticket.

- **Upload image** - When uploading an image first click **Choose File** to browse your computer and look for the image you want to upload. Once you select the image, click **Add** to start uploading. Once the image is uploaded it will be automatically displayed on the page. The allowed image formats are JPG, GIF, PNG, and Transparent PNG.

- **Select a previously uploaded image** - If you want to reuse an image you've uploaded in the past (on any ticket) you can click the **Browse Ticket** tab and then click through the list of images. Note that there will be a small preview displayed down the list to help you make an exact choice.
 
### Measure

If you want to know which size of image you want to add on a specific region on the ticket, a quick way to do so is by using the **Measure** tool. The **Measure** tool is a point-to-point tool which will give you the **Width(W)** and **Height (H)** of a specific region. First select the **Measure** tool, then click on a starting point, move your mouse to the end point, and click again.

> [!Note]
> Bear in mind that the **Measure** tool is not a click-and-drag tool*. 

Note that you can always hide the measuring layer by clicking the **Measure** tool icon from the toolbar again. When hiding the measure tool the selected region is not lost.

### Guidelines

**Guidelines** are here to give you the X and Y coordinates so you can position your elements with high accuracy on the page. Together with the positioning tool in the footer you can quickly move the elements exactly to the required coordinates with pixel point accuracy.

>[!NOTE]
> For the horizontal and vertical lines there are two lines to drag in each direction to use for assistance.

### Layers

Using the **Layer** tool you can move elements on top or send them to the back very easily. Note that you can only move elements within their element group. For example, you can only sort texts within text element group, etc. Images will always be displayed under **Text** and **Text** will always be displayed under **Fields**.  

In the tool you can drag to move the layers up and down:    
![Layers Popup](../images/layerpopup.png)

### Preview

The **Preview** window will show you how the ticket will look after compiling. You can keep the window open and work on the ticket designer. Each time you make a change on the page the preview will reload.

### Reload

To reload, click <img src="../images/reload.png" width="40">.   

Assume you started editing an existing ticket and then you realized that you are doing it all wrong. You can always reload the ticket which will bring the ticket back to it status when last published.

### Publish

To publish, click <img src="../images/publish.png" width="40">.

A ticket will never go to the production mode unless you publish it. Once you are done designing a ticket, and are sure that what you see in the **Preview** is what you want, then the ticket is ready to be published.

>[!IMPORTANT]
>A ticket can always be changed, even if it is put up for sale. The changes provided to the ticket will also take action on the already issued tickets. The customers will have to update the **Ticket** page and the changes will occur.

## Mobile Ticket

For creating a mobile ticket the procedure is just like creating a printed ticket that will be generated for a .pdf-file. The only difference for the designer is that there is a tool for adding a .gif file for your ticket. 

>[!NOTE]
>This ticket will be opened in a browser.

### Related links

- [Ticket module](../intro.md)
- [Set up DIY printed tickets](../howto/SetUpDIYPrintedTicket.md)