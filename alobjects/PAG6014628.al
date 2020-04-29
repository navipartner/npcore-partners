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
                field(Name;Name)
                {
                }
                field("Data Type";"Data Type")
                {
                    Editable = false;
                }
                field(Value;Value)
                {
                }
            }
        }
    }

    actions
    {
    }
}

