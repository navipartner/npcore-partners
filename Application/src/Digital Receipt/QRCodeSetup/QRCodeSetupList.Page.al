page 6150956 "NPR QR Code Setup List"
{
    Extensible = false;
    ApplicationArea = NPRRetail;
    Caption = 'QR Code Setup List';
    PageType = List;
    Editable = false;
    SourceTable = "NPR QR Code Setup Header";
    CardPageId = "NPR QR Code Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(General)
            {

                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies unique identifier for the qr code setup.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                    ApplicationArea = NPRRetail;
                }
                field("Integration Type"; Rec."Integration Type")
                {
                    ToolTip = 'Specifies the value of the Integration Type field.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
