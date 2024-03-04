table 6150781 "NPR Vipps Mp Store"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Vipps Mobilepay Store';
    Extensible = false;
    LookupPageId = "NPR Vipps Mp Store";

    fields
    {
        field(1; "Merchant Serial Number"; Text[10])
        {
            Caption = 'Merchant Serial Number (MSN)';
            DataClassification = CustomerContent;
        }
        field(2; "Store Name"; Text[100])
        {
            Caption = 'Store Name';
            DataClassification = CustomerContent;
        }
        field(3; "Client Id"; Text[50])
        {
            Caption = 'Client Id';
            DataClassification = CustomerContent;
        }
        field(4; "Client Secret"; Text[50])
        {
            Caption = 'Client Secret';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(5; "Client Sub. Key"; Text[50])
        {
            Caption = 'Client Subscription key';
            DataClassification = CustomerContent;
        }
        field(6; "Webhook Reference"; Text[250])
        {
            Caption = 'Webhook Reference';
            DataClassification = CustomerContent;
            TableRelation = "NPR Vipps Mp Webhook";

            trigger OnLookup()
            var
                VippsMpWebhook: Record "NPR Vipps Mp Webhook";
                VippsMpSetupState: Codeunit "NPR Vipps Mp SetupState";
            begin
                VippsMpSetupState.SetCurrentMsn(Rec."Merchant Serial Number");
                if (Page.RunModal(Page::"NPR Vipps Mp Webhook List", VippsMpWebhook) = Action::LookupOK) then begin
                    "Webhook Reference" := VippsMpWebhook."Webhook Reference";
                end;
            end;
        }
        field(7; "Partner API Enabled"; Boolean)
        {
            Caption = 'Partner API Enabled';
            DataClassification = CustomerContent;
        }
        field(8; Sandbox; Boolean)
        {
            Caption = 'Use Sandbox.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                VippsMpAccessTokenAPI: Codeunit "NPR Vipps Mp AccessToken API";
            begin
                VippsMpAccessTokenAPI.ClearCachedAccessTokens();
            end;
        }
    }
}
