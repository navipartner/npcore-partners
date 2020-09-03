page 6151125 "NPR NpIa Item AddOns"
{
    // NPR5.44/MHA /20180629  CASE 286547 Object created - Item AddOn

    Caption = 'Item AddOns';
    CardPageID = "NPR NpIa Item AddOn Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpIa Item AddOn";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

