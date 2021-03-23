codeunit 6014442 "NPR Event Subscriber (Cust)"
{
    Permissions = TableData "NPR POS Entry" = rimd;

    var
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

        if Rec."No." = '' then
            exit;

        GetSalesSetup();
        SalesSetup.TestField("Customer Nos.");
        NoSeriesMgt.InitSeries(SalesSetup."Customer Nos.", '', 0D, Rec."No.", Rec."No. Series");
        Rec."Invoice Disc. Code" := Rec."No.";

        Rec.Modify();
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeDeleteEvent', '', true, false)]
    local procedure OnBeforeDeleteEvent(var Rec: Record Customer; RunTrigger: Boolean)
    var
        SalesLinePOS: Record "NPR Sale Line POS";
        SalesPOS: Record "NPR Sale POS";
        DeleteCustActiveCashErr: Label 'You can''t delete customer %1 as it is used on active cash payment.', Comment = '%1 = Customer';
        DeleteCustActiveSalesDocErr: Label 'You can''t delete customer %1 as it is used on an active sales document.', Comment = '%1 = Customer';
        DeleteCustActivePostedEntriesErr: Label 'You can''t delete customer %1 as there are one or more non posted entries.', Comment = '%1 = Customer';
        POSEntry: Record "NPR POS Entry";
    begin
        if not RunTrigger then
            exit;

        if Rec."No." = '' then
            exit;

        POSEntry.SetRange("Customer No.", Rec."No.");
        POSEntry.SetRange("Post Entry Status", POSEntry."Post Entry Status"::Unposted);
        if POSEntry.FindFirst() then
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
        SalesLinePOS: Record "NPR Sale Line POS";
        SalesPOS: Record "NPR Sale POS";
        POSEntry: Record "NPR POS Entry";
        POSSalesLine: Record "NPR POS Sales Line";
    begin
        if not RunTrigger then
            exit;

        POSEntry.SetRange("Customer No.", xRec."No.");
        POSEntry.SetRange("Post Entry Status", POSEntry."Post Entry Status"::Unposted);
        if POSEntry.FindSet() then begin
            repeat
                POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
                POSSalesLine.ModifyAll("Customer No.", Rec."No.");
            until POSEntry.Next() = 0;
            POSEntry.ModifyAll("Customer No.", Rec."No.");
        end;

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

