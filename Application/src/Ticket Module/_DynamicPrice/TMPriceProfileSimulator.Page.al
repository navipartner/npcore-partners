page 6059867 "NPR TM Price Profile Simulator"
{
    Extensible = False;
    Caption = 'Dynamic Price Profile Analyzer';
    PageType = Worksheet;
    UsageCategory = None;
    SourceTable = Date;
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/intro/';

    layout
    {
        area(Content)
        {

            group(g1)
            {
                field(BookingDate; _BookingDate)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    Caption = 'Booking Date';
                    ToolTip = 'Specify the event date for which you want to analyze admission price.';
                    trigger OnValidate()
                    begin
                        if (_BookingDate = 0D) then
                            _BookingDate := Today();

                        Rec.SetFilter("Period Start", '%1..', _BookingDate);
                        Rec.FindFirst();
                        CurrPage.Update(false);
                    end;
                }
                field(OriginalUnitPrice; _OriginalUnitPrice)
                {
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                    Caption = 'Unit Price';
                    ToolTip = 'Specify the value for Unit Price field. In the simulation, this will be the original (ERP) price.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update(false);
                    end;
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

    var
        _ProfileCode: Code[10];
        _BookingDate: Date;
        _RuleLineNo: Integer;
        _SuggestedAmount: Text;
        _UnitPriceIncludesVAT: Boolean;
        _UnitPriceVatPercentage: Decimal;
        _OriginalUnitPrice: Decimal;
        TempAdmScheduleEntryResponseOut: Record "NPR TM Admis. Schedule Entry" temporary;

    trigger OnInit()
    begin
        _BookingDate := Today();
        _OriginalUnitPrice := 100;
        Rec.SetFilter("Period Type", '%1', Rec."Period Type"::Date);
        Rec.SetFilter("Period Start", '%1..', _BookingDate);
    end;

    trigger OnAfterGetRecord()
    var
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        PriceRule: Record "NPR TM Dynamic Price Rule";
        BasePrice, AddonPrice, Total : Decimal;
    begin

        TempAdmScheduleEntryResponseOut."Admission Start Date" := Rec."Period Start";
        TempAdmScheduleEntryResponseOut."Admission End Date" := Rec."Period Start";
        TempAdmScheduleEntryResponseOut."Dynamic Price Profile Code" := _ProfileCode;

        _SuggestedAmount := StrSubstNo('%1 [-.-- / -.--]', _OriginalUnitPrice);
        _RuleLineNo := 0;
        if (TicketPrice.SelectPriceRule(TempAdmScheduleEntryResponseOut, _BookingDate, 0T, PriceRule)) then begin
            TicketPrice.EvaluatePriceRule(PriceRule, _OriginalUnitPrice, _UnitPriceIncludesVAT, _UnitPriceVatPercentage, true, BasePrice, AddonPrice);
            Total := _OriginalUnitPrice + AddonPrice;
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
}