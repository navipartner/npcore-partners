# What's new

Learn which new features and improvements have been introduced in the newest versions of the NP Retail solution:

## Version 19.0 (March 7th 2023)

### Limiting payment types to specific items

You can now create payment methods that are used on the POS for purchasing only the items or item categories you single out during its creation. This option is especially useful when you wish to establish vouchers as viable types of payment for specific items only.

For more information and operating instructions, refer to the following articles:

- [Meal, eco, and consumption vouchers](retail/posunit/explanation/belgian_voucher.md)
- [Limit payment types to specific items](retail/posunit/howto/belgian_vouchers.md)

### Bin change from the POS

With the new release, if there are multiple bins in a single store location, you can choose which bin the item is taken from during the POS sale. This is done with the new **CHANGE_BIN** POS action that can be added to the POS menu as a button.

For more information and operating instructions, refer to the article on [Changing the bin from a POS sale](retail/posunit/howto/change_bin_pos.md).

### Responsibility center change from the POS

You can now change the selected [responsibility center](https://learn.microsoft.com/en-us/dynamics365/business-central/inventory-responsibility-centers) from an open POS sale. When changing the responsibility center, the dimensions in the POS sale change to the dimensions of the newly selected responsibility center. This is done with the new **CHANGE_RESP_CENTER** POS action that can be added to the POS menu as a button. 

For more information and operating instructions, refer to the article on [Changing the Responsibility Center from a POS sale](retail/posunit/howto/change_responsibility_center.md).

### Email ticket action

You can now send emails with purchase receipts to customers from the POS. This can be done with the new **SEND_RECEIPT** POS action that can be added to the POS menu as a button. 

For more information and operating instructions, refer to the article on [Sending receipt to customers on purchase](retail/posunit/howto/send_receipt_pos.md).

## Version 18.0 (January 28th 2023)

### Take a photo (from the POS)

You can now take photos of products and other items (like documents) directly from the POS. Among other things, this feature significantly improves the return process, allowing cashiers to capture the state of items at the moment of their return, and record the transaction receipts.

For more information and operating instructions, refer to the article on the [Take Photo on POS](retail/posunit/howto/take_photo_pos.md) feature.

> [!Video https://share.synthesia.io/d67f2a75-b897-46d8-80e1-50a83e9603b1]

### GS1 coupons

The GS 1 flat rate discount coupon has been introduced to NP Retail. [GS1](https://www.gs1us.org/upcs-barcodes-prefixes/additional-ways-to-identify-products/coupons) is a standard that facilitates connection between a product and all its vital data, allowing trackability, workflow efficiency, and information-sharing via electronic means. GS1 coupons can now be created on scanning, then used, and finally archived as soon as the POS sale is finalized. 

For more information and operating instructions, refer to the article on the [Coupons](retail/coupons/intro.md).

### HTML display profile - enhanced customer interaction and sales experience

A new POS profile has been introduced for desktop POS units with multiple displays. Its purpose is to enhance customer interaction and sales experience by allowing you to display media content on the POS screen. This content can be in the form of images, videos or even an entire website.

For more information and operating instructions, refer to the article on the [POS HTML display profile](retail/pos_profiles/howto/POS_HTMLDisplay_profile.md).

> [!Video https://share.synthesia.io/48a111db-645a-4ab4-85b6-4551b787b45f]

### V4 POS balancing feature - end-of-day process

A new version of the balancing feature has been released. For more information and setup instructions, refer to the article on the [POS balancing feature V4](retail/posunit/howto/balance_pos_v4.md).

> [!Video https://share.synthesia.io/ec8e0a32-7578-4569-a608-664743059921]

### NP Power BI for Retail

[NP Power BI for Retail](https://appsource.microsoft.com/en-us/product/power-bi/navipartner.np-power-bi-for-retail?tab=Overview) is a new tool that can be used to analyze sales through multidimensional views and provide a detailed insight into business performance. 

For more information and operating instructions, refer to the articles on the [NP Power BI for Retail](power_bi/power_bi_retail/intro.md).

### Softpay integration - Tap on Phone feature

NP Retail is now integrated with Softpay, which also includes the Tap on Phone feature, which essentially turns your smartphone into a contactless POS terminal capable of accepting payments from customers' cards or mobile wallets. 

For more information and operating instructions, refer to the articles on the [Softpay integration](retail/eft/howto/softpay.md)