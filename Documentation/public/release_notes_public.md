# What's new

Learn which new features and improvements have been introduced in the newest versions of the NP Retail solution:

## Version 19.0 (March 7th 2023)

### Limiting payment types to specific items

You can now create payment methods that are used on the POS for purchasing only the items or item categories you single out during its creation. This option is especially useful when you wish to establish vouchers as viable types of payment for specific items only.

For more information and operating instructions, refer to the following articles:

- [Meal, eco, and consumption vouchers](retail/posunit/explanation/belgian_voucher.md)
- [Limit payment types to specific items](retail/posunit/howto/belgian_vouchers.md)

> [!Video https://share.synthesia.io/1bfaa867-e9d0-41b8-b660-9af1b51026c0]

### Bin change from the POS

With the new release, if there are multiple bins in a single store location, you can choose which bin the item is taken from during the POS sale. This is done with the new **CHANGE_BIN** POS action that can be added to the POS menu as a button.

For more information and operating instructions, refer to the article on [Changing the bin from a POS sale](retail/posunit/howto/change_bin_pos.md).

> [!Video https://share.synthesia.io/20e98ccd-0283-4092-b0ca-627b84fcdbc2]

### Responsibility center change from the POS

You can now change the selected [responsibility center](https://learn.microsoft.com/en-us/dynamics365/business-central/inventory-responsibility-centers) from an open POS sale. When changing the responsibility center, the dimensions in the POS sale change to the dimensions of the newly selected responsibility center. This is done with the new **CHANGE_RESP_CENTER** POS action that can be added to the POS menu as a button. 

For more information and operating instructions, refer to the article on [Changing the Responsibility Center from a POS sale](retail/posunit/howto/change_responsibility_center.md).

> [!Video https://share.synthesia.io/5b7d04a9-c202-49fe-90bf-c2dc8da3ecf7]

### Sending email receipts from the POS

You can now send emails with purchase receipts to customers from the POS. This can be done with the new **SEND_RECEIPT** POS action that can be added to the POS menu as a button. 

For more information and operating instructions, refer to the article on [Sending receipt to customers on purchase](retail/posunit/howto/send_receipt_pos.md).

> [!Video https://share.synthesia.io/7e37de5d-ab4e-4217-9e46-dafee10ccabb]

### Second display control

You can now get the customer's signature on the second display upon returning of items, and enclose that with the invoice for that transaction.

For more information and operating instruction refer to the article on [returning items with the help of the second POS screen](retail/posunit/howto/take_photo_pos.md).

> [!Video https://share.synthesia.io/bcb78cc7-925f-4182-bfdb-79fa15061b2e]

## Version 18.0 (January 28th 2023)

### Take a photo (from the POS)

You can now take photos of products and other items (like documents) directly from the POS. Among other things, this feature significantly improves the return process, allowing cashiers to capture the state of items at the moment of their return, and record the transaction receipts.

For more information and operating instructions, refer to the article on the [Take Photo](retail/posunit/howto/take_photo_pos.md) feature.

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