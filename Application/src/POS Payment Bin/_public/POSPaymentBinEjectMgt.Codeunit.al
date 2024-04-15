codeunit 6150641 "NPR POS Payment Bin Eject Mgt."
{
    var
        WORKFLOW_STEP: Label 'Eject Payment Bin';

    internal procedure EjectDrawer(POSPaymentBin: Record "NPR POS Payment Bin"; SalePOS: Record "NPR POS Sale"; ManualOpen: Boolean): Boolean
    var
        Ejected: Boolean;
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        RecordId: RecordId;
        AuditLogDesc: Label 'Opened by %1';
        POSEntry: Record "NPR POS Entry";
    begin
        if POSPaymentBin."Eject Method" = '' then
            exit;

        OnEjectPaymentBin(POSPaymentBin, Ejected);

        if Ejected then begin
            if POSEntry.GetBySystemId(SalePOS.SystemId) then
                POSAuditLogMgt.CreateEntryExtended(POSEntry.RecordId, GetDrawerActionType(ManualOpen), POSEntry."Entry No.", POSEntry."Fiscal No.", SalePOS."Register No.", StrSubstNo(AuditLogDesc, SalePOS."Salesperson Code"), '')
            else
                POSAuditLogMgt.CreateEntryExtended(RecordId, GetDrawerActionType(ManualOpen), 0, '', SalePOS."Register No.", StrSubstNo(AuditLogDesc, SalePOS."Salesperson Code"), '');
        end;

        exit(Ejected);
    end;

    procedure LookupInvokeMethods(POSPaymentBin: Record "NPR POS Payment Bin"; var SelectedMethod: Text): Boolean
    var
        TempRetailList: Record "NPR Retail List" temporary;
    begin
        OnLookupBinInvokeMethods(TempRetailList);
        if PAGE.RunModal(0, TempRetailList) = ACTION::LookupOK then begin
            SelectedMethod := TempRetailList.Value;
            exit(true);
        end;
    end;

    internal procedure ShowGenericParameters(POSPaymentBin: Record "NPR POS Payment Bin")
    var
        POSPaymentBinInvokeParameter: Record "NPR POS Paym. Bin Eject Param.";
    begin
        POSPaymentBinInvokeParameter.SetRange("Bin No.", POSPaymentBin."No.");
        PAGE.RunModal(0, POSPaymentBinInvokeParameter);
    end;

    internal procedure GetTextParameterValue(BinNoIn: Code[10]; NameIn: Text; DefaultValue: Text): Text
    var
        InvokeParameter: Record "NPR POS Paym. Bin Eject Param.";
    begin
        InvokeParameter.FindOrCreateRecord(BinNoIn, NameIn, InvokeParameter."Data Type"::Text, DefaultValue, '');
        exit(InvokeParameter.Value);
    end;

    internal procedure GetIntegerParameterValue(BinNoIn: Code[10]; NameIn: Text; DefaultValue: Integer): Integer
    var
        InvokeParameter: Record "NPR POS Paym. Bin Eject Param.";
        "Integer": Integer;
    begin
        InvokeParameter.FindOrCreateRecord(BinNoIn, NameIn, InvokeParameter."Data Type"::Integer, DefaultValue, '');
        Evaluate(Integer, InvokeParameter.Value, 9);
        exit(Integer);
    end;

    internal procedure GetBooleanParameterValue(BinNoIn: Code[10]; NameIn: Text; DefaultValue: Boolean): Boolean
    var
        InvokeParameter: Record "NPR POS Paym. Bin Eject Param.";
        Boolean: Boolean;
    begin
        InvokeParameter.FindOrCreateRecord(BinNoIn, NameIn, InvokeParameter."Data Type"::Boolean, DefaultValue, '');
        Evaluate(Boolean, InvokeParameter.Value, 9);
        exit(Boolean);
    end;

    internal procedure GetOptionParameterValue(BinNoIn: Code[10]; NameIn: Text; DefaultValue: Integer; OptionStringIn: Text): Integer
    var
        InvokeParameter: Record "NPR POS Paym. Bin Eject Param.";
        "Integer": Integer;
    begin
        InvokeParameter.FindOrCreateRecord(BinNoIn, NameIn, InvokeParameter."Data Type"::Option, DefaultValue, OptionStringIn);
        Evaluate(Integer, InvokeParameter.Value, 9);
        exit(Integer);
    end;

    internal procedure GetDecimalParameterValue(BinNoIn: Code[10]; NameIn: Text; DefaultValue: Decimal): Decimal
    var
        InvokeParameter: Record "NPR POS Paym. Bin Eject Param.";
        Decimal: Decimal;
    begin
        InvokeParameter.FindOrCreateRecord(BinNoIn, NameIn, InvokeParameter."Data Type"::Decimal, DefaultValue, '');
        Evaluate(Decimal, InvokeParameter.Value, 9);
        exit(Decimal);
    end;

    internal procedure GetDateParameterValue(BinNoIn: Code[10]; NameIn: Text; DefaultValue: Date): Date
    var
        InvokeParameter: Record "NPR POS Paym. Bin Eject Param.";
        Date: Date;
    begin
        InvokeParameter.FindOrCreateRecord(BinNoIn, NameIn, InvokeParameter."Data Type"::Date, DefaultValue, '');
        Evaluate(Date, InvokeParameter.Value, 9);
        exit(Date);
    end;


    local procedure IsDrawerOpenRequiredPOSEntry(SalePOS: Record "NPR POS Sale"): Boolean
    var
        POSEntry: Record "NPR POS Entry";
        POSPaymentLine: Record "NPR POS Entry Payment Line";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSEntryManagement: Codeunit "NPR POS Entry Management";
        FilterString: Text;
    begin
        POSPaymentMethod.SetCurrentKey("Processing Type");
        POSPaymentMethod.SetRange("Open Drawer", true);
        if not POSPaymentMethod.FindSet() then
            exit;

        repeat
            if FilterString <> '' then
                FilterString += '|';
            FilterString += '''' + POSPaymentMethod.Code + '''';
        until POSPaymentMethod.Next() = 0;

        if not POSEntryManagement.FindPOSEntryViaDocumentNo(SalePOS."Sales Ticket No.", POSEntry) then
            exit(false);

        POSPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSPaymentLine.SetFilter("POS Payment Method Code", FilterString);
        POSPaymentLine.SetFilter("Amount (Sales Currency)", '<>%1', 0);
        exit(not POSPaymentLine.IsEmpty());
    end;

    procedure CarryOutPaymentBinEject(SalePOS: Record "NPR POS Sale"; Force: Boolean)
    var
        POSPaymentBin: Record "NPR POS Payment Bin";
        POSUnit: Record "NPR POS Unit";
        OpenDrawer: Boolean;
    begin
        OpenDrawer := Force;
        if not OpenDrawer then begin
            //Change below to just loop and fire open on all unique payment bin from pos payment lines when the payment bins are properly implemented on payments
            OpenDrawer := IsDrawerOpenRequiredPOSEntry(SalePOS);
            if not OpenDrawer then
                exit;
        end;

        if ((not POSUnit.Get(SalePOS."Register No.")) or (not POSPaymentBin.Get(POSUnit."Default POS Payment Bin"))) then
            POSPaymentBin."Eject Method" := 'PRINTER';

        EjectDrawer(POSPaymentBin, SalePOS, false);
    end;

    local procedure GetDrawerActionType(Manual: Boolean): Option
    var
        POSAuditLog: Record "NPR POS Audit Log";
    begin
        if Manual then
            exit(POSAuditLog."Action Type"::MANUAL_DRAWER_OPEN);

        exit(POSAuditLog."Action Type"::AUTO_DRAWER_OPEN);
    end;

    [Obsolete('Remove after POS Scenario is removed', 'NPR32.0')]
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

    [Obsolete('Remove after POS Scenario is removed', 'NPR32.0')]
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnFinishSale', '', true, true)]
    local procedure EjectPaymentBin(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SalePOS: Record "NPR POS Sale")
    var
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        if FeatureFlagsManagement.IsEnabled('posLifeCycleEventsWorkflowsEnabled_v2') then
            exit;
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CODEUNIT::"NPR POS Payment Bin Eject Mgt." then
            exit;
        if POSSalesWorkflowStep."Subscriber Function" <> 'EjectPaymentBin' then
            exit;

        CarryOutPaymentBinEject(SalePOS, false);
    end;

    [Obsolete('Remove after POS Scenario is removed', 'NPR32.0')]
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

    [Obsolete('Remove after POS Scenario is removed', 'NPR32.0')]
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Credit Sale Post-Process", 'OnFinishCreditSale', '', true, true)]
    local procedure EjectPaymentBinOnCreditSale(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SalePOS: Record "NPR POS Sale")
    begin
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CODEUNIT::"NPR POS Payment Bin Eject Mgt." then
            exit;
        if POSSalesWorkflowStep."Subscriber Function" <> 'EjectPaymentBinOnCreditSale' then
            exit;
        CarryOutPaymentBinEject(SalePOS, true);
    end;

    procedure EjectPaymeBinOnCreditSale(SalePOS: Record "NPR POS Sale")
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSUnit: Record "NPR POS Unit";
    begin
        If POSUnit.Get(SalePOS."Register No.") then
            if POSAuditProfile.Get(POSUnit."POS Audit Profile") then
                if POSAuditProfile."Bin Eject After Credit Sale" then
                    CarryOutPaymentBinEject(SalePOS, true);
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnEjectPaymentBin(POSPaymentBin: Record "NPR POS Payment Bin"; var Ejected: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLookupBinInvokeMethods(var tmpRetailList: Record "NPR Retail List")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnShowInvokeParameters(POSPaymentBin: Record "NPR POS Payment Bin")
    begin
    end;
}

