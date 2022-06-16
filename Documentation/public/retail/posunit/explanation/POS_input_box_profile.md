# POS input box profile

POS input box profile is used to set up which data can be recognized in the input box in POS Unit.

In system by default there is one POS input box profile with **Code** SALE and **Description** Default EAN box Sales Setup. If there is need to create different profile, there is posibillity to create new one with unique **Code** and **Description**.

Events which trigers action for inserting data in POS are assigned in **POS Input Box Setup Events** section. In this section fields that are editable are Event Code and Enabled. Every Event code has to be enabled so it can be used in POS.

Diferent types of Event codes:
- **CUSTOMERNO** - customers will be searched by Customer number.
- **CUSTOMERSEARCH** - customers will be searched by name.
- **ITEMNO** - item will be searched by item number
- **ITEMSEARCH** - item will be searched by name.
- **ITEMCROSSREFERENCENO** - item will be searched by cross reference number.
- **DISCOUNT_COUPON** - coupons will be searched (scaned) by coupon reference number.
- **QTYSTAR** - allows change of quantity in active sales line by entering *3 (new quantity) in input box. Pressing **Enter** quantity in active sale line will change from old to 3.