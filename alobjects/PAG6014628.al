page 6014628 "RP Device Settings"
{
    Caption = 'Device Settings';
    DelayedInsert = true;
    PageType = List;
    ShowFilter = false;
    SourceTable = "RP Device Settings";

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

