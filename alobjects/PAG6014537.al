page 6014537 "Scanner - List"
{
    Caption = 'Scanner - List';
    CardPageID = "Scanner - Setup";
    Editable = false;
    PageType = List;
    SourceTable = "Scanner - Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ID;ID)
                {
                }
                field(Description;Description)
                {
                }
                field(Port;Port)
                {
                }
            }
        }
    }

    actions
    {
    }
}

