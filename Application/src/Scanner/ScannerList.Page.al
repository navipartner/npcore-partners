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
                    ToolTip = 'Specifies the value of the Scanner ID field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Port; Port)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Connected on port field';
                }
            }
        }
    }

    actions
    {
    }
}

