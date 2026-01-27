enum 6014577 "NPR Feature" implements "NPR Feature Management"
{
#if not BC17  
    Access = Internal;
    UnknownValueImplementation = "NPR Feature Management" = "NPR Unknown Feature";
#endif
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ', Locked = true, MaxLength = 50;
        Implementation = "NPR Feature Management" = "NPR Unknown Feature";
    }
    value(1; Retail)
    {
        Caption = 'Retail', Locked = true, MaxLength = 50;
        Implementation = "NPR Feature Management" = "NPR Retail Feature";
    }
    value(10; "Ticket Essential")
    {
        Caption = 'Ticket Essential', Locked = true, MaxLength = 50;
        Implementation = "NPR Feature Management" = "NPR Ticket Essential Feature";
    }
    value(20; "Ticket Advanced")
    {
        Caption = 'Ticket Advanced', Locked = true, MaxLength = 50;
        Implementation = "NPR Feature Management" = "NPR Ticket Advanced Feature";
    }
    value(30; "Ticket Wallet")
    {
        Caption = 'Ticket Wallet', Locked = true, MaxLength = 50;
        Implementation = "NPR Feature Management" = "NPR Ticket Wallet Feature";
    }
    value(40; "Ticket Dynamic Price")
    {
        Caption = 'Ticket Dynamic Price', Locked = true, MaxLength = 50;
        Implementation = "NPR Feature Management" = "NPR Ticket Dyn. Price Feature";
    }
    value(50; NaviConnect)
    {
        Caption = 'NaviConnect', Locked = true, MaxLength = 50;
        Implementation = "NPR Feature Management" = "NPR NaviConnect Feature";
    }
    value(60; "Membership Essential")
    {
        Caption = 'Membership Essential', Locked = true, MaxLength = 50;
        Implementation = "NPR Feature Management" = "NPR Membership Essent. Feature";
    }
    value(70; "Membership Advanced")
    {
        Caption = 'Membership Advanced', Locked = true, MaxLength = 50;
        Implementation = "NPR Feature Management" = "NPR Membership Adv. Feature";
    }
    value(80; HeyLoyalty)
    {
        Caption = 'HeyLoyalty', Locked = true, MaxLength = 50;
        Implementation = "NPR Feature Management" = "NPR HeyLoyalty Feature";
    }
#if not BC17
    value(90; Shopify)
    {
        Caption = 'Shopify Integration', Locked = true, MaxLength = 50;
        Implementation = "NPR Feature Management" = "NPR Spfy Integration Feature";
    }
#endif
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    value(91; "Shopify Ecommerce Order Experience")
    {
        Caption = 'Shopify Ecommerce Order Experience', Locked = true, MaxLength = 50;
        Implementation = "NPR Feature Management" = "NPR Spfy Ecommerce Order Exp";
    }
#endif
    value(100; "POS Scenarios Obsoleted")
    {
        Caption = 'POS Scenarios Obsoleted', Locked = true, MaxLength = 50;
        Implementation = "NPR Feature Management" = "NPR Scenario Obsoleted Feature";
    }
    value(110; "New POS Editor")
    {
        Caption = 'New POS Editor', Locked = true, MaxLength = 50;
        Implementation = "NPR Feature Management" = "NPR New POS Editor Feature";
    }
    value(120; "POS Statistics Dashboard")
    {
        Caption = 'POS Statistics Dashboard', Locked = true, MaxLength = 50;
        Implementation = "NPR Feature Management" = "NPR POS Stat Dashboard Feature";
    }
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    value(130; "NP Email")
    {
        Caption = 'NP Email', Locked = true, MaxLength = 50;
        Implementation = "NPR Feature Management" = "NPR NP Email Feature";
    }
    value(131; "New Email Experience")
    {
        Caption = 'New Email Experience', Locked = true, MaxLength = 50;
        Implementation = "NPR Feature Management" = "NPR NewEmailExpFeature";
    }
#endif
    value(140; "POS Webservice Sessions")
    {
        Caption = 'POS Webservice Sessions', Locked = true, MaxLength = 50;
        Implementation = "NPR Feature Management" = "NPR POS Webservice Sessions";
    }
    value(150; "New Sales Receipt Experience")
    {
        Caption = 'New Sales Receipt Experience';
        Implementation = "NPR Feature Management" = "NPR New Sales Receipt Exp";
    }
    value(160; "New EFT Receipt Experience")
    {
        Caption = 'New EFT Receipt Experience';
        Implementation = "NPR Feature Management" = "NPR New EFT Receipt Exp";
    }
    value(170; Magento)
    {
        Caption = 'Magento Integration', Locked = true, MaxLength = 50;
        Implementation = "NPR Feature Management" = "NPR Magento Feature";
    }
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    value(180; "POS License Billing Integration")
    {
        Caption = 'POS License Billing Integration', Locked = true, MaxLength = 50;
        Implementation = "NPR Feature Management" = "NPR POS License Billing Feat.";
    }
#endif

    value(185; MemberMediaInCloudflare)
    {
        Caption = 'BC Media in Cloudflare R2 Storage', Locked = true, MaxLength = 50;
        Implementation = "NPR Feature Management" = "NPR MemberImageMediaFeature";
    }
    value(190; "New Attraction Print Exerience")
    {
        Caption = 'New Attraction Print Experience';
        Implementation = "NPR Feature Management" = "NPR New Attraction Print Exp";
    }
}
