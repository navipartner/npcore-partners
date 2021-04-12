page 6151507 "NPR Nc Task Proces. Card"
{
    // NC1.22/MHA/20160125 CASE 232733 Object created
    // NC1.22/MHA/20160415 CASE 231214 Added Parameter subform
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect

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

    actions
    {
    }
}

