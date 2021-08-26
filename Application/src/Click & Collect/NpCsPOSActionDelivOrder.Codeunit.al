codeunit 6151203 "NPR NpCs POSAction Deliv.Order"
{
    var
        DeliverCollectInStoreLbl: Label 'Deliver Collect in Store Documents';
        CollectInStoreLbl: Label 'Collect in Store';
        EnterCollectRefNoLbl: Label 'Enter Collect Reference No.';
        ProcessingStatusQst: Label 'Processing Status is ''%1''.\Continue delivering %2 %3?', Comment = '%1=NpCsDocument."Processing Status";%2=NpCsDocument."Document Type";%3=NpCsDocument."Reference No."';
        DeliveryStatusQst: Label 'Delivery Status is ''%1''.\Continue delivering %2 %3?', Comment = '%1=NpCsDocument."Processing Status";%2=NpCsDocument."Document Type";%3=NpCsDocument."Reference No."';
        EmptyLinesOnDocumentErr: Label 'Document ''%1'' has no lines to deliver.', Comment = '%1=NpCsDocument."Reference No."';
        DeliveryLbl: Label 'Collect %1 %2', Comment = '%1=NpCsDocument."Document Type";%2=NpCsDocument."Reference No."';
        SalesLineTypeNotSupportedErr: Label 'Supported types are %1, %2 and %3.', Comment = '%1=SalesLine.Type::"";%2=SalesLine.Type::Item;%3=SalesLine.Type::"G/L Account"';
        PrepaidAmountLbl: Label 'Prepaid Amount %1', Comment = '%1=POS Menu Button Parameter Value';
        FoundDeliverReferenceErr: Label 'Collect %1 %2 is already being delivery on current sale', Comment = '%1=NpCsDocument."Document Type";%2=NpCsDocument."Document No."';
        OpenDocumentLbl: Label 'Open Document';
        OpenDocumentDescriptionLbl: Label 'Open the selected order before document is delivered';

    local procedure ActionCode(): Text[20]
    begin
        exit('DELIVER_COLLECT_ORD');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.3');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverActions(var Sender: Record "NPR POS Action")
    begin
        if not Sender.DiscoverAction(
          ActionCode(),
          DeliverCollectInStoreLbl,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple) then
            exit;

        Sender.RegisterWorkflowStep('document_input', 'input({title: labels.DocumentInputTitle,caption: labels.ReferenceNo,value: ""}).cancel(abort);');
        Sender.RegisterWorkflowStep('select_document', 'respond();');
        Sender.RegisterWorkflowStep('deliver_document', 'if(context.entry_no) {respond();}');
        Sender.RegisterWorkflow(false);
        Sender.RegisterDataSourceBinding('BUILTIN_SALE');
        Sender.RegisterCustomJavaScriptLogic('enable', 'return row.getField("CollectInStore.ProcessedOrdersExists").rawValue;');
        Sender.RegisterOptionParameter('Location From', 'POS Store,Location Filter Parameter', 'POS Store');
        Sender.RegisterTextParameter('Location Filter', '');
        Sender.RegisterTextParameter('Delivery Text', DeliveryLbl);
        Sender.RegisterTextParameter('Prepaid Text', PrepaidAmountLbl);
        Sender.RegisterOptionParameter('Sorting', 'Entry No.,Reference No.,Delivery expires at', 'Entry No.');
        Sender.RegisterBooleanParameter('OpenDocument', false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'DocumentInputTitle', CollectInStoreLbl);
        Captions.AddActionCaption(ActionCode(), 'ReferenceNo', EnterCollectRefNoLbl);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', true, true)]
    local procedure OnLookupLocationFilter(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
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

        if PAGE.RunModal(0, Location) = ACTION::LookupOK then
            POSParameterValue.Value := Location.Code;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', true, true)]
    local procedure OnValidateLocationFilter(var POSParameterValue: Record "NPR POS Parameter Value")
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
        Location.SetFilter(Code, POSParameterValue.Value);
        if not Location.FindFirst() then begin
            Location.SetFilter(Code, '%1', POSParameterValue.Value + '*');
            if Location.FindFirst() then
                POSParameterValue.Value := Location.Code;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterNameCaption', '', false, false)]
    local procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'OpenDocument':
                Caption := OpenDocumentLbl;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterDescriptionCaption', '', false, false)]
    local procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'OpenDocument':
                Caption := OpenDocumentDescriptionLbl;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', true, true)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
    begin
        if Handled then
            exit;
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        case WorkflowStep of
            'select_document':
                begin
                    OnActionSelectDocument(JSON, POSSession, FrontEnd);
                end;
            'deliver_document':
                begin
                    OnActionDeliverDocument(JSON, POSSession);
                    POSSession.RequestRefreshData();
                end;
        end;
    end;

    local procedure OnActionSelectDocument(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        if not FindDocument(JSON, POSSession, NpCsDocument) then
            exit;

        if not ConfirmDocumentStatus(NpCsDocument) then
            exit;

        if not ConfirmOpenDocument(JSON, NpCsDocument) then
            exit;

        JSON.SetContext('entry_no', NpCsDocument."Entry No.");
        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure OnActionDeliverDocument(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        NpCsDocument: Record "NPR NpCs Document";
        EntryNo: Integer;
    begin
        JSON.SetContext('/', false);
        EntryNo := JSON.GetInteger('entry_no');
        if EntryNo = 0 then
            exit;

        NpCsDocument.Get(EntryNo);
        case NpCsDocument."Document Type" of
            NpCsDocument."Document Type"::Order:
                begin
                    DeliverOrder(JSON, POSSession, NpCsDocument);
                end;
            NpCsDocument."Document Type"::"Posted Invoice":
                begin
                    DeliverPostedInvoice(JSON, POSSession, NpCsDocument);
                end;
        end;
    end;

    local procedure DeliverOrder(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsSaleLinePOSReference: Record "NPR NpCs Sale Line POS Ref.";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalesDocImpMgt: codeunit "NPR Sales Doc. Imp. Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        RemainingAmount: Decimal;
    begin
        SalesHeader.Get(SalesHeader."Document Type"::Order, NpCsDocument."Document No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.IsEmpty() then
            Error(EmptyLinesOnDocumentErr, NpCsDocument."Reference No.");

        SalesLine.SetFilter(Type, '%1|%2|%3', SalesLine.Type::" ", SalesLine.Type::"G/L Account", SalesLine.Type::Item);
        if SalesLine.IsEmpty() then
            Error(SalesLineTypeNotSupportedErr, SalesLine.Type::" ", SalesLine.Type::"G/L Account", SalesLine.Type::Item);

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);

        if SalePOS."Customer No." <> '' then begin
            SalePOS.TestField("Customer Type", SalePOS."Customer Type"::Ord);
            SalePOS.TestField("Customer No.", SalesHeader."Bill-to Customer No.");
        end else begin
            SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
            SalePOS.Validate("Customer No.", SalesHeader."Bill-to Customer No.");
            SalePOS.Modify(true);
            POSSale.RefreshCurrent();
        end;

        POSSession.GetSaleLine(POSSaleLine);

        InsertDocumentReference(JSON, NpCsDocument, POSSaleLine, NpCsSaleLinePOSReference);

        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        RemainingAmount := SalesDocImpMgt.GetTotalAmountToBeInvoiced(SalesHeader);
        SalesHeader.Invoice := true;
        SalesHeader.Ship := true;
        SalesHeader.Receive := false;
        SalesHeader."Print Posted Documents" := false;
        SalesDocImpMgt.SalesDocumentPaymentAmountToPOSSaleLine(RemainingAmount, SaleLinePOS, SalesHeader, false, false, true);
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        POSSaleLine.InsertLineRaw(SaleLinePOS, false);
    end;

    local procedure DeliverPostedInvoice(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsSaleLinePOSReference: Record "NPR NpCs Sale Line POS Ref.";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalesDocImpMgt: codeunit "NPR Sales Doc. Imp. Mgt.";
        RemainingAmount: Decimal;
    begin
        SalesInvHeader.Get(NpCsDocument."Document No.");
        POSSession.GetSaleLine(POSSaleLine);
        SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
        if SalesInvLine.IsEmpty() then
            Error(EmptyLinesOnDocumentErr, NpCsDocument."Reference No.");

        SalesInvLine.SetFilter(Type, '%1|%2|%3', SalesInvLine.Type::" ", SalesInvLine.Type::"G/L Account", SalesInvLine.Type::Item);
        if SalesInvLine.IsEmpty() then
            Error(SalesLineTypeNotSupportedErr, SalesInvLine.Type::" ", SalesInvLine.Type::"G/L Account", SalesInvLine.Type::Item);

        InsertDocumentReference(JSON, NpCsDocument, POSSaleLine, NpCsSaleLinePOSReference);

        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        RemainingAmount := SalesDocImpMgt.GetTotalAmountToBeInvoiced(SalesInvHeader);
        SalesDocImpMgt.SalesDocumentPaymentAmountToPOSSaleLine(RemainingAmount, SaleLinePOS, SalesInvHeader, false, false, true);
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        POSSaleLine.InsertLineRaw(SaleLinePOS, false);
    end;

    local procedure InsertDocumentReference(JSON: Codeunit "NPR POS JSON Management"; NpCsDocument: Record "NPR NpCs Document"; POSSaleLine: Codeunit "NPR POS Sale Line"; var NpCsSaleLinePOSReference: Record "NPR NpCs Sale Line POS Ref.")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        DeliveryText: Text;
    begin
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        NpCsSaleLinePOSReference.SetRange("Register No.", SaleLinePOS."Register No.");
        NpCsSaleLinePOSReference.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        NpCsSaleLinePOSReference.SetRange("Document Type", NpCsDocument."Document Type");
        NpCsSaleLinePOSReference.SetRange("Document No.", NpCsDocument."Document No.");
        if not NpCsSaleLinePOSReference.IsEmpty() then
            Error(FoundDeliverReferenceErr, NpCsDocument."Document Type", NpCsDocument."Document No.");

        DeliveryText := StrSubstNo(JSON.GetStringParameter('Delivery Text'), NpCsDocument."Document Type", NpCsDocument."Reference No.");
        if DeliveryText = '' then
            DeliveryText := StrSubstNo(DeliveryLbl, NpCsDocument."Document Type", NpCsDocument."Reference No.");
        SaleLinePOS.Init();
        SaleLinePOS.Type := SaleLinePOS.Type::Comment;
        SaleLinePOS."No." := '*';
        SaleLinePOS.Description := CopyStr(DeliveryText, 1, MaxStrLen(SaleLinePOS.Description));
        POSSaleLine.InsertLine(SaleLinePOS);

        if NpCsSaleLinePOSReference.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS."Sale Type", SaleLinePOS.Date, SaleLinePOS."Line No.") then
            NpCsSaleLinePOSReference.Delete();

        NpCsSaleLinePOSReference.Init();
        NpCsSaleLinePOSReference."Register No." := SaleLinePOS."Register No.";
        NpCsSaleLinePOSReference."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        NpCsSaleLinePOSReference."Sale Type" := SaleLinePOS."Sale Type";
        NpCsSaleLinePOSReference."Sale Date" := SaleLinePOS.Date;
        NpCsSaleLinePOSReference."Sale Line No." := SaleLinePOS."Line No.";
        NpCsSaleLinePOSReference."Collect Document Entry No." := NpCsDocument."Entry No.";
        NpCsSaleLinePOSReference."Document No." := NpCsDocument."Document No.";
        NpCsSaleLinePOSReference."Document Type" := NpCsDocument."Document Type";
        NpCsSaleLinePOSReference.Insert();
    end;

    local procedure FindDocument(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; var NpCsDocument: Record "NPR NpCs Document"): Boolean
    begin
        if FindDocumentFromInput(JSON, NpCsDocument) then
            exit(true);

        if SelectDocument(JSON, POSSession, NpCsDocument) then
            exit(true);

        exit(false);
    end;

    local procedure ConfirmOpenDocument(JSON: Codeunit "NPR POS JSON Management"; NpCsDocument: Record "NPR NpCs Document"): Boolean
    var
        SalesHeader: Record "Sales Header";
        OpenDocument: Boolean;
    begin
        OpenDocument := JSON.GetBooleanParameterOrFail('OpenDocument', ActionCode());
        if OpenDocument then begin
            SalesHeader."Document Type" := NpCsDocument."Document Type";
            SalesHeader."No." := NpCsDocument."Document No.";
            SalesHeader.SetRecFilter();
            exit(PAGE.RunModal(SalesHeader.GetCardpageID(), SalesHeader) = ACTION::LookupOK);
        end;
        exit(true);
    end;

    local procedure ConfirmDocumentStatus(NpCsDocument: Record "NPR NpCs Document") Confirmed: Boolean
    begin
        if NpCsDocument."Delivery Status" = NpCsDocument."Delivery Status"::Ready then
            exit(true);

        if NpCsDocument."Delivery Status" = NpCsDocument."Delivery Status"::" " then begin
            Confirmed := Confirm(ProcessingStatusQst, false, NpCsDocument."Processing Status", NpCsDocument."Document Type", NpCsDocument."Reference No.");
            exit(Confirmed);
        end;

        Confirmed := Confirm(DeliveryStatusQst, false, NpCsDocument."Delivery Status", NpCsDocument."Document Type", NpCsDocument."Reference No.");
        exit(Confirmed);
    end;

    local procedure FindDocumentFromInput(JSON: Codeunit "NPR POS JSON Management"; var NpCsDocument: Record "NPR NpCs Document"): Boolean
    var
        ReferenceNo: Text;
    begin
        JSON.SetScope('/');
        if not JSON.SetScope('$document_input') then
            exit(false);

        ReferenceNo := CopyStr(JSON.GetString('input'), 1, MaxStrLen(NpCsDocument."Reference No."));
        if ReferenceNo = '' then
            exit(false);

        NpCsDocument.SetRange("Reference No.", ReferenceNo);
        NpCsDocument.SetRange(Type, NpCsDocument.Type::"Collect in Store");
        exit(NpCsDocument.FindFirst());
    end;

    local procedure SelectDocument(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; var NpCsDocument: Record "NPR NpCs Document"): Boolean
    var
        LocationFilter: Text;
        Sorting: Option "Entry No.","Reference No.","Delivery expires at";
    begin
        LocationFilter := GetLocationFilter(JSON, POSSession);

        Clear(NpCsDocument);
        NpCsDocument.SetRange(Type, NpCsDocument.Type::"Collect in Store");
        NpCsDocument.SetRange("Delivery Status", NpCsDocument."Delivery Status"::Ready);
        if LocationFilter <> '' then
            NpCsDocument.SetFilter("Location Code", LocationFilter);
        case JSON.GetIntegerParameter('Sorting') of
            Sorting::"Entry No.":
                begin
                    NpCsDocument.SetCurrentKey("Entry No.");
                end;
            Sorting::"Reference No.":
                begin
                    NpCsDocument.SetCurrentKey("Reference No.");
                end;
            Sorting::"Delivery expires at":
                begin
                    NpCsDocument.SetCurrentKey("Delivery expires at");
                end;
        end;
        if PAGE.RunModal(PAGE::"NPR NpCs Coll. Store Orders", NpCsDocument) = ACTION::LookupOK then
            exit(true);

        exit(false);
    end;

    local procedure GetLocationFilter(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session") LocationFilter: Text
    var
        POSStore: Record "NPR POS Store";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        case JSON.GetIntegerParameterOrFail('Location From', ActionCode()) of
            0:
                begin
                    POSSession.GetSetup(POSSetup);
                    POSSetup.GetPOSStore(POSStore);
                    LocationFilter := POSStore."Location Code";
                end;
            1:
                begin
                    LocationFilter := UpperCase(JSON.GetStringParameterOrFail('Location Filter', ActionCode()));
                end;
        end;

        exit(LocationFilter);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnGetDataSourceExtension', '', false, false)]
    local procedure OnGetExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        DataType: Enum "NPR Data Type";
    begin
        if DataSourceName <> 'BUILTIN_SALE' then
            exit;
        if ExtensionName <> 'CollectInStore' then
            exit;

        Handled := true;

        DataSource.AddColumn('ProcessedOrdersExists', 'Processed Orders Exists', DataType::Boolean, false);
        DataSource.AddColumn('ProcessedOrdersQty', 'Processed Orders Qty.', DataType::Integer, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDataSourceExtensionReadData', '', false, false)]
    local procedure OnReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: Codeunit "NPR Data Row"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        ProcessedOrdersExists: Boolean;
        LocationFilter: Text;
    begin
        if DataSourceName <> 'BUILTIN_SALE' then
            exit;
        if ExtensionName <> 'CollectInStore' then
            exit;

        Handled := true;

        LocationFilter := GetPOSMenuButtonLocationFilter(POSSession);
        ProcessedOrdersExists := GetProcessedOrdersExists(LocationFilter);
        DataRow.Fields().Add('ProcessedOrdersExists', ProcessedOrdersExists);
        if ProcessedOrdersExists then
            DataRow.Fields().Add('ProcessedOrdersQty', GetProcessedOrdersQty(LocationFilter))
        else
            DataRow.Fields().Add('ProcessedOrdersQty', 0);
    end;

    local procedure GetPOSMenuButtonLocationFilter(POSSession: Codeunit "NPR POS Session"): Text
    var
        POSStore: Record "NPR POS Store";
        POSMenuButton: Record "NPR POS Menu Button";
        POSParameterValue: Record "NPR POS Parameter Value";
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

        if not POSParameterValue.Get(DATABASE::"NPR POS Menu Button", POSMenuButton."Menu Code", POSMenuButton.ID, POSMenuButton.RecordId, 'Location From') then
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
                    if POSParameterValue.Get(DATABASE::"NPR POS Menu Button", POSMenuButton."Menu Code", POSMenuButton.ID, POSMenuButton.RecordId, 'Location Filter') then;
                    exit(POSParameterValue.Value);
                end;
        end;

        exit('');
    end;

    local procedure GetProcessedOrdersExists(LocationFilter: Text): Boolean
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        SetProcessedFilter(LocationFilter, NpCsDocument);
        exit(NpCsDocument.FindFirst());
    end;

    local procedure GetProcessedOrdersQty(LocationFilter: Text): Integer
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        SetProcessedFilter(LocationFilter, NpCsDocument);
        exit(NpCsDocument.Count());
    end;

    local procedure SetProcessedFilter(LocationFilter: Text; var NpCsDocument: Record "NPR NpCs Document")
    begin
        NpCsDocument.SetRange(Type, NpCsDocument.Type::"Collect in Store");
        NpCsDocument.SetRange("Processing Status", NpCsDocument."Processing Status"::Confirmed);
        NpCsDocument.SetRange("Delivery Status", NpCsDocument."Delivery Status"::Ready);
        NpCsDocument.SetFilter("Location Code", LocationFilter);
    end;
}
