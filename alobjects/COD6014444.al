codeunit 6014444 "NPR Event Subscriber (Purch)"
{
    // --Table 39 Purchase Line--
    // NPR4.14/RMT/20150730 CASE 219456 Added code to resolve item information from "Vendor Item No."
    // NPR4.15/JDH/20150929 CASE 223643 only validate vendors item no, if its actually entered from that field
    // NPR5.22/TJ/20160406 CASE 236840 New subscriber added for Variant Code field
    // NPR5.00.01/TJ/20160517 CASE 241673 Rearranged code and added new events
    // NPR5.29/NPKNAV/20170127  CASE 260472 Transport NPR5.29 - 27 januar 2017
    // NPR5.32/BR /20170503  CASE 274473 Hook into Item worksheet


    trigger OnRun()
    begin
    end;

    var
        RetailSetup: Record "Retail Setup";
        RetailSetupFetched: Boolean;

    [EventSubscriber(ObjectType::Table, 39, 'OnBeforeValidateEvent', 'Vendor Item No.', true, false)]
    local procedure OnBeforeValidateEventVendorItemNo(var Rec: Record "Purchase Line";var xRec: Record "Purchase Line";CurrFieldNo: Integer)
    var
        Item: Record Item;
        PurchLine: Record "Purchase Line";
        PurchHeader: Record "Purchase Header";
        Text001: Label 'Vendor Item No. %1 was not created on vendor.';
        ItemWorksheetPurchIntegr: Codeunit "Item Worksheet Purch. Integr.";
        CreatedItemNo: Code[20];
        CreatedVariantCode: Code[10];
    begin
        //-NPR5.22.01
        /*
        //-NPR4.15
        IF CurrFieldNo = Rec.FIELDNO("Vendor Item No.") THEN
        //+NPR4.15
          //-NPR4.14
          RetailCode.KLLevVNOV(Rec);
          //+NPR4.14
        */
        //-NPR4.15
        if CurrFieldNo = Rec.FieldNo("Vendor Item No.") then begin
        //+NPR4.15
          GetRetailSetup;
          with Rec do begin
            PurchHeader.Get("Document Type","Document No.");
            Item.SetCurrentKey("Vendor No.","Vendor Item No.");
            if RetailSetup."Check Purchase Lines if vendor" then
               Item.SetFilter("Vendor No.",PurchHeader."Buy-from Vendor No.");
            if "Vendor Item No." <> '' then begin
              Item.SetFilter("Vendor Item No.","Vendor Item No.");
              if Item.FindFirst then begin
                //-NPR4.14
                //Type := Type::Item;
                //+NPR4.14
                if "No." <> Item."No." then begin
                  PurchLine := Rec;
                  PurchLine.Validate("No.",Item."No.");
                  PurchLine."Vendor Item No." := Item."Vendor Item No.";
                  Rec := PurchLine;
                end;
          //      IF "No." <> Vare."No." THEN
          //        VALIDATE("No.",Vare."No.");
                //-NPR4.14
          //      "Vendor Item No." := Vare."Vendor Item No.";
                //+NPR4.14
              end else
                //-NPR5.32 [274473]
                if ItemWorksheetPurchIntegr.CreateItemFromWorksheet(PurchHeader."Buy-from Vendor No.","Vendor Item No.",CreatedItemNo,CreatedVariantCode) then begin
                  PurchLine := Rec;
                  PurchLine.Validate("No.",CreatedItemNo);
                  PurchLine.Validate("Variant Code",CreatedVariantCode);
                  PurchLine."Vendor Item No." := "Vendor Item No.";
                  Rec := PurchLine;
                end else
                //+NPR5.32 [274473]
                  Error(Text001,"Vendor Item No.");
            end;
          end;
        end;
        //+NPR5.22.01

    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnBeforeValidateEvent', 'Vendor Item No.', false, false)]
    local procedure OnBeforeValidateEventVendorItemNo2(var Rec: Record "Purchase Line";var xRec: Record "Purchase Line";CurrFieldNo: Integer)
    var
        Item: Record Item;
        ItemVend: Record "Item Vendor";
    begin
        //ToCheck
        //-NPR5.22.01
        /*
        IF CurrFieldNo IN [Rec.FIELDNO("Cross-Reference No."),Rec.FIELDNO("No."),Rec.FIELDNO("Variant Code"),Rec.FIELDNO("Location Code")] THEN BEGIN
          Rec.TESTFIELD("No.");
          Item.GET(Rec."No.");
          ItemVend.INIT;
          ItemVend."Vendor No." := Rec."Buy-from Vendor No.";
          ItemVend."Variant Code" := Rec."Variant Code";
          Item.FindItemVend(ItemVend,Rec."Location Code");
          //-NPR4.14
          IF (ItemVend."Vendor Item No."='') AND (Item."Vendor Item No."<>'') THEN
            Rec."Vendor Item No." := Item."Vendor Item No.";
          //+NPR4.14
        END;
        */
        with Rec do begin
          if CurrFieldNo in [FieldNo("Cross-Reference No."),FieldNo("No."),FieldNo("Variant Code"),FieldNo("Location Code")] then begin
            TestField("No.");
            Item.Get("No.");
            ItemVend.Init;
            ItemVend."Vendor No." := "Buy-from Vendor No.";
            ItemVend."Variant Code" := "Variant Code";
            Item.FindItemVend(ItemVend,"Location Code");
            //-NPR4.14
            if (ItemVend."Vendor Item No."='') and (Item."Vendor Item No."<>'') then
              "Vendor Item No." := Item."Vendor Item No.";
            //+NPR4.14
          end;
        end;
        //+NPR5.22.01

    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnAfterValidateEvent', 'Gift Voucher', true, false)]
    local procedure OnAfterValidateEventGiftVoucher(var Rec: Record "Purchase Line";var xRec: Record "Purchase Line";CurrFieldNo: Integer)
    var
        GiftVoucher: Record "Gift Voucher";
        Text001: Label '%1 on %2 is %3. Do You want to update %4 on %5 with %3?';
    begin
        //-NPR5.22.01
        /*
        //-NPR-3.0
        StdTableCode.K�bsLinjeValidateGavekort(Rec);
        //+NPR-3.0
        */
        with Rec do begin
          if "Gift Voucher" <> '' then begin
            TestField(Type,Type::"G/L Account");
            "Credit Note" := '';
            GiftVoucher.Get("Gift Voucher");
            GiftVoucher.TestField(Status,GiftVoucher.Status::Open);
            if GiftVoucher.Amount <> "Amount Including VAT" then
              if Confirm(StrSubstNo(Text001,
                GiftVoucher.FieldCaption(Amount),GiftVoucher.TableCaption,
                GiftVoucher.Amount,FieldCaption("Amount Including VAT"),TableCaption)) then begin
                  "Direct Unit Cost" := GiftVoucher.Amount;
                  "Direct Unit Cost" := "Direct Unit Cost" / 1 + ("VAT %" / 100);
                  Validate("Direct Unit Cost",Round("Direct Unit Cost"));
              end;
          end;
        end;
        //+NPR5.22.01

    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnAfterValidateEvent', 'Credit Note', true, false)]
    local procedure OnAfterValidateEventCreditNote(var Rec: Record "Purchase Line";var xRec: Record "Purchase Line";CurrFieldNo: Integer)
    var
        CreditVoucher: Record "Credit Voucher";
        Text001: Label '%1 on %2 is %3. Do You want to update %4 on %5 with %3?';
    begin
        //-NPR5.22.01
        /*
        //-NPR-3.0
        StdTableCode.K�bsLinjeValidateTilgbevis(Rec)
        //+NPR-3.0
        */
        with Rec do begin
          if "Credit Note" <> '' then begin
            TestField(Type,Type::"G/L Account");
            "Gift Voucher" := '';
            CreditVoucher.Get("Credit Note");
            CreditVoucher.TestField(Status,CreditVoucher.Status::Open);
            if CreditVoucher.Amount <> "Amount Including VAT" then
              if Confirm(StrSubstNo(Text001,
                CreditVoucher.FieldCaption(Amount),CreditVoucher.TableCaption,
                CreditVoucher.Amount,FieldCaption("Amount Including VAT"),TableCaption)) then begin
                  "Direct Unit Cost" := CreditVoucher.Amount;
                  "Direct Unit Cost" := "Direct Unit Cost" / 1 + ("VAT %" / 100);
                  Validate("Direct Unit Cost",Round("Direct Unit Cost"));
              end;
          end;
        end;
        //+NPR5.22.01

    end;

    local procedure GetRetailSetup(): Boolean
    begin
        if RetailSetupFetched then
          exit(true);

        if not RetailSetup.Get then
          exit(false);
        RetailSetupFetched := true;
        exit(true);
    end;
}

