codeunit 6150861 "POS Action - Doc. Import"
{
    // NPR5.50/MMV /20181105 CASE 300557 New action, based on CU 6150815
    // NPR5.53/ALPO/20191211 CASE 378678 Data source extension to have number of open sales orders available for displaying on a POS button


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Import an open standard NAV sales document to current POS sale and delete the document.';
        Setup: Codeunit "POS Setup";
        REMOVE: Codeunit "Retail Sales Doc. Mgt.";
        ERRDOCTYPE: Label 'Wrong Document Type. Document Type is set to %1. It must be one of %2, %3, %4 or %5';
        ERRPARSED: Label 'SalesDocumentToPOS and SalesDocumentAmountToPOS can not be used simultaneously. This is an error in parameter setting on menu button for action %1.';
        ERRPARSEDCOMB: Label 'Import of amount is only supported for Document Type Order. This is an error in parameter setting on menu button for action %1.';
        CaptionDocType: Label 'Document Type';
        CaptionSelectCustomer: Label 'Select Customer';
        DescSelectCustomer: Label 'Prompt for customer selection if none on sale';
        DescDocType: Label 'Filter on Document Type';
        OptionDocType: Label 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';

    local procedure ActionCode(): Text
    begin
        exit ('SALES_DOC_IMP');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.1');  //NPR5.53 [378678]
        //EXIT ('1.0');  //NPR5.53 [378678]-revoked
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do begin
          if DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple) then
          begin
            RegisterWorkflowStep('ImportDocument','respond();');
            RegisterWorkflow(false);
            RegisterDataSourceBinding(ThisDataSource);  //NPR5.53 [378678]

            RegisterOptionParameter('DocumentType', 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order', 'Order');
            RegisterBooleanParameter('SelectCustomer', true);
          end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        SalesHeader: Record "Sales Header";
        JSON: Codeunit "POS JSON Management";
        SelectCustomer: Boolean;
        DocumentType: Integer;
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        SelectCustomer := JSON.GetBooleanParameter('SelectCustomer', true);
        DocumentType := JSON.GetIntegerParameter('DocumentType', true);

        if not CheckCustomer(POSSession, SelectCustomer) then
          exit;

        if not SelectDocument(POSSession, SalesHeader, DocumentType) then
          exit;

        ImportFromDocument(Context, POSSession,FrontEnd, SalesHeader);
    end;

    local procedure CheckCustomer(POSSession: Codeunit "POS Session";SelectCustomer: Boolean): Boolean
    var
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
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

        SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);
        POSSale.RefreshCurrent();
        Commit;
        exit(true);
    end;

    local procedure SelectDocument(POSSession: Codeunit "POS Session";var SalesHeader: Record "Sales Header";DocumentType: Integer): Boolean
    var
        RetailSalesDocImpMgt: Codeunit "Retail Sales Doc. Imp. Mgt.";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        if SalePOS."Customer No." <> '' then
          SalesHeader.SetRange("Bill-to Customer No.", SalePOS."Customer No.");
        SalesHeader.SetRange("Document Type", DocumentType);
        exit(RetailSalesDocImpMgt.SelectSalesDocument(SalesHeader.GetView(false), SalesHeader));
    end;

    local procedure ImportFromDocument(Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var SalesHeader: Record "Sales Header")
    var
        JSON: Codeunit "POS JSON Management";
        RetailSalesDocImpMgt: Codeunit "Retail Sales Doc. Imp. Mgt.";
        SalePOS: Record "Sale POS";
        POSSale: Codeunit "POS Sale";
        DocumentType: Option Quote,"Order",Invoice,CreditMemo,BlanketOrder,ReturnOrder;
        OrderType: Option NotSet,"Order",Lending;
        POSSaleLine: Codeunit "POS Sale Line";
    begin
        RetailSalesDocImpMgt.SalesDocumentToPOS(POSSession, SalesHeader);
        POSSession.RequestRefreshData();
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterNameCaption', '', false, false)]
    procedure OnGetParameterNameCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'DocumentType' : Caption := CaptionDocType;
          'SelectCustomer' : Caption := CaptionSelectCustomer;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterDescriptionCaption', '', false, false)]
    procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'DocumentType' : Caption := DescDocType;
          'SelectCustomer' : Caption := DescSelectCustomer;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterOptionStringCaption', '', false, false)]
    procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'DocumentType' : Caption := OptionDocType;
        end;
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
    local procedure OnDiscoverDataSourceExtension(DataSourceName: Text;Extensions: DotNet npNetList_Of_T)
    begin
        //-NPR5.53 [378678]
        if ThisDataSource <> DataSourceName then
          exit;

        Extensions.Add(ThisExtension);
        //+NPR5.53 [378678]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnGetDataSourceExtension', '', true, false)]
    local procedure OnGetDataSourceExtension(DataSourceName: Text;ExtensionName: Text;var DataSource: DotNet npNetDataSource0;var Handled: Boolean;Setup: Codeunit "POS Setup")
    var
        DataType: DotNet npNetDataType;
    begin
        //-NPR5.53 [378678]
        if (DataSourceName <> ThisDataSource) or (ExtensionName <> ThisExtension) then
          exit;

        Handled := true;

        DataSource.AddColumn('OpenOrdersQty','Number of open sales orders',DataType.String,true);
        //+NPR5.53 [378678]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDataSourceExtensionReadData', '', true, false)]
    local procedure OnDataSourceExtensionReadData(DataSourceName: Text;ExtensionName: Text;var RecRef: RecordRef;DataRow: DotNet npNetDataRow0;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        SalesHeader: Record "Sales Header";
    begin
        //-NPR5.53 [378678]
        if (DataSourceName <> ThisDataSource) or (ExtensionName <> ThisExtension) then
          exit;

        Handled := true;

        SalesHeader.SetRange("Document Type",SalesHeader."Document Type"::Order);
        SalesHeader.SetRange(Status,SalesHeader.Status::Open);

        DataRow.Add('OpenOrdersQty',SalesHeader.Count);
        //+NPR5.53 [378678]
    end;
}

