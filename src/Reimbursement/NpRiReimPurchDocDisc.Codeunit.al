codeunit 6151107 "NPR NpRi Reim. Purch.Doc.Disc."
{
    // NPR5.46/MHA /20181002  CASE 323942 Object Created - NaviPartner Reimbursement - Purchase Document Discount
    // NPR5.47/MHA /20181011  CASE 323942 Added Read/Modify Permission to Vendor Ledger Entry

    Permissions = TableData "Vendor Ledger Entry" = rm;

    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Purchase Document Discount';
        Text001: Label 'Purchase Document Discount may only be applied to Vendor Ledger Entries';
        GeneralLedgerSetup: Record "General Ledger Setup";

    local procedure "--- Discover"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151100, 'DiscoverModules', '', true, true)]
    local procedure DiscoverPurchDocDiscCode(var NpRiModule: Record "NPR NpRi Reimbursement Module")
    begin
        if NpRiModule.Get(PurchDocDiscCode()) then
            exit;

        NpRiModule.Init;
        NpRiModule.Code := PurchDocDiscCode();
        NpRiModule.Description := CopyStr(Text000, 1, MaxStrLen(NpRiModule.Description));
        NpRiModule.Type := NpRiModule.Type::Reimbursement;
        NpRiModule."Subscriber Codeunit ID" := CurrCodeunitId();
        NpRiModule.Insert(true);
    end;

    local procedure PurchDocDiscCode(): Code[20]
    begin
        exit('PURCH_DOC_DISCOUNT');
    end;

    [EventSubscriber(ObjectType::Table, 6151101, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeleteTemplate(var Rec: Record "NPR NpRi Reimbursement Templ."; RunTrigger: Boolean)
    var
        NpRiPurchDocDiscSetup: Record "NPR NpRi Purch.Doc.Disc. Setup";
    begin
        if Rec.IsTemporary then
            exit;

        if NpRiPurchDocDiscSetup.Get(Rec.Code) then
            NpRiPurchDocDiscSetup.Delete(RunTrigger);
    end;

    local procedure "--- Setup Parameters"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151102, 'HasTemplateParameters', '', true, true)]
    procedure HasTemplateParameters(NpRiReimbursementTemplate: Record "NPR NpRi Reimbursement Templ."; var HasParameters: Boolean)
    begin
        if NpRiReimbursementTemplate."Reimbursement Module" <> PurchDocDiscCode() then
            exit;

        HasParameters := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151102, 'SetupTemplateParameters', '', true, true)]
    procedure SetupTemplateParameters(var NpRiReimbursementTemplate: Record "NPR NpRi Reimbursement Templ.")
    var
        NpRiPurchDocDiscSetup: Record "NPR NpRi Purch.Doc.Disc. Setup";
        Summary: Text;
    begin
        if NpRiReimbursementTemplate."Reimbursement Module" <> PurchDocDiscCode() then
            exit;

        if not NpRiPurchDocDiscSetup.Get(NpRiReimbursementTemplate.Code) then begin
            NpRiPurchDocDiscSetup.Init;
            NpRiPurchDocDiscSetup."Template Code" := NpRiReimbursementTemplate.Code;
            NpRiPurchDocDiscSetup.Insert(true);
            Commit;
        end;

        NpRiPurchDocDiscSetup.FilterGroup(2);
        NpRiPurchDocDiscSetup.SetRange("Template Code", NpRiReimbursementTemplate.Code);
        NpRiPurchDocDiscSetup.FilterGroup(0);

        PAGE.RunModal(PAGE::"NPR NpRi Purch.Doc.Disc. Setup", NpRiPurchDocDiscSetup);

        if NpRiPurchDocDiscSetup.Find then;
        NpRiPurchDocDiscSetup.SetRange("Discount %", NpRiPurchDocDiscSetup."Discount %");
        NpRiPurchDocDiscSetup.SetRange("Bal. Account No.", NpRiPurchDocDiscSetup."Bal. Account No.");
        NpRiPurchDocDiscSetup.SetRange("Bal. Gen. Prod. Posting Group", NpRiPurchDocDiscSetup."Bal. Gen. Prod. Posting Group");
        NpRiPurchDocDiscSetup.SetRange("Bal. VAT Prod. Posting Group", NpRiPurchDocDiscSetup."Bal. VAT Prod. Posting Group");
        Summary := NpRiPurchDocDiscSetup.GetFilters;
        NpRiReimbursementTemplate."Reimbursement Summary" := CopyStr(Summary, 1, MaxStrLen(NpRiReimbursementTemplate."Reimbursement Summary"));
        NpRiReimbursementTemplate.Modify(true);
    end;

    local procedure "--- Reimbursement"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151102, 'OnRunReimbursement', '', true, true)]
    local procedure OnRunReimbursement(var NpRiReimbursement: Record "NPR NpRi Reimbursement"; var NpRiReimbursementEntryApply: Record "NPR NpRi Reimbursement Entry"; var Handled: Boolean)
    begin
        if NpRiReimbursement."Reimbursement Module" <> PurchDocDiscCode() then
            exit;
        if Handled then
            exit;

        Handled := true;
        RunPurchDocDiscReimbursement(NpRiReimbursement, NpRiReimbursementEntryApply);
    end;

    local procedure RunPurchDocDiscReimbursement(var NpRiReimbursement: Record "NPR NpRi Reimbursement"; var NpRiReimbursementEntryApply: Record "NPR NpRi Reimbursement Entry")
    var
        TempGenJnlLine: Record "Gen. Journal Line" temporary;
        Vendor: Record Vendor;
        ReimbursementAmount: Decimal;
    begin
        GeneralLedgerSetup.Get;
        GetVendor(NpRiReimbursement, Vendor);

        CreateGenJnl(NpRiReimbursement, Vendor, NpRiReimbursementEntryApply, TempGenJnlLine);
        ReimbursementAmount := -SetVendLedgEntryAppIds(NpRiReimbursement, NpRiReimbursementEntryApply, TempGenJnlLine);

        if TempGenJnlLine."VAT %" > 0 then
            ReimbursementAmount := Round(ReimbursementAmount * (1 + (TempGenJnlLine."VAT %" / 100)), GeneralLedgerSetup."Amount Rounding Precision");
        TempGenJnlLine."Amount (LCY)" := ReimbursementAmount;
        TempGenJnlLine."Source Currency Amount" := ReimbursementAmount;
        TempGenJnlLine.Amount := ReimbursementAmount;
        TempGenJnlLine.Validate(Amount);
        PostPurchDocDisc(ReimbursementAmount, NpRiReimbursementEntryApply, TempGenJnlLine);
    end;

    local procedure GetVendor(NpRiReimbursement: Record "NPR NpRi Reimbursement"; var Vendor: Record Vendor)
    var
        NpRiPartyType: Record "NPR NpRi Party Type";
    begin
        NpRiPartyType.Get(NpRiReimbursement."Party Type");
        NpRiPartyType.TestField("Table No.", DATABASE::Vendor);

        Vendor.Get(NpRiReimbursement."Party No.");
    end;

    local procedure CreateGenJnl(NpRiReimbursement: Record "NPR NpRi Reimbursement"; Vendor: Record Vendor; var NpRiReimbursementEntryApply: Record "NPR NpRi Reimbursement Entry"; var TempGenJnlLine: Record "Gen. Journal Line" temporary)
    var
        NpRiPurchDocDiscSetup: Record "NPR NpRi Purch.Doc.Disc. Setup";
    begin
        Clear(TempGenJnlLine);

        NpRiPurchDocDiscSetup.Get(NpRiReimbursement."Template Code");
        NpRiPurchDocDiscSetup.TestField("Discount %");
        NpRiPurchDocDiscSetup.TestField("Bal. Account No.");

        GeneralLedgerSetup.Get;

        TempGenJnlLine.Init;
        TempGenJnlLine."Posting Date" := NpRiReimbursement."Posting Date";
        TempGenJnlLine."Document No." := NpRiReimbursementEntryApply."Document No.";
        TempGenJnlLine."Document Date" := NpRiReimbursement."Posting Date";
        TempGenJnlLine.Description := NpRiReimbursementEntryApply.Description;
        TempGenJnlLine."Reason Code" := '';
        TempGenJnlLine."Account Type" := TempGenJnlLine."Account Type"::Vendor;
        TempGenJnlLine.Validate("Account No.", Vendor."No.");
        TempGenJnlLine."Document Type" := TempGenJnlLine."Document Type"::" ";
        TempGenJnlLine."External Document No." := NpRiReimbursement."Template Code";
        TempGenJnlLine."Bal. Account Type" := TempGenJnlLine."Bal. Account Type"::"G/L Account";
        TempGenJnlLine."Bal. Account No." := NpRiPurchDocDiscSetup."Bal. Account No.";
        TempGenJnlLine.Validate("Bal. Account No.");
        if NpRiPurchDocDiscSetup."Bal. Gen. Prod. Posting Group" <> '' then
            TempGenJnlLine.Validate("Bal. Gen. Prod. Posting Group", NpRiPurchDocDiscSetup."Bal. Gen. Prod. Posting Group");
        if NpRiPurchDocDiscSetup."Bal. VAT Prod. Posting Group" <> '' then
            TempGenJnlLine.Validate("Bal. VAT Prod. Posting Group", NpRiPurchDocDiscSetup."Bal. VAT Prod. Posting Group");

        TempGenJnlLine.Correction := false;
        TempGenJnlLine."Currency Factor" := 1;

        TempGenJnlLine."Applies-to Doc. No." := '';
        TempGenJnlLine."Applies-to ID" := TempGenJnlLine."Document No.";
        TempGenJnlLine."Allow Zero-Amount Posting" := true;
        TempGenJnlLine.Insert;
    end;

    local procedure SetVendLedgEntryAppIds(NpRiReimbursement: Record "NPR NpRi Reimbursement"; var NpRiReimbursementEntryApply: Record "NPR NpRi Reimbursement Entry"; var TempGenJnlLine: Record "Gen. Journal Line" temporary) ReimbursementAmount: Decimal
    var
        NpRiPurchDocDiscSetup: Record "NPR NpRi Purch.Doc.Disc. Setup";
        NpRiReimbursementEntry: Record "NPR NpRi Reimbursement Entry";
    begin
        NpRiReimbursementEntry.SetRange("Closed by Entry No.", NpRiReimbursementEntryApply."Entry No.");
        NpRiReimbursementEntry.SetFilter("Source Table No.", '<>%1', DATABASE::"Vendor Ledger Entry");
        if NpRiReimbursementEntry.FindFirst then
            Error(Text001);

        NpRiPurchDocDiscSetup.Get(NpRiReimbursement."Template Code");

        NpRiReimbursementEntry.Reset;
        NpRiReimbursementEntry.SetRange("Closed by Entry No.", NpRiReimbursementEntryApply."Entry No.");
        if NpRiReimbursementEntry.FindSet then
            repeat
                ReimbursementAmount += SetVendLedgEntryAppId(NpRiPurchDocDiscSetup, TempGenJnlLine, NpRiReimbursementEntry);
            until NpRiReimbursementEntry.Next = 0;

        exit(ReimbursementAmount);
    end;

    local procedure SetVendLedgEntryAppId(NpRiPurchDocDiscSetup: Record "NPR NpRi Purch.Doc.Disc. Setup"; var TempGenJnlLine: Record "Gen. Journal Line" temporary; var NpRiReimbursementEntry: Record "NPR NpRi Reimbursement Entry") ReimbursementAmount: Decimal
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
        VendEntrySetApplID: Codeunit "Vend. Entry-SetAppl.ID";
        AmountToApply: Decimal;
    begin
        VendLedgEntry.Get(NpRiReimbursementEntry."Source Entry No.");
        if not VendLedgEntry.Open then
            exit;
        if not (VendLedgEntry."Document Type" in [VendLedgEntry."Document Type"::"Credit Memo", VendLedgEntry."Document Type"::Invoice]) then
            exit;

        AmountToApply := Round(VendLedgEntry."Purchase (LCY)" * NpRiPurchDocDiscSetup."Discount %" / 100, GeneralLedgerSetup."Amount Rounding Precision");
        if AmountToApply = 0 then
            exit;

        VendLedgEntry."Applies-to ID" := TempGenJnlLine."Document No.";
        VendLedgEntry."Amount to Apply" := AmountToApply;
        VendLedgEntry.Modify;

        NpRiReimbursementEntry."Reimbursement Amount" := VendLedgEntry."Amount to Apply";
        NpRiReimbursementEntry.Modify;

        exit(NpRiReimbursementEntry."Reimbursement Amount");
    end;

    local procedure PostPurchDocDisc(ReimbursementAmount: Decimal; var NpRiReimbursementEntryApply: Record "NPR NpRi Reimbursement Entry"; var TempGenJnlLine: Record "Gen. Journal Line" temporary)
    var
        GLEntry: Record "G/L Entry";
        TempGenJnlLine2: Record "Gen. Journal Line" temporary;
        VendLedgEntry: Record "Vendor Ledger Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        TempGenJnlLine2 := TempGenJnlLine;

        LockGLEntry(GLEntry);
        UpdateApplicationEntry(GLEntry, TempGenJnlLine, ReimbursementAmount, NpRiReimbursementEntryApply);
        GenJnlPostLine.RunWithCheck(TempGenJnlLine);

        VendLedgEntry.SetRange("Posting Date", TempGenJnlLine2."Posting Date");
        VendLedgEntry.SetRange("Document No.", TempGenJnlLine2."Document No.");
        VendLedgEntry.FindLast;
        UpdateApplicationEntry2(VendLedgEntry, NpRiReimbursementEntryApply);
    end;

    local procedure LockGLEntry(var GLEntry: Record "G/L Entry")
    begin
        Clear(GLEntry);
        GLEntry.LockTable;
        if GLEntry.FindLast then;
        GLEntry."Entry No." += 1;
    end;

    local procedure UpdateApplicationEntry(GLEntry: Record "G/L Entry"; TempGenJnlLine: Record "Gen. Journal Line" temporary; ReimbursementAmount: Decimal; var NpRiReimbursementEntryApply: Record "NPR NpRi Reimbursement Entry")
    begin
        NpRiReimbursementEntryApply."Source Table No." := DATABASE::"G/L Entry";
        NpRiReimbursementEntryApply."Source Record ID" := GLEntry.RecordId;
        NpRiReimbursementEntryApply."Source Record Position" := GLEntry.GetPosition(false);
        NpRiReimbursementEntryApply."Source Entry No." := GLEntry."Entry No.";
        NpRiReimbursementEntryApply."Reimbursement Amount" := ReimbursementAmount;
        NpRiReimbursementEntryApply."Document Type" := NpRiReimbursementEntryApply."Document Type"::" ";
        NpRiReimbursementEntryApply."Document No." := TempGenJnlLine."Document No.";
        NpRiReimbursementEntryApply."Account Type" := TempGenJnlLine."Account Type";
        NpRiReimbursementEntryApply."Account No." := TempGenJnlLine."Account No.";
        NpRiReimbursementEntryApply.Modify(true);
    end;

    local procedure UpdateApplicationEntry2(VendLedgEntry: Record "Vendor Ledger Entry"; var NpRiReimbursementEntryApply: Record "NPR NpRi Reimbursement Entry")
    begin
        NpRiReimbursementEntryApply."Source Table No." := DATABASE::"Vendor Ledger Entry";
        NpRiReimbursementEntryApply."Source Record ID" := VendLedgEntry.RecordId;
        NpRiReimbursementEntryApply."Source Record Position" := VendLedgEntry.GetPosition(false);
        NpRiReimbursementEntryApply."Source Entry No." := VendLedgEntry."Entry No.";
        NpRiReimbursementEntryApply.Modify(true);
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpRi Reim. Purch.Doc.Disc.");
    end;
}

