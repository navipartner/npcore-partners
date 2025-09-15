codeunit 6151033 "NPR POS Action Set Serial No B"
{
    Access = Internal;

    #region CheckLineTracking
    internal procedure CheckLineTracking(SaleLinePOS: Record "NPR POS Sale Line";
                                         var RequiresSerialNo: Boolean;
                                         var UseSpecificTracking: Boolean;
                                         var HasAssignedSerialNo: boolean)
    begin
        CheckTrackingOptions(SaleLinePOS);

        GetTrackingOptions(SaleLinePOS,
                           RequiresSerialNo,
                           UseSpecificTracking);

        HasAssignedSerialNo := SaleLinePOS."Serial No." <> '';


    end;
    #endregion CheckLineTracking


    #region AssignSerialNo
    internal procedure AssignSerialNo(var SaleLinePOS: Record "NPR POS Sale Line"; var SerialNumberInput: Text[50]; SerialSelectionFromList: Boolean; POSSetup: Codeunit "NPR POS Setup"; LocationSource: Option "POS Store","All Locations",SpecificLocation; SpecificLocationCode: Code[10])
    var
        POSStore: Record "NPR POS Store";
        NPRPOSTrackingUtils: Codeunit "NPR POS Tracking Utils";
        QuantityErrLbl: Label 'Quantity at %1 %2 can only be 1 or -1', Comment = '%1 - field name, %2 - field value';
        LocationCode: Code[10];
    begin
        CheckTrackingOptions(SaleLinePOS);

        POSSetup.GetPOSStore(POSStore);
        case LocationSource of
            LocationSource::"POS Store":
                LocationCode := POSStore."Location Code";
            LocationSource::"All Locations":
                LocationCode := GetAvailableLocationsSource(SaleLinePOS."No.");
            LocationSource::SpecificLocation:
                begin
                    CheckSpecificLocation(LocationSource, SpecificLocationCode);
                    LocationCode := SpecificLocationCode;
                end;
        end;

        NPRPOSTrackingUtils.ValidateSerialNo(SaleLinePOS."No.", SaleLinePOS."Variant Code", SerialNumberInput, SerialSelectionFromList, POSStore, LocationCode);

        if (SerialNumberInput <> '') and
           (Abs(SaleLinePOS.Quantity) <> 1)
        then
            Error(QuantityErrLbl,
                  SaleLinePOS.FieldName("Serial No."),
                  SerialNumberInput);

        SaleLinePOS.Validate("Serial No.", SerialNumberInput);
        SaleLinePOS.Modify(true);

    end;
    #endregion AssignSerialNo

    #region CheckTrackingOptions
    internal procedure CheckTrackingOptions(SaleLinePOS: Record "NPR POS Sale Line")
    var
        Item: Record Item;
        NPRPOSTrackingUtils: Codeunit "NPR POS Tracking Utils";
        UseSpecificTracking: Boolean;
        LineTypeErr: Label 'Line Type on %1 must be %2 or %3. Current value %4.', Comment = '%1 - Current line record id, %2 - allowed line type value, %3 - allowed line type value, %4 - current line type value.';
        ItemDoesNotRequireSerialNoErr: Label 'Item %1 does not require serial no tracking.', Comment = '%1 - item no.';

    begin
        if not (SaleLinePOS."Line Type" in [SaleLinePOS."Line Type"::Item,
                                            salelinepos."Line Type"::"BOM List"])
        then
            Error(LineTypeErr, Format(SaleLinePOS.RecordId),
                               SaleLinePOS."Line Type"::Item,
                               SaleLinePOS."Line Type"::"BOM List",
                               SaleLinePOS."Line Type");

        SaleLinePOS.TestField("No.");
        Item.get(SaleLinePOS."No.");
        if not NPRPOSTrackingUtils.ItemRequiresSerialNumber(Item,
                                                            UseSpecificTracking)
        then
            Error(ItemDoesNotRequireSerialNoErr, Item."No.");

    end;
    #endregion CheckTrackingOptions

    #region CheckAllLocations
    local procedure GetAvailableLocationsSource(ItemNo: Code[20]): Code[10]
    var
        Item: Record Item;
        Location: Record Location;
        LocationSelected: Record Location;
        Locations: Page "Location List";
        LocationFilter: Text;
        LocationSelectedEmptyLbl: Label 'You must select a location to use for serial no. selection.';
    begin
        if Location.FindSet() then
            repeat
                Item.SetLoadFields(Inventory);
                Item.Get(ItemNo);
                Item.SetFilter("Location Filter", Location.Code);
                Item.CalcFields(Inventory);
                if Item.Inventory <> 0 then
                    if LocationFilter = '' then
                        LocationFilter := Location.Code
                    else
                        LocationFilter += '|' + Location.Code;
            until Location.Next() = 0;

        Clear(Location);
        Locations.Editable(false);
        Locations.LookupMode(true);
        Location.SetFilter(Code, LocationFilter);
        Locations.SetTableView(Location);
        if not (Locations.RunModal() = Action::LookupOK) then
            Error(LocationSelectedEmptyLbl);
        Locations.GetRecord(LocationSelected);
        exit(LocationSelected.Code);
    end;
    #endregion CheckAllLocations

    #region GetTrackingOptions
    internal procedure GetTrackingOptions(SaleLinePOS: Record "NPR POS Sale Line";
                                          var RequiresSerialNo: Boolean;
                                          var UseSpecificTracking: Boolean) TrackingOptionsFound: Boolean
    var
        Item: Record Item;
        NPRPOSTrackingUtils: Codeunit "NPR POS Tracking Utils";
    begin
        if not (SaleLinePOS."Line Type" in [SaleLinePOS."Line Type"::Item,
                                            salelinepos."Line Type"::"BOM List"])
        then
            exit;

        if SaleLinePOS."No." = '' then
            exit;

        Item.get(SaleLinePOS."No.");
        RequiresSerialNo := NPRPOSTrackingUtils.ItemRequiresSerialNumber(Item,
                                                                         UseSpecificTracking);

        TrackingOptionsFound := true;
    end;
    #endregion GetTrackingOptions

    local procedure CheckSpecificLocation(LocationSource: Option "POS Store","All Locations",SpecificLocation; SpecificLocationCode: Code[10])
    var
        CaptionUseLocationFrom: Label 'Use Location From';
        CaptionUseSpecLocationCode: Label 'Use Specific Location Code';
        OptionNameUseLocationFrom: Label 'POS Store,POS Sale,SpecificLocation', Locked = true;
        SpecLocationCodeMustBeSpecified: Label 'POS Action''s parameter ''%1'' is set to ''%2''. You must specify location code to be used for serial no. selection as a parameter of the POS action (the parameter name is ''%3'')', Comment = 'POS Action''s parameter ''Use Location From'' is set to ''Specific Location''. You must specify location code to be used for serial no. selection as a parameter of the POS action (the parameter name is ''Use Specific Location Code'')';
    begin
        if (LocationSource = LocationSource::SpecificLocation) and (SpecificLocationCode = '') then
            Error(SpecLocationCodeMustBeSpecified, CaptionUseLocationFrom, SelectStr(LocationSource + 1, OptionNameUseLocationFrom), CaptionUseSpecLocationCode);
    end;
}