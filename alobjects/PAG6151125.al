page 6151125 "NpIa Item AddOns"
{
    // NPR5.44/MHA /20180629  CASE 286547 Object created - Item AddOn

    Caption = 'Item AddOns';
    CardPageID = "NpIa Item AddOn Card";
    Editable = false;
    PageType = List;
    SourceTable = "NpIa Item AddOn";
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

