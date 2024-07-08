page 6184504 "NPR EFT Adyen Paym. Type Setup"
{
    Extensible = False;
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
                field("Transaction Condition"; Rec."Transaction Condition")
                {

                    ToolTip = 'Specifies the value of the Transaction Condition field';
                    ApplicationArea = NPRRetail;
                }
                field("Log Level"; Rec."Log Level")
                {

                    ToolTip = 'Specifies the value of the Log Level field';
                    ApplicationArea = NPRRetail;
                }
                field("Capture Delay Hours"; Rec."Capture Delay Hours")
                {

                    ToolTip = 'Specifies the value of the Capture Delay Hours field';
                    ApplicationArea = NPRRetail;
                }
                field("Cashback Allowed"; Rec."Cashback Allowed")
                {

                    ToolTip = 'Specifies the value of the Cashback Allowed field';
                    ApplicationArea = NPRRetail;
                }
            }

            group(Cloud)
            {
                Caption = 'Cloud Integration';
                Visible = _IsCloud;

                field("API Key"; Rec."API Key")
                {

                    ToolTip = 'Specifies the value of the API Key field';
                    ApplicationArea = NPRRetail;
                }
                field(Environment; Rec.Environment)
                {

                    ToolTip = 'Specifies the value of the Environment field';
                    ApplicationArea = NPRRetail;
                }
            }

            group(Local)
            {
                Caption = 'Local Integration';
                Visible = not _IsCloud;

                field("Local Key Identifier"; Rec."Local Key Identifier")
                {
                    ToolTip = 'Specifies the value of the Local Key Identifier field';
                    ApplicationArea = NPRRetail;
                }
                field("Local Key Passphrase"; Rec."Local Key Passphrase")
                {
                    ToolTip = 'Specifies the value of the Local Key Passphrase field';
                    ApplicationArea = NPRRetail;
                }
                field("Local Key Version"; Rec."Local Key Version")
                {
                    ToolTip = 'Specifies the value of the Local Key Version field';
                    ApplicationArea = NPRRetail;
                }
            }

            group(Loyalty)
            {
                Caption = 'Customer Loyalty';
                field("Merchant Account"; Rec."Merchant Account")
                {
                    ToolTip = 'Specifies the value of the Merchant Account field';
                    ApplicationArea = NPRRetail;
                }
                field("Create Recurring Contract"; Rec."Create Recurring Contract")
                {
                    ToolTip = 'Specifies the value of the Create Recurring Contract field';
                    ApplicationArea = NPRRetail;
                }
                field("Acquire Card First"; Rec."Acquire Card First")
                {
                    ToolTip = 'Specifies the value of the Acquire Card First field';
                    ApplicationArea = NPRRetail;
                }
                field("Silent Discount Allowed"; Rec."Silent Discount Allowed")
                {
                    ToolTip = 'Specifies the value of the Silent Discount Allowed field';
                    ApplicationArea = NPRRetail;
                }
                field("Recurring API URL Prefix"; Rec."Recurring API URL Prefix")
                {
                    ToolTip = 'Specifies the value of the Recurring API URL Prefix field';
                    ApplicationArea = NPRRetail;
                }
            }


        }
    }

    actions
    {
    }
    procedure SetCloud(IsCloud: Boolean)
    begin
        _IsCloud := IsCloud;
    end;


    var
        _IsCloud: Boolean;
}