page 6014643 "NPR RP Data Item Constr. Links"
{
    // NPR5.47/MMV /20181017 CASE 318084 Added field 12

    AutoSplitKey = true;
    Caption = 'Data Item Constraint Links';
    DelayedInsert = true;
    PageType = ListPart;
    ShowFilter = false;
    SourceTable = "NPR RP Data Item Constr. Links";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Data Item Name"; "Data Item Name")
                {
                    ApplicationArea = All;
                    Enabled = "Filter Type" = 0;
                    Style = Subordinate;
                    StyleExpr = "Filter Type" <> 0;
                    Visible = false;
                }
                field("Data Item Field ID"; "Data Item Field ID")
                {
                    ApplicationArea = All;
                    Enabled = "Filter Type" = 0;
                    Style = Subordinate;
                    StyleExpr = "Filter Type" <> 0;
                }
                field("Data Item Field Name"; "Data Item Field Name")
                {
                    ApplicationArea = All;
                    Enabled = "Filter Type" = 0;
                    Style = Subordinate;
                    StyleExpr = "Filter Type" <> 0;
                }
                field("Filter Type"; "Filter Type")
                {
                    ApplicationArea = All;
                }
                field("Field ID"; "Field ID")
                {
                    ApplicationArea = All;
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                }
                field("Filter Value"; "Filter Value")
                {
                    ApplicationArea = All;
                    Enabled = "Filter Type" <> 0;
                }
                field("Link Type"; "Link Type")
                {
                    ApplicationArea = All;
                    Enabled = "Filter Type" = 0;
                    Style = Subordinate;
                    StyleExpr = "Filter Type" <> 0;
                }
            }
        }
    }

    actions
    {
    }
}

