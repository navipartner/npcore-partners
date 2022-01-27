page 6150628 "NPR POS Payment Bin Checkpoint"
{
    Extensible = False;
    Caption = 'POS Payment Bin Checkpoint';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR POS Payment Bin Checkp.";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(Counting)
            {
                repeater(Control6014417)
                {
                    Editable = ViewMode = false;
                    ShowCaption = false;
                    Visible = ShowCountingSection;
                    field(PaymentTypeNo; Rec."Payment Type No.")
                    {

                        Editable = false;
                        ToolTip = 'Specifies the value of the Payment Type No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Description; Rec.Description)
                    {

                        Editable = false;
                        ToolTip = 'Specifies the value of the Description field';
                        ApplicationArea = NPRRetail;
                    }
                    field(PaymentBinNo; Rec."Payment Bin No.")
                    {

                        Editable = false;
                        Visible = false;
                        ToolTip = 'Specifies the value of the Payment Bin No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field(PaymentMethodNo; Rec."Payment Method No.")
                    {

                        Editable = false;
                        Visible = false;
                        ToolTip = 'Specifies the value of the Payment Method No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field(CountedAmountInclFloat; Rec."Counted Amount Incl. Float")
                    {

                        MinValue = 0;
                        ToolTip = 'Specifies the value of the Counted Amount Incl. Float field';
                        ApplicationArea = NPRRetail;

                        trigger OnAssistEdit()
                        begin
                            OnAssistEditCounting();
                        end;

                        trigger OnValidate()
                        begin
                            CountingDifference := CalculatedDifference();
                            CalculateNewFloatAmount();
                            CurrPage.Update(true);
                        end;
                    }
                    field(CalculatedAmountInclFloat; Rec."Calculated Amount Incl. Float")
                    {

                        Editable = false;
                        Visible = not IsBlindCount;
                        ToolTip = 'Specifies the value of the Calculated Amount Incl. Float field';
                        ApplicationArea = NPRRetail;
                    }
                    field(CountingDifference; CountingDifference)
                    {

                        Caption = 'Difference';
                        Style = Unfavorable;
                        StyleExpr = CountingDifference <> 0;
                        Visible = not IsBlindCount;
                        ToolTip = 'Specifies the value of the Difference field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            Rec."Counted Amount Incl. Float" := Rec."Calculated Amount Incl. Float" - CountingDifference;
                            CountingDifference := CalculatedDifference();
                            CalculateNewFloatAmount();
                            CurrPage.Update(true);
                        end;
                    }
                    field(Comment1; Rec.Comment)
                    {

                        Visible = not IsBlindCount;
                        ToolTip = 'Specifies the value of the Comment field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group("Closing & Transfer")
            {
                repeater(Control6014403)
                {
                    Editable = ViewMode = false;
                    ShowCaption = false;
                    Visible = ShowClosingSection;
                    field("Payment Type No."; Rec."Payment Type No.")
                    {

                        Editable = false;
                        ToolTip = 'Specifies the value of the Payment Type No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Payment Method No."; Rec."Payment Method No.")
                    {

                        Editable = false;
                        Visible = false;
                        ToolTip = 'Specifies the value of the Payment Method No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Payment Bin No."; Rec."Payment Bin No.")
                    {

                        Editable = false;
                        Visible = false;
                        ToolTip = 'Specifies the value of the Payment Bin No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Float Amount"; Rec."Float Amount")
                    {

                        Editable = false;
                        ToolTip = 'Specifies the value of the Float Amount field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Counted Amount Incl. Float"; Rec."Counted Amount Incl. Float")
                    {

                        MinValue = 0;
                        Visible = false;
                        ToolTip = 'Specifies the value of the Counted Amount Incl. Float field';
                        ApplicationArea = NPRRetail;

                        trigger OnAssistEdit()
                        begin
                            OnAssistEditCounting();
                        end;

                        trigger OnValidate()
                        begin
                            CalculateNewFloatAmount();
                            CurrPage.Update(true);
                        end;
                    }
                    field("Transfer In Amount"; Rec."Transfer In Amount")
                    {

                        Editable = false;
                        Visible = false;
                        ToolTip = 'Specifies the value of the Transfer In Amount field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Transfer Out Amount"; Rec."Transfer Out Amount")
                    {

                        Editable = false;
                        Visible = false;
                        ToolTip = 'Specifies the value of the Transfer Out Amount field';
                        ApplicationArea = NPRRetail;
                    }
                    field(NetTransfer; NetTransfer)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Transferred Amount';
                        Editable = false;
                        ToolTip = 'Specifies the value of the Transferred Amount field';
                    }
                    field("Calculated Amount Incl. Float"; Rec."Calculated Amount Incl. Float")
                    {

                        Editable = false;
                        Visible = not IsBlindCount;
                        ToolTip = 'Specifies the value of the Calculated Amount Incl. Float field';
                        ApplicationArea = NPRRetail;
                    }
                    field("New Float Amount"; Rec."New Float Amount")
                    {

                        Editable = PageMode = PageMode::FINAL_COUNT;
                        MinValue = 0;
                        Style = Strong;
                        StyleExpr = true;
                        ToolTip = 'Specifies the value of the New Float Amount field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            Rec."Bank Deposit Amount" := Rec."Counted Amount Incl. Float" - Rec."Move to Bin Amount" - Rec."New Float Amount";

                            if (Rec."Bank Deposit Amount" < 0) then
                                Error(INVALID_AMOUNT, Rec."New Float Amount");

                            SelectBankBin();
                            SelectSafeBin();
                            CurrPage.Update(true);
                        end;
                    }
                    field("Bank Deposit Amount"; Rec."Bank Deposit Amount")
                    {

                        Style = Unfavorable;
                        StyleExpr = InvalidDistribution;
                        ToolTip = 'Specifies the value of the Bank Deposit Amount field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            CalculateNewFloatAmount();
                            SelectBankBin();
                            CurrPage.Update(true);
                        end;
                    }
                    field("Bank Deposit Bin Code"; Rec."Bank Deposit Bin Code")
                    {

                        ShowMandatory = Rec."Bank Deposit Amount" <> 0;
                        ToolTip = 'Specifies the value of the Bank Deposit Bin Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Bank Deposit Reference"; Rec."Bank Deposit Reference")
                    {

                        ShowMandatory = Rec."Bank Deposit Amount" <> 0;
                        ToolTip = 'Specifies the value of the Bank Deposit Reference field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Move to Bin Amount"; Rec."Move to Bin Amount")
                    {

                        Style = Unfavorable;
                        StyleExpr = InvalidDistribution;
                        ToolTip = 'Specifies the value of the Move to Bin Amount field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            CalculateNewFloatAmount();
                            SelectSafeBin();

                            if (PageMode = PageMode::TRANSFER) then
                                if ((Rec."Move to Bin Amount" <> 0) and (Rec."Include In Counting" = Rec."Include In Counting"::NO)) then
                                    Rec."Include In Counting" := Rec."Include In Counting"::YES;

                            CurrPage.Update(true);
                        end;
                    }
                    field("Move to Bin Code"; Rec."Move to Bin Code")
                    {

                        ShowMandatory = Rec."Move to bin amount" <> 0;
                        ToolTip = 'Specifies the value of the Move to Bin No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Move to Bin Reference"; Rec."Move to Bin Reference")
                    {

                        ShowMandatory = Rec."Move to bin amount" <> 0;
                        ToolTip = 'Specifies the value of the Move to Bin Trans. ID field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Status; Rec.Status)
                    {

                        ToolTip = 'Specifies the value of the Status field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Checkpoint Bin Entry No."; Rec."Checkpoint Bin Entry No.")
                    {

                        Editable = false;
                        Visible = false;
                        ToolTip = 'Specifies the value of the Checkpoint Bin Entry No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Payment Bin Entry Amount"; Rec."Payment Bin Entry Amount")
                    {

                        Editable = false;
                        Visible = false;
                        ToolTip = 'Specifies the value of the Payment Bin Entry Amount field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Payment Bin Entry Amount (LCY)"; Rec."Payment Bin Entry Amount (LCY)")
                    {

                        Editable = false;
                        Visible = false;
                        ToolTip = 'Specifies the value of the Payment Bin Entry Amount (LCY) field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            Action("Count")
            {
                Caption = 'Count';
                Ellipsis = true;
                Image = CalculateRemainingUsage;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Count action';
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CountingDifference := CalculatedDifference();
        InvalidDistribution := Rec."Counted Amount Incl. Float" <> (Rec."Bank Deposit Amount" + Rec."Move to Bin Amount" + Rec."New Float Amount");

        NetTransfer := Rec."Transfer In Amount" + Rec."Transfer Out Amount";
    end;

    trigger OnClosePage()
    begin
        DoOnClosePageProcessing();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if (Rec."Calculated Amount Incl. Float" > 0) then
            Rec.TestField(Status, Rec.Status::WIP);
    end;

    trigger OnOpenPage()
    begin
        DoOnOpenPageProcessing();
    end;

    var
        CountingDifference: Decimal;
        InvalidDistribution: Boolean;
        INVALID_AMOUNT: Label 'The amount %1 is invalid.';
        COMMENT_NO_DIFFERENCE: Label 'No difference.';
        COMMENT_DIFFERENCE: Label 'Difference counted vs calculated.';
        TextFinishCountingandPost: Label 'Do you want to finish counting and post results?';
        TextFinishTransfer: Label 'Do you want to finish transfer and post results?';
        TextSetupPaymentTypeMissing: Label 'No counting details have been setup for %1, enter counted amount/quantity as is.';
        PageMode: Option PRELIMINARY_COUNT,FINAL_COUNT,TRANSFER,VIEW;
        NetTransfer: Decimal;
        ShowCountingSection: Boolean;
        ShowClosingSection: Boolean;
        ViewMode: Boolean;
        AutoCountBin: Label '%1 is configured to %2, but there is no value specified for %3.';
        AutoCount: Label 'Calculated by Auto-Count.';
        IsBlindCount: Boolean;

    local procedure OnAssistEditCounting()
    var
        EODDenomination: Record "NPR EOD Denomination";
    begin
        FillDenominationBuffer(EODDenomination);

        if (EODDenomination.IsEmpty()) then
            Error(TextSetupPaymentTypeMissing, Rec."Payment Type No.");

        CountDenominations(EODDenomination);

        CountingDifference := CalculatedDifference();
        CalculateNewFloatAmount();
        CurrPage.Update(true);
    end;

    local procedure GetRegisterNo(): Code[10]
    var
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        if (POSSession.IsActiveSession(POSFrontEndManagement)) then begin
            POSFrontEndManagement.GetSession(POSSession);
            POSSession.GetSetup(POSSetup);
            exit(POSSetup.GetPOSUnitNo());
        end;

        exit('NOREGISTER');
    end;

    local procedure GetPosUnitNo(): Code[10]
    var
        POSUnit: Record "NPR POS Unit";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        if (POSSession.IsActiveSession(POSFrontEndManagement)) then begin
            POSFrontEndManagement.GetSession(POSSession);
            POSSession.GetSetup(POSSetup);
            POSSetup.GetPOSUnit(POSUnit);
            exit(POSUnit."No.");
        end;

        exit('NOUNIT');
    end;

    local procedure GetStoreCode(): Code[10]
    var
        POSStore: Record "NPR POS Store";
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        if (POSSession.IsActiveSession(POSFrontEndManagement)) then begin
            POSFrontEndManagement.GetSession(POSSession);
            POSSession.GetSetup(POSSetup);
            POSSetup.GetPOSStore(POSStore);
            exit(POSStore.Code);
        end;

        exit('NOSTORE');
    end;

    local procedure CalculatedDifference() Difference: Decimal
    begin

        Difference := Rec."Calculated Amount Incl. Float" - Rec."Counted Amount Incl. Float";
        Rec.Comment := COMMENT_DIFFERENCE;
        if (Difference = 0) then
            Rec.Comment := COMMENT_NO_DIFFERENCE;
    end;

    local procedure CalculateNewFloatAmount()
    begin
        Rec."New Float Amount" := Rec."Counted Amount Incl. Float" - Rec."Bank Deposit Amount" - Rec."Move to Bin Amount";

        if (Rec."New Float Amount" < 0) then
            Rec."New Float Amount" := 0;
    end;

    procedure SetTransferMode()
    begin
        ShowCountingSection := false;
        ShowClosingSection := true;
        ViewMode := false;
        PageMode := PageMode::TRANSFER;
    end;

    procedure SetCheckpointMode(Mode: Option PRELIMINARY,FINAL,VIEW)
    begin
        case Mode of
            Mode::PRELIMINARY:
                begin
                    ShowCountingSection := true;
                    ShowClosingSection := false;
                    ViewMode := false;
                    PageMode := PageMode::PRELIMINARY_COUNT;
                end;

            Mode::FINAL:
                begin
                    ShowCountingSection := true;
                    ShowClosingSection := true;
                    ViewMode := false;
                    PageMode := PageMode::FINAL_COUNT;
                end;

            else begin
                    ShowCountingSection := true;
                    ShowClosingSection := true;
                    ViewMode := true;
                    PageMode := PageMode::VIEW;
                end;
        end;
    end;

    local procedure SelectBankBin()
    var
        POSPaymentBin: Record "NPR POS Payment Bin";
        PymMethodLbl: Label '%1 %2', Locked = true;
    begin
        if (Rec."Bank Deposit Amount" = 0) then begin
            Rec."Bank Deposit Bin Code" := '';
            exit;
        end;

        Rec."Bank Deposit Reference" := StrSubstNo(PymMethodLbl, Rec."Payment Method No.", CopyStr(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')), 1, 7));

        POSPaymentBin.SetFilter("Bin Type", '=%1', POSPaymentBin."Bin Type"::BANK);
        if POSPaymentBin.IsEmpty() then
            exit;

        POSPaymentBin.Reset();
        POSPaymentBin.SetFilter("Bin Type", '=%1', POSPaymentBin."Bin Type"::BANK);
        POSPaymentBin.SetFilter("POS Store Code", '=%1', GetStoreCode());
        if (POSPaymentBin.Count() = 1) then begin
            POSPaymentBin.FindFirst();
            Rec.Validate("Bank Deposit Bin Code", POSPaymentBin."No.");
            exit;
        end;

        POSPaymentBin.Reset();
        POSPaymentBin.SetFilter("Bin Type", '=%1', POSPaymentBin."Bin Type"::BANK);
        POSPaymentBin.SetFilter("Attached to POS Unit No.", '=%1', GetPosUnitNo());
        if (POSPaymentBin.Count() = 1) then begin
            POSPaymentBin.FindFirst();
            Rec.Validate("Bank Deposit Bin Code", POSPaymentBin."No.");
            exit;
        end;

        POSPaymentBin.Reset();
        POSPaymentBin.SetFilter("Bin Type", '=%1', POSPaymentBin."Bin Type"::BANK);
        if (POSPaymentBin.Count() = 1) then begin
            POSPaymentBin.FindFirst();
            Rec.Validate("Bank Deposit Bin Code", POSPaymentBin."No.");
            exit;
        end;
    end;

    local procedure SelectSafeBin()
    var
        POSPaymentBin: Record "NPR POS Payment Bin";
        PymMethodLbl: Label '%1 %2', Locked = true;
    begin
        if (Rec."Move to Bin Amount" = 0) then begin
            Rec."Move to Bin Code" := '';
            exit;
        end;
        Rec."Move to Bin Reference" := StrSubstNo(PymMethodLbl, Rec."Payment Method No.", CopyStr(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')), 1, 7));

        POSPaymentBin.SetFilter("Bin Type", '=%1', POSPaymentBin."Bin Type"::SAFE);
        if POSPaymentBin.IsEmpty() then
            exit;

        POSPaymentBin.Reset();
        POSPaymentBin.SetFilter("Bin Type", '=%1', POSPaymentBin."Bin Type"::SAFE);
        POSPaymentBin.SetFilter("POS Store Code", '=%1', GetStoreCode());
        if (POSPaymentBin.Count() = 1) then begin
            POSPaymentBin.FindFirst();
            Rec.Validate("Move to Bin Code", POSPaymentBin."No.");
            exit;
        end;

        POSPaymentBin.Reset();
        POSPaymentBin.SetFilter("Bin Type", '=%1', POSPaymentBin."Bin Type"::SAFE);
        POSPaymentBin.SetFilter("Attached to POS Unit No.", '=%1', GetPosUnitNo());
        if (POSPaymentBin.Count() = 1) then begin
            POSPaymentBin.FindFirst();
            Rec.Validate("Move to Bin Code", POSPaymentBin."No.");
            exit;
        end;

        POSPaymentBin.Reset();
        POSPaymentBin.SetFilter("Bin Type", '=%1', POSPaymentBin."Bin Type"::SAFE);
        if (POSPaymentBin.Count() = 1) then begin
            POSPaymentBin.FindFirst();
            Rec.Validate("Move to Bin Code", POSPaymentBin."No.");
            exit;
        end;
    end;

    local procedure FillDenominationBuffer(var EODDenomination: Record "NPR EOD Denomination")
    var
        PaymentMethodDenom: Record "NPR Payment Method Denom";
    begin
        EODDenomination.SetFilter("POS Payment Method Code", '=%1', Rec."Payment Type No.");
        EODDenomination.SetFilter("POS Unit No.", '=%1', GetRegisterNo());
        if (EODDenomination.IsEmpty()) then begin
            PaymentMethodDenom.SetFilter("POS Payment Method Code", '=%1', Rec."Payment Type No.");
            if PaymentMethodDenom.FindSet() then begin
                repeat
                    EODDenomination.Init();
                    EODDenomination."POS Payment Method Code" := Rec."Payment Type No.";
                    EODDenomination."POS Unit No." := GetRegisterNo();
                    EODDenomination."Denomination Type" := PaymentMethodDenom."Denomination Type";
                    EODDenomination.Denomination := PaymentMethodDenom.Denomination;
                    EODDenomination.Insert();

                until (PaymentMethodDenom.Next() = 0);
                Commit();
            end;
        end;
    end;

    local procedure CountDenominations(var EODDenomination: Record "NPR EOD Denomination")
    var
        EODDenominationCount: Page "NPR EOD Denomination Count";
    begin
        EODDenominationCount.SetTableView(EODDenomination);
        EODDenominationCount.LookupMode(true);
        EODDenominationCount.Editable(true);

        if (EODDenominationCount.RunModal() = Action::LookupOK) then begin
            Rec."Counted Amount Incl. Float" := 0;
            if (EODDenomination.FindSet()) then
                repeat
                    Rec."Counted Amount Incl. Float" += EODDenomination.Amount;
                until (EODDenomination.Next() = 0);
        end;
    end;

    procedure SetBlindCount(HideFields: Boolean)
    begin
        IsBlindCount := HideFields;
    end;

    procedure DoOnOpenPageProcessing()
    var
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSPaymentBin: Record "NPR POS Payment Bin";
        PymMethodLbl: Label '%1:%2', Locked = true;
    begin
        case PageMode of
            PageMode::TRANSFER:
                Rec.ModifyAll(Type, POSPaymentBinCheckpoint.Type::TRANSFER);
            PageMode::FINAL_COUNT:
                Rec.ModifyAll(Type, POSPaymentBinCheckpoint.Type::ZREPORT);
            PageMode::PRELIMINARY_COUNT:
                Rec.ModifyAll(Type, POSPaymentBinCheckpoint.Type::XREPORT);
        end;

        if (PageMode = PageMode::FINAL_COUNT) then begin
            POSPaymentBinCheckpoint.CopyFilters(Rec);
            POSPaymentBinCheckpoint.SetFilter("Include In Counting", '=%1', POSPaymentBinCheckpoint."Include In Counting"::VIRTUAL);
            if (POSPaymentBinCheckpoint.FindSet()) then begin
                repeat
                    POSPaymentMethod.Get(POSPaymentBinCheckpoint."Payment Method No.");
                    if (POSPaymentMethod."Bin for Virtual-Count" = '') then
                        Error(AutoCountBin, POSPaymentMethod.TableCaption(), POSPaymentMethod."Include In Counting", POSPaymentMethod.FieldCaption("Bin for Virtual-Count"));

                    POSPaymentBin.Get(POSPaymentMethod."Bin for Virtual-Count");

                    POSPaymentBinCheckpoint."Counted Amount Incl. Float" := POSPaymentBinCheckpoint."Calculated Amount Incl. Float";

                    POSPaymentBinCheckpoint."Move to Bin Code" := POSPaymentMethod."Bin for Virtual-Count";
                    POSPaymentBinCheckpoint.Validate("Move to Bin Amount", POSPaymentBinCheckpoint."Counted Amount Incl. Float");
                    POSPaymentBinCheckpoint."Move to Bin Reference" := StrSubstNo(PymMethodLbl, POSPaymentBinCheckpoint."Payment Method No.", CopyStr(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')), 1, 7));
                    POSPaymentBinCheckpoint."New Float Amount" := 0;
                    POSPaymentBinCheckpoint.Comment := AutoCount;
                    POSPaymentBinCheckpoint.Status := POSPaymentBinCheckpoint.Status::READY;
                    POSPaymentBinCheckpoint.Modify();

                until (POSPaymentBinCheckpoint.Next() = 0);
            end;

            POSPaymentBinCheckpoint.Reset();
            POSPaymentBinCheckpoint.CopyFilters(Rec);
            POSPaymentBinCheckpoint.SetFilter("Calculated Amount Incl. Float", '<%1', 0);
            POSPaymentBinCheckpoint.SetFilter("Include In Counting", '<>%1', POSPaymentBinCheckpoint."Include In Counting"::VIRTUAL);
            if (POSPaymentBinCheckpoint.FindSet()) then begin
                repeat
                    POSPaymentBinCheckpoint.Validate("Counted Amount Incl. Float", 0);
                    POSPaymentBinCheckpoint.Status := POSPaymentBinCheckpoint.Status::READY;
                    POSPaymentBinCheckpoint."New Float Amount" := 0;
                    POSPaymentBinCheckpoint.Comment := AutoCount;
                    POSPaymentBinCheckpoint.Modify();
                until (POSPaymentBinCheckpoint.Next() = 0);
            end;
        end;

        if (IsBlindCount) then begin
            POSPaymentBinCheckpoint.Reset();
            POSPaymentBinCheckpoint.CopyFilters(Rec);
            POSPaymentBinCheckpoint.SetFilter("Include In Counting", '=%1', POSPaymentBinCheckpoint."Include In Counting"::YES);
            if (POSPaymentBinCheckpoint.FindSet()) then
                repeat
                    POSPaymentBinCheckpoint."New Float Amount" := 0;
                    POSPaymentBinCheckpoint.Modify();
                until (POSPaymentBinCheckpoint.Next() = 0);
        end;

        case PageMode of
            PageMode::FINAL_COUNT:
                Rec.SetFilter("Include In Counting", '<>%1&<>%2', Rec."Include In Counting"::NO, Rec."Include In Counting"::VIRTUAL);
            PageMode::PRELIMINARY_COUNT:
                Rec.SetFilter("Include In Counting", '<>%1', Rec."Include In Counting"::NO);
            PageMode::TRANSFER:
                ;
            PageMode::VIEW:
                Rec.SetFilter("Include In Counting", '<>%1', Rec."Include In Counting"::NO);
        end;

        if (PageMode = PageMode::TRANSFER) then begin
            POSPaymentBinCheckpoint.CopyFilters(Rec);
            if (POSPaymentBinCheckpoint.FindSet()) then begin
                repeat
                    POSPaymentBinCheckpoint.Validate("Counted Amount Incl. Float", POSPaymentBinCheckpoint."Calculated Amount Incl. Float");
                    POSPaymentBinCheckpoint.Modify();

                until (POSPaymentBinCheckpoint.Next() = 0);
            end;
        end;
    end;


    procedure DoOnClosePageProcessing(): Boolean
    var
        HaveError: Boolean;
    begin
        if (PageMode = PageMode::PRELIMINARY_COUNT) then begin
            Rec.ModifyAll(Status, Rec.Status::READY);
            exit;
        end;

        HaveError := false;
        if (Rec.FindSet()) then begin
            repeat
                HaveError := HaveError or
                 (Rec."Counted Amount Incl. Float" - Rec."Bank Deposit Amount" - Rec."Move to Bin Amount" <> Rec."New Float Amount");
            until (Rec.Next() = 0);
        end;

        if (not HaveError) then begin
            Rec.SetFilter(Status, '=%1', Rec.Status::WIP);
            if (not Rec.IsEmpty()) then begin
                if (PageMode = PageMode::TRANSFER) then
                    if (Confirm(TextFinishTransfer, true)) then
                        Rec.ModifyAll(Status, Rec.Status::READY);


                if (PageMode = PageMode::FINAL_COUNT) then begin
                    Rec.SetFilter("Include In Counting", '<>%1', Rec."Include In Counting"::NO);
                    if (Confirm(TextFinishCountingandPost, true)) then
                        Rec.ModifyAll(Status, Rec.Status::READY);
                end;
            end;
        end;

        exit(HaveError);
    end;

}

