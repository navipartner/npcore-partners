page 6014624 "NPR Pmt. Gateways Select"
{
    Caption = 'Payment Gateways';
    PageType = List;
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

    procedure SetRec(var TempPaymentGateway: Record "NPR Magento Payment Gateway")
    begin
        if TempPaymentGateway.FindSet() then
            repeat
                Rec := TempPaymentGateway;
                Rec.Insert();
            until TempPaymentGateway.Next() = 0;
    end;
}