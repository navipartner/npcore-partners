enum 6151416 "NPR PG Integrations" implements "NPR IPaymentGateway", "NPR Pay by Link"
{
    Extensible = true;

    // It is intentional that a value for id = 0 is not created.
    // 
    // If you want to create that one ensure that all logic relating
    // to the ID is equally updated.
    DefaultImplementation = "NPR Pay by Link" = "NPR Default PayByLink";

    value(1; Adyen)
    {
        Caption = 'Adyen';
        Implementation = "NPR IPaymentGateway" = "NPR Magento Pmt. Adyen Mgt.",
                        "NPR Pay by Link" = "NPR Adyen Pay By Link";

    }

    value(2; Bambora)
    {
        Caption = 'Bambora';
        Implementation = "NPR IPaymentGateway" = "NPR Magento Pmt. Bambora Mgt.",
                        "NPR Pay by Link" = "NPR Unknown PayByLink";
    }

    value(3; Dibs)
    {
        Caption = 'Dibs';
        Implementation = "NPR IPaymentGateway" = "NPR Magento Pmt. Dibs Mgt.",
                        "NPR Pay by Link" = "NPR Unknown PayByLink";
    }

    value(5; Netaxept)
    {
        Caption = 'Netaxept';
        Implementation = "NPR IPaymentGateway" = "NPR Magento Pmt. Netaxept Mgt.",
                        "NPR Pay by Link" = "NPR Unknown PayByLink";
    }

    value(6; EasyNets)
    {
        Caption = 'Nets Easy';
        Implementation = "NPR IPaymentGateway" = "NPR Magento Pmt. EasyNets Mgt",
                        "NPR Pay by Link" = "NPR Unknown PayByLink";
    }

    value(7; Quickpay)
    {
        Caption = 'Quickpay';
        Implementation = "NPR IPaymentGateway" = "NPR Magento Pmt. Quickpay Mgt.",
                        "NPR Pay by Link" = "NPR Unknown PayByLink";
    }

    value(8; Vipps)
    {
        Caption = 'Vipps';
        Implementation = "NPR IPaymentGateway" = "NPR PG Vipps Integration Mgt.",
                        "NPR Pay by Link" = "NPR Unknown PayByLink";
    }
    value(9; Stripe)
    {
        Caption = 'Stripe';
        Implementation = "NPR IPaymentGateway" = "NPR PG Stripe Integration Mgt.",
                        "NPR Pay by Link" = "NPR Unknown PayByLink";
    }
#if not BC17
    value(10; Shopify)
    {
        Caption = 'Shopify';
        Implementation = "NPR IPaymentGateway" = "NPR Spfy Payment Gateway Hdlr",
                        "NPR Pay by Link" = "NPR Unknown PayByLink";
    }
#endif
}