codeunit 6060139 "NPR MM Loyalty Point Mgt."
{
    trigger OnRun()
    begin
    end;

    var
        RuleType: Option INCLUDE,EXCLUDE,NO_RULE;
        NO_COUPON_AVAILABLE: Label 'No coupons are available. Remaining points %1, threshold %2.';
        SELECT_COUPON: Label 'Select Discount Coupon';
        POINT_ASSIGNMENT: Label 'Point assignment on finish sale as opposed to point assignment during posting.';
        LoyaltyPostingSourceEnum: Option VALUE_ENTRY,MEMBERSHIP_ENTRY,POS_ENDOFSALE;
        PERIOD_SETUP_ERROR: Label 'The collection period data formulas are setup correctly.';
        CONFIRM_EXPIRE_POINTS: Label 'Points earned until %1 will be expired on transaction date %2.';
        PROGRESS_DIALOG: Label 'Expire loyalty points: #1##################\\';
        EXPIRE_CALC_PREV: Label 'When testing %1, previous period end %2 must be the day before current period start %3.';
        EXPIRE_CALC_NEXT: Label 'When testing %1, next period start %2 must be the day after previous period end %3.';
        MISSING_VALUE: Label 'Missing value in field %1.';
        EXPIRE_FORMULA: Label '%1  is expected to be greater than %2.';
        SUBTOTAL_ZERO: Label 'The SubTotal parameter must not be zero when discount type is based on "discount %" for %1 %2.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInsertValueEntry', '', true, true)]
    local procedure OnAfterInsertValueEntry(var ValueEntry: Record "Value Entry"; ItemJournalLine: Record "Item Journal Line")
    var
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
    begin

        if (ValueEntry."Document Type" = ValueEntry."Document Type"::" ") then begin

            POSSalesWorkflowStep.SetFilter("Subscriber Function", '=%1', PointAssignmentStepName());
            if (POSSalesWorkflowStep.FindFirst()) then
                if (POSSalesWorkflowStep.Enabled) then
                    exit; // Handled by OnFinishSale workflow

        end;

        CreatePointEntryFromValueEntry(ValueEntry, LoyaltyPostingSourceEnum::VALUE_ENTRY, CopyStr(ItemJournalLine."NPR Register Number", 1, 10));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR MM Membership Events", 'OnAfterInsertMembershipEntry', '', true, true)]
    local procedure OnAfterInsertMembershipEntry(MembershipEntry: Record "NPR MM Membership Entry")
    var
        Membership: Record "NPR MM Membership";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        Item: Record Item;
        AssignLoyaltyPoints: Boolean;
        AlterationFilterOption: Integer;
        Quantity: Decimal;
    begin

        if (MembershipEntry."Item No." = '') then
            exit;

        if (not (Membership.Get(MembershipEntry."Membership Entry No."))) then
            exit;

        if (MembershipEntry.Context = MembershipEntry.Context::NEW) or
          ((MembershipEntry.Context = MembershipEntry.Context::REGRET) and (MembershipEntry."Original Context" = MembershipEntry."Original Context"::NEW)) then begin

            MembershipSalesSetup.SetFilter(Type, '=%1', MembershipSalesSetup.Type::ITEM);
            MembershipSalesSetup.SetFilter("No.", '=%1', MembershipEntry."Item No.");
            MembershipSalesSetup.SetFilter("Assign Loyalty Points On Sale", '=%1', true);

            AssignLoyaltyPoints := MembershipSalesSetup.FindFirst();

        end else begin

            AssignLoyaltyPoints := true;

            AlterationFilterOption := MembershipEntry.Context;
            if (AlterationFilterOption = MembershipEntry.Context::REGRET) then
                AlterationFilterOption := MembershipEntry."Original Context";

            case AlterationFilterOption of
                MembershipEntry.Context::RENEW:
                    MembershipAlterationSetup.SetFilter("Alteration Type", '=%1', MembershipAlterationSetup."Alteration Type"::RENEW);
                MembershipEntry.Context::AUTORENEW:
                    exit; //AutoRenew is always via invoice. Loyalty from Value Entry //MembershipAlterationSetup.SetFilter ("Alteration Type", '=%1', MembershipAlterationSetup."Alteration Type"::AUTORENEW);
                MembershipEntry.Context::EXTEND:
                    MembershipAlterationSetup.SetFilter("Alteration Type", '=%1', MembershipAlterationSetup."Alteration Type"::EXTEND);
                MembershipEntry.Context::UPGRADE:
                    MembershipAlterationSetup.SetFilter("Alteration Type", '=%1', MembershipAlterationSetup."Alteration Type"::UPGRADE);
                MembershipEntry.Context::CANCEL:
                    MembershipAlterationSetup.SetFilter("Alteration Type", '=%1', MembershipAlterationSetup."Alteration Type"::CANCEL);
                else
                    AssignLoyaltyPoints := false;
            end;

            if (AssignLoyaltyPoints) then begin
                MembershipAlterationSetup.SetFilter("Sales Item No.", '=%1', MembershipEntry."Item No.");
                if (MembershipAlterationSetup.FindFirst()) then begin
                    AssignLoyaltyPoints := MembershipAlterationSetup."Assign Loyalty Points On Sale";
                end else begin
                    MembershipSalesSetup.SetFilter(Type, '=%1', MembershipSalesSetup.Type::ITEM);
                    MembershipSalesSetup.SetFilter("No.", '=%1', MembershipEntry."Item No.");
                    MembershipSalesSetup.SetFilter("Assign Loyalty Points On Sale", '=%1', true);
                    AssignLoyaltyPoints := MembershipSalesSetup.FindFirst();
                end;
            end;

        end;

        if (not AssignLoyaltyPoints) then
            exit;

        if (not Item.Get(MembershipEntry."Item No.")) then
            exit;

        if ((MembershipEntry."Activate On First Use") and (MembershipEntry."Valid From Date" = 0D)) then
            exit;

        Quantity := -1;
        if (MembershipEntry.Context in [MembershipEntry.Context::CANCEL, MembershipEntry.Context::REGRET]) then
            Quantity := 1;

        // Since customer no is not set on the regular sales we need to forge a value entry on this type of sales to get our initial points
        SimulateValueEntry(
          DT2Date(MembershipEntry."Created At"),
          '',
          MembershipEntry."Item No.",
          Quantity,
          Membership."Customer No.",
          MembershipEntry."Document No.",
          MembershipEntry.Amount,
          0,
          LoyaltyPostingSourceEnum::MEMBERSHIP_ENTRY
          );
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sales Workflow Step", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnDiscoverPointAssignmentSaleWorkflowStep(var Rec: Record "NPR POS Sales Workflow Step"; RunTrigger: Boolean)
    begin

        if (Rec."Subscriber Codeunit ID" <> CurrCodeunitId()) then
            exit;

        if (Rec."Subscriber Function" <> PointAssignmentStepName()) then
            exit;

        Rec.Description := POINT_ASSIGNMENT;
        Rec."Sequence No." := 31;
        Rec.Enabled := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnFinishSale', '', true, true)]
    local procedure PointAssignmentOnSale(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SalePOS: Record "NPR POS Sale")
    var
        PosEntry: Record "NPR POS Entry";
        PosEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin

        if (POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId()) then
            exit;

        if (POSSalesWorkflowStep."Subscriber Function" <> PointAssignmentStepName()) then
            exit;

        // Calculate points and assign.
        PosEntry.SetFilter("Document No.", SalePOS."Sales Ticket No.");
        if (PosEntry.FindFirst()) then begin
            PosEntrySalesLine.SetFilter("POS Entry No.", '=%1', PosEntry."Entry No.");
            PosEntrySalesLine.SetFilter(Type, '=%1', PosEntrySalesLine.Type::Item);
            if (PosEntrySalesLine.FindSet()) then begin
                repeat
                    SimulateValueEntry(
                        PosEntry."Document Date",
                        PosEntry."POS Unit No.",
                        PosEntrySalesLine."No.",
                        PosEntrySalesLine.Quantity * -1,
                        PosEntry."Customer No.",
                        PosEntry."Document No.",
                        PosEntrySalesLine."Amount Excl. VAT (LCY)",
                        PosEntrySalesLine."Line Dsc. Amt. Excl. VAT (LCY)",
                        LoyaltyPostingSourceEnum::POS_ENDOFSALE
                    );
                until (PosEntrySalesLine.Next() = 0);
            end;
        end;
    end;

    local procedure CurrCodeunitId(): Integer
    begin

        exit(Codeunit::"NPR MM Loyalty Point Mgt.");
    end;

    local procedure PointAssignmentStepName(): Text
    begin

        exit('PointAssignmentOnSale');
    end;

    local procedure ErrorExit(var ReasonText: Text; ReasonMessage: Text): Boolean
    begin
        ReasonText := ReasonMessage;
        exit(false);
    end;

    local procedure SimulateValueEntry(PostingDate: Date; PosUnitNo: Code[10]; ItemNo: Code[20]; Quantity: Decimal; CustomerNo: Code[20]; DocumentNo: Code[20]; Amount: Decimal; DiscountAmount: Decimal; DataSource: Option)
    var
        ValueEntry: Record "Value Entry";
        Item: Record Item;
    begin

        if (ItemNo = '') then
            exit;

        if (CustomerNo = '') then
            exit;

        if (not Item.Get(ItemNo)) then
            exit;

        ValueEntry.Init();
        ValueEntry."Posting Date" := PostingDate;
        ValueEntry."Item No." := ItemNo;
        ValueEntry."Source No." := CustomerNo;
        ValueEntry."Item Ledger Entry Type" := ValueEntry."Item Ledger Entry Type"::Sale;
        ValueEntry."Document No." := DocumentNo;
        ValueEntry."Valued Quantity" := Quantity;
        ValueEntry."Sales Amount (Actual)" := Amount;
        ValueEntry."Discount Amount" := DiscountAmount;
        ValueEntry."Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";

        CreatePointEntryFromValueEntry(ValueEntry, DataSource, POSUnitNo);
    end;

    procedure SimulatePointEntryForTestFramework(PostingDate: Date; PosUnitNo: Code[10]; ItemNo: Code[20]; Quantity: Decimal; CustomerNo: Code[20]; DocumentNo: Code[20]; Amount: Decimal; DiscountAmount: Decimal; DataSource: Option)
    var
        ValueEntry: Record "Value Entry";
        Item: Record Item;
    begin

        if (ItemNo = '') then
            exit;

        if (CustomerNo = '') then
            exit;

        ValueEntry.Init();
        ValueEntry."Posting Date" := PostingDate;
        ValueEntry."Item No." := ItemNo;
        ValueEntry."Source No." := CustomerNo;
        ValueEntry."Item Ledger Entry Type" := ValueEntry."Item Ledger Entry Type"::Sale;
        ValueEntry."Document No." := DocumentNo;
        ValueEntry."Valued Quantity" := Quantity;
        ValueEntry."Sales Amount (Actual)" := Amount;
        ValueEntry."Discount Amount" := DiscountAmount;
        ValueEntry."Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";

        CreatePointEntryFromValueEntry(ValueEntry, DataSource, PosUnitNo);
    end;

    local procedure CreatePointEntryFromValueEntry(ValueEntry: Record "Value Entry"; LoyaltyPostingSource: Option; POSUnitNo: Code[10]): Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipPointsEntry: Record "NPR MM Members. Points Entry";
        MemberCommunity: Record "NPR MM Member Community";
        MembershipSetup: Record "NPR MM Membership Setup";
        LoyaltySetup: Record "NPR MM Loyalty Setup";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        MembershipEntry: Record "NPR MM Membership Entry";
        POSUnit: Record "NPR POS Unit";
        AwardPoints: Boolean;
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
    begin

        if (ValueEntry."Item Ledger Entry Type" <> ValueEntry."Item Ledger Entry Type"::Sale) then
            exit(false);

        if (ValueEntry."Source No." = '') then
            exit(false);

        Membership.SetFilter("Customer No.", '=%1', ValueEntry."Source No.");
        Membership.SetFilter(Blocked, '=%1', false);
        if (not Membership.FindFirst()) then
            exit(false);

        if (not MemberCommunity.Get(Membership."Community Code")) then
            exit(false);

        if (not MemberCommunity."Activate Loyalty Program") then
            exit(false);

        if (not MembershipSetup.Get(Membership."Membership Code")) then
            exit(false);

        if (not LoyaltySetup.Get(MembershipSetup."Loyalty Code")) then
            exit(false);

        if (Membership.Blocked) then
            exit(false);

        if (LoyaltyPostingSource in [LoyaltyPostingSourceEnum::POS_ENDOFSALE, LoyaltyPostingSourceEnum::VALUE_ENTRY]) then begin
            if (MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, ValueEntry."Item No.")) then
                if (MembershipSalesSetup."Assign Loyalty Points On Sale") then
                    exit;

            MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
            MembershipEntry.SetFilter(Blocked, '=%1', false);
            if (MembershipEntry.FindLast()) then begin
                // should probably map the alteration types here.
                MembershipAlterationSetup.SetFilter("Sales Item No.", '=%1', ValueEntry."Item No.");
                MembershipAlterationSetup.SetFilter("From Membership Code", Membership."Membership Code");
                MembershipAlterationSetup.SetFilter("To Membership Code", '=%1|=%2', '', Membership."Membership Code");
                MembershipAlterationSetup.SetFilter("Assign Loyalty Points On Sale", '=%1', true);
                if (MembershipAlterationSetup.FindFirst()) then
                    exit;

                MembershipAlterationSetup.Reset();
                // should probably map the alteration types here.
                MembershipAlterationSetup.SetFilter("Sales Item No.", '=%1', ValueEntry."Item No.");
                MembershipAlterationSetup.SetFilter("To Membership Code", '=%2', '', Membership."Membership Code");
                MembershipAlterationSetup.SetFilter("Assign Loyalty Points On Sale", '=%1', true);
                if (MembershipAlterationSetup.FindFirst()) then
                    exit;
            end;
        end;

        // -- Add the points entry
        MembershipPointsEntry.Init();
        MembershipPointsEntry."Entry No." := 0;
        MembershipPointsEntry."Entry Type" := MembershipPointsEntry."Entry Type"::SALE;
        if (ValueEntry."Valued Quantity" > 0) then
            MembershipPointsEntry."Entry Type" := MembershipPointsEntry."Entry Type"::REFUND;

        MembershipPointsEntry."Posting Date" := ValueEntry."Posting Date";
        MembershipPointsEntry."Value Entry No." := ValueEntry."Entry No.";
        MembershipPointsEntry."Customer No." := Membership."Customer No.";
        MembershipPointsEntry."Membership Entry No." := Membership."Entry No.";
        MembershipPointsEntry."Document No." := ValueEntry."Document No.";
        MembershipPointsEntry."Loyalty Code" := MembershipSetup."Loyalty Code";
        MembershipPointsEntry."Item No." := ValueEntry."Item No.";
        MembershipPointsEntry."Variant Code" := ValueEntry."Variant Code";

        if (POSUnit.Get(POSUnitNo)) then begin
            MembershipPointsEntry."POS Unit Code" := POSUnit."No.";
            MembershipPointsEntry."POS Store Code" := POSUnit."POS Store Code";
        end;

        MembershipPointsEntry."Amount (LCY)" := CalculateBaseAmount(ValueEntry, (LoyaltySetup."Amount Base" = LoyaltySetup."Amount Base"::INCL_VAT));
        MembershipPointsEntry.Quantity := ValueEntry."Valued Quantity" * -1;

        MembershipPointsEntry."Point Constraint" := MembershipPointsEntry."Point Constraint"::EXCLUDE;

        AwardPoints := MembershipManagement.IsMembershipActive(Membership."Entry No.", ValueEntry."Posting Date", true);
        if (AwardPoints) or (MembershipPointsEntry."Entry Type" = MembershipPointsEntry."Entry Type"::REFUND) then begin
            MembershipPointsEntry."Point Constraint" := CalculateAwardedPoints(LoyaltySetup,
              MembershipPointsEntry."Posting Date", MembershipPointsEntry."Item No.", MembershipPointsEntry."Variant Code",
              Abs(MembershipPointsEntry."Amount (LCY)"), (ValueEntry."Discount Amount" <> 0),
              MembershipPointsEntry."Awarded Amount (LCY)", MembershipPointsEntry."Awarded Points", MembershipPointsEntry."Loyalty Item Point Line No.");

            MembershipPointsEntry."Awarded Points" *= MembershipPointsEntry.Quantity;
            if (LoyaltySetup."Rounding on Earning" = LoyaltySetup."Rounding on Earning"::NEAREST) then
                MembershipPointsEntry.Points := Round(MembershipPointsEntry."Awarded Amount (LCY)", 1, '=') + MembershipPointsEntry."Awarded Points";
            if (LoyaltySetup."Rounding on Earning" = LoyaltySetup."Rounding on Earning"::UP) then
                MembershipPointsEntry.Points := Round(MembershipPointsEntry."Awarded Amount (LCY)", 1, '>') + MembershipPointsEntry."Awarded Points";
            if (LoyaltySetup."Rounding on Earning" = LoyaltySetup."Rounding on Earning"::DOWN) then
                MembershipPointsEntry.Points := Round(MembershipPointsEntry."Awarded Amount (LCY)", 1, '<') + MembershipPointsEntry."Awarded Points";

            if (MembershipPointsEntry."Entry Type" = MembershipPointsEntry."Entry Type"::REFUND) then begin
                MembershipPointsEntry.Points *= -1;
                MembershipPointsEntry."Awarded Points" *= -1;
                MembershipPointsEntry."Awarded Amount (LCY)" *= -1;
            end;
        end;

        CalculatePointsValidPeriod(LoyaltySetup, MembershipPointsEntry."Posting Date", MembershipPointsEntry."Period Start", MembershipPointsEntry."Period End");

        if (MembershipPointsEntry.Insert()) then;

        AfterMembershipPointsUpdate(Membership."Entry No.", MembershipPointsEntry."Entry No.");
        exit(true);
    end;

    local procedure CalculateBaseAmount(ValueEntry: Record "Value Entry"; IncludeVAT: Boolean) AmountBase: Decimal
    var
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        Customer: Record Customer;
    begin

        if (IncludeVAT) then begin
            if (not GenProductPostingGroup.Get(ValueEntry."Gen. Prod. Posting Group")) then
                exit(0);

            if (not Item.Get(ValueEntry."Item No.")) then
                exit(0);

            VATPostingSetup.SetFilter("VAT Bus. Posting Group", '=%1', Item."VAT Bus. Posting Gr. (Price)");
            VATPostingSetup.SetFilter("VAT Prod. Posting Group", '=%1', Item."VAT Prod. Posting Group");
            if (Customer.Get(ValueEntry."Source No.")) then
                VATPostingSetup.SetFilter("VAT Bus. Posting Group", '=%1', Customer."VAT Bus. Posting Group");

            if (not VATPostingSetup.FindFirst()) then
                exit(0);

            AmountBase := ValueEntry."Sales Amount (Actual)" * ((100 + VATPostingSetup."VAT %") / 100.0);
        end else begin
            AmountBase := ValueEntry."Sales Amount (Actual)";
        end;

        exit(AmountBase);
    end;

    local procedure CalculateAwardedPoints(LoyaltySetup: Record "NPR MM Loyalty Setup"; ReferenceDate: Date; ItemNo: Code[20]; VariantCode: Code[10]; AmountBase: Decimal; AmountIsDiscounted: Boolean; var AwardedAmount: Decimal; var AwardedPoints: Integer; var RuleReference: Integer): Integer
    var
        Item: Record Item;
    begin
        AwardedAmount := 0;
        AwardedPoints := 0;
        RuleReference := 0;

        // Check Settings level Exclude
        if (AmountIsDiscounted) then
            if (not LoyaltySetup."Points On Discounted Sales") then begin
                AwardedAmount := 0;
                AwardedPoints := 0;
                exit(RuleType::EXCLUDE);
            end;

        if (LoyaltySetup."Amount Factor" <> 0) then
            AmountBase := (AmountBase * LoyaltySetup."Amount Factor");

        if (LoyaltySetup."Point Base" = LoyaltySetup."Point Base"::AMOUNT) then begin
            AwardedAmount := AmountBase;
            AwardedPoints := 0;
            RuleReference := 0;
            exit(ApplyRule(LoyaltySetup.Code, RuleReference, AmountBase, AwardedAmount, AwardedPoints));
        end;

        AwardedAmount := 0;
        AwardedPoints := 0;
        Item.Get(ItemNo);

        if (CheckItemRule(LoyaltySetup.Code, ReferenceDate, ItemNo, VariantCode, AmountIsDiscounted, RuleReference) = RuleType::EXCLUDE) then
            exit(RuleType::EXCLUDE);

        if (CheckItemGroupRule(LoyaltySetup.Code, ReferenceDate, ItemNo, AmountIsDiscounted, RuleReference) = RuleType::EXCLUDE) then
            exit(RuleType::EXCLUDE);

        if (CheckItemVendorRule(LoyaltySetup.Code, ReferenceDate, ItemNo, AmountIsDiscounted, RuleReference) = RuleType::EXCLUDE) then
            exit(RuleType::EXCLUDE);

        // This item will award points by default as sales amount
        if (LoyaltySetup."Point Base" = LoyaltySetup."Point Base"::AMOUNT_ITEM_SETUP) then begin
            AwardedAmount := AmountBase;
            AwardedPoints := Round(AmountBase, 1);
        end;

        // This item will award points only if there is a include rule
        if (LoyaltySetup."Point Base" = LoyaltySetup."Point Base"::ITEM_SETUP) then begin
            AwardedAmount := 0;
            AwardedPoints := 0
        end;

        // Check include rules
        if (CheckItemRule(LoyaltySetup.Code, ReferenceDate, ItemNo, VariantCode, AmountIsDiscounted, RuleReference) = RuleType::INCLUDE) then
            exit(ApplyRule(LoyaltySetup.Code, RuleReference, AmountBase, AwardedAmount, AwardedPoints));

        if (CheckItemGroupRule(LoyaltySetup.Code, ReferenceDate, ItemNo, AmountIsDiscounted, RuleReference) = RuleType::INCLUDE) then
            exit(ApplyRule(LoyaltySetup.Code, RuleReference, AmountBase, AwardedAmount, AwardedPoints));

        if (CheckItemVendorRule(LoyaltySetup.Code, ReferenceDate, ItemNo, AmountIsDiscounted, RuleReference) = RuleType::INCLUDE) then
            exit(ApplyRule(LoyaltySetup.Code, RuleReference, AmountBase, AwardedAmount, AwardedPoints));

        // No rule implies include in loyalty when amount based
        if (LoyaltySetup."Point Base" = LoyaltySetup."Point Base"::AMOUNT_ITEM_SETUP) then
            exit(ApplyRule(LoyaltySetup.Code, RuleReference, AmountBase, AwardedAmount, AwardedPoints));

        // No rule implies exclude from loyalty when rule based
        if (LoyaltySetup."Point Base" = LoyaltySetup."Point Base"::ITEM_SETUP) then
            exit(RuleType::EXCLUDE);
    end;

    procedure CalculatePointsValidPeriod(LoyaltySetup: Record "NPR MM Loyalty Setup"; ReferenceDate: Date; var ValidFromDate: Date; var ValidUntilDate: Date)
    begin

        if (ReferenceDate = 0D) then
            ReferenceDate := Today();

        ValidFromDate := 0D;
        ValidUntilDate := 0D;

        case LoyaltySetup."Collection Period" of
            LoyaltySetup."Collection Period"::AS_YOU_GO:
                begin
                    ValidUntilDate := ReferenceDate;
                    ValidFromDate := 0D;
                    if (Format(LoyaltySetup."Expire Uncollected After") <> '') and (LoyaltySetup."Expire Uncollected Points") then
                        ValidFromDate := CALCDATE('<+1D>', CALCDATE(LoyaltySetup."Expire Uncollected After", ReferenceDate));
                end;

            LoyaltySetup."Collection Period"::FIXED:
                begin
                    if (Format(LoyaltySetup."Fixed Period Start") <> '') then begin
                        ValidFromDate := CalcDate(LoyaltySetup."Fixed Period Start", ReferenceDate);

                        if (Format(LoyaltySetup."Collection Period Length") <> '') then
                            ValidUntilDate := CalcDate(LoyaltySetup."Collection Period Length", ValidFromDate);

                    end;
                end;

        end;
    end;

    procedure ValidateFixedPeriodCalculation(LoyaltySetup: Record "NPR MM Loyalty Setup"; var ReasonText: Text) PeriodCalculationIssue: Boolean
    var
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
        CollectionPeriodStart: Date;
        CollectionPeriodEnd: Date;
        TestPeriodStart: Date;
        TestPeriodEnd: Date;
        ExpirePointsAt: Date;
    begin

        ReasonText := '';

        if (not (LoyaltySetup."Collection Period" = LoyaltySetup."Collection Period"::FIXED)) then
            exit(true);

        if (Format(LoyaltySetup."Collection Period Length") = '') then begin
            ReasonText := StrSubstNo(MISSING_VALUE, LoyaltySetup.FieldCaption("Collection Period Length"));
            exit(false);
        end;

        if (Format(LoyaltySetup."Fixed Period Start") = '') then begin
            ReasonText := StrSubstNo(MISSING_VALUE, LoyaltySetup.FieldCaption("Fixed Period Start"));
            exit(false);
        end;

        CalculatePointsValidPeriod(LoyaltySetup, Today, CollectionPeriodStart, CollectionPeriodEnd);

        if (CollectionPeriodStart <> 0D) and (CollectionPeriodEnd <> 0D) then begin
            LoyaltyPointManagement.CalculatePointsValidPeriod(LoyaltySetup, CalcDate('<-1D>', CollectionPeriodStart), TestPeriodStart, TestPeriodEnd);
            PeriodCalculationIssue := (TestPeriodEnd >= CollectionPeriodStart);
            ReasonText := StrSubstNo(EXPIRE_CALC_PREV, CalcDate('<-1D>', CollectionPeriodStart), TestPeriodEnd, CollectionPeriodStart);

            LoyaltyPointManagement.CalculatePointsValidPeriod(LoyaltySetup, CalcDate('<+1D>', CollectionPeriodEnd), TestPeriodStart, TestPeriodEnd);
            PeriodCalculationIssue := PeriodCalculationIssue or (TestPeriodStart <= CollectionPeriodEnd);
            ReasonText := StrSubstNo(EXPIRE_CALC_NEXT, CalcDate('<+1D>', CollectionPeriodEnd), TestPeriodStart, CollectionPeriodEnd);
        end;

        if (not PeriodCalculationIssue) then begin
            ExpirePointsAt := 0D;
            if (LoyaltySetup."Expire Uncollected Points") then
                if (Format(LoyaltySetup."Expire Uncollected After") <> '') then
                    ExpirePointsAt := CalcDate(LoyaltySetup."Expire Uncollected After", CollectionPeriodEnd);

            if (ExpirePointsAt <> 0D) and (ExpirePointsAt < CollectionPeriodEnd) then begin
                ReasonText := StrSubstNo(EXPIRE_FORMULA, ExpirePointsAt, CollectionPeriodEnd);
                exit(false);
            end;
        end;

        if (not PeriodCalculationIssue) then
            ReasonText := 'OK';

        exit(not PeriodCalculationIssue);

    end;

    local procedure CalculateCurrentExpiryDate(LoyaltySetup: Record "NPR MM Loyalty Setup"; var ExpirePointStart: Date; var ExpirePointEnd: Date; var ReasonText: Text): Boolean
    var
        ReferenceDate: Date;
        CollectionPeriodStart: Date;
        CollectionPeriodEnd: Date;
    begin

        if (not LoyaltySetup."Expire Uncollected Points") then
            exit(false);

        if (not ValidateFixedPeriodCalculation(LoyaltySetup, ReasonText)) then
            Error(ReasonText);

        // Might have to do a couple of iterations to find the expire points data.
        ReferenceDate := Today();
        repeat

            CalculatePointsValidPeriod(LoyaltySetup, ReferenceDate, CollectionPeriodStart, CollectionPeriodEnd);

            if (CollectionPeriodEnd = 0D) then
                Error(PERIOD_SETUP_ERROR);

            ExpirePointStart := CalcDate('<+1D>', CollectionPeriodEnd);
            ExpirePointEnd := CalcDate(LoyaltySetup."Expire Uncollected After", CollectionPeriodEnd);

            ReferenceDate := CalcDate('<-1D>', CollectionPeriodStart);

        until (ExpirePointEnd <= Today);

        exit(true);

    end;

    local procedure ApplyRule(LoyaltyCode: Code[20]; RuleReference: Integer; AmountBase: Decimal; var AwardedAmount: Decimal; var AwardedPoints: Integer): Integer
    var
        LoyaltyItemPointSetup: Record "NPR MM Loy. Item Point Setup";
    begin

        AwardedAmount := AmountBase;
        AwardedPoints := 0;

        if (not LoyaltyItemPointSetup.Get(LoyaltyCode, RuleReference)) then
            exit(RuleType::INCLUDE);

        case LoyaltyItemPointSetup.Award of
            LoyaltyItemPointSetup.Award::AMOUNT:
                begin
                    AwardedAmount := AmountBase * LoyaltyItemPointSetup."Amount Factor";
                    AwardedPoints := 0;
                end;

            LoyaltyItemPointSetup.Award::POINTS:
                begin
                    AwardedAmount := 0;
                    AwardedPoints := LoyaltyItemPointSetup.Points;
                end;

            LoyaltyItemPointSetup.Award::POINTS_AND_AMOUNT:
                begin
                    AwardedAmount := AmountBase * LoyaltyItemPointSetup."Amount Factor";
                    AwardedPoints := LoyaltyItemPointSetup.Points;
                end;
        end;

        exit(RuleType::INCLUDE);
    end;

    procedure AfterMembershipPointsUpdate(MembershipEntryNo: Integer; MembershipPointsEntryNo: Integer)
    var
        MembershipRole: Record "NPR MM Membership Role";
        UpgradeAlteration: Record "NPR MM Loyalty Alter Members.";
        DowngradeAlteration: Record "NPR MM Loyalty Alter Members.";
        TempValidCouponToCreate: Record "NPR MM Loyalty Point Setup" temporary;
        MemberNotification: Codeunit "NPR MM Member Notification";
        UpgradeAvailable: Boolean;
        DowngradeAvailable: Boolean;
    begin

        // Adjust membership level based on points.
        UpgradeAvailable := EligibleForMembershipAlteration(MembershipEntryNo, true, false, UpgradeAlteration);
        DowngradeAvailable := EligibleForMembershipAlteration(MembershipEntryNo, false, false, DowngradeAlteration);

        if (UpgradeAvailable and not DowngradeAvailable) then
            AlterMembership(MembershipEntryNo, UpgradeAlteration);

        if (DowngradeAvailable and not UpgradeAvailable) then
            AlterMembership(MembershipEntryNo, DowngradeAlteration);

        // Consume points and create a coupon
        if (EligibleForCoupon(MembershipEntryNo, TempValidCouponToCreate)) then
            CreateCouponRequest(MembershipEntryNo, TempValidCouponToCreate);

        // Update wallet with new point summary and membership type
        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipRole.SetFilter(Blocked, '=%1', false);
        MembershipRole.SetFilter("Wallet Pass Id", '<>%1', '');
        if (not MembershipRole.IsEmpty()) then
            MemberNotification.CreateUpdateWalletNotification(MembershipEntryNo, 0, 0, TODAY);

    end;

    local procedure CheckItemRule(LoyaltyCode: Code[20]; ReferenceDate: Date; ItemNo: Code[20]; VariantCode: Code[10]; AmountIsDiscounted: Boolean; var RuleReference: Integer): Integer
    var
        LoyaltyItemPointSetup: Record "NPR MM Loy. Item Point Setup";
    begin

        // Check Variant
        LoyaltyItemPointSetup.Reset();
        LoyaltyItemPointSetup.SetFilter(Code, '=%1', LoyaltyCode);
        LoyaltyItemPointSetup.SetFilter(Type, '=%1', LoyaltyItemPointSetup.Type::Item);
        LoyaltyItemPointSetup.SetFilter(Blocked, '=%1', false);
        LoyaltyItemPointSetup.SetFilter("No.", '=%1', ItemNo);
        LoyaltyItemPointSetup.SetFilter("Variant Code", '=%1', VariantCode);
        LoyaltyItemPointSetup.SetFilter("Valid From Date", '=%1|<=%2', 0D, ReferenceDate);
        LoyaltyItemPointSetup.SetFilter("Valid Until Date", '=%1|>=%2', 0D, ReferenceDate);
        if (LoyaltyItemPointSetup.FindFirst()) then begin
            if (AmountIsDiscounted) then begin
                LoyaltyItemPointSetup.SetFilter("Allow On Discounted Sale", '=%1', true);
                if (LoyaltyItemPointSetup.FindFirst()) then;
            end;
            RuleReference := LoyaltyItemPointSetup."Line No.";
            exit(LoyaltyItemPointSetup.Constraint);
        end;

        // Check Item
        LoyaltyItemPointSetup.Reset();
        LoyaltyItemPointSetup.SetFilter(Code, '=%1', LoyaltyCode);
        LoyaltyItemPointSetup.SetFilter(Type, '=%1', LoyaltyItemPointSetup.Type::Item);
        LoyaltyItemPointSetup.SetFilter(Blocked, '=%1', false);
        LoyaltyItemPointSetup.SetFilter("No.", '=%1', ItemNo);
        LoyaltyItemPointSetup.SetFilter("Valid From Date", '=%1|<=%2', 0D, ReferenceDate);
        LoyaltyItemPointSetup.SetFilter("Valid Until Date", '=%1|>=%2', 0D, ReferenceDate);
        if (LoyaltyItemPointSetup.FindFirst()) then begin
            if (AmountIsDiscounted) then begin
                LoyaltyItemPointSetup.SetFilter("Allow On Discounted Sale", '=%1', true);
                if (LoyaltyItemPointSetup.FindFirst()) then;
            end;

            RuleReference := LoyaltyItemPointSetup."Line No.";
            exit(LoyaltyItemPointSetup.Constraint);
        end;

        // No rule found
        RuleReference := 0;
        exit(RuleType::NO_RULE);
    end;

    local procedure CheckItemGroupRule(LoyaltyCode: Code[20]; ReferenceDate: Date; ItemNo: Code[20]; AmountIsDiscounted: Boolean; var RuleReference: Integer): Integer
    var
        LoyaltyItemPointSetup: Record "NPR MM Loy. Item Point Setup";
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        // TODO traverse to root

        LoyaltyItemPointSetup.Reset();
        LoyaltyItemPointSetup.SetFilter(Code, '=%1', LoyaltyCode);
        LoyaltyItemPointSetup.SetFilter(Blocked, '=%1', false);
        LoyaltyItemPointSetup.SetFilter(Type, '=%1', LoyaltyItemPointSetup.Type::"Item Group");

        LoyaltyItemPointSetup.SetFilter("No.", '=%1', Item."Item Category Code");
        LoyaltyItemPointSetup.SetFilter("Valid From Date", '=%1|<=%2', 0D, ReferenceDate);
        LoyaltyItemPointSetup.SetFilter("Valid Until Date", '=%1|>=%2', 0D, ReferenceDate);
        if (LoyaltyItemPointSetup.FindFirst()) then begin
            if (AmountIsDiscounted) then begin
                LoyaltyItemPointSetup.SetFilter("Allow On Discounted Sale", '=%1', true);
                if (LoyaltyItemPointSetup.FindFirst()) then;
            end;

            RuleReference := LoyaltyItemPointSetup."Line No.";
            exit(LoyaltyItemPointSetup.Constraint);
        end;

        // No rule found
        RuleReference := 0;
        exit(RuleType::NO_RULE);
    end;

    local procedure CheckItemVendorRule(LoyaltyCode: Code[20]; ReferenceDate: Date; ItemNo: Code[20]; AmountIsDiscounted: Boolean; var RuleReference: Integer): Integer
    var
        LoyaltyItemPointSetup: Record "NPR MM Loy. Item Point Setup";
        Item: Record Item;
    begin
        Item.Get(ItemNo);

        // This item group has an explicit include rule
        LoyaltyItemPointSetup.Reset();
        LoyaltyItemPointSetup.SetFilter(Code, '=%1', LoyaltyCode);
        LoyaltyItemPointSetup.SetFilter(Blocked, '=%1', false);
        LoyaltyItemPointSetup.SetFilter(Type, '=%1', LoyaltyItemPointSetup.Type::Vendor);

        LoyaltyItemPointSetup.SetFilter("No.", '=%1', Item."Vendor No.");
        LoyaltyItemPointSetup.SetFilter("Valid From Date", '=%1|<=%2', 0D, ReferenceDate);
        LoyaltyItemPointSetup.SetFilter("Valid Until Date", '=%1|>=%2', 0D, ReferenceDate);
        if (LoyaltyItemPointSetup.FindFirst()) then begin
            if (AmountIsDiscounted) then begin
                LoyaltyItemPointSetup.SetFilter("Allow On Discounted Sale", '=%1', true);
                if (LoyaltyItemPointSetup.FindFirst()) then;
            end;

            RuleReference := LoyaltyItemPointSetup."Line No.";
            exit(LoyaltyItemPointSetup.Constraint);
        end;

        // No Rule Found
        RuleReference := 0;
        exit(RuleType::NO_RULE);
    end;

    procedure IssueOneCoupon(MembershipEntryNo: Integer; var TmpLoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup" temporary; DocumentNo: Code[20]; PostingDate: Date; SubTotal: Decimal) CouponNo: Code[20]
    var
        Membership: Record "NPR MM Membership";
        LoyaltyCouponMgr: Codeunit "NPR MM Loyalty Coupon Mgr";
        PointsToRedeem: Integer;
        CouponAmount: Decimal;
        RedeemablePoints: Integer;
    begin

        if (TmpLoyaltyPointsSetup."Value Assignment" = TmpLoyaltyPointsSetup."Value Assignment"::FROM_COUPON) then
            CouponNo := LoyaltyCouponMgr.IssueOneCoupon(TmpLoyaltyPointsSetup."Coupon Type Code", MembershipEntryNo, DocumentNo, PostingDate, TmpLoyaltyPointsSetup."Points Threshold", 0);

        if (TmpLoyaltyPointsSetup."Value Assignment" = TmpLoyaltyPointsSetup."Value Assignment"::FROM_LOYALTY) then begin
            Membership.Get(MembershipEntryNo);

            RedeemablePoints := TmpLoyaltyPointsSetup."Points Threshold";

            CouponAmount := SubTotal;

            if (RedeemablePoints * TmpLoyaltyPointsSetup."Point Rate" < SubTotal) then
                CouponAmount := RedeemablePoints * TmpLoyaltyPointsSetup."Point Rate";

            PointsToRedeem := Round(CouponAmount / TmpLoyaltyPointsSetup."Point Rate", 1);

            if (CouponAmount >= TmpLoyaltyPointsSetup."Minimum Coupon Amount") then
                CouponNo := LoyaltyCouponMgr.IssueOneCoupon(TmpLoyaltyPointsSetup."Coupon Type Code", MembershipEntryNo, DocumentNo, PostingDate, PointsToRedeem, CouponAmount);

            // if (USERID = 'TSA') then MESSAGE ('Coupon Amount %1, SubTotal %2, Points(redeemable) %3,  Points(redeemed) %4, Rate %5', CouponAmount, SubTotal, RedeemablePoints, PointsToRedeem, TmpLoyaltyPointsSetup."Point Rate");

        end;
    end;

    procedure RedeemPointsCoupon(MembershipEntryNo: Integer; DocumentNo: Code[20]; DocumentDate: Date; CouponNo: Code[20]; PointsToDeduct: Integer)
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipPointsEntry: Record "NPR MM Members. Points Entry";
    begin

        Membership.Get(MembershipEntryNo);
        MembershipSetup.Get(Membership."Membership Code");
        MembershipSetup.TestField("Loyalty Code");

        MembershipPointsEntry."Entry No." := 0;

        MembershipPointsEntry."Entry Type" := MembershipPointsEntry."Entry Type"::POINT_WITHDRAW;
        MembershipPointsEntry."Posting Date" := DocumentDate;
        MembershipPointsEntry."Document No." := DocumentNo;
        MembershipPointsEntry."Membership Entry No." := MembershipEntryNo;
        MembershipPointsEntry."Customer No." := Membership."Customer No.";
        MembershipPointsEntry."Loyalty Code" := MembershipSetup."Loyalty Code";

        MembershipPointsEntry."Redeemed Points" := Abs(PointsToDeduct);
        MembershipPointsEntry.Points := -Abs(PointsToDeduct);

        MembershipPointsEntry."Redeem Ref. Type" := MembershipPointsEntry."Redeem Ref. Type"::COUPON;
        MembershipPointsEntry."Redeem Reference No." := CouponNo;

        MembershipPointsEntry.Quantity := 1;

        MembershipPointsEntry.Insert();
    end;

    procedure UnRedeemPointsCoupon(MembershipEntryNo: Integer; DocumentNo: Code[20]; DocumentDate: Date; CouponNo: Code[20]): Boolean
    var
        MembershipPointsEntry: Record "NPR MM Members. Points Entry";
    begin

        if (CouponNo = '') then
            exit;

        MembershipPointsEntry.SetFilter("Entry Type", '=%1', MembershipPointsEntry."Entry Type"::POINT_WITHDRAW);
        MembershipPointsEntry.SetFilter("Redeem Ref. Type", '=%1', MembershipPointsEntry."Redeem Ref. Type"::COUPON);
        MembershipPointsEntry.SetFilter("Redeem Reference No.", '=%1', CouponNo);
        MembershipPointsEntry.SetFilter(Adjustment, '=%1', true);

        if (not MembershipPointsEntry.IsEmpty()) then
            exit; // Already returned

        MembershipPointsEntry.SetFilter(Adjustment, '=%1', false);
        if (not MembershipPointsEntry.FindFirst()) then
            exit; // Invalid Coupon

        MembershipPointsEntry."Entry No." := 0;

        MembershipPointsEntry."Posting Date" := DocumentDate;
        MembershipPointsEntry."Document No." := DocumentNo;

        MembershipPointsEntry."Redeemed Points" *= -1;
        MembershipPointsEntry.Points *= -1;
        MembershipPointsEntry.Adjustment := true;

        MembershipPointsEntry.Insert();
        exit(true);
    end;

    procedure GetCouponToRedeemPOS(MembershipEntryNo: Integer; var TmpLoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup" temporary; SubTotal: Decimal): Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        LoyaltySetup: Record "NPR MM Loyalty Setup";
        LoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup";
        LineNo: Integer;
        AvailablePoints: Integer;
        ReasonText: Text;
    begin

        Membership.Get(MembershipEntryNo);
        MembershipSetup.Get(Membership."Membership Code");
        MembershipSetup.TestField("Loyalty Code");
        LoyaltySetup.Get(MembershipSetup."Loyalty Code");

        if (not GetEligibleCouponsToRedeemWorker(MembershipEntryNo, TmpLoyaltyPointsSetup, SubTotal, AvailablePoints, ReasonText)) then
            Error(ReasonText);

        if (LoyaltySetup."Voucher Creation" = LoyaltySetup."Voucher Creation"::PROMPT) then begin

            LineNo := DoLookupCoupon(SELECT_COUPON, TmpLoyaltyPointsSetup);
            TmpLoyaltyPointsSetup.DeleteAll();
            if (LoyaltyPointsSetup.Get(LoyaltySetup.Code, LineNo)) then begin
                TmpLoyaltyPointsSetup.TransferFields(LoyaltyPointsSetup, true);

                if (LoyaltyPointsSetup."Consume Available Points") then
                    TmpLoyaltyPointsSetup."Points Threshold" := AvailablePoints;

                TmpLoyaltyPointsSetup.Insert();
            end;
        end;

        exit(not TmpLoyaltyPointsSetup.IsEmpty());
    end;

    procedure GetCouponToRedeemWS(MembershipEntryNo: Integer; var TmpLoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup" temporary; SubTotal: Decimal; var ReasonText: Text): Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        LoyaltySetup: Record "NPR MM Loyalty Setup";
        AvailablePoints: Integer;
    begin

        Membership.Get(MembershipEntryNo);
        MembershipSetup.Get(Membership."Membership Code");
        MembershipSetup.TestField("Loyalty Code");
        LoyaltySetup.Get(MembershipSetup."Loyalty Code");

        if (not GetEligibleCouponsToRedeemWorker(MembershipEntryNo, TmpLoyaltyPointsSetup, SubTotal, AvailablePoints, ReasonText)) then
            exit(false);

        exit(not TmpLoyaltyPointsSetup.IsEmpty());
    end;

    local procedure GetEligibleCouponsToRedeemWorker(MembershipEntryNo: Integer; var TmpLoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup" temporary; SubTotal: Decimal; var PointsToSpend: Integer; var ReasonText: Text): Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        LoyaltySetup: Record "NPR MM Loyalty Setup";
        ThresholdPoints: Integer;
    begin

        Clear(TmpLoyaltyPointsSetup);

        Membership.Get(MembershipEntryNo);
        MembershipSetup.Get(Membership."Membership Code");
        LoyaltySetup.Get(MembershipSetup."Loyalty Code");

        case (LoyaltySetup."Voucher Point Source") of
            LoyaltySetup."Voucher Point Source"::PREVIOUS_PERIOD:
                begin
                    ThresholdPoints := CalculateEarnedPointsRelativePeriod(MembershipEntryNo, -1);
                    PointsToSpend := CalculateRedeemablePointsRelativePeriod(MembershipEntryNo, -1);
                end;

            LoyaltySetup."Voucher Point Source"::UNCOLLECTED:
                begin
                    ThresholdPoints := CalculateAvailablePoints(MembershipEntryNo, Today, true);
                    PointsToSpend := CalculateAvailablePoints(MembershipEntryNo, Today, false);
                end;
        end;
        exit(DoGetCoupon(MembershipEntryNo, TmpLoyaltyPointsSetup, SubTotal, ThresholdPoints, PointsToSpend, ReasonText));
    end;

    local procedure DoGetCoupon(MembershipEntryNo: Integer; var TmpLoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup" temporary; SubTotal: Decimal; ThresholdPoints: Integer; PointsToSpend: Integer; var ReasonText: Text): Boolean;
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        LoyaltySetup: Record "NPR MM Loyalty Setup";
        LoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup";
        ApplyCouponsInOrder: Integer;
        RemainingPoints: Integer;
    begin

        Membership.Get(MembershipEntryNo);
        MembershipSetup.Get(Membership."Membership Code");
        LoyaltySetup.Get(MembershipSetup."Loyalty Code");
        if (ThresholdPoints < LoyaltySetup."Voucher Point Threshold") then
            exit(ErrorExit(ReasonText, StrSubstNo(NO_COUPON_AVAILABLE, ThresholdPoints, LoyaltySetup."Voucher Point Threshold")));

        LoyaltyPointsSetup.SetFilter(Code, '=%1', LoyaltySetup.Code);
        LoyaltyPointsSetup.SetFilter("Points Threshold", '%1..%2', 0, Abs(ThresholdPoints));
        if (LoyaltyPointsSetup.IsEmpty()) then
            exit(ErrorExit(ReasonText, StrSubstNo(NO_COUPON_AVAILABLE, ThresholdPoints, LoyaltySetup."Voucher Point Threshold")));

        LoyaltyPointsSetup.Reset();
        LoyaltyPointsSetup.SetFilter(Code, '=%1', LoyaltySetup.Code);
        LoyaltyPointsSetup.SetFilter("Points Threshold", '%1..%2', 0, Abs(ThresholdPoints));
        case LoyaltySetup."Voucher Creation" of
            LoyaltySetup."Voucher Creation"::SV_MP_HVC:
                begin
                    LoyaltyPointsSetup.SetCurrentKey(Code, "Points Threshold");
                    LoyaltyPointsSetup.FindLast();
                    TmpLoyaltyPointsSetup.TransferFields(LoyaltyPointsSetup, true);
                    TmpLoyaltyPointsSetup.SystemId := LoyaltyPointsSetup.SystemId;

                    if (LoyaltyPointsSetup."Value Assignment" = LoyaltyPointsSetup."Value Assignment"::FROM_COUPON) then
                        SelectCouponFromCouponSetup(TmpLoyaltyPointsSetup, PointsToSpend, LoyaltyPointsSetup);

                    if (LoyaltyPointsSetup."Value Assignment" = LoyaltyPointsSetup."Value Assignment"::FROM_LOYALTY) then
                        SelectCouponFromLoyaltySetup(TmpLoyaltyPointsSetup, SubTotal, PointsToSpend);
                end;

            LoyaltySetup."Voucher Creation"::SV_MP_LVC:
                begin
                    LoyaltyPointsSetup.SetCurrentKey(Code, "Points Threshold");
                    LoyaltyPointsSetup.FindFirst();
                    TmpLoyaltyPointsSetup.TransferFields(LoyaltyPointsSetup, true);
                    TmpLoyaltyPointsSetup.SystemId := LoyaltyPointsSetup.SystemId;

                    if (LoyaltyPointsSetup."Value Assignment" = LoyaltyPointsSetup."Value Assignment"::FROM_COUPON) then
                        SelectCouponFromCouponSetup(TmpLoyaltyPointsSetup, PointsToSpend, LoyaltyPointsSetup);

                    if (LoyaltyPointsSetup."Value Assignment" = LoyaltyPointsSetup."Value Assignment"::FROM_LOYALTY) then
                        SelectCouponFromLoyaltySetup(TmpLoyaltyPointsSetup, SubTotal, PointsToSpend);
                end;

            LoyaltySetup."Voucher Creation"::SV_HVC:
                begin
                    LoyaltyPointsSetup.SetCurrentKey(Code, "Amount LCY");
                    LoyaltyPointsSetup.SetFilter("Value Assignment", '=%1', LoyaltyPointsSetup."Value Assignment"::FROM_COUPON);
                    LoyaltyPointsSetup.FindLast();
                    TmpLoyaltyPointsSetup.TransferFields(LoyaltyPointsSetup, true);
                    TmpLoyaltyPointsSetup.SystemId := LoyaltyPointsSetup.SystemId;

                    if (LoyaltyPointsSetup."Consume Available Points") then
                        TmpLoyaltyPointsSetup."Points Threshold" := PointsToSpend;

                    if (CouponTypeIsValid(LoyaltyPointsSetup."Coupon Type Code")) then
                        TmpLoyaltyPointsSetup.Insert();
                end;

            LoyaltySetup."Voucher Creation"::MV_IVC:
                begin
                    LoyaltyPointsSetup.SetCurrentKey(Code, "Points Threshold");
                    LoyaltyPointsSetup.Ascending(false);
                    LoyaltyPointsSetup.FindSet();
                    ApplyCouponsInOrder := 1;
                    RemainingPoints := PointsToSpend;
                    repeat
                        if (CouponTypeIsValid(LoyaltyPointsSetup."Coupon Type Code")) then
                            while (RemainingPoints >= LoyaltyPointsSetup."Points Threshold") do begin
                                TmpLoyaltyPointsSetup.TransferFields(LoyaltyPointsSetup, true);
                                TmpLoyaltyPointsSetup.SystemId := LoyaltyPointsSetup.SystemId;
                                TmpLoyaltyPointsSetup."Line No." := ApplyCouponsInOrder;
                                TmpLoyaltyPointsSetup.Insert();
                                ApplyCouponsInOrder += 1;
                                RemainingPoints -= LoyaltyPointsSetup."Points Threshold";
                            end;
                    until (LoyaltyPointsSetup.Next() = 0);
                end;

            LoyaltySetup."Voucher Creation"::PROMPT:
                begin

                    LoyaltyPointsSetup.SetCurrentKey(Code, "Points Threshold");
                    if (LoyaltyPointsSetup.FindSet()) then begin
                        repeat
                            TmpLoyaltyPointsSetup.TransferFields(LoyaltyPointsSetup, true);
                            TmpLoyaltyPointsSetup.SystemId := LoyaltyPointsSetup.SystemId;

                            if (TmpLoyaltyPointsSetup."Value Assignment" = TmpLoyaltyPointsSetup."Value Assignment"::FROM_COUPON) then begin
                                TmpLoyaltyPointsSetup.CalcFields("Discount Amount", "Discount %", "Discount Type", "Max. Discount Amount");
                                if (TmpLoyaltyPointsSetup."Discount Type" = TmpLoyaltyPointsSetup."Discount Type"::"Discount Amount") then
                                    TmpLoyaltyPointsSetup."Amount LCY" := TmpLoyaltyPointsSetup."Discount Amount";

                                if (TmpLoyaltyPointsSetup."Discount Type" = TmpLoyaltyPointsSetup."Discount Type"::"Discount %") then begin
                                    if (SubTotal = 0) then
                                        exit(ErrorExit(ReasonText, StrSubstNo(SUBTOTAL_ZERO, TmpLoyaltyPointsSetup.FieldName("Coupon Type Code"), TmpLoyaltyPointsSetup."Coupon Type Code")));

                                    TmpLoyaltyPointsSetup."Amount LCY" := SubTotal * TmpLoyaltyPointsSetup."Discount %" / 100;
                                end;

                                TmpLoyaltyPointsSetup.Insert();
                            end;

                            if (LoyaltyPointsSetup."Value Assignment" = LoyaltyPointsSetup."Value Assignment"::FROM_LOYALTY) then
                                SelectCouponFromLoyaltySetup(TmpLoyaltyPointsSetup, SubTotal, PointsToSpend);

                        until (LoyaltyPointsSetup.Next() = 0);

                    end;
                end;

        end;

        exit(not TmpLoyaltyPointsSetup.IsEmpty());
    end;

    local procedure DoLookupCoupon(LookupCaption: Text; var TmpLoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup" temporary) LineNo: Integer
    var
        AvailableCoupons: Page "NPR MM Available Coupons";
        PageAction: Action;
        TempLoyaltyPointsSetupResponse: Record "NPR MM Loyalty Point Setup" temporary;
    begin

        LineNo := 0;

        AvailableCoupons.LoadEntries(LookupCaption, TmpLoyaltyPointsSetup);
        AvailableCoupons.LookupMode(true);
        PageAction := AvailableCoupons.RunModal();
        if (PageAction = Action::LookupOK) then begin
            AvailableCoupons.GetRecord(TempLoyaltyPointsSetupResponse);
            LineNo := TempLoyaltyPointsSetupResponse."Line No.";
        end;

        exit(LineNo);
    end;

    local procedure AdjustPointsAbsoluteWorker(MembershipEntryNo: Integer; EntryType: Option; Points: Integer; AmountLCY: Decimal; ReferenceDate: Date; DocumentNo: Code[20]): Integer
    begin

        exit(AdjustPointsAbsoluteWorker2(
                MembershipEntryNo,
                EntryType,
                Points,
                AmountLCY,
                ReferenceDate,
                ReferenceDate,
                DocumentNo,
                '')
              );
    end;

    local procedure AdjustPointsAbsoluteWorker2(MembershipEntryNo: Integer; EntryType: Option; Points: Integer; AmountLCY: Decimal; ReferenceDate: Date; PostingDate: Date; DocumentNo: Code[20]; Description: Text[80]): Integer
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipPointsEntry: Record "NPR MM Members. Points Entry";
        LoyaltySetup: Record "NPR MM Loyalty Setup";
    begin

        Membership.Get(MembershipEntryNo);
        MembershipSetup.Get(Membership."Membership Code");
        MembershipSetup.TestField("Loyalty Code");
        LoyaltySetup.Get(MembershipSetup."Loyalty Code");

        MembershipPointsEntry."Entry No." := 0;

        MembershipPointsEntry."Entry Type" := EntryType;
        MembershipPointsEntry.Adjustment := true;
        MembershipPointsEntry."Document No." := DocumentNo;

        MembershipPointsEntry."Posting Date" := PostingDate;
        CalculatePointsValidPeriod(LoyaltySetup, ReferenceDate, MembershipPointsEntry."Period Start", MembershipPointsEntry."Period End");

        MembershipPointsEntry."Membership Entry No." := MembershipEntryNo;
        MembershipPointsEntry."Customer No." := Membership."Customer No.";
        MembershipPointsEntry."Loyalty Code" := MembershipSetup."Loyalty Code";

        MembershipPointsEntry.Points := Points;
        MembershipPointsEntry."Amount (LCY)" := AmountLCY;

        if ((MembershipPointsEntry."Entry Type" = MembershipPointsEntry."Entry Type"::SALE) or
            (MembershipPointsEntry."Entry Type" = MembershipPointsEntry."Entry Type"::REFUND)) then
            MembershipPointsEntry."Awarded Points" := Points;

        MembershipPointsEntry.Quantity := 1;
        MembershipPointsEntry.Description := Description;

        MembershipPointsEntry.Insert();

        AfterMembershipPointsUpdate(Membership."Entry No.", MembershipPointsEntry."Entry No.");

        exit(MembershipPointsEntry."Entry No.");
    end;

    procedure SynchronizePointsAbsolute(MembershipEntryNo: Integer; Points: Integer; ReferenceDate: Date)
    var
        Membership: Record "NPR MM Membership";
        MembershipPointsEntry: Record "NPR MM Members. Points Entry";
    begin

        if (not Membership.Get(MembershipEntryNo)) then
            exit;

        Membership.CalcFields("Remaining Points");
        if (Points = Membership."Remaining Points") then
            exit;

        AdjustPointsAbsoluteWorker(MembershipEntryNo, MembershipPointsEntry."Entry Type"::POINT_DEPOSIT, Points - Membership."Remaining Points", 0, ReferenceDate, '');
    end;

    procedure ManualAddSalePoints(MembershipEntryNo: Integer; ReceiptNo: Code[20]; Points: Integer; "Amount (LCY)": Decimal; Description: Text[50]) EntryNo: Integer
    var
        Membership: Record "NPR MM Membership";
        MembershipPointsEntry: Record "NPR MM Members. Points Entry";
    begin

        if (not Membership.Get(MembershipEntryNo)) then
            exit;

        exit(AdjustPointsAbsoluteWorker(MembershipEntryNo, MembershipPointsEntry."Entry Type"::SALE, Abs(Points), Abs("Amount (LCY)"), Today, ReceiptNo));
    end;

    procedure ManualAddRefundPoints(MembershipEntryNo: Integer; ReceiptNo: Code[20]; Points: Integer; "Amount (LCY)": Decimal; Description: Text[50]) EntryNo: Integer
    var
        Membership: Record "NPR MM Membership";
        MembershipPointsEntry: Record "NPR MM Members. Points Entry";
    begin

        if (not Membership.Get(MembershipEntryNo)) then
            exit;

        exit(AdjustPointsAbsoluteWorker(MembershipEntryNo, MembershipPointsEntry."Entry Type"::REFUND, -1 * Abs(Points), -1 * Abs("Amount (LCY)"), Today, ReceiptNo));

    end;

    procedure ManualRedeemPointsWithdraw(MembershipEntryNo: Integer; ReceiptNo: Code[20]; Points: Integer; "Amount (LCY)": Decimal; Description: Text[50]) EntryNo: Integer
    var
        Membership: Record "NPR MM Membership";
        MembershipPointsEntry: Record "NPR MM Members. Points Entry";
    begin

        if (not Membership.Get(MembershipEntryNo)) then
            exit;

        exit(AdjustPointsAbsoluteWorker(MembershipEntryNo, MembershipPointsEntry."Entry Type"::POINT_WITHDRAW, -1 * Abs(Points), -1 * Abs("Amount (LCY)"), Today, ReceiptNo));

    end;

    procedure ManualRedeemPointsDeposit(MembershipEntryNo: Integer; ReceiptNo: Code[20]; Points: Integer; "Amount (LCY)": Decimal; Description: Text[50]) EntryNo: Integer
    var
        Membership: Record "NPR MM Membership";
        MembershipPointsEntry: Record "NPR MM Members. Points Entry";
    begin

        if (not Membership.Get(MembershipEntryNo)) then
            exit;

        exit(AdjustPointsAbsoluteWorker(MembershipEntryNo, MembershipPointsEntry."Entry Type"::POINT_DEPOSIT, Abs(Points), Abs("Amount (LCY)"), Today, ReceiptNo));

    end;

    procedure ManualRedeemPointsDeposit2(MembershipEntryNo: Integer; ReceiptNo: Code[20]; Points: Integer; "Amount (LCY)": Decimal; TransactionDate: Date; PostingDate: Date; Description: Text[50]) EntryNo: Integer
    var
        Membership: Record "NPR MM Membership";
        MembershipPointsEntry: Record "NPR MM Members. Points Entry";
    begin

        if (not Membership.Get(MembershipEntryNo)) then
            exit;

        exit(AdjustPointsAbsoluteWorker2(MembershipEntryNo, MembershipPointsEntry."Entry Type"::POINT_DEPOSIT, Abs(Points), Abs("Amount (LCY)"), TransactionDate, PostingDate, ReceiptNo, Description));

    end;

    procedure ManualExpirePoints(MembershipEntryNo: Integer; ReceiptNo: Code[20]; Points: Integer; "Amount (LCY)": Decimal; Description: Text[50]) EntryNo: Integer
    var
        Membership: Record "NPR MM Membership";
        MembershipPointsEntry: Record "NPR MM Members. Points Entry";
    begin

        if (not Membership.Get(MembershipEntryNo)) then
            exit;

        exit(AdjustPointsAbsoluteWorker(MembershipEntryNo, MembershipPointsEntry."Entry Type"::EXPIRED, -1 * Abs(Points), -1 * Abs("Amount (LCY)"), Today, ReceiptNo));

    end;

    procedure ExpireFixedPeriodPoints(LoyaltyCode: Code[20])
    var
        LoyaltySetup: Record "NPR MM Loyalty Setup";
        MembershipSetup: Record "NPR MM Membership Setup";
        Membership: Record "NPR MM Membership";
        CollectionPeriodStart: Date;
        CollectionPeriodEnd: Date;
        ExpirePeriodStart: Date;
        ExpirePeriodEnd: Date;
        Window: Dialog;
        RecordCount: Integer;
        ProgressCount: Integer;
        ReasonText: Text;
    begin

        LoyaltySetup.Get(LoyaltyCode);
        LoyaltySetup.TestField("Expire Uncollected Points");
        LoyaltySetup.TestField("Expire Uncollected After");

        if (LoyaltySetup."Collection Period" = LoyaltySetup."Collection Period"::FIXED) then begin

            CalculatePointsValidPeriod(LoyaltySetup, Today, CollectionPeriodStart, CollectionPeriodEnd);
            CalculatePointsValidPeriod(LoyaltySetup, CalcDate('<-1D>', CollectionPeriodStart), CollectionPeriodStart, CollectionPeriodEnd);

            // when we are inside the current expire period, we need to look at one period earlier
            CalculateCurrentExpiryDate(LoyaltySetup, ExpirePeriodStart, ExpirePeriodEnd, ReasonText);
            if (Today <= ExpirePeriodEnd) then
                CalculatePointsValidPeriod(LoyaltySetup, CalcDate('<-1D>', CollectionPeriodStart), CollectionPeriodStart, CollectionPeriodEnd);

            ExpirePeriodStart := CalcDate('<+1D>', CollectionPeriodStart);
            ExpirePeriodEnd := CalcDate(LoyaltySetup."Expire Uncollected After", CollectionPeriodEnd);

            if (not Confirm(CONFIRM_EXPIRE_POINTS, true, CollectionPeriodEnd, Today)) then
                Error('');

        end;

        if (LoyaltySetup."Collection Period" = LoyaltySetup."Collection Period"::AS_YOU_GO) then begin
            ExpirePeriodStart := 0D;
            ExpirePeriodEnd := CalcDate(LoyaltySetup."Expire Uncollected After", Today);
            CollectionPeriodStart := ExpirePeriodEnd;
            CollectionPeriodEnd := ExpirePeriodEnd;

            if (not Confirm(CONFIRM_EXPIRE_POINTS, true, CollectionPeriodEnd, Today)) then
                Error('');
        end;

        MembershipSetup.SetFilter("Loyalty Code", '=%1', LoyaltyCode);
        if (MembershipSetup.FindSet()) then begin
            repeat

                Membership.SetFilter("Membership Code", '=%1', MembershipSetup.Code);
                if (Membership.FindSet()) then begin
                    RecordCount := Membership.Count();
                    ProgressCount := 0;

                    if (GuiAllowed()) then begin
                        Window.Open(PROGRESS_DIALOG);
                        Window.Update(1, MembershipSetup.Description);
                    end;

                    repeat
                        if (GuiAllowed()) then
                            Window.Update(2, Round(10000 / RecordCount * ProgressCount, 1));

                        ExpirePointsPerPeriodWorker(LoyaltySetup, Membership);

                        if ((ProgressCount mod 50) = 0) then
                            Commit();

                        ProgressCount += 1;

                    until (Membership.Next() = 0);
                end;
            until (MembershipSetup.Next() = 0);

            if (GuiAllowed()) then
                Window.Close();

        end;

    end;

    procedure ExpirePointsPerPeriodWorker(LoyaltySetup: Record "NPR MM Loyalty Setup"; Membership: Record "NPR MM Membership")
    var
        TempMembershipPointsSummary: Record "NPR MM Members. Points Summary" temporary;
        Period: Integer;
        MembershipPointsEntry: Record "NPR MM Members. Points Entry";
        ExpireLbl: Label 'EXP-%1', Locked = true;
    begin

        if (not LoyaltySetup."Expire Uncollected Points") then
            exit;

        TempMembershipPointsSummary."Membership Entry No." := Membership."Entry No.";

        for Period := 0 downto -5 do begin
            TempMembershipPointsSummary."Relative Period" := Period;
            GetRelativePeriodToday(LoyaltySetup, Period, TempMembershipPointsSummary."Earn Period Start", TempMembershipPointsSummary."Earn Period End");

            TempMembershipPointsSummary."Points Remaining" := CalculateRedeemablePointsRelativePeriod(Membership."Entry No.", Period);
            TempMembershipPointsSummary."Burn Period Start" := CalcDate('<+1D>', TempMembershipPointsSummary."Earn Period End");
            TempMembershipPointsSummary."Burn Period End" := CalcDate(LoyaltySetup."Expire Uncollected After", TempMembershipPointsSummary."Burn Period Start");

            TempMembershipPointsSummary.Insert();

            if (TempMembershipPointsSummary."Points Remaining" <> 0) then
                if (TempMembershipPointsSummary."Burn Period End" < Today) then
                    AdjustPointsAbsoluteWorker2(Membership."Entry No.", MembershipPointsEntry."Entry Type"::EXPIRED, -1 * TempMembershipPointsSummary."Points Remaining", 0,
                                                 TempMembershipPointsSummary."Burn Period End", TempMembershipPointsSummary."Burn Period End",
                                                 StrSubstNo(ExpireLbl, Format(Today(), 0, 9)), 'Points Expiry');
        end;

    end;

    procedure GetNextLoyaltyTier(MembershipEntryNo: Integer; Upgrade: Boolean; var LoyaltyAlterMembership: Record "NPR MM Loyalty Alter Members."): Boolean
    begin
        exit(
          EligibleForMembershipAlteration(MembershipEntryNo, Upgrade, true, LoyaltyAlterMembership));
    end;

    local procedure EligibleForCoupon(MembershipEntryNo: Integer; var TempValidCouponToCreate: Record "NPR MM Loyalty Point Setup" temporary): Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        LoyaltySetup: Record "NPR MM Loyalty Setup";
        MembershipEntry: Record "NPR MM Membership Entry";
        AvailablePoints: Integer;
        ReasonText: Text;
    begin
        if (not Membership.Get(MembershipEntryNo)) then
            exit(false);

        if (not MembershipSetup.Get(Membership."Membership Code")) then
            exit(false);

        if (MembershipSetup."Loyalty Code" = '') then
            exit(false);

        if (not LoyaltySetup.Get(MembershipSetup."Loyalty Code")) then
            exit(false);

        MembershipEntry.SetCurrentKey("Entry No.");
        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        if (not MembershipEntry.FindLast()) then
            exit(false);

        AvailablePoints := CalculateAvailablePoints(MembershipEntryNo, Today, true);

        GetEligibleCouponsToRedeemWorker(MembershipEntryNo, TempValidCouponToCreate, 0, AvailablePoints, ReasonText);
        exit(TempValidCouponToCreate.Count() > 0);
    end;

    local procedure EligibleForMembershipAlteration(MembershipEntryNo: Integer; Upgrade: Boolean; GetNextTier: Boolean; var LoyaltyAlterMembership: Record "NPR MM Loyalty Alter Members."): Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        LoyaltySetup: Record "NPR MM Loyalty Setup";
        MembershipEntry: Record "NPR MM Membership Entry";
        AvailablePoints: Integer;
    begin

        if (not Membership.Get(MembershipEntryNo)) then
            exit(false);

        if (not MembershipSetup.Get(Membership."Membership Code")) then
            exit(false);

        if (MembershipSetup."Loyalty Code" = '') then
            exit(false);

        if (not LoyaltySetup.Get(MembershipSetup."Loyalty Code")) then
            exit(false);

        MembershipEntry.SetCurrentKey("Entry No.");
        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        if (not MembershipEntry.FindLast()) then
            exit(false);

        case LoyaltySetup."Auto Upgrade Point Source" of
            LoyaltySetup."Auto Upgrade Point Source"::PREVIOUS_PERIOD:
                AvailablePoints := CalculateAvailablePoints(MembershipEntryNo, Today, false);
            LoyaltySetup."Auto Upgrade Point Source"::UNCOLLECTED:
                AvailablePoints := CalculateAvailablePoints(MembershipEntryNo, Today, false);
            else
                exit(false);
        end;

        LoyaltyAlterMembership.SetCurrentKey("Loyalty Code", "From Membership Code", "Change Direction", "Points Threshold");
        LoyaltyAlterMembership.SetFilter("Loyalty Code", '=%1', MembershipSetup."Loyalty Code");
        LoyaltyAlterMembership.SetFilter("From Membership Code", '=%1', Membership."Membership Code");
        LoyaltyAlterMembership.SetFilter(Blocked, '=%1', false);

        if (GetNextTier) then begin
            case Upgrade of
                true:
                    begin
                        LoyaltyAlterMembership.SetFilter("Change Direction", '=%1', LoyaltyAlterMembership."Change Direction"::UPGRADE);
                        LoyaltyAlterMembership.SetFilter("Points Threshold", '%1..', AvailablePoints);
                        exit(LoyaltyAlterMembership.FindFirst());
                    end;

                false:
                    begin
                        LoyaltyAlterMembership.SetFilter("Change Direction", '=%1', LoyaltyAlterMembership."Change Direction"::DOWNGRADE);
                        LoyaltyAlterMembership.SetFilter("Points Threshold", '..%1', AvailablePoints);
                        exit(LoyaltyAlterMembership.FindLast());
                    end;
            end;
        end;

        case Upgrade of
            true:
                begin
                    LoyaltyAlterMembership.SetFilter("Change Direction", '=%1', LoyaltyAlterMembership."Change Direction"::UPGRADE);
                    LoyaltyAlterMembership.SetFilter("Points Threshold", '..%1', AvailablePoints);
                    if (not LoyaltyAlterMembership.FindLast()) then
                        exit(false);
                end;

            false:
                begin
                    LoyaltyAlterMembership.SetFilter("Change Direction", '=%1', LoyaltyAlterMembership."Change Direction"::DOWNGRADE);
                    LoyaltyAlterMembership.SetFilter("Points Threshold", '%1..', AvailablePoints);
                    if (not LoyaltyAlterMembership.FindFirst()) then
                        exit(false);
                end;
        end;

        exit(true);
    end;

    local procedure AlterMembership(MembershipEntryNo: Integer; LoyaltyAlterMembership: Record "NPR MM Loyalty Alter Members."): Boolean
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipStartDate: Date;
        MembershipUntilDate: Date;
        MembershipChangedLbl: Label 'Membership Change %1->%2 (%3)';
    begin

        MemberInfoCapture.Init();
        MemberInfoCapture."Entry No." := 0;

        MemberInfoCapture."Membership Entry No." := MembershipEntryNo;
        MemberInfoCapture."Membership Code" := LoyaltyAlterMembership."From Membership Code";
        MemberInfoCapture."Item No." := LoyaltyAlterMembership."Sales Item No.";
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::UPGRADE;
        MemberInfoCapture."Document Date" := Today();
        if (Format(LoyaltyAlterMembership."Defer Change Until") <> '') then
            MemberInfoCapture."Document Date" := CalcDate(LoyaltyAlterMembership."Defer Change Until", Today);

        MemberInfoCapture.Description :=
          CopyStr(
            StrSubstNo(MembershipChangedLbl, LoyaltyAlterMembership."From Membership Code", LoyaltyAlterMembership."To Membership Code", LoyaltyAlterMembership."Points Threshold"),
            1, MaxStrLen(MemberInfoCapture.Description));

        exit(MembershipManagement.UpgradeMembership(MemberInfoCapture, false, true, MembershipStartDate, MembershipUntilDate, MemberInfoCapture."Unit Price"));

    end;

    local procedure CalculateAvailablePoints(MembershipEntryNo: Integer; ReferenceDate: Date; ForThreshold: Boolean) AvailablePoints: Integer
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        LoyaltySetup: Record "NPR MM Loyalty Setup";
        ExpiredPoints: Integer;
        RedeemedPoints: Integer;
        RefundedPoints: Integer;
        EarnedPoints: Integer;
        PeriodStart: Date;
        PeriodEnd: Date;
    begin
        Membership.Get(MembershipEntryNo);
        MembershipSetup.Get(Membership."Membership Code");
        LoyaltySetup.Get(MembershipSetup."Loyalty Code");

        if (LoyaltySetup."Collection Period" = LoyaltySetup."Collection Period"::FIXED) then begin

            // Get period start and end for reference date
            CalculatePointsValidPeriod(LoyaltySetup, ReferenceDate, PeriodStart, PeriodEnd); // Current period
            Membership.SetFilter("Date Filter", '%1..%2', PeriodStart, PeriodEnd);

            Membership.CalcFields("Redeemed Points (Withdrawl)", "Awarded Points (Refund)", "Awarded Points (Sale)");
            // RedeemedPoints := Membership."Redeemed Points (Withdrawl)";
            RefundedPoints := Membership."Awarded Points (Refund)";
            EarnedPoints := Membership."Awarded Points (Sale)";

            // Redeem points have dates in the period after earn period
            Membership.SetFilter("Date Filter", '%1..%2', CalcDate('<+1D>', PeriodEnd), CalcDate(LoyaltySetup."Collection Period Length", CalcDate('<+1D>', PeriodEnd)));
            Membership.CalcFields("Redeemed Points (Withdrawl)");
            RedeemedPoints := Membership."Redeemed Points (Withdrawl)";

            if (LoyaltySetup."Expire Uncollected Points") then begin
                Membership.SetFilter("Date Filter", '=%1', CalcDate(LoyaltySetup."Expire Uncollected After", CalcDate('<+1D>', PeriodEnd)));
                Membership.CalcFields("Expired Points");
                ExpiredPoints := Membership."Expired Points";
            end;

            AvailablePoints := EarnedPoints + ExpiredPoints + RedeemedPoints + RefundedPoints;
            if (ForThreshold) then
                AvailablePoints := EarnedPoints + RefundedPoints;

        end;

        if (LoyaltySetup."Collection Period" = LoyaltySetup."Collection Period"::AS_YOU_GO) then begin

            CalculatePointsValidPeriod(LoyaltySetup, ReferenceDate, PeriodStart, PeriodEnd);
            Membership.SetFilter("Date Filter", '%1..%2', PeriodStart, PeriodEnd);

            Membership.CalcFields("Redeemed Points (Withdrawl)", "Awarded Points (Refund)", "Awarded Points (Sale)", "Expired Points");

            RefundedPoints := Membership."Awarded Points (Refund)";
            EarnedPoints := Membership."Awarded Points (Sale)";
            RedeemedPoints := Membership."Redeemed Points (Withdrawl)";
            ExpiredPoints := Membership."Expired Points";

            AvailablePoints := EarnedPoints + ExpiredPoints + RedeemedPoints + RefundedPoints;
            if (ForThreshold) then
                AvailablePoints := EarnedPoints + RefundedPoints;

        end;

        exit(AvailablePoints);

        //if (USERID = 'TSA') then MESSAGE ('Available points %1, redeemed %2, expired %3, thresholdcalculation %4', AvailablePoints, RedeemedPoints, ExpiredPoints, ForThreshold);
    end;

    procedure CalculateRedeemablePointsCurrentPeriod(MembershipEntryNo: Integer) RedeemablePoints: Integer
    begin
        exit(CalculateRedeemablePointsRelativePeriod(MembershipEntryNo, 0));
    end;

    procedure CalculateRedeemablePointsRelativePeriod(MembershipEntryNo: Integer; RelativePeriodNo: Integer) RedeemablePoints: Integer
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        LoyaltySetup: Record "NPR MM Loyalty Setup";
        PeriodStart: Date;
        PeriodEnd: Date;
    begin
        Membership.Get(MembershipEntryNo);
        MembershipSetup.Get(Membership."Membership Code");
        LoyaltySetup.Get(MembershipSetup."Loyalty Code");

        GetRelativePeriodToday(LoyaltySetup, RelativePeriodNo, PeriodStart, PeriodEnd);

        case (LoyaltySetup."Voucher Point Source") of
            LoyaltySetup."Voucher Point Source"::PREVIOUS_PERIOD:
                RedeemablePoints := CalculateAvailablePoints(MembershipEntryNo, PeriodEnd, false);
            LoyaltySetup."Voucher Point Source"::UNCOLLECTED:
                RedeemablePoints := CalculateAvailablePoints(MembershipEntryNo, Today, false);
        end;
    end;

    procedure CalculateEarnedPointsCurrentPeriod(MembershipEntryNo: Integer) RedeemablePoints: Integer
    begin
        exit(CalculateEarnedPointsRelativePeriod(MembershipEntryNo, 0));
    end;

    procedure CalculateEarnedPointsRelativePeriod(MembershipEntryNo: Integer; RelativePeriodNo: Integer) RedeemablePoints: Integer
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        LoyaltySetup: Record "NPR MM Loyalty Setup";
        PeriodStart: Date;
        PeriodEnd: Date;
    begin

        Membership.Get(MembershipEntryNo);
        MembershipSetup.Get(Membership."Membership Code");
        LoyaltySetup.Get(MembershipSetup."Loyalty Code");

        GetRelativePeriodToday(LoyaltySetup, RelativePeriodNo, PeriodStart, PeriodEnd);

        case (LoyaltySetup."Voucher Point Source") of
            LoyaltySetup."Voucher Point Source"::PREVIOUS_PERIOD:
                RedeemablePoints := CalculateAvailablePoints(MembershipEntryNo, PeriodEnd, true);
            LoyaltySetup."Voucher Point Source"::UNCOLLECTED:
                RedeemablePoints := CalculateAvailablePoints(MembershipEntryNo, Today, true);
        end;

    end;

    procedure CalculateSpendPeriod(MembershipEntryNo: Integer; ReferenceDate: Date; var SpendPeriodStart: Date; var SpendPeriodEnd: Date): Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        LoyaltySetup: Record "NPR MM Loyalty Setup";
    begin

        Membership.Get(MembershipEntryNo);
        MembershipSetup.Get(Membership."Membership Code");
        LoyaltySetup.Get(MembershipSetup."Loyalty Code");

        CalculatePointsValidPeriod(LoyaltySetup, ReferenceDate, SpendPeriodStart, SpendPeriodEnd);

        if (LoyaltySetup."Expire Uncollected Points") then
            SpendPeriodEnd := CalcDate(LoyaltySetup."Expire Uncollected After", SpendPeriodStart);

        if ((ReferenceDate >= SpendPeriodStart) and (ReferenceDate <= SpendPeriodEnd)) then
            exit;

        if (ReferenceDate > SpendPeriodEnd) then begin
            CalculatePointsValidPeriod(LoyaltySetup, CalcDate('<+1D>', SpendPeriodEnd), SpendPeriodStart, SpendPeriodEnd);
            CalculatePointsValidPeriod(LoyaltySetup, CalcDate('<+1D>', SpendPeriodEnd), SpendPeriodStart, SpendPeriodEnd);
            if (LoyaltySetup."Expire Uncollected Points") then
                SpendPeriodEnd := CalcDate(LoyaltySetup."Expire Uncollected After", SpendPeriodStart);
            exit;
        end;

        CalculatePointsValidPeriod(LoyaltySetup, CalcDate('<-1D>', SpendPeriodStart), SpendPeriodStart, SpendPeriodEnd);
        if (LoyaltySetup."Expire Uncollected Points") then
            SpendPeriodEnd := CalcDate(LoyaltySetup."Expire Uncollected After", SpendPeriodStart);

    end;

    procedure CalculatePeriodPointsSummary(MembershipEntryNo: Integer; var TmpMembershipPointsSummary: Record "NPR MM Members. Points Summary" temporary)
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        LoyaltySetup: Record "NPR MM Loyalty Setup";
        Period: Integer;
    begin

        if (not Membership.Get(MembershipEntryNo)) then
            exit;

        if (not MembershipSetup.Get(Membership."Membership Code")) then
            exit;

        if (not (LoyaltySetup.Get(MembershipSetup."Loyalty Code"))) then
            exit;

        if (LoyaltySetup."Voucher Point Source" <> LoyaltySetup."Voucher Point Source"::PREVIOUS_PERIOD) then
            exit;

        if (LoyaltySetup."Collection Period" = LoyaltySetup."Collection Period"::FIXED) then begin
            Period := 0;
            repeat
                CalculateFixedPeriodPointsTransaction(LoyaltySetup, Membership, Period, TmpMembershipPointsSummary);
                Period := Period - 1;
            until ((TmpMembershipPointsSummary."Points Expired" = 0) and (TmpMembershipPointsSummary."Points Remaining" = 0) and (TmpMembershipPointsSummary."Points Earned" = 0) and (Period < -1));
            TmpMembershipPointsSummary.Delete();
        end;

        if ((LoyaltySetup."Collection Period" = LoyaltySetup."Collection Period"::AS_YOU_GO) and (LoyaltySetup."Expire Uncollected Points")) then begin
            Period := 0;
            repeat
                CalculateFixedPeriodPointsTransaction(LoyaltySetup, Membership, Period, TmpMembershipPointsSummary);
                Period := Period - 1;
            until ((TmpMembershipPointsSummary."Points Expired" = 0) and (TmpMembershipPointsSummary."Points Remaining" = 0) and (TmpMembershipPointsSummary."Points Earned" = 0));
            TmpMembershipPointsSummary.Delete();
        end;
    end;

    procedure CalculateFixedPeriodPointsTransaction(LoyaltySetup: Record "NPR MM Loyalty Setup"; Membership: Record "NPR MM Membership"; RelativePeriod: Integer; var TmpMembershipPointsSummary: Record "NPR MM Members. Points Summary" temporary)
    var
        TempLoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup" temporary;
        ReasonText: Text;
    begin

        TmpMembershipPointsSummary.Init();
        GetRelativePeriodToday(LoyaltySetup, RelativePeriod, TmpMembershipPointsSummary."Earn Period Start", TmpMembershipPointsSummary."Earn Period End");

        TmpMembershipPointsSummary."Membership Entry No." := Membership."Entry No.";
        TmpMembershipPointsSummary."Relative Period" := RelativePeriod;

        TmpMembershipPointsSummary."Points Earned" := CalculateEarnedPointsRelativePeriod(Membership."Entry No.", RelativePeriod);
        TmpMembershipPointsSummary."Points Remaining" := CalculateRedeemablePointsRelativePeriod(Membership."Entry No.", RelativePeriod);
        TmpMembershipPointsSummary."Points Redeemed" := (TmpMembershipPointsSummary."Points Earned" - TmpMembershipPointsSummary."Points Remaining");

        if (LoyaltySetup."Expire Uncollected Points") then begin
            if (LoyaltySetup."Collection Period" = LoyaltySetup."Collection Period"::FIXED) then begin
                TmpMembershipPointsSummary."Burn Period Start" := CalcDate('<+1D>', TmpMembershipPointsSummary."Earn Period End");
                TmpMembershipPointsSummary."Burn Period End" := CalcDate(LoyaltySetup."Expire Uncollected After", TmpMembershipPointsSummary."Burn Period Start");
            end;

            if (LoyaltySetup."Collection Period" = LoyaltySetup."Collection Period"::AS_YOU_GO) then begin
                TmpMembershipPointsSummary."Burn Period Start" := TmpMembershipPointsSummary."Earn Period Start";
                TmpMembershipPointsSummary."Burn Period End" := TmpMembershipPointsSummary."Earn Period End";
            end;

            Membership.SetFilter("Date Filter", '=%1', TmpMembershipPointsSummary."Burn Period End");
            Membership.CalcFields("Expired Points");
            TmpMembershipPointsSummary."Points Expired" := Membership."Expired Points";
            TmpMembershipPointsSummary."Points Redeemed" += Membership."Expired Points";
        end else begin
            TmpMembershipPointsSummary."Points Expired" := 0;
            TmpMembershipPointsSummary."Burn Period Start" := CalcDate('<+1D>', TmpMembershipPointsSummary."Earn Period End");
            TmpMembershipPointsSummary."Burn Period End" := CalcDate(LoyaltySetup."Collection Period Length", TmpMembershipPointsSummary."Burn Period Start");
        end;

        // Estimate value of points
        if (DoGetCoupon(Membership."Entry No.", TempLoyaltyPointsSetup, 1000000000, TmpMembershipPointsSummary."Points Earned", TmpMembershipPointsSummary."Points Remaining", ReasonText)) then begin
            TempLoyaltyPointsSetup.Reset();
            TempLoyaltyPointsSetup.SetCurrentKey(Code, "Amount LCY");
            TempLoyaltyPointsSetup.FindLast();
            TmpMembershipPointsSummary."Amount Earned (LCY)" := Round(TmpMembershipPointsSummary."Points Earned" * TempLoyaltyPointsSetup."Point Rate", 1);
            TmpMembershipPointsSummary."Amount Redeemed (LCY)" := Round(TmpMembershipPointsSummary."Points Redeemed" * TempLoyaltyPointsSetup."Point Rate", 1);
            TmpMembershipPointsSummary."Amount Remaining (LCY)" := Round(TmpMembershipPointsSummary."Points Remaining" * TempLoyaltyPointsSetup."Point Rate", 1);
        end;

        TmpMembershipPointsSummary.Insert();

    end;

    local procedure GetRelativePeriodToday(LoyaltySetup: Record "NPR MM Loyalty Setup"; RelativePeriodNo: Integer; var PeriodStart: Date; var PeriodEnd: Date)
    begin
        GetRelativePeriodRefDate(LoyaltySetup, RelativePeriodNo, Today, PeriodStart, PeriodEnd);
    end;

    local procedure GetRelativePeriodRefDate(LoyaltySetup: Record "NPR MM Loyalty Setup"; RelativePeriodNo: Integer; ReferenceDate: Date; var PeriodStart: Date; var PeriodEnd: Date)
    var
        Period: Integer;
    begin

        CalculatePointsValidPeriod(LoyaltySetup, ReferenceDate, PeriodStart, PeriodEnd);

        for Period := 1 to Abs(RelativePeriodNo) do begin
            if (RelativePeriodNo < 0) then
                ReferenceDate := CalcDate('<-1D>', PeriodStart);
            if (RelativePeriodNo > 0) then
                ReferenceDate := CalcDate('<+1D>', PeriodEnd);

            CalculatePointsValidPeriod(LoyaltySetup, ReferenceDate, PeriodStart, PeriodEnd);
        end;
    end;

    local procedure SelectCouponFromCouponSetup(var TmpLoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup" temporary; PointsToSpend: Integer; var LoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup")
    begin
        if (PointsToSpend < TmpLoyaltyPointsSetup."Points Threshold") then // can be true when points are spent from previous period
            TmpLoyaltyPointsSetup."Points Threshold" := PointsToSpend;

        if (LoyaltyPointsSetup."Consume Available Points") then
            TmpLoyaltyPointsSetup."Points Threshold" := PointsToSpend;

        if (PointsToSpend > 0) then
            TmpLoyaltyPointsSetup.Insert();
    end;

    local procedure SelectCouponFromLoyaltySetup(var TmpLoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup" temporary; SubTotal: Decimal; PointsToSpend: Integer)
    begin
        TmpLoyaltyPointsSetup."Amount LCY" := SubTotal;
        if (PointsToSpend * TmpLoyaltyPointsSetup."Point Rate" < SubTotal) then
            TmpLoyaltyPointsSetup."Amount LCY" := PointsToSpend * TmpLoyaltyPointsSetup."Point Rate";

        TmpLoyaltyPointsSetup."Points Threshold" := Round(TmpLoyaltyPointsSetup."Amount LCY" / TmpLoyaltyPointsSetup."Point Rate", 1);

        if (TmpLoyaltyPointsSetup."Amount LCY" >= TmpLoyaltyPointsSetup."Minimum Coupon Amount") then
            if (CouponTypeIsValid(TmpLoyaltyPointsSetup."Coupon Type Code")) then
                TmpLoyaltyPointsSetup.Insert();
    end;

    local procedure CreateCouponRequest(MembershipEntryNo: Integer; var TempValidCouponToCreate: Record "NPR MM Loyalty Point Setup" temporary)
    var
        CouponNotification: Record "NPR MM Membership Notific.";
        NotificationSetup: Record "NPR MM Member Notific. Setup";
        Membership: Record "NPR MM Membership";
        LoyaltyPointSetup: Record "NPR MM Loyalty Point Setup";
        LoyaltyMgr: Codeunit "NPR MM Loyalty Coupon Mgr";
    begin
        TempValidCouponToCreate.Reset();
        TempValidCouponToCreate.SetFilter("Notification Code", '<>%1', '');
        if (not TempValidCouponToCreate.FindSet()) then
            exit;

        if (not Membership.Get(MembershipEntryNo)) then
            exit;

        repeat
            if (NotificationSetup.Get(TempValidCouponToCreate."Notification Code")) then begin
                Clear(CouponNotification);
                CouponNotification."Membership Entry No." := MembershipEntryNo;
                CouponNotification."External Membership No." := Membership."External Membership No.";
                CouponNotification."Notification Trigger" := CouponNotification."Notification Trigger"::COUPON;
                CouponNotification."Template Filter Value" := NotificationSetup."Template Filter Value";
                CouponNotification."Target Member Role" := NotificationSetup."Target Member Role";
                CouponNotification."Processing Method" := NotificationSetup."Processing Method";
                CouponNotification."Notification Method Source" := CouponNotification."Notification Method Source"::MEMBER;
                CouponNotification."Date To Notify" := Today() + abs(NotificationSetup."Days Past");
                CouponNotification."Include NP Pass" := NotificationSetup."Include NP Pass";

                CouponNotification."Notification Code" := TempValidCouponToCreate."Notification Code";
                CouponNotification."Loyalty Point Setup Id" := TempValidCouponToCreate.SystemId;

                if (LoyaltyPointSetup.GetBySystemId(CouponNotification."Loyalty Point Setup Id")) then begin
                    CouponNotification."Coupon No." := LoyaltyMgr.IssueOneCoupon(LoyaltyPointSetup."Coupon Type Code", CouponNotification."Membership Entry No.", '', Today(), LoyaltyPointSetup."Points Threshold", 0);
                    CouponNotification.Insert();
                end;
            end;
        until (TempValidCouponToCreate.Next() = 0);
    end;

    local procedure CouponTypeIsValid(CouponTypeCode: Code[10]): Boolean
    var
        CouponType: Record "NPR NpDc Coupon Type";
    begin

        if (not CouponType.Get(CouponTypeCode)) then
            exit(false);

        if (not CouponType.Enabled) then
            exit(false);

        if ((CouponType."Ending Date" = CreateDateTime(0D, 0T)) and (Format(CouponType."Ending Date DateFormula") = '')) then
            exit(true);

        if ((CouponType."Ending Date" = CreateDateTime(0D, 0T)) and (Format(CouponType."Ending Date DateFormula") <> '')) then
            exit(CalcDate(CouponType."Ending Date DateFormula") > Today());

        if (CouponType."Ending Date" < CurrentDateTime()) then
            exit(false);

        exit(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Create Entry", 'OnAfterInsertRmaEntry', '', true, true)]
    local procedure OnReturnSale(POSRMALine: Record "NPR POS RMA Line"; POSEntry: Record "NPR POS Entry"; SalePOS: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line")
    var
        RMALine: Record "NPR POS RMA Line";
        MembershipPointsEntry: Record "NPR MM Members. Points Entry";
        OriginalPOSSalesLine: Record "NPR POS Entry Sales Line";
        OriginalPOSEntry: Record "NPR POS Entry";
    begin

        // Quickly check if the items is fully returned, if so continue with rest of the order
        POSRMALine.CalcFields("FF Total Qty Returned", "FF Total Qty Sold");
        if ((POSRMALine."FF Total Qty Sold" + POSRMALine."FF Total Qty Returned") <> 0) then
            exit;

        // Check that sales is a completly reversed
        OriginalPOSEntry.SetFilter("Document No.", '=%1', POSRMALine."Sales Ticket No.");
        if (not OriginalPOSEntry.FindFirst()) then
            exit;

        OriginalPOSSalesLine.SetFilter("POS Entry No.", '=%1', OriginalPOSEntry."Entry No.");
        OriginalPOSSalesLine.SetFilter(Type, '=%1', OriginalPOSSalesLine.Type::Item);
        if (not OriginalPOSSalesLine.FindSet()) then
            exit;

        repeat
            RMALine.SetFilter(RMALine."Sales Ticket No.", POSRMALine."Sales Ticket No.");
            RMALine.SetFilter("Returned Item No.", '=%1', OriginalPOSSalesLine."No.");
            RMALine.SetAutoCalcFields("FF Total Qty Returned", "FF Total Qty Sold");
            if (not RMALine.FindFirst()) then
                exit; // Not returned yet

            if ((RMALine."FF Total Qty Sold" + RMALine."FF Total Qty Returned") <> 0) then
                exit; // Not fully returned

        until (OriginalPOSSalesLine.Next() = 0);

        // Full Reversal - all item lines are returned
        // Support multiple coupons
        MembershipPointsEntry.SetFilter("Document No.", '=%1', POSRMALine."Sales Ticket No.");
        MembershipPointsEntry.SetFilter("Entry Type", '=%1', MembershipPointsEntry."Entry Type"::POINT_WITHDRAW);
        MembershipPointsEntry.SetFilter("Redeem Ref. Type", '=%1', MembershipPointsEntry."Redeem Ref. Type"::COUPON);
        MembershipPointsEntry.SetFilter(Adjustment, '=%1', false);
        if (not MembershipPointsEntry.FindSet()) then
            exit;

        repeat
            // Unredeem all coupon for sales
            UnRedeemPointsCoupon(MembershipPointsEntry."Entry No.", POSRMALine."Return Ticket No.", MembershipPointsEntry."Posting Date", MembershipPointsEntry."Redeem Reference No.");

        until (MembershipPointsEntry.Next() = 0);

    end;
}

