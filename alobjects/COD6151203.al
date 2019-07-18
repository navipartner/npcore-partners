codeunit 6151203 "NpCs POS Action Deliver Order"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store
    // #344264/MHA /20190717  CASE 344264 "Delivery Only (non stock)" changed to "From Store Stock"
    // #362329/MHA /20190718  CASE 362329 Updated StrSubStNo on DeliveryText in InsertDocumentReference()


    trigger OnRun()
    begin
    end;

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

        Sender.RegisterWorkflowStep('document_input','input({title: labels.DocumentInputTitle,caption: labels.ReferenceNo,value: ""}).cancel(abort);');
        Sender.RegisterWorkflowStep('select_document','respond();');
        Sender.RegisterWorkflowStep('deliver_document','if(context.entry_no) {respond();}');
        Sender.RegisterWorkflow(false);

        Sender.RegisterOptionParameter('Location From','POS Store,Location Filter Parameter','POS Store');
        Sender.RegisterTextParameter('Location Filter','');
        Sender.RegisterTextParameter('Delivery Text',Text006);
        Sender.RegisterTextParameter('Prepaid Text',Text008);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(),'DocumentInputTitle',Text001);
        Captions.AddActionCaption(ActionCode(),'ReferenceNo',Text002);
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
    begin
        if Handled then
          exit;
        if not Action.IsThisAction(ActionCode()) then
          exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        case WorkflowStep of
          'select_document':
            begin
              OnActionSelectDocument(JSON,POSSession,FrontEnd);
            end;
          'deliver_document':
            begin
              OnActionDeliverDocument(JSON,POSSession);
              POSSession.RequestRefreshData();
            end;
        end;
    end;

    local procedure OnActionSelectDocument(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        NpCsDocument: Record "NpCs Document";
    begin
        if not FindDocument(JSON,POSSession,NpCsDocument) then
          exit;

        if not ConfirmDocumentStatus(NpCsDocument) then
          exit;

        JSON.SetContext('entry_no',NpCsDocument."Entry No.");
        FrontEnd.SetActionContext(ActionCode(),JSON);
    end;

    local procedure OnActionDeliverDocument(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session")
    var
        NpCsDocument: Record "NpCs Document";
        NpCsSaleLinePOSReference: Record "NpCs Sale Line POS Reference";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        POSSaleLine: Codeunit "POS Sale Line";
        PrepaidText: Text;
        EntryNo: Integer;
    begin
        JSON.SetContext('/',false);
        EntryNo := JSON.GetInteger('entry_no',false);
        if EntryNo = 0 then
          exit;

        NpCsDocument.Get(EntryNo);
        SalesHeader.Get(NpCsDocument."Document Type",NpCsDocument."Document No.");
        POSSession.GetSaleLine(POSSaleLine);
        SalesLine.SetRange("Document Type",SalesHeader."Document Type");
        SalesLine.SetRange("Document No.",SalesHeader."No.");
        if not SalesLine.FindSet then
          Error(Text005,NpCsDocument."Reference No.");

        InsertDocumentReference(JSON,NpCsDocument,POSSaleLine,NpCsSaleLinePOSReference);

        repeat
          DeliverSalesLine(NpCsDocument,SalesLine,NpCsSaleLinePOSReference,POSSaleLine);
        until SalesLine.Next = 0;

        if NpCsDocument."Prepaid Amount" > 0 then begin
          PrepaidText := JSON.GetStringParameter('Prepaid Text',false);
          if PrepaidText = '' then
            PrepaidText := Text008;
          DeliverPrepaymentLine(NpCsDocument,NpCsSaleLinePOSReference,PrepaidText,POSSaleLine);
        end;
    end;

    local procedure InsertDocumentReference(JSON: Codeunit "POS JSON Management";NpCsDocument: Record "NpCs Document";POSSaleLine: Codeunit "POS Sale Line";var NpCsSaleLinePOSReference: Record "NpCs Sale Line POS Reference")
    var
        SaleLinePOS: Record "Sale Line POS";
        DeliveryText: Text;
    begin
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        NpCsSaleLinePOSReference.SetRange("Register No.",SaleLinePOS."Register No.");
        NpCsSaleLinePOSReference.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
        NpCsSaleLinePOSReference.SetRange("Document Type",NpCsDocument."Document Type");
        NpCsSaleLinePOSReference.SetRange("Document No.",NpCsDocument."Document No.");
        if NpCsSaleLinePOSReference.FindFirst then
          Error(Text009,NpCsDocument."Document Type",NpCsDocument."Document No.");

        //-#362329 [362329]
        DeliveryText := StrSubstNo(JSON.GetStringParameter('Delivery Text',false),NpCsDocument."Document Type",NpCsDocument."Reference No.");
        //+#362329 [362329]
        if DeliveryText = '' then
          DeliveryText := StrSubstNo(Text006,NpCsDocument."Document Type",NpCsDocument."Reference No.");
        SaleLinePOS.Init;
        SaleLinePOS.Type := SaleLinePOS.Type::Comment;
        SaleLinePOS."No." := '*';
        SaleLinePOS.Description := CopyStr(DeliveryText,1,MaxStrLen(SaleLinePOS.Description));
        POSSaleLine.InsertLine(SaleLinePOS);

        if NpCsSaleLinePOSReference.Get(SaleLinePOS."Register No.",SaleLinePOS."Sales Ticket No.",SaleLinePOS."Sale Type",SaleLinePOS.Date,SaleLinePOS."Line No.") then
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

    local procedure DeliverPrepaymentLine(NpCsDocument: Record "NpCs Document";NpCsSaleLinePOSReference: Record "NpCs Sale Line POS Reference";PrepaidText: Text;POSSaleLine: Codeunit "POS Sale Line")
    var
        NpCsSaleLinePOSReference2: Record "NpCs Sale Line POS Reference";
        SaleLinePOS: Record "Sale Line POS";
    begin
        //-#344264 [344264]
        if not NpCsDocument."Store Stock" then
          exit;
        //+#344264 [344264]
        if NpCsDocument."Bill via" <> NpCsDocument."Bill via"::POS then
          exit;

        SaleLinePOS.Init;
        SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Deposit;
        SaleLinePOS.Type := SaleLinePOS.Type::"G/L Entry";
        SaleLinePOS."No." := NpCsDocument."Prepayment Account No.";
        SaleLinePOS."Unit Price" := -NpCsDocument."Prepaid Amount";
        SaleLinePOS.Quantity := 1;
        SaleLinePOS."Amount Including VAT" := -NpCsDocument."Prepaid Amount";
        POSSaleLine.InsertDepositLine(SaleLinePOS,-NpCsDocument."Prepaid Amount");
        SaleLinePOS.Validate("No.");
        SaleLinePOS.Description := CopyStr(StrSubstNo(PrepaidText,NpCsDocument."Reference No."),1,MaxStrLen(SaleLinePOS.Description));
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

    local procedure DeliverSalesLine(NpCsDocument: Record "NpCs Document";SalesLine: Record "Sales Line";NpCsSaleLinePOSReference: Record "NpCs Sale Line POS Reference";POSSaleLine: Codeunit "POS Sale Line")
    var
        NpCsSaleLinePOSReference2: Record "NpCs Sale Line POS Reference";
        SaleLinePOS: Record "Sale Line POS";
    begin
        case SalesLine.Type of
          SalesLine.Type::" ":
            begin
              DeliverSalesLineComment(SalesLine,POSSaleLine,SaleLinePOS);
            end;
          SalesLine.Type::"G/L Account":
            begin
              DeliverSalesLineGLAccount(NpCsDocument,SalesLine,POSSaleLine,SaleLinePOS);
            end;
          SalesLine.Type::Item:
            begin
              DeliverSalesLineItem(NpCsDocument,SalesLine,POSSaleLine,SaleLinePOS);
            end;
          else
            Error(Text007,SalesLine.Type);
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

    local procedure DeliverSalesLineComment(SalesLine: Record "Sales Line";POSSaleLine: Codeunit "POS Sale Line";var SaleLinePOS: Record "Sale Line POS")
    begin
        SaleLinePOS.Init;
        SaleLinePOS.Type := SaleLinePOS.Type::Comment;
        SaleLinePOS."No." := '*';
        SaleLinePOS.Description := SalesLine.Description;
        SaleLinePOS."Description 2" := SalesLine."Description 2";
        POSSaleLine.InsertLine(SaleLinePOS);
    end;

    local procedure DeliverSalesLineGLAccount(NpCsDocument: Record "NpCs Document";SalesLine: Record "Sales Line";POSSaleLine: Codeunit "POS Sale Line";var SaleLinePOS: Record "Sale Line POS")
    begin
        SaleLinePOS.Init;
        //-#344264 [344264]
        if not NpCsDocument."Store Stock" then
          SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::"Debit Sale";
        //+#344264 [344264]
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

    local procedure DeliverSalesLineItem(NpCsDocument: Record "NpCs Document";SalesLine: Record "Sales Line";POSSaleLine: Codeunit "POS Sale Line";var SaleLinePOS: Record "Sale Line POS")
    begin
        SaleLinePOS.Init;
        //-#344264 [344264]
        if not NpCsDocument."Store Stock" then
          SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::"Debit Sale";
        //+#344264 [344264]
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

    local procedure FindDocument(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session";var NpCsDocument: Record "NpCs Document"): Boolean
    begin
        if FindDocumentFromInput(JSON,NpCsDocument) then
          exit(true);

        if SelectDocument(JSON,POSSession,NpCsDocument) then
          exit(true);

        exit(false);
    end;

    local procedure ConfirmDocumentStatus(NpCsDocument: Record "NpCs Document") Confirmed: Boolean
    begin
        if NpCsDocument."Delivery Status" = NpCsDocument."Delivery Status"::Ready then
          exit(true);

        if NpCsDocument."Delivery Status" = NpCsDocument."Delivery Status"::" " then begin
          Confirmed := Confirm(Text003,false,NpCsDocument."Processing Status",NpCsDocument."Document Type",NpCsDocument."Reference No.");
          exit(Confirmed);
        end;

        Confirmed := Confirm(Text004,false,NpCsDocument."Delivery Status",NpCsDocument."Document Type",NpCsDocument."Reference No.");
        exit(Confirmed);
    end;

    local procedure FindDocumentFromInput(JSON: Codeunit "POS JSON Management";var NpCsDocument: Record "NpCs Document"): Boolean
    var
        ReferenceNo: Text;
    begin
        JSON.SetScope('/',false);
        if not JSON.SetScope('$document_input',false) then
          exit(false);

        ReferenceNo := CopyStr(JSON.GetString('input',false),1,MaxStrLen(NpCsDocument."Reference No."));
        if ReferenceNo = '' then
          exit(false);

        NpCsDocument.SetRange("Reference No.",ReferenceNo);
        exit(NpCsDocument.FindFirst);
    end;

    local procedure SelectDocument(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session";var NpCsDocument: Record "NpCs Document"): Boolean
    var
        LocationFilter: Text;
    begin
        LocationFilter := GetLocationFilter(JSON,POSSession);

        Clear(NpCsDocument);
        NpCsDocument.SetRange(Type,NpCsDocument.Type::"Collect in Store");
        NpCsDocument.SetRange("Delivery Status",NpCsDocument."Delivery Status"::Ready);
        if LocationFilter <> '' then
          NpCsDocument.SetFilter("Location Code",LocationFilter);
        if PAGE.RunModal(PAGE::"NpCs Collect Store Orders",NpCsDocument) = ACTION::LookupOK then
          exit(true);

        exit(false);
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
}

