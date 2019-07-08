page 6014564 "Warranty Cat. Lines"
{
    // NPR5.29/MHA /20161208  CASE 256690 AutoSplitKey set to Yes
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer

    AutoSplitKey = true;
    Caption = 'Warranty Cat. Lines';
    PageType = ListPart;
    SourceTable = "Warranty Line";

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field("Item No.";"Item No.")
                {
                }
                field(Description;Description)
                {
                }
                field("Label No.";"Label No.")
                {
                }
                field("Lock Code";"Lock Code")
                {
                }
                field("Serial No.";"Serial No.")
                {
                }
                field(InsuranceType;InsuranceType)
                {
                }
                field("Insurance send";"Insurance send")
                {
                }
                field("Serial No. not Created";"Serial No. not Created")
                {
                }
                field(Quantity;Quantity)
                {
                }
                field("Unit Price";"Unit Price")
                {
                }
                field(Amount;Amount)
                {
                }
                field("Amount incl. VAT";"Amount incl. VAT")
                {
                }
                field("Discount %";"Discount %")
                {
                }
            }
        }
    }

    actions
    {
    }
}

