page 6184504 "NPR EFT Adyen Paym. Type Setup"
{
    // NPR5.49/MMV /20190401 CASE 345188 Created object
    // NPR5.49/MMV /20190410 CASE 347476 Added field 7
    // NPR5.50/MMV /20190430 CASE 352465 Added field 8
    // NPR5.51/MMV /20190520 CASE 355433 Added field 9, 10
    // NPR5.53/MMV /20191211 CASE 377533 Added fields 11, 12
    // NPR5.55/MMV /20200421 CASE 386254 Added field 13

    Caption = 'EFT Adyen Payment Type Setup';
    DelayedInsert = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Card;
    UsageCategory = Administration;
    ShowFilter = false;
    SourceTable = "NPR EFT Adyen Paym. Type Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Merchant Account"; "Merchant Account")
                {
                    ApplicationArea = All;
                }
                field("API Key"; "API Key")
                {
                    ApplicationArea = All;
                }
                field(Environment; Environment)
                {
                    ApplicationArea = All;
                }
                field("Transaction Condition"; "Transaction Condition")
                {
                    ApplicationArea = All;
                }
                field("Create Recurring Contract"; "Create Recurring Contract")
                {
                    ApplicationArea = All;
                }
                field("Acquire Card First"; "Acquire Card First")
                {
                    ApplicationArea = All;
                }
                field("Log Level"; "Log Level")
                {
                    ApplicationArea = All;
                }
                field("Silent Discount Allowed"; "Silent Discount Allowed")
                {
                    ApplicationArea = All;
                }
                field("Capture Delay Hours"; "Capture Delay Hours")
                {
                    ApplicationArea = All;
                }
                field("Cashback Allowed"; "Cashback Allowed")
                {
                    ApplicationArea = All;
                }
                field("Recurring API URL Prefix"; "Recurring API URL Prefix")
                {
                    ApplicationArea = All;
                }
                field(Unattended; Unattended)
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

