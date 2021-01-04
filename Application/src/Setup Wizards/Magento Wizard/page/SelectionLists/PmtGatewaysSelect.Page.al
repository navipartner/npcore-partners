page 6014624 "NPR Pmt. Gateways Select"
{
    Caption = 'Payment Gateways';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Magento Payment Gateway";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Api Url"; "Api Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Api Url field';
                }
                field("Api Username"; "Api Username")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Api Username field';
                }
                field("Api Password"; "Api Password")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Api Password field';
                }
                field("Merchant ID"; "Merchant ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Merchant Id field';
                }
                field("Merchant Name"; "Merchant Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Merchant Name field';
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Code field';
                }
                field("Capture Codeunit Id"; "Capture Codeunit Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Capture codeunit-id field';
                }
                field("Refund Codeunit Id"; "Refund Codeunit Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Refund codeunit-id field';
                }
                field("Cancel Codeunit Id"; "Cancel Codeunit Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cancel Codeunit Id field';
                }
            }
        }
    }

    procedure SetRec(var TempPaymentGateway: Record "NPR Magento Payment Gateway")
    begin
        if TempPaymentGateway.FindSet() then
            repeat
                Rec := TempPaymentGateway;
                Rec.Insert();
            until TempPaymentGateway.Next() = 0;
    end;
}