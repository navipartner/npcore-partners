codeunit 6151010 "NPR NpRv Voucher Mgt."
{
    TableNo = "NPR NpRv Voucher";

    trigger OnRun()
    begin
        SendSingleVoucher(Rec);
    end;

    var
        Text000: Label 'Invalid EAN13: %1.';
        Text001: Label 'Invalid Reference No.';
        Text002: Label 'Retail Voucher Payment Amount %1 is higher than Remaining Amount %2 on Retail Voucher %3';
        Text003: Label 'Retail Voucher Payment Amount %1 must not be less than 0';

    procedure ResetInUseQty(Voucher: Record "NPR NpRv Voucher")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        NpRvSalesLine.SetRange("Voucher No.", Voucher."No.");
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::Payment);
        if NpRvSalesLine.FindFirst then
            NpRvSalesLine.DeleteAll;
    end;

    local procedure "--- POS Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6014406, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeletePOSSaleLine(var Rec: Record "NPR Sale Line POS"; RunTrigger: Boolean)
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        if Rec.IsTemporary then
            exit;

        SetSalesLineFilter(Rec, NpRvSalesLine);
        if NpRvSalesLine.IsEmpty then
            exit;

        NpRvSalesLine.DeleteAll;
    end;

    [EventSubscriber(ObjectType::Table, 6151015, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeleteNpRvSalesLine(var Rec: Record "NPR NpRv Sales Line"; RunTrigger: Boolean)
    var
        NpRvSalesLineReference: Record "NPR NpRv Sales Line Ref.";
    begin
        if Rec.IsTemporary then
            exit;

        SetSalesLineReferenceFilter(Rec, NpRvSalesLineReference);
        if NpRvSalesLineReference.IsEmpty then
            exit;

        NpRvSalesLineReference.DeleteAll;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014435, 'OnBeforeAuditRoleLineInsertEvent', '', true, true)]
    local procedure OnBeforeAuditRollInsert(var SaleLinePos: Record "NPR Sale Line POS")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        SetSalesLineFilter(SaleLinePos, NpRvSalesLine);
        if NpRvSalesLine.IsEmpty then
            exit;

        NpRvSalesLine.SetFilter(Type, '%1|%2|%3', NpRvSalesLine.Type::"New Voucher", NpRvSalesLine.Type::"Top-up", NpRvSalesLine.Type::"Partner Issue Voucher");
        if NpRvSalesLine.FindSet then
            repeat
                IssueVouchers(NpRvSalesLine);
            until NpRvSalesLine.Next = 0;

        SetSalesLineFilter(SaleLinePos, NpRvSalesLine);
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::Payment);
        if NpRvSalesLine.FindSet then
            repeat
                PostPayment(NpRvSalesLine);
            until NpRvSalesLine.Next = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150705, 'OnAfterEndSale', '', true, true)]
    local procedure OnAfterEndSale(var Sender: Codeunit "NPR POS Sale"; SalePOS: Record "NPR Sale POS")
    var
        Voucher: Record "NPR NpRv Voucher";
        VoucherType: Record "NPR NpRv Voucher Type";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
    begin
        VoucherEntry.SetFilter("Entry Type", '%1|%2|%3', VoucherEntry."Entry Type"::"Issue Voucher", VoucherEntry."Entry Type"::Payment, VoucherEntry."Entry Type"::"Top-up");
        VoucherEntry.SetRange("Register No.", SalePOS."Register No.");
        VoucherEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        if VoucherEntry.IsEmpty then
            exit;

        VoucherEntry.FindSet;
        repeat
            if Voucher.Get(VoucherEntry."Voucher No.") then
                SendSingleVoucher(Voucher);
        until VoucherEntry.Next = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014407, 'OnAfterDebitSalePostEvent', '', true, true)]
    local procedure OnAfterDebitSalePostEvent(var Sender: Codeunit "NPR Sales Doc. Exp. Mgt."; SalePOS: Record "NPR Sale POS"; SalesHeader: Record "Sales Header"; Posted: Boolean; WriteInAuditRoll: Boolean)
    var
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
    begin
        VoucherEntry.SetFilter("Entry Type", '%1|%2|%3', VoucherEntry."Entry Type"::"Issue Voucher", VoucherEntry."Entry Type"::Payment, VoucherEntry."Entry Type"::"Top-up");
        VoucherEntry.SetRange("Register No.", SalePOS."Register No.");
        VoucherEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        if VoucherEntry.IsEmpty then
            exit;

        VoucherEntry.FindSet;
        repeat
            if Voucher.Get(VoucherEntry."Voucher No.") then
                SendSingleVoucher(Voucher);
        until VoucherEntry.Next = 0;
    end;

    local procedure "--- Issue Voucher"()
    begin
    end;

    procedure IssueVouchers(var NpRvSalesLine: Record "NPR NpRv Sales Line")
    var
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SaleLinePOS: Record "NPR Sale Line POS";
        NpRvSalesLineReference: Record "NPR NpRv Sales Line Ref.";
        VoucherType: Record "NPR NpRv Voucher Type";
        i: Integer;
        VoucherAmount: Decimal;
        VoucherQty: Decimal;
    begin
        if not (NpRvSalesLine.Type in [NpRvSalesLine.Type::"New Voucher", NpRvSalesLine.Type::"Top-up", NpRvSalesLine.Type::"Partner Issue Voucher"]) then
            exit;

        VoucherType.Get(NpRvSalesLine."Voucher Type");
        case NpRvSalesLine."Document Source" of
            NpRvSalesLine."Document Source"::POS:
                begin
                    SaleLinePOS.SetRange("Retail ID", NpRvSalesLine."Retail ID");
                    if not SaleLinePOS.FindFirst then
                        exit;

                    if SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::Payment then begin
                        SaleLinePOS."Unit Price" := Abs(SaleLinePOS."Amount Including VAT");
                        SaleLinePOS.Quantity := 1;
                    end;

                    VoucherQty := SaleLinePOS.Quantity;
                    VoucherAmount := SaleLinePOS."Unit Price";
                    if not SaleLinePOS."Price Includes VAT" then
                        VoucherAmount *= 1 + SaleLinePOS."VAT %" / 100;
                end;
            NpRvSalesLine."Document Source"::"Sales Document":
                begin
                    if not SalesLine.Get(NpRvSalesLine."Document Type", NpRvSalesLine."Document No.", NpRvSalesLine."Document Line No.") then
                        exit;

                    VoucherQty := SalesLine."Qty. to Invoice";
                    VoucherAmount := SalesLine."Unit Price";
                    if SalesHeader.Get(SalesHeader."Document Type", SalesLine."Document No.") and not SalesHeader."Prices Including VAT" then
                        VoucherAmount *= 1 + SalesLine."VAT %" / 100;
                end;
            NpRvSalesLine."Document Source"::"Payment Line":
                begin
                    if not MagentoPaymentLine.Get(DATABASE::"Sales Invoice Header", 0, NpRvSalesLine."Posting No.", NpRvSalesLine."Document Line No.") then begin
                        if not MagentoPaymentLine.Get(DATABASE::"Sales Header", NpRvSalesLine."Document Type", NpRvSalesLine."Document No.", NpRvSalesLine."Document Line No.") then
                            exit;
                    end;
                    if MagentoPaymentLine.Amount >= 0 then
                        exit;

                    VoucherQty := 1;
                    VoucherAmount := -MagentoPaymentLine.Amount;
                end;
        end;

        if VoucherAmount <= 0 then
            exit;
        if VoucherQty <= 0 then
            exit;

        for i := 1 to VoucherQty do begin
            Clear(NpRvSalesLineReference);
            NpRvSalesLineReference.SetRange("Sales Line Id", NpRvSalesLine.Id);
            if NpRvSalesLineReference.FindFirst then;

            IssueVoucher(VoucherType, VoucherAmount, NpRvSalesLine, NpRvSalesLineReference);
        end;
    end;

    local procedure IssueVoucher(VoucherType: Record "NPR NpRv Voucher Type"; VoucherAmount: Decimal; var NpRvSalesLine: Record "NPR NpRv Sales Line"; var NpRvSalesLineReference: Record "NPR NpRv Sales Line Ref.")
    var
        NpRvSalesLine2: Record "NPR NpRv Sales Line";
        Voucher: Record "NPR NpRv Voucher";
        PrevVoucher: Text;
        NpRvSalesLineReferencePrev: Record "NPR NpRv Sales Line Ref.";
    begin
        if VoucherAmount <= 0 then
            exit;

        case NpRvSalesLine.Type of
            NpRvSalesLine.Type::"New Voucher":
                begin
                    if NpRvSalesLineReference."Reference No." = '' then
                        VoucherType.TestField("Reference No. Pattern");

                    Voucher.Init;
                    if NpRvSalesLine."Starting Date" > CurrentDateTime then
                        Voucher."Starting Date" := NpRvSalesLine."Starting Date";
                    Voucher.Validate("Voucher Type", VoucherType.Code);
                    Voucher."No." := NpRvSalesLineReference."Voucher No.";
                    Voucher."Reference No." := NpRvSalesLineReference."Reference No.";
                    OnBeforeInsertIssuedVoucher(Voucher, NpRvSalesLine);
                    Voucher.Insert(true);

                    PrevVoucher := Format(Voucher);
                    Voucher.Description := CopyStr(VoucherType.Description + ' ' + Voucher."No.", 1, MaxStrLen(Voucher.Description));
                    Voucher."Customer No." := NpRvSalesLine."Customer No.";
                    Voucher."Contact No." := NpRvSalesLine."Contact No.";
                    Voucher.Name := NpRvSalesLine.Name;
                    Voucher."Name 2" := NpRvSalesLine."Name 2";
                    Voucher.Address := NpRvSalesLine.Address;
                    Voucher."Address 2" := NpRvSalesLine."Address 2";
                    Voucher."Post Code" := NpRvSalesLine."Post Code";
                    Voucher.City := NpRvSalesLine.City;
                    Voucher.County := NpRvSalesLine.County;
                    Voucher."Country/Region Code" := NpRvSalesLine."Country/Region Code";
                    Voucher."E-mail" := NpRvSalesLine."E-mail";
                    Voucher."Phone No." := NpRvSalesLine."Phone No.";
                    Voucher."Send via Print" := NpRvSalesLine."Send via Print";
                    Voucher."Send via E-mail" := NpRvSalesLine."Send via E-mail";
                    Voucher."Send via SMS" := NpRvSalesLine."Send via SMS";
                    Voucher."Voucher Message" := NpRvSalesLine."Voucher Message";
                    if PrevVoucher <> Format(Voucher) then
                        Voucher.Modify(true);
                end;
            NpRvSalesLine.Type::"Top-up":
                begin
                    Voucher.Get(NpRvSalesLine."Voucher No.");
                end;
        end;

        if NpRvSalesLineReference.Find then begin
            NpRvSalesLineReferencePrev := NpRvSalesLineReference;
            NpRvSalesLineReference.Delete;
            NpRvSalesLineReference := NpRvSalesLineReferencePrev;
        end;

        PostIssueVoucher(Voucher, VoucherAmount, NpRvSalesLine);

        if NpRvSalesLine2.Get(NpRvSalesLine.Id) and not NpRvSalesLine2.Posted then begin
            NpRvSalesLine2.Posted := true;
            NpRvSalesLine2.Modify;
        end;
    end;

    procedure InitialEntryExists(Voucher: Record "NPR NpRv Voucher"): Boolean
    var
        VoucherEntry: Record "NPR NpRv Voucher Entry";
    begin
        VoucherEntry.SetRange("Voucher No.", Voucher."No.");
        VoucherEntry.SetRange("Entry Type", VoucherEntry."Entry Type"::"Issue Voucher");
        exit(VoucherEntry.FindFirst);
    end;

    local procedure PostIssueVoucher(Voucher: Record "NPR NpRv Voucher"; VoucherAmount: Decimal; var NpRvSalesLine: Record "NPR NpRv Sales Line")
    var
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        VoucherType: Record "NPR NpRv Voucher Type";
    begin
        VoucherType.Get(Voucher."Voucher Type");

        VoucherEntry.Init;
        VoucherEntry."Entry No." := 0;
        VoucherEntry."Voucher No." := Voucher."No.";
        case NpRvSalesLine.Type of
            NpRvSalesLine.Type::"New Voucher":
                begin
                    if InitialEntryExists(Voucher) then
                        exit;

                    VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Issue Voucher";
                end;
            NpRvSalesLine.Type::"Top-up":
                begin
                    VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Top-up";
                end;
            NpRvSalesLine.Type::"Partner Issue Voucher":
                begin
                    if InitialEntryExists(Voucher) then
                        exit;

                    VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Partner Issue Voucher";
                end;
        end;
        VoucherEntry."Voucher Type" := Voucher."Voucher Type";
        VoucherEntry.Amount := VoucherAmount;
        VoucherEntry."Remaining Amount" := VoucherEntry.Amount;
        VoucherEntry.Positive := VoucherEntry.Amount > 0;
        VoucherEntry."Posting Date" := DT2Date(Voucher."Starting Date");
        VoucherEntry.Open := VoucherEntry.Amount <> 0;
        VoucherEntry."Register No." := NpRvSalesLine."Register No.";
        case NpRvSalesLine."Document Source" of
            NpRvSalesLine."Document Source"::POS:
                begin
                    VoucherEntry."Document Type" := VoucherEntry."Document Type"::"POS Entry";
                    VoucherEntry."Document No." := NpRvSalesLine."Sales Ticket No.";
                end;
            NpRvSalesLine."Document Source"::"Sales Document":
                begin
                    VoucherEntry."Document Type" := VoucherEntry."Document Type"::Invoice;
                    VoucherEntry."Document No." := NpRvSalesLine."Posting No.";
                    VoucherEntry."External Document No." := NpRvSalesLine."External Document No.";
                end;
            NpRvSalesLine."Document Source"::"Payment Line":
                begin
                    VoucherEntry."Document Type" := VoucherEntry."Document Type"::Invoice;
                    VoucherEntry."Document No." := NpRvSalesLine."Posting No.";
                    VoucherEntry."External Document No." := NpRvSalesLine."External Document No.";
                end;
        end;
        VoucherEntry."Partner Code" := VoucherType."Partner Code";
        VoucherEntry."User ID" := UserId;
        VoucherEntry."Closed by Entry No." := 0;
        OnBeforeInsertIssuedVoucherEntry(VoucherEntry, Voucher, NpRvSalesLine);
        VoucherEntry.Insert;
    end;

    [Obsolete('Replaced with Codeunit.run(Codeunit::"NPR NpRv Voucher Mgt."...)')]
    procedure SendVoucher(Voucher: Record "NPR NpRv Voucher")
    begin
        SendSingleVoucher(Voucher);
    end;

    local procedure SendSingleVoucher(Voucher: Record "NPR NpRv Voucher")
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        NpRvModuleMgt: Codeunit "NPR NpRv Module Mgt.";
        NpRvModuleSendDefault: Codeunit "NPR NpRv Module Send: Def.";
        Handled: Boolean;
    begin
        if not VoucherType.Get(Voucher."Voucher Type") then
            exit;

        Voucher.CalcFields(Amount);
        if Voucher.Amount <= 0 then
            exit;

        Voucher.CalcFields("Send Voucher Module");
        NpRvModuleMgt.OnRunSendVoucher(Voucher, VoucherType, Handled);

        if not Handled then
            NpRvModuleSendDefault.SendVoucher(Voucher);
    end;

    procedure LogSending(NpRvVoucher: Record "NPR NpRv Voucher"; SendingType: Integer; LogMessage: Text; SentTo: Text; ErrorMessage: Text)
    var
        NpRvSendingLog: Record "NPR NpRv Sending Log";
        OutStr: OutStream;
    begin
        NpRvVoucher.CalcFields(Amount);

        NpRvSendingLog.Init;
        NpRvSendingLog."Entry No." := 0;
        NpRvSendingLog."Voucher No." := NpRvVoucher."No.";
        NpRvSendingLog."Log Date" := CurrentDateTime;
        if SendingType > 0 then
            NpRvSendingLog."Sending Type" := SendingType;
        NpRvSendingLog."Log Message" := CopyStr(LogMessage, 1, MaxStrLen(NpRvSendingLog."Log Message"));
        NpRvSendingLog."Sent to" := CopyStr(SentTo, 1, MaxStrLen(NpRvSendingLog."Sent to"));
        NpRvSendingLog.Amount := NpRvVoucher.Amount;
        NpRvSendingLog."User ID" := UserId;
        NpRvSendingLog."Error during Send" := ErrorMessage <> '';
        if ErrorMessage <> '' then begin
            NpRvSendingLog."Error Message".CreateOutStream(OutStr, TEXTENCODING::UTF8);
            OutStr.WriteText(ErrorMessage);
        end;
        NpRvSendingLog.Insert(true);
    end;

    local procedure "--- Voucher Payment"()
    begin
    end;

    procedure ApplyPayment(FrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session"; NpRvSalesLine: Record "NPR NpRv Sales Line")
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        NpRvModuleMgt: Codeunit "NPR NpRv Module Mgt.";
        NpRvModulePaymentDefault: Codeunit "NPR NpRv Module Pay.: Default";
        Handled: Boolean;
    begin
        VoucherType.Get(NpRvSalesLine."Voucher Type");
        NpRvModuleMgt.OnRunApplyPayment(FrontEnd, POSSession, VoucherType, NpRvSalesLine, Handled);
        if Handled then
            exit;

        NpRvModulePaymentDefault.ApplyPayment(FrontEnd, POSSession, VoucherType, NpRvSalesLine);
    end;

    procedure PostPayment(var NpRvSalesLine: Record "NPR NpRv Sales Line")
    var
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        NpRvSalesLine2: Record "NPR NpRv Sales Line";
        SaleLinePOS: Record "NPR Sale Line POS";
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        i: Integer;
    begin
        case NpRvSalesLine."Document Source" of
            NpRvSalesLine."Document Source"::POS:
                begin
                    SaleLinePOS.SetRange("Retail ID", NpRvSalesLine."Retail ID");
                    if not SaleLinePOS.FindFirst then
                        exit;

                    if SaleLinePOS."Amount Including VAT" <= 0 then
                        exit;
                end;
            NpRvSalesLine."Document Source"::"Payment Line":
                begin
                    if not MagentoPaymentLine.Get(DATABASE::"Sales Invoice Header", 0, NpRvSalesLine."Posting No.", NpRvSalesLine."Document Line No.") then begin
                        if not MagentoPaymentLine.Get(DATABASE::"Sales Header", NpRvSalesLine."Document Type", NpRvSalesLine."Document No.", NpRvSalesLine."Document Line No.") then
                            exit;
                    end;

                    if MagentoPaymentLine.Amount <= 0 then
                        exit;
                end;
            else
                exit;
        end;

        Voucher.Get(NpRvSalesLine."Voucher No.");

        VoucherEntry.Init;
        VoucherEntry."Entry No." := 0;
        VoucherEntry."Voucher No." := Voucher."No.";
        VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::Payment;
        VoucherEntry."Voucher Type" := Voucher."Voucher Type";
        case NpRvSalesLine."Document Source" of
            NpRvSalesLine."Document Source"::POS:
                begin
                    VoucherEntry."Document Type" := VoucherEntry."Document Type"::"POS Entry";
                    VoucherEntry."Register No." := SaleLinePOS."Register No.";
                    VoucherEntry."Document No." := SaleLinePOS."Sales Ticket No.";
                    VoucherEntry."Posting Date" := SaleLinePOS.Date;
                    VoucherEntry.Amount := -SaleLinePOS."Amount Including VAT";
                end;
            NpRvSalesLine."Document Source"::"Payment Line":
                begin
                    VoucherEntry."Document Type" := VoucherEntry."Document Type"::Invoice;
                    VoucherEntry."Document No." := MagentoPaymentLine."Document No.";
                    VoucherEntry."Posting Date" := MagentoPaymentLine."Posting Date";
                    VoucherEntry.Amount := -MagentoPaymentLine.Amount;
                end;
        end;
        VoucherEntry."Remaining Amount" := VoucherEntry.Amount;
        VoucherEntry.Positive := VoucherEntry.Amount > 0;
        VoucherEntry.Open := VoucherEntry.Amount <> 0;
        VoucherEntry."User ID" := UserId;
        VoucherEntry."Closed by Entry No." := 0;
        if NpRvVoucherType.Get(Voucher."Voucher Type") then
            VoucherEntry."Partner Code" := NpRvVoucherType."Partner Code";
        OnBeforeInsertPaymentVoucherEntry(VoucherEntry, NpRvSalesLine);
        VoucherEntry.Insert;

        ApplyEntry(VoucherEntry);

        ArchiveClosedVoucher(Voucher);

        if NpRvSalesLine2.Get(NpRvSalesLine.Id) and not NpRvSalesLine2.Posted then begin
            NpRvSalesLine2.Posted := true;
            NpRvSalesLine2.Modify;
        end;
    end;

    procedure ApplyEntry(var VoucherEntry: Record "NPR NpRv Voucher Entry")
    var
        VoucherEntryApply: Record "NPR NpRv Voucher Entry";
    begin
        if VoucherEntry.IsTemporary then
            exit;
        if not VoucherEntry.Find then
            exit;
        if not VoucherEntry.Open then
            exit;

        VoucherEntryApply.SetRange("Voucher No.", VoucherEntry."Voucher No.");
        VoucherEntryApply.SetRange(Open, true);
        VoucherEntryApply.SetRange(Positive, not VoucherEntry.Positive);
        if not VoucherEntryApply.FindSet then
            exit;

        repeat
            if Abs(VoucherEntryApply."Remaining Amount") >= Abs(VoucherEntry."Remaining Amount") then begin
                VoucherEntryApply."Remaining Amount" += VoucherEntry."Remaining Amount";
                if VoucherEntryApply."Remaining Amount" = 0 then begin
                    VoucherEntryApply."Closed by Entry No." := VoucherEntry."Entry No.";
                    VoucherEntryApply."Closed by Partner Code" := VoucherEntry."Partner Code";
                    VoucherEntryApply.Open := false;
                end;

                VoucherEntry."Remaining Amount" := 0;
                VoucherEntry."Closed by Entry No." := VoucherEntryApply."Entry No.";
                VoucherEntry."Closed by Partner Code" := VoucherEntryApply."Partner Code";
                VoucherEntry.Open := false;
            end else begin
                VoucherEntry."Remaining Amount" += VoucherEntryApply."Remaining Amount";
                if VoucherEntry."Remaining Amount" = 0 then begin
                    VoucherEntry."Closed by Entry No." := VoucherEntryApply."Entry No.";
                    VoucherEntry."Closed by Partner Code" := VoucherEntryApply."Partner Code";
                    VoucherEntry.Open := false;
                end;

                VoucherEntryApply."Remaining Amount" := 0;
                VoucherEntryApply."Closed by Entry No." := VoucherEntry."Entry No.";
                VoucherEntryApply."Closed by Partner Code" := VoucherEntry."Partner Code";
                VoucherEntryApply.Open := false;
            end;

            VoucherEntry."Partner Clearing" := VoucherEntry."Partner Code" <> VoucherEntry."Closed by Partner Code";
            VoucherEntryApply."Partner Clearing" := VoucherEntryApply."Partner Code" <> VoucherEntryApply."Closed by Partner Code";
            VoucherEntry.Modify;
            VoucherEntryApply.Modify;
        until (VoucherEntryApply.Next = 0) or not VoucherEntry.Open;
    end;

    local procedure "--- Archive"()
    begin
    end;

    procedure ArchiveVouchers(var VoucherFilter: Record "NPR NpRv Voucher")
    var
        Voucher: Record "NPR NpRv Voucher";
    begin
        Voucher.Copy(VoucherFilter);
        if Voucher.GetFilters = '' then
            Voucher.SetRecFilter;

        if not Voucher.FindSet then
            exit;

        repeat
            ArchiveVoucher(Voucher);
        until Voucher.Next = 0;
    end;

    local procedure ArchiveVoucher(var Voucher: Record "NPR NpRv Voucher")
    var
        VoucherEntry: Record "NPR NpRv Voucher Entry";
    begin
        Voucher.CalcFields(Amount);
        if Voucher.Amount <> 0 then begin
            VoucherEntry.Init;
            VoucherEntry."Entry No." := 0;
            VoucherEntry."Voucher No." := Voucher."No.";
            VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Manual Archive";
            VoucherEntry."Voucher Type" := Voucher."Voucher Type";
            VoucherEntry.Amount := -Voucher.Amount;
            VoucherEntry."Remaining Amount" := VoucherEntry.Amount;
            VoucherEntry.Positive := VoucherEntry.Amount > 0;
            VoucherEntry."Posting Date" := Today;
            VoucherEntry.Open := true;
            VoucherEntry."Register No." := '';
            VoucherEntry."Document No." := '';
            VoucherEntry."User ID" := UserId;
            VoucherEntry."Closed by Entry No." := 0;
            VoucherEntry.Insert;

            ApplyEntry(VoucherEntry);
        end;

        ArchiveClosedVoucher(Voucher);
    end;

    procedure ArchiveClosedVoucher(var Voucher: Record "NPR NpRv Voucher")
    var
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        VoucherType: Record "NPR NpRv Voucher Type";
        NpRvSendingLog: Record "NPR NpRv Sending Log";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        if not Voucher.Find then
            exit;
        Voucher.CalcFields(Open);
        if Voucher.Open then
            exit;

        if Voucher."Allow Top-up" then
            exit;

        VoucherType.Get(Voucher."Voucher Type");
        VoucherType.TestField("Arch. No. Series");
        Voucher."Arch. No." := Voucher."No.";
        if Voucher."No. Series" <> VoucherType."Arch. No. Series" then
            Voucher."Arch. No." := NoSeriesMgt.GetNextNo(VoucherType."Arch. No. Series", Today, true);

        InsertArchivedVoucher(Voucher);
        VoucherEntry.SetRange("Voucher No.", Voucher."No.");
        if VoucherEntry.FindSet then begin
            repeat
                InsertArchivedVoucherEntry(Voucher, VoucherEntry);
            until VoucherEntry.Next = 0;
            VoucherEntry.DeleteAll;
        end;
        NpRvSendingLog.SetRange("Voucher No.", Voucher."No.");
        if NpRvSendingLog.FindSet then begin
            repeat
                InsertArchivedSendingLog(Voucher, NpRvSendingLog);
            until NpRvSendingLog.Next = 0;
            NpRvSendingLog.DeleteAll;
        end;
        Voucher.Delete;
    end;

    local procedure InsertArchivedVoucher(var Voucher: Record "NPR NpRv Voucher")
    var
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
    begin
        ArchVoucher.Init;
        ArchVoucher."No." := Voucher."Arch. No.";
        ArchVoucher."Voucher Type" := Voucher."Voucher Type";
        ArchVoucher.Description := Voucher.Description;
        ArchVoucher."Reference No." := Voucher."Reference No.";
        ArchVoucher."Starting Date" := Voucher."Starting Date";
        ArchVoucher."Ending Date" := Voucher."Ending Date";
        ArchVoucher."No. Series" := Voucher."No. Series";
        ArchVoucher."Arch. No. Series" := Voucher."Arch. No. Series";
        ArchVoucher."Arch. No." := Voucher."Arch. No.";
        ArchVoucher."Account No." := Voucher."Account No.";
        ArchVoucher."Provision Account No." := Voucher."Provision Account No.";
        ArchVoucher."Print Template Code" := Voucher."Print Template Code";
        ArchVoucher."Customer No." := Voucher."Customer No.";
        ArchVoucher."Contact No." := Voucher."Contact No.";
        ArchVoucher.Name := Voucher.Name;
        ArchVoucher."Name 2" := Voucher."Name 2";
        ArchVoucher.Address := Voucher.Address;
        ArchVoucher."Address 2" := Voucher."Address 2";
        ArchVoucher."Post Code" := Voucher."Post Code";
        ArchVoucher.City := Voucher.City;
        ArchVoucher.County := Voucher.County;
        ArchVoucher."Country/Region Code" := Voucher."Country/Region Code";
        ArchVoucher."E-mail" := Voucher."E-mail";
        ArchVoucher."Phone No." := Voucher."Phone No.";
        ArchVoucher."Voucher Message" := Voucher."Voucher Message";
        ArchVoucher."E-mail Template Code" := Voucher."E-mail Template Code";
        ArchVoucher."SMS Template Code" := Voucher."SMS Template Code";
        ArchVoucher."Send via Print" := Voucher."Send via Print";
        ArchVoucher."Send via E-mail" := Voucher."Send via E-mail";
        ArchVoucher."Send via SMS" := Voucher."Send via SMS";
        Voucher.CalcFields(Barcode);
        ArchVoucher.Barcode := Voucher.Barcode;
        ArchVoucher.Insert;
    end;

    local procedure InsertArchivedVoucherEntry(Voucher: Record "NPR NpRv Voucher"; VoucherEntry: Record "NPR NpRv Voucher Entry")
    var
        ArchVoucherEntry: Record "NPR NpRv Arch. Voucher Entry";
    begin
        ArchVoucherEntry.Init;
        ArchVoucherEntry."Entry No." := 0;
        ArchVoucherEntry."Original Entry No." := VoucherEntry."Entry No.";
        ArchVoucherEntry."Arch. Voucher No." := Voucher."Arch. No.";
        ArchVoucherEntry."Entry Type" := VoucherEntry."Entry Type";
        ArchVoucherEntry."Voucher Type" := VoucherEntry."Voucher Type";
        ArchVoucherEntry.Positive := VoucherEntry.Positive;
        ArchVoucherEntry.Amount := VoucherEntry.Amount;
        ArchVoucherEntry."Posting Date" := VoucherEntry."Posting Date";
        ArchVoucherEntry.Open := VoucherEntry.Open;
        ArchVoucherEntry."Remaining Amount" := VoucherEntry."Remaining Amount";
        ArchVoucherEntry."Register No." := VoucherEntry."Register No.";
        ArchVoucherEntry."Document Type" := VoucherEntry."Document Type";
        ArchVoucherEntry."External Document No." := VoucherEntry."External Document No.";
        ArchVoucherEntry."Document No." := VoucherEntry."Document No.";
        ArchVoucherEntry."User ID" := VoucherEntry."User ID";
        ArchVoucherEntry."Partner Code" := VoucherEntry."Partner Code";
        ArchVoucherEntry."Closed by Partner Code" := VoucherEntry."Closed by Partner Code";
        ArchVoucherEntry."Partner Clearing" := VoucherEntry."Partner Clearing";
        ArchVoucherEntry."Closed by Entry No." := VoucherEntry."Closed by Entry No.";
        OnBeforeInsertArchiveEntry(ArchVoucherEntry, VoucherEntry);
        ArchVoucherEntry.Insert;
    end;

    local procedure InsertArchivedSendingLog(Voucher: Record "NPR NpRv Voucher"; NpRvSendingLog: Record "NPR NpRv Sending Log")
    var
        NpRvArchSendingLog: Record "NPR NpRv Arch. Sending Log";
    begin
        NpRvArchSendingLog.Init;
        NpRvArchSendingLog."Entry No." := 0;
        NpRvArchSendingLog."Arch. Voucher No." := Voucher."Arch. No.";
        NpRvArchSendingLog."Sending Type" := NpRvSendingLog."Sending Type";
        NpRvArchSendingLog."Log Message" := NpRvSendingLog."Log Message";
        NpRvArchSendingLog."Log Date" := NpRvSendingLog."Log Date";
        NpRvArchSendingLog."Sent to" := NpRvSendingLog."Sent to";
        NpRvArchSendingLog.Amount := NpRvSendingLog.Amount;
        NpRvArchSendingLog."User ID" := NpRvSendingLog."User ID";
        NpRvArchSendingLog."Error during Send" := NpRvSendingLog."Error during Send";
        if NpRvSendingLog."Error Message".HasValue then begin
            NpRvSendingLog.CalcFields("Error Message");
            NpRvArchSendingLog."Error Message" := NpRvSendingLog."Error Message";
        end;
        NpRvArchSendingLog."Original Entry No." := NpRvSendingLog."Entry No.";
        NpRvArchSendingLog.Insert;
    end;

    procedure "--- Validation"()
    begin
    end;

    procedure FindVoucher(VoucherTypeCode: Text; ReferenceNo: Text; var Voucher: Record "NPR NpRv Voucher"): Boolean
    var
        VoucherType: Record "NPR NpRv Voucher Type";
    begin
        if VoucherTypeCode <> '' then
            Voucher.SetFilter("Voucher Type", VoucherTypeCode);
        Voucher.SetRange("Reference No.", ReferenceNo);
        exit(Voucher.FindFirst);
    end;

    procedure ValidateVoucher(var NpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary)
    var
        NpRvModuleMgt: Codeunit "NPR NpRv Module Mgt.";
        NpRvModuleValidateDefault: Codeunit "NPR NpRv Module Valid.: Def.";
        Handled: Boolean;
    begin
        NpRvModuleMgt.OnRunValidateVoucher(NpRvVoucherBuffer, Handled);
        if Handled then
            exit;

        NpRvModuleValidateDefault.ValidateVoucher(NpRvVoucherBuffer);
    end;

    procedure Voucher2Buffer(var NpRvVoucher: Record "NPR NpRv Voucher"; var NpRvGlobalVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary)
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
    begin
        if NpRvVoucherType.Get(NpRvVoucher."Voucher Type") then;

        NpRvVoucher.CalcFields(Amount, "Issue Date", "Issue Register No.", "Issue Document No.", "Issue User ID", "Issue Partner Code");
        NpRvGlobalVoucherBuffer."Voucher Type" := NpRvVoucher."Voucher Type";
        NpRvGlobalVoucherBuffer."No." := NpRvVoucher."No.";
        NpRvGlobalVoucherBuffer."Validate Voucher Module" := NpRvVoucherType."Validate Voucher Module";
        NpRvGlobalVoucherBuffer.Description := NpRvVoucher.Description;
        NpRvGlobalVoucherBuffer."Starting Date" := NpRvVoucher."Starting Date";
        NpRvGlobalVoucherBuffer."Ending Date" := NpRvVoucher."Ending Date";
        NpRvGlobalVoucherBuffer."Account No." := NpRvVoucher."Account No.";
        NpRvGlobalVoucherBuffer.Amount := NpRvVoucher.Amount;
        NpRvGlobalVoucherBuffer.Name := NpRvVoucher.Name;
        NpRvGlobalVoucherBuffer."Name 2" := NpRvVoucher."Name 2";
        NpRvGlobalVoucherBuffer.Address := NpRvVoucher.Address;
        NpRvGlobalVoucherBuffer."Address 2" := NpRvVoucher."Address 2";
        NpRvGlobalVoucherBuffer."Post Code" := NpRvVoucher."Post Code";
        NpRvGlobalVoucherBuffer.City := NpRvVoucher.City;
        NpRvGlobalVoucherBuffer.County := NpRvVoucher.County;
        NpRvGlobalVoucherBuffer."Country/Region Code" := NpRvVoucher."Country/Region Code";
        NpRvGlobalVoucherBuffer."E-mail" := NpRvVoucher."E-mail";
        NpRvGlobalVoucherBuffer."Phone No." := NpRvVoucher."Phone No.";
        NpRvGlobalVoucherBuffer."Voucher Message" := NpRvVoucher."Voucher Message";
        NpRvGlobalVoucherBuffer."Issue Date" := NpRvVoucher."Issue Date";
        NpRvGlobalVoucherBuffer."Issue Register No." := NpRvVoucher."Issue Register No.";
        NpRvGlobalVoucherBuffer."Issue Sales Ticket No." := NpRvVoucher."Issue Document No.";
        NpRvGlobalVoucherBuffer."Issue User ID" := NpRvVoucher."Issue User ID";
        NpRvGlobalVoucherBuffer."Issue Partner Code" := NpRvVoucher."Issue Partner Code";
    end;

    procedure "--- Filter"()
    begin
    end;

    local procedure SetSalesLineFilter(SaleLinePOS: Record "NPR Sale Line POS"; var NpRvSalesLine: Record "NPR NpRv Sales Line")
    begin
        Clear(NpRvSalesLine);
        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::POS);
        NpRvSalesLine.SetRange("Retail ID", SaleLinePOS."Retail ID");
    end;

    procedure SetSalesLineReferenceFilter(NpRvSalesLine: Record "NPR NpRv Sales Line"; var NpRvSalesLineReference: Record "NPR NpRv Sales Line Ref.")
    begin
        NpRvSalesLineReference.SetRange("Sales Line Id", NpRvSalesLine.Id);
    end;

    local procedure "--- Generate Reference No"()
    begin
    end;

    procedure GenerateTempVoucher(VoucherType: Record "NPR NpRv Voucher Type"; var TempVoucher: Record "NPR NpRv Voucher" temporary)
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        TempVoucher.Init;
        TempVoucher."No." := '';
        TempVoucher.Validate("Voucher Type", VoucherType.Code);
        if VoucherType."No. Series" <> '' then begin
            NoSeriesMgt.InitSeries(TempVoucher."No. Series", '', 0D, TempVoucher."No.", TempVoucher."No. Series");
            TempVoucher.Description := CopyStr(VoucherType.Description + ' ' + TempVoucher."No.", 1, MaxStrLen(TempVoucher.Description));
        end;
        TempVoucher."Reference No." := GenerateReferenceNo(TempVoucher);
    end;

    procedure GenerateReferenceNo(Voucher: Record "NPR NpRv Voucher") ReferenceNo: Text
    var
        Voucher2: Record "NPR NpRv Voucher";
        VoucherType: Record "NPR NpRv Voucher Type";
        i: Integer;
    begin
        VoucherType.Get(Voucher."Voucher Type");

        case VoucherType."Reference No. Type" of
            VoucherType."Reference No. Type"::Pattern:
                begin
                    ReferenceNo := GenerateReferenceNoPattern(Voucher);
                    exit(ReferenceNo);
                end;
            VoucherType."Reference No. Type"::EAN13:
                begin
                    ReferenceNo := GenerateReferenceNoEAN13(Voucher);
                    exit(ReferenceNo);
                end;
        end;

        exit('');
    end;

    local procedure GenerateReferenceNoPattern(Voucher: Record "NPR NpRv Voucher") ReferenceNo: Text
    var
        Voucher2: Record "NPR NpRv Voucher";
        VoucherType: Record "NPR NpRv Voucher Type";
        i: Integer;
    begin
        VoucherType.Get(Voucher."Voucher Type");
        if VoucherType."Reference No. Type" <> VoucherType."Reference No. Type"::Pattern then
            exit('');

        for i := 1 to 100 do begin
            ReferenceNo := VoucherType."Reference No. Pattern";
            ReferenceNo := RegExReplaceN(ReferenceNo);
            ReferenceNo := RegExReplaceAN(ReferenceNo);
            ReferenceNo := RegExReplaceS(ReferenceNo, Voucher."No.");
            ReferenceNo := UpperCase(CopyStr(ReferenceNo, 1, MaxStrLen(Voucher."Reference No.")));

            Voucher2.SetFilter("No.", '<>%1', Voucher."No.");
            Voucher2.SetRange("Reference No.", ReferenceNo);
            if Voucher2.IsEmpty then
                exit(ReferenceNo);

            if ReferenceNo = VoucherType."Reference No. Pattern" then
                exit(ReferenceNo);
        end;

        exit(ReferenceNo);
    end;

    local procedure GenerateReferenceNoEAN13(Voucher: Record "NPR NpRv Voucher") ReferenceNo: Text
    var
        Voucher2: Record "NPR NpRv Voucher";
        VoucherType: Record "NPR NpRv Voucher Type";
        i: Integer;
        CheckSum: Integer;
    begin
        VoucherType.Get(Voucher."Voucher Type");
        if VoucherType."Reference No. Type" <> VoucherType."Reference No. Type"::EAN13 then
            exit('');

        for i := 1 to 100 do begin
            ReferenceNo := VoucherType."Reference No. Pattern";
            ReferenceNo := RegExReplaceN(ReferenceNo);
            ReferenceNo := RegExReplaceAN(ReferenceNo);
            ReferenceNo := RegExReplaceS(ReferenceNo, Voucher."No.");
            ReferenceNo := UpperCase(CopyStr(ReferenceNo, 1, MaxStrLen(Voucher."Reference No.")));
            if StrLen(ReferenceNo) < 12 then
                ReferenceNo := CopyStr(ReferenceNo, 1, 2) + PadStr('', 12 - StrLen(ReferenceNo), '0') + CopyStr(ReferenceNo, 3);
            if StrLen(ReferenceNo) > 12 then
                Error(Text000, ReferenceNo);
            if not TryGetCheckSum(ReferenceNo, CheckSum) then
                Error(Text000, ReferenceNo);
            ReferenceNo := ReferenceNo + Format(CheckSum);

            Voucher2.SetFilter("No.", '<>%1', Voucher."No.");
            Voucher2.SetRange("Reference No.", ReferenceNo);
            if Voucher2.IsEmpty then
                exit(ReferenceNo);

            if ReferenceNo = VoucherType."Reference No. Pattern" then
                exit(ReferenceNo);
        end;

        exit(ReferenceNo);
    end;

    [TryFunction]
    local procedure TryGetCheckSum(ReferenceNo: Text; var CheckSum: Integer)
    begin
        CheckSum := StrCheckSum(ReferenceNo, '131313131313');
    end;

    local procedure RegExReplaceAN(Input: Text) Output: Text
    var
        Match: DotNet NPRNetMatch;
        RegEx: DotNet NPRNetRegex;
        Pattern: Text;
        ReplaceString: Text;
        RandomQty: Integer;
        i: Integer;
    begin
        Pattern := '(?<RandomStart>\[AN\*?)' +
                   '(?<RandomQty>\d?)' +
                   '(?<RandomEnd>\])';
        RegEx := RegEx.Regex(Pattern);

        Match := RegEx.Match(Input);
        while Match.Success do begin
            ReplaceString := '';
            RandomQty := 1;
            if Evaluate(RandomQty, Format(Match.Groups.Item('RandomQty'))) then;
            for i := 1 to RandomQty do
                ReplaceString += Format(GenerateRandomChar());
            Input := RegEx.Replace(Input, ReplaceString, 1);

            Match := RegEx.Match(Input);
        end;

        Output := Input;
        exit(Output);
    end;

    local procedure RegExReplaceN(Input: Text) Output: Text
    var
        Match: DotNet NPRNetMatch;
        RegEx: DotNet NPRNetRegex;
        Pattern: Text;
        ReplaceString: Text;
        RandomQty: Integer;
        i: Integer;
    begin
        Pattern := '(?<RandomStart>\[N\*?)' +
                   '(?<RandomQty>\d?)' +
                   '(?<RandomEnd>\])';
        RegEx := RegEx.Regex(Pattern);

        Match := RegEx.Match(Input);
        while Match.Success do begin
            ReplaceString := '';
            RandomQty := 1;
            if Evaluate(RandomQty, Format(Match.Groups.Item('RandomQty'))) then;
            for i := 1 to RandomQty do
                ReplaceString += Format(Random(9));
            Input := RegEx.Replace(Input, ReplaceString, 1);

            Match := RegEx.Match(Input);
        end;

        Output := Input;
        exit(Output);
    end;

    local procedure RegExReplaceS(Input: Text; SerialNo: Text) Output: Text
    var
        Match: DotNet NPRNetMatch;
        RegEx: DotNet NPRNetRegex;
        Pattern: Text;
    begin
        Pattern := '(?<SerialNo>\[S\])';
        RegEx := RegEx.Regex(Pattern);
        Output := RegEx.Replace(Input, SerialNo);
        exit(Output);
    end;

    local procedure GenerateRandomChar() RandomChar: Char
    var
        RandomInt: Integer;
        RandomText: Text[1];
    begin
        RandomInt := Random(9999);

        if Random(35) < 10 then begin
            RandomText := Format(RandomInt mod 10);
            RandomChar := RandomText[1];
            exit(RandomChar);
        end;

        RandomChar := (RandomInt mod 25) + 65;
        RandomText := UpperCase(Format(RandomChar));
        RandomChar := RandomText[1];
        exit(RandomChar);
    end;

    local procedure "--- Events"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertIssuedVoucher(var Voucher: Record "NPR NpRv Voucher"; SaleLinePOSVoucher: Record "NPR NpRv Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertIssuedVoucherEntry(var VoucherEntry: Record "NPR NpRv Voucher Entry"; Voucher: Record "NPR NpRv Voucher"; NpRvSalesLine: Record "NPR NpRv Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPaymentVoucherEntry(var VoucherEntry: Record "NPR NpRv Voucher Entry"; SaleLinePOSVoucher: Record "NPR NpRv Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertArchiveEntry(var ArchVoucherEntry: Record "NPR NpRv Arch. Voucher Entry"; NpRvVoucherEntry: Record "NPR NpRv Voucher Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIssueVouchers(var NpRvSalesLine: Record "NPR NpRv Sales Line"; var Handled: Boolean)
    begin
    end;
}