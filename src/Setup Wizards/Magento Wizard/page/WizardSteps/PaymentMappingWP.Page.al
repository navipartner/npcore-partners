page 6014531 "NPR Payment Mapping WP"
{
    Caption = 'Payment Method Mapping';
    PageType = ListPart;
    SourceTable = "NPR Magento Payment Mapping";
    SourceTableTemporary = true;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Payment Method Code"; "External Payment Method Code")
                {
                    ShowMandatory = true;
                }
                field("External Payment Type"; "External Payment Type")
                {
                }
                field("Payment Method Code"; "Payment Method Code")
                {
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PaymentMethod: Record "Payment Method";
                        PaymentMethods: Page "Payment Methods";
                    begin
                        PaymentMethods.LookupMode := true;

                        if "Payment Method Code" <> '' then
                            if PaymentMethod.Get("Payment Method Code") then
                                PaymentMethods.SetRecord(PaymentMethod);

                        if PaymentMethods.RunModal() = Action::LookupOK then begin
                            PaymentMethods.GetRecord(PaymentMethod);
                            "Payment Method Code" := PaymentMethod.Code;
                        end;
                    end;
                }
                field("Allow Adjust Payment Amount"; "Allow Adjust Payment Amount")
                {
                }
                field("Payment Gateway Code"; "Payment Gateway Code")
                {
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PaymentGateways: Page "NPR Pmt. Gateways Select";
                    begin
                        PaymentGateways.LookupMode := true;
                        PaymentGateways.Editable := false;

                        PaymentGateways.SetRec(TempAllMagentoPaymentGateway);

                        IF "Payment Gateway Code" <> '' then
                            if TempAllMagentoPaymentGateway.Get("Payment Gateway Code") then
                                PaymentGateways.SetRecord(TempAllMagentoPaymentGateway);

                        if PaymentGateways.RunModal() = Action::LookupOK then begin
                            PaymentGateways.GetRecord(TempAllMagentoPaymentGateway);
                            "Payment Gateway Code" := TempAllMagentoPaymentGateway.Code;
                        end;
                    end;
                }
                field("Captured Externally"; "Captured Externally")
                {
                }
            }
        }
    }

    var
        TempAllMagentoPaymentGateway: Record "NPR Magento Payment Gateway" temporary;

    procedure SetGlobals(var TempMagentoPaymentGateway: Record "NPR Magento Payment Gateway")
    begin
        TempAllMagentoPaymentGateway.DeleteAll();

        if TempMagentoPaymentGateway.FindSet() then
            repeat
                TempAllMagentoPaymentGateway := TempMagentoPaymentGateway;
                TempAllMagentoPaymentGateway.Insert();
            until TempMagentoPaymentGateway.Next() = 0;
    end;

    procedure CreateMagentoPaymentMapping()
    var
        MagentoPaymentMapping: Record "NPR Magento Payment Mapping";
    begin
        if Rec.FindSet() then
            repeat
                MagentoPaymentMapping := Rec;
                if not MagentoPaymentMapping.Insert() then
                    MagentoPaymentMapping.Modify();
            until Rec.Next() = 0;
    end;

    procedure MagentoPaymentMappingToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;
}