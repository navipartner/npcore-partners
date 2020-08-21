page 6150733 "POS Sales Workflow Set Card"
{
    // NPR5.45/MHA /20180820  CASE 321266 Object created

    Caption = 'POS Sales Workflow Set Card';
    PageType = Card;
    SourceTable = "POS Sales Workflow Set";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
            }
            part(Control6014404; "POS Sales Workflow Set Entries")
            {
                SubPageLink = "Set Code" = FIELD(Code);
            }
        }
    }

    actions
    {
    }
}

