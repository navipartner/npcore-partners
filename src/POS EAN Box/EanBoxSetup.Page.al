page 6060100 "NPR Ean Box Setup"
{
    // NPR4.02/JC  /20150319  CASE 207094 Data collect for Customer, Vendor and Item
    // NPR4.10/JC  /20150422  CASE 207094 Added Description Field
    // NPR5.45/MHA /20180814  CASE 319706 Reworked this unused page "Data Cleanup GCVI" to be included in Ean Box Event Handler

    Caption = 'Ean Box Setup';
    SourceTable = "NPR Ean Box Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("POS View"; "POS View")
                {
                    ApplicationArea = All;
                }
            }
            part(Control6014402; "NPR Ean Box Setup Events")
            {
                SubPageLink = "Setup Code" = FIELD(Code);
            }
        }
    }

    actions
    {
    }

    var
        ShowDeleteFields: Boolean;
        ShowRenameFields: Boolean;
}

