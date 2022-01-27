page 6151508 "NPR Nc Task Proces. List"
{
    Extensible = False;
    Caption = 'NaviConnect Task Processors';
    CardPageID = "NPR Nc Task Proces. Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Nc Task Processor";
    UsageCategory = Administration;
    ApplicationArea = NPRNaviConnect;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRNaviConnect;
                }
            }
        }
    }
}

