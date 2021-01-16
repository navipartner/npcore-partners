page 6151125 "NPR NpIa Item AddOns"
{
    Caption = 'Item AddOns';
    CardPageID = "NPR NpIa Item AddOn Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpIa Item AddOn";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the involved entry or record.';                    
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the item.';                    
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTIp = 'Specifies if the current Item AddOn is enabled.';                    
                }
            }
        }
    }
}

