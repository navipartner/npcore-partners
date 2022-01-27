page 6151125 "NPR NpIa Item AddOns"
{
    Extensible = False;
    Caption = 'Item AddOns';
    CardPageID = "NPR NpIa Item AddOn Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpIa Item AddOn";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the number of the involved entry or record.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies a description of the item.';
                    ApplicationArea = NPRRetail;
                }
                field(Enabled; Rec.Enabled)
                {

                    ToolTIp = 'Specifies if the current Item AddOn is enabled.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

