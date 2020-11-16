page 6151561 "NPR NpXml Field Value Buffer"
{
    // NC1.08/MH/20150310  CASE 206395 Object created
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect

    Caption = 'NpXml Field Value Buffer';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR NpXml Field Val. Buffer";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Description; Description)
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

