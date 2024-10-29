page 6059930 "NPR TM Price Adm. Sch. Sim."
{
    Extensible = False;
    Caption = 'Dynamic Price Profile Analyzer';
    UsageCategory = None;
    PageType = Worksheet;
    SourceTable = "NPR TM Admis. Schedule Entry";
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

                        Rec.SetFilter("Admission Start Date", '%1..', _BookingDate);
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
                field("Admission Code"; Rec."Admission Code")
                {
                    ToolTip = 'Specifies the value of the Admission Code field';
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                }
                field("Schedule Code"; Rec."Schedule Code")
                {
                    ToolTip = 'Specifies the value of the Schedule Code field';
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                }
                field("Dynamic Price Profile Code"; Rec."Dynamic Price Profile Code")
                {
                    ToolTip = 'Specifies the value of the Dynamic Price Profile Code field';
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                }
                field(RuleLineNo; _RuleLineNo)
                {
                    Caption = 'Rule Line No.';
                    ToolTip = 'Specifies the value of the Rule Line No. field.';
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                }
                field("Admission Start Date"; Rec."Admission Start Date")
                {
                    Caption = 'Admission Start Date';
                    ToolTip = 'Specifies the value of the Admission Start Date field';
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                }
                field("Admission Start Time"; Rec."Admission Start Time")
                {
                    Caption = 'Admission Start Time';
                    ToolTip = 'Specifies the value of the Admission Start Time field.';
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                }
                field(UnitPrice; _UnitPrice)
                {
                    Caption = 'Unit Price';
                    ToolTip = 'Specifies the value of the admission unit price.';
                    ApplicationArea = NPRTicketDynamicPrice, NPRTicketAdvanced;
                }
            }
        }
    }

    var
        _BookingDate: Date;
        _RuleLineNo: Integer;
        _UnitPrice: Text;
        _UnitPriceIncludesVAT: Boolean;
        _UnitPriceVatPercentage: Decimal;
        _OriginalUnitPrice: Decimal;

    trigger OnInit()
    begin
        _BookingDate := Today();
        _OriginalUnitPrice := 100;
    end;

    trigger OnAfterGetRecord()
    var
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        PriceRule: Record "NPR TM Dynamic Price Rule";
        BasePrice, AddonPrice, Total : Decimal;
    begin

        _UnitPrice := StrSubstNo('%1 [-.-- / -.--]', _OriginalUnitPrice);
        _RuleLineNo := 0;
        if (TicketPrice.SelectPriceRule(Rec, '', '', _BookingDate, 0T, PriceRule)) then begin
            TicketPrice.EvaluatePriceRule(PriceRule, _OriginalUnitPrice, _UnitPriceIncludesVAT, _UnitPriceVatPercentage, true, BasePrice, AddonPrice);
            Total := _OriginalUnitPrice + AddonPrice;
            if (BasePrice <> 0) then
                Total := BasePrice + AddonPrice;
            _UnitPrice := StrSubstNo('%1 [%2 / %3]', Total, BasePrice, AddonPrice);
            _RuleLineNo := PriceRule.LineNo;

        end;
    end;
}