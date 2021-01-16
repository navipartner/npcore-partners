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
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Merchant Account field';
                }
                field("API Key"; "API Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the API Key field';
                }
                field(Environment; Environment)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Environment field';
                }
                field("Transaction Condition"; "Transaction Condition")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction Condition field';
                }
                field("Create Recurring Contract"; "Create Recurring Contract")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Recurring Contract field';
                }
                field("Acquire Card First"; "Acquire Card First")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Acquire Card First field';
                }
                field("Log Level"; "Log Level")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Log Level field';
                }
                field("Silent Discount Allowed"; "Silent Discount Allowed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Silent Discount Allowed field';
                }
                field("Capture Delay Hours"; "Capture Delay Hours")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Capture Delay Hours field';
                }
                field("Cashback Allowed"; "Cashback Allowed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cashback Allowed field';
                }
                field("Recurring API URL Prefix"; "Recurring API URL Prefix")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Recurring API URL Prefix field';
                }
                field(Unattended; Unattended)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unattended field';
                }
            }
        }
    }

    actions
    {
    }
}

