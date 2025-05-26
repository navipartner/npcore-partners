report 6014561 "NPR NpRv Mass Top-up"
{
#IF NOT BC17
    Extensible = false;
#ENDIF
    ApplicationArea = NPRRetail;
    Caption = 'Voucher Mass Top-up';
    UsageCategory = Tasks;
    ProcessingOnly = true;

    dataset
    {
        dataitem(NpRvVoucher; "NPR NpRv Voucher")
        {
            RequestFilterFields = "No.", "Reference No.", "Voucher Type", Open;
            DataItemTableView = sorting("No.") where("Allow Top-up" = const(true));

            trigger OnAfterGetRecord()
            var
                VoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
                VoucherType: Record "NPR NpRv Voucher Type";
                TempVoucherSalesLine: Record "NPR NpRv Sales Line" temporary;
            begin
                VoucherType.Get(NpRvVoucher."Voucher Type");

                TempVoucherSalesLine.Init();
                TempVoucherSalesLine."Document Source" := TempVoucherSalesLine."Document Source"::"Sales Document";
                TempVoucherSalesLine."Document Type" := TempVoucherSalesLine."Document Type"::Invoice;
                TempVoucherSalesLine."Document No." := DocumentNo;
                TempVoucherSalesLine."Posting No." := DocumentNo;
                TempVoucherSalesLine.Type := TempVoucherSalesLine.Type::"Top-up";
                TempVoucherSalesLine."Voucher No." := NpRvVoucher."No.";
                TempVoucherSalesLine."Voucher Type" := NpRvVoucher."Voucher Type";
                TempVoucherSalesLine."Sale Date" := PostingDate;

                VoucherMgt.PostIssueVoucher(NpRvVoucher, VoucherType, TopupAmount, TempVoucherSalesLine);

                // Prepare general journal lines for posting
                PopulateGenJnlLines(NpRvVoucher);

                VoucherCount += 1;
            end;

            trigger OnPostDataItem()
            begin
                //Post voucher to general ledger
                PostGenJnlLines();
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(content)
            {
                group(TopupOptions)
                {
                    Caption = 'Top-up Options';
                    field(TopupAmountFld; TopupAmount)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Top-up Amount';
                        ToolTip = 'Amount to top up for each selected voucher.';
                        Style = StandardAccent;
                        MinValue = 0;
                    }
                }
                group(PostingOptions)
                {
                    Caption = 'Posting Options';
                    field(DocumentNoFld; DocumentNo)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Document No.';
                        ToolTip = 'Document number for the journal lines created during the top-up process.';
                    }
                    field(PostingDateFld; PostingDate)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Posting Date';
                        ToolTip = 'Posting date for the journal lines created during the top-up process.';
                    }
                    field(AccountNoFld; ClosingAccountNo)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Account No.';
                        TableRelation = "G/L Account"."No." where("Account Type" = const(Posting), "Direct Posting" = const(true));
                        ToolTip = 'Account which will be used as the closing account.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            PostingDate := WorkDate();
            DocumentNo := '';
            TopupAmount := 0;
        end;
    }

    var
        TempGeneralJournalLine: Record "Gen. Journal Line" temporary;
        GenJnlLineNo: Integer;
        DocumentNo: Code[20];
        PostingDate: Date;
        TopupAmount: Decimal;
        VoucherCount: Integer;
        ClosingAccountNo: Code[20];
        TopUpGreaterThanZeroLbl: Label 'Top-up Amount must be greater than zero.';

    trigger OnPreReport()
    begin
        PreReportChecks();
    end;

    trigger OnPostReport()
    var
        TopUpCompletedLbl: Label 'Top-up completed for %1 vouchers.', Comment = '%1 - Number of vouchers processed';
        NoVouchersProcessedLbl: Label 'No vouchers were processed.\\Check the filter and that the selected vouchers are eligible for top-up.';
    begin
        if VoucherCount > 0 then begin
            Message(TopUpCompletedLbl, VoucherCount);
        end else
            Message(NoVouchersProcessedLbl);
    end;

    local procedure PreReportChecks()
    var
        GLAccount: Record "G/L Account";
        AccountNoNotValidLbl: Label 'Please select a valid payment method or account number.';
        DocumentNoNotValidLbl: Label 'Document No. must be specified.';
    begin
        // Check if the top-up amount is greater than zero
        if TopupAmount <= 0 then
            Error(TopUpGreaterThanZeroLbl);

        //Check if Document No. is specified
        if DocumentNo = '' then
            Error(DocumentNoNotValidLbl);

        // Check if the closing account is valid
        if ClosingAccountNo = '' then
            Error(AccountNoNotValidLbl);
        GLAccount.Get(ClosingAccountNo);
    end;

    local procedure PopulateGenJnlLines(Voucher: Record "NPR NpRv Voucher")
    begin
        GenJnlLineNo += 10000;
        TempGeneralJournalLine.Init();
        TempGeneralJournalLine."Line No." := GenJnlLineNo;
        TempGeneralJournalLine.SetSuppressCommit(true);
        TempGeneralJournalLine.Insert();

        TempGeneralJournalLine.Validate("Document No.", DocumentNo);
        TempGeneralJournalLine.Validate("Posting Date", PostingDate);
        TempGeneralJournalLine.Validate("Account Type", TempGeneralJournalLine."Account Type"::"G/L Account");
        TempGeneralJournalLine.Validate("Account No.", GetVoucherAccountNo(Voucher));
        TempGeneralJournalLine.Description := Voucher.Description;
        TempGeneralJournalLine.Validate("Amount", -TopupAmount);
        TempGeneralJournalLine.Validate("Bal. Account Type", TempGeneralJournalLine."Bal. Account Type"::"G/L Account");
        TempGeneralJournalLine.Validate("Bal. Account No.", ClosingAccountNo);
        TempGeneralJournalLine.Modify(true);
    end;

    local procedure GetVoucherAccountNo(Voucher: Record "NPR NpRv Voucher"): Code[20]
    var
        VoucherType: Record "NPR NpRv Voucher Type";
    begin
        VoucherType.Get(Voucher."Voucher Type");
        VoucherType.TestField("Account No.");
        exit(VoucherType."Account No.");
    end;

    local procedure PostGenJnlLines()
    var
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        TempGeneralJournalLine.Reset();
        if (TempGeneralJournalLine.FindSet()) then
            repeat
                GenJnlPostLine.RunWithCheck(TempGeneralJournalLine);
            until TempGeneralJournalLine.Next() = 0;
    end;
}