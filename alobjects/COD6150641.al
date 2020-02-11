codeunit 6150641 "POS Payment Bin Eject Mgt."
{
    // NPR5.40/MMV /20180228 CASE 300660 Created object
    // NPR5.40.02/MMV /20180418 CASE 311900 Fallback if missing setup
    // NPR5.41/MMV /20180425 CASE 312990 Proper fallback.
    // NPR5.43/MMV /20180627 CASE 320714 Filter on payment amount
    // NPR5.51/TJ  /20190628 CASE 357069 Drawer opening requirement is now checked based on Open Drawer field
    // NPR5.53/ALPO/20191216 CASE 378985 Finish credit sale workflow: eject payment bin step


    trigger OnRun()
    begin
    end;

    var
        WORKFLOW_STEP: Label 'Eject Payment Bin';

    procedure EjectDrawer(POSPaymentBin: Record "POS Payment Bin";SalePOS: Record "Sale POS"): Boolean
    var
        Ejected: Boolean;
        POSCreateEntry: Codeunit "POS Create Entry";
    begin
        if POSPaymentBin."Eject Method" = '' then
          exit;

        OnEjectPaymentBin(POSPaymentBin, Ejected);

        if Ejected then
          POSCreateEntry.InsertBinOpenEntry(SalePOS."Register No.", SalePOS."Salesperson Code");

        exit(Ejected);
    end;

    procedure LookupInvokeMethods(POSPaymentBin: Record "POS Payment Bin";var SelectedMethod: Text): Boolean
    var
        tmpRetailList: Record "Retail List" temporary;
    begin
        OnLookupBinInvokeMethods(tmpRetailList);
        if PAGE.RunModal(0, tmpRetailList) = ACTION::LookupOK then begin
          SelectedMethod := tmpRetailList.Value;
          exit(true);
        end;
    end;

    procedure ShowGenericParameters(POSPaymentBin: Record "POS Payment Bin")
    var
        POSPaymentBinInvokeParameter: Record "POS Payment Bin Eject Param.";
    begin
        POSPaymentBinInvokeParameter.SetRange("Bin No.", POSPaymentBin."No.");
        PAGE.RunModal(0, POSPaymentBinInvokeParameter);
    end;

    procedure GetTextParameterValue(BinNoIn: Code[10];NameIn: Text;DefaultValue: Text): Text
    var
        InvokeParameter: Record "POS Payment Bin Eject Param.";
    begin
        InvokeParameter.FindOrCreateRecord(BinNoIn, NameIn, InvokeParameter."Data Type"::Text, DefaultValue, '');
        exit(InvokeParameter.Value);
    end;

    procedure GetIntegerParameterValue(BinNoIn: Code[10];NameIn: Text;DefaultValue: Integer): Integer
    var
        InvokeParameter: Record "POS Payment Bin Eject Param.";
        "Integer": Integer;
    begin
        InvokeParameter.FindOrCreateRecord(BinNoIn, NameIn, InvokeParameter."Data Type"::Integer, DefaultValue, '');
        Evaluate(Integer, InvokeParameter.Value, 9);
        exit(Integer);
    end;

    procedure GetBooleanParameterValue(BinNoIn: Code[10];NameIn: Text;DefaultValue: Boolean): Boolean
    var
        InvokeParameter: Record "POS Payment Bin Eject Param.";
        Boolean: Boolean;
    begin
        InvokeParameter.FindOrCreateRecord(BinNoIn, NameIn, InvokeParameter."Data Type"::Boolean, DefaultValue, '');
        Evaluate(Boolean, InvokeParameter.Value, 9);
        exit(Boolean);
    end;

    procedure GetOptionParameterValue(BinNoIn: Code[10];NameIn: Text;DefaultValue: Integer;OptionStringIn: Text): Integer
    var
        InvokeParameter: Record "POS Payment Bin Eject Param.";
        "Integer": Integer;
    begin
        InvokeParameter.FindOrCreateRecord(BinNoIn, NameIn, InvokeParameter."Data Type"::Option, DefaultValue, OptionStringIn);
        Evaluate(Integer, InvokeParameter.Value, 9);
        exit(Integer);
    end;

    procedure GetDecimalParameterValue(BinNoIn: Code[10];NameIn: Text;DefaultValue: Decimal): Decimal
    var
        InvokeParameter: Record "POS Payment Bin Eject Param.";
        Decimal: Decimal;
    begin
        InvokeParameter.FindOrCreateRecord(BinNoIn, NameIn, InvokeParameter."Data Type"::Decimal, DefaultValue, '');
        Evaluate(Decimal, InvokeParameter.Value, 9);
        exit(Decimal);
    end;

    procedure GetDateParameterValue(BinNoIn: Code[10];NameIn: Text;DefaultValue: Date): Date
    var
        InvokeParameter: Record "POS Payment Bin Eject Param.";
        Date: Date;
    begin
        InvokeParameter.FindOrCreateRecord(BinNoIn, NameIn, InvokeParameter."Data Type"::Date, DefaultValue, '');
        Evaluate(Date, InvokeParameter.Value, 9);
        exit(Date);
    end;

    local procedure "-- Aux"()
    begin
    end;

    local procedure IsDrawerOpenRequiredAuditRoll(SalePOS: Record "Sale POS"): Boolean
    var
        AuditRoll: Record "Audit Roll";
        PaymentTypePOS: Record "Payment Type POS";
        FilterString: Text;
    begin
        PaymentTypePOS.SetCurrentKey("Processing Type");
        //-NPR5.51 [357069]
        //PaymentTypePOS.SETFILTER("Processing Type", '%1|%2', PaymentTypePOS."Processing Type"::Cash, PaymentTypePOS."Processing Type"::"Foreign Currency");
        PaymentTypePOS.SetRange("Open Drawer",true);
        //+NPR5.51 [357069]
        if not PaymentTypePOS.FindSet then
          exit;

        repeat
          if FilterString <> '' then
            FilterString += '|';
          FilterString += '''' + PaymentTypePOS."No." + '''';
        until PaymentTypePOS.Next = 0;

        AuditRoll.SetRange("Register No.", SalePOS."Register No.");
        AuditRoll.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        AuditRoll.SetRange("Sale Type",AuditRoll."Sale Type"::Payment);
        AuditRoll.SetRange(Type, AuditRoll.Type::Payment);
        AuditRoll.SetFilter("No.", FilterString);
        //-NPR5.43 [320714]
        AuditRoll.SetFilter("Amount Including VAT", '<>%1', 0);
        //+NPR5.43 [320714]
        exit(not AuditRoll.IsEmpty);
    end;

    local procedure IsDrawerOpenRequiredPOSEntry(SalePOS: Record "Sale POS"): Boolean
    var
        POSEntry: Record "POS Entry";
        POSPaymentLine: Record "POS Payment Line";
        PaymentTypePOS: Record "Payment Type POS";
        POSEntryManagement: Codeunit "POS Entry Management";
        FilterString: Text;
    begin
        PaymentTypePOS.SetCurrentKey("Processing Type");
        //-NPR5.51 [357069]
        //PaymentTypePOS.SETFILTER("Processing Type", '%1|%2', PaymentTypePOS."Processing Type"::Cash, PaymentTypePOS."Processing Type"::"Foreign Currency");
        PaymentTypePOS.SetRange("Open Drawer",true);
        //+NPR5.51 [357069]
        if not PaymentTypePOS.FindSet then
          exit;

        repeat
          if FilterString <> '' then
            FilterString += '|';
          FilterString += '''' + PaymentTypePOS."No." + '''';
        until PaymentTypePOS.Next = 0;

        if not POSEntryManagement.FindPOSEntryViaDocumentNo(SalePOS."Sales Ticket No.", POSEntry) then
          exit(false);

        POSPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSPaymentLine.SetFilter("POS Payment Method Code", FilterString);
        //-NPR5.43 [320714]
        POSPaymentLine.SetFilter("Amount (Sales Currency)", '<>%1', 0);
        //+NPR5.43 [320714]
        exit(not POSPaymentLine.IsEmpty);
    end;

    local procedure CarryOutPaymentBinEject(SalePOS: Record "Sale POS";Force: Boolean)
    var
        NPRetailSetup: Record "NP Retail Setup";
        POSPaymentBin: Record "POS Payment Bin";
        POSUnit: Record "POS Unit";
        OpenDrawer: Boolean;
    begin
        //-NPR5.53 [378985]
        OpenDrawer := Force;
        if not OpenDrawer then begin
        //+NPR5.53 [378985]
          if not NPRetailSetup.Get then
            exit;

          //Change below to just loop and fire open on all unique payment bin from pos payment lines when the payment bins are properly implemented on payments

          if NPRetailSetup."Advanced Posting Activated" then
            OpenDrawer := IsDrawerOpenRequiredPOSEntry(SalePOS)
          else
            OpenDrawer := IsDrawerOpenRequiredAuditRoll(SalePOS);

          if not OpenDrawer then
            exit;
        end;  //NPR5.53 [378985]

        if ((not POSUnit.Get(SalePOS."Register No.")) or (not POSPaymentBin.Get(POSUnit."Default POS Payment Bin"))) then
          POSPaymentBin."Eject Method" := 'PRINTER';

        EjectDrawer(POSPaymentBin, SalePOS);
    end;

    local procedure "-- Finish Sales Workflow"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6150730, 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "POS Sales Workflow Step";RunTrigger: Boolean)
    begin
        if Rec."Subscriber Codeunit ID" <> CODEUNIT::"POS Payment Bin Eject Mgt." then
          exit;
        if Rec."Subscriber Function" <> 'EjectPaymentBin' then
          exit;

        Rec.Description := WORKFLOW_STEP;
        Rec."Sequence No." := 15;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150705, 'OnFinishSale', '', true, true)]
    local procedure EjectPaymentBin(POSSalesWorkflowStep: Record "POS Sales Workflow Step";SalePOS: Record "Sale POS")
    begin
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CODEUNIT::"POS Payment Bin Eject Mgt." then
          exit;
        if POSSalesWorkflowStep."Subscriber Function" <> 'EjectPaymentBin' then
          exit;
        
        CarryOutPaymentBinEject(SalePOS,false);  //NPR5.53 [378985]
        
        //-NPR5.53 [378985]-revoked (Moved to a separate function to avoid code duplication)
        /*
        IF NOT NPRetailSetup.GET THEN
          EXIT;
        
        //Change below to just loop and fire open on all unique payment bin from pos payment lines when the payment bins are properly implemented on payments
        
        IF NPRetailSetup."Advanced Posting Activated" THEN
          OpenDrawer := IsDrawerOpenRequiredPOSEntry(SalePOS)
        ELSE
          OpenDrawer := IsDrawerOpenRequiredAuditRoll(SalePOS);
        
        IF NOT OpenDrawer THEN
          EXIT;
        
        IF ((NOT POSUnit.GET(SalePOS."Register No.")) OR (NOT POSPaymentBin.GET(POSUnit."Default POS Payment Bin"))) THEN
          POSPaymentBin."Eject Method" := 'PRINTER';
        
        EjectDrawer(POSPaymentBin, SalePOS);
        */
        //+NPR5.53 [378985]-revoked

    end;

    local procedure "-- Finish Credit Sale Workflow"()
    begin
        //NPR5.53 [378985]
    end;

    [EventSubscriber(ObjectType::Table, 6150730, 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertCreditSaleWorkflowStep(var Rec: Record "POS Sales Workflow Step";RunTrigger: Boolean)
    begin
        //-NPR5.53 [378985]
        if Rec."Subscriber Codeunit ID" <> CODEUNIT::"POS Payment Bin Eject Mgt." then
          exit;
        if Rec."Subscriber Function" <> 'EjectPaymentBinOnCreditSale' then
          exit;

        Rec.Description := WORKFLOW_STEP;
        Rec."Sequence No." := 10;
        Rec.Enabled := false;
        //+NPR5.53 [378985]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014407, 'OnFinishCreditSale', '', true, true)]
    local procedure EjectPaymentBinOnCreditSale(POSSalesWorkflowStep: Record "POS Sales Workflow Step";SalePOS: Record "Sale POS")
    var
        NPRetailSetup: Record "NP Retail Setup";
        OpenDrawer: Boolean;
        POSPaymentBin: Record "POS Payment Bin";
        POSUnit: Record "POS Unit";
    begin
        //-NPR5.53 [378985]
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CODEUNIT::"POS Payment Bin Eject Mgt." then
          exit;
        if POSSalesWorkflowStep."Subscriber Function" <> 'EjectPaymentBinOnCreditSale' then
          exit;

        CarryOutPaymentBinEject(SalePOS,true);
        //+NPR5.53 [378985]
    end;

    local procedure "-- Event Publishers"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnEjectPaymentBin(POSPaymentBin: Record "POS Payment Bin";var Ejected: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLookupBinInvokeMethods(var tmpRetailList: Record "Retail List")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnShowInvokeParameters(POSPaymentBin: Record "POS Payment Bin")
    begin
    end;
}

