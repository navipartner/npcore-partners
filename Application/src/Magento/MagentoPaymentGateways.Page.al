page 6151453 "NPR Magento Payment Gateways"
{
    // MAG1.20/MHA /20150826  CASE 219645 Object created
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.01/MHA /20160928  CASE 250694 Added Field 30 "Refund Codeunit Id" and 35 "Cancel Codeunit Id"
    // MAG2.20/MHA /20190502  CASE 352184 Added field 15 "Merchant Name"

    Caption = 'Payment Gateways';
    PageType = List;
    SourceTable = "NPR Magento Payment Gateway";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field("Api Url"; "Api Url")
                {
                    ApplicationArea = All;
                }
                field("Api Username"; "Api Username")
                {
                    ApplicationArea = All;
                }
                field("Api Password"; "Api Password")
                {
                    ApplicationArea = All;
                }
                field("Merchant ID"; "Merchant ID")
                {
                    ApplicationArea = All;
                }
                field("Merchant Name"; "Merchant Name")
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                }
                field("Capture Codeunit Id"; "Capture Codeunit Id")
                {
                    ApplicationArea = All;
                }
                field("Refund Codeunit Id"; "Refund Codeunit Id")
                {
                    ApplicationArea = All;
                }
                field("Cancel Codeunit Id"; "Cancel Codeunit Id")
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

