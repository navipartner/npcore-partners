page 6150628 "NPR POS Payment Bin Checkpoint"
{
    Caption = 'POS Payment Bin Checkpoint';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Payment Bin Checkp.";

    layout
    {
        area(content)
        {
            group(Counting)
            {
                repeater(Control6014417)
                {
                    Editable = ViewMode = FALSE;
                    ShowCaption = false;
                    Visible = ShowCountingSection;
                    field(PaymentTypeNo; "Payment Type No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Payment Type No. field';
                    }
                    field(Description; Description)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Description field';
                    }
                    field(PaymentBinNo; "Payment Bin No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Visible = false;
                        ToolTip = 'Specifies the value of the Payment Bin No. field';
                    }
                    field(PaymentMethodNo; "Payment Method No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Visible = false;
                        ToolTip = 'Specifies the value of the Payment Method No. field';
                    }
                    field(CountedAmountInclFloat; "Counted Amount Incl. Float")
                    {
                        ApplicationArea = All;
                        MinValue = 0;
                        ToolTip = 'Specifies the value of the Counted Amount Incl. Float field';

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
                    field(CalculatedAmountInclFloat; "Calculated Amount Incl. Float")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Visible = NOT IsBlindCount;
                        ToolTip = 'Specifies the value of the Calculated Amount Incl. Float field';
                    }
                    field(CountingDifference; CountingDifference)
                    {
                        ApplicationArea = All;
                        Caption = 'Difference';
                        Style = Unfavorable;
                        StyleExpr = CountingDifference <> 0;
                        Visible = NOT IsBlindCount;
                        ToolTip = 'Specifies the value of the Difference field';

                        trigger OnValidate()
                        begin

                            "Counted Amount Incl. Float" := "Calculated Amount Incl. Float" - CountingDifference;
                            CountingDifference := CalculatedDifference();
                            CalculateNewFloatAmount();
                            CurrPage.Update(true);
                        end;
                    }
                    field(Comment1; Comment)
                    {
                        ApplicationArea = All;
                        Visible = NOT IsBlindCount;
                        ToolTip = 'Specifies the value of the Comment field';
                    }
                }
            }
            group("Closing & Transfer")
            {
                repeater(Control6014403)
                {
                    Editable = ViewMode = FALSE;
                    ShowCaption = false;
                    Visible = ShowClosingSection;
                    field("Payment Type No."; "Payment Type No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Payment Type No. field';
                    }
                    field("Payment Method No."; "Payment Method No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Visible = false;
                        ToolTip = 'Specifies the value of the Payment Method No. field';
                    }
                    field("Payment Bin No."; "Payment Bin No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Visible = false;
                        ToolTip = 'Specifies the value of the Payment Bin No. field';
                    }
                    field("Float Amount"; "Float Amount")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Float Amount field';
                    }
                    field("Counted Amount Incl. Float"; "Counted Amount Incl. Float")
                    {
                        ApplicationArea = All;
                        MinValue = 0;
                        Visible = false;
                        ToolTip = 'Specifies the value of the Counted Amount Incl. Float field';

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
                    field("Transfer In Amount"; "Transfer In Amount")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Visible = false;
                        ToolTip = 'Specifies the value of the Transfer In Amount field';
                    }
                    field("Transfer Out Amount"; "Transfer Out Amount")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Visible = false;
                        ToolTip = 'Specifies the value of the Transfer Out Amount field';
                    }
                    field(NetTransfer; NetTransfer)
                    {
                        ApplicationArea = All;
                        Caption = 'Transfered Amount';
                        Editable = false;
                        ToolTip = 'Specifies the value of the Transfered Amount field';
                    }
                    field("Calculated Amount Incl. Float"; "Calculated Amount Incl. Float")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Visible = NOT IsBlindCount;
                        ToolTip = 'Specifies the value of the Calculated Amount Incl. Float field';
                    }
                    field("New Float Amount"; "New Float Amount")
                    {
                        ApplicationArea = All;
                        Editable = PageMode = PageMode::FINAL_COUNT;
                        MinValue = 0;
                        Style = Strong;
                        StyleExpr = TRUE;
                        ToolTip = 'Specifies the value of the New Float Amount field';

                        trigger OnValidate()
                        begin

                            "Bank Deposit Amount" := "Counted Amount Incl. Float" - "Move to Bin Amount" - "New Float Amount";

                            if ("Bank Deposit Amount" < 0) then
                                Error(INVALID_AMOUNT, "New Float Amount");

                            SelectBankBin();
                            SelectSafeBin();
                            CurrPage.Update(true);
                        end;
                    }
                    field("Bank Deposit Amount"; "Bank Deposit Amount")
                    {
                        ApplicationArea = All;
                        Style = Unfavorable;
                        StyleExpr = InvalidDistribution;
                        ToolTip = 'Specifies the value of the Bank Deposit Amount field';

                        trigger OnValidate()
                        begin

                            CalculateNewFloatAmount();
                            SelectBankBin();
                            CurrPage.Update(true);
                        end;
                    }
                    field("Bank Deposit Bin Code"; "Bank Deposit Bin Code")
                    {
                        ApplicationArea = All;
                        ShowMandatory = "Bank Deposit Amount" <> 0;
                        ToolTip = 'Specifies the value of the Bank Deposit Bin Code field';
                    }
                    field("Bank Deposit Reference"; "Bank Deposit Reference")
                    {
                        ApplicationArea = All;
                        ShowMandatory = "Bank Deposit Amount" <> 0;
                        ToolTip = 'Specifies the value of the Bank Deposit Reference field';
                    }
                    field("Move to Bin Amount"; "Move to Bin Amount")
                    {
                        ApplicationArea = All;
                        Style = Unfavorable;
                        StyleExpr = InvalidDistribution;
                        ToolTip = 'Specifies the value of the Move to Bin Amount field';

                        trigger OnValidate()
                        begin

                            CalculateNewFloatAmount();
                            SelectSafeBin();

                            if (PageMode = PageMode::TRANSFER) then
                                if (("Move to Bin Amount" <> 0) and ("Include In Counting" = "Include In Counting"::NO)) then
                                    "Include In Counting" := "Include In Counting"::YES;

                            CurrPage.Update(true);
                        end;
                    }
                    field("Move to Bin Code"; "Move to Bin Code")
                    {
                        ApplicationArea = All;
                        ShowMandatory = "Move to bin amount" <> 0;
                        ToolTip = 'Specifies the value of the Move to Bin No. field';
                    }
                    field("Move to Bin Reference"; "Move to Bin Reference")
                    {
                        ApplicationArea = All;
                        ShowMandatory = "Move to bin amount" <> 0;
                        ToolTip = 'Specifies the value of the Move to Bin Trans. ID field';
                    }
                    field(Status; Status)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Status field';
                    }
                    field("Checkpoint Bin Entry No."; "Checkpoint Bin Entry No.")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Visible = false;
                        ToolTip = 'Specifies the value of the Checkpoint Bin Entry No. field';
                    }
                    field("Payment Bin Entry Amount"; "Payment Bin Entry Amount")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Visible = false;
                        ToolTip = 'Specifies the value of the Payment Bin Entry Amount field';
                    }
                    field("Payment Bin Entry Amount (LCY)"; "Payment Bin Entry Amount (LCY)")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Visible = false;
                        ToolTip = 'Specifies the value of the Payment Bin Entry Amount (LCY) field';
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Count")
            {
                Caption = 'Count';
                Ellipsis = true;
                Image = CalculateRemainingUsage;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Count action';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CountingDifference := CalculatedDifference();
        InvalidDistribution := "Counted Amount Incl. Float" <> ("Bank Deposit Amount" + "Move to Bin Amount" + "New Float Amount");

        NetTransfer := "Transfer In Amount" + "Transfer Out Amount";
    end;

    trigger OnClosePage()
    var
        HaveError: Boolean;
    begin

        if (PageMode = PageMode::PRELIMINARY_COUNT) then begin
            ModifyAll(Status, Status::READY);
            exit;
        end;

        HaveError := false;
        if (FindSet()) then begin
            repeat
                HaveError := HaveError or
                 ("Counted Amount Incl. Float" - "Bank Deposit Amount" - "Move to Bin Amount" <> "New Float Amount");
            until (Next() = 0);
        end;

        if (not HaveError) then begin
            SetFilter(Status, '=%1', Status::WIP);


            if (not IsEmpty()) then begin
                if (PageMode = PageMode::TRANSFER) then
                    if (Confirm(TextFinishTransfer, true)) then
                        ModifyAll(Status, Status::READY);


                if (PageMode = PageMode::FINAL_COUNT) then begin
                    SetFilter("Include In Counting", '<>%1', "Include In Counting"::NO);
                    if (Confirm(TextFinishCountingandPost, true)) then
                        ModifyAll(Status, Status::READY);
                end;
            end;
        end;
    end;

    trigger OnModifyRecord(): Boolean
    begin


        if ("Calculated Amount Incl. Float" > 0) then
            TestField(Status, Status::WIP);
    end;

    trigger OnOpenPage()
    var
        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSPaymentBin: Record "NPR POS Payment Bin";
    begin

        case PageMode of
            PageMode::TRANSFER:
                ModifyAll(Type, POSPaymentBinCheckpoint.Type::TRANSFER);
            PageMode::FINAL_COUNT:
                ModifyAll(Type, POSPaymentBinCheckpoint.Type::ZREPORT);
            PageMode::PRELIMINARY_COUNT:
                ModifyAll(Type, POSPaymentBinCheckpoint.Type::XREPORT);
        end;

        if (PageMode = PageMode::FINAL_COUNT) then begin

            POSPaymentBinCheckpoint.CopyFilters(Rec);
            POSPaymentBinCheckpoint.SetFilter("Include In Counting", '=%1', POSPaymentBinCheckpoint."Include In Counting"::VIRTUAL);
            if (POSPaymentBinCheckpoint.FindSet()) then begin
                repeat
                    POSPaymentMethod.Get(POSPaymentBinCheckpoint."Payment Method No.");
                    if (POSPaymentMethod."Bin for Virtual-Count" = '') then
                        Error(AutoCountBin, POSPaymentMethod.TableCaption, POSPaymentMethod."Include In Counting", POSPaymentMethod.FieldCaption("Bin for Virtual-Count"));

                    POSPaymentBin.Get(POSPaymentMethod."Bin for Virtual-Count");

                    POSPaymentBinCheckpoint."Counted Amount Incl. Float" := POSPaymentBinCheckpoint."Calculated Amount Incl. Float";

                    POSPaymentBinCheckpoint."Move to Bin Code" := POSPaymentMethod."Bin for Virtual-Count";
                    POSPaymentBinCheckpoint.Validate("Move to Bin Amount", POSPaymentBinCheckpoint."Counted Amount Incl. Float");
                    POSPaymentBinCheckpoint."Move to Bin Reference" := StrSubstNo('%1:%2', POSPaymentBinCheckpoint."Payment Method No.", CopyStr(UpperCase(DelChr(Format(CreateGuid), '=', '{}-')), 1, 7));
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
            if (POSPaymentBinCheckpoint.FindSet()) then begin
                repeat
                    POSPaymentBinCheckpoint."New Float Amount" := 0;
                    POSPaymentBinCheckpoint.Modify();
                until (POSPaymentBinCheckpoint.Next() = 0);
            end;
        end;

        case PageMode of
            PageMode::FINAL_COUNT:
                SetFilter("Include In Counting", '<>%1&<>%2', "Include In Counting"::NO, "Include In Counting"::VIRTUAL);
            PageMode::PRELIMINARY_COUNT:
                SetFilter("Include In Counting", '<>%1', "Include In Counting"::NO);
            PageMode::TRANSFER:
                ;
            PageMode::VIEW:
                SetFilter("Include In Counting", '<>%1', "Include In Counting"::NO);
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
        PaymentTypeDetailed: Record "NPR Payment Type - Detailed";
        TouchScreenBalancingLine: Page "NPR Touch Screen: Balanc.Line";
        PaymentTypePrefix: Record "NPR Payment Type - Prefix";
    begin

        PaymentTypeDetailed.SetFilter("Payment No.", '=%1', "Payment Type No.");
        PaymentTypeDetailed.SetFilter("Register No.", '=%1', GetRegisterNo());
        if (PaymentTypeDetailed.IsEmpty()) then begin


            PaymentTypePrefix.SetFilter("Payment Type", '=%1', "Payment Type No.");
            if PaymentTypePrefix.FindSet() then begin
                repeat
                    PaymentTypeDetailed.Init;
                    PaymentTypeDetailed."Payment No." := "Payment Type No.";
                    PaymentTypeDetailed."Register No." := GetRegisterNo();
                    PaymentTypeDetailed.Weight := PaymentTypePrefix.Weight;
                    PaymentTypeDetailed.Insert();

                until (PaymentTypePrefix.Next() = 0);
                Commit;
            end;
        end;

        if (PaymentTypeDetailed.IsEmpty()) then
            Error(TextSetupPaymentTypeMissing, "Payment Type No.");

        TouchScreenBalancingLine.SetTableView(PaymentTypeDetailed);
        TouchScreenBalancingLine.LookupMode(true);
        TouchScreenBalancingLine.Editable(true);

        IF (TouchScreenBalancingLine.RUNMODAL() = ACTION::LookupOK) THEN BEGIN

            "Counted Amount Incl. Float" := 0;
            if (PaymentTypeDetailed.FindSet()) then begin
                repeat
                    "Counted Amount Incl. Float" += PaymentTypeDetailed.Amount;

                until (PaymentTypeDetailed.Next() = 0);
            end;
        END;
        CountingDifference := CalculatedDifference();
        CalculateNewFloatAmount();
        CurrPage.Update(true);
    end;

    local procedure GetRegisterNo() RegisterNo: Code[10]
    var
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
    begin

        if (POSSession.IsActiveSession(POSFrontEndManagement)) then begin
            POSFrontEndManagement.GetSession(POSSession);
            POSSession.GetSetup(POSSetup);
            exit(POSSetup.Register());
        end;

        exit('NOREGISTER');
    end;

    local procedure GetPosUnitNo(): Code[10]
    var
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
        POSUnit: Record "NPR POS Unit";
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
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
        POSStore: Record "NPR POS Store";
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

        Difference := "Calculated Amount Incl. Float" - "Counted Amount Incl. Float";
        Comment := COMMENT_DIFFERENCE;
        if (Difference = 0) then
            Comment := COMMENT_NO_DIFFERENCE;
    end;

    local procedure CalculateNewFloatAmount()
    begin

        "New Float Amount" := "Counted Amount Incl. Float" - "Bank Deposit Amount" - "Move to Bin Amount";

        if ("New Float Amount" < 0) then
            "New Float Amount" := 0;
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
    begin
        if ("Bank Deposit Amount" = 0) then begin
            "Bank Deposit Bin Code" := '';
            exit;
        end;

        "Bank Deposit Reference" := StrSubstNo('%1 %2', "Payment Method No.", CopyStr(UpperCase(DelChr(Format(CreateGuid), '=', '{}-')), 1, 7));

        POSPaymentBin.SetFilter("Bin Type", '=%1', POSPaymentBin."Bin Type"::BANK);
        if POSPaymentBin.IsEmpty() then
            exit;

        POSPaymentBin.Reset;
        POSPaymentBin.SetFilter("Bin Type", '=%1', POSPaymentBin."Bin Type"::BANK);
        POSPaymentBin.SetFilter("POS Store Code", '=%1', GetStoreCode());
        if (POSPaymentBin.Count() = 1) then begin
            POSPaymentBin.FindFirst();
            Validate("Bank Deposit Bin Code", POSPaymentBin."No.");
            exit;
        end;

        POSPaymentBin.Reset;
        POSPaymentBin.SetFilter("Bin Type", '=%1', POSPaymentBin."Bin Type"::BANK);
        POSPaymentBin.SetFilter("Attached to POS Unit No.", '=%1', GetPosUnitNo());
        if (POSPaymentBin.Count() = 1) then begin
            POSPaymentBin.FindFirst();
            Validate("Bank Deposit Bin Code", POSPaymentBin."No.");
            exit;
        end;

        POSPaymentBin.Reset;
        POSPaymentBin.SetFilter("Bin Type", '=%1', POSPaymentBin."Bin Type"::BANK);
        if (POSPaymentBin.Count() = 1) then begin
            POSPaymentBin.FindFirst();
            Validate("Bank Deposit Bin Code", POSPaymentBin."No.");
            exit;
        end;
    end;

    local procedure SelectSafeBin()
    var
        POSPaymentBin: Record "NPR POS Payment Bin";
    begin
        if ("Move to Bin Amount" = 0) then begin
            "Move to Bin Code" := '';
            exit;
        end;
        "Move to Bin Reference" := StrSubstNo('%1 %2', "Payment Method No.", CopyStr(UpperCase(DelChr(Format(CreateGuid), '=', '{}-')), 1, 7));

        POSPaymentBin.SetFilter("Bin Type", '=%1', POSPaymentBin."Bin Type"::SAFE);
        if POSPaymentBin.IsEmpty() then
            exit;

        POSPaymentBin.Reset;
        POSPaymentBin.SetFilter("Bin Type", '=%1', POSPaymentBin."Bin Type"::SAFE);
        POSPaymentBin.SetFilter("POS Store Code", '=%1', GetStoreCode());
        if (POSPaymentBin.Count() = 1) then begin
            POSPaymentBin.FindFirst();
            Validate("Move to Bin Code", POSPaymentBin."No.");
            exit;
        end;

        POSPaymentBin.Reset;
        POSPaymentBin.SetFilter("Bin Type", '=%1', POSPaymentBin."Bin Type"::SAFE);
        POSPaymentBin.SetFilter("Attached to POS Unit No.", '=%1', GetPosUnitNo());
        if (POSPaymentBin.Count() = 1) then begin
            POSPaymentBin.FindFirst();
            Validate("Move to Bin Code", POSPaymentBin."No.");
            exit;
        end;

        POSPaymentBin.Reset;
        POSPaymentBin.SetFilter("Bin Type", '=%1', POSPaymentBin."Bin Type"::SAFE);
        if (POSPaymentBin.Count() = 1) then begin
            POSPaymentBin.FindFirst();
            Validate("Move to Bin Code", POSPaymentBin."No.");
            exit;
        end;
    end;

    procedure SetBlindCount(HideFields: Boolean)
    begin

        IsBlindCount := HideFields;
    end;
}

