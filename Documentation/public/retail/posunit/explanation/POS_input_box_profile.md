# POS Input Box Profile

The POS Input Box Profile is used for setting up which data will be recognized in the input box in a POS Unit.

By default there is one POS input box profile with the **Code** *SALE* and **Description** *Default EAN box Sales Setup* in the system. If there is a need to create a different profile, you can create a new one with the unique **Code** and **Description**.

Events which trigger the action for inserting data in the POS are assigned in the **POS Input Box Setup Events** section. In this section the editable fields are **Event Code** and **Enabled**. Every **Event Code** has to be enabled so it can be used in the POS.

Different types of event codes are:

| Field Name      | Description |
| ----------- | ----------- |
| **CUSTOMERN**       | The customers will be searched by their customer numbers.     |
| **CUSTOMERSEARCH**   | The customers will be searched by their names.        |
| **ITEMNO**  | The items will be searched by their item numbers. |
| **ITEMSEARCH** | The items will be searched by their names. |
| **ITEMCROSSREFERENCENO** | The items will be searched by their cross reference numbers. |
| **DISCOUNT_COUPON** | The coupons will be searched (scanned) by coupon reference numbers. |
| **QTYSTAR** | Allows changing the quantity in the active sales line by entering *3 (a new quantity) in the input box. When you press **Enter**, the quantity in active sale line will change from the old quantity to "3" (a new quantity). |
