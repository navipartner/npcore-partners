page 6184887 "NPR NP Pay POS Payment Setup"
{
    PageType = Card;
    UsageCategory = None;
    Extensible = false;
    SourceTable = "NPR NP Pay POS Payment Setup";
    Caption = 'NP Pay POS Payment Setup';

    layout
    {
        area(Content)
        {
            field("Code"; Rec.Code)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Code';
                ToolTip = 'Specifies the code for this NP Pay POS Payment Setup.';
            }
            field("Merchant Account"; Rec."Merchant Account")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Merchant Account';
                ToolTip = 'Specifies which Merchant Account should be used for the payment setup.';
            }
            field("API Key"; _ApiKey)
            {
                ApplicationArea = NPRRetail;
                Caption = 'API Key';
                ToolTip = 'Specifies the API key used for accessing NP Pay APIs.';
                ExtendedDatatype = Masked;

                trigger OnValidate()
                begin
                    if (_ApiKey = '') then
                        Rec.DeleteAPIKey()
                    else begin
                        Rec.SetAPIKey(_ApiKey);
                        Rec.Modify();
                    end;
                end;
            }
            field(Environment; Rec.Environment)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Environment';
                ToolTip = 'Specifies which environment to use for the payment setup. Live is for production.';
            }
            field("Encryption Key Id"; Rec."Encryption Key Id")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Encryption Key ID';
                ToolTip = 'Specifies the ID of the Encryption Key.';
            }
            field("Encryption Key Version"; Rec."Encryption Key Version")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Encryption Key Version';
                ToolTip = 'Specifies the version of the Encryption Key.';
            }
            field("Encryption Key Password"; Rec."Encryption Key Password")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Encryption Key Password';
                ToolTip = 'Specifies the Encryption Key Password/passphrase.';
            }
        }
    }

    trigger OnOpenPage()
    begin
        if Rec.HasAPIKey() then
            _ApiKey := '***';
    end;

    var
        _ApiKey: Text;
}