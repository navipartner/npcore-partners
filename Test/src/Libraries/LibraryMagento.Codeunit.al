codeunit 85009 "NPR Library - Magento"
{
    var
        LibraryUtility: Codeunit "Library - Utility";

    procedure CreateMagentoSetup(var MagentoSetup: Record "NPR Magento Setup")
    begin
        if (MagentoSetup.Get()) then
            exit;

        MagentoSetup.Init();
        MagentoSetup.Insert();
    end;

    procedure CreateMagentoItem(var Item: Record Item)
    var
        ItemNo: Code[20];
        LibraryInventory: Codeunit "Library - Inventory";
    begin
        ItemNo := Item."No.";

        LibraryInventory.CreateItem(Item);

        if (ItemNo <> '') and (ItemNo <> Item."No.") then
            Item.Rename(ItemNo);

        Item."NPR Magento Item" := true;
        Item."NPR Magento Name" := Item.Description;
        Item.Modify(true);
    end;

    procedure CreateMagentoStore(WebsiteCode: Code[32]; StoreCode: Code[32])
    var
        MagentoStore: Record "NPR Magento Store";
        MagentoWebsite: Record "NPR Magento Website";
    begin
        if (MagentoStore.Get(StoreCode)) then
            exit;

        if (not MagentoWebsite.Get(WebsiteCode)) then
            CreateMagentoWebsite(WebsiteCode);

        MagentoStore.Init();
        MagentoStore.Code := StoreCode;
        MagentoStore.Name := LibraryUtility.GenerateRandomText(MaxStrLen(MagentoStore.Name));
        MagentoStore.Insert();
    end;

    procedure CreateMagentoWebsite(WebsiteCode: Code[32])
    var
        MagentoWebsite: Record "NPR Magento Website";
    begin
        if (MagentoWebsite.Get(WebsiteCode)) then
            exit;

        MagentoWebsite.Init();
        MagentoWebsite.Code := WebsiteCode;
        MagentoWebsite.Name := LibraryUtility.GenerateRandomText(MaxStrLen(MagentoWebsite.Name));
        MagentoWebsite.Insert();
    end;

    procedure CreatePaymentMapping(PaymentCode: Text[50]; PaymentType: Text[50])
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

    procedure CreatePaymentMappingBalAccount(PaymentCode: Text[50]; PaymentType: Text[50])
    var
        PaymentMapping: Record "NPR Magento Payment Mapping";
    begin
        PaymentMapping."External Payment Method Code" := PaymentCode;
        PaymentMapping."External Payment Type" := PaymentType;
        PaymentMapping.Init();
        PaymentMapping."Payment Method Code" := CreatePaymentMethodWithBalAccount();
        PaymentMapping."Allow Adjust Payment Amount" := true;
        PaymentMapping.Insert();
    end;



    procedure CreateShipmentMapping(ExternalShipmentMethodCode: Text[50])
    var
        ShipmentMapping: Record "NPR Magento Shipment Mapping";
    begin
        CreateShipmentMapping(ExternalShipmentMethodCode, ShipmentMapping);
    end;

    procedure CreateVATBusinessGroupMapping(VATBusGroupCode: Code[20]; TaxClass: Text[250])
    var
        MagentoVATBusGroup: Record "NPR Magento VAT Bus. Group";
    begin
        if (not MagentoVATBusGroup.Get(VATBusGroupCode)) then begin
            MagentoVATBusGroup.Init();
            MagentoVATBusGroup."VAT Business Posting Group" := VATBusGroupCode;
            MagentoVATBusGroup.Insert();
        end;

        MagentoVATBusGroup."Magento Tax Class" := TaxClass;
        MagentoVATBusGroup.Modify();
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

    local procedure CreatePaymentMethodWithBalAccount(): Code[10]
    var
        PaymentMethod: Record "Payment Method";
        LibraryERM: Codeunit "Library - ERM";
    begin
        LibraryERM.CreatePaymentMethodWithBalAccount(PaymentMethod);
        exit(PaymentMethod.Code);
    end;

    local procedure CreateShipmentMethodWithCode(): Code[10]
    begin
        exit(LibraryUtility.CreateCodeRecord(Database::"Shipment Method"));
    end;

    local procedure CreateShipingAgentWithCode(): Code[10]
    begin
        exit(LibraryUtility.CreateCodeRecord(Database::"Shipping Agent"));
    end;

    local procedure CreateShipingAgentServiceWithCode(ShippingAgentCode: Code[10]): Code[10]
    var
        ShippingAgentServices: Record "Shipping Agent Services";
    begin
        ShippingAgentServices."Shipping Agent Code" := ShippingAgentCode;
        ShippingAgentServices.Code := LibraryUtility.GenerateRandomCode(ShippingAgentServices.FieldNo(Code), Database::"Shipping Agent Services");
        ShippingAgentServices.Init();
        ShippingAgentServices.Description := CopyStr(ShippingAgentServices.Code, 1, MaxStrLen(ShippingAgentServices.Description));
        ShippingAgentServices.Insert();
        exit(ShippingAgentServices.Code);
    end;
}