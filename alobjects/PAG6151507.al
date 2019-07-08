page 6151507 "Nc Task Proces. Card"
{
    // NC1.22/MHA/20160125 CASE 232733 Object created
    // NC1.22/MHA/20160415 CASE 231214 Added Parameter subform
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect

    Caption = 'NaviConnect Task Processor';
    PageType = Card;
    SourceTable = "Nc Task Processor";

    layout
    {
        area(content)
        {
            group(Generelt)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
            }
            part(Control6150618;"Nc Task Proces. Lines")
            {
            }
        }
    }

    actions
    {
    }
}

