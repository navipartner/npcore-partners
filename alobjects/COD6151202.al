codeunit 6151202 "NpCs POS Action Process Order"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Process Collect in Store Orders';

    local procedure ActionCode(): Text
    begin
        exit('PROCESS_COLLECT_ORD');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverActions(var Sender: Record "POS Action")
    begin
        if not Sender.DiscoverAction(
          ActionCode(),
          Text000,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple) then
         exit;

        Sender.RegisterWorkflowStep('run_collect_in_store_orders','respond();');
        Sender.RegisterWorkflow(false);
        Sender.RegisterDataSourceBinding('BUILTIN_SALE');
        Sender.RegisterCustomJavaScriptLogic('enable','return row.getField("CollectInStore.UnprocessedOrdersExists").rawValue;');

        Sender.RegisterOptionParameter('Location From','POS Store,Location Filter Parameter','POS Store');
        Sender.RegisterTextParameter('Location Filter','');
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', true, true)]
    local procedure OnLookupLocationFilter(var POSParameterValue: Record "POS Parameter Value";Handled: Boolean)
    var
        Location: Record Location;
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
          exit;
        if POSParameterValue.Name <> 'Location Filter' then
          exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
          exit;

        Handled := true;

        if StrLen(POSParameterValue.Value) > MaxStrLen(Location.Code) then
          if Location.Get(UpperCase(POSParameterValue.Value)) then;

        if PAGE.RunModal(0,Location) = ACTION::LookupOK then
          POSParameterValue.Value := Location.Code;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', true, true)]
    local procedure OnValidateLocationFilter(var POSParameterValue: Record "POS Parameter Value")
    var
        Location: Record Location;
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
          exit;
        if POSParameterValue.Name <> 'Location Filter' then
          exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
          exit;
        if POSParameterValue.Value = '' then
          exit;

        POSParameterValue.Value := UpperCase(POSParameterValue.Value);
        Location.SetFilter(Code,POSParameterValue.Value);
        if not Location.FindFirst then begin
          Location.SetFilter(Code,'%1',POSParameterValue.Value + '*');
          if Location.FindFirst then
            POSParameterValue.Value := Location.Code;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', true, true)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        LocationFilter: Text;
        POSSale: Codeunit "POS Sale";
    begin
        if Handled then
          exit;
        if not Action.IsThisAction(ActionCode()) then
          exit;
        Handled := true;

        case WorkflowStep of
          'run_collect_in_store_orders':
            begin
              JSON.InitializeJObjectParser(Context,FrontEnd);
              LocationFilter := GetLocationFilter(JSON,POSSession);
              RunCollectInStoreOrders(LocationFilter);
              POSSession.GetSale(POSSale);
              POSSale.RefreshCurrent();
              POSSession.RequestRefreshData();
            end;
        end;
    end;

    local procedure RunCollectInStoreOrders(LocationFilter: Text)
    var
        NpCsDocument: Record "NpCs Document";
    begin
        SetUnprocessedFilter(LocationFilter,NpCsDocument);
        PAGE.RunModal(PAGE::"NpCs Collect Store Orders",NpCsDocument);
    end;

    local procedure GetLocationFilter(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session") LocationFilter: Text
    var
        POSStore: Record "POS Store";
        POSSetup: Codeunit "POS Setup";
    begin
        case JSON.GetIntegerParameter('Location From',true) of
          0:
            begin
              POSSession.GetSetup(POSSetup);
              POSSetup.GetPOSStore(POSStore);
              LocationFilter := POSStore."Location Code";
            end;
          1:
            begin
              LocationFilter := UpperCase(JSON.GetStringParameter('Location Filter',true));
            end;
        end;

        exit(LocationFilter);
    end;

    local procedure "--- POS Data Source"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDiscoverDataSourceExtensions', '', false, false)]
    local procedure OnDiscover(DataSourceName: Text;Extensions: DotNet List_Of_T)
    var
        NpCsStore: Record "NpCs Store";
    begin
        if DataSourceName <> 'BUILTIN_SALE' then
          exit;
        if NpCsStore.IsEmpty then
          exit;

        Extensions.Add('CollectInStore');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnGetDataSourceExtension', '', false, false)]
    local procedure OnGetExtension(DataSourceName: Text;ExtensionName: Text;var DataSource: DotNet DataSource0;var Handled: Boolean;Setup: Codeunit "POS Setup")
    var
        DataType: DotNet DataType;
    begin
        if DataSourceName <> 'BUILTIN_SALE' then
          exit;
        if ExtensionName <> 'CollectInStore' then
          exit;

        Handled := true;

        DataSource.AddColumn('UnprocessedOrdersExists','Unprocessed Orders Exists',DataType.Boolean,false);
        DataSource.AddColumn('UnprocessedOrdersQty','Unprocessed Orders Qty.',DataType.Integer,false);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDataSourceExtensionReadData', '', false, false)]
    local procedure OnReadData(DataSourceName: Text;ExtensionName: Text;var RecRef: RecordRef;DataRow: DotNet DataRow0;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        UnprocessedOrdersExists: Boolean;
        LocationFilter: Text;
    begin
        if DataSourceName <> 'BUILTIN_SALE' then
          exit;
        if ExtensionName <> 'CollectInStore' then
          exit;

        Handled := true;

        LocationFilter := GetPOSMenuButtonLocationFilter(POSSession);
        UnprocessedOrdersExists := GetUnprocessedOrdersExists(LocationFilter);
        DataRow.Fields.Add('UnprocessedOrdersExists',UnprocessedOrdersExists);
        if UnprocessedOrdersExists then
          DataRow.Fields.Add('UnprocessedOrdersQty',GetUnprocessedOrdersQty(LocationFilter))
        else
          DataRow.Fields.Add('UnprocessedOrdersQty',0);
    end;

    local procedure GetPOSMenuButtonLocationFilter(POSSession: Codeunit "POS Session") LocationFilter: Text
    var
        POSStore: Record "POS Store";
        POSMenuButton: Record "POS Menu Button";
        POSParameterValue: Record "POS Parameter Value";
        SalePOS: Record "Sale POS";
        POSSale: Codeunit "POS Sale";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSMenuButton.SetRange("Action Code",ActionCode());
        POSMenuButton.SetRange("Register No.",SalePOS."Register No.");
        if not POSMenuButton.FindFirst then
          POSMenuButton.SetRange("Register No.");
        if not POSMenuButton.FindFirst then
          exit('');

        if not POSParameterValue.Get(DATABASE::"POS Menu Button",POSMenuButton."Menu Code",POSMenuButton.ID,POSMenuButton.RecordId,'Location From') then
          exit('');
        case POSParameterValue.Value of
          'POS Store':
            begin
              if POSStore.Get(SalePOS."POS Store Code") then;
              exit(POSStore."Location Code");
            end;
          'Location Filter Parameter':
            begin
              Clear(POSParameterValue);
              if POSParameterValue.Get(DATABASE::"POS Menu Button",POSMenuButton."Menu Code",POSMenuButton.ID,POSMenuButton.RecordId,'Location Filter') then;
              exit(POSParameterValue.Value);
            end;
        end;

        exit('');
    end;

    local procedure GetUnprocessedOrdersExists(LocationFilter: Text): Boolean
    var
        NpCsDocument: Record "NpCs Document";
    begin
        SetUnprocessedFilter(LocationFilter,NpCsDocument);
        exit(NpCsDocument.FindFirst);
    end;

    local procedure GetUnprocessedOrdersQty(LocationFilter: Text): Integer
    var
        NpCsDocument: Record "NpCs Document";
    begin
        SetUnprocessedFilter(LocationFilter,NpCsDocument);
        exit(NpCsDocument.Count);
    end;

    local procedure SetUnprocessedFilter(LocationFilter: Text;var NpCsDocument: Record "NpCs Document")
    begin
        NpCsDocument.SetRange(Type,NpCsDocument.Type::"Collect in Store");
        NpCsDocument.SetRange("Processing Status",NpCsDocument."Processing Status"::Pending);
        NpCsDocument.SetRange("Delivery Status",NpCsDocument."Delivery Status"::" ");
        NpCsDocument.SetFilter("Location Code",LocationFilter);
    end;
}

