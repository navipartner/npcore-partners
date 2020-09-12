page 6151507 "NPR Nc Task Proces. Card"
{
    // NC1.22/MHA/20160125 CASE 232733 Object created
    // NC1.22/MHA/20160415 CASE 231214 Added Parameter subform
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect

    Caption = 'NaviConnect Task Processor';
    PageType = Card;
    SourceTable = "NPR Nc Task Processor";

    layout
    {
        area(content)
        {
            group(Generelt)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
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

