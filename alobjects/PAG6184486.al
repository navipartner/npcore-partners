page 6184486 "Pepper Card Type Fees"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created

    Caption = 'Pepper Card Type Fees';
    PageType = List;
    SourceTable = "Pepper Card Type Fee";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Card Type Code";"Card Type Code")
                {
                }
                field("Minimum Amount";"Minimum Amount")
                {
                }
                field("Merchant Fee %";"Merchant Fee %")
                {
                }
                field("Merchant Fee Amount";"Merchant Fee Amount")
                {
                }
                field("Customer Surcharge %";"Customer Surcharge %")
                {
                }
                field("Customer Surcharge Amount";"Customer Surcharge Amount")
                {
                }
            }
        }
    }

    actions
    {
    }
}

