codeunit 6060143 "MM Loyalty Coupon Mgr"
{
    // MM1.22/TSA /20170731 CASE 285403 Initial Version
    // MM1.28/TSA /20180425 CASE 307048 Refactored to handle value to redeem
    // MM1.42/TSA /20191024 CASE 374403 Changed signature on IssueOneCoupon(), IssueOneCouponAndPrint(), and IssueCoupon()


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Issue Coupon - Member Loyalty';
        Text001: Label 'Member Loyalty Coupons needs to be issued in context of a member.';

    procedure IssueOneCoupon(CouponTypeCode: Code[20];MembershipEntryNo: Integer;DocumentNo: Code[20];PostingDate: Date;PointsToRedeem: Integer;ValueToRedeem: Decimal) CouponNo: Code[20]
    var
        CouponType: Record "NpDc Coupon Type";
        NpDcIssueCouponsQty: Report "NpDc Request Coupon Qty.";
        IssueCouponsQty: Integer;
        i: Integer;
    begin

        CouponType.Get (CouponTypeCode);
        CouponType.TestField("Reference No. Pattern");

        //-MM1.42 [374403]
        //CouponNo := IssueCoupon(CouponType, MembershipEntryNo, PointsToRedeem, ValueToRedeem, FALSE);
        CouponNo := IssueCoupon(CouponType, MembershipEntryNo, DocumentNo, PostingDate, PointsToRedeem, ValueToRedeem, false);
        //+MM1.42 [374403]
    end;

    procedure IssueOneCouponAndPrint(CouponTypeCode: Code[20];MembershipEntryNo: Integer;DocumentNo: Code[20];PostingDate: Date;PointsToRedeem: Integer;ValueToRedeem: Decimal) CouponNo: Code[20]
    var
        CouponType: Record "NpDc Coupon Type";
        NpDcIssueCouponsQty: Report "NpDc Request Coupon Qty.";
        IssueCouponsQty: Integer;
        i: Integer;
    begin
        CouponType.Get (CouponTypeCode);
        CouponType.TestField("Reference No. Pattern");

        //-MM1.42 [374403]
        //CouponNo := IssueCoupon(CouponType, MembershipEntryNo, PointsToRedeem, ValueToRedeem, TRUE);
        CouponNo := IssueCoupon(CouponType, MembershipEntryNo, DocumentNo, PostingDate, PointsToRedeem, ValueToRedeem, true);
        //+MM1.42 [374403]
    end;

    local procedure IssueCoupon(CouponType: Record "NpDc Coupon Type";MembershipEntryNo: Integer;DocumentNo: Code[20];PostingDate: Date;PointsToRedeem: Integer;ValueToRedeem: Decimal;WithPrint: Boolean) CouponNo: Code[20]
    var
        Coupon: Record "NpDc Coupon";
        CouponMgt: Codeunit "NpDc Coupon Mgt.";
        LoyaltyPointMgt: Codeunit "MM Loyalty Point Management";
        Membership: Record "MM Membership";
    begin

        Membership.Get (MembershipEntryNo);

        Coupon.Init;
        Coupon.Validate("Coupon Type",CouponType.Code);
        Coupon."No." := '';
        Coupon.Insert(true);

        if (ValueToRedeem > 0) then begin
          Coupon."Discount Type" := Coupon."Discount Type"::"Discount Amount";
          Coupon."Discount Amount" := ValueToRedeem;
        end;

        Coupon."Customer No." := Membership."Customer No.";
        Coupon.Modify ();

        if (ValueToRedeem > 0) then
          CouponMgt.PostIssueCoupon2 (Coupon, 1, ValueToRedeem);

        if (ValueToRedeem = 0) then
          CouponMgt.PostIssueCoupon(Coupon);

        //-MM1.42 [374403]
        //LoyaltyPointMgt.RedeemPointsCoupon (MembershipEntryNo, '', TODAY, Coupon."No.", PointsToRedeem);
        LoyaltyPointMgt.RedeemPointsCoupon (MembershipEntryNo, DocumentNo, PostingDate, Coupon."No.", PointsToRedeem);
        //+MM1.42 [374403]

        if (WithPrint) then
          CouponMgt.PrintCoupon (Coupon);

        exit (Coupon."No.");
    end;

    local procedure "--- Coupon Interface"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnInitCouponModules', '', true, true)]
    local procedure OnInitCouponModules(var CouponModule: Record "NpDc Coupon Module")
    begin
        if CouponModule.Get(CouponModule.Type::"Issue Coupon",ModuleCode()) then
          exit;

        CouponModule.Init;
        CouponModule.Type := CouponModule.Type::"Issue Coupon";
        CouponModule.Code := ModuleCode();
        CouponModule.Description := Text000;
        CouponModule."Event Codeunit ID" := CurrCodeunitId();
        CouponModule.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnHasIssueCouponSetup', '', true, true)]
    local procedure OnHasIssueCouponsSetup(CouponType: Record "NpDc Coupon Type";var HasIssueSetup: Boolean)
    begin
        if not IsSubscriber(CouponType) then
          exit;

        HasIssueSetup := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnSetupIssueCoupon', '', true, true)]
    local procedure OnSetupIssueCoupon(var CouponType: Record "NpDc Coupon Type")
    begin
        if not IsSubscriber(CouponType) then
          exit;

        PAGE.Run (PAGE::"MM Loyalty Points Setup");
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnRunIssueCoupon', '', true, true)]
    local procedure OnRunIssueCoupon(CouponType: Record "NpDc Coupon Type";var Handled: Boolean)
    begin
        if Handled then
          exit;
        if not IsSubscriber(CouponType) then
          exit;

        Handled := true;
        Error (Text001);
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"MM Loyalty Coupon Mgr");
    end;

    local procedure IsSubscriber(CouponType: Record "NpDc Coupon Type"): Boolean
    begin
        exit(CouponType."Issue Coupon Module" = ModuleCode());
    end;

    local procedure ModuleCode(): Code[20]
    begin
        exit('MEMBER-LOYALTY');
    end;
}

