page 6014478 "RFID Setup"
{
    // NPR5.48/JAVA/20190205  CASE 327107 Transport NPR5.48 - 5 February 2019

    Caption = 'RFID Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "RFID Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("RFID Value No. Series";"RFID Value No. Series")
                {
                }
                field("RFID Hex Value Length";"RFID Hex Value Length")
                {
                }
                field("RFID Hex Value Prefix";"RFID Hex Value Prefix")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
          Init;
          Insert;
        end;
    end;
}

