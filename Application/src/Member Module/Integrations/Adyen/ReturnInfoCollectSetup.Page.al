page 6150857 "NPR Return Info Collect Setup"
{
    Extensible = False;
    ApplicationArea = NPRRetail;
    Caption = 'Return Information Collection Setup';
    PageType = Card;
    SourceTable = "NPR Return Info Collect Setup";
    UsageCategory = Administration;
    DelayedInsert = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    LinksAllowed = false;
    ShowFilter = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Collect Signature"; Rec."Collect Signature")
                {
                    ToolTip = 'Specifies the value of the Collect Signature field.';
                    ApplicationArea = NPRRetail;
                }
                field("Collect Phone No."; Rec."Collect Phone No.")
                {
                    ToolTip = 'Specifies the value of the Collect Phone No. field.';
                    ApplicationArea = NPRRetail;
                }
                field("Collect E-Mail"; Rec."Collect E-Mail")
                {
                    ToolTip = 'Specifies the value of the Collect E-Mail field.';
                    ApplicationArea = NPRRetail;
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
                                AdyenManagement.TestReturnInfoCollectSetupApiKey(Rec.Environment);
                        end;
                    end;
                }
                field(Environment; Rec.Environment)
                {
                    ToolTip = 'Specifies the value of the Environment field.';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Device Settings")
            {
                part("Return Info Device Settings"; "NPR ReturnInfo Device Settings")
                {
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
        if (Rec.HasAPIKey()) then
            _APISecretKey := '***';
    end;

    var
        _APISecretKey: Text;
}
