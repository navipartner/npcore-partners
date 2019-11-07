codeunit 6060139 "MM Loyalty Point Management"
{
    // MM1.17/TSA/20161214  CASE 243075 Member Point System Setup
    // MM1.22/TSA /20170731 CASE 285403 Integrate with Coupons, RedeemPointsCoupon(), GetCouponToRedeem()
    // MM1.22/TSA /20170808 CASE 285403 Added Subscriber OnAfterInsertMembershipEntry()
    // MM1.23/TSA /20171006 CASE 257011 Added the default Amount Factor and Point Rate calculations (was implicitly 1)
    // MM1.23/TSA /20171010 CASE 257011 Added functions to set points for a membership
    // MM1.24/TSA /20171205 CASE 297852 Added a check on blocked memberships
    // MM1.24/TSA /20171205 CASE 297852 Added auto-loyalty points for membership alterations
    // MM1.25/TSA /20171220 CASE 300685 cancel and regret dont reverse points on a new transaction
    // MM1.25/TSA /20180109 CASE 301612 Function SynchronizePointsAbsolute() ignored parameter ReferenceDate
    // MM1.25.01/TSA /20180123 CASE 300685 Regretting a new entry will leave the memberhship not active before returning the points
    // MM1.26/TSA /20180219 CASE 300685 Versioning
    // MM1.26/TSA /20171006 CASE 257011 AmountBase should not include point rate in calculation
    // MM1.28/TSA /20180425 CASE 307048 Refactored GetCouponToRedeem to handle new settings
    // MM1.29/TSA /20180518 CASE 314131 Added ManualExpirePoints function
    // MM1.29/TSA /20180518 CASE 314131 Added update wallet when NP Pass is activated
    // MM1.29.02/TSA/20180529 CASE 317673 Minor fixes, found during testing
    // MM1.32/TSA /20180711 CASE 318132 Wallet update optimization
    // MM1.32/TSA /20180712 CASE 321176 User Select for Coupon.
    // MM1.33/TSA /20180813 CASE 324660 Points handling in by OnFinishSale workflowstep
    // MM1.36/TSA /20181128 CASE 337873 "Awarded Points" did not consider sales quantity
    // MM1.36/TSA /20181128 CASE 337873 Refactored CreatePointEntryFromValueEntry() to due to duplicate points assigment when having multiple memberships on same sales order
    // MM1.37/TSA /20190226 CASE 343053 Expire loyalty points, some restructuring
    // MM1.37/TSA /20190227 CASE 343053 Cleaned / Removed green code
    // MM1.40/TSA /20190731 CASE 361664 Added Loyalty point based upgrade functionality
    // MM1.40/TSA /20190813 CASE 343352 Points on web. Refactored GetCouponToRedeem() -> GetCouponToRedeemPOS() added GetCouponToRedeemWS(), GetEligibleCouponsToRedeemWorker()
    // MM1.41/TSA /20191001 CASE 371095 Previous Period point threshold calculation, added CalculateSpendablePoints()
    // MM1.41/TSA /20191018 CASE 372777 Changed posting date for points earn base on membership alterations


    trigger OnRun()
    var
        MyValueEntry: Record "Value Entry";
    begin
    end;

    var
        RuleType: Option INCLUDE,EXCLUDE,NO_RULE;
        NO_COUPON_AVAILABLE: Label 'No coupons are available. Remaining points %1, threshold %2.';
        SELECT_COUPON: Label 'Select Discount Coupon';
        POINT_ASSIGNMENT: Label 'Point assigment on finish sale as opposed to point assignment during posting.';
        LoyaltyPostingSourceEnum: Option VALUE_ENTRY,MEMBERSHIP_ENTRY,POS_ENDOFSALE;
        PERIOD_SETUP_ERROR: Label 'The collection period dataformulas are setup correctly.';
        CONFIRM_EXPIRE_POINTS: Label 'Points earned until %1 will be expired on date %2.';
        PROGRESS_DIALOG: Label 'Expire loyalty points: #1##################\\@2@@@@@@@@@@@@@@@@@@';
        EXPIRE_CALC_PREV: Label 'When testing %1, previous period end %2 must be the day before current period start %3.';
        EXPIRE_CALC_NEXT: Label 'When testing %1, next period start %2 must be the day after previous period end %3.';
        MISSING_VALUE: Label 'Missing value in field %1.';
        EXPIRE_FORMULA: Label '%1  is expected to be greater than %2.';
        PointsCalculationOption: Option PREVIOUS_PERIOD,UNCOLLECTED;
        SUBTOTAL_ZERO: Label 'The SubTotal parameter must not be zero when discount type is based on "discount %" for %1 %2.';

    [EventSubscriber(ObjectType::Codeunit, 22, 'OnAfterInsertValueEntry', '', true, true)]
    local procedure OnAfterInsertValueEntry(var ValueEntry: Record "Value Entry";ItemJournalLine: Record "Item Journal Line")
    var
        POSSalesWorkflowStep: Record "POS Sales Workflow Step";
    begin

        if (ValueEntry."Document Type" = ValueEntry."Document Type"::" ") then begin

          // POS entries could be handled by OnFinishSale workflow
          POSSalesWorkflowStep.SetFilter ("Subscriber Function", '=%1', PointAssignmentStepName());
          if (POSSalesWorkflowStep.FindFirst ()) then
            if (POSSalesWorkflowStep.Enabled) then
              exit; // Handled by OnFinishSale workflow

        end;

        CreatePointEntryFromValueEntry (ValueEntry, LoyaltyPostingSourceEnum::VALUE_ENTRY);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060127, 'OnAfterInsertMembershipEntry', '', true, true)]
    local procedure OnAfterInsertMembershipEntry(MembershipEntry: Record "MM Membership Entry")
    var
        Membership: Record "MM Membership";
        MembershipSalesSetup: Record "MM Membership Sales Setup";
        MembershipAlterationSetup: Record "MM Membership Alteration Setup";
        ValueEntry: Record "Value Entry";
        Item: Record Item;
        AssignLoyaltyPoints: Boolean;
        AlterationFilterOption: Integer;
        Quantity: Decimal;
    begin

        if (MembershipEntry."Item No." = '') then
          exit;

        if (not (Membership.Get (MembershipEntry."Membership Entry No."))) then
          exit;

        if (MembershipEntry.Context = MembershipEntry.Context::NEW) or
          ((MembershipEntry.Context = MembershipEntry.Context::REGRET) and (MembershipEntry."Original Context" = MembershipEntry."Original Context"::NEW)) then begin

          MembershipSalesSetup.SetFilter (Type, '=%1', MembershipSalesSetup.Type::ITEM);
          MembershipSalesSetup.SetFilter ("No.", '=%1', MembershipEntry."Item No.");
          MembershipSalesSetup.SetFilter ("Assign Loyalty Points On Sale", '=%1', true);

          AssignLoyaltyPoints := MembershipSalesSetup.FindFirst ();

        end else begin

          AssignLoyaltyPoints := true;

          AlterationFilterOption := MembershipEntry.Context;
          if (AlterationFilterOption = MembershipEntry.Context::REGRET) then
            AlterationFilterOption := MembershipEntry."Original Context";

          case AlterationFilterOption of
            MembershipEntry.Context::RENEW     : MembershipAlterationSetup.SetFilter ("Alteration Type", '=%1', MembershipAlterationSetup."Alteration Type"::RENEW);
            MembershipEntry.Context::AUTORENEW : exit; //AutoRenew is always via invoice. Loyalty from Value Entry //MembershipAlterationSetup.SETFILTER ("Alteration Type", '=%1', MembershipAlterationSetup."Alteration Type"::AUTORENEW);
            MembershipEntry.Context::EXTEND    : MembershipAlterationSetup.SetFilter ("Alteration Type", '=%1', MembershipAlterationSetup."Alteration Type"::EXTEND);
            MembershipEntry.Context::UPGRADE   : MembershipAlterationSetup.SetFilter ("Alteration Type", '=%1', MembershipAlterationSetup."Alteration Type"::UPGRADE);
            MembershipEntry.Context::CANCEL    : MembershipAlterationSetup.SetFilter ("Alteration Type", '=%1', MembershipAlterationSetup."Alteration Type"::CANCEL);
          else
            AssignLoyaltyPoints := false;
          end;

          if (AssignLoyaltyPoints) then begin
            MembershipAlterationSetup.SetFilter ("Sales Item No.", '=%1', MembershipEntry."Item No.");
            if (MembershipAlterationSetup.FindFirst ()) then begin
              AssignLoyaltyPoints := MembershipAlterationSetup."Assign Loyalty Points On Sale";
            end else begin
              MembershipSalesSetup.SetFilter (Type, '=%1', MembershipSalesSetup.Type::ITEM);
              MembershipSalesSetup.SetFilter ("No.", '=%1', MembershipEntry."Item No.");
              MembershipSalesSetup.SetFilter ("Assign Loyalty Points On Sale", '=%1', true);
              AssignLoyaltyPoints := MembershipSalesSetup.FindFirst ();
            end;
          end;

        end;

        if (not AssignLoyaltyPoints) then
          exit;

        if (not Item.Get (MembershipEntry."Item No.")) then
          exit;

        if ((MembershipEntry."Activate On First Use") and (MembershipEntry."Valid From Date" = 0D)) then
          exit;

        Quantity := -1;
        if (MembershipEntry.Context in [MembershipEntry.Context::CANCEL, MembershipEntry.Context::REGRET]) then
          Quantity := 1;

        // Since customer no is not set on the regulare sales we need to forge a value entry on this type of sales to get our initial points
        //-MM1.37 [343053]
        // SimulateValueEntry (MembershipEntry."Valid From Date", MembershipEntry."Item No.", Quantity, Membership."Customer No.", MembershipEntry."Document No.", MembershipEntry.Amount, 0, LoyaltyPostingSourceEnum::MEMBERSHIP_ENTRY);
        SimulateValueEntry (
          DT2Date (MembershipEntry."Created At"), //-+MM1.41 [372777] MembershipEntry."Valid From Date",
          '',
          MembershipEntry."Item No.",
          Quantity,
          Membership."Customer No.",
          MembershipEntry."Document No.",
          MembershipEntry.Amount,
          0,
          LoyaltyPostingSourceEnum::MEMBERSHIP_ENTRY
          );
        //+MM1.37 [343053]
    end;

    [EventSubscriber(ObjectType::Table, 6150730, 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnDiscoverPointAssignmentSaleWorkflowStep(var Rec: Record "POS Sales Workflow Step";RunTrigger: Boolean)
    begin

        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
          exit;

        if (Rec."Subscriber Function" <> PointAssignmentStepName()) then
          exit;

        Rec.Description := POINT_ASSIGNMENT;
        Rec."Sequence No." := 31;
        Rec.Enabled := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150705, 'OnFinishSale', '', true, true)]
    local procedure PointAssignmentOnSale(POSSalesWorkflowStep: Record "POS Sales Workflow Step";SalePOS: Record "Sale POS")
    var
        AuditRoll: Record "Audit Roll";
    begin

        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
          exit;

        if (POSSalesWorkflowStep."Subscriber Function" <> PointAssignmentStepName()) then
          exit;

        // Calculate points and assign.
        AuditRoll.SetFilter ("Sales Ticket No.", '=%1', SalePOS."Sales Ticket No.");
        AuditRoll.SetFilter ("Register No.", '=%1', SalePOS."Register No.");
        AuditRoll.SetFilter (Type, '=%1', AuditRoll.Type::Item);

        if (AuditRoll.FindSet ()) then begin
          repeat
            //-MM1.37 [343053]
            // SimulateValueEntry (AuditRoll."Sale Date", AuditRoll."No.", AuditRoll.Quantity * -1, AuditRoll."Customer No.", AuditRoll."Sales Ticket No.",
            //  AuditRoll."Amount Including VAT", AuditRoll."Line Discount Amount", LoyaltyPostingSourceEnum::POS_ENDOFSALE);
            SimulateValueEntry (
              AuditRoll."Sale Date",
              AuditRoll."Register No.",
              AuditRoll."No.",
              AuditRoll.Quantity * -1,
              AuditRoll."Customer No.",
              AuditRoll."Sales Ticket No.",
              AuditRoll."Amount Including VAT",
              AuditRoll."Line Discount Amount",
              LoyaltyPostingSourceEnum::POS_ENDOFSALE
            );
            //+MM1.37 [343053]

          until (AuditRoll.Next () = 0);

        end;
    end;

    local procedure CurrCodeunitId(): Integer
    begin

        exit(CODEUNIT::"MM Loyalty Point Management");
    end;

    local procedure PointAssignmentStepName(): Text
    begin

        exit ('PointAssignmentOnSale');
    end;

    local procedure "--"()
    begin
    end;

    local procedure ErrorExit(var ReasonText: Text;ReasonMessage: Text): Boolean
    begin

        //-MM1.40 [343352]
        ReasonText := ReasonMessage;
        exit (false);

        //+MM1.40 [343352]
    end;

    local procedure SimulateValueEntry(PostingDate: Date;PosUnitNo: Code[10];ItemNo: Code[20];Quantity: Decimal;CustomerNo: Code[20];DocumentNo: Code[20];Amount: Decimal;DiscountAmount: Decimal;DataSource: Option)
    var
        ValueEntry: Record "Value Entry";
        Item: Record Item;
    begin

        if (ItemNo = '') then
          exit;

        if (CustomerNo = '') then
          exit;

        if (not Item.Get (ItemNo)) then
          exit;

        ValueEntry.Init ();
        ValueEntry."Posting Date" := PostingDate;
        ValueEntry."Item No." := ItemNo;
        ValueEntry."Source No." := CustomerNo;
        ValueEntry."Item Ledger Entry Type" := ValueEntry."Item Ledger Entry Type"::Sale;
        ValueEntry."Document No." := DocumentNo;
        ValueEntry."Valued Quantity" := Quantity;

        //-MM1.37 [343053]
        ValueEntry."Register No." := PosUnitNo;
        //+MM1.37 [343053]

        ValueEntry."Sales Amount (Actual)" := Amount;
        ValueEntry."Discount Amount" := DiscountAmount;

        ValueEntry."Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";

        CreatePointEntryFromValueEntry (ValueEntry, DataSource);
    end;

    local procedure CreatePointEntryFromValueEntry(ValueEntry: Record "Value Entry";LoyaltyPostingSource: Option): Boolean
    var
        Membership: Record "MM Membership";
        MembershipPointsEntry: Record "MM Membership Points Entry";
        MemberCommunity: Record "MM Member Community";
        MembershipSetup: Record "MM Membership Setup";
        LoyaltySetup: Record "MM Loyalty Setup";
        MembershipRole: Record "MM Membership Role";
        MembershipSalesSetup: Record "MM Membership Sales Setup";
        MembershipAlterationSetup: Record "MM Membership Alteration Setup";
        MembershipEntry: Record "MM Membership Entry";
        POSUnit: Record "POS Unit";
        UpgradeAlteration: Record "MM Loyalty Alter Membership";
        DowngradeAlteration: Record "MM Loyalty Alter Membership";
        MembershipManagement: Codeunit "MM Membership Management";
        AwardPoints: Boolean;
        MemberNotification: Codeunit "MM Member Notification";
        UpgradeAvailable: Boolean;
        DowngradeAvailable: Boolean;
    begin

        if (ValueEntry."Item Ledger Entry Type" <> ValueEntry."Item Ledger Entry Type"::Sale) then
          exit (false);

        if (ValueEntry."Source No." = '') then
          exit (false);

        Membership.SetFilter ("Customer No.", '=%1', ValueEntry."Source No.");
        Membership.SetFilter (Blocked, '=%1', false);
        if (not Membership.FindFirst ()) then
          exit (false);

        if (not MemberCommunity.Get (Membership."Community Code")) then
          exit (false);

        if (not MemberCommunity."Activate Loyalty Program") then
          exit (false);

        if (not MembershipSetup.Get (Membership."Membership Code")) then
          exit (false);

        if (not LoyaltySetup.Get (MembershipSetup."Loyalty Code")) then
          exit (false);

        if (Membership.Blocked) then
          exit (false);

        if (LoyaltyPostingSource in [LoyaltyPostingSourceEnum::POS_ENDOFSALE, LoyaltyPostingSourceEnum::VALUE_ENTRY]) then begin
          if (MembershipSalesSetup.Get (MembershipSalesSetup.Type::ITEM, ValueEntry."Item No.")) then
            if (MembershipSalesSetup."Assign Loyalty Points On Sale") then
              exit;

          MembershipEntry.SetFilter ("Membership Entry No.", '=%1', Membership."Entry No.");
          MembershipEntry.SetFilter (Blocked, '=%1', false);
          if (MembershipEntry.FindLast ()) then begin
            // should probably map the alteration types here.
            MembershipAlterationSetup.SetFilter ("Sales Item No.", '=%1', ValueEntry."Item No.");
            MembershipAlterationSetup.SetFilter ("From Membership Code", Membership."Membership Code");
            MembershipAlterationSetup.SetFilter ("To Membership Code", '=%1|=%2', '', Membership."Membership Code");
            MembershipAlterationSetup.SetFilter ("Assign Loyalty Points On Sale", '=%1', true);
            if (MembershipAlterationSetup.FindFirst ()) then
              exit;

            MembershipAlterationSetup.Reset;
            // should probably map the alteration types here.
            MembershipAlterationSetup.SetFilter ("Sales Item No.", '=%1', ValueEntry."Item No.");
            MembershipAlterationSetup.SetFilter ("To Membership Code", '=%2', '', Membership."Membership Code");
            MembershipAlterationSetup.SetFilter ("Assign Loyalty Points On Sale", '=%1', true);
            if (MembershipAlterationSetup.FindFirst ()) then
              exit;
          end;
        end;

        // -- Add the points entry
        MembershipPointsEntry.Init;
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
        //-MM1.37 [343053]
        if (POSUnit.Get (ValueEntry."Register No.")) then begin
          MembershipPointsEntry."POS Unit Code" := POSUnit."No.";
          MembershipPointsEntry."POS Store Code" := POSUnit."POS Store Code";
        end;
        //+MM1.37 [343053]

        MembershipPointsEntry."Amount (LCY)" := CalculateBaseAmount (ValueEntry, (LoyaltySetup."Amount Base" = LoyaltySetup."Amount Base"::INCL_VAT));
        MembershipPointsEntry.Quantity := ValueEntry."Valued Quantity" * -1;

        MembershipPointsEntry."Point Constraint" := MembershipPointsEntry."Point Constraint"::EXCLUDE;

        AwardPoints := MembershipManagement.IsMembershipActive (Membership."Entry No.", ValueEntry."Posting Date", true);
        if (AwardPoints) or (MembershipPointsEntry."Entry Type" = MembershipPointsEntry."Entry Type"::REFUND) then begin
          MembershipPointsEntry."Point Constraint" := CalculateAwardedPoints (LoyaltySetup,
            MembershipPointsEntry."Posting Date", MembershipPointsEntry."Item No.", MembershipPointsEntry."Variant Code",
            Abs (MembershipPointsEntry."Amount (LCY)"), (ValueEntry."Discount Amount" <> 0),
            MembershipPointsEntry."Awarded Amount (LCY)", MembershipPointsEntry."Awarded Points", MembershipPointsEntry."Loyalty Item Point Line No.");

          MembershipPointsEntry."Awarded Points" *= MembershipPointsEntry.Quantity;
          MembershipPointsEntry.Points := Round (MembershipPointsEntry."Awarded Amount (LCY)", 1) + Round (MembershipPointsEntry."Awarded Points", 1);

          if (MembershipPointsEntry."Entry Type" = MembershipPointsEntry."Entry Type"::REFUND) then begin
            MembershipPointsEntry.Points *= -1;
            MembershipPointsEntry."Awarded Points" *= -1;
            MembershipPointsEntry."Awarded Amount (LCY)" *= -1;
          end;
        end;

        CalcultatePointsValidPeriod (LoyaltySetup, MembershipPointsEntry."Posting Date", MembershipPointsEntry."Period Start", MembershipPointsEntry."Period End");

        if (MembershipPointsEntry.Insert()) then ;

        //-MM1.40 [361664]
        // Check for upgrade
        UpgradeAvailable := EligibleForMembershipAlteration (Membership."Entry No.", true, UpgradeAlteration);
        DowngradeAvailable := EligibleForMembershipAlteration (Membership."Entry No.", false, DowngradeAlteration);

        if (UpgradeAvailable and not DowngradeAvailable) then
          AlterMembership (Membership."Entry No.", UpgradeAlteration);

        if (DowngradeAvailable and not UpgradeAvailable) then
          AlterMembership (Membership."Entry No.", DowngradeAlteration);

        //+MM1.40 [361664]

        if (MembershipSetup."Enable NP Pass Integration") then begin

          MembershipRole.SetFilter ("Membership Entry No.", '=%1', Membership."Entry No.");
          MembershipRole.SetFilter (Blocked, '=%1', false);
          MembershipRole.SetFilter ("Wallet Pass Id", '<>%1', '');
          if (not MembershipRole.IsEmpty ()) then
            MemberNotification.CreateUpdateWalletNotification (Membership."Entry No.", 0, 0);
        end;

        exit (true);
    end;

    local procedure CalculateBaseAmount(ValueEntry: Record "Value Entry";IncludeVAT: Boolean) AmountBase: Decimal
    var
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        VATProductPostingGroup: Record "VAT Product Posting Group";
        VATPostingSetup: Record "VAT Posting Setup";
    begin

        if (IncludeVAT) then begin
          if (not GenProductPostingGroup.Get (ValueEntry."Gen. Prod. Posting Group")) then
            exit (0);
          VATPostingSetup.SetFilter ("VAT Bus. Posting Group", '=%1', ValueEntry."Gen. Bus. Posting Group");
          VATPostingSetup.SetFilter ("VAT Prod. Posting Group", '=%1', GenProductPostingGroup."Def. VAT Prod. Posting Group");
          if (not VATPostingSetup.FindFirst ()) then
            exit (0);
          AmountBase := ValueEntry."Sales Amount (Actual)" * ( (100 + VATPostingSetup."VAT %") / 100.0 );
        end else begin
          AmountBase := ValueEntry."Sales Amount (Actual)";
        end;

        exit (AmountBase);
    end;

    local procedure CalculateAwardedPoints(LoyaltySetup: Record "MM Loyalty Setup";ReferenceDate: Date;ItemNo: Code[20];VariantCode: Code[10];AmountBase: Decimal;AmountIsDiscounted: Boolean;var AwardedAmount: Decimal;var AwardedPoints: Integer;var RuleReference: Integer): Integer
    var
        LoyaltyItemPointSetup: Record "MM Loyalty Item Point Setup";
        Item: Record Item;
    begin
        AwardedAmount := 0;
        AwardedPoints := 0;
        RuleReference := 0;

        // Check Settings level Exclude
        if (AmountIsDiscounted) then
          if (not LoyaltySetup."Points On Discounted Sales") then begin
            //-MM1.29.02 [317673]
            AwardedAmount := 0;
            AwardedPoints := 0;
            //+MM1.29.02 [317673]
            exit (RuleType::EXCLUDE);
          end;

        if (LoyaltySetup."Amount Factor" <> 0) then
          AmountBase := (AmountBase * LoyaltySetup."Amount Factor");

        if (LoyaltySetup."Point Base" = LoyaltySetup."Point Base"::AMOUNT) then begin
          AwardedAmount := AmountBase;
          AwardedPoints := 0;
          RuleReference := 0;
          exit (ApplyRule (LoyaltySetup.Code, RuleReference, AmountBase, AwardedAmount, AwardedPoints));
        end;

        AwardedAmount := 0;
        AwardedPoints := 0;
        Item.Get (ItemNo);

        if (CheckItemRule (LoyaltySetup.Code, ReferenceDate, ItemNo, VariantCode, AmountIsDiscounted, RuleReference) = RuleType::EXCLUDE) then
          exit (RuleType::EXCLUDE);

        if (CheckItemGroupRule (LoyaltySetup.Code, ReferenceDate, ItemNo, AmountIsDiscounted, RuleReference) = RuleType::EXCLUDE) then
          exit (RuleType::EXCLUDE);

        if (CheckItemVendorRule (LoyaltySetup.Code, ReferenceDate, ItemNo, AmountIsDiscounted, RuleReference) = RuleType::EXCLUDE) then
          exit (RuleType::EXCLUDE);

        // This item will award points by default as sales amount
        if (LoyaltySetup."Point Base" = LoyaltySetup."Point Base"::AMOUNT_ITEM_SETUP) then begin
          AwardedAmount := AmountBase;
          AwardedPoints := Round (AmountBase, 1);
        end;

        // This item will award points only if there is a include rule
        if (LoyaltySetup."Point Base" = LoyaltySetup."Point Base"::ITEM_SETUP) then begin
          AwardedAmount := 0;
          AwardedPoints := 0
        end;

        // Check include rules
        if (CheckItemRule (LoyaltySetup.Code, ReferenceDate, ItemNo, VariantCode, AmountIsDiscounted, RuleReference) = RuleType::INCLUDE) then
          exit (ApplyRule (LoyaltySetup.Code, RuleReference, AmountBase, AwardedAmount, AwardedPoints));

        if (CheckItemGroupRule (LoyaltySetup.Code, ReferenceDate, ItemNo, AmountIsDiscounted, RuleReference) = RuleType::INCLUDE) then
          exit (ApplyRule (LoyaltySetup.Code, RuleReference, AmountBase, AwardedAmount, AwardedPoints));

        if (CheckItemVendorRule (LoyaltySetup.Code, ReferenceDate, ItemNo, AmountIsDiscounted, RuleReference) = RuleType::INCLUDE) then
          exit (ApplyRule (LoyaltySetup.Code, RuleReference, AmountBase, AwardedAmount, AwardedPoints));

        // No rule implies include in loyalty when amount based
        if (LoyaltySetup."Point Base" = LoyaltySetup."Point Base"::AMOUNT_ITEM_SETUP) then
          exit (ApplyRule (LoyaltySetup.Code, RuleReference, AmountBase, AwardedAmount, AwardedPoints));

        // No rule implies exclude from loyalty when rule based
        if (LoyaltySetup."Point Base" = LoyaltySetup."Point Base"::ITEM_SETUP) then
          exit (RuleType::EXCLUDE);
    end;

    procedure CalcultatePointsValidPeriod(LoyaltySetup: Record "MM Loyalty Setup";ReferenceDate: Date;var ValidFromDate: Date;var ValidUnitlDate: Date)
    begin

        //-MM1.37 [343053]
        if (ReferenceDate = 0D) then
          ReferenceDate := Today;

        ValidFromDate := 0D;
        ValidUnitlDate := 0D;
        //+MM1.37 [343053]

        case LoyaltySetup."Collection Period" of
          LoyaltySetup."Collection Period"::AS_YOU_GO : begin
            ValidFromDate := ReferenceDate;
            if (Format (LoyaltySetup."Expire Uncollected After") <> '') then
              ValidUnitlDate := CalcDate (LoyaltySetup."Expire Uncollected After", ReferenceDate);
          end;

          LoyaltySetup."Collection Period"::FIXED : begin
            if (Format (LoyaltySetup."Fixed Period Start") <> '') then begin
              ValidFromDate := CalcDate (LoyaltySetup."Fixed Period Start", ReferenceDate);

              if (Format (LoyaltySetup."Collection Period Length") <> '') then
                ValidUnitlDate := CalcDate (LoyaltySetup."Collection Period Length", ValidFromDate);

            end;
          end;

        end;
    end;

    procedure ValidateFixedPeriodCalculation(LoyaltySetup: Record "MM Loyalty Setup";var ReasonText: Text) PeriodCalculationIssue: Boolean
    var
        LoyaltyPointManagement: Codeunit "MM Loyalty Point Management";
        CollectionPeriodStart: Date;
        CollectionPeriodEnd: Date;
        TestPeriodStart: Date;
        TestPeriodEnd: Date;
        ExpirePointsAt: Date;
    begin

        //-MM1.37 [343053]
        ReasonText := '';

        with LoyaltySetup do begin
          if (not ("Collection Period" = "Collection Period"::FIXED)) then
            exit (true);

          if (Format (LoyaltySetup."Collection Period Length") = '') then begin
            ReasonText := StrSubstNo (MISSING_VALUE, LoyaltySetup.FieldCaption ("Collection Period Length"));
            exit (false);
          end;

          if (Format (LoyaltySetup."Fixed Period Start") = '') then begin
            ReasonText := StrSubstNo (MISSING_VALUE, LoyaltySetup.FieldCaption ("Fixed Period Start"));
            exit (false);
          end;

          CalcultatePointsValidPeriod (LoyaltySetup, Today, CollectionPeriodStart, CollectionPeriodEnd);

          if (CollectionPeriodStart <> 0D) and (CollectionPeriodEnd <> 0D) then begin
            LoyaltyPointManagement.CalcultatePointsValidPeriod (LoyaltySetup, CalcDate ('<-1D>', CollectionPeriodStart), TestPeriodStart, TestPeriodEnd);
            PeriodCalculationIssue := (TestPeriodEnd >= CollectionPeriodStart);
            ReasonText := StrSubstNo (EXPIRE_CALC_PREV, CalcDate ('<-1D>', CollectionPeriodStart), TestPeriodEnd, CollectionPeriodStart);

            LoyaltyPointManagement.CalcultatePointsValidPeriod (LoyaltySetup, CalcDate ('<+1D>', CollectionPeriodEnd), TestPeriodStart, TestPeriodEnd);
            PeriodCalculationIssue := PeriodCalculationIssue or (TestPeriodStart <= CollectionPeriodEnd);
            ReasonText := StrSubstNo (EXPIRE_CALC_NEXT, CalcDate ('<+1D>', CollectionPeriodEnd), TestPeriodStart, CollectionPeriodEnd);
          end;

          if (not PeriodCalculationIssue) then begin
            ExpirePointsAt := 0D;
            if ("Expire Uncollected Points") then
              if (Format ("Expire Uncollected After") <> '') then
                ExpirePointsAt := CalcDate ("Expire Uncollected After", CollectionPeriodEnd);

            if (ExpirePointsAt <> 0D) and (ExpirePointsAt < CollectionPeriodEnd) then begin
              ReasonText := StrSubstNo (EXPIRE_FORMULA, ExpirePointsAt, CollectionPeriodEnd);
              exit (false);
            end;
          end;

        end;

        if (not PeriodCalculationIssue) then
          ReasonText := 'OK';

        exit (not PeriodCalculationIssue);
        //+MM1.37 [343053]
    end;

    local procedure CalculateCurrentExpiryDate(LoyaltySetup: Record "MM Loyalty Setup";var ExpirePointsAt: Date;var ReasonText: Text): Boolean
    var
        ReferenceDate: Date;
        CollectionPeriodStart: Date;
        CollectionPeriodEnd: Date;
    begin

        //-MM1.37 [343053]
        if (not LoyaltySetup."Expire Uncollected Points") then
          exit (false);

        if (not ValidateFixedPeriodCalculation (LoyaltySetup, ReasonText)) then
          Error (ReasonText);

        // Might have to do a couple of iterations to find the expire points data.
        ReferenceDate := Today;
        repeat

          CalcultatePointsValidPeriod (LoyaltySetup, ReferenceDate, CollectionPeriodStart, CollectionPeriodEnd);

          if (CollectionPeriodEnd = 0D) then
            Error (PERIOD_SETUP_ERROR);

          ExpirePointsAt := CalcDate (LoyaltySetup."Expire Uncollected After", CollectionPeriodEnd);
          ReferenceDate := CalcDate ('<-1D>', CollectionPeriodStart);

        until (ExpirePointsAt <= Today);

        exit (true);
        //+MM1.37 [343053]
    end;

    local procedure ApplyRule(LoyaltyCode: Code[20];RuleReference: Integer;AmountBase: Decimal;var AwardedAmount: Decimal;var AwardedPoints: Integer): Integer
    var
        LoyaltyItemPointSetup: Record "MM Loyalty Item Point Setup";
    begin

        AwardedAmount := AmountBase;
        AwardedPoints := 0;

        if (not LoyaltyItemPointSetup.Get (LoyaltyCode, RuleReference)) then
          exit (RuleType::INCLUDE);

        case LoyaltyItemPointSetup.Award of
          LoyaltyItemPointSetup.Award::AMOUNT : begin
            AwardedAmount := AmountBase * LoyaltyItemPointSetup."Amount Factor";
            AwardedPoints := 0;
          end;

          LoyaltyItemPointSetup.Award::POINTS : begin
            AwardedAmount := 0;
            AwardedPoints := LoyaltyItemPointSetup.Points;
          end;

          LoyaltyItemPointSetup.Award::POINTS_AND_AMOUNT :
            begin
              AwardedAmount := AmountBase * LoyaltyItemPointSetup."Amount Factor";
              AwardedPoints := LoyaltyItemPointSetup.Points;
            end;
        end;

        exit (RuleType::INCLUDE);
    end;

    local procedure "--RulesSelection"()
    begin
    end;

    local procedure CheckItemRule(LoyaltyCode: Code[20];ReferenceDate: Date;ItemNo: Code[20];VariantCode: Code[10];AmountIsDiscounted: Boolean;var RuleReference: Integer): Integer
    var
        LoyaltyItemPointSetup: Record "MM Loyalty Item Point Setup";
    begin

        // Check Variant
        LoyaltyItemPointSetup.Reset;
        LoyaltyItemPointSetup.SetFilter (Code, '=%1', LoyaltyCode);
        LoyaltyItemPointSetup.SetFilter (Type, '=%1', LoyaltyItemPointSetup.Type::Item);
        LoyaltyItemPointSetup.SetFilter (Blocked, '=%1', false);
        LoyaltyItemPointSetup.SetFilter ("No.", '=%1', ItemNo);
        LoyaltyItemPointSetup.SetFilter ("Variant Code", '=%1', VariantCode);
        LoyaltyItemPointSetup.SetFilter ("Valid From Date", '=%1|<=%2', 0D, ReferenceDate);
        LoyaltyItemPointSetup.SetFilter ("Valid Until Date", '=%1|>=%2', 0D, ReferenceDate);
        if (LoyaltyItemPointSetup.FindFirst ()) then begin
          if (AmountIsDiscounted) then begin
            LoyaltyItemPointSetup.SetFilter ("Allow On Discounted Sale", '=%1', true);
            if (LoyaltyItemPointSetup.FindFirst ()) then ;
          end;
          RuleReference := LoyaltyItemPointSetup."Line No.";
          exit (LoyaltyItemPointSetup.Constraint);
        end;

        // Check Item
        LoyaltyItemPointSetup.Reset;
        LoyaltyItemPointSetup.SetFilter (Code, '=%1', LoyaltyCode);
        LoyaltyItemPointSetup.SetFilter (Type, '=%1', LoyaltyItemPointSetup.Type::Item);
        LoyaltyItemPointSetup.SetFilter (Blocked, '=%1', false);
        LoyaltyItemPointSetup.SetFilter ("No.", '=%1', ItemNo);
        LoyaltyItemPointSetup.SetFilter ("Valid From Date", '=%1|<=%2', 0D, ReferenceDate);
        LoyaltyItemPointSetup.SetFilter ("Valid Until Date", '=%1|>=%2', 0D, ReferenceDate);
        if (LoyaltyItemPointSetup.FindFirst ()) then begin
          if (AmountIsDiscounted) then begin
            LoyaltyItemPointSetup.SetFilter ("Allow On Discounted Sale", '=%1', true);
            if (LoyaltyItemPointSetup.FindFirst ()) then ;
          end;

          RuleReference := LoyaltyItemPointSetup."Line No.";
          exit (LoyaltyItemPointSetup.Constraint);
        end;

        // No rule found
        RuleReference := 0;
        exit (RuleType::NO_RULE);
    end;

    local procedure CheckItemGroupRule(LoyaltyCode: Code[20];ReferenceDate: Date;ItemNo: Code[20];AmountIsDiscounted: Boolean;var RuleReference: Integer): Integer
    var
        LoyaltyItemPointSetup: Record "MM Loyalty Item Point Setup";
        Item: Record Item;
    begin
        Item.Get (ItemNo);
        // TODO traverse to root

        LoyaltyItemPointSetup.Reset;
        LoyaltyItemPointSetup.SetFilter (Code, '=%1', LoyaltyCode);
        LoyaltyItemPointSetup.SetFilter (Blocked, '=%1', false);
        LoyaltyItemPointSetup.SetFilter (Type, '=%1', LoyaltyItemPointSetup.Type::"Item Group");

        LoyaltyItemPointSetup.SetFilter ("No.", '=%1', Item."Item Group");
        LoyaltyItemPointSetup.SetFilter ("Valid From Date", '=%1|<=%2', 0D, ReferenceDate);
        LoyaltyItemPointSetup.SetFilter ("Valid Until Date", '=%1|>=%2', 0D, ReferenceDate);
        if (LoyaltyItemPointSetup.FindFirst ()) then begin
          if (AmountIsDiscounted) then begin
            LoyaltyItemPointSetup.SetFilter ("Allow On Discounted Sale", '=%1', true);
            if (LoyaltyItemPointSetup.FindFirst ()) then ;
          end;

          RuleReference := LoyaltyItemPointSetup."Line No.";
          exit (LoyaltyItemPointSetup.Constraint);
        end;

        // No rule found
        RuleReference := 0;
        exit (RuleType::NO_RULE);
    end;

    local procedure CheckItemVendorRule(LoyaltyCode: Code[20];ReferenceDate: Date;ItemNo: Code[20];AmountIsDiscounted: Boolean;var RuleReference: Integer): Integer
    var
        LoyaltyItemPointSetup: Record "MM Loyalty Item Point Setup";
        Item: Record Item;
    begin
        Item.Get (ItemNo);

        // This item group has an explicit include rule
        LoyaltyItemPointSetup.Reset;
        LoyaltyItemPointSetup.SetFilter (Code, '=%1', LoyaltyCode);
        LoyaltyItemPointSetup.SetFilter (Blocked, '=%1', false);
        LoyaltyItemPointSetup.SetFilter (Type, '=%1', LoyaltyItemPointSetup.Type::Vendor);

        LoyaltyItemPointSetup.SetFilter ("No.", '=%1', Item."Vendor No.");
        LoyaltyItemPointSetup.SetFilter ("Valid From Date", '=%1|<=%2', 0D, ReferenceDate);
        LoyaltyItemPointSetup.SetFilter ("Valid Until Date", '=%1|>=%2', 0D, ReferenceDate);
        if (LoyaltyItemPointSetup.FindFirst ()) then begin
          if (AmountIsDiscounted) then begin
            LoyaltyItemPointSetup.SetFilter ("Allow On Discounted Sale", '=%1', true);
            if (LoyaltyItemPointSetup.FindFirst ()) then ;
          end;

          RuleReference := LoyaltyItemPointSetup."Line No.";
          exit (LoyaltyItemPointSetup.Constraint);
        end;

        // No Rule Found
        RuleReference := 0;
        exit (RuleType::NO_RULE);
    end;

    local procedure "--consume points"()
    begin
    end;

    procedure IssueOneCoupon(MembershipEntryNo: Integer;var TmpLoyaltyPointsSetup: Record "MM Loyalty Points Setup" temporary;SubTotal: Decimal) CouponNo: Code[20]
    var
        Membership: Record "MM Membership";
        LoyaltyCouponMgr: Codeunit "MM Loyalty Coupon Mgr";
        PointsToRedeem: Integer;
        CouponAmount: Decimal;
        RedeemablePoints: Integer;
    begin

        //-MM1.40 [343352]
        if (TmpLoyaltyPointsSetup."Value Assignment" = TmpLoyaltyPointsSetup."Value Assignment"::FROM_COUPON) then
          CouponNo := LoyaltyCouponMgr.IssueOneCoupon (TmpLoyaltyPointsSetup."Coupon Type Code", MembershipEntryNo, TmpLoyaltyPointsSetup."Points Threshold", 0);

        if (TmpLoyaltyPointsSetup."Value Assignment" = TmpLoyaltyPointsSetup."Value Assignment"::FROM_LOYALTY) then begin
          Membership.Get (MembershipEntryNo);

          //-MM1.41 [371095]
          // Membership.CALCFIELDS ("Remaining Points");
          //RedeemablePoints := CalculateAvailablePoints (MembershipEntryNo, PointsCalculationOption::PREVIOUS_PERIOD, FALSE);
          RedeemablePoints := TmpLoyaltyPointsSetup."Points Threshold";
          //+MM1.41 [371095]

          CouponAmount := SubTotal;

        //-MM1.41 [371095]
          // IF (Membership."Remaining Points" * TmpLoyaltyPointsSetup."Point Rate" < SubTotal) THEN
          //   CouponAmount := Membership."Remaining Points" * TmpLoyaltyPointsSetup."Point Rate";
          if (RedeemablePoints * TmpLoyaltyPointsSetup."Point Rate" < SubTotal) then
            CouponAmount := RedeemablePoints * TmpLoyaltyPointsSetup."Point Rate";
            //-MM1.41 [371095]

          PointsToRedeem := Round (CouponAmount / TmpLoyaltyPointsSetup."Point Rate", 1);

          if (CouponAmount >= TmpLoyaltyPointsSetup."Minimum Coupon Amount") then
            CouponNo := LoyaltyCouponMgr.IssueOneCoupon (TmpLoyaltyPointsSetup."Coupon Type Code", MembershipEntryNo, PointsToRedeem, CouponAmount);

          // IF (USERID = 'TSA') THEN MESSAGE ('Coupon Amount %1, SubTotal %2, Points(redeemable) %3,  Points(redeemed) %4, Rate %5', CouponAmount, SubTotal, RedeemablePoints, PointsToRedeem, TmpLoyaltyPointsSetup."Point Rate");

        end;
        //+MM1.40 [343352]
    end;

    procedure RedeemPointsCoupon(MembershipEntryNo: Integer;DocumentNo: Code[20];DocumentDate: Date;CouponNo: Code[20];PointsToDeduct: Integer)
    var
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        MembershipPointsEntry: Record "MM Membership Points Entry";
    begin

        Membership.Get (MembershipEntryNo);
        MembershipSetup.Get (Membership."Membership Code");
        MembershipSetup.TestField ("Loyalty Code");

        MembershipPointsEntry."Entry No." := 0;

        MembershipPointsEntry."Entry Type" := MembershipPointsEntry."Entry Type"::POINT_WITHDRAW;
        MembershipPointsEntry."Posting Date" := DocumentDate;
        MembershipPointsEntry."Document No." := DocumentNo;
        MembershipPointsEntry."Membership Entry No." := MembershipEntryNo;
        MembershipPointsEntry."Customer No." := Membership."Customer No.";
        MembershipPointsEntry."Loyalty Code" := MembershipSetup."Loyalty Code";

        MembershipPointsEntry."Redeemed Points" := Abs (PointsToDeduct);
        MembershipPointsEntry.Points := - Abs(PointsToDeduct);

        MembershipPointsEntry."Redeem Ref. Type" := MembershipPointsEntry."Redeem Ref. Type"::COUPON;
        MembershipPointsEntry."Redeem Reference No." := CouponNo;

        MembershipPointsEntry.Quantity := 1;

        MembershipPointsEntry.Insert;
    end;

    procedure GetCouponToRedeemPOS(MembershipEntryNo: Integer;var TmpLoyaltyPointsSetup: Record "MM Loyalty Points Setup" temporary;SubTotal: Decimal): Boolean
    var
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        LoyaltySetup: Record "MM Loyalty Setup";
        LoyaltyPointsSetup: Record "MM Loyalty Points Setup";
        LineNo: Integer;
        AvailablePoints: Integer;
        ReasonText: Text;
    begin

        //-MM1.40 [343352] Refactored from GetCouponToRedeem ()
        Membership.Get (MembershipEntryNo);
        MembershipSetup.Get (Membership."Membership Code");
        MembershipSetup.TestField ("Loyalty Code");
        LoyaltySetup.Get (MembershipSetup."Loyalty Code");

        if (not GetEligibleCouponsToRedeemWorker (MembershipEntryNo, TmpLoyaltyPointsSetup, SubTotal, AvailablePoints, ReasonText)) then
          Error (ReasonText);

        if (LoyaltySetup."Voucher Creation" = LoyaltySetup."Voucher Creation"::PROMPT) then begin

          LineNo := DoLookupCoupon (SELECT_COUPON, TmpLoyaltyPointsSetup);
          TmpLoyaltyPointsSetup.DeleteAll;
          if (LoyaltyPointsSetup.Get (LoyaltySetup.Code, LineNo)) then begin
            TmpLoyaltyPointsSetup.TransferFields (LoyaltyPointsSetup, true);

            if (LoyaltyPointsSetup."Consume Available Points") then
              TmpLoyaltyPointsSetup."Points Threshold" := AvailablePoints;

            TmpLoyaltyPointsSetup.Insert ();
          end;
        end;

        exit (not TmpLoyaltyPointsSetup.IsEmpty());
        //+MM1.40 [343352]
    end;

    procedure GetCouponToRedeemWS(MembershipEntryNo: Integer;var TmpLoyaltyPointsSetup: Record "MM Loyalty Points Setup" temporary;SubTotal: Decimal;var ReasonText: Text): Boolean
    var
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        LoyaltySetup: Record "MM Loyalty Setup";
        LoyaltyPointsSetup: Record "MM Loyalty Points Setup";
        AvailablePoints: Integer;
    begin

        //-MM1.40 [343352]
        Membership.Get (MembershipEntryNo);
        MembershipSetup.Get (Membership."Membership Code");
        MembershipSetup.TestField ("Loyalty Code");
        LoyaltySetup.Get (MembershipSetup."Loyalty Code");

        if (not GetEligibleCouponsToRedeemWorker (MembershipEntryNo, TmpLoyaltyPointsSetup, SubTotal, AvailablePoints, ReasonText)) then
          exit (false);

        exit (not TmpLoyaltyPointsSetup.IsEmpty());
        //+MM1.40 [343352]
    end;

    local procedure GetEligibleCouponsToRedeemWorker(MembershipEntryNo: Integer;var TmpLoyaltyPointsSetup: Record "MM Loyalty Points Setup" temporary;SubTotal: Decimal;var PointsToSpend: Integer;var ReasonText: Text): Boolean
    var
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        LoyaltySetup: Record "MM Loyalty Setup";
        LoyaltyPointsSetup: Record "MM Loyalty Points Setup";
        ApplyCouponsInOrder: Integer;
        RemainingPoints: Integer;
        PeriodStart: Date;
        PeriodEnd: Date;
        ExpirePointsBefore: Date;
        ExpiredPoints: Integer;
        RedeemedPoints: Integer;
        ThresholdPoints: Integer;
    begin

        //-MM1.40 [343352] Refactored from GetCouponToRedeem ()
        //-MM1.41 [371095] Refactored again to separate threshold points from spending points
        Clear (TmpLoyaltyPointsSetup);

        Membership.Get (MembershipEntryNo);
        MembershipSetup.Get (Membership."Membership Code");
        LoyaltySetup.Get (MembershipSetup."Loyalty Code");

        with LoyaltySetup do
          case ("Voucher Point Source") of
            "Voucher Point Source"::PREVIOUS_PERIOD :
              begin
                ThresholdPoints := CalculateAvailablePoints (MembershipEntryNo, PointsCalculationOption::PREVIOUS_PERIOD, true);
                PointsToSpend   := CalculateAvailablePoints (MembershipEntryNo, PointsCalculationOption::PREVIOUS_PERIOD, false);
              end;

            "Voucher Point Source"::UNCOLLECTED     :
              begin
                ThresholdPoints := CalculateAvailablePoints (MembershipEntryNo, PointsCalculationOption::UNCOLLECTED, true);
                PointsToSpend   := CalculateAvailablePoints (MembershipEntryNo, PointsCalculationOption::UNCOLLECTED, false);
              end;
          end;

        if (ThresholdPoints < LoyaltySetup."Voucher Point Threshold") then
          // ERROR (NO_COUPON_AVAILABLE, AvailablePoints, LoyaltySetup."Voucher Point Threshold");
          exit (ErrorExit (ReasonText, StrSubstNo (NO_COUPON_AVAILABLE, ThresholdPoints, LoyaltySetup."Voucher Point Threshold")));

        LoyaltyPointsSetup.SetFilter (Code, '=%1', LoyaltySetup.Code);
        LoyaltyPointsSetup.SetFilter ("Points Threshold", '%1..%2', 0, Abs(ThresholdPoints));
        if (LoyaltyPointsSetup.IsEmpty ()) then
          // ERROR (NO_COUPON_AVAILABLE, AvailablePoints, LoyaltySetup."Voucher Point Threshold");
          exit (ErrorExit (ReasonText, StrSubstNo (NO_COUPON_AVAILABLE, ThresholdPoints, LoyaltySetup."Voucher Point Threshold")));

        LoyaltyPointsSetup.Reset ();
        LoyaltyPointsSetup.SetFilter (Code, '=%1', LoyaltySetup.Code);
        LoyaltyPointsSetup.SetFilter ("Points Threshold", '%1..%2', 0, Abs(ThresholdPoints));
        case LoyaltySetup."Voucher Creation" of
          LoyaltySetup."Voucher Creation"::SV_MP_HVC :
            begin
              LoyaltyPointsSetup.SetCurrentKey (Code, "Points Threshold");
              LoyaltyPointsSetup.FindLast ();
              TmpLoyaltyPointsSetup.TransferFields (LoyaltyPointsSetup, true);

              if (LoyaltyPointsSetup."Value Assignment" = LoyaltyPointsSetup."Value Assignment"::FROM_COUPON) then begin
                if (PointsToSpend < TmpLoyaltyPointsSetup."Points Threshold") then // can be true when points are spent from previous period
                  TmpLoyaltyPointsSetup."Points Threshold" := PointsToSpend;

                if (LoyaltyPointsSetup."Consume Available Points") then
                  TmpLoyaltyPointsSetup."Points Threshold" := PointsToSpend;

                if (PointsToSpend > 0) then
                  TmpLoyaltyPointsSetup.Insert ();
              end;

              if (LoyaltyPointsSetup."Value Assignment" = LoyaltyPointsSetup."Value Assignment"::FROM_LOYALTY) then begin
                TmpLoyaltyPointsSetup."Amount LCY" := SubTotal;
                if (PointsToSpend * TmpLoyaltyPointsSetup."Point Rate" < SubTotal) then
                  TmpLoyaltyPointsSetup."Amount LCY" := PointsToSpend * TmpLoyaltyPointsSetup."Point Rate";

                TmpLoyaltyPointsSetup."Points Threshold" := Round (TmpLoyaltyPointsSetup."Amount LCY" / TmpLoyaltyPointsSetup."Point Rate", 1);

                if (TmpLoyaltyPointsSetup."Amount LCY" >= TmpLoyaltyPointsSetup."Minimum Coupon Amount") then
                  TmpLoyaltyPointsSetup.Insert ();
              end;
            end;

          LoyaltySetup."Voucher Creation"::SV_MP_LVC :
            begin
              LoyaltyPointsSetup.SetCurrentKey (Code, "Points Threshold");
              LoyaltyPointsSetup.FindFirst ();
              TmpLoyaltyPointsSetup.TransferFields (LoyaltyPointsSetup, true);

              if (LoyaltyPointsSetup."Value Assignment" = LoyaltyPointsSetup."Value Assignment"::FROM_COUPON) then begin
                if (PointsToSpend < TmpLoyaltyPointsSetup."Points Threshold") then // can be true when points are spent from previous period
                  TmpLoyaltyPointsSetup."Points Threshold" := PointsToSpend;

                if (LoyaltyPointsSetup."Consume Available Points") then
                  TmpLoyaltyPointsSetup."Points Threshold" := PointsToSpend;

                if (PointsToSpend > 0) then
                  TmpLoyaltyPointsSetup.Insert ();
              end;

              if (LoyaltyPointsSetup."Value Assignment" = LoyaltyPointsSetup."Value Assignment"::FROM_LOYALTY) then begin
                TmpLoyaltyPointsSetup."Amount LCY" := SubTotal;
                if (PointsToSpend * TmpLoyaltyPointsSetup."Point Rate" < SubTotal) then
                  TmpLoyaltyPointsSetup."Amount LCY" := PointsToSpend * TmpLoyaltyPointsSetup."Point Rate";

                TmpLoyaltyPointsSetup."Points Threshold" := Round (TmpLoyaltyPointsSetup."Amount LCY" / TmpLoyaltyPointsSetup."Point Rate", 1);

                if (TmpLoyaltyPointsSetup."Amount LCY" >= TmpLoyaltyPointsSetup."Minimum Coupon Amount") then
                  TmpLoyaltyPointsSetup.Insert ();
              end;
            end;

          LoyaltySetup."Voucher Creation"::SV_HVC :
            begin
              LoyaltyPointsSetup.SetCurrentKey (Code, "Amount LCY");
              LoyaltyPointsSetup.SetFilter ("Value Assignment", '=%1', LoyaltyPointsSetup."Value Assignment"::FROM_COUPON);
              LoyaltyPointsSetup.FindLast ();
              TmpLoyaltyPointsSetup.TransferFields (LoyaltyPointsSetup, true);

              if (LoyaltyPointsSetup."Consume Available Points") then
                TmpLoyaltyPointsSetup."Points Threshold" := PointsToSpend;

              TmpLoyaltyPointsSetup.Insert ();
            end;

          LoyaltySetup."Voucher Creation"::MV_IVC :
            begin
              LoyaltyPointsSetup.SetCurrentKey (Code, "Points Threshold");
              LoyaltyPointsSetup.Ascending (false);
              LoyaltyPointsSetup.FindSet ();
              ApplyCouponsInOrder := 1;
              RemainingPoints := PointsToSpend;
              repeat
                while (RemainingPoints > LoyaltyPointsSetup."Points Threshold") do begin
                  TmpLoyaltyPointsSetup.TransferFields (LoyaltyPointsSetup, true);
                  TmpLoyaltyPointsSetup."Line No." := ApplyCouponsInOrder;
                  TmpLoyaltyPointsSetup.Insert ();
                  ApplyCouponsInOrder += 1;
                  RemainingPoints -= LoyaltyPointsSetup."Points Threshold";
                end;
              until (LoyaltyPointsSetup.Next () = 0);
            end;

          LoyaltySetup."Voucher Creation"::PROMPT :
            begin

              LoyaltyPointsSetup.SetCurrentKey (Code, "Points Threshold");
              if (LoyaltyPointsSetup.FindSet ()) then begin
                repeat
                  TmpLoyaltyPointsSetup.TransferFields (LoyaltyPointsSetup, true);

                  if (TmpLoyaltyPointsSetup."Value Assignment" = TmpLoyaltyPointsSetup."Value Assignment"::FROM_COUPON) then begin
                    TmpLoyaltyPointsSetup.CalcFields ("Discount Amount", "Discount %", "Discount Type", "Max. Discount Amount");
                    if (TmpLoyaltyPointsSetup."Discount Type" = TmpLoyaltyPointsSetup."Discount Type"::"Discount Amount") then
                      TmpLoyaltyPointsSetup."Amount LCY" := TmpLoyaltyPointsSetup."Discount Amount";

                    if (TmpLoyaltyPointsSetup."Discount Type" = TmpLoyaltyPointsSetup."Discount Type"::"Discount %") then begin
                      if (SubTotal = 0) then
                        exit (ErrorExit (ReasonText, StrSubstNo (SUBTOTAL_ZERO, SubTotal, TmpLoyaltyPointsSetup.FieldName ("Coupon Type Code"), TmpLoyaltyPointsSetup."Coupon Type Code")));

                      TmpLoyaltyPointsSetup."Amount LCY" := SubTotal * TmpLoyaltyPointsSetup."Discount %" / 100;
                    end;

                    TmpLoyaltyPointsSetup.Insert ();
                  end;

                  if (TmpLoyaltyPointsSetup."Value Assignment" = TmpLoyaltyPointsSetup."Value Assignment"::FROM_LOYALTY) then begin

                    TmpLoyaltyPointsSetup."Amount LCY" := SubTotal;
                    if (PointsToSpend * TmpLoyaltyPointsSetup."Point Rate" < SubTotal) then
                      TmpLoyaltyPointsSetup."Amount LCY" := PointsToSpend * TmpLoyaltyPointsSetup."Point Rate";

                    TmpLoyaltyPointsSetup."Points Threshold" := Round (TmpLoyaltyPointsSetup."Amount LCY" / TmpLoyaltyPointsSetup."Point Rate", 1);

                    if (TmpLoyaltyPointsSetup."Amount LCY" >= TmpLoyaltyPointsSetup."Minimum Coupon Amount") then
                      TmpLoyaltyPointsSetup.Insert ();

                  end;

                until (LoyaltyPointsSetup.Next () = 0);

              end;
            end;

        end;

        exit (not TmpLoyaltyPointsSetup.IsEmpty());
        //+MM1.41 [371095]
        //+MM1.40 [343352]
    end;

    local procedure DoLookupCoupon(LookupCaption: Text;var TmpLoyaltyPointsSetup: Record "MM Loyalty Points Setup" temporary) LineNo: Integer
    var
        UI: Codeunit "MM Member POS UI";
        LookupRecRef: RecordRef;
        Position: Text;
    begin

        LineNo := 0;

        LookupRecRef.GetTable(TmpLoyaltyPointsSetup);
        Position := UI.DoLookup (LookupCaption, LookupRecRef);

        if (Position <> '') then begin
          LookupRecRef.SetPosition (Position);
          if (LookupRecRef.Find ()) then begin
            LookupRecRef.SetTable (TmpLoyaltyPointsSetup);
            LineNo := TmpLoyaltyPointsSetup."Line No."
          end;
        end;

        exit (LineNo);
    end;

    local procedure AdjustPointsAbsoluteWorker(MembershipEntryNo: Integer;EntryType: Option;Points: Integer;AmountLCY: Decimal;ReferenceDate: Date;DocumentNo: Code[20]) MembershipPointsEntryNo: Integer
    var
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        MembershipPointsEntry: Record "MM Membership Points Entry";
        LoyaltySetup: Record "MM Loyalty Setup";
    begin

        exit (AdjustPointsAbsoluteWorker2 (
                MembershipEntryNo,
                EntryType,
                Points,
                AmountLCY,
                ReferenceDate,
                ReferenceDate,
                DocumentNo)
              );
    end;

    local procedure AdjustPointsAbsoluteWorker2(MembershipEntryNo: Integer;EntryType: Option;Points: Integer;AmountLCY: Decimal;ReferenceDate: Date;PostingDate: Date;DocumentNo: Code[20]) MembershipPointsEntryNo: Integer
    var
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        MembershipPointsEntry: Record "MM Membership Points Entry";
        LoyaltySetup: Record "MM Loyalty Setup";
        UpgradeAlteration: Record "MM Loyalty Alter Membership";
        DowngradeAlteration: Record "MM Loyalty Alter Membership";
        MembershipRole: Record "MM Membership Role";
        MemberNotification: Codeunit "MM Member Notification";
        UpgradeAvailable: Boolean;
        DowngradeAvailable: Boolean;
    begin

        Membership.Get (MembershipEntryNo);
        MembershipSetup.Get (Membership."Membership Code");
        MembershipSetup.TestField ("Loyalty Code");
        //-MM1.37 [343053]
        LoyaltySetup.Get (MembershipSetup."Loyalty Code");
        //+MM1.37 [343053]

        MembershipPointsEntry."Entry No." := 0;

        MembershipPointsEntry."Entry Type" := EntryType;
        MembershipPointsEntry.Adjustment := true;
        MembershipPointsEntry."Document No." := DocumentNo;

        //-MM1.37 [343053]
        //MembershipPointsEntry."Posting Date" := ReferenceDate;
        MembershipPointsEntry."Posting Date" := PostingDate;
        CalcultatePointsValidPeriod (LoyaltySetup, ReferenceDate, MembershipPointsEntry."Period Start", MembershipPointsEntry."Period End");
        //+MM1.37 [343053]

        MembershipPointsEntry."Membership Entry No." := MembershipEntryNo;
        MembershipPointsEntry."Customer No." := Membership."Customer No.";
        MembershipPointsEntry."Loyalty Code" := MembershipSetup."Loyalty Code";

        MembershipPointsEntry.Points := Points;
        MembershipPointsEntry."Amount (LCY)" := AmountLCY;

        if ((MembershipPointsEntry."Entry Type" = MembershipPointsEntry."Entry Type"::SALE) or
            (MembershipPointsEntry."Entry Type" = MembershipPointsEntry."Entry Type"::REFUND)) then
          MembershipPointsEntry."Awarded Points" := Points;

        MembershipPointsEntry.Quantity := 1;
        MembershipPointsEntry.Insert;

        //-MM1.40 [361664]
        // Check for upgrade
        UpgradeAvailable := EligibleForMembershipAlteration (Membership."Entry No.", true, UpgradeAlteration);
        DowngradeAvailable := EligibleForMembershipAlteration (Membership."Entry No.", false, DowngradeAlteration);

        if (UpgradeAvailable and not DowngradeAvailable) then
          AlterMembership (Membership."Entry No.", UpgradeAlteration);

        if (DowngradeAvailable and not UpgradeAvailable) then
          AlterMembership (Membership."Entry No.", DowngradeAlteration);

        if (MembershipSetup."Enable NP Pass Integration") then begin
          MembershipRole.SetFilter ("Membership Entry No.", '=%1', Membership."Entry No.");
          MembershipRole.SetFilter (Blocked, '=%1', false);
          MembershipRole.SetFilter ("Wallet Pass Id", '<>%1', '');
          if (not MembershipRole.IsEmpty ()) then
            MemberNotification.CreateUpdateWalletNotification (Membership."Entry No.", 0, 0);
        end;
        //+MM1.40 [361664]

        exit (MembershipPointsEntry."Entry No.");
    end;

    procedure SynchronizePointsAbsolute(MembershipEntryNo: Integer;Points: Integer;ReferenceDate: Date)
    var
        Membership: Record "MM Membership";
        MembershipPointsEntry: Record "MM Membership Points Entry";
    begin

        if (not Membership.Get (MembershipEntryNo)) then
          exit;

        Membership.CalcFields ("Remaining Points");
        if (Points = Membership."Remaining Points") then
          exit;

        AdjustPointsAbsoluteWorker (MembershipEntryNo, MembershipPointsEntry."Entry Type"::POINT_DEPOSIT, Points - Membership."Remaining Points", 0, ReferenceDate, '');
    end;

    procedure ManualAddSalePoints(MembershipEntryNo: Integer;ReceiptNo: Code[20];Points: Integer;"Amount (LCY)": Decimal;Description: Text[50])
    var
        Membership: Record "MM Membership";
        MembershipPointsEntry: Record "MM Membership Points Entry";
    begin

        if (not Membership.Get (MembershipEntryNo)) then
          exit;

        AdjustPointsAbsoluteWorker (MembershipEntryNo, MembershipPointsEntry."Entry Type"::SALE, Abs(Points), Abs("Amount (LCY)"), Today, ReceiptNo);
    end;

    procedure ManualAddRefundPoints(MembershipEntryNo: Integer;ReceiptNo: Code[20];Points: Integer;"Amount (LCY)": Decimal;Description: Text[50])
    var
        Membership: Record "MM Membership";
        MembershipPointsEntry: Record "MM Membership Points Entry";
    begin

        if (not Membership.Get (MembershipEntryNo)) then
          exit;

        AdjustPointsAbsoluteWorker (MembershipEntryNo, MembershipPointsEntry."Entry Type"::REFUND, -1 * Abs(Points), -1 * Abs ("Amount (LCY)"), Today, ReceiptNo);
    end;

    procedure ManualRedeemPointsWithdraw(MembershipEntryNo: Integer;ReceiptNo: Code[20];Points: Integer;"Amount (LCY)": Decimal;Description: Text[50])
    var
        Membership: Record "MM Membership";
        MembershipPointsEntry: Record "MM Membership Points Entry";
    begin

        if (not Membership.Get (MembershipEntryNo)) then
          exit;

        AdjustPointsAbsoluteWorker (MembershipEntryNo, MembershipPointsEntry."Entry Type"::POINT_WITHDRAW, -1 * Abs (Points), -1 * Abs ("Amount (LCY)"), Today, ReceiptNo);
    end;

    procedure ManualRedeemPointsDeposit(MembershipEntryNo: Integer;ReceiptNo: Code[20];Points: Integer;"Amount (LCY)": Decimal;Description: Text[50])
    var
        Membership: Record "MM Membership";
        MembershipPointsEntry: Record "MM Membership Points Entry";
    begin

        if (not Membership.Get (MembershipEntryNo)) then
          exit;

        AdjustPointsAbsoluteWorker (MembershipEntryNo, MembershipPointsEntry."Entry Type"::POINT_DEPOSIT, Abs (Points), Abs ("Amount (LCY)"), Today, ReceiptNo);
    end;

    procedure ManualExpirePoints(MembershipEntryNo: Integer;ReceiptNo: Code[20];Points: Integer;"Amount (LCY)": Decimal;Description: Text[50])
    var
        Membership: Record "MM Membership";
        MembershipPointsEntry: Record "MM Membership Points Entry";
    begin

        if (not Membership.Get (MembershipEntryNo)) then
          exit;

        AdjustPointsAbsoluteWorker (MembershipEntryNo, MembershipPointsEntry."Entry Type"::EXPIRED, -1 * Abs (Points), -1 * Abs ("Amount (LCY)"), Today, ReceiptNo);
    end;

    procedure ExpireFixedPeriodPoints(LoyaltyCode: Code[20])
    var
        LoyaltySetup: Record "MM Loyalty Setup";
        MembershipSetup: Record "MM Membership Setup";
        Membership: Record "MM Membership";
        MembershipPointsEntry: Record "MM Membership Points Entry";
        CollectionPeriodStart: Date;
        CollectionPeriodEnd: Date;
        ExpireAtDate: Date;
        Window: Dialog;
        PeriodPoints: Integer;
        TotalExpiredPoints: Integer;
        PointsToExpire: Integer;
        RecordCount: Integer;
        ProgressCount: Integer;
        ReasonText: Text;
        TotalRedeemedPoints: Integer;
    begin

        //-MM1.37 [343053]
        LoyaltySetup.Get (LoyaltyCode);
        LoyaltySetup.TestField ("Expire Uncollected Points");
        LoyaltySetup.TestField ("Expire Uncollected After");
        LoyaltySetup.TestField ("Collection Period", LoyaltySetup."Collection Period"::FIXED);

        // Current Period
        CalcultatePointsValidPeriod (LoyaltySetup, Today, CollectionPeriodStart, CollectionPeriodEnd);

        if (not CalculateCurrentExpiryDate (LoyaltySetup, ExpireAtDate, ReasonText)) then
          Error (ReasonText);

        if (not Confirm (CONFIRM_EXPIRE_POINTS, true, CalcDate ('<-1D>', CollectionPeriodStart), ExpireAtDate)) then
          Error ('');

        MembershipSetup.SetFilter ("Loyalty Code", '=%1', LoyaltyCode);
        if (MembershipSetup.FindSet ()) then begin
          repeat
            Membership.SetFilter ("Membership Code", '=%1', MembershipSetup.Code);
            if (Membership.FindSet ()) then begin
              RecordCount := Membership.Count ();
              ProgressCount := 0;

              if (GuiAllowed) then begin
                Window.Open (PROGRESS_DIALOG);
                Window.Update (1, MembershipSetup.Description);
              end;

              repeat
                if (GuiAllowed) then
                  Window.Update (2, Round (10000/RecordCount*ProgressCount, 1));

                Membership.SetFilter ("Date Filter", '..%1', Today);
                Membership.CalcFields ("Expired Points", "Redeemed Points (Withdrawl)");
                TotalExpiredPoints := Membership."Expired Points";
                TotalRedeemedPoints := Membership."Redeemed Points (Withdrawl)";

                Membership.SetFilter ("Date Filter", '..%1', ExpireAtDate);
                Membership.CalcFields ("Remaining Points");
                PeriodPoints := Membership."Remaining Points";

                PointsToExpire := PeriodPoints + TotalExpiredPoints+TotalRedeemedPoints;
                if (PointsToExpire <> 0) then
                  AdjustPointsAbsoluteWorker2 (Membership."Entry No.", MembershipPointsEntry."Entry Type"::EXPIRED, -1 * PointsToExpire, 0, CollectionPeriodEnd, Today, StrSubstNo ('EXP-%1', Format (Today, 0, 9)));

                ProgressCount += 1;

              until (Membership.Next () = 0);
            end;
          until (MembershipSetup.Next () = 0);

          if (GuiAllowed) then
            Window.Close ();

        end;

        //+MM1.37 [343053]
    end;

    local procedure "--Membership Elegibility and Upgrade"()
    begin
    end;

    local procedure EligibleForMembershipAlteration(MembershipEntryNo: Integer;Upgrade: Boolean;var LoyaltyAlterMembership: Record "MM Loyalty Alter Membership"): Boolean
    var
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        LoyaltySetup: Record "MM Loyalty Setup";
        MembershipEntry: Record "MM Membership Entry";
        AvailablePoints: Integer;
    begin

        //-MM1.40 [361664]
        if (not Membership.Get (MembershipEntryNo)) then
          exit (false);

        if (not MembershipSetup.Get (Membership."Membership Code")) then
          exit (false);

        if (MembershipSetup."Loyalty Code" = '') then
          exit (false);

        if (not LoyaltySetup.Get (MembershipSetup."Loyalty Code")) then
          exit (false);

        MembershipEntry.SetCurrentKey ("Entry No.");
        MembershipEntry.SetFilter ("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipEntry.SetFilter (Blocked, '=%1', false);
        MembershipEntry.SetFilter (Context, '<>%1', MembershipEntry.Context::REGRET);
        if (not MembershipEntry.FindLast ()) then
          exit (false);

        case LoyaltySetup."Auto Upgrade Point Source" of
          //-MM1.41 [371095]
          // LoyaltySetup."Auto Upgrade Point Source"::PREVIOUS_PERIOD : AvailablePoints := CalculateAvailablePoints (MembershipEntryNo, PointsCalculationOption::PREVIOUS_PERIOD);
          // LoyaltySetup."Auto Upgrade Point Source"::UNCOLLECTED     : AvailablePoints := CalculateAvailablePoints (MembershipEntryNo, PointsCalculationOption::UNCOLLECTED);
          LoyaltySetup."Auto Upgrade Point Source"::PREVIOUS_PERIOD : AvailablePoints := CalculateAvailablePoints (MembershipEntryNo, PointsCalculationOption::PREVIOUS_PERIOD, false);
          LoyaltySetup."Auto Upgrade Point Source"::UNCOLLECTED     : AvailablePoints := CalculateAvailablePoints (MembershipEntryNo, PointsCalculationOption::UNCOLLECTED, false);
          //+MM1.41 [371095]
          else
            exit (false);
        end;

        LoyaltyAlterMembership.SetCurrentKey ("Loyalty Code","From Membership Code","Change Direction","Points Threshold");
        LoyaltyAlterMembership.SetFilter ("Loyalty Code", '=%1', MembershipSetup."Loyalty Code");
        LoyaltyAlterMembership.SetFilter ("From Membership Code", '=%1', Membership."Membership Code");
        LoyaltyAlterMembership.SetFilter (Blocked, '=%1', false);

        case Upgrade of
          true : begin
            LoyaltyAlterMembership.SetFilter ("Change Direction", '=%1', LoyaltyAlterMembership."Change Direction"::UPGRADE);
            LoyaltyAlterMembership.SetFilter ("Points Threshold", '..%1', AvailablePoints);
            if (not LoyaltyAlterMembership.FindLast ()) then
              exit (false);
          end;

          false: begin
            LoyaltyAlterMembership.SetFilter ("Change Direction", '=%1', LoyaltyAlterMembership."Change Direction"::DOWNGRADE);
            LoyaltyAlterMembership.SetFilter ("Points Threshold", '%1..', AvailablePoints);
            if (not LoyaltyAlterMembership.FindFirst ()) then
              exit (false);
          end;
        end;



        exit (true);
        //+MM1.40 [361664]
    end;

    local procedure AlterMembership(MembershipEntryNo: Integer;LoyaltyAlterMembership: Record "MM Loyalty Alter Membership"): Boolean
    var
        Membership: Record "MM Membership";
        MemberInfoCapture: Record "MM Member Info Capture";
        MembershipEntry: Record "MM Membership Entry";
        MembershipManagement: Codeunit "MM Membership Management";
        MembershipStartDate: Date;
        MembershipUntilDate: Date;
    begin

        //-MM1.40 [361664]

        MemberInfoCapture.Init ();
        MemberInfoCapture."Entry No." := 0;


        MemberInfoCapture."Membership Entry No." := MembershipEntryNo;
        MemberInfoCapture."Membership Code" := LoyaltyAlterMembership."From Membership Code";
        MemberInfoCapture."Item No." := LoyaltyAlterMembership."Sales Item No.";
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::UPGRADE;
        MemberInfoCapture."Document Date" := Today;
        if (Format (LoyaltyAlterMembership."Defer Change Until") <> '') then
          MemberInfoCapture."Document Date" := CalcDate (LoyaltyAlterMembership."Defer Change Until", Today);

        MemberInfoCapture.Description :=
          CopyStr (
            StrSubstNo ('Membership Change %1->%2 (%3)', LoyaltyAlterMembership."From Membership Code", LoyaltyAlterMembership."To Membership Code", LoyaltyAlterMembership."Points Threshold"),
            1, MaxStrLen (MemberInfoCapture.Description));

        exit (MembershipManagement.UpgradeMembership (MemberInfoCapture, false, true, MembershipStartDate, MembershipUntilDate, MemberInfoCapture."Unit Price"));

        //+MM1.40 [361664]
    end;

    local procedure CalculateAvailablePoints(MembershipEntryNo: Integer;CalculationOption: Option;ForThreshold: Boolean) AvailablePoints: Integer
    var
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        LoyaltySetup: Record "MM Loyalty Setup";
        ExpiredPoints: Integer;
        RedeemedPoints: Integer;
        PeriodStart: Date;
        PeriodEnd: Date;
        ExpirePointsBefore: Date;
        ReasonText: Text;
    begin

        //-MM1.40 [361664]
        Membership.Get (MembershipEntryNo);
        MembershipSetup.Get (Membership."Membership Code");
        LoyaltySetup.Get (MembershipSetup."Loyalty Code");

        if (CalculationOption = PointsCalculationOption::PREVIOUS_PERIOD) then begin

          CalcultatePointsValidPeriod (LoyaltySetup, Today, PeriodStart, PeriodEnd);

          if (LoyaltySetup."Expire Uncollected Points") then begin
            Membership.SetFilter ("Date Filter", '..%1', Today);
            Membership.CalcFields ("Expired Points");
            ExpiredPoints := Membership."Expired Points";

            if (CalculateCurrentExpiryDate (LoyaltySetup, ExpirePointsBefore, ReasonText)) then
              PeriodEnd := ExpirePointsBefore;
          end;

          // The spend period is current period (unless expire calculation made it smaller)
          Membership.SetFilter ("Date Filter", '..%1', Today);
          Membership.CalcFields ("Redeemed Points (Withdrawl)");
          RedeemedPoints := Membership."Redeemed Points (Withdrawl)";

          // Total available points collected in the earn period (previous period)
          CalcultatePointsValidPeriod (LoyaltySetup, CalcDate ('<-1D>', PeriodStart), PeriodStart, PeriodEnd);
          Membership.SetFilter ("Date Filter", '%1..%2', PeriodStart, PeriodEnd);
        end;

        if (CalculationOption = PointsCalculationOption::UNCOLLECTED) then begin
          ExpiredPoints := 0;
          RedeemedPoints := 0;
          Membership.SetFilter ("Date Filter", '..%1', Today);
        end;

        Membership.CalcFields ("Remaining Points");

        AvailablePoints := Membership."Remaining Points" + ExpiredPoints + RedeemedPoints;
        //-MM1.41 [371095]
        if (ForThreshold) then
          AvailablePoints := Membership."Remaining Points";
        //+MM1.41 [371095]

        //IF (USERID = 'TSA') THEN MESSAGE ('Available points %1, redeemed %2, expired %3, thresholdcalculation %4', AvailablePoints, RedeemedPoints, ExpiredPoints, ForThreshold);
        //+MM1.40 [361664]
    end;

    procedure CalculateRedeemablePoints(MembershipEntryNo: Integer) RedeemablePoints: Integer
    var
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        LoyaltySetup: Record "MM Loyalty Setup";
    begin

        //-MM1.41 [371095]
        Membership.Get (MembershipEntryNo);
        MembershipSetup.Get (Membership."Membership Code");
        LoyaltySetup.Get (MembershipSetup."Loyalty Code");

        with LoyaltySetup do
          case ("Voucher Point Source") of
            "Voucher Point Source"::PREVIOUS_PERIOD : RedeemablePoints   := CalculateAvailablePoints (MembershipEntryNo, PointsCalculationOption::PREVIOUS_PERIOD, false);
            "Voucher Point Source"::UNCOLLECTED     : RedeemablePoints   := CalculateAvailablePoints (MembershipEntryNo, PointsCalculationOption::UNCOLLECTED, false);
          end;

        //+MM1.41 [371095]
    end;
}

