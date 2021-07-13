page 6184486 "NPR Pepper Card Type Fees"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created

    Caption = 'Pepper Card Type Fees';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Pepper Card Type Fee";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Card Type Code"; Rec."Card Type Code")
                {

                    ToolTip = 'Specifies the value of the Card Type Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Minimum Amount"; Rec."Minimum Amount")
                {

                    ToolTip = 'Specifies the value of the Minimum Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Merchant Fee %"; Rec."Merchant Fee %")
                {

                    ToolTip = 'Specifies the value of the Merchant Fee % field';
                    ApplicationArea = NPRRetail;
                }
                field("Merchant Fee Amount"; Rec."Merchant Fee Amount")
                {

                    ToolTip = 'Specifies the value of the Merchant Fee Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Surcharge %"; Rec."Customer Surcharge %")
                {

                    ToolTip = 'Specifies the value of the Customer Surcharge % field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Surcharge Amount"; Rec."Customer Surcharge Amount")
                {

                    ToolTip = 'Specifies the value of the Customer Surcharge Amount field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

