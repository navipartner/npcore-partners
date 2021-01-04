page 6150654 "NPR POS Paym. Line Subpage"
{
    // NPR5.36/BR  /20170808  CASE  277096 Object created
    // NPR5.38/BR  /20171108 CASE 294720 Added field External Doc. No.
    // NPR5.41/TSA /20180425 CASE 312784 Added Page Action ShowDimensions
    // NPR5.50/TSA /20190520 CASE 354832 Added VAT amount fields

    Caption = 'POS Payment Line Subpage';
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;
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
                    ToolTip = 'Specifies the value of the POS Payment Method Code field';
                }
                field("POS Payment Bin Code"; "POS Payment Bin Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Payment Bin Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Paid Currency Code field';
                }
                field("Amount (LCY)"; "Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount (LCY) field';
                }
                field("Amount (Sales Currency)"; "Amount (Sales Currency)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount (Sales Currency) field';
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Document No. field';
                }
                field("VAT Amount (LCY)"; "VAT Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Amount (LCY) field';
                }
                field("VAT Base Amount (LCY)"; "VAT Base Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Base Amount field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Dimensions action';

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

