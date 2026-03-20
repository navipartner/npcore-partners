page 6185080 "NPR QR Code Setup"
{
    Extensible = False;
    Caption = 'QR Code Setup';
    PageType = Card;
    SourceTable = "NPR QR Code Setup Header";
    UsageCategory = None;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies unique identifier for the qr code setup.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(APISecretKey; _APISecretKey)
                {
                    Caption = 'API Key';
                    ToolTip = 'Specifies the value of the API Key field';
                    ApplicationArea = NPRRetail;
                    ExtendedDatatype = Masked;
                    trigger OnValidate()
                    var
                        AdyenManagement: Codeunit "NPR Adyen Management";
                    begin
                        if (_APISecretKey = '') then
                            Rec.DeleteAPIKey()
                        else begin
                            Rec.SetAPIKey(_APISecretKey);
                            Rec.Modify();
                            if Rec.HasAPIKey() then
                                case Rec."Integration Type" of
                                    Rec."Integration Type"::Adyen:
                                        AdyenManagement.TestQRCodeSetupApiKey(Rec.Code, Rec.Environment);
                                end;
                        end;
                    end;
                }
                field(Environment; Rec.Environment)
                {
                    ToolTip = 'Specifies the value of the Environment field.';
                    ApplicationArea = NPRRetail;
                }
                field("Integration Type"; Rec."Integration Type")
                {
                    ToolTip = 'Specifies the value of the Integration Type field.';
                    ApplicationArea = NPRRetail;
                }

            }
            group("QR Code Setup Lines")
            {
                part("QR Code Setup Line"; "NPR QR Code Setup Lines")
                {
                    ApplicationArea = NPRRetail;
                    SubPageLink = "QR Code Setup Header Code" = field(Code);
                    Editable = _HasCode;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        _HasCode := Rec.Code <> '';
        if (Rec.HasAPIKey()) then
            _APISecretKey := '***'
        else
            _APISecretKey := '';
    end;

    trigger OnOpenPage()
    begin
        if (Rec.HasAPIKey()) then
            _APISecretKey := '***';
        _HasCode := Rec.Code <> '';
    end;

    var
        _APISecretKey: Text;
        _HasCode: Boolean;
}
