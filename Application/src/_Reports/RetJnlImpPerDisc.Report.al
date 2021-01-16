report 6014481 "NPR Ret. Jnl. Imp. Per. Disc."
{
    // NPR5.39/MMV /20180212  CASE 303556 Removed manual barcode logic

    UsageCategory = None;
    Caption = 'Import Periode Discounts';
    ProcessingOnly = true;

    dataset
    {
        dataitem(RetailJournalHeader; "NPR Retail Journal Header")
        {
            DataItemTableView = SORTING("No.");
            dataitem(PeriodDiscount; "NPR Period Discount")
            {
                RequestFilterFields = "Code", "Starting Date", "Ending Date", Status, "Global Dimension 1 Code", "Global Dimension 2 Code";
                dataitem(PeriodDiscountLine; "NPR Period Discount Line")
                {
                    DataItemLink = Code = FIELD(Code);
                    DataItemTableView = SORTING(Code, "Item No.");

                    trigger OnAfterGetRecord()
                    begin
                        Item.Get(PeriodDiscountLine."Item No.");

                        RetailJournalLine.SetRange("No.", RetailJournalHeader."No.");
                        if RetailJournalLine.Find('+') then
                            RetailJournalLine.Validate("Line No.", RetailJournalLine."Line No." + 10000)
                        else
                            RetailJournalLine.Validate("Line No.", 10000);

                        RetailJournalLine.Init;
                        RetailJournalLine.Validate("No.", RetailJournalHeader."No.");
                        RetailJournalLine.Validate("Item No.", Item."No.");
                        RetailJournalLine.Insert;
                        RetailJournalLine.Validate("Quantity to Print", 1);
                        RetailJournalLine.Validate(Description, Item.Description);
                        RetailJournalLine.Validate("Vendor No.", Item."Vendor No.");
                        RetailJournalLine.Validate("Vendor Item No.", Item."Vendor Item No.");
                        RetailJournalLine.Validate("Discount Price Incl. Vat", PeriodDiscountLine."Campaign Unit Price");
                        RetailJournalLine.Validate("Last Direct Cost", PeriodDiscountLine."Campaign Unit Cost");
                        //-NPR5.39 [303556]
                        //RetailJournalLine.VALIDATE(Barcode, Item."Label Barcode");
                        //+NPR5.39 [303556]
                        RetailJournalLine.Validate("Period Discount", PeriodDiscount.Code);
                        RetailJournalLine.Modify;
                    end;
                }
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        RetailJournalLine: Record "NPR Retail Journal Line";
        Item: Record Item;
}

