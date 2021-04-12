page 6184504 "NPR EFT Adyen Paym. Type Setup"
{
    Caption = 'EFT Adyen Payment Type Setup';
    DelayedInsert = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Card;
    UsageCategory = None;
    ShowFilter = false;
    SourceTable = "NPR EFT Adyen Paym. Type Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Merchant Account"; Rec."Merchant Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Merchant Account field';
                }
                field("API Key"; Rec."API Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the API Key field';
                }
                field(Environment; Rec.Environment)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Environment field';
                }
                field("Transaction Condition"; Rec."Transaction Condition")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction Condition field';
                }
                field("Create Recurring Contract"; Rec."Create Recurring Contract")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Recurring Contract field';
                }
                field("Acquire Card First"; Rec."Acquire Card First")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Acquire Card First field';
                }
                field("Log Level"; Rec."Log Level")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Log Level field';
                }
                field("Silent Discount Allowed"; Rec."Silent Discount Allowed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Silent Discount Allowed field';
                }
                field("Capture Delay Hours"; Rec."Capture Delay Hours")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Capture Delay Hours field';
                }
                field("Cashback Allowed"; Rec."Cashback Allowed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cashback Allowed field';
                }
                field("Recurring API URL Prefix"; Rec."Recurring API URL Prefix")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Recurring API URL Prefix field';
                }
                field(Unattended; Rec.Unattended)
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

