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
        Implementation = "NPR Feature Management" = "NPR Shopify Integr. Feature";
    }
#endif
}
