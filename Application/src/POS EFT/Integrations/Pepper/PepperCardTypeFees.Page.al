page 6184486 "NPR Pepper Card Type Fees"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created

    Caption = 'Pepper Card Type Fees';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Pepper Card Type Fee";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Card Type Code"; Rec."Card Type Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Type Code field';
                }
                field("Minimum Amount"; Rec."Minimum Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Minimum Amount field';
                }
                field("Merchant Fee %"; Rec."Merchant Fee %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Merchant Fee % field';
                }
                field("Merchant Fee Amount"; Rec."Merchant Fee Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Merchant Fee Amount field';
                }
                field("Customer Surcharge %"; Rec."Customer Surcharge %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Surcharge % field';
                }
                field("Customer Surcharge Amount"; Rec."Customer Surcharge Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Surcharge Amount field';
                }
            }
        }
    }

    actions
    {
    }
}

