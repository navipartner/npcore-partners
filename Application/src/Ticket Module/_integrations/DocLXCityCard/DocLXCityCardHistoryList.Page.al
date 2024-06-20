page 6184576 "NPR DocLXCityCardHistoryList"
{
    Caption = 'DocLX Card History List';
    Extensible = False;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR DocLXCityCardHistory";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field(EntryNo; Rec.EntryNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Entry No. field.';
                    Editable = _IsEditable;
                }
                field(CardNumber; Rec.CardNumber)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Card Number field.';
                    Editable = _IsEditable;
                }
                field(CityCode; Rec.CityCode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the City Code field.';
                    Editable = _IsEditable;
                }
                field(LocationCode; Rec.LocationCode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Location Code field.';
                    Editable = _IsEditable;
                }
                field(POSUnitNo; Rec.POSUnitNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the POS Unit No. field.';
                    Editable = _IsEditable;
                }
                field(SalesTicketNo; Rec.SalesDocumentNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field.';
                    Editable = _IsEditable;
                }
                field(ValidationResultCode; Rec.ValidationResultCode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Validation Result Code field.';
                    Editable = _IsEditable;
                }
                field(ValidationResultMessage; Rec.ValidationResultMessage)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Validation Result Message field.';
                    Editable = _IsEditable;
                }
                field(ValidatedAtDateTime; Rec.ValidatedAtDateTime)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Validated At Date Time field.';
                    Editable = _IsEditable;
                }
                field(ValidatedAtDateTimeUtc; Rec.ValidatedAtDateTimeUtc)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Validated At Date Time (UTC) field.';
                    Editable = _IsEditable;
                }
                field(RedeemedAtDateTime; Rec.RedeemedAtDateTime)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Redeemed At Date Time field.';
                    Editable = _IsEditable;
                }
                field(RedemptionResultCode; Rec.RedemptionResultCode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Redemption Result Code field.';
                    Editable = _IsEditable;
                }
                field(RedemptionResultMessage; Rec.RedemptionResultMessage)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Redemption Result Message field.';
                    Editable = _IsEditable;
                }
                field(CouponResultCode; Rec.CouponResultCode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Coupon Result Code field.';
                    Editable = _IsEditable;
                }
                field(CouponResultMessage; Rec.CouponResultMessage)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Coupon Result Message field.';
                    Editable = _IsEditable;
                }

                field(CouponType; Rec.CouponType)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Coupon Type field.';
                    Editable = _IsEditable;
                }
                field(CouponNo; Rec.CouponNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Coupon No. field.';
                    Editable = _IsEditable;
                }
                field(CouponReferenceNo; Rec.CouponReferenceNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Coupon Reference No. field.';
                    Editable = _IsEditable;
                }

                field(IsRedeemed; _IsRedeemed)
                {
                    Caption = 'Redeemed';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies if coupon is redeemed.';
                    Editable = false;
                }

                field(ArticleId; Rec.ArticleId)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Article ID field.';
                    Editable = _IsEditable;
                }
                field(ArticleName; Rec.ArticleName)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Article Name field.';
                    Editable = _IsEditable;
                }
                field(CategoryName; Rec.CategoryName)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Category Name field.';
                    Editable = _IsEditable;
                }
                field(ActivationDate; Rec.ActivationDate)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Activation Date field.';
                    Editable = _IsEditable;
                }
                field(ValidUntilDate; Rec.ValidUntilDate)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Valid Until Date field.';
                    Editable = _IsEditable;
                }
                field(ValidTimeSpan; Rec.ValidTimeSpan)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Valid Time Span field.';
                    Editable = _IsEditable;
                }

                field(ShopKey; Rec.ShopKey)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Shop Key field.';
                    Editable = _IsEditable;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SetEditable)
            {
                ApplicationArea = NPRTicketAdvanced;
                Caption = 'Set Editable';
                ToolTip = 'Set editable mode for the page.';
                Image = Edit;
                trigger OnAction()
                begin
                    _IsEditable := true;
                    CurrPage.Update(false);
                end;
            }
        }

        area(Navigation)
        {
            action(TicketRequest)
            {
                Caption = 'Ticket Request';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                ToolTip = 'Show ticket request for this City Card entry.';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Scope = Repeater;
                Image = Navigate;

                trigger OnAction()
                begin
                    Rec.TestField(SalesDocumentNo);
                    DisplayTicketRequest(Rec.SalesDocumentNo);
                end;
            }

            action(ShowCoupon)
            {
                Caption = 'Show Coupon';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                ToolTip = 'Show coupon for this City Card entry.';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Scope = Repeater;
                Image = Navigate;

                trigger OnAction()
                var
                    CouponsPage: Page "NPR NpDc Coupons";
                    Coupons: Record "NPR NpDc Coupon";
                    ArchivedCouponsPage: Page "NPR NpDc Arch. Coupons";
                    ArchivedCoupons: Record "NPR NpDc Arch. Coupon";
                begin
                    if (IsCouponArchived(Rec.CouponNo)) then begin
                        Rec.TestField(CouponReferenceNo);
                        ArchivedCoupons.SetFilter("Reference No.", '=%1', Rec.CouponReferenceNo);
                        ArchivedCouponsPage.SetTableView(ArchivedCoupons);
                        ArchivedCouponsPage.Run();
                    end else begin
                        Rec.TestField(Rec.CouponNo);
                        Coupons.SetFilter("No.", '=%1', Rec.CouponNo);
                        CouponsPage.SetTableView(Coupons);
                        CouponsPage.Run();
                    end;
                end;
            }
        }

    }

    var
        _IsEditable: Boolean;
        _IsRedeemed: Boolean;

    trigger OnOpenPage()
    begin
        _IsEditable := false;
    end;

    trigger OnAfterGetRecord()
    begin
        _IsRedeemed := IsCouponArchived(Rec.CouponNo);
    end;

    local procedure IsCouponArchived(CouponNumber: Code[20]): Boolean
    var
        Coupon: Record "NPR NpDc Coupon";
    begin
        if (CouponNumber = '') then
            exit(false);

        exit(not Coupon.Get(CouponNumber));
    end;

    local procedure DisplayTicketRequest(ReceiptNumber: Code[20]);
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TempTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary;
    begin

        TicketReservationRequest.SetFilter("Receipt No.", '=%1', ReceiptNumber);
        if (TicketReservationRequest.FindFirst()) then
            AddRequestToTmp(TicketReservationRequest."Session Token ID", TempTicketReservationRequest);

        TicketReservationRequest.CalcFields("Is Superseeded");
        repeat
            if (TicketReservationRequest."Is Superseeded") then begin
                TicketReservationRequest.Reset();
                TicketReservationRequest.SetFilter("Superseeds Entry No.", '=%1', TicketReservationRequest."Entry No.");
                TicketReservationRequest.FindFirst();
                AddRequestToTmp(TicketReservationRequest."Session Token ID", TempTicketReservationRequest);

                TicketReservationRequest.CalcFields("Is Superseeded");
            end;
        until (not TicketReservationRequest."Is Superseeded");

        Page.Run(Page::"NPR TM Ticket Request", TempTicketReservationRequest);
    end;

    local procedure AddRequestToTmp(Token: Text[100]; var TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary);
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin

        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindSet()) then begin
            repeat
                TmpTicketReservationRequest.TransferFields(TicketReservationRequest, true);
                TmpTicketReservationRequest.Insert();
            until (TicketReservationRequest.Next() = 0);
        end;
    end;

}