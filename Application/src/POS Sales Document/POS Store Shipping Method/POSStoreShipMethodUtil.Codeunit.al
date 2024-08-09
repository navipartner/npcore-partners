codeunit 6184946 "NPR POS Store Ship Method Util"
{
    Access = Internal;
    internal procedure CreatePOSStoreShipmentMethodFromMagentoShipmentMethodMappings(StoreShipProfileHeader: Record "NPR Store Ship. Profile Header"; Confirm: Boolean)
    var
        ConfirmManagement: Codeunit "Confirm Management";
        CreatePOSStoreShipmentMethodsFromMagentoShipmentMethodMappingLbl: Label 'Do you want to create the store shipment fees from the webshop?';
    begin
        if Confirm then
            if not ConfirmManagement.GetResponseOrDefault(CreatePOSStoreShipmentMethodsFromMagentoShipmentMethodMappingLbl, true) then
                exit;

        CreatePOSStoreShipmentMethodFromMagentoShipmentMethodMappings(StoreShipProfileHeader);
    end;

    local procedure CreatePOSStoreShipmentMethodFromMagentoShipmentMethodMappings(StoreShipProfileHeader: Record "NPR Store Ship. Profile Header")
    var
        MagentoShipmentMapping: Record "NPR Magento Shipment Mapping";
        StoreShipProfileLine: Record "NPR Store Ship. Profile Line";
        POSStoreShipmentMethodLineNo: Integer;
    begin
        MagentoShipmentMapping.Reset();
        MagentoShipmentMapping.SetFilter("Shipment Fee Type", '%1|%2', MagentoShipmentMapping."Shipment Fee Type"::Item, MagentoShipmentMapping."Shipment Fee Type"::"G/L Account");
        MagentoShipmentMapping.SetLoadFields(Description, "Shipment Method Code", "Shipping Agent Code", "Shipping Agent Service Code", "Shipment Fee Type", "Shipment Fee No.");
        if not MagentoShipmentMapping.FindSet() then
            exit;

        POSStoreShipmentMethodLineNo := GetPOSStoreShipmentMethodLastLineNo(StoreShipProfileHeader);

        repeat
            StoreShipProfileLine.Reset();
            StoreShipProfileLine.SetRange("Profile Code", StoreShipProfileHeader.Code);
            StoreShipProfileLine.SetRange("Shipment Method Code", MagentoShipmentMapping."Shipment Method Code");
            StoreShipProfileLine.SetRange("Shipping Agent Code", MagentoShipmentMapping."Shipping Agent Code");
            StoreShipProfileLine.SetRange("Shipping Agent Service Code", MagentoShipmentMapping."Shipping Agent Service Code");
            StoreShipProfileLine.SetRange("Shipment Fee Type", MagentoShipmentMapping."Shipment Fee Type");
            StoreShipProfileLine.SetRange("Shipment Fee No.", MagentoShipmentMapping."Shipment Fee No.");
            if not StoreShipProfileLine.FindFirst() then begin
                POSStoreShipmentMethodLineNo += 10000;

                StoreShipProfileLine.Init();
                StoreShipProfileLine."Profile Code" := StoreShipProfileHeader.Code;
                StoreShipProfileLine."Line No." := POSStoreShipmentMethodLineNo;
                StoreShipProfileLine."Shipment Method Code" := MagentoShipmentMapping."Shipment Method Code";
                StoreShipProfileLine."Shipping Agent Code" := MagentoShipmentMapping."Shipping Agent Code";
                StoreShipProfileLine."Shipping Agent Service Code" := MagentoShipmentMapping."Shipping Agent Service Code";
                StoreShipProfileLine."Shipment Fee Type" := MagentoShipmentMapping."Shipment Fee Type";
                StoreShipProfileLine."Shipment Fee No." := MagentoShipmentMapping."Shipment Fee No.";
                StoreShipProfileLine.Description := MagentoShipmentMapping.Description;
                StoreShipProfileLine.Insert();
            end;
            if StoreShipProfileLine.Description <> MagentoShipmentMapping.Description then begin
                StoreShipProfileLine.Description := MagentoShipmentMapping.Description;
                StoreShipProfileLine.Modify();
            end
        until MagentoShipmentMapping.Next() = 0;
    end;

    local procedure GetPOSStoreShipmentMethodLastLineNo(StoreShipProfileHeader: Record "NPR Store Ship. Profile Header") LastLineNo: Integer;
    var
        StoreShipProfileLine: Record "NPR Store Ship. Profile Line";
    begin
        StoreShipProfileLine.Reset();
        StoreShipProfileLine.SetRange("Profile Code", StoreShipProfileHeader.Code);
        StoreShipProfileLine.SetLoadFields("Profile Code", "Line No.");
        if not StoreShipProfileLine.FindLast() then
            exit;

        LastLineNo := StoreShipProfileLine."Line No.";
    end;
}