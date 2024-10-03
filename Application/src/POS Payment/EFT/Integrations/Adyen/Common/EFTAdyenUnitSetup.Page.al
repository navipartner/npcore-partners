page 6150838 "NPR EFT Adyen Unit Setup"
{
    Extensible = False;
    Caption = 'EFT Adyen POS Unit Setup';
    DelayedInsert = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Card;
    UsageCategory = None;
    ShowFilter = false;
    SourceTable = "NPR EFT Adyen Unit Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRRetail;
                    Enabled = False;
                    ToolTip = 'The POS Unit for this configuration';
                }
            }
            group("Cloud Unit Setup")
            {
                Visible = _IsCloud;
                field(CloudPOIID; Rec.POIID)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'POI ID';
                    ToolTip = 'Specify the unique identifier of the terminal. Format: [device model]-[serial number].';
                }
            }
            group("LAN Unit Setup")
            {
                Visible = not _IsCloud;

                field(LANPOITID; Rec.POIID)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'POI ID';
                    ToolTip = 'Specify the unique identifier of the terminal. Format: [device model]-[serial number].';
                }
                field(TerminalIP; Rec."Terminal LAN IP")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'LAN IP';
                    ToolTip = 'Specify the IP of the adyen terminal on the same LAN as the POS device. Do not specify the http protcol prefix or the port postfix.';
                }
            }

        }

    }

    procedure SetCloud()
    begin
        _IsCloud := True;
    end;

    procedure SetLan()
    begin
        _IsCloud := False;
    end;


    var
        _IsCloud: Boolean;
}