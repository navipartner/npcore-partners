﻿page 6150628 "NPR POS Payment Bin Checkpoint"
{
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
                        AssistEdit = true;
                        Editable = CountedAmountInclFloatEditable;

                        trigger OnAssistEdit()
                        begin
                            OnAssistEditCounting();
                        end;

                        trigger OnValidate()
                        begin
                            OnValidateCounting();
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
                        Editable = DifferenceAmountEditable;

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
                        ToolTip = 'Specifies the opening count of this POS period.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Counted Amount Incl. Float"; Rec."Counted Amount Incl. Float")
                    {
                        MinValue = 0;
                        Visible = false;
                        ToolTip = 'Specifies the value of the Counted Amount Incl. Float field';
                        ApplicationArea = NPRRetail;
                        AssistEdit = true;
                        Editable = CountedAmountInclFloatEditable;

                        trigger OnAssistEdit()
                        begin
                            OnAssistEditCounting();
                        end;

                        trigger OnValidate()
                        begin
                            OnValidateCounting();
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
                        ToolTip = 'Specifies the total amount that has been transferred into this Payment Bin from another one (such as from another register or from a safe).';
                    }
                    field("Calculated Amount Incl. Float"; Rec."Calculated Amount Incl. Float")
                    {
                        Editable = false;
                        Visible = not IsBlindCount;
                        ToolTip = 'Specifies the value of the Calculated Amount Incl. Float. It contains the same information as in the Counting tab.';
                        ApplicationArea = NPRRetail;
                    }
                    field("New Float Amount"; Rec."New Float Amount")
                    {
                        Editable = (PageMode = PageMode::FINAL_COUNT) and BankDepositAmtEditable;
                        MinValue = 0;
                        Style = Strong;
                        StyleExpr = true;
                        ToolTip = 'Specifies the opening balance of the Payment Bin.';
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
                        ToolTip = 'Specifies the amount that should be transferred to the bank.';
                        ApplicationArea = NPRRetail;
                        AssistEdit = true;
                        Editable = BankDepositAmtEditable;

                        trigger OnAssistEdit()
                        var
                            DenominationMgt: Codeunit "NPR Denomination Mgt.";
                        begin
                            if not DenominationMgt.AssistEditPOSPaymentBinCheckpointDenominations(Rec, "NPR Denomination Target"::BankDeposit, ViewMode, Rec."Bank Deposit Amount") then
                                exit;
                            OnValidateBankDepositAmount();
                        end;

                        trigger OnValidate()
                        begin
                            OnValidateBankDepositAmount();
                        end;
                    }
                    field("Bank Deposit Bin Code"; Rec."Bank Deposit Bin Code")
                    {
                        ShowMandatory = Rec."Bank Deposit Amount" <> 0;
                        ToolTip = 'This field is automatically populated according to the value provided in the Bank Deposit Amount field.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Bank Deposit Reference"; Rec."Bank Deposit Reference")
                    {
                        ShowMandatory = Rec."Bank Deposit Amount" <> 0;
                        ToolTip = 'This field is automatically populated according to the value provided in the Bank Deposit Amount field, but it can be changed later.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Move to Bin Amount"; Rec."Move to Bin Amount")
                    {
                        Style = Unfavorable;
                        StyleExpr = InvalidDistribution;
                        ToolTip = 'Specifies the value of the Move to Bin Amount field';
                        ApplicationArea = NPRRetail;
                        AssistEdit = true;
                        Editable = MoveToBinAmtEditable;

                        trigger OnAssistEdit()
                        var
                            DenominationMgt: Codeunit "NPR Denomination Mgt.";
                        begin
                            if not DenominationMgt.AssistEditPOSPaymentBinCheckpointDenominations(Rec, "NPR Denomination Target"::MoveToBin, ViewMode, Rec."Move to Bin Amount") then
                                exit;
                            OnValidateMoveToBinAmount();
                        end;

                        trigger OnValidate()
                        begin
                            OnValidateMoveToBinAmount();
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
        PageMode: Option PRELIMINARY_COUNT,FINAL_COUNT,TRANSFER,VIEW;
        NetTransfer: Decimal;
        AutoCountCompleted: Boolean;
        ShowCountingSection: Boolean;
        ShowClosingSection: Boolean;
        ViewMode: Boolean;
        IsBlindCount: Boolean;
        CountedAmountInclFloatEditable: Boolean;
        BankDepositAmtEditable: Boolean;
        DifferenceAmountEditable: Boolean;
        MoveToBinAmtEditable: Boolean;


    local procedure OnAssistEditCounting()
    var
        DenominationMgt: Codeunit "NPR Denomination Mgt.";
    begin
        if not DenominationMgt.AssistEditPOSPaymentBinCheckpointDenominations(Rec, "NPR Denomination Target"::Counted, ViewMode, Rec."Counted Amount Incl. Float") then
            exit;
        CountingDifference := CalculatedDifference();
        CalculateNewFloatAmount();
        CurrPage.Update(true);
    end;

    local procedure OnValidateCounting()
    begin
        CountingDifference := CalculatedDifference();
        CalculateNewFloatAmount();
        CurrPage.Update(true);
    end;

    local procedure OnValidateBankDepositAmount()
    begin
        CalculateNewFloatAmount();
        SelectBankBin();
        CurrPage.Update(true);
    end;

    local procedure OnValidateMoveToBinAmount()
    begin
        CalculateNewFloatAmount();
        SelectSafeBin();

        if (PageMode = PageMode::TRANSFER) then
            if ((Rec."Move to Bin Amount" <> 0) and (Rec."Include In Counting" = Rec."Include In Counting"::NO)) then
                Rec."Include In Counting" := Rec."Include In Counting"::YES;

        CurrPage.Update(true);
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

    internal procedure SetTransferMode()
    begin
        ShowCountingSection := false;
        ShowClosingSection := true;
        ViewMode := false;
        PageMode := PageMode::TRANSFER;
    end;

    internal procedure SetCheckpointMode(Mode: Option PRELIMINARY,FINAL,VIEW)
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

    local procedure GetEoDProfile(Rec: Record "NPR POS Payment Bin Checkp."; var POSEODProfile: Record "NPR POS End of Day Profile"): Boolean
    var
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        POSUnit: Record "NPR POS Unit";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        Found: Boolean;
    begin
        clear(POSEODProfile);
        POSPaymentBinCheckpoint.CopyFilters(Rec);
        POSPaymentBinCheckpoint.SetLoadFields("Workshift Checkpoint Entry No.");
        POSWorkshiftCheckpoint.SetLoadFields("POS Unit No.");
        POSUnit.SetLoadFields("POS End of Day Profile");
        if POSPaymentBinCheckpoint.Find('-') then
            repeat
                if POSPaymentBinCheckpoint."Workshift Checkpoint Entry No." <> 0 then begin
                    POSWorkshiftCheckpoint.Get(POSPaymentBinCheckpoint."Workshift Checkpoint Entry No.");
                    if POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.") then
                        Found := POSUnit.GetProfile(POSEODProfile);
                end;
            until Found or (POSPaymentBinCheckpoint.Next() = 0);
        exit(Found);
    end;

    internal procedure SetBlindCount(HideFields: Boolean)
    begin
        IsBlindCount := HideFields;
    end;

    internal procedure DoOnOpenPageProcessing()
    var
        POSEODProfile: Record "NPR POS End of Day Profile";
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
    begin
        GetEoDProfile(Rec, POSEODProfile);
        CountedAmountInclFloatEditable := not POSEODProfile."Require Denomin.(Counted Amt.)";
        BankDepositAmtEditable := not POSEODProfile."Require Denomin.(Bank Deposit)";
        MoveToBinAmtEditable := not POSEODProfile."Require Denomin. (Move to Bin)";
        DifferenceAmountEditable := not POSEODProfile.DisableDifferenceField;

        if (PageMode in [PageMode::PRELIMINARY_COUNT, PageMode::TRANSFER]) or
           ((PageMode = PageMode::FINAL_COUNT) and not AutoCountCompleted)
        then begin
            POSPaymentBinCheckpoint.CopyFilters(Rec);
            POSPaymentBinCheckpoint.SetLoadFields(Type);
            if POSPaymentBinCheckpoint.FindSet(true) then
                repeat
                    case PageMode of
                        PageMode::TRANSFER:
                            POSPaymentBinCheckpoint.Type := POSPaymentBinCheckpoint.Type::TRANSFER;
                        PageMode::FINAL_COUNT:
                            POSPaymentBinCheckpoint.Type := POSPaymentBinCheckpoint.Type::ZREPORT;
                        PageMode::PRELIMINARY_COUNT:
                            POSPaymentBinCheckpoint.Type := POSPaymentBinCheckpoint.Type::XREPORT;
                    end;
                    POSPaymentBinCheckpoint.Modify();
                until POSPaymentBinCheckpoint.Next() = 0;
        end;

        if (PageMode = PageMode::FINAL_COUNT) and not AutoCountCompleted then
            AutoCount(Rec);

        if (IsBlindCount) then begin
            POSPaymentBinCheckpoint.Reset();
            POSPaymentBinCheckpoint.CopyFilters(Rec);
            POSPaymentBinCheckpoint.SetFilter("Include In Counting", '=%1', POSPaymentBinCheckpoint."Include In Counting"::YES);
            POSPaymentBinCheckpoint.SetLoadFields("New Float Amount");
            if (POSPaymentBinCheckpoint.FindSet(true)) then
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
            POSPaymentBinCheckpoint.SetLoadFields("Counted Amount Incl. Float", "Calculated Amount Incl. Float");
            if (POSPaymentBinCheckpoint.FindSet(true)) then
                repeat
                    POSPaymentBinCheckpoint.Validate("Counted Amount Incl. Float", POSPaymentBinCheckpoint."Calculated Amount Incl. Float");
                    POSPaymentBinCheckpoint.Modify();
                until (POSPaymentBinCheckpoint.Next() = 0);
        end;
    end;

    internal procedure AutoCount(var POSPaymentBinCheckpoint2: Record "NPR POS Payment Bin Checkp.")
    var
        POSPaymentBin: Record "NPR POS Payment Bin";
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        POSPaymentMethod: Record "NPR POS Payment Method";
        AutoCountBinLbl: Label '%1 is configured to %2, but there is no value specified for %3.', Comment = '%1 - POS Payment Method tablecaption, %2 - "Virtual" ("Include in Counting" field option), %3 - "Bin for Virtual-Count" fieldcaption';
        CalculatedByAutoCountLbl: Label 'Calculated by Auto-Count.';
        PymMethodLbl: Label '%1:%2', Locked = true;
    begin
        POSPaymentBinCheckpoint.CopyFilters(POSPaymentBinCheckpoint2);
        POSPaymentBinCheckpoint.SetRange("Include In Counting", POSPaymentBinCheckpoint."Include In Counting"::VIRTUAL);
        if POSPaymentBinCheckpoint.FindSet(true) then
            repeat
                POSPaymentMethod.Get(POSPaymentBinCheckpoint."Payment Method No.");
                if (POSPaymentMethod."Bin for Virtual-Count" = '') then
                    Error(AutoCountBinLbl, POSPaymentMethod.TableCaption(), POSPaymentMethod."Include In Counting", POSPaymentMethod.FieldCaption("Bin for Virtual-Count"));
                POSPaymentBin.Get(POSPaymentMethod."Bin for Virtual-Count");

                POSPaymentBinCheckpoint."Counted Amount Incl. Float" := POSPaymentBinCheckpoint."Calculated Amount Incl. Float";
                POSPaymentBinCheckpoint."Move to Bin Code" := POSPaymentMethod."Bin for Virtual-Count";
                POSPaymentBinCheckpoint.Validate("Move to Bin Amount", POSPaymentBinCheckpoint."Counted Amount Incl. Float");
                POSPaymentBinCheckpoint."Move to Bin Reference" := StrSubstNo(PymMethodLbl, POSPaymentBinCheckpoint."Payment Method No.", CopyStr(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')), 1, 7));
                POSPaymentBinCheckpoint."New Float Amount" := 0;
                POSPaymentBinCheckpoint.Comment := CalculatedByAutoCountLbl;
                POSPaymentBinCheckpoint.Status := POSPaymentBinCheckpoint.Status::READY;
                POSPaymentBinCheckpoint.Modify();
            until POSPaymentBinCheckpoint.Next() = 0;

        POSPaymentBinCheckpoint.SetFilter("Calculated Amount Incl. Float", '<%1', 0);
        POSPaymentBinCheckpoint.SetFilter("Include In Counting", '<>%1', POSPaymentBinCheckpoint."Include In Counting"::VIRTUAL);
        if POSPaymentBinCheckpoint.FindSet(true) then
            repeat
                POSPaymentBinCheckpoint.Validate("Counted Amount Incl. Float", 0);
                POSPaymentBinCheckpoint.Status := POSPaymentBinCheckpoint.Status::READY;
                POSPaymentBinCheckpoint."New Float Amount" := 0;
                POSPaymentBinCheckpoint.Comment := CalculatedByAutoCountLbl;
                POSPaymentBinCheckpoint.Modify();
            until POSPaymentBinCheckpoint.Next() = 0;
    end;

    internal procedure SetAutoCountCompleted(Set: Boolean)
    begin
        AutoCountCompleted := Set;
    end;

    internal procedure DoOnClosePageProcessing(): Boolean
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
