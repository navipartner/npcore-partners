page 6014528 "NPR Payment Gateways WP"
{
    Extensible = False;
    Caption = 'Payment Gateways';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR Magento Payment Gateway";
    SourceTableTemporary = true;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Desctiption; Rec.Description)
                {

                    ToolTip = 'Specifies description';
                    ApplicationArea = NPRRetail;
                }
                field("Integration Type"; Rec."Integration Type")
                {

                    ToolTip = 'Specifies the payment gateway integration type';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    internal procedure CreateMagentoPaymentGatewayData()
    var
        MagentoCustomerGateway: Record "NPR Magento Payment Gateway";
    begin
        if Rec.FindSet() then
            repeat
                MagentoCustomerGateway := Rec;
                if not MagentoCustomerGateway.Insert() then
                    MagentoCustomerGateway.Modify();
            until Rec.Next() = 0;
    end;

    internal procedure MagentoPaymentGatewayDataToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    internal procedure CopyRealAndTemp(var TempMagentoPaymentGateway: Record "NPR Magento Payment Gateway")
    var
        MagentoPaymentGateway: Record "NPR Magento Payment Gateway";
    begin
        TempMagentoPaymentGateway.DeleteAll();
        if Rec.FindSet() then
            repeat
                TempMagentoPaymentGateway := Rec;
                TempMagentoPaymentGateway.Insert();
            until Rec.Next() = 0;

        TempMagentoPaymentGateway.Init();
        if MagentoPaymentGateway.FindSet() then
            repeat
                TempMagentoPaymentGateway.TransferFields(MagentoPaymentGateway);
                TempMagentoPaymentGateway.Insert();
            until MagentoPaymentGateway.Next() = 0;
    end;
}
