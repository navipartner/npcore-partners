page 6059973 "NPR Variety Value"
{
    Caption = 'Variety Value';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Variety Value";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Table"; Rec.Table)
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Table field';
                    ApplicationArea = NPRRetail;
                }
                field(Value; Rec.Value)
                {

                    ToolTip = 'Specifies the value of the Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Sort Order"; Rec."Sort Order")
                {

                    ToolTip = 'Specifies the value of the Sort Order field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

