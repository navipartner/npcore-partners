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
                field("Data Item Name"; Rec."Data Item Name")
                {
                    ApplicationArea = All;
                    Enabled = Rec."Filter Type" = 0;
                    Style = Subordinate;
                    StyleExpr = Rec."Filter Type" <> 0;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Data Item Name field';
                }
                field("Data Item Field ID"; Rec."Data Item Field ID")
                {
                    ApplicationArea = All;
                    Enabled = Rec."Filter Type" = 0;
                    Style = Subordinate;
                    StyleExpr = Rec."Filter Type" <> 0;
                    ToolTip = 'Specifies the value of the Data Item Field ID field';
                }
                field("Data Item Field Name"; Rec."Data Item Field Name")
                {
                    ApplicationArea = All;
                    Enabled = Rec."Filter Type" = 0;
                    Style = Subordinate;
                    StyleExpr = Rec."Filter Type" <> 0;
                    ToolTip = 'Specifies the value of the Data Item Field Name field';
                }
                field("Filter Type"; Rec."Filter Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Filter Type field';
                }
                field("Field ID"; Rec."Field ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field ID field';
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Name field';
                }
                field("Filter Value"; Rec."Filter Value")
                {
                    ApplicationArea = All;
                    Enabled = Rec."Filter Type" <> 0;
                    ToolTip = 'Specifies the value of the Filter Value field';
                }
                field("Link Type"; Rec."Link Type")
                {
                    ApplicationArea = All;
                    Enabled = Rec."Filter Type" = 0;
                    Style = Subordinate;
                    StyleExpr = Rec."Filter Type" <> 0;
                    ToolTip = 'Specifies the value of the Link Type field';
                }
            }
        }
    }

    actions
    {
    }
}

