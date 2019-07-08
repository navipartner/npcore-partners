page 6150656 "POS Payment Line List"
{
    // NPR5.36/BR  /20170810  CASE  277096 Object created

    Caption = 'POS Payment Line List';
    Editable = false;
    PageType = List;
    SourceTable = "POS Payment Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Entry No.";"POS Entry No.")
                {
                }
                field("POS Store Code";"POS Store Code")
                {
                }
                field("POS Unit No.";"POS Unit No.")
                {
                }
                field("Document No.";"Document No.")
                {
                }
                field("Line No.";"Line No.")
                {
                }
                field("POS Period Register No.";"POS Period Register No.")
                {
                }
                field("POS Payment Method Code";"POS Payment Method Code")
                {
                }
                field("POS Payment Bin Code";"POS Payment Bin Code")
                {
                }
                field(Description;Description)
                {
                }
                field(Amount;Amount)
                {
                }
                field("Currency Code";"Currency Code")
                {
                }
                field("Amount (Sales Currency)";"Amount (Sales Currency)")
                {
                }
                field("Amount (LCY)";"Amount (LCY)")
                {
                }
            }
        }
    }

    actions
    {
    }
}

