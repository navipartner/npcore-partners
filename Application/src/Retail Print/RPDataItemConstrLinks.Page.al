page 6014643 "NPR RP Data Item Constr. Links"
{
    Extensible = False;
    // NPR5.47/MMV /20181017 CASE 318084 Added field 12

    AutoSplitKey = true;
    Caption = 'Data Item Constraint Links';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = None;
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

                    Enabled = Rec."Filter Type" = 0;
                    Style = Subordinate;
                    StyleExpr = Rec."Filter Type" <> 0;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Data Item Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Data Item Field ID"; Rec."Data Item Field ID")
                {

                    Enabled = Rec."Filter Type" = 0;
                    Style = Subordinate;
                    StyleExpr = Rec."Filter Type" <> 0;
                    ToolTip = 'Specifies the value of the Data Item Field ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Data Item Field Name"; Rec."Data Item Field Name")
                {

                    Enabled = Rec."Filter Type" = 0;
                    Style = Subordinate;
                    StyleExpr = Rec."Filter Type" <> 0;
                    ToolTip = 'Specifies the value of the Data Item Field Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Filter Type"; Rec."Filter Type")
                {

                    ToolTip = 'Specifies the value of the Filter Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Field ID"; Rec."Field ID")
                {

                    ToolTip = 'Specifies the value of the Field ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Field Name"; Rec."Field Name")
                {

                    ToolTip = 'Specifies the value of the Field Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Filter Value"; Rec."Filter Value")
                {

                    Enabled = Rec."Filter Type" <> 0;
                    ToolTip = 'Specifies the value of the Filter Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Link Type"; Rec."Link Type")
                {

                    Enabled = Rec."Filter Type" = 0;
                    Style = Subordinate;
                    StyleExpr = Rec."Filter Type" <> 0;
                    ToolTip = 'Specifies the value of the Link Type field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

