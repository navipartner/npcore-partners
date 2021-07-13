page 6060164 "NPR Event Attr. Column Values"
{
    AutoSplitKey = true;
    Caption = 'Attribute Column Values';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Event Attr. Column Value";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Line No."; Rec."Line No.")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Include in Formula"; Rec."Include in Formula")
                {

                    ToolTip = 'Specifies the value of the Include in Formula field';
                    ApplicationArea = NPRRetail;
                }
                field(Promote; Rec.Promote)
                {

                    ToolTip = 'Specifies the value of the Promote field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

