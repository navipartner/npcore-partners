page 6060044 "NPR Item Worksh.Vrty. Values"
{
    Extensible = False;
    Caption = 'Item Worksheet Variety Values';
    PageType = List;
    SourceTable = "NPR Item Worksh. Variety Value";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table"; Rec.Table)
                {

                    ToolTip = 'Specifies the value of the Table field.';
                    ApplicationArea = NPRRetail;
                }
                field("Sort Order"; Rec."Sort Order")
                {

                    ToolTip = 'Specifies the value of the Sort Order field.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

}

