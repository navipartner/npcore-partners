codeunit 6151105 "NPR NpRi Reimburse Provision"
{
    var
        Text000: Label 'Post percentage of Data Collection Amount to G/L';

    // Discover

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRi Setup Mgt.", 'DiscoverModules', '', true, true)]
    local procedure DiscoverProvision(var NpRiModule: Record "NPR NpRi Reimbursement Module")
    begin
        if NpRiModule.Get(ProvisionCode()) then
            exit;

        NpRiModule.Init;
        NpRiModule.Code := ProvisionCode();
        NpRiModule.Description := Text000;
        NpRiModule.Type := NpRiModule.Type::Reimbursement;
        NpRiModule."Subscriber Codeunit ID" := CurrCodeunitId();
        NpRiModule.Insert(true);
    end;

    local procedure ProvisionCode(): Code[20]
    begin
        exit('PROVISION');
    end;

    [EventSubscriber(ObjectType::Table, Codeunit::"NPR NpRi Data Collection Mgt.", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeleteTemplate(var Rec: Record "NPR NpRi Reimbursement Templ."; RunTrigger: Boolean)
    var
        NpRiProvisionSetup: Record "NPR NpRi Provision Setup";
    begin
        if Rec.IsTemporary then
            exit;

        if NpRiProvisionSetup.Get(Rec.Code) then
            NpRiProvisionSetup.Delete(RunTrigger);
    end;

    //Setup Parameters
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRi Reimbursement Mgt.", 'HasTemplateParameters', '', true, true)]
    procedure HasTemplateParameters(NpRiReimbursementTemplate: Record "NPR NpRi Reimbursement Templ."; var HasParameters: Boolean)
    begin
        if NpRiReimbursementTemplate."Reimbursement Module" <> ProvisionCode() then
            exit;

        HasParameters := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRi Reimbursement Mgt.", 'SetupTemplateParameters', '', true, true)]
    procedure SetupTemplateParameters(var NpRiReimbursementTemplate: Record "NPR NpRi Reimbursement Templ.")
    var
        NpRiProvisionSetup: Record "NPR NpRi Provision Setup";
        Summary: Text;
    begin
        if NpRiReimbursementTemplate."Reimbursement Module" <> ProvisionCode() then
            exit;

        if not NpRiProvisionSetup.Get(NpRiReimbursementTemplate.Code) then begin
            NpRiProvisionSetup.Init;
            NpRiProvisionSetup."Template Code" := NpRiReimbursementTemplate.Code;
            NpRiProvisionSetup.Insert(true);
            Commit;
        end;

        NpRiProvisionSetup.FilterGroup(2);
        NpRiProvisionSetup.SetRange("Template Code", NpRiReimbursementTemplate.Code);
        NpRiProvisionSetup.FilterGroup(0);

        PAGE.RunModal(PAGE::"NPR NpRi Provision Setup", NpRiProvisionSetup);

        if NpRiProvisionSetup.Find then;
        NpRiProvisionSetup.SetRange("Provision %", NpRiProvisionSetup."Provision %");
        NpRiProvisionSetup.SetRange("Account No.", NpRiProvisionSetup."Account No.");
        NpRiProvisionSetup.SetRange("Bal. Account No.", NpRiProvisionSetup."Bal. Account No.");
        NpRiProvisionSetup.SetRange("Source Code", NpRiProvisionSetup."Source Code");
        Summary := NpRiProvisionSetup.GetFilters;
        NpRiReimbursementTemplate."Reimbursement Summary" := CopyStr(Summary, 1, MaxStrLen(NpRiReimbursementTemplate."Reimbursement Summary"));
        NpRiReimbursementTemplate.Modify(true);
    end;

    //Reimbursement

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRi Reimbursement Mgt.", 'OnRunReimbursement', '', true, true)]
    local procedure OnRunReimbursement(var NpRiReimbursement: Record "NPR NpRi Reimbursement"; var NpRiReimbursementEntryApply: Record "NPR NpRi Reimbursement Entry"; var Handled: Boolean)
    begin
        if NpRiReimbursement."Reimbursement Module" <> ProvisionCode() then
            exit;
        if Handled then
            exit;

        Handled := true;

        RunProvisionReimbursement(NpRiReimbursement, NpRiReimbursementEntryApply);
    end;

    local procedure RunProvisionReimbursement(var NpRiReimbursement: Record "NPR NpRi Reimbursement"; var NpRiReimbursementEntryApply: Record "NPR NpRi Reimbursement Entry")
    var
        TempGenJnlLine: Record "Gen. Journal Line" temporary;
        ReimbursementAmount: Decimal;
    begin
        ReimbursementAmount := CreateGenJnl(NpRiReimbursement, NpRiReimbursementEntryApply, TempGenJnlLine);
        if ReimbursementAmount = 0 then
            exit;
        PostProvision(ReimbursementAmount, NpRiReimbursementEntryApply, TempGenJnlLine);
    end;

    local procedure CreateGenJnl(NpRiReimbursement: Record "NPR NpRi Reimbursement"; var NpRiReimbursementEntryApply: Record "NPR NpRi Reimbursement Entry"; var TempGenJnlLine: Record "Gen. Journal Line" temporary) ReimbursementAmount: Decimal
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        NpRiProvisionSetup: Record "NPR NpRi Provision Setup";
        NpRiPartyType: Record "NPR NpRi Party Type";
        AmountExclVat: Decimal;
        AmountInclVat: Decimal;
    begin
        Clear(TempGenJnlLine);

        if NpRiReimbursementEntryApply.Amount = 0 then
            exit(0);

        NpRiProvisionSetup.Get(NpRiReimbursement."Template Code");
        NpRiProvisionSetup.TestField("Provision %");
        NpRiProvisionSetup.TestField("Account No.");
        NpRiProvisionSetup.TestField("Bal. Account No.");

        GeneralLedgerSetup.Get;
        AmountExclVat := Round(NpRiReimbursementEntryApply.Amount * NpRiProvisionSetup."Provision %" / 100, GeneralLedgerSetup."Amount Rounding Precision");
        if AmountExclVat = 0 then
            exit(0);

        TempGenJnlLine.Init;
        TempGenJnlLine."Posting Date" := NpRiReimbursement."Posting Date";
        TempGenJnlLine."Document No." := NpRiReimbursementEntryApply."Document No.";
        TempGenJnlLine."Document Date" := NpRiReimbursement."Posting Date";
        TempGenJnlLine.Description := NpRiReimbursementEntryApply.Description;
        TempGenJnlLine."Reason Code" := '';
        TempGenJnlLine."Account Type" := TempGenJnlLine."Account Type"::"G/L Account";
        TempGenJnlLine.Validate("Account No.", NpRiProvisionSetup."Account No.");
        TempGenJnlLine."Document Type" := TempGenJnlLine."Document Type"::" ";
        TempGenJnlLine."External Document No." := NpRiReimbursement."Template Code";
        TempGenJnlLine."Bal. Account Type" := TempGenJnlLine."Bal. Account Type"::"G/L Account";
        TempGenJnlLine."Bal. Account No." := NpRiProvisionSetup."Bal. Account No.";
        TempGenJnlLine.Validate("Bal. Account No.");
        if NpRiProvisionSetup."Gen. Prod. Posting Group" <> '' then
            TempGenJnlLine.Validate("Gen. Prod. Posting Group", NpRiProvisionSetup."Gen. Prod. Posting Group");
        if NpRiProvisionSetup."VAT Prod. Posting Group" <> '' then
            TempGenJnlLine.Validate("VAT Prod. Posting Group", NpRiProvisionSetup."VAT Prod. Posting Group");
        if NpRiProvisionSetup."Bal. Gen. Prod. Posting Group" <> '' then
            TempGenJnlLine.Validate("Bal. Gen. Prod. Posting Group", NpRiProvisionSetup."Bal. Gen. Prod. Posting Group");
        if NpRiProvisionSetup."Bal. VAT Prod. Posting Group" <> '' then
            TempGenJnlLine.Validate("Bal. VAT Prod. Posting Group", NpRiProvisionSetup."Bal. VAT Prod. Posting Group");

        AmountInclVat := AmountExclVat;
        if TempGenJnlLine."VAT %" > 0 then
            AmountInclVat := Round(AmountExclVat * (1 + (TempGenJnlLine."VAT %" / 100)), 0.01);
        TempGenJnlLine."Source Currency Amount" := AmountInclVat;
        TempGenJnlLine.Correction := false;
        TempGenJnlLine."Amount (LCY)" := AmountInclVat;
        TempGenJnlLine."Currency Factor" := 1;
        TempGenJnlLine.Amount := AmountInclVat;
        TempGenJnlLine.Validate(Amount);

        TempGenJnlLine."Applies-to Doc. No." := '';
        NpRiPartyType.Get(NpRiReimbursement."Party Type");
        case NpRiPartyType."Table No." of
            DATABASE::Customer:
                TempGenJnlLine."Source Type" := TempGenJnlLine."Source Type"::Customer;
            DATABASE::Vendor:
                TempGenJnlLine."Source Type" := TempGenJnlLine."Source Type"::Vendor;
            DATABASE::"Bank Account":
                TempGenJnlLine."Source Type" := TempGenJnlLine."Source Type"::"Bank Account";
            DATABASE::"Fixed Asset":
                TempGenJnlLine."Source Type" := TempGenJnlLine."Source Type"::"Fixed Asset";
            else
                TempGenJnlLine."Source Type" := TempGenJnlLine."Source Type"::" ";
        end;
        TempGenJnlLine."Source No." := NpRiReimbursement."Party No.";
        if NpRiProvisionSetup."Source Code" <> '' then
            TempGenJnlLine."Source Code" := NpRiProvisionSetup."Source Code";
        TempGenJnlLine."Allow Zero-Amount Posting" := true;
        TempGenJnlLine.Insert;

        exit(AmountExclVat);
    end;

    local procedure PostProvision(ReimbursementAmount: Decimal; var NpRiReimbursementEntryApply: Record "NPR NpRi Reimbursement Entry"; var TempGenJnlLine: Record "Gen. Journal Line" temporary)
    var
        GLEntry: Record "G/L Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        LockGLEntry(GLEntry);

        UpdateApplicationEntry(GLEntry, TempGenJnlLine, ReimbursementAmount, NpRiReimbursementEntryApply);
        GenJnlPostLine.RunWithCheck(TempGenJnlLine);
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

    //Aux
    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpRi Reimburse Provision");
    end;
}

