page 6060164 "NPR Event Attr. Column Values"
{
    AutoSplitKey = true;
    Caption = 'Attribute Column Values';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Event Attr. Column Value";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Include in Formula"; Rec."Include in Formula")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Include in Formula field';
                }
                field(Promote; Rec.Promote)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Promote field';
                }
            }
        }
    }
}

