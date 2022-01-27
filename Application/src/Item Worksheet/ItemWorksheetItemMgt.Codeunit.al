codeunit 6060041 "NPR Item Worksheet Item Mgt."
{
    Access = Internal;
    var
        ItemNumberManagement: Codeunit "NPR Item Number Mgt.";

    procedure MatchItemNo(var ItemWorksheetLine: Record "NPR Item Worksheet Line")
    var
        ItemWorksheetTemplate: Record "NPR Item Worksh. Template";
        ItemNo: Code[20];
        VendorNo: Code[20];
        CodeVar: Code[10];
    begin
        if ItemWorksheetLine."Existing Item No." <> '' then
            exit;
        ItemWorksheetTemplate.Get(ItemWorksheetLine."Worksheet Template Name");
        if ItemWorksheetTemplate."Match by Item No. Only" then
            exit;
        ItemNo := '';
        VendorNo := ItemWorksheetLine."Vendor No.";
        if not ItemNumberManagement.FindItemInfo(ItemWorksheetLine."Vendor Item No.", 1, true, CodeVar, VendorNo, ItemNo, CodeVar) then         // Unblocked items Vendor Item No.
            if not ItemNumberManagement.FindItemInfo(ItemWorksheetLine."Internal Bar Code", 2, true, CodeVar, VendorNo, ItemNo, CodeVar) then                 // Unblocked items Barcode
                if not ItemNumberManagement.FindItemInfo(ItemWorksheetLine."Vendors Bar Code", 1, true, CodeVar, VendorNo, ItemNo, CodeVar) then         // Unblocked items Vendor Barcode
                    if not ItemNumberManagement.FindItemInfo(ItemWorksheetLine."Vendors Bar Code", 2, true, CodeVar, VendorNo, ItemNo, CodeVar) then                 // Unblocked items Vendor Barcode
                        if not ItemNumberManagement.FindItemInfo(ItemWorksheetLine."Vendor Item No.", 1, false, CodeVar, VendorNo, ItemNo, CodeVar) then    // All items Vendor Item No.
                            if not ItemNumberManagement.FindItemInfo(ItemWorksheetLine."Internal Bar Code", 2, false, CodeVar, VendorNo, ItemNo, CodeVar) then            // All itmes Barcode
                                if not ItemNumberManagement.FindItemInfo(ItemWorksheetLine."Vendor Item No.", 0, false, CodeVar, VendorNo, ItemNo, CodeVar) then// All places vendor item no.
                                    if not ItemNumberManagement.FindItemInfo(ItemWorksheetLine."Internal Bar Code", 0, false, CodeVar, VendorNo, ItemNo, CodeVar) then        // All places Barcode
                                        exit;
        if VendorNo <> '' then
            ItemWorksheetLine.Validate("Vendor No.", VendorNo);
        if ItemNo <> '' then
            ItemWorksheetLine.Validate("Existing Item No.", ItemNo);
    end;

    procedure GetVariantCode(OurItemNo: Code[20]; Var1Value: Code[20]; Var2Value: Code[20]; Var3Value: Code[20]; Var4Value: Code[20]) Variant: Code[20]
    begin
    end;

    procedure UpdateItemNo(var ItemWorksheetLine: Record "NPR Item Worksheet Line")
    var
        VarCode: Code[10];
        ItemNo: Code[20];
    begin
        if FindItemNo(
            ItemWorksheetLine."Vendors Bar Code",
            ItemWorksheetLine."Vendor Item No.", ItemWorksheetLine."Vendor No.", ItemNo, VarCode) then
            ItemWorksheetLine.Validate("Item No.", ItemNo)
        else
            ItemWorksheetLine.Validate("Item No.", '');
    end;

    local procedure FindItemNo(ItemRefNo: Code[50]; VendorsItemNo: Code[20]; OurVendorNo: Code[20]; var OurItemNo: Code[20]; var OurVariantCode: Code[10]): Boolean
    var
        ItemRef: Record "Item Reference";
        Item: Record Item;
    begin
        if ItemRefNo <> '' then begin
            ItemRef.SetRange("Reference Type", ItemRef."Reference Type"::Vendor);
            if OurVendorNo <> '' then
                ItemRef.SetRange("Reference Type No.", OurVendorNo);
            ItemRef.SetRange("Reference No.", ItemRefNo);
            if ItemRef.FindFirst() then begin
                OurItemNo := ItemRef."Item No.";
                OurVariantCode := ItemRef."Variant Code";
                exit(true);
            end;
        end;

        if VendorsItemNo <> '' then begin
            Item.SetRange("Vendor Item No.", VendorsItemNo);
            if OurVendorNo <> '' then
                Item.SetRange("Vendor No.", OurVendorNo);
            if Item.FindFirst() then begin
                OurItemNo := Item."No.";
                OurVariantCode := '';
                exit(true);
            end;
        end;
    end;

    procedure CheckDuplicateLine(ItemWorksheetLine: Record "NPR Item Worksheet Line")
    var
        ItemWorksheet: Record "NPR Item Worksheet";
        ItemWorksheetLine2: Record "NPR Item Worksheet Line";
    begin
        //only check inside current Worksheet
        ItemWorksheetLine2.SetRange("Worksheet Template Name", ItemWorksheetLine."Worksheet Template Name");
        ItemWorksheetLine2.SetRange("Worksheet Name", ItemWorksheetLine."Worksheet Name");
        ItemWorksheetLine2.SetFilter("Line No.", '<>%1', ItemWorksheetLine."Line No.");

        //duplicate Item No
        if ItemWorksheetLine."Item No." <> '' then begin
            ItemWorksheetLine2.SetRange("Item No.", ItemWorksheetLine."Item No.");
            if not ItemWorksheetLine2.IsEmpty() then
                GenerateDuplicateError(
                    ItemWorksheetLine, ItemWorksheetLine.FieldCaption("Item No."),
                    ItemWorksheetLine."Item No.", ItemWorksheet.TableCaption, ItemWorksheetLine."Worksheet Name");
            ItemWorksheetLine2.SetRange("Item No.");
        end;

        //Duplicate Vendor Item no
        if ItemWorksheetLine."Vendor Item No." <> '' then begin
            ItemWorksheetLine2.SetRange("Vendor Item No.", ItemWorksheetLine."Vendor Item No.");
            if not ItemWorksheetLine2.IsEmpty() then
                GenerateDuplicateError(
                    ItemWorksheetLine, ItemWorksheetLine.FieldCaption("Vendor Item No."),
                    ItemWorksheetLine."Vendor Item No.", ItemWorksheet.TableCaption, ItemWorksheetLine."Worksheet Name");
            ItemWorksheetLine2.SetRange("Vendor Item No.");
        end;

        //Duplicate Barcode
        if ItemWorksheetLine."Internal Bar Code" <> '' then begin
            ItemWorksheetLine2.SetRange("Internal Bar Code", ItemWorksheetLine."Internal Bar Code");
            if not ItemWorksheetLine2.IsEmpty() then
                GenerateDuplicateError(
                    ItemWorksheetLine, ItemWorksheetLine.FieldCaption("Internal Bar Code"),
                    ItemWorksheetLine."Internal Bar Code", ItemWorksheet.TableCaption, ItemWorksheetLine."Worksheet Name");
            ItemWorksheetLine2.SetRange("Internal Bar Code");
        end;

        //Duplicate vendor Barcode
        if ItemWorksheetLine."Vendors Bar Code" <> '' then begin
            ItemWorksheetLine2.SetRange("Vendors Bar Code", ItemWorksheetLine."Vendors Bar Code");
            if not ItemWorksheetLine2.IsEmpty() then
                GenerateDuplicateError(
                    ItemWorksheetLine, ItemWorksheetLine.FieldCaption("Vendors Bar Code"),
                    ItemWorksheetLine."Vendors Bar Code", ItemWorksheet.TableCaption, ItemWorksheetLine."Worksheet Name");
            ItemWorksheetLine2.SetRange("Vendors Bar Code");
        end;
    end;

    local procedure GenerateDuplicateError(ItemWorksheetLine: Record "NPR Item Worksheet Line"; ErrorText1: Text; ErrorText2: Text; ErrorText3: Text; ErrorText4: Text)
    var
        ItemWorksheetTemplate: Record "NPR Item Worksh. Template";
        AlreadyExistErr: Label '%1 %2 already exists in %3 %4.', Comment = '%1 = Error Text 1; %2 = Error Text 2; %3 = Error Text 3; %4 = Error Text 4';
        FullErrortext: Text;
    begin
        FullErrortext := StrSubstNo(AlreadyExistErr, ErrorText1, ErrorText2, ErrorText3, ErrorText4);
        ItemWorksheetTemplate.Get(ItemWorksheetLine."Worksheet Template Name");
        case ItemWorksheetTemplate."Error Handling" of
            ItemWorksheetTemplate."Error Handling"::StopOnFirst:
                Error(FullErrortext);
        end;
        ItemWorksheetLine.Status := ItemWorksheetLine.Status::Error;
        ItemWorksheetLine."Status Comment" := CopyStr(FullErrortext, 1, MaxStrLen(ItemWorksheetLine."Status Comment"));
        ItemWorksheetLine.Modify();
    end;

    procedure ItemVariantExists(ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        if Item.Get(ItemNo) then begin
            Item.CalcFields("NPR Has Variants");
            exit(Item."NPR Has Variants");
        end else
            exit(false);
    end;

    procedure ItemVarietyExists(ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        if Item.Get(ItemNo) then begin
            if (Item."NPR Variety 1" <> '') or
               (Item."NPR Variety 2" <> '') or
               (Item."NPR Variety 3" <> '') or
               (Item."NPR Variety 4" <> '') then
                exit(true);
        end else
            exit(false);
    end;
}

