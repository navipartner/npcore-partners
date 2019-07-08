codeunit 6151080 "ExRv Management"
{
    // NPR5.40/MHA /20180212  CASE 301346 Object created - External Retail Voucher


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Amount must be greater than 0.';

    local procedure "--- Issue Voucher"()
    begin
    end;

    procedure IssueVoucher(var TempExRvVoucher: Record "ExRv Voucher"): Boolean
    var
        ExRvVoucherType: Record "ExRv Voucher Type";
        ExRvVoucher: Record "ExRv Voucher";
        PrevVoucher: Text;
    begin
        if ExRvVoucher.Get(TempExRvVoucher."Voucher Type",TempExRvVoucher."No.") then begin
          PrevVoucher := Format(ExRvVoucher);

          UpdateIsOpen(ExRvVoucher);

          if Format(ExRvVoucher) <> PrevVoucher then
            ExRvVoucher.Modify;

          TempExRvVoucher := ExRvVoucher;
          TempExRvVoucher.Modify;
          exit;
        end;

        if TempExRvVoucher.Amount <= 0 then
          Error(Text000);

        ExRvVoucherType.Get(TempExRvVoucher."Voucher Type");

        case ExRvVoucherType."Source Type" of
          ExRvVoucherType."Source Type"::"Gift Voucher":
            IssueGiftVoucher(ExRvVoucherType,TempExRvVoucher);
        end;

        ExRvVoucher.Init;
        ExRvVoucher := TempExRvVoucher;
        ExRvVoucher.Insert(true);

        if ExRvVoucherType."Direct Posting" then
          PostVoucher(ExRvVoucher);

        TempExRvVoucher := ExRvVoucher;
        TempExRvVoucher.Modify;
    end;

    local procedure IssueGiftVoucher(ExRvVoucherType: Record "ExRv Voucher Type";var TempExRvVoucher: Record "ExRv Voucher")
    var
        GiftVoucher: Record "Gift Voucher";
    begin
        TempExRvVoucher.TestField("Voucher Type",ExRvVoucherType.Code);
        ExRvVoucherType.TestField("Source Type",ExRvVoucherType."Source Type"::"Gift Voucher");

        GiftVoucher.Init;
        GiftVoucher."No." := '';
        GiftVoucher."Issue Date" := Today;
        GiftVoucher.Status := GiftVoucher.Status::Open;
        GiftVoucher.Amount := TempExRvVoucher.Amount;
        GiftVoucher.Validate("Customer No.",ExRvVoucherType."Customer No.");
        GiftVoucher."External No." := TempExRvVoucher."No.";
        GiftVoucher.Insert(true);

        TempExRvVoucher."Issued at" := CurrentDateTime;
        TempExRvVoucher."Source Type" := TempExRvVoucher."Source Type"::"Gift Voucher";
        TempExRvVoucher."Source No." := GiftVoucher."No.";
        TempExRvVoucher."Reference No." := GiftVoucher."No.";
        TempExRvVoucher."Online Reference No." := GiftVoucher."External Reference No.";
        TempExRvVoucher.Open := true;
        TempExRvVoucher."Remaining Amount" := TempExRvVoucher.Amount;
        TempExRvVoucher."Posting Date" := Today;
        TempExRvVoucher.Posted := false;
        TempExRvVoucher."Shortcut Dimension 1 Code" := ExRvVoucherType."Shortcut Dimension 1 Code";
        TempExRvVoucher."Shortcut Dimension 2 Code" := ExRvVoucherType."Shortcut Dimension 2 Code";
        TempExRvVoucher."Dimension Set ID" := ExRvVoucherType."Dimension Set ID";
        TempExRvVoucher.Modify;
    end;

    local procedure "--- Status"()
    begin
    end;

    procedure UpdateIsOpen(var ExRvVoucher: Record "ExRv Voucher")
    var
        GiftVoucher: Record "Gift Voucher";
    begin
        if not ExRvVoucher.Open then
          exit;

        case ExRvVoucher."Source Type" of
          ExRvVoucher."Source Type"::"Gift Voucher":
            begin
              ExRvVoucher.Open := GiftVoucher.Get(ExRvVoucher."Source No.") and (GiftVoucher.Status = GiftVoucher.Status::Open);
              if not ExRvVoucher.Open then begin
                ExRvVoucher."Remaining Amount" := 0;
                ExRvVoucher."Closed at" := GiftVoucher."Cashed Date";
              end;
            end;
        end;
    end;

    procedure UpdateIsOpenVouchers(ExRvVoucherType: Record "ExRv Voucher Type")
    var
        ExRvVoucher: Record "ExRv Voucher";
        PrevVoucher: Text;
    begin
        ExRvVoucher.SetRange("Voucher Type",ExRvVoucherType.Code);
        if not ExRvVoucher.FindSet then
          exit;

        repeat
          PrevVoucher := Format(ExRvVoucher);

          UpdateIsOpen(ExRvVoucher);

          if Format(ExRvVoucher) <> PrevVoucher then
            ExRvVoucher.Modify;
        until ExRvVoucher.Next = 0;
    end;

    local procedure "--- Post"()
    begin
    end;

    procedure PostVouchers(var ExRvVoucher: Record "ExRv Voucher")
    var
        ExRvVoucher2: Record "ExRv Voucher";
    begin
        ExRvVoucher2.Copy(ExRvVoucher);
        ExRvVoucher2.FilterGroup(40);
        ExRvVoucher2.SetRange(Posted,false);
        if ExRvVoucher2.IsEmpty then
          exit;

        ExRvVoucher2.FindSet;
        repeat
          PostVoucher(ExRvVoucher2);
        until ExRvVoucher2.Next = 0;
    end;

    procedure PostVoucher(var ExRvVoucher: Record "ExRv Voucher")
    var
        TempGenJnlLine: Record "Gen. Journal Line" temporary;
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        if ExRvVoucher.Posted then
          exit;

        if ExRvVoucher."Posting Date" = 0D then
          ExRvVoucher."Posting Date" := Today;

        ExRvVoucher.Posted := true;
        ExRvVoucher.Modify;

        SetupGenJnlLine(ExRvVoucher,TempGenJnlLine);
        GenJnlPostLine.RunWithCheck(TempGenJnlLine);
    end;

    local procedure SetupGenJnlLine(ExRvVoucher: Record "ExRv Voucher";var GenJnlLine: Record "Gen. Journal Line")
    var
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
        ExRvVoucherType: Record "ExRv Voucher Type";
        GiftVoucher: Record "Gift Voucher";
        SourceCodeSetup: Record "Source Code Setup";
        SourceCode: Code[10];
    begin
        ExRvVoucherType.Get(ExRvVoucher."Voucher Type");
        ExRvVoucherType.TestField("Customer No.");
        Customer.Get(ExRvVoucherType."Customer No.");
        Customer.TestField("Customer Posting Group");
        CustomerPostingGroup.Get(Customer."Customer Posting Group");
        CustomerPostingGroup.TestField("Receivables Account");

        SourceCodeSetup.Get;
        SourceCode := SourceCodeSetup.Sales;

        GenJnlLine.Init;
        GenJnlLine."Posting Date" := ExRvVoucher."Posting Date";
        GenJnlLine."Document Date" := DT2Date(ExRvVoucher."Issued at");
        GenJnlLine.Description := ExRvVoucherType.Description;
        GenJnlLine."Shortcut Dimension 1 Code" := ExRvVoucher."Shortcut Dimension 1 Code";
        GenJnlLine."Shortcut Dimension 2 Code" := ExRvVoucher."Shortcut Dimension 2 Code";
        GenJnlLine."Dimension Set ID" := ExRvVoucher."Dimension Set ID";
        GenJnlLine."Reason Code" := '';
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine."Account No." := ExRvVoucherType."Account No.";
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::" ";
        GenJnlLine."Document No." := ExRvVoucher."Source No.";
        GenJnlLine."External Document No." := ExRvVoucher."No.";
        GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::Customer;
        GenJnlLine."Bal. Account No." := ExRvVoucherType."Customer No.";
        GenJnlLine."Currency Code" := '';
        GenJnlLine.Amount := -ExRvVoucher.Amount;
        GenJnlLine."Source Currency Code" := '';
        GenJnlLine."Source Currency Amount" := GenJnlLine.Amount;
        GenJnlLine.Correction := false;
        GenJnlLine."Currency Factor" := 1;
        GenJnlLine.Validate(Amount);
        GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::" ";
        GenJnlLine."Applies-to Doc. No." := '';
        GenJnlLine."Source Type" := GenJnlLine."Source Type"::Customer;
        GenJnlLine."Source No." := ExRvVoucherType."Customer No.";
        GenJnlLine."Source Code" := SourceCode;
        GenJnlLine."Salespers./Purch. Code" := Customer."Salesperson Code";
        GenJnlLine."Allow Zero-Amount Posting" := true;
        case ExRvVoucher."Source Type" of
          ExRvVoucher."Source Type"::"Gift Voucher":
            begin
              GiftVoucher.Get(ExRvVoucher."Source No.");
              GenJnlLine."Due Date" := GiftVoucher."Expire Date";
            end;
        end;
    end;
}

