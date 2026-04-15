page 6059867 "NPR TM Price Profile Simulator"
{
    Extensible = False;
    Caption = 'Dynamic Price Profile Analyzer';
    PageType = Worksheet;
    UsageCategory = None;
    SourceTable = Date;
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/intro/';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {

            group(Simulation)
            {
                Caption = 'Price Simulation';
                field(_ItemNo; _ItemNo)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    Caption = 'Item No.';
                    ToolTip = 'Specifies the value of the Item No. field.';
                    Visible = _ItemNo <> '';
                    Editable = false;
                }
                field(_VariantCode; _VariantCode)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    Caption = 'Variant Code';
                    ToolTip = 'Specifies the value of the Variant Code field.';
                    Visible = _VariantCode <> '';
                    Editable = false;
                }
                field(_ProfileCode; _ProfileCode)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    Caption = 'Price Profile Code';
                    ToolTip = 'Specifies the value of the Price Profile Code field.';
                    Visible = _ProfileCode <> '';
                    Editable = false;
                }

                Group(DateAndTime)
                {
                    Caption = 'Date and Time for Price Simulation';

                    field(BookingDate; _BookingDate)
                    {
                        ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                        Caption = 'Booking Date';
                        ToolTip = 'Specify the event date for which you want to analyze admission price.';
                        trigger OnValidate()
                        var
                            TicketDynamicPrice: Codeunit "NPR TM Dynamic Price";
                        begin
                            if (_BookingDate = 0D) then
                                _BookingDate := Today();

                            TicketDynamicPrice.CalculateErpUnitPrice(_ItemNo, _VariantCode, _CustomerNo, _BookingDate, 1, _ErpUnitPrice, _ErpDiscountPct, _UnitPriceIncludesVAT, _UnitPriceVatPercentage);
                            Rec.SetFilter("Period Start", '%1..', _BookingDate);
                            Rec.FindFirst();
                            CurrPage.Update(false);
                        end;
                    }

                    field(AdmissionLocalTime; _LocalAdmissionTime)
                    {
                        ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                        Caption = 'Admission Local Time';
                        ToolTip = 'Specify the local time for which you want to analyze admission price.';
                        trigger OnValidate()
                        var
                            TicketDynamicPrice: Codeunit "NPR TM Dynamic Price";
                        begin
                            if (_BookingDate = 0D) then
                                _BookingDate := Today();

                            TicketDynamicPrice.CalculateErpUnitPrice(_ItemNo, _VariantCode, _CustomerNo, _BookingDate, 1, _ErpUnitPrice, _ErpDiscountPct, _UnitPriceIncludesVAT, _UnitPriceVatPercentage);
                            Rec.SetFilter("Period Start", '%1..', _BookingDate);
                            Rec.FindFirst();
                            CurrPage.Update(false);
                        end;
                    }
                }
                field(OriginalUnitPrice; _ErpUnitPrice)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    Caption = 'Unit Price';
                    ToolTip = 'Specify the value for Unit Price field. In the simulation, this will be the original (ERP) price.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;
                }
                field(OriginalUnitDiscountPct; _ErpDiscountPct)
                {
                    Caption = 'Unit Discount %';
                    ToolTip = 'Specify the value for Unit Discount % field. In the simulation, this will be the original (ERP) discount percentage from the price list. It is not included in the price calculation.';
                    Editable = false;
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    Visible = false;
                }
                field(UnitPriceIncludesVAT; _UnitPriceIncludesVAT)
                {
                    Caption = 'Price Includes VAT';
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specify the value for Price Includes VAT field. Determines if the amount on the selected price rule must compensate for VAT differences.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;
                }
                field(UnitPriceVatPercentage; _UnitPriceVatPercentage)
                {
                    Caption = 'VAT Percentage';
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    ToolTip = 'Specify the value for VAT Percentage field.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;
                }

            }

            repeater(GroupName)
            {
                Editable = false;
                field("Period Start"; Rec."Period Start")
                {
                    Caption = 'Event Date';
                    ToolTip = 'Specifies the value of the Event Date field';
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                }
                field("Period No."; Rec."Period No.")
                {
                    Caption = 'Weekday Number';
                    ToolTip = 'Specifies the value of the Period No. field.';
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                }
                field(RuleLineNo; _RuleLineNo)
                {
                    Caption = 'Rule Line No.';
                    ToolTip = 'Specifies the value of the Rule Line No. field.';
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                }
                field(SuggestedAmount; _SuggestedAmount)
                {
                    Caption = 'Suggested Amount';
                    ToolTip = 'Specifies the value of the Suggested Amount field.';
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CheckButtonPrice)
            {
                Caption = 'Check Button Price';
                ToolTip = 'Click to calculate the price that should be shown on the POS button when evaluating the #CURRPRICE# button caption placeholder.';
                Image = Price;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Visible = _ItemNo <> '';
                ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                trigger OnAction()
                var
                    TicketTimeHelper: Codeunit "NPR TM TimeHelper";
                begin
                    if (_LocalAdmissionTime = 0T) then
                        _LocalAdmissionTime := DT2Time(TicketTimeHelper.GetLocalTimeAtAdmission(_AdmissionCode));
                    CalculateButtonPrice();
                    Message('The price on the POS button should be %1, and the next update time should be %2 (UTC: %3)', _ButtonPriceCaption, _NextUpdateTime, _ButtonPriceNextUpdateTimeText);
                end;
            }
        }
    }

    var
        _ProfileCode: Code[10];
        _ItemNo: Code[20];
        _VariantCode: Code[10];
        _AdmissionCode: Code[20];
        _BookingDate: Date;
        _RuleLineNo: Integer;
        _SuggestedAmount: Text;
        _UnitPriceIncludesVAT: Boolean;
        _UnitPriceVatPercentage: Decimal;
        _ErpUnitPrice: Decimal;
        _ErpDiscountPct: Decimal;
        TempAdmScheduleEntryResponseOut: Record "NPR TM Admis. Schedule Entry" temporary;

        _LocalAdmissionTime: Time;
        _ButtonPriceCaption: Text;
        _ButtonPriceNextUpdateTimeText: Text;
        _NextUpdateTime: DateTime;
        _CustomerNo: Code[20];

    trigger OnInit()
    begin
        _BookingDate := Today();
        _ErpUnitPrice := 100;
        Rec.SetFilter("Period Type", '%1', Rec."Period Type"::Date);
        Rec.SetFilter("Period Start", '%1..', _BookingDate);
    end;

    trigger OnOpenPage()
    var
        Item: Record Item;
        TicketDynamicPrice: Codeunit "NPR TM Dynamic Price";
    begin
        if (Item.Get(_ItemNo)) then
            TicketDynamicPrice.CalculateErpUnitPrice(_ItemNo, _VariantCode, _CustomerNo, _BookingDate, 1, _ErpUnitPrice, _ErpDiscountPct, _UnitPriceIncludesVAT, _UnitPriceVatPercentage);
    end;

    trigger OnAfterGetRecord()
    var
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        TicketTimeHelper: Codeunit "NPR TM TimeHelper";
        PriceRule: Record "NPR TM Dynamic Price Rule";
        BasePrice, AddonPrice, Total : Decimal;
    begin

        if (_LocalAdmissionTime = 0T) then
            _LocalAdmissionTime := DT2Time(TicketTimeHelper.GetLocalTimeAtAdmission(_AdmissionCode));

        TempAdmScheduleEntryResponseOut."Admission Start Date" := Rec."Period Start";
        TempAdmScheduleEntryResponseOut."Admission End Date" := Rec."Period Start";
        TempAdmScheduleEntryResponseOut."Dynamic Price Profile Code" := _ProfileCode;
        TempAdmScheduleEntryResponseOut."Admission Code" := _AdmissionCode;

        _SuggestedAmount := StrSubstNo('%1 [-.-- / -.--]', _ErpUnitPrice);
        _RuleLineNo := 0;
        if (TicketPrice.SelectPriceRule(TempAdmScheduleEntryResponseOut, _ItemNo, _VariantCode, _BookingDate, _LocalAdmissionTime, PriceRule)) then begin
            TicketPrice.EvaluatePriceRule(PriceRule, _ErpUnitPrice, _UnitPriceIncludesVAT, _UnitPriceVatPercentage, true, BasePrice, AddonPrice);
            Total := _ErpUnitPrice + AddonPrice;
            if (BasePrice <> 0) then
                Total := BasePrice + AddonPrice;
            _SuggestedAmount := StrSubstNo('%1 [%2 / %3]', Total, BasePrice, AddonPrice);
            _RuleLineNo := PriceRule.LineNo;

        end;
    end;

    internal procedure Initialize(PriceProfileCode: Code[10])
    begin
        _ProfileCode := PriceProfileCode;
    end;

    internal procedure Initialize(PriceProfileCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]; AdmissionCode: Code[20])
    begin
        _ProfileCode := PriceProfileCode;
        _ItemNo := ItemNo;
        _VariantCode := VariantCode;
        _AdmissionCode := AdmissionCode;
    end;


    local procedure CalculateButtonPrice()
    var
        TicketDynamicPrice: Codeunit "NPR TM Dynamic Price";
        TicketManagement: Codeunit "NPR TM Ticket Management";

        Item: Record Item;
        ItemReference: Record "Item Reference";

        ReferenceDate: Date;
        ReferenceTime: Time;
        Quantity: Integer;

        ErpUnitPrice: Decimal;
        ErpDiscountPct: Decimal;
        ErpUnitPriceIncludesVat: Boolean;
        ErpUnitPriceVatPercentage: Decimal;

        TicketPrice: Decimal;

        ItemPrice: Decimal;
        Currency: Record Currency;
        ItemProcessingEvents: Codeunit "NPR POS Act. Insert Item Event";
    begin
        Item.Get(_ItemNo);
        ItemReference.SetFilter("Item No.", _ItemNo);
        ItemReference.SetFilter("Variant Code", _VariantCode);
        if (not ItemReference.FindFirst()) then;

        ReferenceDate := _BookingDate;
        ReferenceTime := _LocalAdmissionTime;
        Quantity := 1;

        if (Item."NPR Ticket Type" <> '') then begin
            TicketPrice := TicketDynamicPrice.CalculatePrice(Item."No.", _VariantCode, _CustomerNo, ReferenceDate, ReferenceTime, Quantity, ErpUnitPrice, ErpDiscountPct, ErpUnitPriceIncludesVat, ErpUnitPriceVatPercentage);
            if (TicketPrice = 0) then
                TicketPrice := ErpUnitPrice;

            if (TicketPrice <> 0) then
                ItemPrice := TicketPrice * Quantity;
        end;

        Currency.InitRoundingPrecision();
        // calculate and push past midnight of local today in UTC; handles timezone offset and DST (ie 00:00:00Z tomorrow) 
        _NextUpdateTime := CurrentDateTime() + (CreateDateTime(CalcDate('<+1D>'), 000000T) - (CreateDateTime(Today(), Time())));

        // Ticket - find the next schedule
        if (Item."NPR Ticket Type" <> '') then
            TicketManagement.GetNextPossibleAdmissionScheduleStartDateTime(Item."No.", ItemReference."Variant Code", _NextUpdateTime);

        ItemProcessingEvents.OnSetNextCaptionUpdateTime(Item, ItemReference, _NextUpdateTime);

        _ButtonPriceCaption := Format(Round(ItemPrice, Currency."Amount Rounding Precision"));
        _ButtonPriceNextUpdateTimeText := Format(_NextUpdateTime, 0, 9);
    end;
}