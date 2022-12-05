page 6060033 "NPR Edit POS Pmt. Denomination"
{
    Extensible = false;
    Caption = 'Edit POS Payment Denominations';
    PageType = Worksheet;
    SourceTable = "NPR POS Pmt. Bin Checkp. Denom";
    UsageCategory = None;
    InsertAllowed = false;
    DataCaptionExpression = Format(Rec."Attached-to ID");

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
                    Editable = false;
                }
                field("Denomination Variant ID"; Rec."Denomination Variant ID")
                {
                    ToolTip = 'Specifies the variant of denomination set. May be used if there are multiple denomination sets circulating at the same time after, for example, a money reform.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    Visible = false;
                }
                field(Denomination; Rec.Denomination)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the denomination of a currency unit of this type.';
                    Editable = false;
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

    trigger OnAfterGetCurrRecord()
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
