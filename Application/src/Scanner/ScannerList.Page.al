page 6014537 "NPR Scanner - List"
{
    Caption = 'Scanner - List';
    CardPageID = "NPR Scanner - Setup";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Scanner - Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ID; ID)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Port; Port)
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

