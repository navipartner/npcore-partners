report 6014482 "Ret. Jnl. - Imp. Mix Disc."
{
    // NPR5.31/MHA /20170110  CASE 262904 Primary key updated for Mixed Discount Line
    // NPR5.39/MMV /20180212  CASE 303556 Removed manual barcode logic

    Caption = 'Import Mixed Discounts';
    ProcessingOnly = true;

    dataset
    {
        dataitem(RetailJournalHeader;"Retail Journal Header")
        {
            DataItemTableView = SORTING("No.");
            dataitem(MixedDiscount;"Mixed Discount")
            {
                RequestFilterFields = "Code";
                dataitem(MixedDiscountLine;"Mixed Discount Line")
                {
                    DataItemLink = Code=FIELD(Code);
                    DataItemTableView = SORTING(Code,"Disc. Grouping Type","No.","Variant Code");

                    trigger OnAfterGetRecord()
                    var
                        RetailJournalLine: Record "Retail Journal Line";
                        Item: Record Item;
                    begin

                        Item.Get(MixedDiscountLine."No.");

                        RetailJournalLine.SetRange("No.",RetailJournalHeader."No.");
                        if RetailJournalLine.Find('+') then
                          RetailJournalLine.Validate("Line No.", RetailJournalLine."Line No." + 10000)
                        else RetailJournalLine.Validate("Line No.",1);

                        RetailJournalLine.Init();
                        RetailJournalLine.Validate("No.", RetailJournalHeader."No.");
                        RetailJournalLine.Validate("Item No.",Item."No.");
                        RetailJournalLine.Insert;
                        RetailJournalLine.Validate("Quantity to Print",1);
                        RetailJournalLine.Validate(Description, Item.Description);
                        RetailJournalLine.Validate("Vendor No.",Item."Vendor No.");
                        RetailJournalLine.Validate("Vendor Item No.",Item."Vendor Item No.");
                        RetailJournalLine.Validate("Discount Price Incl. Vat", MixedDiscountLine."Unit price");
                        RetailJournalLine.Validate("Last Direct Cost", MixedDiscountLine."Unit cost");
                        //-NPR5.39 [303556]
                        //RetailJournalLine.VALIDATE(Barcode,Item."Label Barcode");
                        //+NPR5.39 [303556]
                        RetailJournalLine.Validate("Mixed Discount", MixedDiscount.Code);
                        RetailJournalLine.Modify();
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
}

