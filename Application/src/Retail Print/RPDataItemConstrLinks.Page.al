page 6014643 "NPR RP Data Item Constr. Links"
{
    // NPR5.47/MMV /20181017 CASE 318084 Added field 12

    AutoSplitKey = true;
    Caption = 'Data Item Constraint Links';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Data Item Name field';
                }
                field("Data Item Field ID"; "Data Item Field ID")
                {
                    ApplicationArea = All;
                    Enabled = "Filter Type" = 0;
                    Style = Subordinate;
                    StyleExpr = "Filter Type" <> 0;
                    ToolTip = 'Specifies the value of the Data Item Field ID field';
                }
                field("Data Item Field Name"; "Data Item Field Name")
                {
                    ApplicationArea = All;
                    Enabled = "Filter Type" = 0;
                    Style = Subordinate;
                    StyleExpr = "Filter Type" <> 0;
                    ToolTip = 'Specifies the value of the Data Item Field Name field';
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

