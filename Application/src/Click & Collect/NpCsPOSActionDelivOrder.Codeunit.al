codeunit 6151203 "NPR NpCs POSAction Deliv.Order"
{
    var
        Text000: Label 'Deliver Collect in Store Documents';
        Text001: Label 'Collect in Store';
        Text002: Label 'Enter Collect Reference No.:';
        Text003: Label 'Processing Status is ''%1''.\Continue delivering %2 %3?';
        Text004: Label 'Delivery Status is ''%1''.\Continue delivering %2 %3?';
        Text005: Label 'Document ''%1'' has no lines to deliver.';
        Text006: Label 'Collect %1 %2';
        Text007: Label 'Sales Line Type %1 is not supported';
        Text008: Label 'Prepaid Amount %1';
        Text009: Label 'Collect %1 %2 is already being delivery on current sale';

    local procedure ActionCode(): Text
    begin
        exit('DELIVER_COLLECT_ORD');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.2');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverActions(var Sender: Record "NPR POS Action")
    begin
        if not Sender.DiscoverAction(
          ActionCode(),
          Text000,
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
        Sender.RegisterTextParameter('Delivery Text', Text006);
        Sender.RegisterTextParameter('Prepaid Text', Text008);
        Sender.RegisterOptionParameter('Sorting', 'Entry No.,Reference No.,Delivery expires at', 'Entry No.');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'DocumentInputTitle', Text001);
        Captions.AddActionCaption(ActionCode(), 'ReferenceNo', Text002);
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', true, true)]
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

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', true, true)]
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
        if not Location.FindFirst then begin
            Location.SetFilter(Code, '%1', POSParameterValue.Value + '*');
            if Location.FindFirst then
                POSParameterValue.Value := Location.Code;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', true, true)]
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
        POSSaleLine: Codeunit "NPR POS Sale Line";
        PrepaidText: Text;
    begin
        SalesHeader.Get(SalesHeader."Document Type"::Order, NpCsDocument."Document No.");
        POSSession.GetSaleLine(POSSaleLine);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if not SalesLine.FindSet then
            Error(Text005, NpCsDocument."Reference No.");

        InsertDocumentReference(JSON, NpCsDocument, POSSaleLine, NpCsSaleLinePOSReference);

        repeat
            DeliverSalesLine(NpCsDocument, SalesLine, NpCsSaleLinePOSReference, POSSaleLine);
        until SalesLine.Next = 0;

        if NpCsDocument."Prepaid Amount" > 0 then begin
            PrepaidText := JSON.GetStringParameter('Prepaid Text');
            if PrepaidText = '' then
                PrepaidText := Text008;
            DeliverPrepaymentLine(NpCsDocument, NpCsSaleLinePOSReference, PrepaidText, POSSaleLine);
        end;
    end;

    local procedure DeliverPostedInvoice(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsSaleLinePOSReference: Record "NPR NpCs Sale Line POS Ref.";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        PrepaidText: Text;
    begin
        SalesInvHeader.Get(NpCsDocument."Document No.");
        POSSession.GetSaleLine(POSSaleLine);
        SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
        if not SalesInvLine.FindSet then
            Error(Text005, NpCsDocument."Reference No.");

        InsertDocumentReference(JSON, NpCsDocument, POSSaleLine, NpCsSaleLinePOSReference);

        repeat
            DeliverSalesInvLine(NpCsDocument, SalesInvLine, NpCsSaleLinePOSReference, POSSaleLine);
        until SalesInvLine.Next = 0;

        if NpCsDocument."Prepaid Amount" > 0 then begin
            PrepaidText := JSON.GetStringParameter('Prepaid Text');
            if PrepaidText = '' then
                PrepaidText := Text008;
            DeliverPrepaymentLine(NpCsDocument, NpCsSaleLinePOSReference, PrepaidText, POSSaleLine);
        end;
    end;

    local procedure InsertDocumentReference(JSON: Codeunit "NPR POS JSON Management"; NpCsDocument: Record "NPR NpCs Document"; POSSaleLine: Codeunit "NPR POS Sale Line"; var NpCsSaleLinePOSReference: Record "NPR NpCs Sale Line POS Ref.")
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        DeliveryText: Text;
    begin
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        NpCsSaleLinePOSReference.SetRange("Register No.", SaleLinePOS."Register No.");
        NpCsSaleLinePOSReference.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        NpCsSaleLinePOSReference.SetRange("Document Type", NpCsDocument."Document Type");
        NpCsSaleLinePOSReference.SetRange("Document No.", NpCsDocument."Document No.");
        if NpCsSaleLinePOSReference.FindFirst then
            Error(Text009, NpCsDocument."Document Type", NpCsDocument."Document No.");

        DeliveryText := StrSubstNo(JSON.GetStringParameter('Delivery Text'), NpCsDocument."Document Type", NpCsDocument."Reference No.");
        if DeliveryText = '' then
            DeliveryText := StrSubstNo(Text006, NpCsDocument."Document Type", NpCsDocument."Reference No.");
        SaleLinePOS.Init;
        SaleLinePOS.Type := SaleLinePOS.Type::Comment;
        SaleLinePOS."No." := '*';
        SaleLinePOS.Description := CopyStr(DeliveryText, 1, MaxStrLen(SaleLinePOS.Description));
        POSSaleLine.InsertLine(SaleLinePOS);

        if NpCsSaleLinePOSReference.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS."Sale Type", SaleLinePOS.Date, SaleLinePOS."Line No.") then
            NpCsSaleLinePOSReference.Delete;

        NpCsSaleLinePOSReference.Init;
        NpCsSaleLinePOSReference."Register No." := SaleLinePOS."Register No.";
        NpCsSaleLinePOSReference."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        NpCsSaleLinePOSReference."Sale Type" := SaleLinePOS."Sale Type";
        NpCsSaleLinePOSReference."Sale Date" := SaleLinePOS.Date;
        NpCsSaleLinePOSReference."Sale Line No." := SaleLinePOS."Line No.";
        NpCsSaleLinePOSReference."Collect Document Entry No." := NpCsDocument."Entry No.";
        NpCsSaleLinePOSReference."Document No." := NpCsDocument."Document No.";
        NpCsSaleLinePOSReference."Document Type" := NpCsDocument."Document Type";
        NpCsSaleLinePOSReference.Insert;
    end;

    local procedure DeliverPrepaymentLine(NpCsDocument: Record "NPR NpCs Document"; NpCsSaleLinePOSReference: Record "NPR NpCs Sale Line POS Ref."; PrepaidText: Text; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        NpCsSaleLinePOSReference2: Record "NPR NpCs Sale Line POS Ref.";
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        if not NpCsDocument."Store Stock" then
            exit;
        if NpCsDocument."Bill via" <> NpCsDocument."Bill via"::POS then
            exit;

        SaleLinePOS.Init;
        SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Deposit;
        SaleLinePOS.Type := SaleLinePOS.Type::"G/L Entry";
        SaleLinePOS."No." := NpCsDocument."Prepayment Account No.";
        SaleLinePOS."Unit Price" := -NpCsDocument."Prepaid Amount";
        SaleLinePOS.Quantity := 1;
        SaleLinePOS."Amount Including VAT" := -NpCsDocument."Prepaid Amount";
        POSSaleLine.InsertDepositLine(SaleLinePOS, -NpCsDocument."Prepaid Amount");
        SaleLinePOS.Validate("No.");
        SaleLinePOS.Description := CopyStr(StrSubstNo(PrepaidText, NpCsDocument."Reference No."), 1, MaxStrLen(SaleLinePOS.Description));
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        SaleLinePOS.Modify;

        NpCsSaleLinePOSReference2.Init;
        NpCsSaleLinePOSReference2."Register No." := SaleLinePOS."Register No.";
        NpCsSaleLinePOSReference2."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        NpCsSaleLinePOSReference2."Sale Type" := SaleLinePOS."Sale Type";
        NpCsSaleLinePOSReference2."Sale Date" := SaleLinePOS.Date;
        NpCsSaleLinePOSReference2."Sale Line No." := SaleLinePOS."Line No.";
        NpCsSaleLinePOSReference2."Collect Document Entry No." := NpCsSaleLinePOSReference."Collect Document Entry No.";
        NpCsSaleLinePOSReference2."Applies-to Line No." := NpCsSaleLinePOSReference."Sale Line No.";
        NpCsSaleLinePOSReference2."Document No." := NpCsSaleLinePOSReference."Document No.";
        NpCsSaleLinePOSReference2."Document Type" := NpCsSaleLinePOSReference."Document Type";
        NpCsSaleLinePOSReference2."Document Line No." := 0;
        NpCsSaleLinePOSReference2.Insert;
    end;

    local procedure DeliverSalesLine(NpCsDocument: Record "NPR NpCs Document"; SalesLine: Record "Sales Line"; NpCsSaleLinePOSReference: Record "NPR NpCs Sale Line POS Ref."; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        NpCsSaleLinePOSReference2: Record "NPR NpCs Sale Line POS Ref.";
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        case SalesLine.Type of
            SalesLine.Type::" ":
                begin
                    DeliverSalesLineComment(SalesLine, POSSaleLine, SaleLinePOS);
                end;
            SalesLine.Type::"G/L Account":
                begin
                    DeliverSalesLineGLAccount(NpCsDocument, SalesLine, POSSaleLine, SaleLinePOS);
                end;
            SalesLine.Type::Item:
                begin
                    DeliverSalesLineItem(NpCsDocument, SalesLine, POSSaleLine, SaleLinePOS);
                end;
            else
                Error(Text007, SalesLine.Type);
        end;

        NpCsSaleLinePOSReference2.Init;
        NpCsSaleLinePOSReference2."Register No." := SaleLinePOS."Register No.";
        NpCsSaleLinePOSReference2."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        NpCsSaleLinePOSReference2."Sale Type" := SaleLinePOS."Sale Type";
        NpCsSaleLinePOSReference2."Sale Date" := SaleLinePOS.Date;
        NpCsSaleLinePOSReference2."Sale Line No." := SaleLinePOS."Line No.";
        NpCsSaleLinePOSReference2."Collect Document Entry No." := NpCsSaleLinePOSReference."Collect Document Entry No.";
        NpCsSaleLinePOSReference2."Applies-to Line No." := NpCsSaleLinePOSReference."Sale Line No.";
        NpCsSaleLinePOSReference2."Document No." := NpCsSaleLinePOSReference."Document No.";
        NpCsSaleLinePOSReference2."Document Type" := NpCsSaleLinePOSReference."Document Type";
        NpCsSaleLinePOSReference2."Document Line No." := SalesLine."Line No.";
        NpCsSaleLinePOSReference2.Insert;
    end;

    local procedure DeliverSalesLineComment(SalesLine: Record "Sales Line"; POSSaleLine: Codeunit "NPR POS Sale Line"; var SaleLinePOS: Record "NPR Sale Line POS")
    begin
        SaleLinePOS.Init;
        SaleLinePOS.Type := SaleLinePOS.Type::Comment;
        SaleLinePOS."No." := '*';
        SaleLinePOS.Description := SalesLine.Description;
        SaleLinePOS."Description 2" := SalesLine."Description 2";
        POSSaleLine.InsertLine(SaleLinePOS);
    end;

    local procedure DeliverSalesLineGLAccount(NpCsDocument: Record "NPR NpCs Document"; SalesLine: Record "Sales Line"; POSSaleLine: Codeunit "NPR POS Sale Line"; var SaleLinePOS: Record "NPR Sale Line POS")
    begin
        SaleLinePOS.Init;
        if not NpCsDocument."Store Stock" then
            SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::"Debit Sale";
        if NpCsDocument."Bill via" <> NpCsDocument."Bill via"::POS then
            SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::"Debit Sale";

        SaleLinePOS.Type := SaleLinePOS.Type::"G/L Entry";
        SaleLinePOS."No." := SalesLine."No.";
        SaleLinePOS.Description := SalesLine.Description;
        SaleLinePOS."Description 2" := SalesLine."Description 2";
        SaleLinePOS."Unit Price" := SalesLine."Unit Price";
        SaleLinePOS.Quantity := SalesLine.Quantity;
        SaleLinePOS."Unit of Measure Code" := SalesLine."Unit of Measure Code";
        SaleLinePOS."Discount %" := SalesLine."Line Discount %";
        POSSaleLine.InsertLine(SaleLinePOS);
    end;

    local procedure DeliverSalesLineItem(NpCsDocument: Record "NPR NpCs Document"; SalesLine: Record "Sales Line"; POSSaleLine: Codeunit "NPR POS Sale Line"; var SaleLinePOS: Record "NPR Sale Line POS")
    begin
        SaleLinePOS.Init;
        if not NpCsDocument."Store Stock" then
            SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::"Debit Sale";
        if NpCsDocument."Bill via" <> NpCsDocument."Bill via"::POS then
            SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::"Debit Sale";
        SaleLinePOS.Type := SaleLinePOS.Type::Item;
        SaleLinePOS."No." := SalesLine."No.";
        SaleLinePOS."Variant Code" := SalesLine."Variant Code";
        SaleLinePOS.Description := SalesLine.Description;
        SaleLinePOS."Description 2" := SalesLine."Description 2";
        SaleLinePOS."Unit Price" := SalesLine."Unit Price";
        SaleLinePOS.Quantity := SalesLine.Quantity;
        SaleLinePOS."Unit of Measure Code" := SalesLine."Unit of Measure Code";
        SaleLinePOS."Discount %" := SalesLine."Line Discount %";
        POSSaleLine.InsertLine(SaleLinePOS);
    end;

    local procedure DeliverSalesInvLine(NpCsDocument: Record "NPR NpCs Document"; SalesInvLine: Record "Sales Invoice Line"; NpCsSaleLinePOSReference: Record "NPR NpCs Sale Line POS Ref."; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        NpCsSaleLinePOSReference2: Record "NPR NpCs Sale Line POS Ref.";
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        case SalesInvLine.Type of
            SalesInvLine.Type::" ":
                begin
                    DeliverSalesInvLineComment(SalesInvLine, POSSaleLine, SaleLinePOS);
                end;
            SalesInvLine.Type::"G/L Account":
                begin
                    DeliverSalesInvLineGLAccount(NpCsDocument, SalesInvLine, POSSaleLine, SaleLinePOS);
                end;
            SalesInvLine.Type::Item:
                begin
                    DeliverSalesInvLineItem(NpCsDocument, SalesInvLine, POSSaleLine, SaleLinePOS);
                end;
            else
                Error(Text007, SalesInvLine.Type);
        end;

        NpCsSaleLinePOSReference2.Init;
        NpCsSaleLinePOSReference2."Register No." := SaleLinePOS."Register No.";
        NpCsSaleLinePOSReference2."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        NpCsSaleLinePOSReference2."Sale Type" := SaleLinePOS."Sale Type";
        NpCsSaleLinePOSReference2."Sale Date" := SaleLinePOS.Date;
        NpCsSaleLinePOSReference2."Sale Line No." := SaleLinePOS."Line No.";
        NpCsSaleLinePOSReference2."Collect Document Entry No." := NpCsSaleLinePOSReference."Collect Document Entry No.";
        NpCsSaleLinePOSReference2."Applies-to Line No." := NpCsSaleLinePOSReference."Sale Line No.";
        NpCsSaleLinePOSReference2."Document No." := NpCsSaleLinePOSReference."Document No.";
        NpCsSaleLinePOSReference2."Document Type" := NpCsSaleLinePOSReference."Document Type";
        NpCsSaleLinePOSReference2."Document Line No." := SalesInvLine."Line No.";
        NpCsSaleLinePOSReference2.Insert;
    end;

    local procedure DeliverSalesInvLineComment(SalesInvLine: Record "Sales Invoice Line"; POSSaleLine: Codeunit "NPR POS Sale Line"; var SaleLinePOS: Record "NPR Sale Line POS")
    begin
        SaleLinePOS.Init;
        SaleLinePOS.Type := SaleLinePOS.Type::Comment;
        SaleLinePOS."No." := '*';
        SaleLinePOS.Description := SalesInvLine.Description;
        SaleLinePOS."Description 2" := SalesInvLine."Description 2";
        POSSaleLine.InsertLine(SaleLinePOS);
    end;

    local procedure DeliverSalesInvLineGLAccount(NpCsDocument: Record "NPR NpCs Document"; SalesInvLine: Record "Sales Invoice Line"; POSSaleLine: Codeunit "NPR POS Sale Line"; var SaleLinePOS: Record "NPR Sale Line POS")
    begin
        SaleLinePOS.Init;
        if not NpCsDocument."Store Stock" then
            SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::"Debit Sale";
        if NpCsDocument."Bill via" <> NpCsDocument."Bill via"::POS then
            SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::"Debit Sale";

        SaleLinePOS.Type := SaleLinePOS.Type::"G/L Entry";
        SaleLinePOS."No." := SalesInvLine."No.";
        SaleLinePOS.Description := SalesInvLine.Description;
        SaleLinePOS."Description 2" := SalesInvLine."Description 2";
        SaleLinePOS."Unit Price" := SalesInvLine."Unit Price";
        SaleLinePOS.Quantity := SalesInvLine.Quantity;
        SaleLinePOS."Unit of Measure Code" := SalesInvLine."Unit of Measure Code";
        SaleLinePOS."Discount %" := SalesInvLine."Line Discount %";
        POSSaleLine.InsertLine(SaleLinePOS);
    end;

    local procedure DeliverSalesInvLineItem(NpCsDocument: Record "NPR NpCs Document"; SalesInvLine: Record "Sales Invoice Line"; POSSaleLine: Codeunit "NPR POS Sale Line"; var SaleLinePOS: Record "NPR Sale Line POS")
    begin
        SaleLinePOS.Init;
        if not NpCsDocument."Store Stock" then
            SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::"Debit Sale";
        if NpCsDocument."Bill via" <> NpCsDocument."Bill via"::POS then
            SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::"Debit Sale";
        SaleLinePOS.Type := SaleLinePOS.Type::Item;
        SaleLinePOS."No." := SalesInvLine."No.";
        SaleLinePOS."Variant Code" := SalesInvLine."Variant Code";
        SaleLinePOS.Description := SalesInvLine.Description;
        SaleLinePOS."Description 2" := SalesInvLine."Description 2";
        SaleLinePOS."Unit Price" := SalesInvLine."Unit Price";
        SaleLinePOS.Quantity := SalesInvLine.Quantity;
        SaleLinePOS."Unit of Measure Code" := SalesInvLine."Unit of Measure Code";
        SaleLinePOS."Discount %" := SalesInvLine."Line Discount %";
        POSSaleLine.InsertLine(SaleLinePOS);
    end;

    local procedure FindDocument(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; var NpCsDocument: Record "NPR NpCs Document"): Boolean
    begin
        if FindDocumentFromInput(JSON, NpCsDocument) then
            exit(true);

        if SelectDocument(JSON, POSSession, NpCsDocument) then
            exit(true);

        exit(false);
    end;

    local procedure ConfirmDocumentStatus(NpCsDocument: Record "NPR NpCs Document") Confirmed: Boolean
    begin
        if NpCsDocument."Delivery Status" = NpCsDocument."Delivery Status"::Ready then
            exit(true);

        if NpCsDocument."Delivery Status" = NpCsDocument."Delivery Status"::" " then begin
            Confirmed := Confirm(Text003, false, NpCsDocument."Processing Status", NpCsDocument."Document Type", NpCsDocument."Reference No.");
            exit(Confirmed);
        end;

        Confirmed := Confirm(Text004, false, NpCsDocument."Delivery Status", NpCsDocument."Document Type", NpCsDocument."Reference No.");
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
        exit(NpCsDocument.FindFirst);
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

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnGetDataSourceExtension', '', false, false)]
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

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDataSourceExtensionReadData', '', false, false)]
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
        DataRow.Fields.Add('ProcessedOrdersExists', ProcessedOrdersExists);
        if ProcessedOrdersExists then
            DataRow.Fields.Add('ProcessedOrdersQty', GetProcessedOrdersQty(LocationFilter))
        else
            DataRow.Fields.Add('ProcessedOrdersQty', 0);
    end;

    local procedure GetPOSMenuButtonLocationFilter(POSSession: Codeunit "NPR POS Session") LocationFilter: Text
    var
        POSStore: Record "NPR POS Store";
        POSMenuButton: Record "NPR POS Menu Button";
        POSParameterValue: Record "NPR POS Parameter Value";
        SalePOS: Record "NPR Sale POS";
        POSSale: Codeunit "NPR POS Sale";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSMenuButton.SetRange("Action Code", ActionCode());
        POSMenuButton.SetRange("Register No.", SalePOS."Register No.");
        if not POSMenuButton.FindFirst then
            POSMenuButton.SetRange("Register No.");
        if not POSMenuButton.FindFirst then
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
        exit(NpCsDocument.FindFirst);
    end;

    local procedure GetProcessedOrdersQty(LocationFilter: Text): Integer
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        SetProcessedFilter(LocationFilter, NpCsDocument);
        exit(NpCsDocument.Count);
    end;

    local procedure SetProcessedFilter(LocationFilter: Text; var NpCsDocument: Record "NPR NpCs Document")
    begin
        NpCsDocument.SetRange(Type, NpCsDocument.Type::"Collect in Store");
        NpCsDocument.SetRange("Processing Status", NpCsDocument."Processing Status"::Confirmed);
        NpCsDocument.SetRange("Delivery Status", NpCsDocument."Delivery Status"::Ready);
        NpCsDocument.SetFilter("Location Code", LocationFilter);
    end;
}
