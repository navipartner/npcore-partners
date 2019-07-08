page 6060021 "GIM - Mail List"
{
    Caption = 'GIM - Mail List';
    CardPageID = "GIM - Mail";
    Editable = false;
    PageType = List;
    SourceTable = "GIM - Mail Header";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Sender ID";"Sender ID")
                {
                }
                field("Process Code";"Process Code")
                {
                }
                field(Description;Description)
                {
                }
                field(Status;Status)
                {
                }
                field("To";"To")
                {
                }
            }
        }
    }

    actions
    {
    }
}

