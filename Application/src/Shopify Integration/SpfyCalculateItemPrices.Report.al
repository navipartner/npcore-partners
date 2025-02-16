#if not BC17
report 6014551 "NPR Spfy Calculate Item Prices"
{
    Extensible = False;
    Caption = 'Shopify Calculate Item Prices';
    ProcessingOnly = true;
    UsageCategory = None;

    dataset
    {
        dataitem("NPR Spfy Store"; "NPR Spfy Store")
        {
            RequestFilterFields = Code;

            trigger OnPreDataItem()
            begin
                CurrReport.Break();
            end;
        }
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.", "Variant Filter";

            trigger OnPreDataItem()
            begin
                CurrReport.Break();
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group("Options")
                {
                    Caption = 'Options';
                    field("Recalculate Item Prices as of Date"; ItemPricesCalculationDate)
                    {
                        Caption = 'Price Date';
                        ToolTip = 'Specifies the date from which the calculated item price will be effective.';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        var
                            WrongCalculationDateLbl: Label 'The price date must be greater than or equal to today’s date.';
                        begin
                            if (ItemPricesCalculationDate > 0D) and (ItemPricesCalculationDate < Today()) then
                                Error(WrongCalculationDateLbl);
                        end;
                    }
                }
            }
        }
    }

    trigger OnPostReport()
    var
        ItemPriceMgt: Codeunit "NPR Spfy Item Price Mgt.";
    begin
        ItemPriceMgt.CalculateItemPrices("NPR Spfy Store", Item, false, ItemPricesCalculationDate);
    end;

    var
        ItemPricesCalculationDate: Date;
}
#endif
