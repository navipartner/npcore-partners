codeunit 6184871 "NPR TM TicketToCoupon"
{
    Access = Internal;

    internal procedure ExchangeTicketForCoupon(ExternalTicketNo: Code[30]; CouponAlias: Code[20]; var CouponReferenceNo: Text[50]; var ReasonCode: Integer; var ReasonText: Text) Success: Boolean
    var
        Ticket: Record "NPR TM Ticket";
        TicketType: Record "NPR TM Ticket Type";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketCoupons: Record "NPR TM TicketCoupons";
        CouponProfile: Record "NPR TM CouponProfile";
        CouponValidFrom: Date;
        CouponValidUntil: Date;

        TicketNotFound: Label 'Ticket not found';
        TicketBlocked: Label 'Ticket is blocked';
        NoCouponProfile: Label 'Ticket type does not have a coupon profile';
        InvalidProfile: Label 'Coupon profile not found';
        CouponProfileNotFound: Label 'Coupon profile for ticket type does not define a default coupon';
        NotPaid: Label 'Ticket has not been paid, purchase date is required';
        NotAdmitted: Label 'Ticket has not been used, admission date is required';
        NotRequiredAdmitted: Label 'Ticket has not been used for the required admission, admission date is required';
        AlreadyCreated: Label 'Already created';
        CouponCreated: Label 'OK';
    begin
        Ticket.SetFilter("External Ticket No.", '=%1', ExternalTicketNo);
        Ticket.SetFilter(Blocked, '=%1', false);
        if (not Ticket.FindFirst()) then
            exit(ExitWithReason(-10, TicketNotFound, ReasonCode, ReasonText));

        if (Ticket.Blocked) then
            exit(ExitWithReason(-11, TicketBlocked, ReasonCode, ReasonText));

        TicketType.Get(Ticket."Ticket Type Code");
        if (TicketType."CouponProfileCode" = '') then
            exit(ExitWithReason(-20, NoCouponProfile, ReasonCode, ReasonText));

        if (not CouponProfile.Get(TicketType."CouponProfileCode", CouponAlias)) then begin
            if (CouponAlias <> '') then
                exit(ExitWithReason(-22, InvalidProfile, ReasonCode, ReasonText));

            CouponProfile.SetFilter(ProfileCode, '=%1', TicketType."CouponProfileCode");
            CouponProfile.SetFilter(Default, '=%1', true);
            if (not CouponProfile.FindFirst()) then
                exit(ExitWithReason(-21, CouponProfileNotFound, ReasonCode, ReasonText));
        end;

        if (not TicketCoupons.Get(Ticket."No.", CouponProfile."CouponType", CouponProfile.AliasCode)) then begin
            case (CouponProfile.ValidFromDate) of
                CouponProfile.ValidFromDate::Purchase:
                    begin
                        DetTicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
                        DetTicketAccessEntry.SetFilter(Type, '=%1|=%2|=%3', DetTicketAccessEntry.Type::PAYMENT, DetTicketAccessEntry.Type::POSTPAID, DetTicketAccessEntry.Type::PREPAID);
                        if (not DetTicketAccessEntry.FindFirst()) then
                            exit(ExitWithReason(-30, NotPaid, ReasonCode, ReasonText));

                        CouponValidFrom := DT2Date(DetTicketAccessEntry.SystemCreatedAt);
                        CouponValidUntil := CalcDate(CouponProfile.ValidForDateFormula, CouponValidFrom);
                    end;
                CouponProfile.ValidFromDate::FIRST_ADMISSION:
                    begin
                        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
                        TicketAccessEntry.SetFilter("Access Date", '>%1', 0D);
                        if (not TicketAccessEntry.FindFirst()) then
                            exit(ExitWithReason(-31, NotAdmitted, ReasonCode, ReasonText));

                        CouponValidFrom := TicketAccessEntry."Access Date";
                        CouponValidUntil := CalcDate(CouponProfile.ValidForDateFormula, CouponValidFrom);
                    end;
                CouponProfile.ValidFromDate::SELECTED_ADMISSION:
                    begin
                        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
                        TicketAccessEntry.SetFilter("Admission Code", '=%1', CouponProfile.RequiredAdmissionCode);
                        TicketAccessEntry.SetFilter("Access Date", '>%1', 0D);
                        if (not TicketAccessEntry.FindFirst()) then
                            exit(ExitWithReason(-32, NotRequiredAdmitted, ReasonCode, ReasonText));

                        CouponValidFrom := TicketAccessEntry."Access Date";
                        CouponValidUntil := CalcDate(CouponProfile.ValidForDateFormula, CouponValidFrom);
                    end;
                CouponProfile.ValidFromDate::NA:
                    begin
                        DetTicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
                        DetTicketAccessEntry.SetFilter(Type, '=%1|=%2|=%3', DetTicketAccessEntry.Type::PAYMENT, DetTicketAccessEntry.Type::POSTPAID, DetTicketAccessEntry.Type::PREPAID);
                        if (not DetTicketAccessEntry.FindFirst()) then
                            exit(ExitWithReason(-30, NotPaid, ReasonCode, ReasonText));

                        CouponValidFrom := Ticket."Valid From Date";
                        CouponValidUntil := Ticket."Valid To Date";
                    end;
                else
                    Error('Invalid ValidFromDate value in Coupon Profile, this is a programming error.');
            end;

            IssueCoupon(CouponProfile."CouponType", TicketCoupons.CouponNo, TicketCoupons.CouponReferenceNo, CouponValidFrom, CouponValidUntil);
            TicketCoupons.TicketNo := Ticket."No.";
            TicketCoupons.CouponType := CouponProfile."CouponType";
            TicketCoupons.CouponAlias := CouponProfile.AliasCode;
            TicketCoupons.Insert();
            CouponReferenceNo := TicketCoupons.CouponReferenceNo;
            exit(ExitWithReason(10, CouponCreated, ReasonCode, ReasonText));
        end;

        CouponReferenceNo := TicketCoupons.CouponReferenceNo;
        exit(ExitWithReason(11, AlreadyCreated, ReasonCode, ReasonText));

    end;

    local procedure IssueCoupon(CouponTypeCode: Code[20]; var CouponNo: Code[20]; var CouponReferenceNo: Text[50]; ValidFrom: Date; ValidUntil: Date)
    var
        CouponType: Record "NPR NpDc Coupon Type";
        Coupon: Record "NPR NpDc Coupon";
        CouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
    begin

        CouponType.Get(CouponTypeCode);

        Coupon.Init();
        Coupon.Validate("Coupon Type", CouponTypeCode);
        Coupon."No." := '';
        if (ValidFrom <> 0D) then begin
            Coupon."Starting Date" := CreateDateTime(ValidFrom, 0T);
            Coupon."Ending Date" := CreateDateTime(ValidUntil, 235959T);
        end;
        Coupon.Insert(true);
        CouponMgt.PostIssueCoupon(Coupon);

        if (CouponType."Print on Issue") then
            CouponMgt.PrintCoupon(Coupon);

        CouponNo := Coupon."No.";
        CouponReferenceNo := Coupon."Reference No.";
    end;

    local procedure ExitWithReason(arg1: Integer; arg2: Text; var ReasonCode: Integer; var ReasonText: Text): Boolean
    begin
        ReasonCode := arg1;
        ReasonText := arg2;
        exit(arg1 > 0);
    end;

}