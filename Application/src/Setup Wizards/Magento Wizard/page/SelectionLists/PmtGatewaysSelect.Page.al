page 6014624 "NPR Pmt. Gateways Select"
{
    Extensible = False;
    Caption = 'Payment Gateways';
    PageType = List;
    UsageCategory = None;

    SourceTable = "NPR Magento Payment Gateway";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRMagento;
                }
                field(Desctiption; Rec.Description)
                {

                    ToolTip = 'Specifies description';
                    ApplicationArea = NPRMagento;
                }
                field("Integration Type"; Rec."Integration Type")
                {

                    ToolTip = 'Specifies the payment gateway integration type';
                    ApplicationArea = NPRMagento;
                }
            }
        }
    }

    internal procedure SetRec(var TempPaymentGateway: Record "NPR Magento Payment Gateway")
    begin
        if TempPaymentGateway.FindSet() then
            repeat
                Rec := TempPaymentGateway;
                Rec.Insert();
            until TempPaymentGateway.Next() = 0;
    end;
}
