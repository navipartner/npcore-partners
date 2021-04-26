page 6151508 "NPR Nc Task Proces. List"
{
    Caption = 'NaviConnect Task Processors';
    CardPageID = "NPR Nc Task Proces. Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Nc Task Processor";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
        }
    }
}

