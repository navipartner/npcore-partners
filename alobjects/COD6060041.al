codeunit 6060041 "Item Worksheet Item Management"
{
    // NPR4.18\BR\20160209  CASE 182391 Object Created
    // NPR5.29\BR\20161215  CASE 261123 Added support for only matching by item No.


    trigger OnRun()
    begin
    end;

    var
        ItemNumberManagement: Codeunit "Item Number Management";

    procedure MatchItemNo(var ItemWorksheetLine: Record "Item Worksheet Line")
    var
        ItemNo: Code[20];
        VendorNo: Code[20];
        CodeVar: Code[30];
        ItemWorksheetTemplate: Record "Item Worksheet Template";
    begin
        if ItemWorksheetLine."Existing Item No." <> '' then
          exit;
        //-NPR5.29 [261123]
        ItemWorksheetTemplate.Get(ItemWorksheetLine."Worksheet Template Name");
        if ItemWorksheetTemplate."Match by Item No. Only" then
          exit;
        //+NPR5.29 [261123]
        ItemNo := '';
        VendorNo := ItemWorksheetLine."Vendor No.";
        if not ItemNumberManagement.FindItemInfo(ItemWorksheetLine."Vendor Item No.",1,true,CodeVar,VendorNo,ItemNo,CodeVar) then         // Unblocked items Vendor Item No.
          if not ItemNumberManagement.FindItemInfo(ItemWorksheetLine."Internal Bar Code",2,true,CodeVar,VendorNo,ItemNo,CodeVar) then                 // Unblocked items Barcode
            if not ItemNumberManagement.FindItemInfo(ItemWorksheetLine."Vendors Bar Code",1,true,CodeVar,VendorNo,ItemNo,CodeVar) then         // Unblocked items Vendor Barcode
              if not ItemNumberManagement.FindItemInfo(ItemWorksheetLine."Vendors Bar Code",2,true,CodeVar,VendorNo,ItemNo,CodeVar) then                 // Unblocked items Vendor Barcode
                if not ItemNumberManagement.FindItemInfo(ItemWorksheetLine."Vendor Item No.",1,false,CodeVar,VendorNo,ItemNo,CodeVar) then    // All items Vendor Item No.
                  if not ItemNumberManagement.FindItemInfo(ItemWorksheetLine."Internal Bar Code",2,false,CodeVar,VendorNo,ItemNo,CodeVar) then            // All itmes Barcode
                    if not ItemNumberManagement.FindItemInfo(ItemWorksheetLine."Vendor Item No.",0,false,CodeVar,VendorNo,ItemNo,CodeVar) then// All places vendor item no.
                      if not ItemNumberManagement.FindItemInfo(ItemWorksheetLine."Internal Bar Code",0,false,CodeVar,VendorNo,ItemNo,CodeVar) then        // All places Barcode
                        exit;
        if VendorNo <> '' then begin
          ItemWorksheetLine.Validate("Vendor No.",VendorNo);
        end;
        if ItemNo <> '' then begin
          ItemWorksheetLine.Validate("Existing Item No.",ItemNo);
        end;
    end;

    local procedure GetItemNo(VendorsBarCode: Code[20];VendorsItemNo: Code[20];OurBarCode: Code[20];OurItemNo: Code[20])
    begin
    end;

    procedure GetVariantCode(OurItemNo: Code[20];Var1Value: Code[20];Var2Value: Code[20];Var3Value: Code[20];Var4Value: Code[20]) Variant: Code[20]
    begin
    end;

    local procedure GetFromVendorItemNo(VendorNo: Code[20];VendorItemNo: Code[20])
    begin
    end;

    procedure UpdateItemNo(var ItemWorksheetLine: Record "Item Worksheet Line")
    var
        ItemNo: Code[20];
        VarCode: Code[10];
    begin
        with ItemWorksheetLine do begin
          if FindItemNo("Vendors Bar Code", "Internal Bar Code", "Vendor Item No.", "Vendor No.", ItemNo, VarCode) then begin
            Validate("Item No.", ItemNo);
          end else begin
            Validate("Item No.", '');
          end;
        end;
    end;

    local procedure FindItemNo(ItemCrossRefNo: Code[20];AltNo: Code[20];VendorsItemNo: Code[20];OurVendorNo: Code[20];var OurItemNo: Code[20];var OurVariantCode: Code[20]) found: Boolean
    var
        ItemCrossRef: Record "Item Cross Reference";
        AlternativeNo: Record "Alternative No.";
        Item: Record Item;
    begin
        //first item cross reference
        if ItemCrossRefNo <> '' then begin
          ItemCrossRef.SetRange("Cross-Reference Type", ItemCrossRef."Cross-Reference Type"::Vendor);
          if OurVendorNo <> '' then
            ItemCrossRef.SetRange("Cross-Reference Type No.", OurVendorNo);
          ItemCrossRef.SetRange("Cross-Reference No.", ItemCrossRefNo);
          if ItemCrossRef.FindFirst then begin
            OurItemNo := ItemCrossRef."Item No.";
            OurVariantCode := ItemCrossRef."Variant Code";
            exit(true);
          end;
        end;

        if AltNo <> '' then begin
          AlternativeNo.SetCurrentKey("Alt. No.", Type);
          AlternativeNo.SetRange("Alt. No.", AltNo);
          AlternativeNo.SetRange(Type, AlternativeNo.Type::Item);
          if AlternativeNo.FindFirst then begin
            OurItemNo := AlternativeNo.Code;
            OurVariantCode := AlternativeNo."Variant Code";
            exit(true);
          end;
        end;

        if VendorsItemNo <> '' then begin
          Item.SetRange("Vendor Item No.", VendorsItemNo);
          if OurVendorNo <> '' then
            Item.SetRange("Vendor No.", OurVendorNo);
          if Item.FindFirst then begin
            OurItemNo := Item."No.";
            OurVariantCode := '';
            exit(true);
          end;
        end;
    end;

    procedure CheckDuplicateLine(ItemWorksheetLine: Record "Item Worksheet Line")
    var
        ItemWorksheetLine2: Record "Item Worksheet Line";
        Text001: Label 'Item No %1 already exists in %2 %3';
        ItemWorksheet: Record "Item Worksheet";
    begin
        with ItemWorksheetLine do begin
          //only check inside current Worksheet
          ItemWorksheetLine2.SetRange("Worksheet Template Name", "Worksheet Template Name");
          ItemWorksheetLine2.SetRange("Worksheet Name", "Worksheet Name");
          ItemWorksheetLine2.SetFilter("Line No.", '<>%1', "Line No.");

          //duplicate Item No
          if "Item No." <> '' then begin
            ItemWorksheetLine2.SetRange("Item No.", "Item No.");
            if not ItemWorksheetLine2.IsEmpty then
              GenerateDuplicateError(ItemWorksheetLine,FieldCaption("Item No."), "Item No.", ItemWorksheet.TableCaption,"Worksheet Name");
            ItemWorksheetLine2.SetRange("Item No.");
          end;

          //Duplicate Vendor Item no
          if "Vendor Item No." <> '' then begin
            ItemWorksheetLine2.SetRange("Vendor Item No.", "Vendor Item No.");
            if not ItemWorksheetLine2.IsEmpty then
              GenerateDuplicateError(ItemWorksheetLine, FieldCaption("Vendor Item No."), "Vendor Item No.", ItemWorksheet.TableCaption, "Worksheet Name");
            ItemWorksheetLine2.SetRange("Vendor Item No.");
          end;

          //Duplicate Barcode
          if "Internal Bar Code" <> '' then begin
            ItemWorksheetLine2.SetRange("Internal Bar Code", "Internal Bar Code");
            if not ItemWorksheetLine2.IsEmpty then
              GenerateDuplicateError(ItemWorksheetLine,FieldCaption("Internal Bar Code"), "Internal Bar Code", ItemWorksheet.TableCaption, "Worksheet Name");
            ItemWorksheetLine2.SetRange("Internal Bar Code");
          end;

          //Duplicate vendor Barcode
          if "Vendors Bar Code" <> '' then begin
            ItemWorksheetLine2.SetRange("Vendors Bar Code", "Vendors Bar Code");
            if not ItemWorksheetLine2.IsEmpty then
              GenerateDuplicateError(ItemWorksheetLine, FieldCaption("Vendors Bar Code"), "Vendors Bar Code", ItemWorksheet.TableCaption, "Worksheet Name");
            ItemWorksheetLine2.SetRange("Vendors Bar Code");
          end;
        end;
    end;

    local procedure GenerateDuplicateError(ItemWorksheetLine: Record "Item Worksheet Line";ErrorText1: Text[50];ErrorText2: Text[50];ErrorText3: Text[50];ErrorText4: Text[50])
    var
        Text001: Label '%1 %2 already exists in %3 %4.';
        ItemWorksheetTemplate: Record "Item Worksheet Template";
        FullErrortext: Text[512];
    begin
        FullErrortext := StrSubstNo(Text001,ErrorText1,ErrorText2,ErrorText3,ErrorText4);
        ItemWorksheetTemplate.Get(ItemWorksheetLine."Worksheet Template Name");
        case ItemWorksheetTemplate."Error Handling" of
          ItemWorksheetTemplate."Error Handling"::StopOnFirst :
            Error(FullErrortext);
        end;
        with ItemWorksheetLine do begin
          Status := Status :: Error;
          "Status Comment" := CopyStr(FullErrortext,1,MaxStrLen("Status Comment"));
          Modify;
        end;
    end;

    procedure ItemVariantExists(ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        if Item.Get(ItemNo) then begin
          Item.CalcFields("Has Variants");
          exit(Item."Has Variants");
        end else
          exit(false);
    end;

    procedure ItemVarietyExists(ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        if Item.Get(ItemNo) then begin
          if (Item."Variety 1" <> '') or
             (Item."Variety 2" <> '') or
             (Item."Variety 3" <> '') or
             (Item."Variety 4" <> '') then
            exit(true);
        end else
          exit(false);
    end;
}

