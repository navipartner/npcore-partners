codeunit 6151110 "NpRi Reim. Sales Inv."
{
    // NPR5.53/MHA /20191104  CASE 364131 Object Created - NaviPartner Reimbursement - Sales Invoice


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Sales Invoice';
        GeneralLedgerSetup: Record "General Ledger Setup";

    local procedure "--- Discover"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151100, 'DiscoverModules', '', true, true)]
    local procedure DiscoverSalesInv(var NpRiModule: Record "NpRi Reimbursement Module")
    begin
        if NpRiModule.Get(ModuleCode()) then
          exit;

        NpRiModule.Init;
        NpRiModule.Code := ModuleCode();
        NpRiModule.Description := CopyStr(Text000,1,MaxStrLen(NpRiModule.Description));
        NpRiModule.Type := NpRiModule.Type::Reimbursement;
        NpRiModule."Subscriber Codeunit ID" := CurrCodeunitId();
        NpRiModule.Insert(true);
    end;

    local procedure ModuleCode(): Code[20]
    begin
        exit('SALES_INVOICE');
    end;

    [EventSubscriber(ObjectType::Table, 6151101, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeleteTemplate(var Rec: Record "NpRi Reimbursement Template";RunTrigger: Boolean)
    var
        NpRiSalesInvSetup: Record "NpRi Sales Inv. Setup";
    begin
        if Rec.IsTemporary then
          exit;

        if NpRiSalesInvSetup.Get(Rec.Code) then
          NpRiSalesInvSetup.Delete(RunTrigger);
    end;

    local procedure "--- Setup Parameters"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151102, 'HasTemplateParameters', '', true, true)]
    procedure HasTemplateParameters(NpRiReimbursementTemplate: Record "NpRi Reimbursement Template";var HasParameters: Boolean)
    begin
        if NpRiReimbursementTemplate."Reimbursement Module" <> ModuleCode() then
          exit;

        HasParameters := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151102, 'SetupTemplateParameters', '', true, true)]
    procedure SetupTemplateParameters(var NpRiReimbursementTemplate: Record "NpRi Reimbursement Template")
    var
        NpRiSalesInvSetup: Record "NpRi Sales Inv. Setup";
        Summary: Text;
    begin
        if NpRiReimbursementTemplate."Reimbursement Module" <> ModuleCode() then
          exit;

        if not NpRiSalesInvSetup.Get(NpRiReimbursementTemplate.Code) then begin
          NpRiSalesInvSetup.Init;
          NpRiSalesInvSetup."Template Code" := NpRiReimbursementTemplate.Code;
          NpRiSalesInvSetup.Insert(true);
          Commit;
        end;

        NpRiSalesInvSetup.FilterGroup(2);
        NpRiSalesInvSetup.SetRange("Template Code",NpRiReimbursementTemplate.Code);
        NpRiSalesInvSetup.FilterGroup(0);

        PAGE.RunModal(PAGE::"NpRi Sales Inv. Setup",NpRiSalesInvSetup);

        if NpRiSalesInvSetup.Find then;

        NpRiSalesInvSetup.SetRecFilter;
        NpRiSalesInvSetup.SetRange("Template Code");
        Summary := NpRiSalesInvSetup.GetFilters;
        NpRiReimbursementTemplate."Reimbursement Summary" := CopyStr(Summary,1,MaxStrLen(NpRiReimbursementTemplate."Reimbursement Summary"));
        NpRiReimbursementTemplate.Modify(true);
    end;

    local procedure "--- Reimbursement"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151102, 'OnRunReimbursement', '', true, true)]
    local procedure OnRunReimbursement(var NpRiReimbursement: Record "NpRi Reimbursement";var NpRiReimbursementEntryApply: Record "NpRi Reimbursement Entry";var Handled: Boolean)
    var
        NpRiSalesInvSetup: Record "NpRi Sales Inv. Setup";
    begin
        if NpRiReimbursement."Reimbursement Module" <> ModuleCode() then
          exit;
        if Handled then
          exit;

        Handled := true;

        NpRiSalesInvSetup.Get(NpRiReimbursement."Template Code");
        case NpRiSalesInvSetup."Invoice per" of
          NpRiSalesInvSetup."Invoice per"::Period:
            begin
              RunSalesInvReimbursementPeriod(NpRiReimbursement,NpRiReimbursementEntryApply);
            end;
          NpRiSalesInvSetup."Invoice per"::Document:
            begin
              RunSalesInvReimbursementDocuments(NpRiReimbursement,NpRiReimbursementEntryApply);
            end;
        end;
    end;

    local procedure RunSalesInvReimbursementPeriod(var NpRiReimbursement: Record "NpRi Reimbursement";var NpRiReimbursementEntryApply: Record "NpRi Reimbursement Entry")
    var
        Cust: Record Customer;
        NpRiSalesInvSetupLine: Record "NpRi Sales Inv. Setup Line";
        SalesHeader: Record "Sales Header";
        ReimbursementAmt: Decimal;
        PostImmediately: Boolean;
    begin
        FindCust(NpRiReimbursement,Cust,PostImmediately);

        InsertSalesInvHeader(Cust,NpRiReimbursement,NpRiReimbursementEntryApply,SalesHeader);

        NpRiSalesInvSetupLine.SetRange("Template Code",NpRiReimbursement."Template Code");
        NpRiSalesInvSetupLine.FindSet;
        repeat
          ReimbursementAmt += InsertSalesInvLine(SalesHeader,NpRiReimbursementEntryApply,NpRiSalesInvSetupLine);
        until NpRiSalesInvSetupLine.Next = 0;

        NpRiReimbursementEntryApply."Reimbursement Amount" := ReimbursementAmt;
        NpRiReimbursementEntryApply.Modify;

        Commit;

        if PostImmediately then
          PostSalesInv(NpRiReimbursementEntryApply);
    end;

    local procedure RunSalesInvReimbursementDocuments(var NpRiReimbursement: Record "NpRi Reimbursement";var NpRiReimbursementEntryApply: Record "NpRi Reimbursement Entry")
    var
        Cust: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        NpRiReimbursementEntry: Record "NpRi Reimbursement Entry";
        NpRiReimbursementEntryApply2: Record "NpRi Reimbursement Entry";
        TempNpRiReimbursementEntry: Record "NpRi Reimbursement Entry" temporary;
        ErrorText: Text;
        LastErrorText: Text;
        PostImmediately: Boolean;
    begin
        FindCust(NpRiReimbursement,Cust,PostImmediately);
        NpRiReimbursementEntry.SetRange("Closed by Entry No.",NpRiReimbursementEntryApply."Entry No.");
        if not NpRiReimbursementEntry.FindSet then
          exit;

        repeat
          RunSalesInvReimbursementDocument(Cust,NpRiReimbursement,NpRiReimbursementEntry,NpRiReimbursementEntryApply2);

          TempNpRiReimbursementEntry.Init;
          TempNpRiReimbursementEntry := NpRiReimbursementEntryApply2;
          TempNpRiReimbursementEntry.Insert;
        until NpRiReimbursementEntry.Next = 0;

        NpRiReimbursementEntryApply.Delete(true);
        Commit;

        if TempNpRiReimbursementEntry.FindSet then
          repeat
            asserterror begin
              NpRiReimbursementEntryApply.Get(TempNpRiReimbursementEntry."Entry No.");
              if PostImmediately then
                PostSalesInv(NpRiReimbursementEntryApply);

              Commit;
              Error('');
            end;

            LastErrorText := GetLastErrorText;
            if LastErrorText <> '' then
              ErrorText += LastErrorText + NewLine();
          until TempNpRiReimbursementEntry.Next = 0;

        if ErrorText <> '' then
          Error(ErrorText);
    end;

    local procedure RunSalesInvReimbursementDocument(Cust: Record Customer;NpRiReimbursement: Record "NpRi Reimbursement";var NpRiReimbursementEntry: Record "NpRi Reimbursement Entry";var NpRiReimbursementEntryApply: Record "NpRi Reimbursement Entry")
    var
        NpRiSalesInvSetupLine: Record "NpRi Sales Inv. Setup Line";
        SalesHeader: Record "Sales Header";
        ReimbursementAmt: Decimal;
    begin
        ReapplyEntry(NpRiReimbursement,NpRiReimbursementEntry,NpRiReimbursementEntryApply);

        InsertSalesInvHeader(Cust,NpRiReimbursement,NpRiReimbursementEntryApply,SalesHeader);

        NpRiSalesInvSetupLine.SetRange("Template Code",NpRiReimbursement."Template Code");
        NpRiSalesInvSetupLine.FindSet;
        repeat
          ReimbursementAmt += InsertSalesInvLine(SalesHeader,NpRiReimbursementEntryApply,NpRiSalesInvSetupLine);
        until NpRiSalesInvSetupLine.Next = 0;

        NpRiReimbursementEntryApply."Reimbursement Amount" := ReimbursementAmt;
        NpRiReimbursementEntryApply.Modify;
    end;

    local procedure PostSalesInv(var NpRiReimbursementEntryApply: Record "NpRi Reimbursement Entry")
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetPosition(NpRiReimbursementEntryApply."Source Record Position");
        SalesHeader.Find;
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        CODEUNIT.Run(CODEUNIT::"Sales-Post",SalesHeader);

        if NpRiReimbursementEntryApply.Find then;
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterPostSalesDoc', '', true, true)]
    local procedure OnAfterPostSalesInv(var SalesHeader: Record "Sales Header";var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";SalesShptHdrNo: Code[20];RetRcpHdrNo: Code[20];SalesInvHdrNo: Code[20];SalesCrMemoHdrNo: Code[20])
    var
        NpRiReimbursementTemplate: Record "NpRi Reimbursement Template";
        NpRiReimbursementEntry: Record "NpRi Reimbursement Entry";
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        if SalesInvHdrNo = '' then
          exit;

        NpRiReimbursementTemplate.SetRange("Reimbursement Module",ModuleCode());
        if NpRiReimbursementTemplate.IsEmpty then
          exit;

        if not SalesInvHeader.Get(SalesInvHdrNo) then
          exit;

        asserterror begin
          NpRiReimbursementTemplate.FindSet;
          repeat
            NpRiReimbursementEntry.SetRange("Template Code",NpRiReimbursementTemplate.Code);
            NpRiReimbursementEntry.SetRange("Entry Type",NpRiReimbursementEntry."Entry Type"::Reimbursement);
            NpRiReimbursementEntry.SetRange("Source Table No.",DATABASE::"Sales Header");
            NpRiReimbursementEntry.SetRange("Source Record Position",SalesHeader.GetPosition(false));
            if NpRiReimbursementEntry.FindSet then
              repeat
                NpRiReimbursementEntry.Description := SalesInvHeader."Posting Description";
                NpRiReimbursementEntry."Source Record ID" := SalesInvHeader.RecordId;
                NpRiReimbursementEntry."Source Table No." := DATABASE::"Sales Invoice Header";
                NpRiReimbursementEntry."Source Record Position" := SalesInvHeader.GetPosition(false);
                NpRiReimbursementEntry."Document Type" := NpRiReimbursementEntry."Document Type"::Invoice;
                NpRiReimbursementEntry."Document No." := SalesInvHeader."No.";
                NpRiReimbursementEntry."Account Type" := NpRiReimbursementEntry."Account Type"::Customer;
                NpRiReimbursementEntry."Account No." := SalesInvHeader."Bill-to Customer No.";
                NpRiReimbursementEntry.Modify;
              until NpRiReimbursementEntry.Next = 0;
          until NpRiReimbursementTemplate.Next = 0;

          Commit;
          Error('');
        end;
    end;

    local procedure ReapplyEntry(NpRiReimbursement: Record "NpRi Reimbursement";var NpRiReimbursementEntry: Record "NpRi Reimbursement Entry";var NpRiReimbursementEntryApply: Record "NpRi Reimbursement Entry")
    var
        NpRiSalesInvSetup: Record "NpRi Sales Inv. Setup";
    begin
        NpRiSalesInvSetup.Get(NpRiReimbursement."Template Code");

        NpRiReimbursementEntryApply.Init;
        NpRiReimbursementEntryApply."Entry No." := 0;
        case NpRiSalesInvSetup."Invoice Posting Date" of
          NpRiSalesInvSetup."Invoice Posting Date"::Reimbursement:
            begin
              NpRiReimbursementEntryApply."Posting Date" := NpRiReimbursement."Posting Date";
            end;
          NpRiSalesInvSetup."Invoice Posting Date"::Document:
            begin
              NpRiReimbursementEntryApply."Posting Date" := NpRiReimbursementEntry."Posting Date";
            end;
        end;
        NpRiReimbursementEntryApply."Entry Type" := NpRiReimbursementEntryApply."Entry Type"::Reimbursement;
        NpRiReimbursementEntryApply."Party Type" := NpRiReimbursementEntry."Party Type";
        NpRiReimbursementEntryApply."Party No." := NpRiReimbursementEntry."Party No.";
        NpRiReimbursementEntryApply."Template Code" := NpRiReimbursementEntry."Template Code";
        NpRiReimbursementEntryApply.Description := NpRiReimbursementEntry.Description;
        NpRiReimbursementEntryApply.Amount := -NpRiReimbursementEntry.Amount;
        NpRiReimbursementEntryApply.Positive := NpRiReimbursementEntry.Amount > 0;
        NpRiReimbursementEntryApply.Open := false;
        NpRiReimbursementEntryApply."Remaining Amount" := 0;
        NpRiReimbursementEntryApply."Closed by Entry No." := NpRiReimbursementEntry."Entry No.";
        NpRiReimbursementEntry."Source Company Name" := CompanyName;
        NpRiReimbursementEntryApply.Insert(true);

        NpRiReimbursementEntry.Open := false;
        NpRiReimbursementEntry."Remaining Amount" := 0;
        NpRiReimbursementEntry."Closed by Entry No." := NpRiReimbursementEntryApply."Entry No.";
        NpRiReimbursementEntry.Modify;
    end;

    local procedure InsertSalesInvHeader(Cust: Record Customer;NpRiReimbursement: Record "NpRi Reimbursement";var NpRiReimbursementEntry: Record "NpRi Reimbursement Entry";var SalesHeader: Record "Sales Header")
    var
        NpRiSalesInvSetup: Record "NpRi Sales Inv. Setup";
    begin
        NpRiSalesInvSetup.Get(NpRiReimbursement."Template Code");

        SalesHeader.Init;
        SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
        SalesHeader."No." := '';
        SalesHeader.Insert(true);

        SalesHeader.Validate("Sell-to Customer No.",Cust."No.");
        SalesHeader.Validate("Posting Date",NpRiReimbursementEntry."Posting Date");
        SalesHeader.Validate("Salesperson Code",NpRiSalesInvSetup."Salesperson Code");
        SalesHeader.Modify(true);

        NpRiReimbursementEntry."Source Record ID" := SalesHeader.RecordId;
        NpRiReimbursementEntry."Source Table No." := DATABASE::"Sales Header";
        NpRiReimbursementEntry."Source Record Position" := SalesHeader.GetPosition(false);
        NpRiReimbursementEntry."Document Type" := NpRiReimbursementEntry."Document Type"::Invoice;
        NpRiReimbursementEntry."Document No." := SalesHeader."No.";
        NpRiReimbursementEntry."Account Type" := NpRiReimbursementEntry."Account Type"::Customer;
        NpRiReimbursementEntry."Account No." := SalesHeader."Bill-to Customer No.";
        NpRiReimbursementEntry.Modify;
    end;

    local procedure InsertSalesInvLine(SalesHeader: Record "Sales Header";NpRiReimbursementEntry: Record "NpRi Reimbursement Entry";NpRiSalesInvSetupLine: Record "NpRi Sales Inv. Setup Line") LineAmt: Decimal
    var
        GLSetup: Record "General Ledger Setup";
        SalesLine: Record "Sales Line";
    begin
        GLSetup.Get;
        LineAmt := Abs(Round(NpRiReimbursementEntry.Amount * NpRiSalesInvSetupLine."Invoice %" / 100,GLSetup."Amount Rounding Precision"));
        if NpRiSalesInvSetupLine.Quantity < 0 then
          LineAmt := -LineAmt;

        SalesLine.Init;
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := NpRiSalesInvSetupLine."Line No.";
        SalesLine.Validate(Type,NpRiSalesInvSetupLine.Type);
        SalesLine.Validate("No.",NpRiSalesInvSetupLine."No.");
        SalesLine.Description := CopyStr(StrSubstNo(NpRiSalesInvSetupLine.Description,NpRiReimbursementEntry.Description),1,MaxStrLen(SalesLine.Description));
        SalesLine.Validate(Quantity,NpRiSalesInvSetupLine.Quantity);
        if SalesLine.Quantity <> 0 then begin
          SalesLine.Validate("Unit Price",Round(LineAmt / SalesLine.Quantity,GLSetup."Unit-Amount Rounding Precision"));
          SalesLine.Validate("Line Discount %",0);
        end;
        SalesLine.Insert(true);
    end;

    local procedure FindCust(NpRiReimbursement: Record "NpRi Reimbursement";var Cust: Record Customer;var PostImmediately: Boolean)
    var
        NpRiPartyType: Record "NpRi Party Type";
        NpRiSalesInvSetup: Record "NpRi Sales Inv. Setup";
    begin
        NpRiPartyType.Get(NpRiReimbursement."Party Type");
        if NpRiPartyType."Table No." = DATABASE::Customer then begin
          Cust.Get(NpRiReimbursement."Party No.");
          exit;
        end;

        NpRiSalesInvSetup.Get(NpRiReimbursement."Template Code");
        NpRiSalesInvSetup.TestField("Customer No.");
        Cust.Get(NpRiSalesInvSetup."Customer No.");
    end;

    local procedure CreateGenJnl(NpRiReimbursement: Record "NpRi Reimbursement";Vendor: Record Vendor;var NpRiReimbursementEntryApply: Record "NpRi Reimbursement Entry";var TempGenJnlLine: Record "Gen. Journal Line" temporary)
    var
        NpRiPurchDocDiscSetup: Record "NpRi Purch. Doc. Disc. Setup";
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
        TempGenJnlLine.Validate("Account No.",Vendor."No.");
        TempGenJnlLine."Document Type" := TempGenJnlLine."Document Type"::" ";
        TempGenJnlLine."External Document No." := NpRiReimbursement."Template Code";
        TempGenJnlLine."Bal. Account Type" := TempGenJnlLine."Bal. Account Type"::"G/L Account";
        TempGenJnlLine."Bal. Account No." := NpRiPurchDocDiscSetup."Bal. Account No.";
        TempGenJnlLine.Validate("Bal. Account No.");
        if NpRiPurchDocDiscSetup."Bal. Gen. Prod. Posting Group" <> '' then
          TempGenJnlLine.Validate("Bal. Gen. Prod. Posting Group",NpRiPurchDocDiscSetup."Bal. Gen. Prod. Posting Group");
        if NpRiPurchDocDiscSetup."Bal. VAT Prod. Posting Group" <> '' then
          TempGenJnlLine.Validate("Bal. VAT Prod. Posting Group",NpRiPurchDocDiscSetup."Bal. VAT Prod. Posting Group");

        TempGenJnlLine.Correction := false;
        TempGenJnlLine."Currency Factor" := 1;

        TempGenJnlLine."Applies-to Doc. No." := '';
        TempGenJnlLine."Applies-to ID" := TempGenJnlLine."Document No.";
        TempGenJnlLine."Allow Zero-Amount Posting" := true;
        TempGenJnlLine.Insert;
    end;

    local procedure SetVendLedgEntryAppIds(NpRiReimbursement: Record "NpRi Reimbursement";var NpRiReimbursementEntryApply: Record "NpRi Reimbursement Entry";var TempGenJnlLine: Record "Gen. Journal Line" temporary) ReimbursementAmount: Decimal
    var
        NpRiPurchDocDiscSetup: Record "NpRi Purch. Doc. Disc. Setup";
        NpRiReimbursementEntry: Record "NpRi Reimbursement Entry";
    begin
        NpRiPurchDocDiscSetup.Get(NpRiReimbursement."Template Code");

        NpRiReimbursementEntry.Reset;
        NpRiReimbursementEntry.SetRange("Closed by Entry No.",NpRiReimbursementEntryApply."Entry No.");
        if NpRiReimbursementEntry.FindSet then
          repeat
            ReimbursementAmount += SetVendLedgEntryAppId(NpRiPurchDocDiscSetup,TempGenJnlLine,NpRiReimbursementEntry);
          until NpRiReimbursementEntry.Next = 0;

        exit(ReimbursementAmount);
    end;

    local procedure SetVendLedgEntryAppId(NpRiPurchDocDiscSetup: Record "NpRi Purch. Doc. Disc. Setup";var TempGenJnlLine: Record "Gen. Journal Line" temporary;var NpRiReimbursementEntry: Record "NpRi Reimbursement Entry") ReimbursementAmount: Decimal
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
        VendEntrySetApplID: Codeunit "Vend. Entry-SetAppl.ID";
        AmountToApply: Decimal;
    begin
        VendLedgEntry.Get(NpRiReimbursementEntry."Source Entry No.");
        if not VendLedgEntry.Open then
          exit;
        if not (VendLedgEntry."Document Type" in [VendLedgEntry."Document Type"::"Credit Memo",VendLedgEntry."Document Type"::Invoice]) then
          exit;

        AmountToApply := Round(VendLedgEntry."Purchase (LCY)" * NpRiPurchDocDiscSetup."Discount %" / 100,GeneralLedgerSetup."Amount Rounding Precision");
        if AmountToApply = 0 then
          exit;

        VendLedgEntry."Applies-to ID" := TempGenJnlLine."Document No.";
        VendLedgEntry."Amount to Apply" := AmountToApply;
        VendLedgEntry.Modify;

        NpRiReimbursementEntry."Reimbursement Amount" := VendLedgEntry."Amount to Apply";
        NpRiReimbursementEntry.Modify;

        exit(NpRiReimbursementEntry."Reimbursement Amount");
    end;

    local procedure PostPurchDocDisc(ReimbursementAmount: Decimal;var NpRiReimbursementEntryApply: Record "NpRi Reimbursement Entry";var TempGenJnlLine: Record "Gen. Journal Line" temporary)
    var
        GLEntry: Record "G/L Entry";
        TempGenJnlLine2: Record "Gen. Journal Line" temporary;
        VendLedgEntry: Record "Vendor Ledger Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        TempGenJnlLine2 := TempGenJnlLine;

        LockGLEntry(GLEntry);
        UpdateApplicationEntry(GLEntry,TempGenJnlLine,ReimbursementAmount,NpRiReimbursementEntryApply);
        GenJnlPostLine.RunWithCheck(TempGenJnlLine);

        VendLedgEntry.SetRange("Posting Date",TempGenJnlLine2."Posting Date");
        VendLedgEntry.SetRange("Document No.",TempGenJnlLine2."Document No.");
        VendLedgEntry.FindLast;
        UpdateApplicationEntry2(VendLedgEntry,NpRiReimbursementEntryApply);
    end;

    local procedure LockGLEntry(var GLEntry: Record "G/L Entry")
    begin
        Clear(GLEntry);
        GLEntry.LockTable;
        if GLEntry.FindLast then;
        GLEntry."Entry No." += 1;
    end;

    local procedure UpdateApplicationEntry(GLEntry: Record "G/L Entry";TempGenJnlLine: Record "Gen. Journal Line" temporary;ReimbursementAmount: Decimal;var NpRiReimbursementEntryApply: Record "NpRi Reimbursement Entry")
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

    local procedure UpdateApplicationEntry2(VendLedgEntry: Record "Vendor Ledger Entry";var NpRiReimbursementEntryApply: Record "NpRi Reimbursement Entry")
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
        exit(CODEUNIT::"NpRi Reim. Purch. Doc. Disc.");
    end;

    local procedure NewLine() CRLF: Text
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        exit(CRLF);
    end;
}

