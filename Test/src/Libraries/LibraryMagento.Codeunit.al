codeunit 85009 "NPR Library - Magento"
{
    procedure CreatePaymentMapping(PaymentCode: Code[50]; PaymentType: Text[50])
    var
        PaymentMapping: Record "NPR Magento Payment Mapping";
    begin
        PaymentMapping."External Payment Method Code" := PaymentCode;
        PaymentMapping."External Payment Type" := PaymentType;
        PaymentMapping.Init();
        PaymentMapping."Payment Method Code" := CreatePaymentMethodWithCode();
        PaymentMapping."Allow Adjust Payment Amount" := true;
        PaymentMapping.Insert();
    end;

    procedure CreateShipmentMapping(ExternalShipmentMethodCode: Text[50]; var ShipmentMapping: Record "NPR Magento Shipment Mapping")
    begin
        ShipmentMapping."External Shipment Method Code" := ExternalShipmentMethodCode;
        ShipmentMapping.Init();
        ShipmentMapping."Shipment Method Code" := CreateShipmentMethodWithCode();
        ShipmentMapping."Shipping Agent Code" := CreateShipingAgentWithCode();
        ShipmentMapping."Shipping Agent Service Code" := CreateShipingAgentServiceWithCode(ShipmentMapping."Shipping Agent Code");
        ShipmentMapping.Insert();
    end;

    local procedure CreatePaymentMethodWithCode(): Code[10]
    var
        PaymentMethod: Record "Payment Method";
        LibraryPaymentExport: Codeunit "Library - Payment Export";
    begin
        LibraryPaymentExport.CreatePaymentMethod(PaymentMethod);
        exit(PaymentMethod.Code);
    end;

    local procedure CreateShipmentMethodWithCode(): Code[10]
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        exit(LibraryUtility.CreateCodeRecord(Database::"Shipment Method"));
    end;

    local procedure CreateShipingAgentWithCode(): Code[10]
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        exit(LibraryUtility.CreateCodeRecord(Database::"Shipping Agent"));
    end;

    local procedure CreateShipingAgentServiceWithCode(ShippingAgentCode: Code[10]): Code[10]
    var
        ShippingAgentServices: Record "Shipping Agent Services";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        ShippingAgentServices."Shipping Agent Code" := ShippingAgentCode;
        ShippingAgentServices.Code := LibraryUtility.GenerateRandomCode(ShippingAgentServices.FieldNo(Code), Database::"Shipping Agent Services");
        ShippingAgentServices.Init();
        ShippingAgentServices.Description := CopyStr(ShippingAgentServices.Code, 1, MaxStrLen(ShippingAgentServices.Description));
        ShippingAgentServices.Insert();
        exit(ShippingAgentServices.Code);
    end;
}