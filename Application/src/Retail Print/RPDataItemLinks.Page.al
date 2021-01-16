page 6014562 "NPR RP Data Item Links"
{
    // NPR5.47/MMV /20181017 CASE 318084 Added field 19

    Caption = 'Data Item Links';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Parent Field ID field';
                }
                field("Parent Field Name"; "Parent Field Name")
                {
                    ApplicationArea = All;
                    Enabled = "Filter Type" = 0;
                    Style = Subordinate;
                    StyleExpr = "Filter Type" <> 0;
                    ToolTip = 'Specifies the value of the Parent Field Name field';
                }
                field("Filter Type"; "Filter Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Filter Type field';
                }
                field("Field ID"; "Field ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field ID field';
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Name field';
                }
                field("Filter Value"; "Filter Value")
                {
                    ApplicationArea = All;
                    Enabled = "Filter Type" <> 0;
                    ToolTip = 'Specifies the value of the Filter Value field';
                }
                field("Link Type"; "Link Type")
                {
                    ApplicationArea = All;
                    Enabled = "Filter Type" = 0;
                    Style = Subordinate;
                    StyleExpr = "Filter Type" <> 0;
                    ToolTip = 'Specifies the value of the Link Type field';
                }
            }
        }
    }

    actions
    {
    }
}

