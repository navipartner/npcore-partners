page 6014478 "NPR RFID Setup"
{
    Extensible = False;
    // NPR5.48/JAVA/20190205  CASE 327107 Transport NPR5.48 - 5 February 2019

    Caption = 'RFID Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR RFID Setup";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("RFID Value No. Series"; Rec."RFID Value No. Series")
                {

                    ToolTip = 'Specifies the value of the RFID Value No. Series field';
                    ApplicationArea = NPRRetail;
                }
                field("RFID Hex Value Length"; Rec."RFID Hex Value Length")
                {

                    ToolTip = 'Specifies the value of the RFID Hex Value Length field';
                    ApplicationArea = NPRRetail;
                }
                field("RFID Hex Value Prefix"; Rec."RFID Hex Value Prefix")
                {

                    ToolTip = 'Specifies the value of the RFID Hex Value Prefix field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}

