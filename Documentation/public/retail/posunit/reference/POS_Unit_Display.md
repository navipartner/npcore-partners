# POS Unit Display (reference guide)

In the **POS Unit Display** you can configure device-specific information for the **POS Display Profile**. For example, the **POS Display Profile** specifies what a theme looks like, whereas **POS Unit Display** specifies if the device bound to the **POS Unit No.** has downloaded the media and on which connected screen it will be displayed.

| Field Name      | Description |
| ----------- | ----------- |
| **POS Unit No.**       | The unique code for the POS Unit that is beeing configured.   |
| **Media Downloaded**   | Specifies whether the media from **Display Content Code** in **POS Display Profile** should be downloaded. If checked, the POS won't download any media when loaded, and it will not check whether the local cache contains the images in the **Display Content Code** group. Instead, it will download and replace all, or do nothing. When adding new media to the **Display Content Code**, you need to deactivate this field to see the new media.       |
| **Screen No.**  | Specifies on which screen connected to the POS Unit, the costummer display should be displayed on. *0* is default, and will auto-select a non-main display. It is recommended to leave it on *0* unless the POS unit has more than 2 screens. |

### Related links

- [POS unit](../explanation/POSUnit.md)
- [POS Display Profile (reference guide)](./POS_Display_profile.md)