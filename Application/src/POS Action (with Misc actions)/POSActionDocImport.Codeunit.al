codeunit 6150861 "NPR POS Action: Doc. Import"
{
    var
        ActionDescription: Label 'Import an open standard NAV sales document to current POS sale and delete the document.';
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

    local procedure ActionCode(): Code[20]
    begin
        exit('SALES_DOC_IMP');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.4');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple) then begin
            Sender.RegisterWorkflowStep('ImportDocument', 'respond();');
            Sender.RegisterWorkflow(false);
            Sender.RegisterDataSourceBinding(ThisDataSource());

            Sender.RegisterOptionParameter('DocumentType', 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order', 'Order');
            Sender.RegisterBooleanParameter('SelectCustomer', true);
            Sender.RegisterTextParameter('SalesDocViewString', '');
            Sender.RegisterOptionParameter('LocationFrom', 'POS Store,Location Filter Parameter', 'POS Store');
            Sender.RegisterTextParameter('LocationFilter', '');
            Sender.RegisterBooleanParameter('ConfirmInvDiscAmt', false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        JSON: Codeunit "NPR POS JSON Management";
        POSSale: Codeunit "NPR POS Sale";
        SalesDocImpMgt: codeunit "NPR Sales Doc. Imp. Mgt.";
        SelectCustomer, ConfirmInvDiscAmt : Boolean;
        DocumentType: Integer;
        LocationSource: Option "POS Store","Location Filter Parameter";
        LocationFilter: Text;
        SalesDocViewString: Text;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        SelectCustomer := JSON.GetBooleanParameterOrFail('SelectCustomer', ActionCode());
        DocumentType := JSON.GetIntegerParameterOrFail('DocumentType', ActionCode());
        SalesDocViewString := JSON.GetStringParameter('SalesDocViewString');
        LocationSource := JSON.GetIntegerParameterOrFail('LocationFrom', ActionCode());
        LocationFilter := JSON.GetStringParameter('LocationFilter');

        if not CheckCustomer(POSSession, SelectCustomer) then
            exit;

        if not
            SelectDocument(
              POSSession,
              SalesHeader,
              DocumentType,
              SalesDocViewString,
              LocationSource,
              LocationFilter)
        then
            exit;

        SalesHeader.TestField("Bill-to Customer No.");
        ConfirmInvDiscAmt := JSON.GetBooleanParameterOrFail('ConfirmInvDiscAmt', ActionCode());
        if ConfirmInvDiscAmt then begin
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            SalesLine.SetFilter("Inv. Discount Amount", '>%1', 0);
            SalesLine.CalcSums("Inv. Discount Amount");
            if SalesLine."Inv. Discount Amount" > 0 then begin
                if not Confirm(SalesDocImpMgt.GetImportInvDiscAmtQst()) then
                    exit;
            end;
        end;
        POSSession.GetSale(POSSale);
        SetPosSaleCustomer(POSSale, SalesHeader."Bill-to Customer No.");

        ImportFromDocument(POSSession, SalesHeader);
    end;

    local procedure CheckCustomer(POSSession: Codeunit "NPR POS Session"; SelectCustomer: Boolean): Boolean
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
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

        SetPosSaleCustomer(POSSale, Customer."No.");
        Commit();
        exit(true);
    end;

    local procedure SetPosSaleCustomer(POSSale: Codeunit "NPR POS Sale"; CustomerNo: Code[20])
    var
        SalePOS: Record "NPR POS Sale";
    begin
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."Customer No." <> '' then
            exit;
        SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
        SalePOS.Validate("Customer No.", CustomerNo);
        SalePOS.Modify(true);
        POSSale.RefreshCurrent();
        POSSale.SetModified();
    end;

    local procedure SelectDocument(POSSession: Codeunit "NPR POS Session"; var SalesHeader: Record "Sales Header"; DocumentType: Integer; SalesDocViewString: Text; LocationSource: Option "POS Store","Location Filter Parameter"; LocationFilter: Text): Boolean
    var
        RetailSalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        POSStore: Record "NPR POS Store";
        SalePOS: Record "NPR POS Sale";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        if SalesDocViewString <> '' then
            SalesHeader.SetView(SalesDocViewString);
        SalesHeader.FilterGroup(2);
        if SalePOS."Customer No." <> '' then
            SalesHeader.SetRange("Bill-to Customer No.", SalePOS."Customer No.");
        SalesHeader.SetRange("Document Type", DocumentType);
        case LocationSource of
            LocationSource::"POS Store":
                begin
                    POSStore.Get(SalePOS."POS Store Code");
                    LocationFilter := POSStore."Location Code";
                end;
        end;
        if LocationFilter <> '' then
            SalesHeader.SetFilter("Location Code", LocationFilter);
        SalesHeader.FilterGroup(0);
        if SalesHeader.FindFirst() then;
        exit(RetailSalesDocImpMgt.SelectSalesDocument('', SalesHeader));
    end;

    local procedure ImportFromDocument(POSSession: Codeunit "NPR POS Session"; var SalesHeader: Record "Sales Header")
    var
        RetailSalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
    begin
        RetailSalesDocImpMgt.SalesDocumentToPOS(POSSession, SalesHeader);
        POSSession.RequestRefreshData();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterNameCaption', '', false, false)]
    local procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        SalesDocImpMgt: codeunit "NPR Sales Doc. Imp. Mgt.";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'DocumentType':
                Caption := CaptionDocType;
            'SelectCustomer':
                Caption := CaptionSelectCustomer;
            'SalesDocViewString':
                Caption := CaptionSalesView;
            'LocationFrom':
                Caption := CaptionLocationFrom;
            'LocationFilter':
                Caption := CaptionLocationFilter;
            'ConfirmInvDiscAmt':
                Caption := SalesDocImpMgt.GetConfirmInvDiscAmtLbl();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterDescriptionCaption', '', false, false)]
    local procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        SalesDocImpMgt: codeunit "NPR Sales Doc. Imp. Mgt.";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'DocumentType':
                Caption := DescDocType;
            'SelectCustomer':
                Caption := DescSelectCustomer;
            'SalesDocViewString':
                Caption := DescSalesView;
            'LocationFrom':
                Caption := DescLocationFrom;
            'LocationFilter':
                Caption := DescLocationFilter;
            'ConfirmInvDiscAmt':
                Caption := SalesDocImpMgt.GetConfirmInvDiscAmtDescLbl();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterOptionStringCaption', '', false, false)]
    local procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'DocumentType':
                Caption := OptionDocType;
            'LocationFrom':
                Caption := OptionLocationFrom;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        Location: Record Location;
        SalesHeader: Record "Sales Header";
        LocationList: Page "Location List";
        FilterPageBuilder: FilterPageBuilder;
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'SalesDocViewString':
                begin
                    FilterPageBuilder.AddRecord(SalesHeader.TableCaption, SalesHeader);
                    if POSParameterValue.Value <> '' then begin
                        SalesHeader.SetView(POSParameterValue.Value);
                        FilterPageBuilder.SetView(SalesHeader.TableCaption, SalesHeader.GetView(false));
                    end;
                    if FilterPageBuilder.RunModal() then
                        POSParameterValue.Value := CopyStr(FilterPageBuilder.GetView(SalesHeader.TableCaption, false), 1, MaxStrLen(POSParameterValue.Value));
                end;

            'LocationFilter':
                begin
                    Clear(LocationList);
                    Location.SetRange("Use As In-Transit", false);
                    LocationList.SetTableView(Location);
                    LocationList.LookupMode(true);
                    if LocationList.RunModal() = ACTION::LookupOK then
                        POSParameterValue.Value := CopyStr(LocationList.GetSelectionFilter(), 1, MaxStrLen(POSParameterValue.Value));
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        SalesHeader: Record "Sales Header";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'SalesDocViewString':
                if POSParameterValue.Value <> '' then
                    SalesHeader.SetView(POSParameterValue.Value);
        end;
    end;

    local procedure ThisDataSource(): Code[50]
    begin
        exit('BUILTIN_SALE');
    end;

    local procedure ThisExtension(): Text
    begin
        exit('SalesDoc');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDiscoverDataSourceExtensions', '', true, false)]
    local procedure OnDiscoverDataSourceExtension(DataSourceName: Text; Extensions: List of [Text])
    begin
        if ThisDataSource() <> DataSourceName then
            exit;

        Extensions.Add(ThisExtension());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnGetDataSourceExtension', '', true, false)]
    local procedure OnGetDataSourceExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        DataType: Enum "NPR Data Type";
    begin
        if (DataSourceName <> ThisDataSource()) or (ExtensionName <> ThisExtension()) then
            exit;

        Handled := true;

        DataSource.AddColumn('OpenOrdersQty', 'Number of open sales orders', DataType::String, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDataSourceExtensionReadData', '', true, false)]
    local procedure OnDataSourceExtensionReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: Codeunit "NPR Data Row"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        SalesHeader: Record "Sales Header";
        LocationFilter: Text;
    begin
        if (DataSourceName <> ThisDataSource()) or (ExtensionName <> ThisExtension()) then
            exit;

        Handled := true;

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange(Status, SalesHeader.Status::Open);
        LocationFilter := GetPOSMenuButtonLocationFilter(POSSession);
        if LocationFilter <> '' then
            SalesHeader.SetFilter("Location Code", LocationFilter);

        DataRow.Add('OpenOrdersQty', SalesHeader.Count());
    end;

    local procedure GetPOSMenuButtonLocationFilter(POSSession: Codeunit "NPR POS Session"): Text
    var
        POSMenuButton: Record "NPR POS Menu Button";
        POSParameterValue: Record "NPR POS Parameter Value";
        POSStore: Record "NPR POS Store";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSMenuButton.SetRange("Action Code", ActionCode());
        POSMenuButton.SetRange("Register No.", SalePOS."Register No.");
        if not POSMenuButton.FindFirst() then
            POSMenuButton.SetRange("Register No.");
        if not POSMenuButton.FindFirst() then
            exit('');

        if not POSParameterValue.Get(DATABASE::"NPR POS Menu Button", POSMenuButton."Menu Code", POSMenuButton.ID, POSMenuButton.RecordId, 'LocationFrom') then
            exit('');

        case POSParameterValue.Value of
            'POS Store':
                begin
                    if not POSStore.Get(SalePOS."POS Store Code") then
                        POSStore.Init();
                    exit(POSStore."Location Code");
                end;
            'Location Filter Parameter':
                begin
                    if not POSParameterValue.Get(DATABASE::"NPR POS Menu Button", POSMenuButton."Menu Code", POSMenuButton.ID, POSMenuButton.RecordId, 'LocationFilter') then
                        POSParameterValue.Init();
                    exit(POSParameterValue.Value);
                end;
        end;

        exit('');
    end;
}
