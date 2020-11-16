page 6184486 "NPR Pepper Card Type Fees"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created

    Caption = 'Pepper Card Type Fees';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Pepper Card Type Fee";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Card Type Code"; "Card Type Code")
                {
                    ApplicationArea = All;
                }
                field("Minimum Amount"; "Minimum Amount")
                {
                    ApplicationArea = All;
                }
                field("Merchant Fee %"; "Merchant Fee %")
                {
                    ApplicationArea = All;
                }
                field("Merchant Fee Amount"; "Merchant Fee Amount")
                {
                    ApplicationArea = All;
                }
                field("Customer Surcharge %"; "Customer Surcharge %")
                {
                    ApplicationArea = All;
                }
                field("Customer Surcharge Amount"; "Customer Surcharge Amount")
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

