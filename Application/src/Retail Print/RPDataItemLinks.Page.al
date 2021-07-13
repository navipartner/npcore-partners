page 6014562 "NPR RP Data Item Links"
{
    // NPR5.47/MMV /20181017 CASE 318084 Added field 19

    Caption = 'Data Item Links';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;

    ShowFilter = false;
    SourceTable = "NPR RP Data Item Links";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Parent Field ID"; Rec."Parent Field ID")
                {

                    Enabled = Rec."Filter Type" = 0;
                    Style = Subordinate;
                    StyleExpr = Rec."Filter Type" <> 0;
                    ToolTip = 'Specifies the value of the Parent Field ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Parent Field Name"; Rec."Parent Field Name")
                {

                    Enabled = Rec."Filter Type" = 0;
                    Style = Subordinate;
                    StyleExpr = Rec."Filter Type" <> 0;
                    ToolTip = 'Specifies the value of the Parent Field Name field';
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

