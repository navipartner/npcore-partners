codeunit 6151021 "NPR NpRv Ext. Voucher WS"
{
    var
        Text000: Label 'Invalid Reference No. %1';
        Text001: Label 'Voucher %1 is already in use';
        Text003: Label 'Voucher %1 has already been used';
        Text004: Label 'Voucher %1 is not valid yet';
        Text005: Label 'Voucher %1 is not valid anymore';
        Text006: Label 'Voucher %1 is reserved on different document_no';
        Text007: Label 'Voucher %1 is being used on Sales Order %2';

    procedure CheckVouchers(var vouchers: XMLport "NPR NpRv Ext. Vouchers")
    var
        TempNpRvExtVoucherBuffer: Record "NPR NpRv Ext. Voucher Buffer" temporary;
    begin
        SetGlobalLanguage(UserId);

        vouchers.Import();
        vouchers.GetSourceTable(TempNpRvExtVoucherBuffer);
        if TempNpRvExtVoucherBuffer.IsEmpty then
            exit;

        TempNpRvExtVoucherBuffer.FindSet();
        repeat
            CheckVoucher(TempNpRvExtVoucherBuffer);
        until TempNpRvExtVoucherBuffer.Next() = 0;
    end;

    local procedure CheckVoucher(var NpRvExtVoucherBuffer: Record "NPR NpRv Ext. Voucher Buffer" temporary)
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
    begin
        if not FindVoucher(NpRvExtVoucherBuffer."Voucher Type", NpRvExtVoucherBuffer."Reference No.", NpRvVoucher) then
            Error(Text000, NpRvExtVoucherBuffer."Reference No.");

        Voucher2Buffer(NpRvVoucher, NpRvExtVoucherBuffer);
    end;

    procedure GetVouchersByCustomerNo(CustomerNo: Text; var vouchers: XMLport "NPR NpRv Ext. Vouchers")
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        TempNpRvExtVoucherBuffer: Record "NPR NpRv Ext. Voucher Buffer" temporary;
        DocNo: Text[50];
        LineNo: Integer;
    begin
        Clear(vouchers);
        if StrLen(CustomerNo) > MaxStrLen(NpRvVoucher."Customer No.") then
            exit;

        DocNo := CreateGuid();
        NpRvVoucher.SetRange("Customer No.", UpperCase(CustomerNo));
        if NpRvVoucher.FindSet() then
            repeat
                LineNo += 10000;

                TempNpRvExtVoucherBuffer.Init();
                TempNpRvExtVoucherBuffer."Document No." := DocNo;
                TempNpRvExtVoucherBuffer."Line No." := LineNo;
                TempNpRvExtVoucherBuffer.Insert();
                Voucher2Buffer(NpRvVoucher, TempNpRvExtVoucherBuffer);
            until NpRvVoucher.Next() = 0;

        vouchers.SetSourceTable(TempNpRvExtVoucherBuffer);
    end;

    procedure GetVouchersByEmail(Email: Text; var vouchers: XMLport "NPR NpRv Ext. Vouchers")
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        TempNpRvExtVoucherBuffer: Record "NPR NpRv Ext. Voucher Buffer" temporary;
        DocNo: Text[50];
        LineNo: Integer;
    begin
        Clear(vouchers);
        if StrLen(Email) > MaxStrLen(NpRvVoucher."E-mail") then
            exit;

        DocNo := CreateGuid();
        NpRvVoucher.SetFilter("E-mail", '@' + ConvertStr(Email, '@', '?'));
        if NpRvVoucher.FindSet() then
            repeat
                LineNo += 10000;

                TempNpRvExtVoucherBuffer.Init();
                TempNpRvExtVoucherBuffer."Document No." := DocNo;
                TempNpRvExtVoucherBuffer."Line No." := LineNo;
                TempNpRvExtVoucherBuffer.Insert();
                Voucher2Buffer(NpRvVoucher, TempNpRvExtVoucherBuffer);
            until NpRvVoucher.Next() = 0;

        vouchers.SetSourceTable(TempNpRvExtVoucherBuffer);
    end;

    procedure CreateVouchers(var vouchers: XMLport "NPR NpRv Ext. Vouchers")
    var
        TempNpRvExtVoucherBuffer: Record "NPR NpRv Ext. Voucher Buffer" temporary;
    begin
        vouchers.Import();
        vouchers.GetSourceTable(TempNpRvExtVoucherBuffer);

        if TempNpRvExtVoucherBuffer.IsEmpty then
            exit;

        TempNpRvExtVoucherBuffer.FindSet();
        repeat
            CreateVoucher(TempNpRvExtVoucherBuffer);
        until TempNpRvExtVoucherBuffer.Next() = 0;
    end;

    local procedure CreateVoucher(var NpRvExtVoucherBuffer: Record "NPR NpRv Ext. Voucher Buffer" temporary)
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvSalesLineReference: Record "NPR NpRv Sales Line Ref.";
        TempNpRvVoucher: Record "NPR NpRv Voucher" temporary;
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        NpRvSalesLine.SetRange("External Document No.", NpRvExtVoucherBuffer."Document No.");
        NpRvSalesLine.SetRange("Reference No.", NpRvExtVoucherBuffer."Reference No.");
        if NpRvSalesLine.FindFirst() then begin
            VoucherSalesLine2Buffer(NpRvSalesLine, NpRvExtVoucherBuffer);
            exit;
        end;

        if NpRvExtVoucherBuffer."Reference No." <> '' then begin
            if FindVoucher(NpRvExtVoucherBuffer."Voucher Type", NpRvExtVoucherBuffer."Reference No.", NpRvVoucher) then begin
                NpRvVoucher.TestField("Allow Top-up");
                Voucher2Buffer(NpRvVoucher, NpRvExtVoucherBuffer);

                NpRvSalesLine.Init();
                NpRvSalesLine.Id := CreateGuid();
                NpRvSalesLine.Type := NpRvSalesLine.Type::"Top-up";
                NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
                NpRvSalesLine."External Document No." := NpRvExtVoucherBuffer."Document No.";
                Buffer2VoucherSalesLine(NpRvExtVoucherBuffer, NpRvSalesLine);
                NpRvSalesLine."Voucher No." := NpRvVoucher."No.";
                NpRvSalesLine."Reference No." := NpRvVoucher."Reference No.";
                NpRvSalesLine."Voucher Type" := NpRvVoucher."Voucher Type";
                NpRvSalesLine.Description := NpRvVoucher.Description;
                NpRvSalesLine.Insert(true);

                exit;
            end;
            if FindSalesVoucher(NpRvExtVoucherBuffer."Voucher Type", NpRvExtVoucherBuffer."Reference No.", NpRvSalesLine) then begin
                VoucherSalesLine2Buffer(NpRvSalesLine, NpRvExtVoucherBuffer);
                exit;
            end;
        end;

        NpRvExtVoucherBuffer.TestField("Voucher Type");
        NpRvVoucherType.Get(NpRvExtVoucherBuffer."Voucher Type");
        NpRvVoucherMgt.GenerateTempVoucher(NpRvVoucherType, TempNpRvVoucher);
        Buffer2Voucher(NpRvExtVoucherBuffer, TempNpRvVoucher);
        TempNpRvVoucher.Insert();

        NpRvSalesLine.Init();
        NpRvSalesLine.Id := CreateGuid();
        NpRvSalesLine.Type := NpRvSalesLine.Type::"New Voucher";
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
        NpRvSalesLine."External Document No." := NpRvExtVoucherBuffer."Document No.";
        Buffer2VoucherSalesLine(NpRvExtVoucherBuffer, NpRvSalesLine);
        NpRvSalesLine."Voucher No." := TempNpRvVoucher."No.";
        NpRvSalesLine."Reference No." := TempNpRvVoucher."Reference No.";
        NpRvSalesLine."Voucher Type" := TempNpRvVoucher."Voucher Type";
        NpRvSalesLine.Description := TempNpRvVoucher.Description;
        NpRvSalesLine.Insert(true);

        NpRvSalesLineReference.Init();
        NpRvSalesLineReference.Id := CreateGuid();
        NpRvSalesLineReference."Voucher No." := TempNpRvVoucher."No.";
        NpRvSalesLineReference."Reference No." := TempNpRvVoucher."Reference No.";
        NpRvSalesLineReference."Sales Line Id" := NpRvSalesLine.Id;
        NpRvSalesLineReference.Insert(true);

        VoucherSalesLine2Buffer(NpRvSalesLine, NpRvExtVoucherBuffer);
    end;

    procedure ReserveVouchers(var vouchers: XMLport "NPR NpRv Ext. Vouchers")
    var
        TempNpRvExtVoucherBuffer: Record "NPR NpRv Ext. Voucher Buffer" temporary;
    begin
        SetGlobalLanguage(UserId);

        vouchers.Import();
        vouchers.GetSourceTable(TempNpRvExtVoucherBuffer);

        if TempNpRvExtVoucherBuffer.IsEmpty then
            exit;

        TempNpRvExtVoucherBuffer.FindSet();
        repeat
            ReserveVoucher(TempNpRvExtVoucherBuffer);
        until TempNpRvExtVoucherBuffer.Next() = 0;
    end;

    local procedure ReserveVoucher(var NpRvExtVoucherBuffer: Record "NPR NpRv Ext. Voucher Buffer" temporary)
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Timestamp: DateTime;
        InUseQty: Integer;
    begin
        if not FindVoucher(NpRvExtVoucherBuffer."Voucher Type", NpRvExtVoucherBuffer."Reference No.", NpRvVoucher) then
            Error(Text000, NpRvExtVoucherBuffer."Reference No.");

        NpRvVoucher.CalcFields(Open);
        if not NpRvVoucher.Open then
            Error(Text003, NpRvExtVoucherBuffer."Reference No.");

        InUseQty := NpRvVoucher.CalcInUseQty();
        if InUseQty > 0 then begin
            NpRvSalesLine.SetRange("External Document No.", NpRvExtVoucherBuffer."Document No.");
            NpRvSalesLine.SetRange("Voucher Type", NpRvVoucher."Voucher Type");
            NpRvSalesLine.SetRange("Voucher No.", NpRvVoucher."No.");
            if InUseQty = NpRvSalesLine.Count() then begin
                Voucher2Buffer(NpRvVoucher, NpRvExtVoucherBuffer);
                exit;
            end;

            Error(Text001, NpRvExtVoucherBuffer."Reference No.");
        end;

        Timestamp := CurrentDateTime;
        if NpRvVoucher."Starting Date" > Timestamp then
            Error(Text004, NpRvExtVoucherBuffer."Reference No.");

        if (NpRvVoucher."Ending Date" < Timestamp) and (NpRvVoucher."Ending Date" <> 0DT) then
            Error(Text005, NpRvExtVoucherBuffer."Reference No.");

        NpRvSalesLine.Init();
        NpRvSalesLine.Id := CreateGuid();
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
        NpRvSalesLine."External Document No." := NpRvExtVoucherBuffer."Document No.";
        NpRvSalesLine.Type := NpRvSalesLine.Type::Payment;
        NpRvSalesLine."Voucher Type" := NpRvVoucher."Voucher Type";
        NpRvSalesLine."Voucher No." := NpRvVoucher."No.";
        NpRvSalesLine."Reference No." := NpRvExtVoucherBuffer."Reference No.";
        NpRvSalesLine.Description := NpRvVoucher.Description;
        NpRvSalesLine.Insert();

        Voucher2Buffer(NpRvVoucher, NpRvExtVoucherBuffer);
    end;

    procedure CancelVoucherReservations(var vouchers: XMLport "NPR NpRv Ext. Vouchers")
    var
        TempNpRvExtVoucherBuffer: Record "NPR NpRv Ext. Voucher Buffer" temporary;
    begin
        SetGlobalLanguage(UserId);

        vouchers.Import();
        vouchers.GetSourceTable(TempNpRvExtVoucherBuffer);
        if TempNpRvExtVoucherBuffer.IsEmpty then
            exit;

        TempNpRvExtVoucherBuffer.FindSet();
        repeat
            CancelVoucherReservation(TempNpRvExtVoucherBuffer);
        until TempNpRvExtVoucherBuffer.Next() = 0;
    end;

    local procedure CancelVoucherReservation(var NpRvExtVoucherBuffer: Record "NPR NpRv Ext. Voucher Buffer" temporary)
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        if not FindVoucher(NpRvExtVoucherBuffer."Voucher Type", NpRvExtVoucherBuffer."Reference No.", NpRvVoucher) then
            Error(Text000, NpRvExtVoucherBuffer."Reference No.");

        NpRvSalesLine.SetRange("Reference No.", NpRvExtVoucherBuffer."Reference No.");
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::Payment);
        if NpRvSalesLine.FindSet() then
            repeat
                if NpRvSalesLine."External Document No." <> NpRvExtVoucherBuffer."Document No." then
                    Error(Text006, NpRvExtVoucherBuffer."Reference No.");
                if NpRvSalesLine."Document No." <> '' then
                    Error(Text007, NpRvExtVoucherBuffer."Reference No.", NpRvSalesLine."Document No.");
                NpRvSalesLine.Delete();
            until NpRvSalesLine.Next() = 0;

        Voucher2Buffer(NpRvVoucher, NpRvExtVoucherBuffer);
    end;

    procedure FindVoucher(VoucherTypeFilter: Text; ReferenceNo: Text[50]; var Voucher: Record "NPR NpRv Voucher"): Boolean
    begin
        if ReferenceNo = '' then
            exit(false);

        Voucher.SetFilter("Voucher Type", UpperCase(VoucherTypeFilter));
        Voucher.SetRange("Reference No.", ReferenceNo);
        if Voucher.FindLast() then
            exit(true);

        Voucher.SetRange("Voucher Type");
        exit(Voucher.FindLast());
    end;

    procedure FindSalesVoucher(VoucherTypeFilter: Text; ReferenceNo: Text[50]; var NpRvSalesLine: Record "NPR NpRv Sales Line"): Boolean
    begin
        NpRvSalesLine.SetFilter("Voucher Type", UpperCase(VoucherTypeFilter));
        NpRvSalesLine.SetRange("Reference No.", ReferenceNo);
        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Sales Document");
        exit(NpRvSalesLine.FindLast());
    end;

    local procedure Voucher2Buffer(var NpRvVoucher: Record "NPR NpRv Voucher"; var NpRvExtVoucherBuffer: Record "NPR NpRv Ext. Voucher Buffer")
    begin
        NpRvVoucher.CalcFields(Amount, "Issue Date", "Issue Register No.", "Issue Document No.", "Issue User ID");
        NpRvVoucher.CalcFields(Open);
        NpRvExtVoucherBuffer."Reference No." := NpRvVoucher."Reference No.";
        NpRvExtVoucherBuffer."Voucher Type" := NpRvVoucher."Voucher Type";
        NpRvExtVoucherBuffer.Description := NpRvVoucher.Description;
        NpRvExtVoucherBuffer."Starting Date" := NpRvVoucher."Starting Date";
        NpRvExtVoucherBuffer."Ending Date" := NpRvVoucher."Ending Date";
        NpRvExtVoucherBuffer."Account No." := NpRvVoucher."Account No.";
        NpRvExtVoucherBuffer."Allow Top-up" := NpRvVoucher."Allow Top-up";
        NpRvExtVoucherBuffer.Open := NpRvVoucher.Open;
        NpRvExtVoucherBuffer."In-use Quantity" := NpRvVoucher.CalcInUseQty();
        NpRvExtVoucherBuffer.Amount := NpRvVoucher.Amount;
        NpRvExtVoucherBuffer.Name := NpRvVoucher.Name;
        NpRvExtVoucherBuffer."Name 2" := NpRvVoucher."Name 2";
        NpRvExtVoucherBuffer.Address := NpRvVoucher.Address;
        NpRvExtVoucherBuffer."Address 2" := NpRvVoucher."Address 2";
        NpRvExtVoucherBuffer."Post Code" := NpRvVoucher."Post Code";
        NpRvExtVoucherBuffer.City := NpRvVoucher.City;
        NpRvExtVoucherBuffer.County := NpRvVoucher.County;
        NpRvExtVoucherBuffer."Country/Region Code" := NpRvVoucher."Country/Region Code";
        NpRvExtVoucherBuffer."E-mail" := NpRvVoucher."E-mail";
        NpRvExtVoucherBuffer."Phone No." := NpRvVoucher."Phone No.";
        NpRvExtVoucherBuffer."Send via Print" := NpRvVoucher."Send via Print";
        NpRvExtVoucherBuffer."Send via E-mail" := NpRvVoucher."Send via E-mail";
        NpRvExtVoucherBuffer."Send via SMS" := NpRvVoucher."Send via SMS";
        NpRvExtVoucherBuffer."Voucher Message" := NpRvVoucher."Voucher Message";
        NpRvExtVoucherBuffer."Issue Date" := NpRvVoucher."Issue Date";
        NpRvExtVoucherBuffer."Issue Register No." := NpRvVoucher."Issue Register No.";
        NpRvExtVoucherBuffer."Issue Sales Ticket No." := NpRvVoucher."Issue Document No.";
        NpRvExtVoucherBuffer."Issue User ID" := NpRvVoucher."Issue User ID";
        NpRvExtVoucherBuffer.Modify();
    end;

    local procedure Buffer2VoucherSalesLine(var NpRvExtVoucherBuffer: Record "NPR NpRv Ext. Voucher Buffer"; var NpRvSalesLine: Record "NPR NpRv Sales Line")
    begin
        NpRvSalesLine.Name := NpRvExtVoucherBuffer.Name;
        NpRvSalesLine."Name 2" := NpRvExtVoucherBuffer."Name 2";
        NpRvSalesLine.Address := NpRvExtVoucherBuffer.Address;
        NpRvSalesLine."Address 2" := NpRvExtVoucherBuffer."Address 2";
        NpRvSalesLine."Post Code" := NpRvExtVoucherBuffer."Post Code";
        NpRvSalesLine.City := NpRvExtVoucherBuffer.City;
        NpRvSalesLine.County := NpRvExtVoucherBuffer.County;
        NpRvSalesLine."Country/Region Code" := NpRvExtVoucherBuffer."Country/Region Code";
        NpRvSalesLine."E-mail" := NpRvExtVoucherBuffer."E-mail";
        NpRvSalesLine."Phone No." := NpRvExtVoucherBuffer."Phone No.";
        NpRvSalesLine."Send via Print" := NpRvExtVoucherBuffer."Send via Print";
        NpRvSalesLine."Send via E-mail" := NpRvExtVoucherBuffer."Send via E-mail";
        NpRvSalesLine."Send via SMS" := NpRvExtVoucherBuffer."Send via SMS";
        if (not NpRvSalesLine."Send via Print") and (not NpRvSalesLine."Send via SMS") and (NpRvSalesLine."E-mail" <> '') then
            NpRvSalesLine."Send via E-mail" := true;
        if NpRvExtVoucherBuffer."Voucher Message" <> '' then
            NpRvSalesLine."Voucher Message" := NpRvExtVoucherBuffer."Voucher Message";
    end;

    local procedure VoucherSalesLine2Buffer(var NpRvSalesLine: Record "NPR NpRv Sales Line"; var NpRvExtVoucherBuffer: Record "NPR NpRv Ext. Voucher Buffer")
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
    begin
        NpRvVoucherType.Get(NpRvSalesLine."Voucher Type");

        NpRvExtVoucherBuffer."Reference No." := NpRvSalesLine."Reference No.";
        NpRvExtVoucherBuffer."Voucher Type" := NpRvSalesLine."Voucher Type";
        NpRvExtVoucherBuffer.Description := NpRvSalesLine.Description;
        NpRvExtVoucherBuffer."Starting Date" := NpRvSalesLine."Starting Date";
        NpRvExtVoucherBuffer."Ending Date" := 0DT;
        NpRvExtVoucherBuffer."Account No." := NpRvVoucherType."Account No.";
        NpRvExtVoucherBuffer."Allow Top-up" := NpRvVoucherType."Allow Top-up";
        NpRvExtVoucherBuffer.Open := false;
        NpRvExtVoucherBuffer."In-use Quantity" := 0;
        NpRvExtVoucherBuffer.Amount := 0;
        NpRvExtVoucherBuffer.Name := NpRvSalesLine.Name;
        NpRvExtVoucherBuffer."Name 2" := NpRvSalesLine."Name 2";
        NpRvExtVoucherBuffer.Address := NpRvSalesLine.Address;
        NpRvExtVoucherBuffer."Address 2" := NpRvSalesLine."Address 2";
        NpRvExtVoucherBuffer."Post Code" := NpRvSalesLine."Post Code";
        NpRvExtVoucherBuffer.City := NpRvSalesLine.City;
        NpRvExtVoucherBuffer.County := NpRvSalesLine.County;
        NpRvExtVoucherBuffer."Country/Region Code" := NpRvSalesLine."Country/Region Code";
        NpRvExtVoucherBuffer."E-mail" := NpRvSalesLine."E-mail";
        NpRvExtVoucherBuffer."Phone No." := NpRvSalesLine."Phone No.";
        NpRvExtVoucherBuffer."Send via Print" := NpRvSalesLine."Send via Print";
        NpRvExtVoucherBuffer."Send via E-mail" := NpRvSalesLine."Send via E-mail";
        NpRvExtVoucherBuffer."Send via SMS" := NpRvSalesLine."Send via SMS";
        NpRvExtVoucherBuffer."Voucher Message" := NpRvSalesLine."Voucher Message";
        NpRvExtVoucherBuffer."Issue Date" := 0D;
        NpRvExtVoucherBuffer."Issue Register No." := '';
        NpRvExtVoucherBuffer."Issue Sales Ticket No." := '';
        NpRvExtVoucherBuffer."Issue User ID" := '';
        NpRvExtVoucherBuffer.Modify();
    end;

    local procedure Buffer2Voucher(var NpRvExtVoucherBuffer: Record "NPR NpRv Ext. Voucher Buffer"; var NpRvVoucher: Record "NPR NpRv Voucher")
    begin
        NpRvVoucher.Name := NpRvExtVoucherBuffer.Name;
        NpRvVoucher."Name 2" := NpRvExtVoucherBuffer."Name 2";
        NpRvVoucher.Address := NpRvExtVoucherBuffer.Address;
        NpRvVoucher."Address 2" := NpRvExtVoucherBuffer."Address 2";
        NpRvVoucher."Post Code" := NpRvExtVoucherBuffer."Post Code";
        NpRvVoucher.City := NpRvExtVoucherBuffer.City;
        NpRvVoucher.County := NpRvExtVoucherBuffer.County;
        NpRvVoucher."Country/Region Code" := NpRvExtVoucherBuffer."Country/Region Code";
        NpRvVoucher."E-mail" := NpRvExtVoucherBuffer."E-mail";
        NpRvVoucher."Phone No." := NpRvExtVoucherBuffer."Phone No.";
        NpRvVoucher."Send via Print" := NpRvExtVoucherBuffer."Send via Print";
        NpRvVoucher."Send via E-mail" := NpRvExtVoucherBuffer."Send via E-mail";
        NpRvVoucher."Send via SMS" := NpRvExtVoucherBuffer."Send via SMS";
        if (not NpRvVoucher."Send via Print") and (not NpRvVoucher."Send via SMS") and (NpRvVoucher."E-mail" <> '') then
            NpRvVoucher."Send via E-mail" := true;
        if NpRvExtVoucherBuffer."Voucher Message" <> '' then
            NpRvVoucher."Voucher Message" := NpRvExtVoucherBuffer."Voucher Message";
    end;

    local procedure SetGlobalLanguage(LanguageUsername: Text)
    var
        User: Record User;
        UserPersonalization: Record "User Personalization";
    begin
        User.SetRange("User Name", LanguageUsername);
        if not User.FindFirst() then
            exit;

        if not UserPersonalization.Get(User."User Security ID") then
            exit;

        if UserPersonalization."Language ID" > 0 then
            GlobalLanguage(UserPersonalization."Language ID");
    end;
}

