page 6014564 "NPR Warranty Cat. Lines"
{
    // NPR5.29/MHA /20161208  CASE 256690 AutoSplitKey set to Yes
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer

    AutoSplitKey = true;
    Caption = 'Warranty Cat. Lines';
    PageType = ListPart;
    SourceTable = "NPR Warranty Line";

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Label No."; "Label No.")
                {
                    ApplicationArea = All;
                }
                field("Lock Code"; "Lock Code")
                {
                    ApplicationArea = All;
                }
                field("Serial No."; "Serial No.")
                {
                    ApplicationArea = All;
                }
                field(InsuranceType; InsuranceType)
                {
                    ApplicationArea = All;
                }
                field("Insurance send"; "Insurance send")
                {
                    ApplicationArea = All;
                }
                field("Serial No. not Created"; "Serial No. not Created")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field("Amount incl. VAT"; "Amount incl. VAT")
                {
                    ApplicationArea = All;
                }
                field("Discount %"; "Discount %")
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

