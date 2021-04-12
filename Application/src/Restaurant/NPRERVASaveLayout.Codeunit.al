codeunit 6150683 "NPR NPRE RVA: Save Layout"
{
    local procedure ActionCode(): Text;
    begin
        exit('RV_SAVE_LAYOUT');
    end;

    local procedure ActionVersion(): Text;
    begin
        exit('1.3');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action");
    var
        ActionDescription: Label 'This built-in action stores the restaurant layout from the front-end editor.';
    begin
        if Sender.DiscoverAction20(ActionCode(), ActionDescription, ActionVersion()) then begin
            Sender.RegisterWorkflow20('await workflow.respond();');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', true, true)]
    local procedure OnAction20(Action: Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean);
    var
        NPREFrontendAssistant: Codeunit "NPR NPRE Frontend Assistant";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        UpdatedRestaurantCode := '';
        SaveLayout(Context);
        if UpdatedRestaurantCode <> '' then
            NPREFrontendAssistant.SetRestaurant(POSSession, FrontEnd, UpdatedRestaurantCode);
    end;

    local procedure SaveLayout(Context: Codeunit "NPR POS JSON Management");
    var
        JArray: JsonArray;
        JObject: JsonObject;
        JToken: JsonToken;
        LayoutName: Text;
    begin
        LayoutName := Context.GetString('layout');
        if LayoutName = '' then
            exit;

        if not JObject.ReadFrom(LayoutName) then
            exit;

        // Message('%1', LayoutName);  //DEBUG

        if JObject.SelectToken('delete.locations', JToken) then begin
            if JToken.IsArray then begin
                JArray := JToken.AsArray();
                foreach JToken in JArray do
                    DeleteLocation(JToken.AsValue().AsText());
            end;
        end;

        if JObject.SelectToken('delete.components', JToken) then begin
            if JToken.IsArray then begin
                JArray := JToken.AsArray();
                foreach JToken in JArray do
                    DeleteComponent(JToken.AsValue().AsText());
            end;
        end;

        if JObject.SelectToken('new.locations', JToken) then begin
            if JToken.IsArray then begin
                JArray := JToken.AsArray();
                foreach JToken in JArray do
                    NewLocation(JToken.AsObject());
            end;
        end;

        if JObject.SelectToken('new.components', JToken) then begin
            if JToken.IsArray then begin
                JArray := JToken.AsArray();
                foreach JToken in JArray do
                    NewComponent(JToken.AsObject());
            end;
        end;

        if JObject.SelectToken('modify.locations', JToken) then begin
            if JToken.IsArray then begin
                JArray := JToken.AsArray();
                foreach JToken in JArray do
                    ModifyLocation(JToken.AsObject());
            end;
        end;

        if JObject.SelectToken('modify.components', JToken) then begin
            if JToken.IsArray then begin
                JArray := JToken.AsArray();
                foreach JToken in JArray do
                    ModifyComponent(JToken.AsObject());
            end;
        end;
    end;

    local procedure NewComponent(ComponentObject: JsonObject);
    var
        LocationLayout: Record "NPR NPRE Location Layout";
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        LocationLayout.Init();
        LocationLayout.Code := GetStringValue(ComponentObject, 'id', MaxStrLen(LocationLayout.Code));
        if LocationLayout.Find() then begin
            RestaurantSetup.Get();
            if RestaurantSetup."Component No. Series" = '' then begin
                RestaurantSetup."Component No. Series" := CreateNoSeries('NPR-NPRE', 'NPRE Component Numbering', 'C10000');
                RestaurantSetup.Modify();
            end;

            LocationLayout.Init();

            LocationLayout.Code := NoSeriesManagement.GetNextNo(RestaurantSetup."Component No. Series", Today, true);

        end;

        TransferToLocationLayout(ComponentObject, LocationLayout);

        LocationLayout.TestField(Code);
        LocationLayout.Insert(true);
    end;

    local procedure ModifyComponent(ComponentObject: JsonObject);
    var
        LocationLayout: Record "NPR NPRE Location Layout";
    begin
        if not LocationLayout.Get(GetStringValue(ComponentObject, 'id', MaxStrLen(LocationLayout.Code))) then begin
            NewComponent(ComponentObject);
            exit;
        end;

        TransferToLocationLayout(ComponentObject, LocationLayout);
        LocationLayout.Modify(true);
    end;

    local procedure TransferToLocationLayout(ComponentObject: JsonObject; var LocationLayout: Record "NPR NPRE Location Layout");
    var
        Seating: Record "NPR NPRE Seating";
        SeatingLocation: Record "NPR NPRE Seating Location";
        SeatingMgt: Codeunit "NPR NPRE Seating Mgt.";
        OutStr: OutStream;
        NewSeating: Boolean;
    begin
        SeatingLocation.Get(GetStringValue(ComponentObject, 'locationId', MaxStrLen(Seating."Seating Location")));

        LocationLayout.Type := GetStringValue(ComponentObject, 'type', MaxStrLen(LocationLayout.Type));
        LocationLayout.Description := GetStringValue(ComponentObject, 'caption', MaxStrLen(LocationLayout.Description));
        LocationLayout."Seating Location" := GetStringValue(ComponentObject, 'locationId', MaxStrLen(LocationLayout."Seating Location"));
        LocationLayout."Frontend Properties".CreateOutStream(OutStr);
        OutStr.Write(GetJsonToken(ComponentObject, 'blob').AsValue().AsText());

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

    local procedure TransferToSeating(ComponentObject: JsonObject; var Seating: Record "NPR NPRE Seating");
    var
        SeatingLocation: Record "NPR NPRE Seating Location";
        JToken: JsonToken;
    begin
        SeatingLocation.Get(GetStringValue(ComponentObject, 'locationId', MaxStrLen(Seating."Seating Location")));

        Seating.Description := GetStringValue(ComponentObject, 'caption', MaxStrLen(Seating.Description));
        Seating."Seating Location" := GetStringValue(ComponentObject, 'locationId', MaxStrLen(Seating."Seating Location"));
        if ComponentObject.get('capacity', JToken) then
            Seating.Capacity := JToken.AsValue().AsInteger();
    end;

    local procedure DeleteComponent(ComponentCode: Text);
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

    local procedure NewLocation(ComponentObject: JsonObject);
    var
        Restaurant: Record "NPR NPRE Restaurant";
        SeatingLocation: Record "NPR NPRE Seating Location";
    begin
        if SeatingLocation.Get(GetStringValue(ComponentObject, 'id', MaxStrLen(SeatingLocation.Code))) then begin
            ModifyLocation(ComponentObject);
            exit;
        end;

        Restaurant.Get(GetStringValue(ComponentObject, 'restaurantId', MaxStrLen(SeatingLocation."Restaurant Code")));

        SeatingLocation.Code := GetStringValue(ComponentObject, 'id', MaxStrLen(SeatingLocation.Code));
        SeatingLocation.Description := GetStringValue(ComponentObject, 'caption', MaxStrLen(SeatingLocation.Description));
        SeatingLocation."Restaurant Code" := Restaurant.Code;
        SeatingLocation.TestField(Code);
        SeatingLocation.Insert(true);
        SetUpdatedRestaurant(SeatingLocation."Restaurant Code");
    end;

    local procedure ModifyLocation(ComponentObject: JsonObject);
    var
        SeatingLocation: Record "NPR NPRE Seating Location";
        Restaurant: Record "NPR NPRE Restaurant";
    begin
        if not SeatingLocation.Get(GetStringValue(ComponentObject, 'id', MaxStrLen(SeatingLocation.Code))) then begin
            ModifyLocation(ComponentObject);
            exit;
        end;

        Restaurant.Get(GetStringValue(ComponentObject, 'restaurantId', MaxStrLen(SeatingLocation."Restaurant Code")));

        SeatingLocation.Description := GetStringValue(ComponentObject, 'caption', MaxStrLen(SeatingLocation.Description));
        SeatingLocation."Restaurant Code" := Restaurant.Code;
        SeatingLocation.Modify(true);
        SetUpdatedRestaurant(SeatingLocation."Restaurant Code");
    end;

    local procedure DeleteLocation(LocationCode: Text);
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

    local procedure GetStringValue(JObject: JsonObject; KeyValue: Text; MaxLength: Integer): Text;
    begin
        exit(CopyStr(GetJsonToken(JObject, KeyValue).AsValue().AsText(), 1, MaxLength));
    end;

    local procedure GetJsonToken(JObject: JsonObject; TokenKey: Text) JToken: JsonToken
    var
        TokenNotFound: Label 'Could not find a Json token with key %1';
    begin
        if not JObject.get(TokenKey, JToken) then
            Error(TokenNotFound, TokenKey);
    end;

    procedure CreateNoSeries(NoSeriesCode: Code[20]; Desc: Text; StartNumber: Code[20]): Code[20];
    var
        NoSeries: Record 308;
        NoSeriesLine: Record 309;
    begin
        if NoSeries.Get(NoSeriesCode) then
            exit(NoSeriesCode);

        NoSeries.Code := NoSeriesCode;
        NoSeries.Insert();

        NoSeries.Description := CopyStr(Desc, 1, MaxStrLen(NoSeries.Description));
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
            UpdatedRestaurantCode := RestaurantCode;
    end;

    var
        UpdatedRestaurantCode: Code[20];
}