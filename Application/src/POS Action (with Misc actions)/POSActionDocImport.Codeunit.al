codeunit 6150861 "NPR POS Action: Doc. Import"
{
    // NPR5.50/MMV /20181105 CASE 300557 New action, based on CU 6150815
    // NPR5.53/ALPO/20191211 CASE 378678 Data source extension to have number of open sales orders available for displaying on a POS button
    // NPR5.54/ALPO/20200127 CASE 387130 New parameter to predefine filter and view for sales order list
    // NPR5.54/ALPO/20200305 CASE 387428 Possibility to filter list of available documents by location; use the same location filter to calculate number of open sales orders
    //                                   Use customer from selected sales document, if none is preselected


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Import an open standard NAV sales document to current POS sale and delete the document.';
        Setup: Codeunit "NPR POS Setup";
        REMOVE: Codeunit "NPR Sales Doc. Exp. Mgt.";
        ERRDOCTYPE: Label 'Wrong Document Type. Document Type is set to %1. It must be one of %2, %3, %4 or %5';
        ERRPARSED: Label 'SalesDocumentToPOS and SalesDocumentAmountToPOS can not be used simultaneously. This is an error in parameter setting on menu button for action %1.';
        ERRPARSEDCOMB: Label 'Import of amount is only supported for Document Type Order. This is an error in parameter setting on menu button for action %1.';
        CaptionDocType: Label 'Document Type';
        CaptionLocationFrom: Label 'Location From';
        CaptionLocationFilter: Label 'Location Filter';
        CaptionSalesView: Label 'Doc. View';
        CaptionSelectCustomer: Label 'Select Customer';
        DescSalesView: Label 'Pre-filtered list of sales documents';
        DescSelectCustomer: Label 'Prompt for customer selection if none on sale';
        DescDocType: Label 'Filter on Document Type';
        DescLocationFrom: Label 'Select the source to get location from to use as a filtering criteria for sales document list';
        DescLocationFilter: Label 'A string, which will be used as a location filter for sales document list, if ''Location From'' parameter is set to ''Location Filter Parameter''';
        OptionDocType: Label 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
        OptionLocationFrom: Label 'POS Store,Location Filter Parameter';

    local procedure ActionCode(): Text
    begin
        exit('SALES_DOC_IMP');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.3');  //NPR5.54 [387428]
        //EXIT ('1.2');  //NPR5.54 [387130]
        //EXIT ('1.1');  //NPR5.53 [378678]
        //EXIT ('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do begin
            if DiscoverAction(
              ActionCode(),
              ActionDescription,
              ActionVersion(),
              Sender.Type::Generic,
              Sender."Subscriber Instances Allowed"::Multiple) then begin
                RegisterWorkflowStep('ImportDocument', 'respond();');
                RegisterWorkflow(false);
                RegisterDataSourceBinding(ThisDataSource);  //NPR5.53 [378678]

                RegisterOptionParameter('DocumentType', 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order', 'Order');
                RegisterBooleanParameter('SelectCustomer', true);
                RegisterTextParameter('SalesDocViewString', '');  //NPR5.54 [387130]
                                                                  //-NPR5.54 [387428]
                Sender.RegisterOptionParameter('LocationFrom', 'POS Store,Location Filter Parameter', 'POS Store');
                Sender.RegisterTextParameter('LocationFilter', '');
                //+NPR5.54 [387428]
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        SalesHeader: Record "Sales Header";
        JSON: Codeunit "NPR POS JSON Management";
        POSSale: Codeunit "NPR POS Sale";
        SelectCustomer: Boolean;
        DocumentType: Integer;
        LocationSource: Option "POS Store","Location Filter Parameter";
        LocationFilter: Text;
        SalesDocViewString: Text;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        SelectCustomer := JSON.GetBooleanParameter('SelectCustomer', true);
        DocumentType := JSON.GetIntegerParameter('DocumentType', true);
        SalesDocViewString := JSON.GetStringParameter('SalesDocViewString', false);  //NPR5.54 [387130]
        //-NPR5.54 [387428]
        LocationSource := JSON.GetIntegerParameter('LocationFrom', true);
        LocationFilter := JSON.GetStringParameter('LocationFilter', false);
        //+NPR5.54 [387428]

        if not CheckCustomer(POSSession, SelectCustomer) then
            exit;

        //IF NOT SelectDocument(POSSession, SalesHeader, DocumentType) THEN  //NPR5.54 [387130]-revoked
        //-NPR5.54 [387130]
        if not
            SelectDocument(
              POSSession,
              SalesHeader,
              DocumentType,
              SalesDocViewString,
              //-NPR5.54 [387428]
              LocationSource,
              LocationFilter)
        //+NPR5.54 [387428]
        then
            //+NPR5.54 [387130]
            exit;

        //-NPR5.54 [387428]
        SalesHeader.TestField("Bill-to Customer No.");
        POSSession.GetSale(POSSale);
        SetPosSaleCustomer(POSSale, SalesHeader."Bill-to Customer No.");
        //+NPR5.54 [387428]

        ImportFromDocument(Context, POSSession, FrontEnd, SalesHeader);
    end;

    local procedure CheckCustomer(POSSession: Codeunit "NPR POS Session"; SelectCustomer: Boolean): Boolean
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR Sale POS";
        Customer: Record Customer;
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."Customer No." <> '' then begin
            SalePOS.TestField("Customer Type", SalePOS."Customer Type"::Ord);
            exit(true);
        end;

        if not SelectCustomer then
            exit(true);

        if PAGE.RunModal(0, Customer) <> ACTION::LookupOK then
            exit(false);

        //-NPR5.54 [387428]-revoked
        // SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
        // SalePOS.VALIDATE("Customer No.", Customer."No.");
        // SalePOS.MODIFY(TRUE);
        // POSSale.RefreshCurrent();
        //+NPR5.54 [387428]-revoked
        SetPosSaleCustomer(POSSale, Customer."No.");  //NPR5.54 [387428]
        Commit;
        exit(true);
    end;

    local procedure SetPosSaleCustomer(POSSale: Codeunit "NPR POS Sale"; CustomerNo: Code[20])
    var
        SalePOS: Record "NPR Sale POS";
    begin
        //-NPR5.54 [387428]
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."Customer No." <> '' then
            exit;
        SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
        SalePOS.Validate("Customer No.", CustomerNo);
        SalePOS.Modify(true);
        POSSale.RefreshCurrent();
        POSSale.SetModified();
        //+NPR5.54 [387428]
    end;

    local procedure SelectDocument(POSSession: Codeunit "NPR POS Session"; var SalesHeader: Record "Sales Header"; DocumentType: Integer; SalesDocViewString: Text; LocationSource: Option "POS Store","Location Filter Parameter"; LocationFilter: Text): Boolean
    var
        RetailSalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        POSStore: Record "NPR POS Store";
        SalePOS: Record "NPR Sale POS";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        //-NPR5.54 [387130]
        if SalesDocViewString <> '' then
            SalesHeader.SetView(SalesDocViewString);
        SalesHeader.FilterGroup(2);
        //+NPR5.54 [387130]
        if SalePOS."Customer No." <> '' then
            SalesHeader.SetRange("Bill-to Customer No.", SalePOS."Customer No.");
        SalesHeader.SetRange("Document Type", DocumentType);
        //-NPR5.54 [387428]
        case LocationSource of
            LocationSource::"POS Store":
                begin
                    POSStore.Get(SalePOS."POS Store Code");
                    LocationFilter := POSStore."Location Code";
                end;
        end;
        if LocationFilter <> '' then
            SalesHeader.SetFilter("Location Code", LocationFilter);
        //+NPR5.54 [387428]
        //-NPR5.54 [387130]
        SalesHeader.FilterGroup(0);
        if SalesHeader.FindFirst then;
        exit(RetailSalesDocImpMgt.SelectSalesDocument('', SalesHeader));
        //+NPR5.54 [387130]
        //EXIT(RetailSalesDocImpMgt.SelectSalesDocument(SalesHeader.GETVIEW(FALSE), SalesHeader));  //NPR5.54 [387130]-revoked
    end;

    local procedure ImportFromDocument(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var SalesHeader: Record "Sales Header")
    var
        JSON: Codeunit "NPR POS JSON Management";
        RetailSalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
        SalePOS: Record "NPR Sale POS";
        POSSale: Codeunit "NPR POS Sale";
        DocumentType: Option Quote,"Order",Invoice,CreditMemo,BlanketOrder,ReturnOrder;
        OrderType: Option NotSet,"Order",Lending;
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        RetailSalesDocImpMgt.SalesDocumentToPOS(POSSession, SalesHeader);
        POSSession.RequestRefreshData();
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterNameCaption', '', false, false)]
    procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
            'DocumentType':
                Caption := CaptionDocType;
            'SelectCustomer':
                Caption := CaptionSelectCustomer;
            'SalesDocViewString':
                Caption := CaptionSalesView;  //NPR5.54 [387130]
                                              //-NPR5.54 [387428]
            'LocationFrom':
                Caption := CaptionLocationFrom;
            'LocationFilter':
                Caption := CaptionLocationFilter;
        //+NPR5.54 [387428]
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterDescriptionCaption', '', false, false)]
    procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
            'DocumentType':
                Caption := DescDocType;
            'SelectCustomer':
                Caption := DescSelectCustomer;
            'SalesDocViewString':
                Caption := DescSalesView;  //NPR5.54 [387130]
                                           //-NPR5.54 [387428]
            'LocationFrom':
                Caption := DescLocationFrom;
            'LocationFilter':
                Caption := DescLocationFilter;
        //+NPR5.54 [387428]
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterOptionStringCaption', '', false, false)]
    procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
            'DocumentType':
                Caption := OptionDocType;
            'LocationFrom':
                Caption := OptionLocationFrom;  //NPR5.54 [387428]
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', false, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        Location: Record Location;
        SalesHeader: Record "Sales Header";
        LocationList: Page "Location List";
        FilterPageBuilder: FilterPageBuilder;
    begin
        //-NPR5.54 [387130]
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
            'SalesDocViewString':
                begin
                    FilterPageBuilder.AddRecord(SalesHeader.TableCaption, SalesHeader);
                    if POSParameterValue.Value <> '' then begin
                        SalesHeader.SetView(POSParameterValue.Value);
                        FilterPageBuilder.SetView(SalesHeader.TableCaption, SalesHeader.GetView(false));
                    end;
                    if FilterPageBuilder.RunModal then
                        POSParameterValue.Value := FilterPageBuilder.GetView(SalesHeader.TableCaption, false);
                end;

            //-NPR5.54 [387428]
            'LocationFilter':
                begin
                    Clear(LocationList);
                    Location.SetRange("Use As In-Transit", false);
                    LocationList.SetTableView(Location);
                    LocationList.LookupMode(true);
                    if LocationList.RunModal = ACTION::LookupOK then
                        POSParameterValue.Value := LocationList.GetSelectionFilter();
                end;
        //+NPR5.54 [387428]
        end;
        //+NPR5.54 [387130]
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', false, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        SalesHeader: Record "Sales Header";
    begin
        //-NPR5.54 [387130]
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
            'SalesDocViewString':
                if POSParameterValue.Value <> '' then
                    SalesHeader.SetView(POSParameterValue.Value);
        end;
        //+NPR5.54 [387130]
    end;

    procedure "//Data Source Extension"()
    begin
    end;

    local procedure ThisDataSource(): Text
    begin
        exit('BUILTIN_SALE');  //NPR5.53 [378678]
    end;

    local procedure ThisExtension(): Text
    begin
        exit('SalesDoc');  //NPR5.53 [378678]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDiscoverDataSourceExtensions', '', true, false)]
    local procedure OnDiscoverDataSourceExtension(DataSourceName: Text; Extensions: DotNet NPRNetList_Of_T)
    begin
        //-NPR5.53 [378678]
        if ThisDataSource <> DataSourceName then
            exit;

        Extensions.Add(ThisExtension);
        //+NPR5.53 [378678]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnGetDataSourceExtension', '', true, false)]
    local procedure OnGetDataSourceExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: DotNet NPRNetDataSource0; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        DataType: DotNet NPRNetDataType;
    begin
        //-NPR5.53 [378678]
        if (DataSourceName <> ThisDataSource) or (ExtensionName <> ThisExtension) then
            exit;

        Handled := true;

        DataSource.AddColumn('OpenOrdersQty', 'Number of open sales orders', DataType.String, true);
        //+NPR5.53 [378678]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDataSourceExtensionReadData', '', true, false)]
    local procedure OnDataSourceExtensionReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: DotNet NPRNetDataRow0; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        SalesHeader: Record "Sales Header";
        LocationFilter: Text;
    begin
        //-NPR5.53 [378678]
        if (DataSourceName <> ThisDataSource) or (ExtensionName <> ThisExtension) then
            exit;

        Handled := true;

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange(Status, SalesHeader.Status::Open);
        //-NPR5.54 [387428]
        LocationFilter := GetPOSMenuButtonLocationFilter(POSSession);
        if LocationFilter <> '' then
            SalesHeader.SetFilter("Location Code", LocationFilter);
        //+NPR5.54 [387428]

        DataRow.Add('OpenOrdersQty', SalesHeader.Count);
        //+NPR5.53 [378678]
    end;

    local procedure GetPOSMenuButtonLocationFilter(POSSession: Codeunit "NPR POS Session"): Text
    var
        POSMenuButton: Record "NPR POS Menu Button";
        POSParameterValue: Record "NPR POS Parameter Value";
        POSStore: Record "NPR POS Store";
        SalePOS: Record "NPR Sale POS";
        POSSale: Codeunit "NPR POS Sale";
    begin
        //-NPR5.54 [387428]
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSMenuButton.SetRange("Action Code", ActionCode());
        POSMenuButton.SetRange("Register No.", SalePOS."Register No.");
        if not POSMenuButton.FindFirst then
            POSMenuButton.SetRange("Register No.");
        if not POSMenuButton.FindFirst then
            exit('');

        if not POSParameterValue.Get(DATABASE::"NPR POS Menu Button", POSMenuButton."Menu Code", POSMenuButton.ID, POSMenuButton.RecordId, 'LocationFrom') then
            exit('');

        case POSParameterValue.Value of
            'POS Store':
                begin
                    if not POSStore.Get(SalePOS."POS Store Code") then
                        POSStore.Init;
                    exit(POSStore."Location Code");
                end;
            'Location Filter Parameter':
                begin
                    if not POSParameterValue.Get(DATABASE::"NPR POS Menu Button", POSMenuButton."Menu Code", POSMenuButton.ID, POSMenuButton.RecordId, 'LocationFilter') then
                        POSParameterValue.Init;
                    exit(POSParameterValue.Value);
                end;
        end;

        exit('');
        //+NPR5.54 [387428]
    end;
}

