codeunit 6151599 "NPR NpDc Module Validate: Time"
{
    // NPR5.35/MHA /20170809  CASE 286355 Object created
    // NPR5.37/MHA /20171010  CASE 292171 Added Weekday restriction


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Validate Coupon - Time Interval';
        Text001: Label 'Coupon is invalid during this Time';

    procedure ValidateCoupon(SalePOS: Record "NPR Sale POS"; Coupon: Record "NPR NpDc Coupon")
    var
        NpDcValidTimeInterval: Record "NPR NpDc Valid Time Interval";
        NpDcModuleValidateDefault: Codeunit "NPR NpDc ModuleValid.: Defa.";
        CheckTime: Time;
        CheckDate: Date;
    begin
        NpDcModuleValidateDefault.ValidateCoupon(SalePOS, Coupon);

        NpDcValidTimeInterval.SetRange("Coupon Type", Coupon."Coupon Type");
        if not NpDcValidTimeInterval.FindSet then
            Error(Text001);

        CheckTime := Time;
        //-NPR5.37 [292171]
        CheckDate := Today;
        //+NPR5.37 [292171]
        repeat
            //-NPR5.37 [292171]
            //IF IsValidTimeInterval(NpDcValidTimeInterval,CheckTime) THEN
            //  EXIT;
            if IsValidTimeInterval(NpDcValidTimeInterval, CheckTime, CheckDate) then
                exit;
        //+NPR5.37 [292171]
        until NpDcValidTimeInterval.Next = 0;

        Error(Text001);
    end;

    local procedure IsValidTimeInterval(NpDcValidTimeInterval: Record "NPR NpDc Valid Time Interval"; CheckTime: Time; CheckDate: Date): Boolean
    begin
        if (NpDcValidTimeInterval."Start Time" = 0T) and (NpDcValidTimeInterval."End Time" = 0T) then
            exit(false);
        //-NPR5.37 [292171]
        if not IsValidDay(NpDcValidTimeInterval, CheckDate) then
            exit(false);
        //+NPR5.37 [292171]

        if (NpDcValidTimeInterval."Start Time" <= NpDcValidTimeInterval."End Time") or (NpDcValidTimeInterval."End Time" = 0T) then begin
            if CheckTime < NpDcValidTimeInterval."Start Time" then
                exit(false);
            if NpDcValidTimeInterval."End Time" = 0T then
                exit(true);
            exit(CheckTime <= NpDcValidTimeInterval."End Time");
        end;

        exit((CheckTime >= NpDcValidTimeInterval."Start Time") or (CheckTime <= NpDcValidTimeInterval."End Time"));
    end;

    local procedure IsValidDay(NpDcValidTimeInterval: Record "NPR NpDc Valid Time Interval"; CheckDate: Date): Boolean
    begin
        //-NPR5.37 [292171]
        if NpDcValidTimeInterval."Period Type" <> NpDcValidTimeInterval."Period Type"::Weekly then
            exit(true);

        case Date2DWY(CheckDate, 1) of
            1:
                exit(NpDcValidTimeInterval.Monday);
            2:
                exit(NpDcValidTimeInterval.Tuesday);
            3:
                exit(NpDcValidTimeInterval.Wednesday);
            4:
                exit(NpDcValidTimeInterval.Thursday);
            5:
                exit(NpDcValidTimeInterval.Friday);
            6:
                exit(NpDcValidTimeInterval.Saturday);
            7:
                exit(NpDcValidTimeInterval.Sunday);
        end;
        //+NPR5.37 [292171]
    end;

    local procedure "--- Coupon Interface"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnInitCouponModules', '', true, true)]
    local procedure OnInitCouponModules(var CouponModule: Record "NPR NpDc Coupon Module")
    begin
        if CouponModule.Get(CouponModule.Type::"Validate Coupon", ModuleCode()) then
            exit;

        CouponModule.Init;
        CouponModule.Type := CouponModule.Type::"Validate Coupon";
        CouponModule.Code := ModuleCode();
        CouponModule.Description := Text000;
        CouponModule."Event Codeunit ID" := CurrCodeunitId();
        CouponModule.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnHasValidateCouponSetup', '', true, true)]
    local procedure OnHasValidateCouponSetup(CouponType: Record "NPR NpDc Coupon Type"; var HasValidateSetup: Boolean)
    begin
        if not IsSubscriber(CouponType) then
            exit;

        HasValidateSetup := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnSetupValidateCoupon', '', true, true)]
    local procedure OnSetupValidateCoupon(var CouponType: Record "NPR NpDc Coupon Type")
    var
        NpDcValidTimeInterval: Record "NPR NpDc Valid Time Interval";
    begin
        if not IsSubscriber(CouponType) then
            exit;

        NpDcValidTimeInterval.FilterGroup(2);
        NpDcValidTimeInterval.SetRange("Coupon Type", CouponType.Code);
        NpDcValidTimeInterval.FilterGroup(0);

        PAGE.Run(PAGE::"NPR NpDc Valid Time Interv.", NpDcValidTimeInterval);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151591, 'OnRunValidateCoupon', '', true, true)]
    local procedure OnRunValidateCoupon(SalePOS: Record "NPR Sale POS"; Coupon: Record "NPR NpDc Coupon"; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if not IsSubscriberCoupon(Coupon) then
            exit;

        Handled := true;

        ValidateCoupon(SalePOS, Coupon);
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpDc Module Validate: Time");
    end;

    local procedure IsSubscriber(CouponType: Record "NPR NpDc Coupon Type"): Boolean
    begin
        exit(CouponType."Validate Coupon Module" = ModuleCode());
    end;

    local procedure IsSubscriberCoupon(Coupon: Record "NPR NpDc Coupon"): Boolean
    begin
        Coupon.CalcFields("Validate Coupon Module");
        exit(Coupon."Validate Coupon Module" = ModuleCode());
    end;

    local procedure ModuleCode(): Code[20]
    begin
        exit('TIME');
    end;
}

