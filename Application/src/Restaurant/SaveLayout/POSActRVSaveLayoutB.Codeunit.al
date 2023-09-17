codeunit 6151356 "NPR POSAct. RV Save LayoutB"
{
    Access = Internal;

    procedure SaveLayout(LayoutDefinition: Text; var RestaurantCode: Code[20])
    var
        JObject: JsonObject;
    begin
        if LayoutDefinition = '' then
            exit;
        if not JObject.ReadFrom(LayoutDefinition) then
            exit;
        SaveLayout(JObject, RestaurantCode);
    end;

    procedure SaveLayout(LayoutDefinition: JsonObject; var RestaurantCode: Code[20])
    var
        LayoutObject: JsonToken;
        LayoutObjectSet: JsonToken;
    begin
        if LayoutDefinition.SelectToken('delete.locations', LayoutObjectSet) then
            if LayoutObjectSet.IsArray() then
                foreach LayoutObject in LayoutObjectSet.AsArray() do
                    DeleteLocation(LayoutObject.AsValue().AsText());

        if LayoutDefinition.SelectToken('delete.components', LayoutObjectSet) then
            if LayoutObjectSet.IsArray() then
                foreach LayoutObject in LayoutObjectSet.AsArray() do
                    DeleteComponent(LayoutObject.AsValue().AsText());

        if LayoutDefinition.SelectToken('new.locations', LayoutObjectSet) then
            if LayoutObjectSet.IsArray() then
                foreach LayoutObject in LayoutObjectSet.AsArray() do
                    NewLocation(LayoutObject);

        if LayoutDefinition.SelectToken('new.components', LayoutObjectSet) then
            if LayoutObjectSet.IsArray() then
                foreach LayoutObject in LayoutObjectSet.AsArray() do
                    NewComponent(LayoutObject);

        if LayoutDefinition.SelectToken('modify.locations', LayoutObjectSet) then
            if LayoutObjectSet.IsArray() then
                foreach LayoutObject in LayoutObjectSet.AsArray() do
                    ModifyLocation(LayoutObject);

        if LayoutDefinition.SelectToken('modify.components', LayoutObjectSet) then
            if LayoutObjectSet.IsArray() then
                foreach LayoutObject in LayoutObjectSet.AsArray() do
                    ModifyComponent(LayoutObject);

        RestaurantCode := _UpdatedRestaurantCode;
    end;

    local procedure NewComponent(ComponentObject: JsonToken)
    var
        LocationLayout: Record "NPR NPRE Location Layout";
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        xLocationLayoutCode: Code[20];
        CouldNotGetNextNoErr: Label 'System could not assign next number from the number series %1. Please adjust the number series or specify another number series on page Restaurant Setup field %2, and try again.', Comment = '%1 - No. Series Code, %2 - Component No. Series field caption';
        NoSeriesDescrTxt: Label 'Restaurant layout component numbering', MaxLength = 100;
    begin
        LocationLayout.Code := CopyStr(JsonHelper.GetJCode(ComponentObject, 'id', true), 1, MaxStrLen(LocationLayout.Code));
        if (LocationLayout.Code = '') or LocationLayout.Find() then begin
            if not RestaurantSetup.Get() then begin
                RestaurantSetup.Init();
                RestaurantSetup.Insert();
            end;
            if RestaurantSetup."Component No. Series" = '' then begin
                RestaurantSetup."Component No. Series" := CreateNoSeries('RESTLAYOUT_COMP', NoSeriesDescrTxt, 'C10000');
                RestaurantSetup.Modify();
            end;
            repeat
                xLocationLayoutCode := LocationLayout.Code;
                LocationLayout.Code := NoSeriesManagement.GetNextNo(RestaurantSetup."Component No. Series", Today(), true);
                if (LocationLayout.Code = '') or (LocationLayout.Code = xLocationLayoutCode) then
                    Error(CouldNotGetNextNoErr, RestaurantSetup."Component No. Series", RestaurantSetup.FieldCaption("Component No. Series"));
            until not LocationLayout.Find();
        end;
        LocationLayout.Init();
        TransferToLocationLayout(ComponentObject, LocationLayout);
        LocationLayout.TestField(Code);
        LocationLayout.Insert(true);
    end;

    local procedure ModifyComponent(ComponentObject: JsonToken)
    var
        LocationLayout: Record "NPR NPRE Location Layout";
    begin
        if not LocationLayout.Get(CopyStr(JsonHelper.GetJCode(ComponentObject, 'id', true), 1, MaxStrLen(LocationLayout.Code))) then begin
            NewComponent(ComponentObject);
            exit;
        end;

        TransferToLocationLayout(ComponentObject, LocationLayout);
        LocationLayout.Modify(true);
    end;

    local procedure TransferToLocationLayout(ComponentObject: JsonToken; var LocationLayout: Record "NPR NPRE Location Layout")
    var
        Seating: Record "NPR NPRE Seating";
        SeatingLocation: Record "NPR NPRE Seating Location";
        SeatingMgt: Codeunit "NPR NPRE Seating Mgt.";
        OutStr: OutStream;
        NewSeating: Boolean;
    begin
        SeatingLocation.Get(CopyStr(JsonHelper.GetJCode(ComponentObject, 'locationId', true), 1, MaxStrLen(Seating."Seating Location")));

        LocationLayout."Seating No." := CopyStr(JsonHelper.GetJText(ComponentObject, 'user_friendly_id', false), 1, MaxStrLen(LocationLayout."Seating No."));
        LocationLayout.Type := CopyStr(JsonHelper.GetJText(ComponentObject, 'type', true), 1, MaxStrLen(LocationLayout.Type));
        LocationLayout.Description := CopyStr(JsonHelper.GetJText(ComponentObject, 'caption', false), 1, MaxStrLen(LocationLayout.Description));
        LocationLayout."Seating Location" := SeatingLocation.Code;
        LocationLayout."Frontend Properties".CreateOutStream(OutStr);
        OutStr.Write(JsonHelper.GetJsonToken(ComponentObject, 'blob').AsValue().AsText());

        if LowerCase(LocationLayout.Type) = 'table' then begin
            NewSeating := not Seating.Get(LocationLayout.Code);
            if NewSeating then begin
                Seating.Init();
                Seating.Code := LocationLayout.Code;
                Seating.Insert();
            end;
            TransferToSeating(ComponentObject, Seating);
            Seating.Modify();
            if NewSeating then
                SeatingMgt.SetSeatingIsReady(Seating.Code);
        end;
        SetUpdatedRestaurant(SeatingLocation."Restaurant Code");
    end;

    local procedure TransferToSeating(ComponentObject: JsonToken; var Seating: Record "NPR NPRE Seating")
    var
        SeatingLocation: Record "NPR NPRE Seating Location";
        FrontendProperties: JsonToken;
    begin
        SeatingLocation.Get(CopyStr(JsonHelper.GetJCode(ComponentObject, 'locationId', true), 1, MaxStrLen(Seating."Seating Location")));

        Seating."Seating No." := CopyStr(JsonHelper.GetJText(ComponentObject, 'user_friendly_id', false), 1, MaxStrLen(Seating."Seating No."));
        Seating.Description := CopyStr(JsonHelper.GetJText(ComponentObject, 'caption', false), 1, MaxStrLen(Seating.Description));
        Seating."Seating Location" := SeatingLocation.Code;

        FrontendProperties.ReadFrom(JsonHelper.GetJText(ComponentObject, 'blob', true));
        Seating.Capacity := JsonHelper.GetJInteger(FrontendProperties, 'capacity', false, Seating.Capacity);
        Seating."Min Party Size" := JsonHelper.GetJInteger(FrontendProperties, 'chairs.min', false, Seating."Min Party Size");
        Seating."Max Party Size" := JsonHelper.GetJInteger(FrontendProperties, 'chairs.max', false, Seating."Max Party Size");
    end;

    local procedure DeleteComponent(ComponentCode: Text)
    var
        LocationLayout: Record "NPR NPRE Location Layout";
        Seating: Record "NPR NPRE Seating";
        SeatingLocation: Record "NPR NPRE Seating Location";
    begin
        if not LocationLayout.Get(CopyStr(ComponentCode, 1, MaxStrLen(LocationLayout.Code))) then
            exit;

        if SeatingLocation.Get(LocationLayout."Seating Location") then
            SetUpdatedRestaurant(SeatingLocation."Restaurant Code");

        LocationLayout.Delete(true);

        if LowerCase(LocationLayout.Type) = 'table' then
            if Seating.Get(LocationLayout.Code) then
                Seating.Delete(true);
    end;

    local procedure NewLocation(ComponentObject: JsonToken)
    var
        Restaurant: Record "NPR NPRE Restaurant";
        SeatingLocation: Record "NPR NPRE Seating Location";
    begin
        if SeatingLocation.Get(CopyStr(JsonHelper.GetJCode(ComponentObject, 'id', true), 1, MaxStrLen(SeatingLocation.Code))) then begin
            ModifyLocation(ComponentObject);
            exit;
        end;

        Restaurant.Get(CopyStr(JsonHelper.GetJCode(ComponentObject, 'restaurantId', true), 1, MaxStrLen(SeatingLocation."Restaurant Code")));

        SeatingLocation.Code := SeatingLocation.Code;
        SeatingLocation.Description := CopyStr(JsonHelper.GetJText(ComponentObject, 'caption', false), 1, MaxStrLen(SeatingLocation.Description));
        SeatingLocation."Restaurant Code" := Restaurant.Code;
        SeatingLocation.TestField(Code);
        SeatingLocation.Insert(true);
        SetUpdatedRestaurant(SeatingLocation."Restaurant Code");
    end;

    local procedure ModifyLocation(ComponentObject: JsonToken)
    var
        SeatingLocation: Record "NPR NPRE Seating Location";
        Restaurant: Record "NPR NPRE Restaurant";
    begin
        if not SeatingLocation.Get(CopyStr(JsonHelper.GetJCode(ComponentObject, 'id', true), 1, MaxStrLen(SeatingLocation.Code))) then begin
            ModifyLocation(ComponentObject);
            exit;
        end;

        Restaurant.Get(CopyStr(JsonHelper.GetJCode(ComponentObject, 'restaurantId', true), 1, MaxStrLen(SeatingLocation."Restaurant Code")));

        SeatingLocation.Description := CopyStr(JsonHelper.GetJText(ComponentObject, 'caption', false), 1, MaxStrLen(SeatingLocation.Description));
        SeatingLocation."Restaurant Code" := Restaurant.Code;
        SeatingLocation.Modify(true);
        SetUpdatedRestaurant(SeatingLocation."Restaurant Code");
    end;

    local procedure DeleteLocation(LocationCode: Text)
    var
        LocationLayout: Record "NPR NPRE Location Layout";
        Seating: Record "NPR NPRE Seating";
        SeatingLocation: Record "NPR NPRE Seating Location";
    begin
        if not SeatingLocation.Get(CopyStr(LocationCode, 1, MaxStrLen(SeatingLocation.Code))) then
            exit;

        SetUpdatedRestaurant(SeatingLocation."Restaurant Code");

        LocationLayout.SetRange("Seating Location", SeatingLocation.Code);
        LocationLayout.DeleteAll(true);

        Seating.SetRange("Seating Location", SeatingLocation.Code);
        Seating.DeleteAll(true);

        SeatingLocation.Delete(true);
    end;

    local procedure CreateNoSeries(NoSeriesCode: Code[20]; Description: Text; StartNumber: Code[20]): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if NoSeries.Get(NoSeriesCode) then
            exit(NoSeriesCode);

        NoSeries.Code := NoSeriesCode;
        NoSeries.Insert();

        NoSeries.Description := CopyStr(Description, 1, MaxStrLen(NoSeries.Description));
        NoSeries."Default Nos." := true;
        NoSeries.Modify();

        if not NoSeriesLine.Get(NoSeriesCode, 10000) then begin
            NoSeriesLine."Series Code" := NoSeriesCode;
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting Date" := Today();
            NoSeriesLine."Starting No." := StartNumber;
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert();
        end;

        exit(NoSeriesCode);
    end;

    local procedure SetUpdatedRestaurant(RestaurantCode: Code[20])
    begin
        if RestaurantCode <> '' then
            _UpdatedRestaurantCode := RestaurantCode;
    end;

    var
        JsonHelper: Codeunit "NPR Json Helper";
        _UpdatedRestaurantCode: Code[20];
}