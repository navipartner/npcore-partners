report 6014482 "NPR Ret. Jnl. Imp. Mix Disc."
{
    Caption = 'Import Mixed Discounts';
    ProcessingOnly = true;
    dataset
    {
        dataitem(RetailJournalHeader; "NPR Retail Journal Header")
        {
            DataItemTableView = SORTING("No.");
            dataitem(MixedDiscount; "NPR Mixed Discount")
            {
                RequestFilterFields = "Code";
                dataitem(MixedDiscountLine; "NPR Mixed Discount Line")
                {
                    DataItemLink = Code = FIELD(Code);
                    DataItemTableView = SORTING(Code, "Disc. Grouping Type", "No.", "Variant Code");

                    trigger OnAfterGetRecord()
                    var
                        Item: Record Item;
                        RetailJournalLine: Record "NPR Retail Journal Line";
                    begin
                        Item.Get(MixedDiscountLine."No.");

                        RetailJournalLine.SetRange("No.", RetailJournalHeader."No.");
                        if RetailJournalLine.Find('+') then
                            RetailJournalLine.Validate("Line No.", RetailJournalLine."Line No." + 10000)
                        else
                            RetailJournalLine.Validate("Line No.", 1);

                        RetailJournalLine.Init();
                        RetailJournalLine.Validate("No.", RetailJournalHeader."No.");
                        RetailJournalLine.Validate("Item No.", Item."No.");
                        RetailJournalLine.Insert();
                        RetailJournalLine.Validate("Quantity to Print", 1);
                        RetailJournalLine.Validate(Description, Item.Description);
                        RetailJournalLine.Validate("Vendor No.", Item."Vendor No.");
                        RetailJournalLine.Validate("Vendor Item No.", Item."Vendor Item No.");
                        RetailJournalLine.Validate("Discount Price Incl. Vat", MixedDiscountLine."Unit price");
                        RetailJournalLine.Validate("Last Direct Cost", MixedDiscountLine."Unit cost");
                        RetailJournalLine.Validate("Mixed Discount", MixedDiscount.Code);
                        RetailJournalLine.Modify();
                    end;
                }
            }
        }
    }

}

