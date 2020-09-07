page 6150654 "NPR POS Paym. Line Subpage"
{
    // NPR5.36/BR  /20170808  CASE  277096 Object created
    // NPR5.38/BR  /20171108 CASE 294720 Added field External Doc. No.
    // NPR5.41/TSA /20180425 CASE 312784 Added Page Action ShowDimensions
    // NPR5.50/TSA /20190520 CASE 354832 Added VAT amount fields

    Caption = 'POS Payment Line Subpage';
    Editable = false;
    PageType = ListPart;
    SourceTable = "NPR POS Payment Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Payment Method Code"; "POS Payment Method Code")
                {
                    ApplicationArea = All;
                }
                field("POS Payment Bin Code"; "POS Payment Bin Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                }
                field("Amount (LCY)"; "Amount (LCY)")
                {
                    ApplicationArea = All;
                }
                field("Amount (Sales Currency)"; "Amount (Sales Currency)")
                {
                    ApplicationArea = All;
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = All;
                }
                field("VAT Amount (LCY)"; "VAT Amount (LCY)")
                {
                    ApplicationArea = All;
                }
                field("VAT Base Amount (LCY)"; "VAT Base Amount (LCY)")
                {
                    ApplicationArea = All;
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
                ApplicationArea=All;

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

