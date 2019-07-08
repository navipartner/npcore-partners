page 6150654 "POS Payment Line Subpage"
{
    // NPR5.36/BR  /20170808  CASE  277096 Object created
    // NPR5.38/BR  /20171108 CASE 294720 Added field External Doc. No.
    // NPR5.41/TSA /20180425 CASE 312784 Added Page Action ShowDimensions
    // NPR5.50/TSA /20190520 CASE 354832 Added VAT amount fields

    Caption = 'POS Payment Line Subpage';
    Editable = false;
    PageType = ListPart;
    SourceTable = "POS Payment Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
                field("Amount (LCY)";"Amount (LCY)")
                {
                }
                field("Amount (Sales Currency)";"Amount (Sales Currency)")
                {
                }
                field("External Document No.";"External Document No.")
                {
                }
                field("VAT Amount (LCY)";"VAT Amount (LCY)")
                {
                }
                field("VAT Base Amount (LCY)";"VAT Base Amount (LCY)")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ShowDimensions)
            {
                Caption = 'Dimensions';
                Image = Dimensions;

                trigger OnAction()
                begin
                    //-NPR5.38 [294717]
                    ShowDimensions;
                    //+NPR5.38 [294717]
                end;
            }
        }
    }
}

