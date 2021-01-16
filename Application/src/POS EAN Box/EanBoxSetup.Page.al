page 6060100 "NPR Ean Box Setup"
{
    // NPR4.02/JC  /20150319  CASE 207094 Data collect for Customer, Vendor and Item
    // NPR4.10/JC  /20150422  CASE 207094 Added Description Field
    // NPR5.45/MHA /20180814  CASE 319706 Reworked this unused page "Data Cleanup GCVI" to be included in Ean Box Event Handler

    UsageCategory = None;
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
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("POS View"; "POS View")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS View field';
                }
            }
            part(Control6014402; "NPR Ean Box Setup Events")
            {
                SubPageLink = "Setup Code" = FIELD(Code);
                ApplicationArea = All;
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

