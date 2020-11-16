page 6059940 "NPR SMS Template List"
{
    // NPR5.26/THRO/20160908 CASE 244114 SMS Module
    // NPR5.40/THRO/20180308 CASE 304312 Added "Report ID"

    Caption = 'SMS Template List';
    CardPageID = "NPR SMS Template Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR SMS Template Header";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                }
                field("Table Caption"; "Table Caption")
                {
                    ApplicationArea = All;
                }
                field("""Table Filters"".HASVALUE"; "Table Filters".HasValue)
                {
                    ApplicationArea = All;
                    Caption = 'Filters on Table';
                }
                field("Report ID"; "Report ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

