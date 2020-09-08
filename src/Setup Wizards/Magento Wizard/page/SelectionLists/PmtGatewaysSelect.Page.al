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
                }
                field("Api Url"; "Api Url")
                {
                }
                field("Api Username"; "Api Username")
                {
                }
                field("Api Password"; "Api Password")
                {
                }
                field("Merchant ID"; "Merchant ID")
                {
                }
                field("Merchant Name"; "Merchant Name")
                {
                }
                field("Currency Code"; "Currency Code")
                {
                }
                field("Capture Codeunit Id"; "Capture Codeunit Id")
                {
                }
                field("Refund Codeunit Id"; "Refund Codeunit Id")
                {
                }
                field("Cancel Codeunit Id"; "Cancel Codeunit Id")
                {
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