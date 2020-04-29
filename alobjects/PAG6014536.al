page 6014536 "Scanner - Field Setup"
{
    Caption = 'Scanner - Field Setup';
    PageType = ListPart;
    SourceTable = "Scanner - Field Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Order";Order)
                {
                }
                field(Prefix;Prefix)
                {
                    Caption = 'Prefix';
                }
                field(Type;Type)
                {
                }
                field(Postfix;Postfix)
                {
                }
                field(Padding;Padding)
                {
                    Caption = 'Padding';
                }
                field(Position;Position)
                {
                }
                field(Length;Length)
                {
                    Caption = 'Length';
                }
            }
        }
    }

    actions
    {
    }
}

