page 6184529 "NPR HU EInvoice Local. Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'HU E-Invoice Localisation Setup';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR HU EInvoice Local. Setup";
    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                Caption = 'General settings';
                field("Enable HU EInvoice Local"; Rec."Enable HU EInvoice Local")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Enable HU E-Invoice Localisation field.';
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}