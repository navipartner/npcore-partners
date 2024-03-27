enum 6151416 "NPR PG Integrations" implements "NPR IPaymentGateway"
{
    Extensible = true;

    // It is intentional that a value for id = 0 is not created.
    // 
    // If you want to create that one ensure that all logic relating
    // to the ID is equally updated.

    value(1; Adyen)
    {
        Caption = 'Adyen';
        Implementation = "NPR IPaymentGateway" = "NPR Magento Pmt. Adyen Mgt.";
    }

    value(2; Bambora)
    {
        Caption = 'Bambora';
        Implementation = "NPR IPaymentGateway" = "NPR Magento Pmt. Bambora Mgt.";
    }

    value(3; Dibs)
    {
        Caption = 'Dibs';
        Implementation = "NPR IPaymentGateway" = "NPR Magento Pmt. Dibs Mgt.";
    }

    value(5; Netaxept)
    {
        Caption = 'Netaxept';
        Implementation = "NPR IPaymentGateway" = "NPR Magento Pmt. Netaxept Mgt.";
    }

    value(6; EasyNets)
    {
        Caption = 'Nets Easy';
        Implementation = "NPR IPaymentGateway" = "NPR Magento Pmt. EasyNets Mgt";
    }

    value(7; Quickpay)
    {
        Caption = 'Quickpay';
        Implementation = "NPR IPaymentGateway" = "NPR Magento Pmt. Quickpay Mgt.";
    }

    value(8; Vipps)
    {
        Caption = 'Vipps';
        Implementation = "NPR IPaymentGateway" = "NPR PG Vipps Integration Mgt.";
    }
    value(9; Stripe)
    {
        Caption = 'Stripe';
        Implementation = "NPR IPaymentGateway" = "NPR PG Stripe Integration Mgt.";
    }
#if not BC17
    value(10; Shopify)
    {
        Caption = 'Shopify';
        Implementation = "NPR IPaymentGateway" = "NPR Spfy Payment Gateway Hdlr";
    }
#endif
}