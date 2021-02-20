codeunit 6150641 "NPR POS Payment Bin Eject Mgt."
{
    var
        WORKFLOW_STEP: Label 'Eject Payment Bin';

    procedure EjectDrawer(POSPaymentBin: Record "NPR POS Payment Bin"; SalePOS: Record "NPR Sale POS"): Boolean
    var
        Ejected: Boolean;
        POSCreateEntry: Codeunit "NPR POS Create Entry";
    begin
        if POSPaymentBin."Eject Method" = '' then
            exit;

        OnEjectPaymentBin(POSPaymentBin, Ejected);

        if Ejected then
            POSCreateEntry.InsertBinOpenEntry(SalePOS."Register No.", SalePOS."Salesperson Code");

        exit(Ejected);
    end;

    procedure LookupInvokeMethods(POSPaymentBin: Record "NPR POS Payment Bin"; var SelectedMethod: Text): Boolean
    var
        tmpRetailList: Record "NPR Retail List" temporary;
    begin
        OnLookupBinInvokeMethods(tmpRetailList);
        if PAGE.RunModal(0, tmpRetailList) = ACTION::LookupOK then begin
            SelectedMethod := tmpRetailList.Value;
            exit(true);
        end;
    end;

    procedure ShowGenericParameters(POSPaymentBin: Record "NPR POS Payment Bin")
    var
        POSPaymentBinInvokeParameter: Record "NPR POS Paym. Bin Eject Param.";
    begin
        POSPaymentBinInvokeParameter.SetRange("Bin No.", POSPaymentBin."No.");
        PAGE.RunModal(0, POSPaymentBinInvokeParameter);
    end;

    procedure GetTextParameterValue(BinNoIn: Code[10]; NameIn: Text; DefaultValue: Text): Text
    var
        InvokeParameter: Record "NPR POS Paym. Bin Eject Param.";
    begin
        InvokeParameter.FindOrCreateRecord(BinNoIn, NameIn, InvokeParameter."Data Type"::Text, DefaultValue, '');
        exit(InvokeParameter.Value);
    end;

    procedure GetIntegerParameterValue(BinNoIn: Code[10]; NameIn: Text; DefaultValue: Integer): Integer
    var
        InvokeParameter: Record "NPR POS Paym. Bin Eject Param.";
        "Integer": Integer;
    begin
        InvokeParameter.FindOrCreateRecord(BinNoIn, NameIn, InvokeParameter."Data Type"::Integer, DefaultValue, '');
        Evaluate(Integer, InvokeParameter.Value, 9);
        exit(Integer);
    end;

    procedure GetBooleanParameterValue(BinNoIn: Code[10]; NameIn: Text; DefaultValue: Boolean): Boolean
    var
        InvokeParameter: Record "NPR POS Paym. Bin Eject Param.";
        Boolean: Boolean;
    begin
        InvokeParameter.FindOrCreateRecord(BinNoIn, NameIn, InvokeParameter."Data Type"::Boolean, DefaultValue, '');
        Evaluate(Boolean, InvokeParameter.Value, 9);
        exit(Boolean);
    end;

    procedure GetOptionParameterValue(BinNoIn: Code[10]; NameIn: Text; DefaultValue: Integer; OptionStringIn: Text): Integer
    var
        InvokeParameter: Record "NPR POS Paym. Bin Eject Param.";
        "Integer": Integer;
    begin
        InvokeParameter.FindOrCreateRecord(BinNoIn, NameIn, InvokeParameter."Data Type"::Option, DefaultValue, OptionStringIn);
        Evaluate(Integer, InvokeParameter.Value, 9);
        exit(Integer);
    end;

    procedure GetDecimalParameterValue(BinNoIn: Code[10]; NameIn: Text; DefaultValue: Decimal): Decimal
    var
        InvokeParameter: Record "NPR POS Paym. Bin Eject Param.";
        Decimal: Decimal;
    begin
        InvokeParameter.FindOrCreateRecord(BinNoIn, NameIn, InvokeParameter."Data Type"::Decimal, DefaultValue, '');
        Evaluate(Decimal, InvokeParameter.Value, 9);
        exit(Decimal);
    end;

    procedure GetDateParameterValue(BinNoIn: Code[10]; NameIn: Text; DefaultValue: Date): Date
    var
        InvokeParameter: Record "NPR POS Paym. Bin Eject Param.";
        Date: Date;
    begin
        InvokeParameter.FindOrCreateRecord(BinNoIn, NameIn, InvokeParameter."Data Type"::Date, DefaultValue, '');
        Evaluate(Date, InvokeParameter.Value, 9);
        exit(Date);
    end;

    local procedure IsDrawerOpenRequiredAuditRoll(SalePOS: Record "NPR Sale POS"): Boolean
    var
        AuditRoll: Record "NPR Audit Roll";
        PaymentTypePOS: Record "NPR Payment Type POS";
        FilterString: Text;
    begin
        PaymentTypePOS.SetCurrentKey("Processing Type");
        PaymentTypePOS.SetRange("Open Drawer", true);
        if not PaymentTypePOS.FindSet then
            exit;

        repeat
            if FilterString <> '' then
                FilterString += '|';
            FilterString += '''' + PaymentTypePOS."No." + '''';
        until PaymentTypePOS.Next = 0;

        AuditRoll.SetRange("Register No.", SalePOS."Register No.");
        AuditRoll.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Payment);
        AuditRoll.SetRange(Type, AuditRoll.Type::Payment);
        AuditRoll.SetFilter("No.", FilterString);
        AuditRoll.SetFilter("Amount Including VAT", '<>%1', 0);
        exit(not AuditRoll.IsEmpty);
    end;

    local procedure IsDrawerOpenRequiredPOSEntry(SalePOS: Record "NPR Sale POS"): Boolean
    var
        POSEntry: Record "NPR POS Entry";
        POSPaymentLine: Record "NPR POS Payment Line";
        PaymentTypePOS: Record "NPR Payment Type POS";
        POSEntryManagement: Codeunit "NPR POS Entry Management";
        FilterString: Text;
    begin
        PaymentTypePOS.SetCurrentKey("Processing Type");
        PaymentTypePOS.SetRange("Open Drawer", true);
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
        POSPaymentLine.SetFilter("Amount (Sales Currency)", '<>%1', 0);
        exit(not POSPaymentLine.IsEmpty);
    end;

    local procedure CarryOutPaymentBinEject(SalePOS: Record "NPR Sale POS"; Force: Boolean)
    var
        NPRetailSetup: Record "NPR NP Retail Setup";
        POSPaymentBin: Record "NPR POS Payment Bin";
        POSUnit: Record "NPR POS Unit";
        POSPostingProfile: Record "NPR POS Posting Profile";
        OpenDrawer: Boolean;
    begin
        OpenDrawer := Force;
        if not OpenDrawer then begin
            if not NPRetailSetup.Get then
                exit;

            //Change below to just loop and fire open on all unique payment bin from pos payment lines when the payment bins are properly implemented on payments

            OpenDrawer := IsDrawerOpenRequiredPOSEntry(SalePOS);

            if not OpenDrawer then
                exit;
        end;

        POSUnit.GetProfile(POSPostingProfile);
        if ((not POSUnit.Get(SalePOS."Register No.")) or (not POSPaymentBin.Get(POSPostingProfile."POS Payment Bin"))) then
            POSPaymentBin."Eject Method" := 'PRINTER';

        EjectDrawer(POSPaymentBin, SalePOS);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sales Workflow Step", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "NPR POS Sales Workflow Step"; RunTrigger: Boolean)
    begin
        if Rec."Subscriber Codeunit ID" <> CODEUNIT::"NPR POS Payment Bin Eject Mgt." then
            exit;
        if Rec."Subscriber Function" <> 'EjectPaymentBin' then
            exit;

        Rec.Description := WORKFLOW_STEP;
        Rec."Sequence No." := 15;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnFinishSale', '', true, true)]
    local procedure EjectPaymentBin(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SalePOS: Record "NPR Sale POS")
    begin
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CODEUNIT::"NPR POS Payment Bin Eject Mgt." then
            exit;
        if POSSalesWorkflowStep."Subscriber Function" <> 'EjectPaymentBin' then
            exit;

        CarryOutPaymentBinEject(SalePOS, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sales Workflow Step", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertCreditSaleWorkflowStep(var Rec: Record "NPR POS Sales Workflow Step"; RunTrigger: Boolean)
    begin
        if Rec."Subscriber Codeunit ID" <> CODEUNIT::"NPR POS Payment Bin Eject Mgt." then
            exit;
        if Rec."Subscriber Function" <> 'EjectPaymentBinOnCreditSale' then
            exit;

        Rec.Description := WORKFLOW_STEP;
        Rec."Sequence No." := 10;
        Rec.Enabled := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Sales Doc. Exp. Mgt.", 'OnFinishCreditSale', '', true, true)]
    local procedure EjectPaymentBinOnCreditSale(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SalePOS: Record "NPR Sale POS")
    var
        NPRetailSetup: Record "NPR NP Retail Setup";
        OpenDrawer: Boolean;
        POSPaymentBin: Record "NPR POS Payment Bin";
        POSUnit: Record "NPR POS Unit";
    begin
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CODEUNIT::"NPR POS Payment Bin Eject Mgt." then
            exit;
        if POSSalesWorkflowStep."Subscriber Function" <> 'EjectPaymentBinOnCreditSale' then
            exit;

        CarryOutPaymentBinEject(SalePOS, true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnEjectPaymentBin(POSPaymentBin: Record "NPR POS Payment Bin"; var Ejected: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLookupBinInvokeMethods(var tmpRetailList: Record "NPR Retail List")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnShowInvokeParameters(POSPaymentBin: Record "NPR POS Payment Bin")
    begin
    end;
}

