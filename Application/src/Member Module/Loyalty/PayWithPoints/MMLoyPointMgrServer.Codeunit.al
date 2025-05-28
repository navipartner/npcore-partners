﻿codeunit 6151161 "NPR MM Loy. Point Mgr (Server)"
{
    Access = Internal;

    trigger OnRun()
    begin
    end;

    var
        E1101_SETUP_MISSING: Label 'The requested store and unit has not been setup. [%1], [%2], [%3]';
        AUTHORIZATION_MISSING: Label 'The authorization request is empty.';
        E1102_AUTHORIZATION_INCORRECT: Label 'The supplied authorization code is not correct.';
        E1108_TRANSACTION_ID: Label 'Transaction Id must not be blank.';
        E1103_RECEIPT_INCORRECT: Label 'Receipt Number must not be blank.';
        E1104_DATE_INCORRECT: Label 'Date must not be empty or in the future.';
        E1105_TIME_INCORRECT: Label 'Time must not be empty.';
        E1109_REF_NUM: Label 'Reference number must be unique for this entry type.';
        E1110_NOT_ENABLED: Label 'Server loyalty setup is not enabled for this client.';
        TYPE_INCORRECT: Label 'Type must be one of %1.';
        MEMBERSHIP_1: Label 'Incorrect membership entry no. referenced from card number %1.';
        MEMBERSHIP_2: Label 'Incorrect setup for membership code %1.';
        MEMBERSHIP_3: Label 'No loyalty program is setup for membership code %1.';
        RESERVE_1: Label 'The authorization code %1 is not valid (%2).';
        RESERVE_2: Label 'The number of points to reserve must be greater than zero.';
        RESERVE_3: Label 'The number of points to refund must be less than zero.';
        RESERVE_4: Label 'Incorrect type for reserve points.';
        PAYMENT_2: Label 'The reserved number of points with authorization code %1 does not match points in payment.';
        PAYMENT_3: Label 'Currency code must be equal to company currency code (%1) and not blank.';
        PAYMENT_4: Label 'The attempted reserved number of points (%1), exceed the members current balance (%2).';
        CANCEL_1: Label 'The authorization code %1 has been captured and can not be cancelled.';
        CANCEL_2: Label 'The authorization code %1 has been cancelled and can not be captured.';
        CAPTURE_1: Label 'The authorization code %1 has been captured and can not be captured again.';

        SALE_1: Label 'Incorrect sign.';
        JNL_NOT_EMPTY: Label 'The %1 %2 is not empty. Confirm YES to delete lines and proceed.';
        SELECT_JNL_TYPE: Label 'Select journal template type:';

        _MembershipEvents: Codeunit "NPR MM Membership Events";

    [CommitBehavior(CommitBehavior::Error)]
    procedure RegisterSales(var TmpAuthorizationIn: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; var TmpSaleLinesIn: Record "NPR MM Reg. Sales Buffer" temporary; var TmpPaymentLinesIn: Record "NPR MM Reg. Sales Buffer" temporary; var TmpPointsOut: Record "NPR MM Loy. LedgerEntry (Srvr)"; var ResponseMessage: Text; var ResponseMessageId: Text): Boolean
    var
        LoyaltyStoreLedger: Record "NPR MM Loy. LedgerEntry (Srvr)";
        LoyaltySetup: Record "NPR MM Loyalty Setup";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
        MembershipEntryNo: Integer;
        TotalEarnAmount: Decimal;
        TotalBurnAmount: Decimal;
    begin

        if (not ValidateAuthorization(false, TmpAuthorizationIn, MembershipEntryNo, ResponseMessage, ResponseMessageId)) then
            exit(false);

        if (not ValidateRegisterSales(TmpSaleLinesIn, TmpPaymentLinesIn, ResponseMessage, ResponseMessageId)) then
            exit(false);

        // validations are done in the validate functions
        Membership.Get(MembershipEntryNo);
        MembershipSetup.Get(Membership."Membership Code");
        LoyaltySetup.Get(MembershipSetup."Loyalty Code");
        // Store the request in the store ledger
        TmpAuthorizationIn.FindFirst();
        LoyaltyStoreLedger.TransferFields(TmpAuthorizationIn, false);
        LoyaltyStoreLedger."Entry No." := 0;
        LoyaltyStoreLedger."Entry Type" := LoyaltyStoreLedger."Entry Type"::RECEIPT;
        LoyaltyStoreLedger."Authorization Code" := CreateAuthorizationCode();
        LoyaltyStoreLedger."Retail Id" := TmpAuthorizationIn."Retail Id";

        // Store the details in the points entry ledgers
        TmpSaleLinesIn.Reset();
        if (TmpSaleLinesIn.FindSet()) then begin
            repeat
                CreateSalesEntry(LoyaltySetup, LoyaltyStoreLedger, Membership, TmpSaleLinesIn, TotalEarnAmount);

            until (TmpSaleLinesIn.Next() = 0);
        end;

        TmpPaymentLinesIn.Reset();
        if (TmpPaymentLinesIn.FindSet()) then begin
            repeat
                if (TmpPaymentLinesIn."Total Points" <> 0) then
                    CreateCaptureEntry(LoyaltySetup, LoyaltyStoreLedger, Membership, TmpPaymentLinesIn, TotalBurnAmount);

            until (TmpPaymentLinesIn.Next() = 0);
        end;

        // Create compensation for amount not eligible for earn
        if (TotalBurnAmount <> 0) then
            CreateNotEligibleEntry(LoyaltySetup, LoyaltyStoreLedger, Membership, TotalEarnAmount, TotalBurnAmount);

        // finalize store ledger and response
        Membership.CalcFields("Remaining Points");
        LoyaltyStoreLedger.Balance := Membership."Remaining Points";
        LoyaltyStoreLedger.Insert();

        LoyaltyPointManagement.AfterMembershipPointsUpdate(Membership."Entry No.", 0);
        _MembershipEvents.OnAfterMembershipPointsUpdate(Membership."Entry No.", 0);

        TmpPointsOut.TransferFields(LoyaltyStoreLedger, true);
        TmpPointsOut.Insert();
        exit(true);
    end;

    [CommitBehavior(CommitBehavior::Error)]
    procedure ReservePoints(var TmpAuthorizationIn: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; var TmpReserveLinesIn: Record "NPR MM Reg. Sales Buffer" temporary; var TmpPointsOut: Record "NPR MM Loy. LedgerEntry (Srvr)"; var ResponseMessage: Text; var ResponseMessageId: Text): Boolean
    var
        LoyaltyStoreLedger: Record "NPR MM Loy. LedgerEntry (Srvr)";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        LoyaltySetup: Record "NPR MM Loyalty Setup";
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
        MembershipEntryNo: Integer;
    begin

        if (not ValidateAuthorization(false, TmpAuthorizationIn, MembershipEntryNo, ResponseMessage, ResponseMessageId)) then
            exit(false);

        if (not ValidateReservePoints(TmpReserveLinesIn, MembershipEntryNo, ResponseMessage, ResponseMessageId)) then
            exit(false);

        // validations are done in the validate functions
        Membership.Get(MembershipEntryNo);
        MembershipSetup.Get(Membership."Membership Code");
        LoyaltySetup.Get(MembershipSetup."Loyalty Code");

        // Store the request in the store ledger
        TmpAuthorizationIn.FindFirst();
        LoyaltyStoreLedger.TransferFields(TmpAuthorizationIn, false);
        LoyaltyStoreLedger."Entry No." := 0;
        LoyaltyStoreLedger."Entry Type" := LoyaltyStoreLedger."Entry Type"::RESERVE;
        LoyaltyStoreLedger."Authorization Code" := CreateAuthorizationCode();
        LoyaltyStoreLedger."Retail Id" := TmpAuthorizationIn."Retail Id";

        // Store the details in the points entry ledger
        TmpReserveLinesIn.Reset();
        if (TmpReserveLinesIn.FindSet()) then begin
            repeat
                if (TmpReserveLinesIn."Total Points" <> 0) then
                    CreateReserveEntry(LoyaltySetup, LoyaltyStoreLedger, Membership, TmpReserveLinesIn);

            until (TmpReserveLinesIn.Next() = 0);
        end;

        // finalize store ledger and response
        Membership.CalcFields("Remaining Points");
        LoyaltyStoreLedger.Balance := Membership."Remaining Points";
        LoyaltyStoreLedger.Insert();

        LoyaltyPointManagement.AfterMembershipPointsUpdate(Membership."Entry No.", 0);
        _MembershipEvents.OnAfterMembershipPointsUpdate(Membership."Entry No.", 0);

        TmpPointsOut.TransferFields(LoyaltyStoreLedger, true);
        TmpPointsOut.Insert();
        exit(true);
    end;

    [CommitBehavior(CommitBehavior::Error)]
    procedure CancelReservation(var TmpAuthorizationIn: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; var TmpCancelLinesIn: Record "NPR MM Reg. Sales Buffer" temporary; var TmpPointsOut: Record "NPR MM Loy. LedgerEntry (Srvr)"; var ResponseMessage: Text; var ResponseMessageId: Text): Boolean
    var
        LoyaltyStoreLedger: Record "NPR MM Loy. LedgerEntry (Srvr)";
        ReservationLedgerEntry: Record "NPR MM Loy. LedgerEntry (Srvr)";
        Membership: Record "NPR MM Membership";
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
        MembershipEntryNo: Integer;
    begin

        if (not ValidateAuthorization(true, TmpAuthorizationIn, MembershipEntryNo, ResponseMessage, ResponseMessageId)) then
            exit(false);

        TmpCancelLinesIn.Reset();
        TmpCancelLinesIn.FindFirst();
        if (TmpCancelLinesIn."Authorization Code" = '') then begin
            ResponseMessage := StrSubstNo(RESERVE_1, '', 1);
            ResponseMessageId := '-1300';
            exit(false);
        end;

        ReservationLedgerEntry.SetCurrentKey("Authorization Code");
        ReservationLedgerEntry.SetAutoCalcFields("Reservation is Captured", "Reservation is Cancelled");
        ReservationLedgerEntry.SetFilter("Authorization Code", '=%1', TmpCancelLinesIn."Authorization Code");
        ReservationLedgerEntry.SetFilter("Entry Type", '=%1', ReservationLedgerEntry."Entry Type"::RESERVE);
        if (ReservationLedgerEntry.FindFirst()) then begin
            if (ReservationLedgerEntry."Reservation is Captured") then begin
                ResponseMessage := StrSubstNo(CANCEL_1, TmpCancelLinesIn."Authorization Code");
                ResponseMessageId := '-1301';
                exit(false);
            end;

            if (ReservationLedgerEntry."Reservation is Cancelled") then begin
                ReservationLedgerEntry.SetFilter("Entry Type", '=%1', ReservationLedgerEntry."Entry Type"::CANCEL_RESERVE);
                ReservationLedgerEntry.FindFirst();
                TmpPointsOut.TransferFields(ReservationLedgerEntry, true);
                TmpPointsOut.Insert();
                exit(true);
            end;

        end else begin
            ResponseMessage := StrSubstNo(RESERVE_1, TmpCancelLinesIn."Authorization Code", 3);
            ResponseMessageId := '-1302';
            exit(false);
        end;

        Membership.Get(MembershipEntryNo);

        // Store the cancel request in the store ledger
        TmpAuthorizationIn.FindFirst();
        LoyaltyStoreLedger.TransferFields(TmpAuthorizationIn, false);

        LoyaltyStoreLedger."Entry Type" := LoyaltyStoreLedger."Entry Type"::CANCEL_RESERVE;
        LoyaltyStoreLedger."Authorization Code" := TmpCancelLinesIn."Authorization Code";
        LoyaltyStoreLedger."Retail Id" := TmpAuthorizationIn."Retail Id";
        LoyaltyStoreLedger."Entry No." := 0;

        if (TmpCancelLinesIn.Type = TmpCancelLinesIn.Type::CANCEL_RESERVATION) then
            if (not CreateCancelReserveEntry(TmpCancelLinesIn."Authorization Code", LoyaltyStoreLedger."Burned Points")) then begin
                ResponseMessage := StrSubstNo(RESERVE_1, TmpCancelLinesIn."Authorization Code", 4);
                ResponseMessageId := '-1303';
                exit(false);
            end;

        // finalize store ledger and response
        Membership.CalcFields("Remaining Points");

        LoyaltyStoreLedger.Balance := Membership."Remaining Points";
        LoyaltyStoreLedger.Insert();

        LoyaltyPointManagement.AfterMembershipPointsUpdate(Membership."Entry No.", 0);
        _MembershipEvents.OnAfterMembershipPointsUpdate(Membership."Entry No.", 0);

        TmpPointsOut.TransferFields(LoyaltyStoreLedger, true);
        TmpPointsOut.Insert();
        exit(true);
    end;

    procedure CaptureReservation(var TmpAuthorizationIn: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; var TmpCaptureLinesIn: Record "NPR MM Reg. Sales Buffer" temporary; var TmpPointsOut: Record "NPR MM Loy. LedgerEntry (Srvr)"; var ResponseMessage: Text; var ResponseMessageId: Text): Boolean
    var
        LoyaltyStoreLedger: Record "NPR MM Loy. LedgerEntry (Srvr)";
        ReservationLedgerEntry: Record "NPR MM Loy. LedgerEntry (Srvr)";
        Membership: Record "NPR MM Membership";
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
        MembershipEntryNo: Integer;
    begin

        if (not ValidateAuthorization(true, TmpAuthorizationIn, MembershipEntryNo, ResponseMessage, ResponseMessageId)) then
            exit(false);

        TmpCaptureLinesIn.Reset();
        TmpCaptureLinesIn.FindFirst();
        if (TmpCaptureLinesIn."Authorization Code" = '') then begin
            ResponseMessage := StrSubstNo(RESERVE_1, '', 1);
            ResponseMessageId := '-1400';
            exit(false);
        end;

        ReservationLedgerEntry.SetCurrentKey("Authorization Code");
        ReservationLedgerEntry.SetAutoCalcFields("Reservation is Captured", "Reservation is Cancelled");
        ReservationLedgerEntry.SetFilter("Authorization Code", '=%1', TmpCaptureLinesIn."Authorization Code");
        ReservationLedgerEntry.SetFilter("Entry Type", '=%1', ReservationLedgerEntry."Entry Type"::RESERVE);
        if (ReservationLedgerEntry.FindFirst()) then begin
            if (ReservationLedgerEntry."Reservation is Captured") then begin
                ResponseMessage := StrSubstNo(CAPTURE_1, TmpCaptureLinesIn."Authorization Code");
                ResponseMessageId := '-1401';
                exit(false);
            end;

            if (ReservationLedgerEntry."Reservation is Cancelled") then begin
                ResponseMessage := StrSubstNo(CANCEL_2, TmpCaptureLinesIn."Authorization Code");
                ResponseMessageId := '-1401';
                exit(false);

            end;
        end else begin
            ResponseMessage := StrSubstNo(RESERVE_1, TmpCaptureLinesIn."Authorization Code", 3);
            ResponseMessageId := '-1402';
            exit(false);
        end;

        Membership.Get(MembershipEntryNo);

        // Store the capture request in the store ledger
        TmpAuthorizationIn.FindFirst();
        LoyaltyStoreLedger.TransferFields(TmpAuthorizationIn, false);

        LoyaltyStoreLedger."Entry Type" := LoyaltyStoreLedger."Entry Type"::RECEIPT;
        LoyaltyStoreLedger."Authorization Code" := TmpCaptureLinesIn."Authorization Code";
        LoyaltyStoreLedger."Retail Id" := TmpAuthorizationIn."Retail Id";
        LoyaltyStoreLedger."Entry No." := 0;

        if (TmpCaptureLinesIn.Type = TmpCaptureLinesIn.Type::CAPTURE) then
            if (not CreateCaptureReserveEntry(TmpCaptureLinesIn."Authorization Code", LoyaltyStoreLedger."Burned Points")) then begin
                ResponseMessage := StrSubstNo(RESERVE_1, TmpCaptureLinesIn."Authorization Code", 4);
                ResponseMessageId := '-1403';
                exit(false);
            end;

        // finalize store ledger and response
        Membership.CalcFields("Remaining Points");

        LoyaltyStoreLedger.Balance := Membership."Remaining Points";
        LoyaltyStoreLedger.Insert();

        LoyaltyPointManagement.AfterMembershipPointsUpdate(Membership."Entry No.", 0);
        _MembershipEvents.OnAfterMembershipPointsUpdate(Membership."Entry No.", 0);

        TmpPointsOut.TransferFields(LoyaltyStoreLedger, true);
        TmpPointsOut.Insert();
        exit(true);
    end;



    procedure GetLoyaltySetup(var TmpAuthorizationIn: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; var TmpLoyaltySetup: Record "NPR MM Loyalty Setup" temporary; var ResponseMessage: Text; var ResponseMessageId: Text): Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        LoyaltySetup: Record "NPR MM Loyalty Setup";
        LoyaltyStoreSetup: Record "NPR MM Loyalty Store Setup";
        MembershipEntryNo: Integer;
    begin

        if (not ValidateAuthorization(true, TmpAuthorizationIn, MembershipEntryNo, ResponseMessage, ResponseMessageId)) then
            exit(false);

        // validations are done in the validate functions
        if (MembershipEntryNo <> 0) then begin
            Membership.Get(MembershipEntryNo);
            MembershipSetup.Get(Membership."Membership Code");
            LoyaltySetup.Get(MembershipSetup."Loyalty Code");
        end else begin
            LoyaltyStoreSetup.Get(TmpAuthorizationIn."Company Name", TmpAuthorizationIn."POS Store Code", TmpAuthorizationIn."POS Unit Code");
            LoyaltySetup.Get(LoyaltyStoreSetup."Loyalty Setup Code");
        end;

        TmpLoyaltySetup.TransferFields(LoyaltySetup, true);
        TmpLoyaltySetup.Insert();
        exit(true);

    end;

    local procedure ValidateAuthorization(BasicCheck: Boolean; var TmpAuthorizationIn: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; var MembershipEntryNo: Integer; var ResponseMessage: Text; var ResponseMessageId: Text): Boolean
    var
        LoyaltyServerStoreLedger: Record "NPR MM Loy. LedgerEntry (Srvr)";
        StoreSetup: Record "NPR MM Loyalty Store Setup";
        Membership: Record "NPR MM Membership";
        LoyaltySetup: Record "NPR MM Loyalty Setup";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin

        TmpAuthorizationIn.Reset();
        if (not TmpAuthorizationIn.FindFirst()) then begin
            ResponseMessage := AUTHORIZATION_MISSING;
            ResponseMessageId := '-1100';
            exit(false);
        end;

        if (not StoreSetup.Get(TmpAuthorizationIn."Company Name", TmpAuthorizationIn."POS Store Code", TmpAuthorizationIn."POS Unit Code")) then begin
            if (not StoreSetup.Get('', TmpAuthorizationIn."POS Store Code", '')) then begin
                ResponseMessage := StrSubstNo(E1101_SETUP_MISSING, TmpAuthorizationIn."Company Name", TmpAuthorizationIn."POS Store Code", TmpAuthorizationIn."POS Unit Code");
                ResponseMessageId := '-1101';
                exit(false);
            end;
        end;

        if (StoreSetup."Accept Client Transactions" = false) then begin
            ResponseMessage := E1110_NOT_ENABLED;
            ResponseMessageId := '-1110';
            exit(false);
        end;

        if (StoreSetup."Authorization Code" <> TmpAuthorizationIn."Authorization Code") then begin
            ResponseMessage := E1102_AUTHORIZATION_INCORRECT;
            ResponseMessageId := '-1102';
            exit(false);
        end;

        if ((BasicCheck) and (TmpAuthorizationIn."Card Number" = '')) then
            exit(true);

        if ((BasicCheck) and (TmpAuthorizationIn."Transaction Date" = 0D)) then
            TmpAuthorizationIn."Transaction Date" := Today();

        //IF ((TmpAuthorizationIn."Transaction Date" = 0D) OR (TmpAuthorizationIn."Transaction Date" >  Today())) THEN BEGIN
        if (TmpAuthorizationIn."Transaction Date" = 0D) then begin
            ResponseMessage := E1104_DATE_INCORRECT;
            ResponseMessageId := '-1104';
            exit(false);
        end;

        MembershipEntryNo := MembershipManagement.GetMembershipFromExtCardNo(TmpAuthorizationIn."Card Number", TmpAuthorizationIn."Transaction Date", ResponseMessage);
        if (MembershipEntryNo = 0) then begin
            ResponseMessage := StrSubstNo(MEMBERSHIP_1, TmpAuthorizationIn."Card Number");
            ResponseMessageId := '-1106';
            exit(false);
        end;

        if (not Membership.Get(MembershipEntryNo)) then begin
            ResponseMessage := StrSubstNo(MEMBERSHIP_1, TmpAuthorizationIn."Card Number");
            ResponseMessageId := '-1107';
            exit(false);
        end;

        if (not MembershipSetup.Get(Membership."Membership Code")) then begin
            ResponseMessage := StrSubstNo(MEMBERSHIP_2, Membership."Membership Code");
            ResponseMessageId := '-1111';
            exit(false);
        end;

        if (MembershipSetup."Loyalty Code" = '') then begin
            ResponseMessage := StrSubstNo(MEMBERSHIP_3, Membership."Membership Code");
            ResponseMessageId := '-1112';
            exit(false);
        end;

        if (not LoyaltySetup.Get(MembershipSetup."Loyalty Code")) then begin
            ResponseMessage := StrSubstNo(MEMBERSHIP_3, Membership."Membership Code");
            ResponseMessageId := '-1113';
            exit(false);
        end;

        if (BasicCheck) then
            exit(true);

        if (TmpAuthorizationIn."Reference Number" = '') then begin
            ResponseMessage := E1103_RECEIPT_INCORRECT;
            ResponseMessageId := '-1103';
            exit(false);
        end;

        if (TmpAuthorizationIn."Transaction Time" = 0T) then begin
            ResponseMessage := E1105_TIME_INCORRECT;
            ResponseMessageId := '-1105';
            exit(false);
        end;

        if (TmpAuthorizationIn."Foreign Transaction Id" = '') then begin
            ResponseMessage := E1108_TRANSACTION_ID;
            ResponseMessageId := '-1108';
            exit(false);
        end;

        if (TmpAuthorizationIn."Entry Type" = TmpAuthorizationIn."Entry Type"::CANCEL_RESERVE) then
            exit(true);

        LoyaltyServerStoreLedger.SetFilter("Entry Type", '=%1', LoyaltyServerStoreLedger."Entry Type"::RECEIPT);
        LoyaltyServerStoreLedger.SetFilter("Reference Number", '=%1', TmpAuthorizationIn."Reference Number");
        LoyaltyServerStoreLedger.SetFilter("Company Name", '=%1', TmpAuthorizationIn."Company Name");
        LoyaltyServerStoreLedger.SetFilter("POS Store Code", '=%1', TmpAuthorizationIn."POS Store Code");
        LoyaltyServerStoreLedger.SetFilter("POS Unit Code", '=%1', TmpAuthorizationIn."POS Unit Code");
        if (not LoyaltyServerStoreLedger.IsEmpty()) then begin
            ResponseMessage := E1109_REF_NUM;
            ResponseMessageId := '-1109';
            exit(false);
        end;

        TmpAuthorizationIn."Authorization Code" := '';
        TmpAuthorizationIn.Modify();
        exit(true);
    end;

#pragma warning disable AA0206
    local procedure ValidateRegisterSales(var TmpSaleLines: Record "NPR MM Reg. Sales Buffer" temporary; var TmpPaymentLines: Record "NPR MM Reg. Sales Buffer" temporary; var ResponseMessage: Text; var ResponseMessageId: Text): Boolean
    var
        LoyaltyServerStoreLedger: Record "NPR MM Loy. LedgerEntry (Srvr)";
        GeneralLedgerSetup: Record "General Ledger Setup";
        MembershipPointsEntry: Record "NPR MM Members. Points Entry";
        EarnedPoints: Integer;
        BurnedPoints: Integer;
        EarnedAmount: Decimal;
        BurnedAmount: Decimal;
        PlaceHolderLbl: Label '[%1,%2]', Locked = true;
    begin

        TmpSaleLines.Reset();
        if (TmpSaleLines.FindSet()) then begin
            GeneralLedgerSetup.Get();
            repeat

                case TmpSaleLines.Type of
                    TmpSaleLines.Type::SALES:
                        if (TmpSaleLines."Total Points" < 0) then begin
                            ResponseMessage := SALE_1;
                            ResponseMessageId := '-1150';
                            exit(false);
                        end;

                    TmpSaleLines.Type::RETURN:
                        if (TmpSaleLines."Total Points" > 0) then begin
                            ResponseMessage := '';
                            ResponseMessageId := '-1151';
                            exit(false);
                        end;
                    else begin
                        ResponseMessage := StrSubstNo(TYPE_INCORRECT, StrSubstNo(PlaceHolderLbl, TmpSaleLines.Type::SALES, TmpSaleLines.Type::RETURN));
                        ResponseMessageId := '-1152';
                        exit(false);
                    end;
                end;

                EarnedPoints += TmpSaleLines."Total Points";
                EarnedAmount += TmpSaleLines."Total Amount";

                if ((TmpSaleLines."Currency Code" = '') or (TmpSaleLines."Currency Code" <> GeneralLedgerSetup."LCY Code")) then begin
                    ResponseMessage := StrSubstNo(PAYMENT_3, GeneralLedgerSetup."LCY Code");
                    ResponseMessageId := '-1153';
                    exit(false);
                end;

            until (TmpSaleLines.Next() = 0);
        end;

        TmpPaymentLines.Reset();
        if (TmpPaymentLines.FindSet()) then begin
            repeat

                case TmpPaymentLines.Type of
                    TmpPaymentLines.Type::PAYMENT:
                        if (TmpSaleLines."Total Points" < 0) then begin
                            ResponseMessage := SALE_1;
                            ResponseMessageId := '-1154';
                            exit(false);
                        end;

                    TmpPaymentLines.Type::REFUND:
                        if (TmpSaleLines."Total Points" > 0) then begin
                            ResponseMessage := SALE_1;
                            ResponseMessageId := '-1155';
                            exit(false);
                        end;
                    else begin
                        ResponseMessage := StrSubstNo(TYPE_INCORRECT, StrSubstNo(PlaceHolderLbl, TmpPaymentLines.Type::PAYMENT, TmpPaymentLines.Type::REFUND));
                        ResponseMessageId := '-1156';
                        exit(false);
                    end;
                end;

                if (TmpPaymentLines."Total Points" <> 0) then begin
                    BurnedPoints += TmpPaymentLines."Total Points";
                    BurnedAmount += TmpPaymentLines."Total Amount";

                    if (TmpPaymentLines."Authorization Code" = '') then begin
                        ResponseMessage := StrSubstNo(RESERVE_1, '', 3);
                        ResponseMessageId := '-1157';
                        exit(false);
                    end;

                    // make sure there is a reservation entry
                    if (TmpPaymentLines."Authorization Code" <> '') then begin
                        LoyaltyServerStoreLedger.SetCurrentKey("Authorization Code", "Entry Type");
                        LoyaltyServerStoreLedger.SetFilter("Authorization Code", '=%1', TmpPaymentLines."Authorization Code");
                        LoyaltyServerStoreLedger.SetFilter("Entry Type", '=%1', LoyaltyServerStoreLedger."Entry Type"::RESERVE);
                        if (not LoyaltyServerStoreLedger.FindLast()) then begin
                            ResponseMessage := StrSubstNo(RESERVE_1, TmpPaymentLines."Authorization Code", 1);
                            ResponseMessageId := '-1158';
                            exit(false);
                        end;

                        // payment points is transferred as positive, but stored as a negative
                        if ((LoyaltyServerStoreLedger."Burned Points" + TmpPaymentLines."Total Points") <> 0) then begin
                            ResponseMessage := StrSubstNo(PAYMENT_2, TmpPaymentLines."Authorization Code");
                            ResponseMessageId := '-1160';
                            exit(false);
                        end;

                        LoyaltyServerStoreLedger.CalcFields("Reservation is Captured");
                        if (LoyaltyServerStoreLedger."Reservation is Captured") then begin
                            ResponseMessage := StrSubstNo(RESERVE_1, TmpPaymentLines."Authorization Code", 4);
                            ResponseMessageId := '-1161';
                            exit(false);
                        end;

                        if (IsReservationCancelled(TmpPaymentLines."Authorization Code")) then begin
                            ResponseMessage := StrSubstNo(CANCEL_2, TmpPaymentLines."Authorization Code");
                            ResponseMessageId := '-2062';
                            exit(false);
                        end;
                    end;
                end;
            until (TmpPaymentLines.Next() = 0);
        end;

        TmpPaymentLines.Reset();
        if (TmpPaymentLines.FindSet()) then begin
            repeat
                // Remove the reserved amount
                if (TmpPaymentLines."Authorization Code" <> '') then begin
                    MembershipPointsEntry.SetCurrentKey("Authorization Code", "Entry Type");
                    MembershipPointsEntry.SetFilter("Authorization Code", '=%1', TmpPaymentLines."Authorization Code");
                    MembershipPointsEntry.SetFilter("Entry Type", '=%1', MembershipPointsEntry."Entry Type"::RESERVE);
                    if (MembershipPointsEntry.FindLast()) then begin
                        MembershipPointsEntry.Points := 0;
                        MembershipPointsEntry.Modify();
                    end;
                end;
            until (TmpPaymentLines.Next() = 0);
        end;

        exit(true);
    end;
#pragma warning restore AA0206

    local procedure ValidateReservePoints(var TmpReserveLines: Record "NPR MM Reg. Sales Buffer" temporary; MembershipEntryNo: Integer; var ResponseMessage: Text; var ResponseMessageId: Text): Boolean
    var
        Membership: Record "NPR MM Membership";
        TotalReservePoints: Decimal;
    begin

        Membership.Get(MembershipEntryNo);
        Membership.CalcFields("Remaining Points");

        TmpReserveLines.Reset();
        if (TmpReserveLines.FindSet()) then begin
            repeat
                if (TmpReserveLines."Total Points" <> 0) then begin
                    TotalReservePoints += TmpReserveLines."Total Points";

                    if (not (TmpReserveLines.Type in [TmpReserveLines.Type::PAYMENT, TmpReserveLines.Type::REFUND])) then begin
                        ResponseMessage := RESERVE_4;
                        ResponseMessageId := '-1202';
                    end;

                    if (TmpReserveLines."Total Points" < 0) and (TmpReserveLines.Type = TmpReserveLines.Type::PAYMENT) then begin
                        ResponseMessage := RESERVE_2;
                        ResponseMessageId := '-1200';
                        exit(false);
                    end;

                    if (TmpReserveLines."Total Points" > 0) and (TmpReserveLines.Type = TmpReserveLines.Type::REFUND) then begin
                        ResponseMessage := RESERVE_3;
                        ResponseMessageId := '-1201';
                        exit(false);
                    end;

                end;
            until (TmpReserveLines.Next() = 0);
        end;

        if (TotalReservePoints > 0) then begin
            if (TotalReservePoints > Membership."Remaining Points") then begin
                ResponseMessage := StrSubstNo(PAYMENT_4, TotalReservePoints, Membership."Remaining Points");
                ResponseMessageId := '-1203';
                exit(false);
            end;

        end;

        exit(true);
    end;

    local procedure CreateSalesEntry(LoyaltySetup: Record "NPR MM Loyalty Setup"; var LoyaltyStoreLedger: Record "NPR MM Loy. LedgerEntry (Srvr)"; Membership: Record "NPR MM Membership"; TmpBuffer: Record "NPR MM Reg. Sales Buffer" temporary; var TotalEarnAmount: Decimal)
    var
        MembershipPointsEntry: Record "NPR MM Members. Points Entry";
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
    begin

        MembershipPointsEntry.Init();

        MembershipPointsEntry."Entry No." := 0;
        MembershipPointsEntry."Posting Date" := LoyaltyStoreLedger."Transaction Date";

        MembershipPointsEntry."Membership Entry No." := Membership."Entry No.";
        MembershipPointsEntry."Customer No." := Membership."Customer No.";

        MembershipPointsEntry."POS Store Code" := LoyaltyStoreLedger."POS Store Code";
        MembershipPointsEntry."POS Unit Code" := LoyaltyStoreLedger."POS Unit Code";
        MembershipPointsEntry."Document No." := LoyaltyStoreLedger."Reference Number";
        MembershipPointsEntry."Loyalty Code" := LoyaltySetup.Code;
        MembershipPointsEntry."Authorization Code" := LoyaltyStoreLedger."Authorization Code";
        MembershipPointsEntry."Retail Id" := LoyaltyStoreLedger."Retail Id";
        MembershipPointsEntry."Retail Id Line" := TmpBuffer."Retail Id";

        MembershipPointsEntry."Item No." := TmpBuffer."Item No.";
        MembershipPointsEntry."Variant Code" := TmpBuffer."Variant Code";

        LoyaltyPointManagement.CalculatePointsValidPeriod(LoyaltySetup, MembershipPointsEntry."Posting Date", MembershipPointsEntry."Period Start", MembershipPointsEntry."Period End");

        case TmpBuffer.Type of
            TmpBuffer.Type::SALES:
                begin
                    MembershipPointsEntry."Entry Type" := MembershipPointsEntry."Entry Type"::SALE;
                    MembershipPointsEntry.Points := Abs(TmpBuffer."Total Points");
                    MembershipPointsEntry."Amount (LCY)" := Abs(TmpBuffer."Total Amount");
                end;
            TmpBuffer.Type::RETURN:
                begin
                    MembershipPointsEntry."Entry Type" := MembershipPointsEntry."Entry Type"::REFUND;
                    MembershipPointsEntry.Points := Abs(TmpBuffer."Total Points") * -1;
                    MembershipPointsEntry."Amount (LCY)" := Abs(TmpBuffer."Total Amount") * -1;
                end;
        end;

        MembershipPointsEntry."Awarded Points" := MembershipPointsEntry.Points;
        MembershipPointsEntry."Awarded Amount (LCY)" := MembershipPointsEntry."Amount (LCY)";

        MembershipPointsEntry.Quantity := TmpBuffer.Quantity;
        MembershipPointsEntry.Description := TmpBuffer.Description;

        _MembershipEvents.OnBeforeInsertPointEntry(MembershipPointsEntry);
        MembershipPointsEntry.Insert();

        LoyaltyStoreLedger."Earned Points" += MembershipPointsEntry.Points;
        TotalEarnAmount += MembershipPointsEntry."Amount (LCY)";
    end;

    local procedure CreateCaptureEntry(LoyaltySetup: Record "NPR MM Loyalty Setup"; var LoyaltyStoreLedger: Record "NPR MM Loy. LedgerEntry (Srvr)"; Membership: Record "NPR MM Membership"; TmpBuffer: Record "NPR MM Reg. Sales Buffer" temporary; var TotalBurnAmount: Decimal)
    var
        MembershipPointsEntry: Record "NPR MM Members. Points Entry";
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
    begin

        MembershipPointsEntry.Init();
        MembershipPointsEntry."Entry No." := 0;
        MembershipPointsEntry."Entry Type" := MembershipPointsEntry."Entry Type"::CAPTURE;

        MembershipPointsEntry."Posting Date" := LoyaltyStoreLedger."Transaction Date";

        MembershipPointsEntry."Membership Entry No." := Membership."Entry No.";
        MembershipPointsEntry."Customer No." := Membership."Customer No.";

        MembershipPointsEntry."POS Store Code" := LoyaltyStoreLedger."POS Store Code";
        MembershipPointsEntry."POS Unit Code" := LoyaltyStoreLedger."POS Unit Code";
        MembershipPointsEntry."Document No." := LoyaltyStoreLedger."Reference Number";
        MembershipPointsEntry."Loyalty Code" := LoyaltySetup.Code;
        MembershipPointsEntry."Authorization Code" := TmpBuffer."Authorization Code";
        MembershipPointsEntry."Retail Id" := LoyaltyStoreLedger."Retail Id";
        MembershipPointsEntry."Retail Id Line" := TmpBuffer."Retail Id";

        LoyaltyPointManagement.CalculatePointsValidPeriod(LoyaltySetup, MembershipPointsEntry."Posting Date", MembershipPointsEntry."Period Start", MembershipPointsEntry."Period End");

        MembershipPointsEntry.Points := 0;
        case TmpBuffer.Type of
            TmpBuffer.Type::PAYMENT:
                begin
                    MembershipPointsEntry.Points := Abs(TmpBuffer."Total Points") * -1;
                    MembershipPointsEntry."Amount (LCY)" := Abs(TmpBuffer."Total Amount") * -1;
                end;
            TmpBuffer.Type::REFUND:
                begin
                    MembershipPointsEntry.Points := Abs(TmpBuffer."Total Points");
                    MembershipPointsEntry."Amount (LCY)" := Abs(TmpBuffer."Total Amount");
                end;
        end;

        MembershipPointsEntry."Redeemed Points" := MembershipPointsEntry.Points;
        MembershipPointsEntry."Awarded Amount (LCY)" := MembershipPointsEntry."Amount (LCY)";

        MembershipPointsEntry.Quantity := 1;
        MembershipPointsEntry.Description := TmpBuffer.Description;

        _MembershipEvents.OnBeforeInsertPointEntry(MembershipPointsEntry);
        MembershipPointsEntry.Insert();

        // Payment points are negative
        LoyaltyStoreLedger."Burned Points" += MembershipPointsEntry.Points;
        TotalBurnAmount += MembershipPointsEntry."Amount (LCY)";
    end;

    local procedure CreateReserveEntry(LoyaltySetup: Record "NPR MM Loyalty Setup"; var LoyaltyStoreLedger: Record "NPR MM Loy. LedgerEntry (Srvr)"; Membership: Record "NPR MM Membership"; TmpBuffer: Record "NPR MM Reg. Sales Buffer" temporary)
    var
        MembershipPointsEntry: Record "NPR MM Members. Points Entry";
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
    begin

        MembershipPointsEntry.Init();
        MembershipPointsEntry."Entry No." := 0;
        MembershipPointsEntry."Entry Type" := MembershipPointsEntry."Entry Type"::RESERVE;
        MembershipPointsEntry."Posting Date" := LoyaltyStoreLedger."Transaction Date";

        MembershipPointsEntry."Membership Entry No." := Membership."Entry No.";
        MembershipPointsEntry."Customer No." := Membership."Customer No.";

        MembershipPointsEntry."POS Store Code" := LoyaltyStoreLedger."POS Store Code";
        MembershipPointsEntry."POS Unit Code" := LoyaltyStoreLedger."POS Unit Code";
        MembershipPointsEntry."Document No." := LoyaltyStoreLedger."Reference Number";
        MembershipPointsEntry."Loyalty Code" := LoyaltySetup.Code;
        MembershipPointsEntry."Authorization Code" := LoyaltyStoreLedger."Authorization Code";
        MembershipPointsEntry."Retail Id" := LoyaltyStoreLedger."Retail Id";
        MembershipPointsEntry."Retail Id Line" := TmpBuffer."Retail Id";

        LoyaltyPointManagement.CalculatePointsValidPeriod(LoyaltySetup, MembershipPointsEntry."Posting Date", MembershipPointsEntry."Period Start", MembershipPointsEntry."Period End");

        case TmpBuffer.Type of
            TmpBuffer.Type::PAYMENT:
                begin
                    MembershipPointsEntry.Points := Abs(TmpBuffer."Total Points") * -1;
                    MembershipPointsEntry."Amount (LCY)" := Abs(TmpBuffer."Total Amount") * -1;
                end;
            TmpBuffer.Type::REFUND:
                begin
                    MembershipPointsEntry.Points := Abs(TmpBuffer."Total Points");
                    MembershipPointsEntry."Amount (LCY)" := Abs(TmpBuffer."Total Amount");
                end;
        end;

        LoyaltyStoreLedger."Burned Points" += MembershipPointsEntry.Points;
        MembershipPointsEntry."Awarded Points" := 0;
        MembershipPointsEntry."Awarded Amount (LCY)" := 0;
        MembershipPointsEntry.Description := TmpBuffer.Description;
        MembershipPointsEntry.Quantity := 1;

        _MembershipEvents.OnBeforeInsertPointEntry(MembershipPointsEntry);
        MembershipPointsEntry.Insert();
    end;

    local procedure IsReservationCancelled(AuthorizationCode: Text[40]): Boolean
    var
        ReservationLedgerEntry: Record "NPR MM Loy. LedgerEntry (Srvr)";
    begin
        if (AuthorizationCode = '') then
            exit(false);

        ReservationLedgerEntry.SetCurrentKey("Authorization Code");
        ReservationLedgerEntry.SetFilter("Authorization Code", '=%1', AuthorizationCode);
        ReservationLedgerEntry.SetFilter("Entry Type", '=%1', ReservationLedgerEntry."Entry Type"::CANCEL_RESERVE);
        exit(not ReservationLedgerEntry.IsEmpty());
    end;

    internal procedure ExpireReservations(SourceReservation: Record "NPR MM Loy. LedgerEntry (Srvr)")
    var
        CancelReservationEntry: Record "NPR MM Loy. LedgerEntry (Srvr)";
        ReversedPoints: Integer;
    begin
        CancelReservationEntry.TransferFields(SourceReservation, false);
        CancelReservationEntry."Entry No." := 0;
        CancelReservationEntry."Entry Type" := CancelReservationEntry."Entry Type"::CANCEL_RESERVE;
        CancelReservationEntry."Foreign Transaction Id" := StrSubstNo('Expired %1', CurrentDateTime());
        CancelReservationEntry."Transaction Date" := Today();
        CancelReservationEntry."Transaction Time" := Time;
        CancelReservationEntry."Earned Points" -= CancelReservationEntry."Earned Points";
        CancelReservationEntry."Burned Points" -= CancelReservationEntry."Burned Points";
        CancelReservationEntry.Balance := 0;

        if (CreateCancelReserveEntry(CancelReservationEntry."Authorization Code", ReversedPoints)) then
            CancelReservationEntry.Insert();

    end;

    local procedure CreateCancelReserveEntry(AuthorizationCodeToCancel: Text[40]; var ReversedPoints: Integer): Boolean
    var
        MembershipPointsEntry: Record "NPR MM Members. Points Entry";
    begin
        ReversedPoints := 0;
        MembershipPointsEntry.SetCurrentKey("Authorization Code", "Entry Type");
        MembershipPointsEntry.SetFilter("Authorization Code", '=%1', AuthorizationCodeToCancel);
        MembershipPointsEntry.SetFilter("Entry Type", '=%1', MembershipPointsEntry."Entry Type"::RESERVE);
        if (not MembershipPointsEntry.FindLast()) then
            exit(false);

        MembershipPointsEntry."Entry No." := 0;
        MembershipPointsEntry."Entry Type" := MembershipPointsEntry."Entry Type"::RESERVE_CANCELLED;
        MembershipPointsEntry.Points *= -1;
        MembershipPointsEntry."Awarded Points" *= -1;
        MembershipPointsEntry."Amount (LCY)" *= -1;
        MembershipPointsEntry."Awarded Amount (LCY)" *= -1;
        _MembershipEvents.OnBeforeInsertPointEntry(MembershipPointsEntry);
        MembershipPointsEntry.Insert();

        ReversedPoints := MembershipPointsEntry.Points;
        exit(true);
    end;

    local procedure CreateCaptureReserveEntry(AuthorizationCodeToCancel: Text[40]; var CapturedPoints: Integer): Boolean
    var
        ReservePointsEntry: Record "NPR MM Members. Points Entry";
        CapturePointsEntry: Record "NPR MM Members. Points Entry";
    begin
        CapturedPoints := 0;
        ReservePointsEntry.SetCurrentKey("Authorization Code", "Entry Type");
        ReservePointsEntry.SetFilter("Authorization Code", '=%1', AuthorizationCodeToCancel);
        ReservePointsEntry.SetFilter("Entry Type", '=%1', ReservePointsEntry."Entry Type"::RESERVE);
        if (not ReservePointsEntry.FindLast()) then
            exit(false);

        CapturePointsEntry.TransferFields(ReservePointsEntry, false);
        CapturePointsEntry."Entry No." := 0;
        CapturePointsEntry."Entry Type" := ReservePointsEntry."Entry Type"::CAPTURE;
        CapturePointsEntry."Redeemed Points" := CapturePointsEntry.Points;
        CapturePointsEntry."Awarded Amount (LCY)" := CapturePointsEntry."Amount (LCY)";
        _MembershipEvents.OnBeforeInsertPointEntry(CapturePointsEntry);
        CapturePointsEntry.Insert();

        ReservePointsEntry.Points := 0;
        ReservePointsEntry."Awarded Points" := 0;
        ReservePointsEntry."Awarded Amount (LCY)" := 0;
        ReservePointsEntry.Modify();

        CapturedPoints := CapturePointsEntry.Points;
        exit(true);
    end;

    local procedure CreateNotEligibleEntry(LoyaltySetup: Record "NPR MM Loyalty Setup"; var LoyaltyStoreLedger: Record "NPR MM Loy. LedgerEntry (Srvr)"; Membership: Record "NPR MM Membership"; TotalEarnAmount: Decimal; TotalBurnAmount: Decimal)
    var
        MembershipPointsEntry: Record "NPR MM Members. Points Entry";
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
        EarnRatio: Decimal;
    begin

        MembershipPointsEntry.Init();
        MembershipPointsEntry."Entry No." := 0;
        MembershipPointsEntry."Entry Type" := MembershipPointsEntry."Entry Type"::CAPTURE;

        MembershipPointsEntry."Posting Date" := LoyaltyStoreLedger."Transaction Date";

        MembershipPointsEntry."Membership Entry No." := Membership."Entry No.";
        MembershipPointsEntry."Customer No." := Membership."Customer No.";

        MembershipPointsEntry."POS Store Code" := LoyaltyStoreLedger."POS Store Code";
        MembershipPointsEntry."POS Unit Code" := LoyaltyStoreLedger."POS Unit Code";
        MembershipPointsEntry."Document No." := LoyaltyStoreLedger."Reference Number";
        MembershipPointsEntry."Loyalty Code" := LoyaltySetup.Code;
        MembershipPointsEntry."Retail Id" := LoyaltyStoreLedger."Retail Id";

        LoyaltyPointManagement.CalculatePointsValidPeriod(LoyaltySetup, MembershipPointsEntry."Posting Date", MembershipPointsEntry."Period Start", MembershipPointsEntry."Period End");

        EarnRatio := LoyaltyStoreLedger."Earned Points" / TotalEarnAmount;

        MembershipPointsEntry."Amount (LCY)" := TotalBurnAmount;
        MembershipPointsEntry.Points := Round(MembershipPointsEntry."Amount (LCY)" * EarnRatio, 1);

        MembershipPointsEntry."Awarded Points" := MembershipPointsEntry.Points;
        MembershipPointsEntry."Awarded Amount (LCY)" := MembershipPointsEntry."Amount (LCY)";

        MembershipPointsEntry.Quantity := 1;
        MembershipPointsEntry.Description := 'Amount not eligible for points';

        _MembershipEvents.OnBeforeInsertPointEntry(MembershipPointsEntry);
        MembershipPointsEntry.Insert();

        LoyaltyStoreLedger."Earned Points" += MembershipPointsEntry.Points;
    end;

    procedure InvoiceAllStorePoints()
    var
        LoyaltyStoreSetup: Record "NPR MM Loyalty Store Setup";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesManagement: Codeunit "No. Series";
#ELSE
        NoSeriesManagement: Codeunit NoSeriesManagement;
#ENDIF
        GenJnlPostBatch: Codeunit "Gen. Jnl.-Post Batch";
        DocumentNo: Code[20];
        JnlType: Option;
        PlaceHolderLbl: Label '%1,%2', Locked = true;
    begin
        JnlType := StrMenu(StrSubstNo(PlaceHolderLbl, Format(GenJournalBatch."Template Type"::General), Format(GenJournalBatch."Template Type"::Intercompany)), 1, SELECT_JNL_TYPE);
        case JnlType of
            1:
                GenJournalBatch.SetFilter("Template Type", '=%1', GenJournalBatch."Template Type"::General);
            2:
                GenJournalBatch.SetFilter("Template Type", '=%1', GenJournalBatch."Template Type"::Intercompany);
            else
                Error('');
        end;

        GenJournalBatch.SetFilter(Recurring, '=%1', false);
        GenJournalBatch.FindFirst();

        if (GenJournalBatch."No. Series" <> '') then
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
            DocumentNo := NoSeriesManagement.PeekNextNo(GenJournalBatch."No. Series", WorkDate());
#ELSE
            DocumentNo := NoSeriesManagement.TryGetNextNo(GenJournalBatch."No. Series", WorkDate());
#ENDIF

        GenJournalLine.SetFilter("Journal Template Name", '=%1', GenJournalBatch."Journal Template Name");
        GenJournalLine.SetFilter("Journal Batch Name", '=%1', GenJournalBatch.Name);

        if (not GenJournalLine.IsEmpty()) then begin
            if (not Confirm(JNL_NOT_EMPTY, false, GenJournalBatch."Journal Template Name", GenJournalBatch.Name)) then
                Error('');

            GenJournalLine.DeleteAll();
        end;

        LoyaltyStoreSetup.FindSet();
        repeat
            InvoiceStoreWorker(GenJournalBatch."Journal Template Name", GenJournalBatch.Name, DocumentNo, LoyaltyStoreSetup);
        until (LoyaltyStoreSetup.Next() = 0);

        if (GenJournalLine.FindFirst()) then
            GenJnlPostBatch.Run(GenJournalLine);
    end;

    procedure InvoiceOneStorePoints(LoyaltyStoreSetup: Record "NPR MM Loyalty Store Setup")
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesManagement: Codeunit "No. Series";
#ELSE
        NoSeriesManagement: Codeunit NoSeriesManagement;
#ENDIF
        GenJnlPostBatch: Codeunit "Gen. Jnl.-Post Batch";
        DocumentNo: Code[20];
        JnlType: Option;
        PlaceHolderLbl: Label '%1,%2', Locked = true;
    begin
        JnlType := StrMenu(StrSubstNo(PlaceHolderLbl, Format(GenJournalBatch."Template Type"::General), Format(GenJournalBatch."Template Type"::Intercompany)), 1, SELECT_JNL_TYPE);
        case JnlType of
            1:
                GenJournalBatch.SetFilter("Template Type", '=%1', GenJournalBatch."Template Type"::General);
            2:
                GenJournalBatch.SetFilter("Template Type", '=%1', GenJournalBatch."Template Type"::Intercompany);
            else
                Error('');
        end;

        GenJournalBatch.SetFilter(Recurring, '=%1', false);
        GenJournalBatch.FindFirst();

        if (GenJournalBatch."No. Series" <> '') then
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
            DocumentNo := NoSeriesManagement.PeekNextNo(GenJournalBatch."No. Series", WorkDate());
#ELSE
            DocumentNo := NoSeriesManagement.TryGetNextNo(GenJournalBatch."No. Series", WorkDate());
#ENDIF

        GenJournalLine.SetFilter("Journal Template Name", '=%1', GenJournalBatch."Journal Template Name");
        GenJournalLine.SetFilter("Journal Batch Name", '=%1', GenJournalBatch.Name);

        if (not GenJournalLine.IsEmpty()) then begin
            if (not Confirm(JNL_NOT_EMPTY, false, GenJournalBatch."Journal Template Name", GenJournalBatch.Name)) then
                Error('');

            GenJournalLine.DeleteAll();
        end;

        InvoiceStoreWorker(GenJournalBatch."Journal Template Name", GenJournalBatch.Name, DocumentNo, LoyaltyStoreSetup);

        if (GenJournalLine.FindFirst()) then
            GenJnlPostBatch.Run(GenJournalLine);
    end;

    local procedure InvoiceStoreWorker(JournalTemplateName: Code[10]; JournalBatchName: Code[10]; DocumentNo: Code[20]; LoyaltyStoreSetup: Record "NPR MM Loyalty Store Setup")
    var
        GenJournalLine: Record "Gen. Journal Line";
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesManagement: Codeunit "No. Series";
#ELSE
        NoSeriesManagement: Codeunit NoSeriesManagement;
#ENDIF
        UntilDate: Date;
        EarnAmount: Decimal;
        BurnAmount: Decimal;
        EarnPoints: Integer;
        BurnPoints: Integer;
        PostingBurnCurrencyCode: Code[10];
        PostingBurnAmount: Decimal;
        PostingEarnAmount: Decimal;
        InvoiceNo: Code[20];
        DocType: Enum "Gen. Journal Document Type";
        PeriodEarnBurnLbl: Label 'Period ..%1, Earn: %2, Burn: %3';
    begin

        case LoyaltyStoreSetup."Reconciliation Period" of
            LoyaltyStoreSetup."Reconciliation Period"::PREVIOUS_MONTH:
                UntilDate := CalcDate('<-CM-1D>', Today);
            LoyaltyStoreSetup."Reconciliation Period"::TODAY:
                UntilDate := Today();
        end;

        case LoyaltyStoreSetup."Posting Model" of
            LoyaltyStoreSetup."Posting Model"::CURRENCY:
                begin
                    LoyaltyStoreSetup.TestField("Burn Points Currency Code");
                end;
            LoyaltyStoreSetup."Posting Model"::LCY:
                begin
                    LoyaltyStoreSetup.TestField("Loyalty Setup Code");
                end;
        end;

        LoyaltyStoreSetup.TestField("Customer No.");
        LoyaltyStoreSetup.TestField("Invoice No. Series");

        InvoiceNo := DocumentNo;
        if (InvoiceNo = '') then
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
            InvoiceNo := NoSeriesManagement.GetNextNo(LoyaltyStoreSetup."Invoice No. Series", UntilDate, false);
#ELSE
            InvoiceNo := NoSeriesManagement.GetNextNo(LoyaltyStoreSetup."Invoice No. Series", UntilDate, true);
#ENDIF
        GenJournalLine.Init();
        GenJournalLine."Journal Template Name" := JournalTemplateName;
        GenJournalLine."Journal Batch Name" := JournalBatchName;
        GenJournalLine."Line No." := 0;

        ReconcilePoints(LoyaltyStoreSetup, UntilDate, InvoiceNo, EarnPoints, EarnAmount, BurnPoints, BurnAmount);

        case LoyaltyStoreSetup."Posting Model" of
            LoyaltyStoreSetup."Posting Model"::CURRENCY:
                begin
                    PostingBurnCurrencyCode := LoyaltyStoreSetup."Burn Points Currency Code";
                    PostingEarnAmount := EarnPoints;
                    PostingBurnAmount := BurnPoints;
                end;

            LoyaltyStoreSetup."Posting Model"::LCY:
                begin
                    PostingEarnAmount := EarnAmount;
                    PostingBurnAmount := BurnAmount;
                end;
        end;

        DocType := GenJournalLine."Document Type"::Invoice;
        if (PostingEarnAmount + PostingBurnAmount < 0) then
            DocType := GenJournalLine."Document Type"::"Credit Memo";

        MakeJournalLine(GenJournalLine,
          UntilDate,
          DocumentNo,
          DocType,
          LoyaltyStoreSetup."Customer No.",
          StrSubstNo(PeriodEarnBurnLbl, UntilDate, EarnPoints, BurnPoints),
          PostingBurnCurrencyCode, // Note: the earned points are projected and valued in burn exchange rate when realized.
          PostingEarnAmount + PostingBurnAmount,
          LoyaltyStoreSetup."G/L Account No.",
          InvoiceNo);
        if (PostingEarnAmount + PostingBurnAmount <> 0) then
            GenJournalLine.Insert(true);
    end;

    local procedure MakeJournalLine(var GenJournalLine: Record "Gen. Journal Line"; PostingDate: Date; DocumentNo: Code[20]; DocType: Enum "Gen. Journal Document Type"; AccNo: Code[20]; Description: Text[50]; CurrencyCode: Code[10]; AmountToPost: Decimal; BalanceGLAccont: Code[20]; InvoiceNo: Code[20])
    begin

        GenJournalLine."Line No." += 10000;
        GenJournalLine.Init();

        GenJournalLine.Validate("Posting Date", PostingDate);
        if (DocumentNo = '') then
            DocumentNo := InvoiceNo;

        GenJournalLine."Document No." := DocumentNo;
        GenJournalLine.Validate("Document Type", DocType);
        GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::Customer);
        GenJournalLine.Validate("Account No.", AccNo);

        GenJournalLine.Validate(Description, Description);
        GenJournalLine.Validate("Currency Code", CurrencyCode);
        GenJournalLine.Validate(Amount, AmountToPost);
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
        GenJournalLine.Validate("Bal. Account No.", BalanceGLAccont);
        GenJournalLine.Validate("External Document No.", InvoiceNo);
    end;

    local procedure ReconcilePoints(LoyaltyStoreSetup: Record "NPR MM Loyalty Store Setup"; UntilDate: Date; ReconciliationReference: Code[20]; var EarnPoints: Integer; var EarnAmount: Decimal; var BurnPoints: Integer; var BurnAmount: Decimal)
    var
        LoyaltySetup: Record "NPR MM Loyalty Setup";
        LoyaltyLedgerEntry: Record "NPR MM Loy. LedgerEntry (Srvr)";
    begin

        LoyaltyStoreSetup.SetFilter("Date Filter", '..%1', UntilDate);
        LoyaltyStoreSetup.CalcFields("Outstanding Burn Points", "Outstanding Earn Points");

        EarnPoints := LoyaltyStoreSetup."Outstanding Earn Points";
        BurnPoints := LoyaltyStoreSetup."Outstanding Burn Points";

        if (LoyaltyStoreSetup."Posting Model" = LoyaltyStoreSetup."Posting Model"::LCY) then begin
            LoyaltySetup.Get(LoyaltyStoreSetup."Loyalty Setup Code");
            EarnAmount := EarnPoints * LoyaltySetup."Point Rate"; // Note: the earned points are projected and valued in burn exchange rate when realized.
            BurnAmount := BurnPoints * LoyaltySetup."Point Rate";
        end;

        LoyaltyLedgerEntry."Entry No." := 0;
        LoyaltyLedgerEntry."Entry Type" := LoyaltyLedgerEntry."Entry Type"::RECONCILE;
        LoyaltyLedgerEntry."Company Name" := LoyaltyStoreSetup."Client Company Name";
        LoyaltyLedgerEntry."POS Store Code" := LoyaltyStoreSetup."Store Code";
        LoyaltyLedgerEntry."POS Unit Code" := LoyaltyStoreSetup."Unit Code";
        LoyaltyLedgerEntry."Transaction Date" := UntilDate;
        LoyaltyLedgerEntry."Transaction Time" := Time;
        LoyaltyLedgerEntry."Reference Number" := ReconciliationReference;
        LoyaltyLedgerEntry."Earned Points" := EarnPoints * -1;
        LoyaltyLedgerEntry."Burned Points" := BurnPoints * -1;
        LoyaltyLedgerEntry.Insert();
    end;
#pragma warning disable AA0139
    local procedure CreateAuthorizationCode(): Text[40]
    begin
        exit(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')));
    end;
#pragma warning restore
}

