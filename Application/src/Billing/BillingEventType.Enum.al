#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
enum 6059854 "NPR Billing Event Type"
{
    Access = Internal;
    Extensible = false;

    value(0; InternalDevelopmentEvent)
    {
        Caption = 'Internal Development Event', Locked = true;
    }
    value(1; POSLogin)
    {
        Caption = 'POS Login', Locked = true;
    }
    value(2; ECOM_SHOPIFY_ORDERS_COUNT)
    {
        Caption = 'Ecommerce Shopify Orders Count', Locked = true;
    }
    value(3; ECOM_SHOPIFY_ORDERS_AMOUNT_PRESENTMENT)
    {
        Caption = 'Ecommerce Shopify Orders Amount Presentment', Locked = true;
    }
    value(4; ECOM_SHOPIFY_ORDERS_AMOUNT_SHOP)
    {
        Caption = 'Ecommerce Shopify Orders Amount Shop', Locked = true;
    }
}
#endif