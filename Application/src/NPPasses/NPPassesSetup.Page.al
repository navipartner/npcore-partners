page 6248730 "NPR NP Passes Setup"
{
    Extensible = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    Caption = 'NP Passes Setup';
    PageType = Card;
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    SourceTable = "NPR NP Passes Setup";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether NP Passes is active. Membership types with an NP Passes design cannot issue wallet links while it is disabled; types without a design use the legacy pass server.';

                    trigger OnValidate()
                    var
                        RestartClientMsg: Label 'Other users must restart their client before the change takes effect.';
                    begin
                        Message(RestartClientMsg);
                    end;
                }
                field("Base URL"; Rec."Base URL")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the URL of the np-passes generator. It is used for the wallet links sent to members, not for pass updates.';
                }
                field("Design List URL"; Rec."Design List URL")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the URL of the design list worker. Only visible in sandbox environments; production environments always use the production worker automatically.';
                    Visible = _IsSandbox;
                }
            }
            group(LinkSigning)
            {
                Caption = 'Link Signing';

                field(SigningSecret; _SigningSecret)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Signing Secret';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the shared secret from the np-passes BC connection. Wallet links are signed with it and np-passes rejects links without a valid signature. Required before NP Passes can be enabled; clear the field to remove it while NP Passes is disabled.';

                    trigger OnValidate()
                    begin
                        if (_SigningSecret = SecretPlaceholder()) then
                            exit;
                        if (_SigningSecret = '') then
                            Rec.DeleteSigningSecret()
                        else
                            Rec.SetSigningSecret(_SigningSecret);
                        Rec.Modify();
                        ShowSecretPlaceholder();
                    end;
                }
            }
        }
    }

    var
        [NonDebuggable]
        _SigningSecret: Text;
        _IsSandbox: Boolean;

    trigger OnAfterGetRecord()
    begin
        ShowSecretPlaceholder();
    end;

    local procedure ShowSecretPlaceholder()
    begin
        if (Rec.HasSigningSecret()) then
            _SigningSecret := SecretPlaceholder()
        else
            _SigningSecret := '';
    end;

    local procedure SecretPlaceholder(): Text
    begin
        exit('***');
    end;

    trigger OnOpenPage()
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        _IsSandbox := EnvironmentInformation.IsSaaS() and EnvironmentInformation.IsSandbox();
        if (not Rec.Get()) then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
