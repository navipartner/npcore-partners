page 6060010 "GIM - Data Format Card"
{
    Caption = 'GIM - Data Format Card';
    PageType = Card;
    SourceTable = "GIM - Data Format";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
            }
            group(CSV)
            {
                field("CSV Field Delimiter";"CSV Field Delimiter")
                {
                    Caption = 'Field Delimiter';
                }
                field("CSV Field Separator";"CSV Field Separator")
                {
                    Caption = 'Field Separator';
                }
                field("CSV First Data Row";"CSV First Data Row")
                {
                    Caption = 'First Data Row';
                }
            }
            group(Excel)
            {
                field("Excel First Data Row";"Excel First Data Row")
                {
                    Caption = 'First Data Row';
                }
            }
        }
    }

    actions
    {
    }
}

