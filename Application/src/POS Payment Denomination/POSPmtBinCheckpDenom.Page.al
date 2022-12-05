page 6060034 "NPR POS Pmt. Bin Checkp. Denom"
{
    Extensible = false;
    Caption = 'POS Pmt. Bin Checkp. Denominations';
    PageType = List;
    SourceTable = "NPR POS Pmt. Bin Checkp. Denom";
    UsageCategory = None;
    Editable = false;
    DataCaptionFields = "Attached-to ID";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Denomination Type"; Rec."Denomination Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the type of currency unit (whether it is a coin, or a banknote).';
                }
                field("Denomination Variant ID"; Rec."Denomination Variant ID")
                {
                    ToolTip = 'Specifies the variant of denomination set. May be used if there are multiple denomination sets circulating at the same time after, for example, a money reform.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field(Denomination; Rec.Denomination)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the denomination of a currency unit of this type.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies number of currency units of selected denomination.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the total payment amount denominated in selected currency units.';
                }
            }
            group(Totals)
            {
                ShowCaption = false;
                fixed(TotalsLine)
                {
                    ShowCaption = false;
                    group(TotalUnits)
                    {
                        Caption = 'Total Quantity';
                        field(TotalNumberOfUnits; TotalNumberOfUnits)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the total number of currency units.';
                            AutoFormatType = 1;
                            Editable = false;
                        }
                    }
                    group(TotalAmount)
                    {
                        Caption = 'Total Amounnt';
                        field(TotalCurrencyAmount; TotalCurrencyAmount)
                        {
                            ShowCaption = false;
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the total payment amount.';
                            AutoFormatType = 1;
                            Editable = false;
                        }
                    }
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        UpdateBalance();
    end;

    local procedure UpdateBalance()
    var
        DenominationMgt: Codeunit "NPR Denomination Mgt.";
    begin
        DenominationMgt.CalculateTotals(Rec, TotalNumberOfUnits, TotalCurrencyAmount);
    end;

    var
        TotalCurrencyAmount: Decimal;
        TotalNumberOfUnits: Integer;
}
