page 6060044 "NPR Item Worksh.Vrty. Values"
{
    Caption = 'Item Worksheet Variety Values';
    PageType = List;
    SourceTable = "NPR Item Worksh. Variety Value";
    UsageCategory = Lists;
    ApplicationArea = All; 

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table"; Rec.Table)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table field.';
                }
                field("Sort Order"; Rec."Sort Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sort Order field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.';
                }
            }
        }
    }

}

