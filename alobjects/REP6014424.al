report 6014424 "Ret. Jnl. - Import Items"
{
    // NPR5.26/MHA /20160810  CASE 248288 Field 6014409 Assortment deleted from ReqFilterFields
    // NPR5.39/MMV /20180212  CASE 303556 Removed manual barcode logic
    // NPR5.46/JDH /20180926 CASE 294354 Removed Import Filters. The field wasnt shown anywhere
    // NPR5.49/BHR /20190115  CASE 341969 Corrections as per OMA Guidelines

    Caption = 'Import Items';
    ProcessingOnly = true;

    dataset
    {
        dataitem(Item;Item)
        {
            RequestFilterFields = "No.","Vendor No.","Item Group","Group sale","Last Date Modified",Description,"Search Description";

            trigger OnAfterGetRecord()
            begin
                CalcFields("Has Variants");
                if ( Inventory <= 0 ) and OnlyInventory then
                  CurrReport.Skip;

                RetailJournalLine.Reset;
                RetailJournalLine.SetRange("No.", RetailJournalHeader."No.");
                if RetailJournalLine.FindLast then
                  LastLineNo := RetailJournalLine."Line No."
                else
                  LastLineNo := 0;

                if not Item."Has Variants" then begin
                  CalcFields(Inventory);
                  RetailJournalLine.Init();
                  RetailJournalLine.Validate("Line No.", LastLineNo + 10000);
                  RetailJournalLine.Validate("No.", RetailJournalHeader."No.");
                  RetailJournalLine.Validate("Item No.",Item."No.");
                  RetailJournalLine.Insert;
                  RetailJournalLine.Validate("Quantity to Print",1);
                  RetailJournalLine.Validate(Description,Item.Description);
                  RetailJournalLine.Validate("Vendor No.",Item."Vendor No.");
                  RetailJournalLine.Validate("Vendor Item No.",Item."Vendor Item No.");
                  RetailJournalLine.Validate("Discount Price Incl. Vat",Item."Unit Price");

                  case ImportUnitCost of
                    ImportUnitCost::"Standard Cost"    : RetailJournalLine.Validate("Last Direct Cost",Item."Standard Cost");
                    ImportUnitCost::"Unit Cost"        : RetailJournalLine.Validate("Last Direct Cost",Item."Unit Cost");
                    ImportUnitCost::"Last direct cost" : RetailJournalLine.Validate("Last Direct Cost",Item."Last Direct Cost");
                  end;

                //-NPR5.39 [303556]
                //  RetailJournalLine.VALIDATE(Barcode,Item."Label Barcode");
                //+NPR5.39 [303556]
                  RetailJournalLine.Modify;
                end else begin
                  //-NPR5.23 [240916]
                //  VariaXVariantInfo.SETRANGE("Item No.",Item."No.");
                //  IF VariaXVariantInfo.FIND('-') THEN REPEAT
                //    RetailJournalLine.INIT();
                //    RetailJournalLine.VALIDATE("Line No.", LastLineNo + 10000);
                //    LastLineNo += 10000;
                //    RetailJournalLine.VALIDATE("No.", RetailJournalHeader."No.");
                //    RetailJournalLine.VALIDATE("Item No.",Item."No.");
                //    RetailJournalLine.VALIDATE("Variant Code",VariaXVariantInfo."Variant Code");
                //    RetailJournalLine.INSERT;
                //    Item.SETFILTER("Variant Filter",'=%1',VariaXVariantInfo."Variant Code");
                //    CALCFIELDS(Item.Inventory);
                //
                //    IF UseStock THEN
                //       RetailJournalLine.VALIDATE(Quantity,Item.Inventory)
                //    ELSE
                //       RetailJournalLine.VALIDATE(Quantity,1);
                //
                //    RetailJournalLine.VALIDATE(Description,Item.Description);
                //    RetailJournalLine.VALIDATE("Vendor No.",Item."Vendor No.");
                //    RetailJournalLine.VALIDATE("Vendor Item No.",Item."Vendor Item No.");
                //    RetailJournalLine.VALIDATE("Unit price",Item."Unit Price");
                //    RetailJournalLine.VALIDATE(RetailJournalLine.Inventory,Item.Inventory);
                //
                //    CASE ImportUnitCost OF
                //      ImportUnitCost::"Standard Cost"    : RetailJournalLine.VALIDATE("Unit cost",Item."Standard Cost");
                //      ImportUnitCost::"Unit Cost"        : RetailJournalLine.VALIDATE("Unit cost",Item."Unit Cost");
                //      ImportUnitCost::"Last direct cost" : RetailJournalLine.VALIDATE("Unit cost",Item."Last Direct Cost");
                //    END;
                //    AlternativeNo.RESET;
                //    AlternativeNo.SETRANGE(Type,AlternativeNo.Type::Item);
                //    AlternativeNo.SETRANGE(AlternativeNo.Code,Item."No.");
                //    AlternativeNo.SETRANGE("Variant Code",VariaXVariantInfo."Variant Code");
                //    IF AlternativeNo.FIND('-') THEN
                //      RetailJournalLine.VALIDATE(Barcode,AlternativeNo."Alt. No.")
                //    ELSE
                //      RetailJournalLine.VALIDATE(Barcode,Item."Label Barcode");
                //    RetailJournalLine.MODIFY;
                //    SETFILTER(Item."Variant Filter",'');
                //  UNTIL VariaXVariantInfo.NEXT = 0;
                  //+NPR5.23 [240916]

                end;
            end;

            trigger OnPreDataItem()
            begin
                //-NPR5.46 [294354]
                //RetailJournalHeader."Import filter" := Item.GETFILTERS;
                //RetailJournalHeader.MODIFY;
                //+NPR5.46 [294354]
            end;
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
        RetailJournalHeader: Record "Retail Journal Header";
        RetailJournalLine: Record "Retail Journal Line";
        OnlyInventory: Boolean;
        RetailJournalCode: Code[20];
        ImportUnitCost: Option "Standard Cost","Unit Cost","Last direct cost";
        LastLineNo: Integer;

    procedure SetJournal(RetailJournalCodeIn: Code[20])
    begin
        RetailJournalCode := RetailJournalCodeIn;
        RetailJournalHeader.Get(RetailJournalCode);
    end;
}

