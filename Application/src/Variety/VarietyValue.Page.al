page 6059973 "NPR Variety Value"
{
    Caption = 'Variety Value';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Variety Value";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Table"; Table)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Table field';
                }
                field(Value; Value)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Value field';
                }
                field("Sort Order"; "Sort Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sort Order field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
        }
    }

    actions
    {
    }
}

