codeunit 6014442 "NPR Event Subscriber (Cust)"
{
    Permissions = TableData "NPR Audit Roll" = rimd;

    var
        RetailSetup: Record "NPR Retail Setup";
        SalesSetup: Record "Sales & Receivables Setup";
        RetailSetupFetched: Boolean;
        SalesSetupFetched: Boolean;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterInsertEvent', '', false, false)]
    local procedure CustomerOnAfterInsertEvent(var Rec: Record Customer; RunTrigger: Boolean)
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
        NoNumberErr: Label 'Number must not be blank!';
    begin
        if not RunTrigger then
            exit;

        if Rec."NPR Type" <> Rec."NPR Type"::Cash then begin
            if Rec."No." = '' then begin
                GetSalesSetup;
                SalesSetup.TestField("Customer Nos.");
                NoSeriesMgt.InitSeries(SalesSetup."Customer Nos.", '', 0D, Rec."No.", Rec."No. Series");
                Rec."Invoice Disc. Code" := Rec."No.";
            end;
        end else
            if Rec."No." = '' then
                Error(NoNumberErr);
        Rec."NPR Primary Key Length" := StrLen(Rec."No.");
        Rec.Modify();
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeDeleteEvent', '', true, false)]
    local procedure OnBeforeDeleteEvent(var Rec: Record Customer; RunTrigger: Boolean)
    var
        AuditRoll: Record "NPR Audit Roll";
        SalesLinePOS: Record "NPR Sale Line POS";
        SalesPOS: Record "NPR Sale POS";
        DeleteCustActiveCashErr: Label 'You can''t delete customer %1 as it is used on active cash payment.', Comment = '%1 = Customer';
        DeleteCustActiveSalesDocErr: Label 'You can''t delete customer %1 as it is used on an active sales document.', Comment = '%1 = Customer';
        DeleteCustActivePostedEntriesErr: Label 'You can''t delete customer %1 as there are one or more non posted entries.', Comment = '%1 = Customer';
    begin
        if not RunTrigger then
            exit;

        if Rec."No." = '' then
            exit;

        AuditRoll.SetCurrentKey("Sale Type", Type, "No.", Posted);
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Deposit);
        AuditRoll.SetRange(Type, AuditRoll.Type::Customer);
        AuditRoll.SetRange("No.", Rec."No.");
        AuditRoll.SetRange(Posted, false);
        if AuditRoll.FindFirst() then
            Error(DeleteCustActivePostedEntriesErr, Rec."No.");

        SalesPOS.SetRange("Customer No.", Rec."No.");
        if SalesPOS.FindFirst() then
            Error(DeleteCustActiveSalesDocErr, Rec."No.");

        SalesLinePOS.SetRange("Sale Type", SalesLinePOS."Sale Type"::Deposit);
        SalesLinePOS.SetRange(Type, SalesLinePOS.Type::Customer);
        SalesLinePOS.SetRange("No.", Rec."No.");
        if SalesLinePOS.FindFirst() then
            Error(DeleteCustActiveCashErr, Rec."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterRenameEvent', '', true, false)]
    local procedure OnAfterRenameEvent(var Rec: Record Customer; var xRec: Record Customer; RunTrigger: Boolean)
    var
        AuditRoll: Record "NPR Audit Roll";
        SalesLinePOS: Record "NPR Sale Line POS";
        SalesPOS: Record "NPR Sale POS";
    begin
        if not RunTrigger then
            exit;

        AuditRoll.SetCurrentKey("Sale Type", Type, "No.", Posted);
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Deposit);
        AuditRoll.SetRange(Type, AuditRoll.Type::Customer);
        AuditRoll.SetRange("No.", xRec."No.");
        AuditRoll.SetRange(Posted, false);
        if AuditRoll.FindFirst() then
            AuditRoll.ModifyAll("No.", Rec."No.");

        if not RunTrigger then
            exit;

        SalesPOS.SetRange("Customer No.", xRec."No.");
        SalesPOS.ModifyAll("Customer No.", Rec."No.");

        SalesLinePOS.SetRange("Sale Type", SalesLinePOS."Sale Type"::Deposit);
        SalesLinePOS.SetRange(Type, SalesLinePOS.Type::Customer);
        SalesLinePOS.SetRange("No.", xRec."No.");
        SalesLinePOS.ModifyAll("No.", Rec."No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterValidateEvent', 'Payment Terms Code', true, false)]
    local procedure OnAfterValidateEventPaymentTermsCode(var Rec: Record Customer; var xRec: Record Customer; CurrFieldNo: Integer)
    var
        PaymentTerms: Record "Payment Terms";
        PaymentTermsErr: Label 'Specify %1 for %2!', Comment = '%1 = Due Date Calculation, %2 = Payment Terms Code';
        ConvertCustQst: Label 'Want to convert customer %1 from type cash to type customer?', Comment = '%1 = Customer Name';
    begin
        if Rec."Payment Terms Code" = '' then
            exit;
        PaymentTerms.Get(Rec."Payment Terms Code");
        if Format(PaymentTerms."Due Date Calculation") = '' then
            Error(PaymentTermsErr, PaymentTerms.FieldCaption("Due Date Calculation"), PaymentTerms.Code);
        if Format(PaymentTerms."Due Date Calculation") = Format(0D) then
            Rec."NPR Type" := Rec."NPR Type"::Cash
        else
            Rec."NPR Type" := Rec."NPR Type"::Customer;

        if (xRec."NPR Type" = xRec."NPR Type"::Cash) and (xRec."NPR Type" <> Rec."NPR Type") then begin
            if not Confirm(StrSubstNo(ConvertCustQst, Rec.Name), false) then begin
                Rec."Payment Terms Code" := xRec."Payment Terms Code";
                Rec."NPR Type" := Rec."NPR Type"::Cash;
            end else
                Rec."NPR Type" := Rec."NPR Type"::Customer;
        end;
    end;

    local procedure GetSalesSetup(): Boolean
    begin
        if SalesSetupFetched then
            exit(true);

        if not SalesSetup.Get then
            exit(false);
        SalesSetupFetched := true;
        exit(true);
    end;

    local procedure GetRetailSetup(): Boolean
    begin
        if RetailSetupFetched then
            exit(true);

        if not RetailSetup.Get then
            exit(false);
        RetailSetupFetched := true;
        exit(true);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Customer List", 'OnAfterActionEvent', 'NPR ItemLedgerEntries', false, false)]
    local procedure CustomerListActionEventItemLedgerEntries(var Rec: Record Customer)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetRange("Source No.", Rec."No.");
        PAGE.RunModal(PAGE::"Item Ledger Entries", ItemLedgerEntry);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Customer Card", 'OnAfterActionEvent', 'NPR ItemLedgerEntries', false, false)]
    local procedure CustomerCardOnAfterActionEventItemLedgerEntries(var Rec: Record Customer)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetRange("Source No.", Rec."No.");
        PAGE.RunModal(PAGE::"Item Ledger Entries", ItemLedgerEntry);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Customer Card", 'OnAfterActionEvent', 'NPR PrintShippingLabel', false, false)]
    local procedure CustomerCardOnAfterActionEventPrintShippingLabel(var Rec: Record Customer)
    var
        Customer: Record Customer;
        LabelLibrary: Codeunit "NPR Label Library";
        RecRef: RecordRef;
    begin
        Customer := Rec;
        Customer.SetRecFilter;
        RecRef.GetTable(Customer);
        LabelLibrary.PrintCustomShippingLabel(RecRef, '');
    end;
}

