codeunit 6150861 "NPR POS Action: Doc. Import" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Import an open standard NAV sales document to current POS sale and delete the document.';
        ParamDocType_CptLbl: Label 'Document Type';
        ParamDocTypeOpt_Lbl: Label 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order', Locked = true;
        ParamDocTypeOpt_CptLbl: Label 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
        ParamDocType_DescLbl: Label 'Filter on Document Type';
        ParamSelectCust_Lbl: Label 'Select Customer';
        ParamSelectCust_DescLbl: Label 'Prompt for customer selection if none on sale';
        ParamSalesDocView_CptLbl: Label 'Sales Document View String';
        ParamSalesDocView_DescLbl: Label 'Pre-filtered list of sales documents';
        ParamLocationFrom_CptLbl: Label 'Location From';
        ParamLocationFrom_DescLbl: Label 'Pre-filtered location option';
        ParamLocationFrom_OptionsLbl: Label 'POS Store,Location Filter Parameter', Locked = true;
        ParamLocationFrom_OptionsCptLbl: Label 'POS Store, Location Filter Parameter';
        ParamLocation_CptLbl: Label 'Location Filter';
        ParamLocation_DescLbl: Label 'Pre-filtered location';
        ParamConfirmDiscAmt_CptLbl: Label 'Confirm Invoice Discount Amount';
        ParamConfirmDiscAmt_DescLbl: Label 'Enable/Disable Invoice Discount Amount confirmation';
        ParamEnableSalesPerson_CptLbl: Label 'Enable Salesperson from Order';
        ParamEnableSalesPerson_DescLbl: Label 'Keeps salesperson from sales order';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddOptionParameter('DocumentType',
                                         ParamDocTypeOpt_Lbl,
                                         SelectStr(2, ParamDocTypeOpt_Lbl),
                                         ParamDocType_CptLbl,
                                         ParamDocType_DescLbl,
                                         ParamDocTypeOpt_CptLbl);
        WorkflowConfig.AddBooleanParameter('SelectCustomer', true, ParamSelectCust_Lbl, ParamSelectCust_DescLbl);
        WorkflowConfig.AddTextParameter('SalesDocViewString', '', ParamSalesDocView_CptLbl, ParamSalesDocView_DescLbl);
        WorkflowConfig.AddOptionParameter('LocationFrom',
                                  ParamLocationFrom_OptionsLbl,
                                  SelectStr(1, ParamLocationFrom_OptionsLbl),
                                  ParamLocationFrom_CptLbl,
                                  ParamLocationFrom_DescLbl,
                                  ParamLocationFrom_OptionsCptLbl);
        WorkflowConfig.AddTextParameter('LocationFilter', '', ParamLocation_CptLbl, ParamLocation_DescLbl);
        WorkflowConfig.AddBooleanParameter('ConfirmInvDiscAmt', false, ParamConfirmDiscAmt_CptLbl, ParamConfirmDiscAmt_DescLbl);
        WorkflowConfig.AddBooleanParameter('EnableSalesPersonFromOrder', false, ParamEnableSalesPerson_CptLbl, ParamEnableSalesPerson_DescLbl);
    end;


    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        ImportDoc(Context, Sale);
    end;

    local procedure ImportDoc(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale")
    var
        SelectCustomer, ConfirmInvDiscAmt, SalesPersonFromOrder : Boolean;
        DocumentType: Integer;
        LocationSource: Option "POS Store","Location Filter Parameter";
        LocationFilter: Text;
        SalesDocViewString: Text;
        POSActionDocImpB: Codeunit "NPR POS Action: Doc. Import B";
    begin
        SelectCustomer := Context.GetBooleanParameter('SelectCustomer');
        DocumentType := Context.GetIntegerParameter('DocumentType');
        SalesDocViewString := Context.GetStringParameter('SalesDocViewString');
        LocationSource := Context.GetIntegerParameter('LocationFrom');
        LocationFilter := Context.GetStringParameter('LocationFilter');
        SalesPersonFromOrder := Context.GetBooleanParameter('EnableSalesPersonFromOrder');
        ConfirmInvDiscAmt := Context.GetBooleanParameter('ConfirmInvDiscAmt');

        POSActionDocImpB.ImportDocument(SelectCustomer,
                                        ConfirmInvDiscAmt,
                                        DocumentType,
                                        LocationSource,
                                        LocationFilter,
                                        SalesDocViewString,
                                        SalesPersonFromOrder,
                                        Sale);
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
        POSMenuMgt: Codeunit "NPR POS Menu Mgt.";
        SalesHeader: Record "Sales Header";
        LocationFilter: Text;
    begin
        if (DataSourceName <> ThisDataSource()) or (ExtensionName <> ThisExtension()) then
            exit;

        Handled := true;

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange(Status, SalesHeader.Status::Open);
        LocationFilter := POSMenuMgt.GetPOSMenuButtonLocationFilter(POSSession, ActionCode());
        if LocationFilter <> '' then
            SalesHeader.SetFilter("Location Code", LocationFilter);

        DataRow.Add('OpenOrdersQty', SalesHeader.Count());
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionDocImport.js###
'let main=async({})=>await workflow.respond();'
       )
    end;

    procedure ActionCode(): Text
    begin
        exit(Format(enum::"NPR POS Workflow"::SALES_DOC_IMP));
    end;
}
