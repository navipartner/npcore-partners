page 6014562 "NPR RP Data Item Links"
{
    // NPR5.47/MMV /20181017 CASE 318084 Added field 19

    Caption = 'Data Item Links';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    ShowFilter = false;
    SourceTable = "NPR RP Data Item Links";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Parent Field ID"; "Parent Field ID")
                {
                    ApplicationArea = All;
                    Enabled = "Filter Type" = 0;
                    Style = Subordinate;
                    StyleExpr = "Filter Type" <> 0;
                }
                field("Parent Field Name"; "Parent Field Name")
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

