page 6014562 "NPR RP Data Item Links"
{
    Extensible = False;
    Caption = 'Data Item Links';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = None;
    ShowFilter = false;
    SourceTable = "NPR RP Data Item Links";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Parent Link On"; Rec."Parent Link On")
                {
                    Enabled = Rec."Filter Type" = Rec."Filter Type"::TableLink;
                    Style = Subordinate;
                    StyleExpr = Rec."Filter Type" <> Rec."Filter Type"::TableLink;
                    ToolTip = 'Specifies the value of the Parent Link On field';
                    ApplicationArea = NPRRetail;
                }
                field("Parent Field ID"; Rec."Parent Field ID")
                {
                    Enabled = (Rec."Filter Type" = Rec."Filter Type"::TableLink) and (Rec."Parent Link On" = Rec."Parent Link On"::Field);
                    Style = Subordinate;
                    StyleExpr = (Rec."Filter Type" <> Rec."Filter Type"::TableLink) or (Rec."Parent Link On" <> Rec."Parent Link On"::Field);
                    ToolTip = 'Specifies the value of the Parent Field ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Parent Field Name"; Rec."Parent Field Name")
                {
                    Enabled = (Rec."Filter Type" = Rec."Filter Type"::TableLink) and (Rec."Parent Link On" = Rec."Parent Link On"::Field);
                    Style = Subordinate;
                    StyleExpr = (Rec."Filter Type" <> Rec."Filter Type"::TableLink) or (Rec."Parent Link On" <> Rec."Parent Link On"::Field);
                    ToolTip = 'Specifies the value of the Parent Field Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Filter Type"; Rec."Filter Type")
                {
                    ToolTip = 'Specifies the value of the Filter Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Link On"; Rec."Link On")
                {
                    Enabled = Rec."Filter Type" = Rec."Filter Type"::TableLink;
                    Style = Subordinate;
                    StyleExpr = Rec."Filter Type" <> Rec."Filter Type"::TableLink;
                    ToolTip = 'Specifies the value of the Link On field';
                    ApplicationArea = NPRRetail;
                }
                field("Field ID"; Rec."Field ID")
                {
                    Enabled = Rec."Link On" = Rec."Link On"::Field;
                    Style = Subordinate;
                    StyleExpr = Rec."Link On" <> Rec."Link On"::Field;
                    ToolTip = 'Specifies the value of the Field ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Field Name"; Rec."Field Name")
                {
                    Enabled = Rec."Link On" = Rec."Link On"::Field;
                    Style = Subordinate;
                    StyleExpr = Rec."Link On" <> Rec."Link On"::Field;
                    ToolTip = 'Specifies the value of the Field Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Filter Value"; Rec."Filter Value")
                {
                    Enabled = Rec."Filter Type" <> Rec."Filter Type"::TableLink;
                    ToolTip = 'Specifies the value of the Filter Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Link Type"; Rec."Link Type")
                {
                    Enabled = (Rec."Filter Type" = Rec."Filter Type"::TableLink) and (Rec."Parent Link On" = Rec."Parent Link On"::Field) and (Rec."Link On" = Rec."Link On"::Field);
                    Style = Subordinate;
                    StyleExpr = (Rec."Filter Type" <> Rec."Filter Type"::TableLink) or (Rec."Parent Link On" <> Rec."Parent Link On"::Field) or (Rec."Link On" <> Rec."Link On"::Field);
                    ToolTip = 'Specifies the value of the Link Type field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
