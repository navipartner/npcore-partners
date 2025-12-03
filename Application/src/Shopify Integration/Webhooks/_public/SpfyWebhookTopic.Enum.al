#if not BC17
enum 6059772 "NPR Spfy Webhook Topic" implements "NPR Spfy Webhook Notif. IHndlr"
{
    Extensible = true;
    DefaultImplementation = "NPR Spfy Webhook Notif. IHndlr" = "NPR Spfy Undef.Webhook Handler";

    value(0; UNDEFINED)
    {
        Caption = '<Undefined>';
    }
    value(10; "products/create")
    {
        Caption = 'product created';
        Implementation = "NPR Spfy Webhook Notif. IHndlr" = "NPR Spfy Item Webhook Handler";
    }
    value(11; "products/delete")
    {
        Caption = 'product deleted';
        Implementation = "NPR Spfy Webhook Notif. IHndlr" = "NPR Spfy Item Webhook Handler";
    }
    value(12; "products/update")
    {
        Caption = 'product updated';
        Implementation = "NPR Spfy Webhook Notif. IHndlr" = "NPR Spfy Item Webhook Handler";
    }
    value(20; "customers/create")
    {
        Caption = 'customer created';
        Implementation = "NPR Spfy Webhook Notif. IHndlr" = "NPR Spfy Cust. Webhook Handler";
    }
    value(21; "customers/delete")
    {
        Caption = 'customer deleted';
        Implementation = "NPR Spfy Webhook Notif. IHndlr" = "NPR Spfy Cust. Webhook Handler";
    }
    value(22; "customers/update")
    {
        Caption = 'customer updated';
        Implementation = "NPR Spfy Webhook Notif. IHndlr" = "NPR Spfy Cust. Webhook Handler";
    }
}
#endif