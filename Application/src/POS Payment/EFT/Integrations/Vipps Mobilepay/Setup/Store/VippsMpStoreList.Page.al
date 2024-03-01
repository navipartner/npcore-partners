page 6151497 "NPR Vipps Mp Store List"
{
    PageType = List;
    Caption = 'Vipps Mobilepay Stores';
    Extensible = false;
    UsageCategory = None;
    SourceTable = "NPR Vipps Mp Store";
    CardPageId = "NPR Vipps Mp Store";
    Editable = False;

    layout
    {
        area(Content)
        {
            repeater("General")
            {
                field("Merchant Serial No."; Rec."Merchant Serial Number")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Merchant Serial Number is the identifier of the store configured in the Vipps Mobilepay portal';
#if NOT BC17
                    AboutTitle = 'Merchant Serial Number';
                    AboutText = 'Merchant Serial Number is the identifier of the store configured in the Vipps Mobilepay portal';
#endif
                }
                field("Store Name"; Rec."Store Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Store Name is the name of the store configured in the Vipps Mobilepay portal';
                    Enabled = False;
#if NOT BC17
                    AboutTitle = 'Store Name';
                    AboutText = 'Store Name is the name of the store configured in the Vipps Mobilepay portal';
#endif
                }
                field("Partner API Enabled"; Rec."Partner API Enabled")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether to use the Partner API, it is required that Navipartner is configured as partner in Vipps Mobilepay portal.';
#if NOT BC17
                    AboutTitle = 'Partner API Enabled';
                    AboutText = 'Specifies whether to use the Partner API, it is required that Navipartner is configured as partner in Vipps Mobilepay portal.';
#endif
                }
                field(Sandbox; Rec.Sandbox)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the sandbox testing environment should be used.';
#if NOT BC17
                    AboutTitle = 'Sandbox environment';
                    AboutText = 'Specifies if the sandbox testing environment should be used.';
#endif
                }
            }

        }
    }
}