report 6014610 "NPR Create Item From ItemGr."
{
    Caption = 'Create Item(s) From Item Category';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    dataset
    {
        dataitem("Item Category"; "Item Category")
        {
            DataItemTableView = SORTING(Code) WHERE("NPR Main Category" = FILTER(false));
            RequestFilterFields = Code;

            trigger OnAfterGetRecord()
            var
                ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
            begin
                if not Item.Get(Code) then begin
                    Item.Reset();
                    Item.Init();
                    Item."No." := Code;
                    Item.Insert(true);
                    Item."Item Category Code" := Code;
                    ItemCategoryMgt.SetupItemFromCategory(Item, "Item Category");
                    Item."Costing Method" := Item."Costing Method"::FIFO;
                    Item.Validate("NPR Group sale", true);
                    Item.Validate("Price Includes VAT", true);
                    Item.Validate("Price/Profit Calculation", Item."Price/Profit Calculation"::"No Relationship");
                    if (ProfitPct <> 0) then
                        Item.Validate("Profit %", ProfitPct);
                    Item.Validate(Description, Description);
                    Item.Modify();

                    Counter += 1;
                end;
            end;

            trigger OnPostDataItem()
            begin
                Message(ItemsCreatedMsg, Counter);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(ProfitPct; ProfitPct)
                {
                    Caption = 'Standard Profit % On The Item Groups';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Standard Profit % On The Item Groups field';
                }
            }
        }

    }


    var
        Item: Record Item;
        ProfitPct: Decimal;
        Counter: Integer;
        ItemsCreatedMsg: Label '%1 Item(s) has been created.', Comment = '%1 = Number of Items';
}

