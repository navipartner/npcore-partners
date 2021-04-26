page 6151507 "NPR Nc Task Proces. Card"
{
    Caption = 'NaviConnect Task Processor';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Nc Task Processor";

    layout
    {
        area(content)
        {
            group(Generelt)
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
            part(Control6150618; "NPR Nc Task Proces. Lines")
            {
                ApplicationArea = All;
            }
        }
    }
}

