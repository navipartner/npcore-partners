page 6014643 "NPR RP Data Item Constr. Links"
{
    Extensible = False;
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
                    Enabled = Rec."Filter Type" = Rec."Filter Type"::TableLink;
                    Style = Subordinate;
                    StyleExpr = Rec."Filter Type" <> Rec."Filter Type"::TableLink;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Data Item Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Data Item Link On"; Rec."Data Item Link On")
                {
                    Enabled = Rec."Filter Type" = Rec."Filter Type"::TableLink;
                    Style = Subordinate;
                    StyleExpr = Rec."Filter Type" <> Rec."Filter Type"::TableLink;
                    ToolTip = 'Specifies the value of the Data Item Link On field';
                    ApplicationArea = NPRRetail;
                }
                field("Data Item Field ID"; Rec."Data Item Field ID")
                {
                    Enabled = (Rec."Filter Type" = Rec."Filter Type"::TableLink) and (Rec."Data Item Link On" = Rec."Data Item Link On"::Field);
                    Style = Subordinate;
                    StyleExpr = (Rec."Filter Type" <> Rec."Filter Type"::TableLink) or (Rec."Data Item Link On" <> Rec."Data Item Link On"::Field);
                    ToolTip = 'Specifies the value of the Data Item Field ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Data Item Field Name"; Rec."Data Item Field Name")
                {
                    Enabled = (Rec."Filter Type" = Rec."Filter Type"::TableLink) and (Rec."Data Item Link On" = Rec."Data Item Link On"::Field);
                    Style = Subordinate;
                    StyleExpr = (Rec."Filter Type" <> Rec."Filter Type"::TableLink) or (Rec."Data Item Link On" <> Rec."Data Item Link On"::Field);
                    ToolTip = 'Specifies the value of the Data Item Field Name field';
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
                    Enabled = (Rec."Filter Type" = Rec."Filter Type"::TableLink) and (Rec."Data Item Link On" = Rec."Data Item Link On"::Field) and (Rec."Link On" = Rec."Link On"::Field);
                    Style = Subordinate;
                    StyleExpr = (Rec."Filter Type" <> Rec."Filter Type"::TableLink) or (Rec."Data Item Link On" <> Rec."Data Item Link On"::Field) or (Rec."Link On" <> Rec."Link On"::Field);
                    ToolTip = 'Specifies the value of the Link Type field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
