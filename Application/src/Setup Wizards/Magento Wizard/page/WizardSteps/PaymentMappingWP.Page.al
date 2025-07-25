﻿page 6014531 "NPR Payment Mapping WP"
{
    Extensible = False;
    Caption = 'Payment Method Mapping';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR Magento Payment Mapping";
    SourceTableTemporary = true;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Payment Method Code"; Rec."External Payment Method Code")
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the External Payment Method Code field';
                    ApplicationArea = NPRMagento;
                }
                field("External Payment Type"; Rec."External Payment Type")
                {

                    ToolTip = 'Specifies the value of the External Payment Type field';
                    ApplicationArea = NPRMagento;
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {

                    ToolTip = 'Specifies the value of the Payment Method Code field';
                    ApplicationArea = NPRMagento;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PaymentMethod: Record "Payment Method";
                        PaymentMethods: Page "Payment Methods";
                    begin
                        PaymentMethods.LookupMode := true;

                        if Rec."Payment Method Code" <> '' then
                            if PaymentMethod.Get(Rec."Payment Method Code") then
                                PaymentMethods.SetRecord(PaymentMethod);

                        if PaymentMethods.RunModal() = Action::LookupOK then begin
                            PaymentMethods.GetRecord(PaymentMethod);
                            Rec."Payment Method Code" := PaymentMethod.Code;
                        end;
                    end;
                }
                field("Allow Adjust Payment Amount"; Rec."Allow Adjust Payment Amount")
                {

                    ToolTip = 'Specifies the value of the Allow Adjust Payment Amount field';
                    ApplicationArea = NPRMagento;
                }
                field("Payment Gateway Code"; Rec."Payment Gateway Code")
                {

                    ToolTip = 'Specifies the value of the Payment Gateway Code field';
                    ApplicationArea = NPRMagento;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PaymentGateways: Page "NPR Pmt. Gateways Select";
                    begin
                        PaymentGateways.LookupMode := true;
                        PaymentGateways.Editable := false;

                        PaymentGateways.SetRec(TempAllMagentoPaymentGateway);

                        IF Rec."Payment Gateway Code" <> '' then
                            if TempAllMagentoPaymentGateway.Get(Rec."Payment Gateway Code") then
                                PaymentGateways.SetRecord(TempAllMagentoPaymentGateway);

                        if PaymentGateways.RunModal() = Action::LookupOK then begin
                            PaymentGateways.GetRecord(TempAllMagentoPaymentGateway);
                            Rec."Payment Gateway Code" := TempAllMagentoPaymentGateway.Code;
                        end;
                    end;
                }
                field("Captured Externally"; Rec."Captured Externally")
                {

                    ToolTip = 'Specifies the value of the Captured Externally field';
                    ApplicationArea = NPRMagento;
                }
            }
        }
    }

    var
        TempAllMagentoPaymentGateway: Record "NPR Magento Payment Gateway" temporary;

    internal procedure SetGlobals(var TempMagentoPaymentGateway: Record "NPR Magento Payment Gateway")
    begin
        TempAllMagentoPaymentGateway.DeleteAll();

        if TempMagentoPaymentGateway.FindSet() then
            repeat
                TempAllMagentoPaymentGateway := TempMagentoPaymentGateway;
                TempAllMagentoPaymentGateway.Insert();
            until TempMagentoPaymentGateway.Next() = 0;
    end;

    internal procedure CreateMagentoPaymentMapping()
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

    internal procedure MagentoPaymentMappingToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;
}
