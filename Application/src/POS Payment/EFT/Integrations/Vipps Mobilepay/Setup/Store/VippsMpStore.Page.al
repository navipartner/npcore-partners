page 6151498 "NPR Vipps Mp Store"
{
    PageType = Card;
    Caption = 'Vipps Mobilepay Store';
    Extensible = False;
    UsageCategory = None;
    SourceTable = "NPR Vipps Mp Store";

    layout
    {
        area(Content)
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
            field("Client Id"; Rec."Client Id")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Client Id is part of the credential info used to obtain access to Vipps Mobilepay service';
#if NOT BC17
                AboutTitle = 'Client Id';
                AboutText = 'Client Id is part of the credential info used to obtain access to Vipps Mobilepay service';
#endif
            }
            field("Client Secret"; Rec."Client Secret")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Client Secret is part of the credential info used to obtain access to Vipps Mobilepay service';
#if NOT BC17
                AboutTitle = 'Client Secret';
                AboutText = 'Client Secret is part of the credential info used to obtain access to Vipps Mobilepay service';
#endif
            }
            field("Client Sub. Key"; Rec."Client Sub. Key")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Client Subscription Key is part of the credential info used to obtain access to Vipps Mobilepay service';
#if NOT BC17
                AboutTitle = 'Client Subscription Key';
                AboutText = 'Client Subscription Key is part of the credential info used to obtain access to Vipps Mobilepay service';
#endif
            }
            field("Webhook Reference"; Rec."Webhook Reference")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Webhook reference, is the reference to which webhook is used for this store.';
#if NOT BC17
                AboutTitle = 'Webhook reference';
                AboutText = 'Webhook reference, is the reference to which webhook is used for this store.';
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

    trigger OnClosePage()
    var
        VippsMpMgtAPI: Codeunit "NPR Vipps Mp Mgt. API";
        Json: JsonObject;
        tok: JsonToken;
    begin
        if (Rec.Sandbox) then
            exit;
        VippsMpMgtAPI.GetSalesUnitDetailsMsn(Rec, Json);
        Json.Get('name', tok);
#pragma warning disable AA0139
        Rec."Store Name" := tok.AsValue().AsText();
#pragma warning restore AA0139
        Rec.Modify();
    end;
}