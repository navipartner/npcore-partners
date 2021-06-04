codeunit 6014419 "NPR Payment Type POS Upgrade"
{
    Subtype = Upgrade;

    var
        MovePaymentTypePOSLbl: Label 'PaymentTypePOS_MoveToPOSPaymentMethod', Locked = true;

    trigger OnUpgradePerCompany()
    begin
        MovePaymentTypePOS();
    end;

    local procedure MovePaymentTypePOS()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Payment Type POS Upgrade', 'MovePaymentTypePos');

        if UpgradeTag.HasUpgradeTag(MovePaymentTypePOSLbl) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        DoMovePaymentTypePOS();

        UpgradeTag.SetUpgradeTag(MovePaymentTypePOSLbl);

        LogMessageStopwatch.LogFinish();
    end;

    local procedure DoMovePaymentTypePOS()
    var

        PaymentTypePOS: Record "NPR Payment Type POS";
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        if not PaymentTypePOS.FindSet() then
            exit;

        repeat
            if not POSPaymentMethod.Get(PaymentTypePOS."No.") then
                InsertPaymentMethod(PaymentTypePOS, POSPaymentMethod);

            CopyFromPaymentType(POSPaymentMethod, PaymentTypePOS);
            SetRoundingAccounts(POSPaymentMethod);
            POSPaymentMethod.Modify();

        until PaymentTypePOS.Next() = 0;
    end;

    local procedure InsertPaymentMethod(var PaymentTypePOS: Record "NPR Payment Type POS"; var POSPaymentMethod: Record "NPR POS Payment Method")
    begin
        POSPaymentMethod.Init();
        POSPaymentMethod.Code := PaymentTypePOS."No.";
        POSPaymentMethod.Insert(true);
    end;

    local procedure GetReturnPaymentMethod(POSPaymentMethod: Record "NPR POS Payment Method"): Code[10]
    var
        Register: Record "NPR Register";
        locPOSPaymentMethod: Record "NPR POS Payment Method";
    begin
        if POSPaymentMethod."Processing Type" = POSPaymentMethod."Processing Type"::CASH then
            exit(POSPaymentMethod.Code);

        Register.SetFilter("Return Payment Type", '<>%1', '');
        if Register.FindFirst() then
            exit(Register."Return Payment Type");

        locPOSPaymentMethod.SetRange("Processing Type", locPOSPaymentMethod."Processing Type"::CASH);
        if locPOSPaymentMethod.FindFirst() then
            exit(locPOSPaymentMethod.Code);

        exit('K');
    end;

    local procedure CopyFromPaymentType(var POSPaymentMethod: Record "NPR POS Payment Method"; PaymentTypePOS: Record "NPR Payment Type POS")
    begin
        POSPaymentMethod."Rounding Precision" := PaymentTypePOS."Rounding Precision";
        POSPaymentMethod."Return Payment Method Code" := GetReturnPaymentMethod(POSPaymentMethod);
        POSPaymentMethod."Description" := PaymentTypePOS."Description";
        SetProcessingType(POSPaymentMethod, PaymentTypePOS);
        POSPaymentMethod."Currency Code" := GetCurrencyCode(PaymentTypePOS);
        POSPaymentMethod."Vouched By" := POSPaymentMethod."Vouched By"::INTERNAL;
        POSPaymentMethod."Account No." := GetAccountNo(PaymentTypePOS);
        POSPaymentMethod."Include In Counting" := GetIncludeInCounting(POSPaymentMethod);
        POSPaymentMethod."Fixed Rate" := PaymentTypePOS."Fixed Rate";
        POSPaymentMethod."Post Condensed" := PaymentTypePOS.Posting = PaymentTypePOS.Posting::Condensed;
        POSPaymentMethod."Rounding Precision" := PaymentTypePOS."Rounding Precision";
        POSPaymentMethod."Rounding Type" := POSPaymentMethod."Rounding Type"::Nearest;
        POSPaymentMethod."Maximum Amount" := PaymentTypePOS."Maximum Amount";
        POSPaymentMethod."Minimum Amount" := PaymentTypePOS."Minimum Amount";
        POSPaymentMethod."Return Payment Method Code" := GetReturnPaymentMethod(POSPaymentMethod);
        POSPaymentMethod."Forced Amount" := PaymentTypePOS."Forced Amount";
        POSPaymentMethod."Match Sales Amount" := PaymentTypePOS."Match Sales Amount";
        POSPaymentMethod."Reverse Unrealized VAT" := PaymentTypePOS."Reverse Unrealized VAT";
        POSPaymentMethod."Open Drawer" := PaymentTypePOS."Open Drawer";
        POSPaymentMethod."Allow Refund" := PaymentTypePOS."Allow Refund";
        POSPaymentMethod."Zero as Default on Popup" := PaymentTypePOS."Zero as Default on Popup";
        POSPaymentMethod."No Min Amount on Web Orders" := PaymentTypePOS."No Min Amount on Web Orders";
        POSPaymentMethod."Auto End Sale" := PaymentTypePOS."Auto End Sale";
        POSPaymentMethod."Payment Method Code" := PaymentTypePOS."Payment Method Code";
        POSPaymentMethod."EFT Surcharge Service Item No." := PaymentTypePOS."EFT Surcharge Service Item No.";
        POSPaymentMethod."EFT Tip Service Item No." := PaymentTypePOS."EFT Tip Service Item No.";
    end;

    local procedure SetProcessingType(var POSPaymentMethod: Record "NPR POS Payment Method"; PaymentTypePOS: Record "NPR Payment Type POS"): Option
    begin
        case PaymentTypePOS."Processing Type" of
            PaymentTypePOS."Processing Type"::Cash:
                POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::CASH;
            PaymentTypePOS."Processing Type"::EFT:
                POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::EFT;
            PaymentTypePOS."Processing Type"::"Foreign Credit Voucher":
                POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::VOUCHER;
            PaymentTypePOS."Processing Type"::"Foreign Gift Voucher":
                POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::VOUCHER;
            PaymentTypePOS."Processing Type"::"Finance Agreement":
                POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::CUSTOMER;
            PaymentTypePOS."Processing Type"::Payout:
                POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::PAYOUT;
            PaymentTypePOS."Processing Type"::"Foreign Currency":
                POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::CASH;
            PaymentTypePOS."Processing Type"::"Gift Voucher":
                POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::VOUCHER;
            PaymentTypePOS."Processing Type"::"Credit Voucher":
                POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::VOUCHER;
            PaymentTypePOS."Processing Type"::"Terminal Card":
                POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::EFT;
            PaymentTypePOS."Processing Type"::"Manual Card":
                POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::EFT;
            PaymentTypePOS."Processing Type"::"Other Credit Cards":
                POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::EFT;
            PaymentTypePOS."Processing Type"::"Debit sale":
                POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::CUSTOMER;
            PaymentTypePOS."Processing Type"::Invoice:
                POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::CUSTOMER;
            PaymentTypePOS."Processing Type"::DIBS:
                POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::EFT;
            PaymentTypePOS."Processing Type"::"Point Card":
                POSPaymentMethod."Processing Type" := POSPaymentMethod."Processing Type"::EFT;
        end;
    end;

    local procedure GetCurrencyCode(PaymentTypePOS: Record "NPR Payment Type POS"): Code[10]
    var
        Currency: Record Currency;
    begin
        if PaymentTypePOS."Processing Type" = PaymentTypePOS."Processing Type"::"Foreign Currency" then
            if Currency.Get(PaymentTypePOS."No.") then
                exit(Currency.Code);
        exit('');
    end;

    local procedure GetAccountNo(PaymentTypePOS: Record "NPR Payment Type POS"): Code[20]
    begin
        case PaymentTypePOS."Account Type" of
            PaymentTypePOS."Account Type"::Bank:
                exit(PaymentTypePOS."Bank Acc. No.");
            PaymentTypePOS."Account Type"::Customer:
                exit(PaymentTypePOS."Customer No.");
            PaymentTypePOS."Account Type"::"G/L Account":
                exit(PaymentTypePOS."G/L Account No.");
        end;
    end;



    local procedure GetIncludeInCounting(POSPaymentMethod: Record "NPR POS Payment Method"): Option
    begin
        if POSPaymentMethod."Processing Type" in [POSPaymentMethod."Processing Type"::CASH, POSPaymentMethod."Processing Type"::EFT] then
            exit(POSPaymentMethod."Include In Counting"::YES)
        else
            exit(POSPaymentMethod."Include In Counting"::NO);
    end;

    local procedure SetRoundingAccounts(var POSPaymentMethod: Record "NPR POS Payment Method")
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        if POSPostingProfile.FindFirst() then begin
            POSPaymentMethod."Rounding Gains Account" := POSPostingProfile."POS Sales Rounding Account";
            POSPaymentMethod."Rounding Losses Account" := POSPostingProfile."POS Sales Rounding Account";
        end;
    end;



}
