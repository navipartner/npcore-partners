codeunit 6151010 "NpRv Voucher Mgt."
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.48/MHA /20180920  CASE 302179 Added External Voucher functionality
    // NPR5.48/MHA /20190123  CASE 341711 Added "Send via Print","Send via E-mail", and "Send via SMS" in IssueVoucher()
    // NPR5.49/MHA /20190212  CASE 302179 Added Cleanup of NpRvExtVoucherSalesLine in OnAfterPostSalesDoc()
    // NPR5.49/MHA /20190228  CASE 342811 Added Retail Voucher Partner functionality used with Cross Company Vouchers
    // NPR5.50/MHA /20190426  CASE 353079 Added Top-up functionality
    // NPR5.50/MMV /20190527  CASE 356003 Added event publishers in between posting steps and set new "Posted" field before deleting buffer lines, for better extensibility.
    //                                    Added event for handling buffered partner issued vouchers, for better extensibility.
    //                                    Changed archiving handling.
    // NPR5.51/MHA /20190617  CASE 358582 Added function OnAfterDebitSalePostEvent()
    // NPR5.51/MHA /20190823  CASE 364542 Return Vouchers are now issued via Payment Lines where Unit Price and Quantity is 0
    // NPR5.53/MHA /20191114  CASE 372315 Added Top-up functionality from Sales Invoice
    // NPR5.53/MHA /20192211  CASE 378597 Added support for Sales Line Quantity greater than 1
    // NPR5.53/MHA /20191209  CASE 380284 Vouchers with balance should be Send again upon Payment and Topup
    // NPR5.54/MHA /20200310  CASE 372135 Adjusted function signature of IssueVoucher() to allow for Voucher No. to also be parsed


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Invalid EAN13: %1.';
        Text001: Label 'Invalid Reference No.';
        Text002: Label 'Retail Voucher Payment Amount %1 is higher than Remaining Amount %2 on Retail Voucher %3';
        Text003: Label 'Retail Voucher Payment Amount %1 must not be less than 0';

    procedure ResetInUseQty(Voucher: Record "NpRv Voucher")
    var
        SaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher";
        ExtSaleLineVoucher: Record "NpRv Ext. Voucher Sales Line";
    begin
        SaleLinePOSVoucher.SetRange("Voucher No.",Voucher."No.");
        //-NPR5.48 [302179]
        // IF SaleLinePOSVoucher.ISEMPTY THEN
        //  EXIT;
        //
        // SaleLinePOSVoucher.DELETEALL;
        if SaleLinePOSVoucher.FindFirst then
          SaleLinePOSVoucher.DeleteAll;

        ExtSaleLineVoucher.SetRange("Voucher No.");
        if ExtSaleLineVoucher.FindFirst then
          ExtSaleLineVoucher.DeleteAll;
        //+NPR5.48 [302179]
    end;

    local procedure "--- POS Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6014406, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeletePOSSaleLine(var Rec: Record "Sale Line POS";RunTrigger: Boolean)
    var
        SaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher";
    begin
        if Rec.IsTemporary then
          exit;

        SetSaleLinePOSVoucherFilter(Rec,SaleLinePOSVoucher);
        if SaleLinePOSVoucher.IsEmpty then
          exit;

        SaleLinePOSVoucher.DeleteAll;
    end;

    [EventSubscriber(ObjectType::Table, 6151015, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeletePOSVoucher(var Rec: Record "NpRv Sale Line POS Voucher";RunTrigger: Boolean)
    var
        SaleLinePOSReference: Record "NpRv Sale Line POS Reference";
    begin
        if Rec.IsTemporary then
          exit;

        SetSaleLinePOSReferenceFilter(Rec,SaleLinePOSReference);
        if SaleLinePOSReference.IsEmpty then
          exit;

        SaleLinePOSReference.DeleteAll;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014435, 'OnBeforeAuditRoleLineInsertEvent', '', false, false)]
    local procedure OnBeforeAuditRollInsert(var SaleLinePos: Record "Sale Line POS")
    var
        SaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher";
    begin
        SetSaleLinePOSVoucherFilter(SaleLinePos,SaleLinePOSVoucher);
        if SaleLinePOSVoucher.IsEmpty then
          exit;

        SaleLinePOSVoucher.SetRange(Type,SaleLinePOSVoucher.Type::"New Voucher");
        if SaleLinePOSVoucher.FindSet then
          repeat
            IssueVouchers(SaleLinePOSVoucher);
          until SaleLinePOSVoucher.Next = 0;

        //-NPR5.50 [356003]
        SetSaleLinePOSVoucherFilter(SaleLinePos,SaleLinePOSVoucher);
        SaleLinePOSVoucher.SetRange(Type,SaleLinePOSVoucher.Type::"Partner Issue Voucher");
        if SaleLinePOSVoucher.FindSet then
          repeat
            OnPostPartnerIssueVoucher(SaleLinePOSVoucher);
          until SaleLinePOSVoucher.Next = 0;
        //+NPR5.50 [356003]

        //-NPR5.50 [353079]
        SetSaleLinePOSVoucherFilter(SaleLinePos,SaleLinePOSVoucher);
        SaleLinePOSVoucher.SetRange(Type,SaleLinePOSVoucher.Type::"Top-up");
        if SaleLinePOSVoucher.FindSet then
          repeat
            ApplyVoucherTopup(SaleLinePOSVoucher);
          until SaleLinePOSVoucher.Next = 0;
        //+NPR5.50 [353079]

        SetSaleLinePOSVoucherFilter(SaleLinePos,SaleLinePOSVoucher);
        SaleLinePOSVoucher.SetRange(Type,SaleLinePOSVoucher.Type::Payment);
        if SaleLinePOSVoucher.FindSet then
          repeat
            PostPayment(SaleLinePOSVoucher);
          until SaleLinePOSVoucher.Next = 0;

        SetSaleLinePOSVoucherFilter(SaleLinePos,SaleLinePOSVoucher);
        SaleLinePOSVoucher.DeleteAll;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150705, 'OnAfterEndSale', '', true, true)]
    local procedure OnAfterEndSale(var Sender: Codeunit "POS Sale";SalePOS: Record "Sale POS")
    var
        Voucher: Record "NpRv Voucher";
        VoucherType: Record "NpRv Voucher Type";
        VoucherEntry: Record "NpRv Voucher Entry";
    begin
        //-NPR5.53 [380284]
        //VoucherEntry.SETRANGE("Entry Type",VoucherEntry."Entry Type"::"Issue Voucher");
        VoucherEntry.SetFilter("Entry Type",'%1|%2|%3',VoucherEntry."Entry Type"::"Issue Voucher",VoucherEntry."Entry Type"::Payment,VoucherEntry."Entry Type"::"Top-up");
        //+NPR5.53 [380284]
        VoucherEntry.SetRange("Register No.",SalePOS."Register No.");
        VoucherEntry.SetRange("Document No.",SalePOS."Sales Ticket No.");
        if VoucherEntry.IsEmpty then
          exit;

        VoucherEntry.FindSet;
        repeat
          if Voucher.Get(VoucherEntry."Voucher No.") then
            SendVoucher(Voucher);
        until VoucherEntry.Next = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014407, 'OnAfterDebitSalePostEvent', '', true, true)]
    local procedure OnAfterDebitSalePostEvent(var Sender: Codeunit "Retail Sales Doc. Mgt.";SalePOS: Record "Sale POS";SalesHeader: Record "Sales Header";Posted: Boolean;WriteInAuditRoll: Boolean)
    var
        Voucher: Record "NpRv Voucher";
        VoucherEntry: Record "NpRv Voucher Entry";
    begin
        //-NPR5.51 [358582]
        //-NPR5.53 [380284]
        //VoucherEntry.SETRANGE("Entry Type",VoucherEntry."Entry Type"::"Issue Voucher");
        VoucherEntry.SetFilter("Entry Type",'%1|%2|%3',VoucherEntry."Entry Type"::"Issue Voucher",VoucherEntry."Entry Type"::Payment,VoucherEntry."Entry Type"::"Top-up");
        //+NPR5.53 [380284]
        VoucherEntry.SetRange("Register No.",SalePOS."Register No.");
        VoucherEntry.SetRange("Document No.",SalePOS."Sales Ticket No.");
        if VoucherEntry.IsEmpty then
          exit;

        VoucherEntry.FindSet;
        repeat
          if Voucher.Get(VoucherEntry."Voucher No.") then
            SendVoucher(Voucher);
        until VoucherEntry.Next = 0;
        //+NPR5.51 [358582]
    end;

    local procedure "--- Sales Doc Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeleteSalesLine(var Rec: Record "Sales Line";RunTrigger: Boolean)
    var
        NpRvExtVoucherSalesLine: Record "NpRv Ext. Voucher Sales Line";
    begin
        //-NPR5.48 [302179]
        if Rec.IsTemporary then
          exit;
        if not RunTrigger then
          exit;

        NpRvExtVoucherSalesLine.SetRange("Document Type",Rec."Document Type");
        NpRvExtVoucherSalesLine.SetRange("Document No.",Rec."Document No.");
        NpRvExtVoucherSalesLine.SetRange("Document Line No.",Rec."Line No.");
        if NpRvExtVoucherSalesLine.FindFirst then
          NpRvExtVoucherSalesLine.DeleteAll;
        //+NPR5.48 [302179]
    end;

    [EventSubscriber(ObjectType::Table, 6151409, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeleteMagentoPaymentLine(var Rec: Record "Magento Payment Line")
    var
        NpRvExtVoucherSalesLine: Record "NpRv Ext. Voucher Sales Line";
    begin
        //-NPR5.48 [302179]
        if Rec.IsTemporary then
          exit;
        if Rec."Payment Type" <> Rec."Payment Type"::Voucher then
          exit;
        if Rec."Source Table No." <> DATABASE::"NpRv Voucher" then
          exit;
        if Rec."External Reference No." = '' then
          exit;
        if Rec."No." = '' then
          exit;

        NpRvExtVoucherSalesLine.SetRange("External Document No.",Rec."External Reference No.");
        NpRvExtVoucherSalesLine.SetRange("Reference No.",Rec."No.");
        if NpRvExtVoucherSalesLine.FindFirst then
          NpRvExtVoucherSalesLine.DeleteAll;
        //+NPR5.48 [302179]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151416, 'OnCheckPayment', '', true, true)]
    local procedure OnCheckMagentoPayment(SalesHeader: Record "Sales Header")
    var
        NpRvVoucher: Record "NpRv Voucher";
        PaymentLine: Record "Magento Payment Line";
    begin
        //-NPR5.48 [302179]
        if SalesHeader.IsTemporary then
          exit;
        if not (SalesHeader."Document Type" in [SalesHeader."Document Type"::Order,SalesHeader."Document Type"::Invoice]) then
          exit;

        PaymentLine.SetRange("Document Table No.",DATABASE::"Sales Header");
        PaymentLine.SetRange("Document Type",SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.",SalesHeader."No.");
        PaymentLine.SetRange("Payment Type",PaymentLine."Payment Type"::Voucher);
        PaymentLine.SetRange("Source Table No.",DATABASE::"NpRv Voucher");
        if PaymentLine.IsEmpty then
          exit;

        PaymentLine.FindSet;
        repeat
          if PaymentLine.Amount < 0 then
            Error(Text003,PaymentLine.Amount);
          NpRvVoucher.Get(PaymentLine."Source No.");
          NpRvVoucher.TestField("Reference No.",PaymentLine."No.");
          NpRvVoucher.CalcFields(Amount);
          if NpRvVoucher.Amount < PaymentLine.Amount then
            Error(Text002,PaymentLine.Amount,NpRvVoucher.Amount,NpRvVoucher."Reference No.");
        until PaymentLine.Next = 0;
        //+NPR5.48 [302179]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151416, 'OnBeforePostPaymentLine', '', true, true)]
    local procedure OnBeforePostMagentoPaymentLine(var PaymentLine: Record "Magento Payment Line")
    var
        NpRvVoucher: Record "NpRv Voucher";
        NpRvExtVoucherSalesLine: Record "NpRv Ext. Voucher Sales Line";
    begin
        //-NPR5.48 [302179]
        if PaymentLine."Payment Type" <> PaymentLine."Payment Type"::Voucher then
          exit;
        if PaymentLine."Source Table No." <> DATABASE::"NpRv Voucher" then
          exit;
        if not NpRvVoucher.Get(PaymentLine."Source No.") then
          exit;
        if NpRvVoucher."Reference No." <> PaymentLine."No." then
          exit;

        NpRvExtVoucherSalesLine.SetRange("External Document No.",PaymentLine."External Reference No.");
        NpRvExtVoucherSalesLine.SetRange("Voucher Type",NpRvVoucher."Voucher Type");
        NpRvExtVoucherSalesLine.SetRange("Voucher No.",NpRvVoucher."No.");
        NpRvExtVoucherSalesLine.SetRange("Reference No.",PaymentLine."No.");
        NpRvExtVoucherSalesLine.SetRange(Type,NpRvExtVoucherSalesLine.Type::Payment);
        if NpRvExtVoucherSalesLine.IsEmpty then
          exit;

        NpRvExtVoucherSalesLine.FindFirst;
        PostMagentoPayment(PaymentLine,NpRvExtVoucherSalesLine);
        NpRvExtVoucherSalesLine.DeleteAll;
        //+NPR5.48 [302179]
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterPostSalesDoc', '', true, true)]
    local procedure OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header";SalesInvHdrNo: Code[20])
    var
        NpRvExtVoucherSalesLine: Record "NpRv Ext. Voucher Sales Line";
        NpRvVoucher: Record "NpRv Voucher";
        NpRvVoucher2: Record "NpRv Voucher";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        TempNpRvVoucher: Record "NpRv Voucher" temporary;
        i: Integer;
    begin
        if SalesHeader."External Order No." = '' then
          exit;
        if not SalesHeader.Invoice then
          exit;
        if SalesInvHdrNo = '' then
          exit;
        if not SalesInvHeader.Get(SalesInvHdrNo) then
          exit;

        //-NPR5.53 [372315]
        NpRvExtVoucherSalesLine.SetRange("External Document No.",SalesHeader."External Order No.");
        NpRvExtVoucherSalesLine.SetRange(Type,NpRvExtVoucherSalesLine.Type::"New Voucher");
        if NpRvExtVoucherSalesLine.FindSet then
          repeat
            if SalesInvLine.Get(SalesInvHeader."No.",NpRvExtVoucherSalesLine."Document Line No.") and NpRvVoucher.Get(NpRvExtVoucherSalesLine."Voucher No.") then begin
              //-NPR5.53 [378597]
              for i := 1 to SalesInvLine."Quantity (Base)" do begin
                NpRvVoucher2.Get(NpRvVoucher."No.");
                if TempNpRvVoucher.Get(NpRvVoucher."No.") then begin
                  NpRvVoucher2.Init;
                  NpRvVoucher2 := NpRvVoucher;
                  NpRvVoucher2."No." := '';
                  NpRvVoucher2."Reference No." := '';
                  NpRvVoucher2.Insert(true);
                end;

                PostIssueVoucherInv(NpRvVoucher2,SalesInvHeader,SalesInvLine);

                TempNpRvVoucher.Init;
                TempNpRvVoucher := NpRvVoucher2;
                TempNpRvVoucher.Insert;
              end;
              //+NPR5.53 [378597]
            end;
            NpRvExtVoucherSalesLine.Delete;
          until NpRvExtVoucherSalesLine.Next = 0;

        NpRvExtVoucherSalesLine.SetRange(Type,NpRvExtVoucherSalesLine.Type::"Top-up");
        if NpRvExtVoucherSalesLine.FindSet then
          repeat
            if SalesInvLine.Get(SalesInvHeader."No.",NpRvExtVoucherSalesLine."Document Line No.") and NpRvVoucher.Get(NpRvExtVoucherSalesLine."Voucher No.") then begin
              ApplyVoucherTopupInv(NpRvVoucher,SalesInvHeader,SalesInvLine);

              if not TempNpRvVoucher.Get(NpRvVoucher."No.") then begin
                TempNpRvVoucher.Init;
                TempNpRvVoucher := NpRvVoucher;
                TempNpRvVoucher.Insert;
              end;
            end;
            NpRvExtVoucherSalesLine.Delete;
          until NpRvExtVoucherSalesLine.Next = 0;

        Commit;

        if TempNpRvVoucher.FindSet then
          repeat
            NpRvVoucher.Get(TempNpRvVoucher."No.");
            SendVoucher(NpRvVoucher);
          until TempNpRvVoucher.Next = 0;
        //+NPR5.53 [372315]
    end;

    local procedure "--- Issue Voucher"()
    begin
    end;

    local procedure IssueVouchers(var SaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher")
    var
        SaleLinePOS: Record "Sale Line POS";
        SaleLinePOSReference: Record "NpRv Sale Line POS Reference";
        VoucherType: Record "NpRv Voucher Type";
        i: Integer;
    begin
        VoucherType.Get(SaleLinePOSVoucher."Voucher Type");
        if not SaleLinePOS.Get(SaleLinePOSVoucher."Register No.",SaleLinePOSVoucher."Sales Ticket No.",SaleLinePOSVoucher."Sale Date",
                               SaleLinePOSVoucher."Sale Type",SaleLinePOSVoucher."Sale Line No.") then
          exit;
        //-NPR5.51 [364542]
        if SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::Payment then begin
          SaleLinePOS."Unit Price" := Abs(SaleLinePOS."Amount Including VAT");
          SaleLinePOS.Quantity := 1;
        end;
        //+NPR5.51 [364542]
        if SaleLinePOS."Unit Price" <= 0 then
          exit;
        if SaleLinePOS.Quantity <= 0 then
          exit;

        SaleLinePOSReference.SetRange("Register No.",SaleLinePOSVoucher."Register No.");
        SaleLinePOSReference.SetRange("Sales Ticket No.",SaleLinePOSVoucher."Sales Ticket No.");
        SaleLinePOSReference.SetRange("Sale Type",SaleLinePOSVoucher."Sale Type");
        SaleLinePOSReference.SetRange("Sale Date",SaleLinePOSVoucher."Sale Date");
        SaleLinePOSReference.SetRange("Sale Line No.",SaleLinePOSVoucher."Sale Line No.");
        SaleLinePOSReference.SetRange("Voucher Line No.",SaleLinePOSVoucher."Line No.");
        if SaleLinePOSReference.FindSet then;

        for i := 1 to SaleLinePOS.Quantity do begin
          //-NPR5.54 [372135]
          //IssueVoucher(VoucherType,SaleLinePOS,SaleLinePOSVoucher,SaleLinePOSReference."Reference No.");
          //IF SaleLinePOSReference.NEXT = 0 THEN
          //  SaleLinePOSReference."Reference No." := '';
          IssueVoucher(VoucherType,SaleLinePOS,SaleLinePOSVoucher,SaleLinePOSReference);
          if SaleLinePOSReference.Next = 0 then begin
            SaleLinePOSReference."Voucher No." := '';
            SaleLinePOSReference."Reference No." := '';
          end;
          //+NPR5.54 [372135]
        end;
    end;

    local procedure IssueVoucher(VoucherType: Record "NpRv Voucher Type";SaleLinePOS: Record "Sale Line POS";var SaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher";SaleLinePOSReference: Record "NpRv Sale Line POS Reference")
    var
        Voucher: Record "NpRv Voucher";
        PrevVoucher: Text;
    begin
        if SaleLinePOS."Unit Price" <= 0 then
          exit;
        //-NPR5.54 [372135]
        //IF ReferenceNo <> '' THEN
        //  VoucherType.TESTFIELD("Reference No. Pattern");
        if SaleLinePOSReference."Reference No." = '' then
          VoucherType.TestField("Reference No. Pattern");
        //+NPR5.54 [372135]

        Voucher.Init;
        Voucher."Starting Date" := SaleLinePOSVoucher."Starting Date";
        Voucher.Validate("Voucher Type",VoucherType.Code);
        //-NPR5.54 [372135]
        // Voucher."No." := '';
        // Voucher."Reference No." := ReferenceNo;
        Voucher."No." := SaleLinePOSReference."Voucher No.";
        Voucher."Reference No." := SaleLinePOSReference."Reference No.";
        //+NPR5.54 [372135]
        //-NPR5.50 [356003]
        OnBeforeInsertIssuedVoucher(Voucher, SaleLinePOSVoucher);
        //+NPR5.50 [356003]
        Voucher.Insert(true);

        PrevVoucher := Format(Voucher);
        Voucher.Description := CopyStr(VoucherType.Description + ' ' + Voucher."No.",1,MaxStrLen(Voucher.Description));
        Voucher."Customer No." := SaleLinePOSVoucher."Customer No.";
        Voucher."Contact No." := SaleLinePOSVoucher."Contact No.";
        Voucher.Name := SaleLinePOSVoucher.Name;
        Voucher."Name 2" := SaleLinePOSVoucher."Name 2";
        Voucher.Address := SaleLinePOSVoucher.Address;
        Voucher."Address 2" := SaleLinePOSVoucher."Address 2";
        Voucher."Post Code" := SaleLinePOSVoucher."Post Code";
        Voucher.City := SaleLinePOSVoucher.City;
        Voucher.County := SaleLinePOSVoucher.County;
        Voucher."Country/Region Code" := SaleLinePOSVoucher."Country/Region Code";
        Voucher."E-mail" := SaleLinePOSVoucher."E-mail";
        Voucher."Phone No." := SaleLinePOSVoucher."Phone No.";
        //-NPR5.48 [341711]
        Voucher."Send via Print" := SaleLinePOSVoucher."Send via Print";
        Voucher."Send via E-mail" := SaleLinePOSVoucher."Send via E-mail";
        Voucher."Send via SMS" := SaleLinePOSVoucher."Send via SMS";
        //+NPR5.48 [341711]
        Voucher."Voucher Message" := SaleLinePOSVoucher."Voucher Message";
        if PrevVoucher <>  Format(Voucher) then
          Voucher.Modify(true);

        PostIssueVoucher(Voucher,SaleLinePOS);

        //-NPR5.50 [356003]
        if not SaleLinePOSVoucher.Posted then begin
          SaleLinePOSVoucher.Posted := true;
          SaleLinePOSVoucher.Modify;
        end;
        //+NPR5.50 [356003]
    end;

    local procedure InitialEntryExists(Voucher: Record "NpRv Voucher"): Boolean
    var
        VoucherEntry: Record "NpRv Voucher Entry";
    begin
        VoucherEntry.SetRange("Voucher No.",Voucher."No.");
        VoucherEntry.SetRange("Entry Type",VoucherEntry."Entry Type"::"Issue Voucher");
        exit(VoucherEntry.FindFirst);
    end;

    procedure PostIssueVoucher(Voucher: Record "NpRv Voucher";SaleLinePOS: Record "Sale Line POS")
    var
        VoucherEntry: Record "NpRv Voucher Entry";
        VoucherType: Record "NpRv Voucher Type";
    begin
        if InitialEntryExists(Voucher) then
          exit;

        VoucherType.Get(Voucher."Voucher Type");

        VoucherEntry.Init;
        VoucherEntry."Entry No." := 0;
        VoucherEntry."Voucher No." := Voucher."No.";
        VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Issue Voucher";
        VoucherEntry."Voucher Type" := Voucher."Voucher Type";
        VoucherEntry.Amount := SaleLinePOS."Unit Price";
        VoucherEntry."Remaining Amount" := VoucherEntry.Amount;
        VoucherEntry.Positive := VoucherEntry.Amount > 0;
        VoucherEntry."Posting Date" := SaleLinePOS.Date;
        VoucherEntry.Open := VoucherEntry.Amount <> 0;
        VoucherEntry."Register No." := SaleLinePOS."Register No.";
        //-NPR5.48 [302179]
        VoucherEntry."Document Type" := VoucherEntry."Document Type"::"Audit Roll";
        //+NPR5.48 [302179]
        VoucherEntry."Document No." := SaleLinePOS."Sales Ticket No.";
        //-NPR5.49 [342811]
        VoucherEntry."Partner Code" := VoucherType."Partner Code";
        //+NPR5.49 [342811]
        VoucherEntry."User ID" := UserId;
        VoucherEntry."Closed by Entry No." := 0;
        //-NPR5.50 [356003]
        OnBeforeInsertIssuedVoucherEntry(VoucherEntry, Voucher, SaleLinePOS);
        //+NPR5.50 [356003]
        VoucherEntry.Insert;
    end;

    procedure PostIssueVoucherInv(Voucher: Record "NpRv Voucher";SalesInvHeader: Record "Sales Invoice Header";SalesInvLine: Record "Sales Invoice Line")
    var
        VoucherEntry: Record "NpRv Voucher Entry";
        VoucherType: Record "NpRv Voucher Type";
    begin
        //-NPR5.48 [302179]
        if InitialEntryExists(Voucher) then
          exit;

        VoucherType.Get(Voucher."Voucher Type");

        VoucherEntry.Init;
        VoucherEntry."Entry No." := 0;
        VoucherEntry."Voucher No." := Voucher."No.";
        VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Issue Voucher";
        VoucherEntry."Voucher Type" := Voucher."Voucher Type";
        //-NPR5.53 [378597]
        VoucherEntry.Amount := SalesInvLine."Unit Price";
        //+NPR5.53 [378597]
        VoucherEntry."Remaining Amount" := VoucherEntry.Amount;
        VoucherEntry.Positive := VoucherEntry.Amount > 0;
        VoucherEntry."Posting Date" := SalesInvLine."Posting Date";
        VoucherEntry.Open := VoucherEntry.Amount <> 0;
        VoucherEntry."Register No." := '';
        VoucherEntry."Document Type" := VoucherEntry."Document Type"::Invoice;
        VoucherEntry."Document No." := SalesInvLine."Document No.";
        //-NPR5.49 [342811]
        VoucherEntry."Partner Code" := VoucherType."Partner Code";
        //+NPR5.49 [342811]
        VoucherEntry."External Document No." := SalesInvHeader."External Order No.";
        VoucherEntry."User ID" := UserId;
        VoucherEntry."Closed by Entry No." := 0;
        VoucherEntry.Insert;
        //+NPR5.48 [302179]
    end;

    procedure SendVoucher(Voucher: Record "NpRv Voucher")
    var
        VoucherType: Record "NpRv Voucher Type";
        NpRvModuleMgt: Codeunit "NpRv Module Mgt.";
        NpRvModuleSendDefault: Codeunit "NpRv Module Send - Default";
        Handled: Boolean;
    begin
        if not VoucherType.Get(Voucher."Voucher Type") then
          exit;

        //-NPR5.53 [380284]
        Voucher.CalcFields(Amount);
        if Voucher.Amount <= 0 then
          exit;
        //+NPR5.53 [380284]

        Voucher.CalcFields("Send Voucher Module");
        NpRvModuleMgt.OnRunSendVoucher(Voucher,VoucherType,Handled);

        if not Handled then
          //-NPR5.48 [341711]
          //NpRvModuleSendDefault.PrintVoucher(Voucher);
          NpRvModuleSendDefault.SendVoucher(Voucher);
          //+NPR5.48 [341711]
    end;

    local procedure "--- Voucher Top-up"()
    begin
    end;

    local procedure ApplyVoucherTopup(var SaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher")
    var
        SaleLinePOS: Record "Sale Line POS";
        NpRvVoucherType: Record "NpRv Voucher Type";
        Voucher: Record "NpRv Voucher";
        VoucherEntry: Record "NpRv Voucher Entry";
        i: Integer;
    begin
        //-NPR5.50 [353079]
        if not SaleLinePOS.Get(
          SaleLinePOSVoucher."Register No.",SaleLinePOSVoucher."Sales Ticket No.",SaleLinePOSVoucher."Sale Date",SaleLinePOSVoucher."Sale Type",SaleLinePOSVoucher."Sale Line No.")
        then
          exit;

        if SaleLinePOS."Amount Including VAT" <= 0 then
          exit;

        Voucher.Get(SaleLinePOSVoucher."Voucher No.");

        VoucherEntry.Init;
        VoucherEntry."Entry No." := 0;
        VoucherEntry."Voucher No." := Voucher."No.";
        VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Top-up";
        VoucherEntry."Voucher Type" := Voucher."Voucher Type";
        VoucherEntry.Amount := SaleLinePOS."Amount Including VAT";
        VoucherEntry."Remaining Amount" := VoucherEntry.Amount;
        VoucherEntry.Positive := VoucherEntry.Amount > 0;
        VoucherEntry."Posting Date" := SaleLinePOS.Date;
        VoucherEntry.Open := VoucherEntry.Amount <> 0;
        VoucherEntry."Register No." := SaleLinePOS."Register No.";
        VoucherEntry."Document Type" := VoucherEntry."Document Type"::"Audit Roll";
        VoucherEntry."Document No." := SaleLinePOS."Sales Ticket No.";
        VoucherEntry."User ID" := UserId;
        VoucherEntry."Closed by Entry No." := 0;
        if NpRvVoucherType.Get(Voucher."Voucher Type") then
          VoucherEntry."Partner Code" := NpRvVoucherType."Partner Code";
        VoucherEntry.Insert;

        ApplyEntry(VoucherEntry);

        ArchiveClosedVoucher(Voucher);

        //-NPR5.50 [356003]
        SaleLinePOSVoucher.Posted := true;
        SaleLinePOSVoucher.Modify;
        //+NPR5.50 [356003]
    end;

    local procedure ApplyVoucherTopupInv(Voucher: Record "NpRv Voucher";SalesInvHeader: Record "Sales Invoice Header";SalesInvLine: Record "Sales Invoice Line")
    var
        NpRvVoucherType: Record "NpRv Voucher Type";
        VoucherEntry: Record "NpRv Voucher Entry";
        i: Integer;
    begin
        //-NPR5.53 [372315]
        if not Voucher."Allow Top-up" then
          exit;

        if SalesInvLine."Line Amount" <= 0 then
          exit;

        VoucherEntry.Init;
        VoucherEntry."Entry No." := 0;
        VoucherEntry."Voucher No." := Voucher."No.";
        VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Top-up";
        VoucherEntry."Voucher Type" := Voucher."Voucher Type";
        VoucherEntry.Amount := SalesInvLine."Line Amount";
        VoucherEntry."Remaining Amount" := VoucherEntry.Amount;
        VoucherEntry.Positive := VoucherEntry.Amount > 0;
        VoucherEntry."Posting Date" := SalesInvLine."Posting Date";
        VoucherEntry.Open := VoucherEntry.Amount <> 0;
        VoucherEntry."Document Type" := VoucherEntry."Document Type"::Invoice;
        VoucherEntry."Document No." := SalesInvLine."Document No.";
        VoucherEntry."External Document No." := SalesInvHeader."External Document No.";
        VoucherEntry."User ID" := UserId;
        VoucherEntry."Closed by Entry No." := 0;
        if NpRvVoucherType.Get(Voucher."Voucher Type") then
          VoucherEntry."Partner Code" := NpRvVoucherType."Partner Code";
        VoucherEntry.Insert;

        ApplyEntry(VoucherEntry);
        //+NPR5.53 [372315]
    end;

    local procedure "--- Voucher Payment"()
    begin
    end;

    procedure ApplyPayment(FrontEnd: Codeunit "POS Front End Management";POSSession: Codeunit "POS Session";SaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher")
    var
        VoucherType: Record "NpRv Voucher Type";
        NpRvModuleMgt: Codeunit "NpRv Module Mgt.";
        NpRvModulePaymentDefault: Codeunit "NpRv Module Payment - Default";
        Handled: Boolean;
    begin
        VoucherType.Get(SaleLinePOSVoucher."Voucher Type");
        NpRvModuleMgt.OnRunApplyPayment(FrontEnd,POSSession,VoucherType,SaleLinePOSVoucher,Handled);
        if Handled then
          exit;

        NpRvModulePaymentDefault.ApplyPayment(FrontEnd,POSSession,VoucherType,SaleLinePOSVoucher);
    end;

    local procedure PostPayment(var SaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher")
    var
        SaleLinePOS: Record "Sale Line POS";
        NpRvVoucherType: Record "NpRv Voucher Type";
        Voucher: Record "NpRv Voucher";
        VoucherEntry: Record "NpRv Voucher Entry";
        i: Integer;
    begin
        if not SaleLinePOS.Get(SaleLinePOSVoucher."Register No.",SaleLinePOSVoucher."Sales Ticket No.",SaleLinePOSVoucher."Sale Date",
                               SaleLinePOSVoucher."Sale Type",SaleLinePOSVoucher."Sale Line No.") then
          exit;

        if SaleLinePOS."Amount Including VAT" <= 0 then
          exit;

        Voucher.Get(SaleLinePOSVoucher."Voucher No.");

        VoucherEntry.Init;
        VoucherEntry."Entry No." := 0;
        VoucherEntry."Voucher No." := Voucher."No.";
        VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::Payment;
        VoucherEntry."Voucher Type" := Voucher."Voucher Type";
        VoucherEntry.Amount := -SaleLinePOS."Amount Including VAT";
        VoucherEntry."Remaining Amount" := VoucherEntry.Amount;
        VoucherEntry.Positive := VoucherEntry.Amount > 0;
        VoucherEntry."Posting Date" := SaleLinePOS.Date;
        VoucherEntry.Open := VoucherEntry.Amount <> 0;
        VoucherEntry."Register No." := SaleLinePOS."Register No.";
        //-NPR5.48 [302179]
        VoucherEntry."Document Type" := VoucherEntry."Document Type"::"Audit Roll";
        //+NPR5.48 [302179]
        VoucherEntry."Document No." := SaleLinePOS."Sales Ticket No.";
        VoucherEntry."User ID" := UserId;
        VoucherEntry."Closed by Entry No." := 0;
        //-NPR5.49 [342811]
        if NpRvVoucherType.Get(Voucher."Voucher Type") then
          VoucherEntry."Partner Code" := NpRvVoucherType."Partner Code";
        //+NPR5.49 [342811]
        //-NPR5.50 [356003]
        OnBeforeInsertPaymentVoucherEntry(VoucherEntry, SaleLinePOSVoucher);
        //+NPR5.50 [356003]
        VoucherEntry.Insert;

        ApplyEntry(VoucherEntry);

        ArchiveClosedVoucher(Voucher);

        //-NPR5.50 [356003]
        SaleLinePOSVoucher.Posted := true;
        SaleLinePOSVoucher.Modify;
        //+NPR5.50 [356003]
    end;

    local procedure PostMagentoPayment(PaymentLine: Record "Magento Payment Line";NpRvExtVoucherSalesLine: Record "NpRv Ext. Voucher Sales Line")
    var
        Voucher: Record "NpRv Voucher";
        VoucherEntry: Record "NpRv Voucher Entry";
        i: Integer;
    begin
        //-NPR5.48 [302179]
        if PaymentLine.Amount <= 0 then
          exit;

        Voucher.Get(NpRvExtVoucherSalesLine."Voucher No.");

        VoucherEntry.Init;
        VoucherEntry."Entry No." := 0;
        VoucherEntry."Voucher No." := Voucher."No.";
        VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::Payment;
        VoucherEntry."Voucher Type" := Voucher."Voucher Type";
        VoucherEntry.Amount := -PaymentLine.Amount;
        VoucherEntry."Remaining Amount" := VoucherEntry.Amount;
        VoucherEntry.Positive := VoucherEntry.Amount > 0;
        VoucherEntry."Posting Date" := PaymentLine."Posting Date";
        VoucherEntry.Open := VoucherEntry.Amount <> 0;
        VoucherEntry."Register No." := '';
        VoucherEntry."Document Type" := VoucherEntry."Document Type"::Invoice;
        VoucherEntry."Document No." := PaymentLine."Document No.";
        VoucherEntry."External Document No." := PaymentLine."External Reference No.";
        VoucherEntry."User ID" := UserId;
        VoucherEntry."Closed by Entry No." := 0;
        VoucherEntry.Insert;

        ApplyEntry(VoucherEntry);

        ArchiveClosedVoucher(Voucher);
        //+NPR5.48 [302179]
        //-NPR5.53 [380284]
        if not Voucher.Find then
          exit;

        Voucher.CalcFields(Amount);
        if Voucher.Amount > 0 then
          SendVoucher(Voucher);
        //+NPR5.53 [380284]
    end;

    procedure ApplyEntry(var VoucherEntry: Record "NpRv Voucher Entry")
    var
        VoucherEntryApply: Record "NpRv Voucher Entry";
    begin
        if VoucherEntry.IsTemporary then
          exit;
        if not VoucherEntry.Find then
          exit;
        if not VoucherEntry.Open then
          exit;

        VoucherEntryApply.SetRange("Voucher No.",VoucherEntry."Voucher No.");
        VoucherEntryApply.SetRange(Open,true);
        VoucherEntryApply.SetRange(Positive,not VoucherEntry.Positive);
        if not VoucherEntryApply.FindSet then
          exit;

        repeat
          if Abs(VoucherEntryApply."Remaining Amount") >= Abs(VoucherEntry."Remaining Amount") then begin
            VoucherEntryApply."Remaining Amount" += VoucherEntry."Remaining Amount";
            if VoucherEntryApply."Remaining Amount" = 0 then begin
              VoucherEntryApply."Closed by Entry No." := VoucherEntry."Entry No.";
              //-NPR5.49 [342811]
              VoucherEntryApply."Closed by Partner Code" := VoucherEntry."Partner Code";
              //+NPR5.49 [342811]
              VoucherEntryApply.Open := false;
            end;

            VoucherEntry."Remaining Amount" := 0;
            VoucherEntry."Closed by Entry No." := VoucherEntryApply."Entry No.";
            //-NPR5.49 [342811]
            VoucherEntry."Closed by Partner Code" := VoucherEntryApply."Partner Code";
            //+NPR5.49 [342811]
            VoucherEntry.Open := false;
          end else begin
            VoucherEntry."Remaining Amount" += VoucherEntryApply."Remaining Amount";
            if VoucherEntry."Remaining Amount" = 0 then begin
              VoucherEntry."Closed by Entry No." := VoucherEntryApply."Entry No.";
              //-NPR5.49 [342811]
              VoucherEntry."Closed by Partner Code" := VoucherEntryApply."Partner Code";
              //+NPR5.49 [342811]
              VoucherEntry.Open := false;
            end;

            VoucherEntryApply."Remaining Amount" := 0;
            VoucherEntryApply."Closed by Entry No." := VoucherEntry."Entry No.";
            //-NPR5.49 [342811]
            VoucherEntryApply."Closed by Partner Code" := VoucherEntry."Partner Code";
            //+NPR5.49 [342811]
            VoucherEntryApply.Open := false;
          end;

          //-NPR5.49 [342811]
          VoucherEntry."Partner Clearing" := VoucherEntry."Partner Code" <> VoucherEntry."Closed by Partner Code";
          VoucherEntryApply."Partner Clearing" := VoucherEntryApply."Partner Code" <> VoucherEntryApply."Closed by Partner Code";
          //+NPR5.49 [342811]
          VoucherEntry.Modify;
          VoucherEntryApply.Modify;
        until (VoucherEntryApply.Next = 0) or not VoucherEntry.Open;
    end;

    local procedure "--- Archive"()
    begin
    end;

    procedure ArchiveVouchers(var VoucherFilter: Record "NpRv Voucher")
    var
        Voucher: Record "NpRv Voucher";
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

    local procedure ArchiveVoucher(var Voucher: Record "NpRv Voucher")
    var
        VoucherEntry: Record "NpRv Voucher Entry";
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

    local procedure ArchiveClosedVoucher(var Voucher: Record "NpRv Voucher")
    var
        VoucherEntry: Record "NpRv Voucher Entry";
        VoucherType: Record "NpRv Voucher Type";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        //-NPR5.53 [380284]
        if not Voucher.Find then
          exit;
        //+NPR5.53 [380284]
        Voucher.CalcFields(Open);
        if Voucher.Open then
          exit;

        //-NPR5.53 [372315]
        if Voucher."Allow Top-up" then
          exit;
        //+NPR5.53 [372315]

        VoucherType.Get(Voucher."Voucher Type");
        VoucherType.TestField("Arch. No. Series");
        Voucher."Arch. No." := Voucher."No.";
        if Voucher."No. Series" <> VoucherType."Arch. No. Series" then
          Voucher."Arch. No." := NoSeriesMgt.GetNextNo(VoucherType."Arch. No. Series",Today,true);

        InsertArchivedVoucher(Voucher);
        VoucherEntry.SetRange("Voucher No.",Voucher."No.");
        if VoucherEntry.FindSet then begin
          repeat
            InsertArchivedVoucherEntry(Voucher,VoucherEntry);
          until VoucherEntry.Next = 0;
          VoucherEntry.DeleteAll;
        end;

        Voucher.Delete;
    end;

    local procedure InsertArchivedVoucher(var Voucher: Record "NpRv Voucher")
    var
        ArchVoucher: Record "NpRv Arch. Voucher";
    begin
        ArchVoucher.Init;
        //-NPR5.50 [356003]
        //ArchVoucher."No." := Voucher."No.";
        ArchVoucher."No." := Voucher."Arch. No.";
        //+NPR5.50 [356003]
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
        //-NPR5.49 [342811]
        ArchVoucher."E-mail Template Code" := Voucher."E-mail Template Code";
        ArchVoucher."SMS Template Code" := Voucher."SMS Template Code";
        ArchVoucher."Send via Print" := Voucher."Send via Print";
        ArchVoucher."Send via E-mail" := Voucher."Send via E-mail";
        ArchVoucher."Send via SMS" := Voucher."Send via SMS";
        Voucher.CalcFields(Barcode);
        ArchVoucher.Barcode := Voucher.Barcode;
        //+NPR5.49 [342811]
        ArchVoucher.Insert;
    end;

    local procedure InsertArchivedVoucherEntry(Voucher: Record "NpRv Voucher";VoucherEntry: Record "NpRv Voucher Entry")
    var
        ArchVoucherEntry: Record "NpRv Arch. Voucher Entry";
    begin
        ArchVoucherEntry.Init;
        //-NPR5.50 [356003]
        //ArchVoucherEntry."Entry No." := VoucherEntry."Entry No.";
        ArchVoucherEntry."Entry No." := 0;
        ArchVoucherEntry."Original Entry No." := VoucherEntry."Entry No.";
        //+NPR5.50 [356003]
        ArchVoucherEntry."Arch. Voucher No." := Voucher."Arch. No.";
        ArchVoucherEntry."Entry Type" := VoucherEntry."Entry Type";
        ArchVoucherEntry."Voucher Type" := VoucherEntry."Voucher Type";
        ArchVoucherEntry.Positive := VoucherEntry.Positive;
        ArchVoucherEntry.Amount := VoucherEntry.Amount;
        ArchVoucherEntry."Posting Date" := VoucherEntry."Posting Date";
        ArchVoucherEntry.Open := VoucherEntry.Open;
        ArchVoucherEntry."Remaining Amount" := VoucherEntry."Remaining Amount";
        ArchVoucherEntry."Register No." := VoucherEntry."Register No.";
        //-NPR5.48 [302179]
        ArchVoucherEntry."Document Type" := VoucherEntry."Document Type";
        ArchVoucherEntry."External Document No." := VoucherEntry."External Document No.";
        //+NPR5.48 [302179]
        ArchVoucherEntry."Document No." := VoucherEntry."Document No.";
        ArchVoucherEntry."User ID" := VoucherEntry."User ID";
        //-NPR5.49 [342811]
        ArchVoucherEntry."Partner Code" := VoucherEntry."Partner Code";
        ArchVoucherEntry."Closed by Partner Code" := VoucherEntry."Closed by Partner Code";
        ArchVoucherEntry."Partner Clearing" := VoucherEntry."Partner Clearing";
        //+NPR5.49 [342811]
        ArchVoucherEntry."Closed by Entry No." := VoucherEntry."Closed by Entry No.";
        //-NPR5.50 [356003]
        OnBeforeInsertArchiveEntry(ArchVoucherEntry, VoucherEntry);
        //+NPR5.50 [356003]
        ArchVoucherEntry.Insert;
    end;

    procedure "--- Validation"()
    begin
    end;

    procedure FindVoucher(VoucherTypeCode: Text;ReferenceNo: Text;var Voucher: Record "NpRv Voucher"): Boolean
    var
        VoucherType: Record "NpRv Voucher Type";
    begin
        //-NPR5.49 [342811]
        // Voucher.SETFILTER("Voucher Type",VoucherTypeCode);
        // Voucher.SETRANGE("Reference No.",ReferenceNo);
        // IF NOT Voucher.FINDFIRST THEN
        //  ERROR(Text001);
        //
        // Voucher.CALCFIELDS(Amount);
        //
        // VoucherType.GET(Voucher."Voucher Type");
        //
        // POSSession.GetSale(POSSale);
        // POSSale.GetCurrentSale(SalePOS);
        //
        // ValidateVoucher(SalePOS,VoucherType,Voucher);
        if VoucherTypeCode <> '' then
          Voucher.SetFilter("Voucher Type",VoucherTypeCode);
        Voucher.SetRange("Reference No.",ReferenceNo);
        exit(Voucher.FindFirst);
        //+NPR5.49 [342811]
    end;

    procedure ValidateVoucher(var NpRvVoucherBuffer: Record "NpRv Voucher Buffer" temporary)
    var
        NpRvModuleMgt: Codeunit "NpRv Module Mgt.";
        NpRvModuleValidateDefault: Codeunit "NpRv Module Validate - Default";
        Handled: Boolean;
    begin
        //-NPR5.49 [342811]
        //NpRvModuleMgt.OnRunValidateVoucher(SalePOS,VoucherType,Voucher,Handled);
        // IF Handled THEN
        //  EXIT;
        //
        // NpRvModuleValidateDefault.ValidateVoucher(SalePOS,VoucherType,Voucher);
        NpRvModuleMgt.OnRunValidateVoucher(NpRvVoucherBuffer,Handled);
        if Handled then
          exit;

        NpRvModuleValidateDefault.ValidateVoucher(NpRvVoucherBuffer);
        //+NPR5.49 [342811]
    end;

    procedure Voucher2Buffer(var NpRvVoucher: Record "NpRv Voucher";var NpRvGlobalVoucherBuffer: Record "NpRv Voucher Buffer" temporary)
    var
        NpRvVoucherType: Record "NpRv Voucher Type";
    begin
        //-NPR5.49 [342811]
        if NpRvVoucherType.Get(NpRvVoucher."Voucher Type") then;

        NpRvVoucher.CalcFields(Amount,"Issue Date","Issue Register No.","Issue Document No.","Issue User ID","Issue Partner Code");
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
        //+NPR5.49 [342811]
    end;

    procedure "--- Filter"()
    begin
    end;

    local procedure SetSaleLinePOSVoucherFilter(SaleLinePOS: Record "Sale Line POS";var SaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher")
    begin
        Clear(SaleLinePOSVoucher);
        SaleLinePOSVoucher.SetRange("Register No.",SaleLinePOS."Register No.");
        SaleLinePOSVoucher.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
        SaleLinePOSVoucher.SetRange("Sale Type",SaleLinePOS."Sale Type");
        SaleLinePOSVoucher.SetRange("Sale Date",SaleLinePOS.Date);
        SaleLinePOSVoucher.SetRange("Sale Line No.",SaleLinePOS."Line No.");
    end;

    procedure SetSaleLinePOSReferenceFilter(SaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher";var SaleLinePOSReference: Record "NpRv Sale Line POS Reference")
    begin
        SaleLinePOSReference.SetRange("Register No.",SaleLinePOSVoucher."Register No.");
        SaleLinePOSReference.SetRange("Sales Ticket No.",SaleLinePOSVoucher."Sales Ticket No.");
        SaleLinePOSReference.SetRange("Sale Type",SaleLinePOSVoucher."Sale Type");
        SaleLinePOSReference.SetRange("Sale Date",SaleLinePOSVoucher."Sale Date");
        SaleLinePOSReference.SetRange("Sale Line No.",SaleLinePOSVoucher."Sale Line No.");
        SaleLinePOSReference.SetRange("Voucher Line No.",SaleLinePOSVoucher."Line No.");
    end;

    local procedure "--- Generate Reference No"()
    begin
    end;

    procedure GenerateTempVoucher(VoucherType: Record "NpRv Voucher Type";var TempVoucher: Record "NpRv Voucher" temporary)
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        //-NPR5.54 [372135]
        TempVoucher.Init;
        TempVoucher."No." := '';
        TempVoucher.Validate("Voucher Type",VoucherType.Code);
        if VoucherType."No. Series" <> '' then begin
          NoSeriesMgt.InitSeries(TempVoucher."No. Series",'',0D,TempVoucher."No.",TempVoucher."No. Series");
          TempVoucher.Description := CopyStr(VoucherType.Description + ' ' + TempVoucher."No.",1,MaxStrLen(TempVoucher.Description));
        end;
        TempVoucher."Reference No." := GenerateReferenceNo(TempVoucher);
        //9+NPR5.54 [372135]
    end;

    procedure GenerateReferenceNo(Voucher: Record "NpRv Voucher") ReferenceNo: Text
    var
        Voucher2: Record "NpRv Voucher";
        VoucherType: Record "NpRv Voucher Type";
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

    local procedure GenerateReferenceNoPattern(Voucher: Record "NpRv Voucher") ReferenceNo: Text
    var
        Voucher2: Record "NpRv Voucher";
        VoucherType: Record "NpRv Voucher Type";
        i: Integer;
    begin
        VoucherType.Get(Voucher."Voucher Type");
        if VoucherType."Reference No. Type" <> VoucherType."Reference No. Type"::Pattern then
          exit('');

        for i := 1 to 100 do begin
          ReferenceNo := VoucherType."Reference No. Pattern";
          ReferenceNo := RegExReplaceN(ReferenceNo);
          ReferenceNo := RegExReplaceAN(ReferenceNo);
          ReferenceNo := RegExReplaceS(ReferenceNo,Voucher."No.");
          ReferenceNo := UpperCase(CopyStr(ReferenceNo,1,MaxStrLen(Voucher."Reference No.")));

          Voucher2.SetFilter("No.",'<>%1',Voucher."No.");
          Voucher2.SetRange("Reference No.",ReferenceNo);
          if Voucher2.IsEmpty then
            exit(ReferenceNo);

          if ReferenceNo = VoucherType."Reference No. Pattern" then
            exit(ReferenceNo);
        end;

        exit(ReferenceNo);
    end;

    local procedure GenerateReferenceNoEAN13(Voucher: Record "NpRv Voucher") ReferenceNo: Text
    var
        Voucher2: Record "NpRv Voucher";
        VoucherType: Record "NpRv Voucher Type";
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
          ReferenceNo := RegExReplaceS(ReferenceNo,Voucher."No.");
          ReferenceNo := UpperCase(CopyStr(ReferenceNo,1,MaxStrLen(Voucher."Reference No.")));
          if StrLen(ReferenceNo) < 12 then
            ReferenceNo := CopyStr(ReferenceNo,1,2) + PadStr('',12 - StrLen(ReferenceNo),'0') + CopyStr(ReferenceNo,3);
          if StrLen(ReferenceNo) > 12 then
            Error(Text000,ReferenceNo);
          if not TryGetCheckSum(ReferenceNo,CheckSum) then
            Error(Text000,ReferenceNo);
          ReferenceNo := ReferenceNo + Format(CheckSum);

          Voucher2.SetFilter("No.",'<>%1',Voucher."No.");
          Voucher2.SetRange("Reference No.",ReferenceNo);
          if Voucher2.IsEmpty then
            exit(ReferenceNo);

          if ReferenceNo = VoucherType."Reference No. Pattern" then
            exit(ReferenceNo);
        end;

        exit(ReferenceNo);
    end;

    [TryFunction]
    local procedure TryGetCheckSum(ReferenceNo: Text;var CheckSum: Integer)
    begin
        CheckSum := StrCheckSum(ReferenceNo,'131313131313');
    end;

    local procedure RegExReplaceAN(Input: Text) Output: Text
    var
        Match: DotNet npNetMatch;
        RegEx: DotNet npNetRegex;
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
          if Evaluate(RandomQty,Format(Match.Groups.Item('RandomQty'))) then;
          for i := 1 to RandomQty do
            ReplaceString += Format(GenerateRandomChar());
          Input := RegEx.Replace(Input,ReplaceString,1);

          Match := RegEx.Match(Input);
        end;

        Output := Input;
        exit(Output);
    end;

    local procedure RegExReplaceN(Input: Text) Output: Text
    var
        Match: DotNet npNetMatch;
        RegEx: DotNet npNetRegex;
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
          if Evaluate(RandomQty,Format(Match.Groups.Item('RandomQty'))) then;
          for i := 1 to RandomQty do
            ReplaceString += Format(Random(9));
          Input := RegEx.Replace(Input,ReplaceString,1);

          Match := RegEx.Match(Input);
        end;

        Output := Input;
        exit(Output);
    end;

    local procedure RegExReplaceS(Input: Text;SerialNo: Text) Output: Text
    var
        Match: DotNet npNetMatch;
        RegEx: DotNet npNetRegex;
        Pattern: Text;
    begin
        Pattern := '(?<SerialNo>\[S\])';
        RegEx := RegEx.Regex(Pattern);
        Output := RegEx.Replace(Input,SerialNo);
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
    local procedure OnBeforeInsertIssuedVoucher(var Voucher: Record "NpRv Voucher";SaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher")
    begin
        //-+NPR5.50 [356003]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertIssuedVoucherEntry(var VoucherEntry: Record "NpRv Voucher Entry";Voucher: Record "NpRv Voucher";SaleLinePOS: Record "Sale Line POS")
    begin
        //-+NPR5.50 [356003]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPaymentVoucherEntry(var VoucherEntry: Record "NpRv Voucher Entry";SaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher")
    begin
        //-+NPR5.50 [356003]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertArchiveEntry(var ArchVoucherEntry: Record "NpRv Arch. Voucher Entry";NpRvVoucherEntry: Record "NpRv Voucher Entry")
    begin
        //-+NPR5.50 [356003]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostPartnerIssueVoucher(var SaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher")
    begin
        //-+NPR5.50 [356003]
    end;
}

