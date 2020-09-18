page 6014628 "NPR RP Device Settings"
{
    Caption = 'Device Settings';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;
    ShowFilter = false;
    SourceTable = "NPR RP Device Settings";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field("Data Type"; "Data Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Value; Value)
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

