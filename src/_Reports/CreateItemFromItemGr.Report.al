report 6014610 "NPR Create Item From ItemGr."
{
    // NPR70.00.00.00/LS/20141218  CASE 201562  : Create report to create items from Item Group

    Caption = 'Create Item(s) From Item Group';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Item Group"; "NPR Item Group")
        {
            DataItemTableView = SORTING("No.") WHERE("Main Item Group" = FILTER(false));
            RequestFilterFields = "No.";

            trigger OnAfterGetRecord()
            begin
                //-NPR70.00.00.00
                if not Item.Get("No.") then begin
                    Item.Reset;
                    Item.Init;
                    Item."No." := "No.";
                    Item.Insert(true);
                    Item."NPR Item Group" := "No.";
                    StdTableCode.VareTVGOVAfter(Item, "Item Group");
                    Item."Costing Method" := Item."Costing Method"::FIFO;
                    Item.Validate("NPR Group sale", true);
                    Item.Validate("Price Includes VAT", true);
                    Item.Validate("Price/Profit Calculation", Item."Price/Profit Calculation"::"No Relationship");
                    if (ProfitPct <> 0) then
                        Item.Validate("Profit %", ProfitPct);
                    Item.Validate(Description, Description);
                    Item.Modify;

                    Counter += 1;
                end;
                //+NPR70.00.00.00
            end;

            trigger OnPostDataItem()
            begin
                Message(Text001, Counter);
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
                    ApplicationArea=All;
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        ProfitPct: Decimal;
        Item: Record Item;
        Counter: Integer;
        Text001: Label '%1 Item(s) has been created.';
        StdTableCode: Codeunit "NPR Std. Table Code";
}

