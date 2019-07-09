codeunit 6014528 "Barcode Library"
{
    // Barcode Handling.
    // (Partially) By Thea Rasmussen.
    // 
    // "GenerateBarcode(BarCode : Code[20],VAR TempBlob : Record TempBlob)"
    //   Creates an image file containing the barcode.
    // 
    // "Init(BarCode : Code[20])"
    //   Initiates all the values. If none are set by the properties then default values are set.
    // 
    // "SetBarcodeType(BarcodeTypeTextIn : Code[10])"
    //   Code options for BarcodeType:'EAN13','CODE39','QR'.
    // 
    // NC1.17/MH/20150616  CASE 215910 Save using MemoryStream instead of file
    // NPR4.13/MMV/20150708 CASE 214173 Added method from status module here as it can be used in many different places and changed order of table check (so Cross-reference is last)
    // NPR5.23/TS/20160602 CASE 242315  Added Events Function for CrossReference Field in Transfer Line Table
    // NPR5.23/MMV /20160610 CASE 242522 Added GetItemVariantBarcode()
    //                                   Added AllowDiscontinued parameter to TranslateBarcodeToItemVariant() & reversed order of lookup to use item cross ref first
    //                                   since this is the main solution going forward.
    //                                   Added seperators to function list.
    // NPR5.27/MMV /20151207 CASE 226605 Added QR barcode case
    //                                   Added functions SetAntiAliasing(), SetShowText() with defaults TRUE if not defined.
    // NPR5.26/BHR/20160712 CASE 246594 Added cross reference for Mixed discount and Period Discount
    //                                     Corrected transfer order
    // NPR5.27/MMV /20161011 CASE 254486 Re-added support for T 27 field "Label Barcode".
    // NPR5.29/MMV /20161214 CASE 259398 Added support for Vendor Item No. in TranslateBarcodeToItemVariant().
    //                                   Added validation on values for ICR lookup just like Alt No. has.
    // NPR5.29/MMV /20170117 CASE 245881 Added support for code128
    // NPR5.34/BR  /20170706 CASE 283366 Changed resolving sequence so Item No. can be used as a Label Barcode on the Item Page
    // NPR5.38/THRO/20180112 CASE 293194 Moved User input dialog to TryFunction to avoid error when in write transaction
    // NPR5.48/RA  /20181219 CASE 337355 Changed FunctionVisibility of funtion GenerateBarcode to External


    trigger OnRun()
    begin
    end;

    var
        BarCodeType: DotNet npNetBarCodeType;
        BarCodeSettings: DotNet npNetBarcodeSettings;
        BarCodeGenerator: DotNet npNetBarCodeGenerator;
        Image: DotNet npNetImage;
        Text007: Label 'Import';
        Text009: Label 'All Files (*.*)|*.*';
        ImageFormat: DotNet npNetImageFormat;
        "-- Global": Integer;
        SizeX: Decimal;
        SizeY: Decimal;
        DpiX: Decimal;
        DpiY: Decimal;
        RotateAngle: Integer;
        BarcodeTypeText: Code[10];
        TempCrossRefItem: Code[20];
        Text000: Label 'There are no items with cross reference: %1';
        TransferLine: Record "Transfer Line";
        Found: Boolean;
        NoAA: Boolean;
        NoBarcodeText: Boolean;
        Text001: Label 'Status should not be %1.';

    local procedure "-- Print Functions"()
    begin
    end;

    [Scope('Personalization')]
    procedure GenerateBarcode(BarCode: Code[20];var TempBlob: Record TempBlob)
    var
        MemoryStream: DotNet npNetMemoryStream;
        OutStream: OutStream;
    begin
        Initialize(BarCode);
        //-NC1.17
        //Path := EnvironmentMgt.ClientEnvironment('TEMP') + 'Barcode.bmp';
        //+NC1.17
        BarCodeGenerator := BarCodeGenerator.BarCodeGenerator(BarCodeSettings);
        BarCodeSettings.ApplyKey('3YOZI-9N0S5-RD239-JN9R0-WCGL8');
        Image := BarCodeGenerator.GenerateImage();
        //-NC1.17
        //Image.Save(Path);
        //CLEAR(TempBlob);
        //TempBlob.Blob.IMPORT(FileMgt.UploadFileSilent(Path));
        MemoryStream := MemoryStream.MemoryStream;
        Image.Save(MemoryStream,ImageFormat.Png);
        Clear(TempBlob);
        TempBlob.Blob.CreateOutStream(OutStream);
        CopyStream(OutStream,MemoryStream);
        //+NC1.17
    end;

    local procedure Initialize(BarCode: Code[20])
    begin
        BarCodeSettings := BarCodeSettings.BarcodeSettings();
        BarCodeSettings.Data := BarCode;

        if SizeX <> 0 then BarCodeSettings.X := SizeX;
        if SizeY <> 0 then BarCodeSettings.Y := SizeY;
        if DpiX <> 0 then BarCodeSettings.DpiX := DpiX;
        if DpiY <> 0 then BarCodeSettings.DpiY := DpiY;
        if RotateAngle <> 0 then BarCodeSettings.Rotate := RotateAngle;
        //-NPR5.27
        BarCodeSettings.ShowText := not NoBarcodeText;
        BarCodeSettings.UseAntiAlias := not NoAA;
        //+NPR5.27

        case UpperCase(BarcodeTypeText) of
          'EAN13':
            BarCodeSettings.Type := BarCodeType.EAN13;
          'CODE39':
            BarCodeSettings.Type := BarCodeType.Code39;
          //-NPR5.27
          'QR' :
            BarCodeSettings.Type := BarCodeType.QRCode;
          //+NPR5.27
          //-NPR5.29 [245881]
          'CODE128' :
            BarCodeSettings.Type := BarCodeType.Code128;
          //+NPR5.29 [245881]
          else begin
            if StrLen(BarCode) = 13 then
              BarCodeSettings.Type := BarCodeType.EAN13
            else
              BarCodeSettings.Type := BarCodeType.Code39;
          end;
        end;
    end;

    procedure SetSizeX(Size: Decimal)
    begin
        SizeX := Size;
    end;

    procedure SetSizeY(Size: Decimal)
    begin
        SizeY := Size;
    end;

    procedure SetDpiX(X: Integer)
    begin
        DpiX := X;
    end;

    procedure SetDpiY(Y: Integer)
    begin
        DpiY := Y;
    end;

    procedure Rotate(RotateAngleIn: Integer)
    begin
        RotateAngle := RotateAngleIn;
    end;

    procedure SetBarcodeType(BarcodeTypeTextIn: Code[10])
    begin
        BarcodeTypeText := BarcodeTypeTextIn;
    end;

    procedure SetAntiAliasing(UseAntiAliasingIn: Boolean)
    begin
        //-NPR5.27
        NoAA := not UseAntiAliasingIn;
        //+NPR5.27
    end;

    procedure SetShowText(ShowTextIn: Boolean)
    begin
        //-NPR5.27
        NoBarcodeText := not ShowTextIn;
        //+NPR5.27
    end;

    local procedure "-- Lookup Functions"()
    begin
    end;

    procedure TranslateBarcodeToItemVariant(Barcode: Text[50];var ItemNo: Code[20];var VariantCode: Code[10];var ResolvingTable: Integer;AllowDiscontinued: Boolean) Found: Boolean
    var
        Item: Record Item;
        ItemCrossReference: Record "Item Cross Reference";
        AlternativeNo: Record "Alternative No.";
        ItemVariant: Record "Item Variant";
    begin
        //-NPR4.13
        ResolvingTable := 0;
        ItemNo := '';
        VariantCode := '';
        if (Barcode = '') then exit (false);

        //-NPR5.34 [283366]
        // Try Item Table
        // IF (STRLEN (Barcode) <= MAXSTRLEN (Item."No.")) THEN BEGIN
        //  IF (Item.GET (UPPERCASE(Barcode))) THEN BEGIN
        //    ResolvingTable := DATABASE::Item;
        //    ItemNo := Item."No.";
        //    EXIT (TRUE);
        //  END;
        // END;
        //+NPR5.34 [283366]

        // Try Item Cross Reference
        with ItemCrossReference do begin
          if (StrLen (Barcode) <= MaxStrLen ("Cross-Reference No.")) then begin
            SetCurrentKey ("Cross-Reference Type", "Cross-Reference No.");
            SetFilter ("Cross-Reference Type", '=%1', "Cross-Reference Type"::"Bar Code");
            SetFilter ("Cross-Reference No.", '=%1', UpperCase (Barcode));
            if not AllowDiscontinued then
              SetFilter ("Discontinue Bar Code", '=%1', false);
            if (FindFirst ()) then begin
              //-NPR5.29 [259398]
              if (not Item.Get ("Item No.")) then
                exit (false);
              if ("Variant Code" <> '') then
                if (not ItemVariant.Get ("Item No.", "Variant Code")) then
                  exit (false);
              //+NPR5.29 [259398]
              ResolvingTable := DATABASE::"Item Cross Reference";
              ItemNo := "Item No.";
              VariantCode := "Variant Code";
              exit (true);
            end;
          end;
        end;

        // Try Alternative No
        with AlternativeNo do begin
          if (StrLen (Barcode) <= MaxStrLen ("Alt. No.")) then begin
            SetCurrentKey ("Alt. No.", Type);
            SetFilter ("Alt. No.", '=%1', UpperCase (Barcode));
            SetFilter (Type, '=%1', Type::Item);
            if not AllowDiscontinued then
              SetFilter (Discontinue, '=%1', false);
            if (FindFirst ()) then begin
              if (Item.Get (Code) = false) then
                exit (false);
              if ("Variant Code" <> '') then
                if (ItemVariant.Get (Code, "Variant Code") = false) then
                  exit (false);
              ResolvingTable := DATABASE::"Alternative No.";
              ItemNo := Code;
              VariantCode := "Variant Code";
              exit (true);
            end;
          end;
        end;

        //-NPR5.34 [283366]
        // Try Item Table
        if (StrLen (Barcode) <= MaxStrLen (Item."No.")) then begin
          if (Item.Get (UpperCase(Barcode))) then begin
            ResolvingTable := DATABASE::Item;
            ItemNo := Item."No.";
            exit (true);
          end;
        end;
        //+NPR5.34 [283366]

        //-NPR5.29 [259398]
        with Item do begin
          if (StrLen (Barcode) <= MaxStrLen("Vendor Item No.")) then begin
            SetCurrentKey("Vendor Item No.","Vendor No.");
            SetRange("Vendor Item No.", Barcode);
            if FindFirst() then begin
              ResolvingTable := DATABASE::Item;
              ItemNo := "No.";
              exit(true);
            end;
          end;
        end;
        //+NPR5.29 [259398]

        exit (false);
        //+NPR4.13
    end;

    procedure GetItemVariantBarcode(var Barcode: Text[50];ItemNo: Code[20];VariantCode: Code[10];var ResolvingTable: Integer;AllowDiscontinued: Boolean): Boolean
    var
        AlternativeNo: Record "Alternative No.";
        ItemCrossReference: Record "Item Cross Reference";
        Item: Record Item;
    begin
        //-NPR5.23 [242522]
        Barcode := '';
        ResolvingTable := 0;

        //-NPR5.27 [254486]
        if (VariantCode = '') and Item.Get(ItemNo) then
          if Item."Label Barcode" <> '' then begin
            Barcode := Item."Label Barcode";
            ResolvingTable := DATABASE::Item;
            exit(true);
          end;
        //+NPR5.27 [254486]

        with ItemCrossReference do begin
          if (StrLen(ItemNo) <= MaxStrLen("Item No.")) and (StrLen(VariantCode) <= MaxStrLen("Variant Code")) then begin
            SetRange("Cross-Reference Type", "Cross-Reference Type"::"Bar Code");
            SetRange("Item No.", ItemNo);
            SetRange("Variant Code", VariantCode);
            if not AllowDiscontinued then
              SetRange("Discontinue Bar Code", false);
            if FindFirst then begin
              Barcode := "Cross-Reference No.";
              ResolvingTable := DATABASE::"Item Cross Reference";
              exit(true);
            end;
          end;
        end;

        with AlternativeNo do begin
          if (StrLen(ItemNo) <= MaxStrLen(Code)) and (StrLen(VariantCode) <= MaxStrLen("Variant Code")) then begin
            SetRange(Type, Type::Item);
            SetRange(Code, ItemNo);
            SetRange("Variant Code", VariantCode);
            if not AllowDiscontinued then
              SetRange(Discontinue, false);
            if FindFirst then begin
              Barcode := "Alt. No.";
              ResolvingTable := DATABASE::"Alternative No.";
              exit(true);
            end;
          end;
        end;

        //Only fallback to Item No. when no variant is specified.
        if (VariantCode = '') and Item.Get(ItemNo) then begin
          Barcode := ItemNo;
          ResolvingTable := DATABASE::Item;
          exit(true);
        end;

        exit(false);
        //+NPR5.23 [242522]
    end;

    local procedure "-- Table Specific Functions"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 5741, 'OnAfterValidateEvent', 'Cross-Reference No.', false, false)]
    local procedure ResolveBarcodeTransferLine(var Rec: Record "Transfer Line";var xRec: Record "Transfer Line";CurrFieldNo: Integer)
    var
        ReturnedCrossRef: Record "Item Cross Reference";
    begin
        //-NPR5.23 [242315]
        with Rec do begin
          GetTransferHeader(Rec);
          ReturnedCrossRef.Init;
          if "Cross-Reference No." <> '' then begin
            ICRLookupTransferItem(Rec,ReturnedCrossRef);
            Validate("Item No.",ReturnedCrossRef."Item No.");
            if ReturnedCrossRef."Variant Code" <> '' then
              Validate("Variant Code",ReturnedCrossRef."Variant Code");
            if ReturnedCrossRef."Unit of Measure" <> '' then
              Validate("Unit of Measure Code",ReturnedCrossRef."Unit of Measure");
          end;
          "Cross-Reference No." := ReturnedCrossRef."Cross-Reference No.";
          if ReturnedCrossRef.Description <> '' then
            Description := ReturnedCrossRef.Description;
        end;
        //+NPR5.23 [242315]
    end;

    local procedure GetTransferHeader(var TransferLine2: Record "Transfer Line")
    var
        TransHeader: Record "Transfer Header";
    begin
        //-NPR5.23 [242315]
        with TransferLine2 do begin
          TestField("Document No.");
          if "Document No." <> TransHeader."No." then
            TransHeader.Get("Document No.");

          TransHeader.TestField("Shipment Date");
          TransHeader.TestField("Receipt Date");
          TransHeader.TestField("Transfer-from Code");
          TransHeader.TestField("Transfer-to Code");
          TransHeader.TestField("In-Transit Code");
          "In-Transit Code" := TransHeader."In-Transit Code";
          "Transfer-from Code" := TransHeader."Transfer-from Code";
          "Transfer-to Code" := TransHeader."Transfer-to Code";
          "Shipment Date" := TransHeader."Shipment Date";
          "Receipt Date" := TransHeader."Receipt Date";
          "Shipping Agent Code" := TransHeader."Shipping Agent Code";
          "Shipping Agent Service Code" := TransHeader."Shipping Agent Service Code";
          "Shipping Time" := TransHeader."Shipping Time";
          "Outbound Whse. Handling Time" := TransHeader."Outbound Whse. Handling Time";
          "Inbound Whse. Handling Time" := TransHeader."Inbound Whse. Handling Time";
          Status := TransHeader.Status;
        end;
        //+NPR5.23 [242315]
    end;

    procedure EnterTransferItemCrossRef(var TransferLine: Record "Transfer Line")
    var
        AlternativeNo: Record "Alternative No.";
        ItemCrossReference: Record "Item Cross Reference";
        ItemVariant: Record "Item Variant";
        Item: Record Item;
    begin
        //-NPR5.23 [242315]
        with TransferLine do
           ItemCrossReference.Reset;
           ItemCrossReference.SetRange("Item No.",TransferLine."Item No.");
           ItemCrossReference.SetRange("Variant Code",TransferLine."Variant Code");
           ItemCrossReference.SetRange("Unit of Measure",TransferLine."Unit of Measure Code");
           //-NPR5.26 [246594]
           ItemCrossReference.SetRange("Cross-Reference Type",ItemCrossReference."Cross-Reference Type"::"Bar Code");
           //+NPR5.26 [246594]
           if ItemCrossReference.Find('-') then
             Found := true
           else begin
             ItemCrossReference.SetRange("Cross-Reference No.");
             Found := ItemCrossReference.Find('-');
           end;

           if not Found then begin
             AlternativeNo.Reset;
             AlternativeNo.SetCurrentKey(Code);
             AlternativeNo.SetRange(Type,AlternativeNo.Type::Item);
             AlternativeNo.SetRange(AlternativeNo.Code,TransferLine."Item No.");
             AlternativeNo.SetRange("Variant Code",TransferLine."Variant Code");
             if AlternativeNo.FindFirst then begin
               ItemCrossReference."Item No." := AlternativeNo.Code ;
               ItemCrossReference."Cross-Reference No." := AlternativeNo."Alt. No.";
               ItemCrossReference."Variant Code"  := AlternativeNo."Variant Code";
               ItemCrossReference."Unit of Measure" :=  AlternativeNo."Base Unit of Measure";
               ItemCrossReference."Cross-Reference Type" := ItemCrossReference."Cross-Reference Type"::"Bar Code";
               if ItemVariant.Get(TransferLine."Item No.",TransferLine."Variant Code") then
                 ItemCrossReference.Description := ItemVariant.Description;
               Found := true;
             end;
           end;

           if Found then begin
             TransferLine."Cross-Reference No." := ItemCrossReference."Cross-Reference No.";
             TransferLine."Unit of Measure Code" := ItemCrossReference."Unit of Measure";
             if ItemCrossReference.Description <> '' then begin
               TransferLine.Description := ItemCrossReference.Description;
             end;
           end else begin
             if TransferLine."Variant Code" <> '' then begin
               ItemVariant.Get(TransferLine."Item No.",TransferLine."Variant Code");
               TransferLine.Description := ItemVariant.Description;
             end else begin
               Item.Get(TransferLine."Item No.");
               TransferLine.Description := Item.Description;
             end;
           end;
        //+NPR5.23 [242315]
    end;

    procedure ICRLookupTransferItem(var TransferLine2: Record "Transfer Line";var ReturnedCrossRef: Record "Item Cross Reference")
    var
        AlternativeNo: Record "Alternative No.";
        ItemCrossReference: Record "Item Cross Reference";
        ItemVariant: Record "Item Variant";
        Item: Record Item;
    begin
        //-NPR5.23 [242315]
        with ItemCrossReference do begin
          TransferLine.Copy(TransferLine2);
          TempCrossRefItem := TransferLine2."Cross-Reference No.";
          Reset;
          SetCurrentKey("Cross-Reference No.","Cross-Reference Type","Cross-Reference Type No.","Discontinue Bar Code");
          SetRange("Cross-Reference No.",TransferLine."Cross-Reference No.");
          SetRange("Discontinue Bar Code",false);
          SetFilter("Cross-Reference Type No.",'%1','');
          //-NPR5.26 [246594]
          SetRange("Cross-Reference Type",ItemCrossReference."Cross-Reference Type"::"Bar Code");
          //+NPR5.26 [246594]
          SetRange("Item No.",TransferLine."Item No.");
          if not Find('-') then begin
            SetRange("Item No.");
            if not Find('-') then begin
              AlternativeNo.Reset;
              AlternativeNo.SetCurrentKey("Alt. No.",Type);
              AlternativeNo.SetRange(Type,AlternativeNo.Type::Item);
              AlternativeNo.SetRange("Alt. No.",TransferLine2."Cross-Reference No.");
              if AlternativeNo.FindFirst then begin
                ItemCrossReference."Item No." := AlternativeNo.Code ;
                ItemCrossReference."Cross-Reference No." := AlternativeNo."Alt. No." ;
                ItemCrossReference."Variant Code"  := AlternativeNo."Variant Code";
                ItemCrossReference."Unit of Measure" := AlternativeNo."Base Unit of Measure";
                ItemCrossReference."Cross-Reference Type" := ItemCrossReference."Cross-Reference Type"::"Bar Code";
                if ItemVariant.Get(TransferLine2."Item No.",TransferLine2."Variant Code") then
                  ItemCrossReference.Description := ItemVariant.Description;
              end else begin
                Error(Text000,TempCrossRefItem)
              end;
            end;
            if Next <> 0 then begin
              SetRange("Cross-Reference Type No.",'');
              if Find('-') then
                if Next <> 0 then begin
                  SetRange("Cross-Reference Type No.");
        //-NPR5.38 [293194]
                  if TryAskUserForCrossRef(ItemCrossReference,TempCrossRefItem) then;
        //          IF PAGE.RUNMODAL(PAGE::"Cross Reference List",ItemCrossReference) <> ACTION::LookupOK
        //          THEN
        //            ERROR(Text000,TempCrossRefItem);
        //+NPR5.38 [293194]
                end;
            end;
            //-NPR5.26 [246594]
            //ReturnedCrossRef.COPY(ItemCrossReference);
            //+NPR5.26 [246594]
          end;
            //-NPR5.26 [246594]
            ReturnedCrossRef.Copy(ItemCrossReference);
            //+NPR5.26 [246594]
        end;
        //+NPR5.23 [242315]
    end;

    [TryFunction]
    local procedure TryAskUserForCrossRef(var ItemCrossReference: Record "Item Cross Reference";EnterCrossRefNo: Code[20])
    begin
        //-NPR5.38 [293194]
        ItemCrossReference.SetRange("Cross-Reference Type No.");
        if PAGE.RunModal(PAGE::"Cross Reference List",ItemCrossReference) <> ACTION::LookupOK
        then
          Error(Text000,EnterCrossRefNo);
        //+NPR5.38 [293194]
    end;

    [IntegrationEvent(TRUE, FALSE)]
    procedure CallCrossReferenceNoLookUp(var TransferLine3: Record "Transfer Line")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014528, 'CallCrossReferenceNoLookUp', '', true, false)]
    local procedure CrossReferenceNoLookUp(var Sender: Codeunit "Barcode Library";var TransferLine3: Record "Transfer Line")
    var
        ItemCrossReference3: Record "Item Cross Reference";
    begin
        //-NPR5.23 [242315]
        with TransferLine3 do begin
          GetTransferHeader(TransferLine3);
          ItemCrossReference3.Reset;
          ItemCrossReference3.SetCurrentKey("Cross-Reference Type","Cross-Reference Type No.");
          ItemCrossReference3.SetFilter("Cross-Reference Type",'%1',ItemCrossReference3."Cross-Reference Type"::" ");
          ItemCrossReference3.SetFilter("Cross-Reference Type No.",'%1','');
          if PAGE.RunModal(PAGE::"Cross Reference List",ItemCrossReference3) = ACTION::LookupOK then
            Validate("Cross-Reference No.",ItemCrossReference3."Cross-Reference No.");
        end;
         //+NPR5.23 [242315]
    end;

    local procedure "--MixedDiscount"()
    begin
    end;

    local procedure GetMixedDiscountHeader(var MixedDiscountLine: Record "Mixed Discount Line")
    var
        MixedDiscount: Record "Mixed Discount";
    begin
        //-NPR5.26 [246594]
        MixedDiscount.Get(MixedDiscountLine.Code);
        if MixedDiscount.Status =  MixedDiscount.Status::Active then
          Error(Text001,MixedDiscount.Status::Active);
        //+NPR5.26 [246594]
    end;

    [IntegrationEvent(TRUE, false)]
    procedure CallCrossRefNoLookupMixDiscount(var MixedDiscountLine: Record "Mixed Discount Line")
    begin
        //-NPR5.26 [246594]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014528, 'CallCrossRefNoLookupMixDiscount', '', false, false)]
    local procedure CrossRefNoLookupMixDiscount(var Sender: Codeunit "Barcode Library";var MixedDiscountLine: Record "Mixed Discount Line")
    var
        ItemCrossReference2: Record "Item Cross Reference";
    begin
        //-NPR5.26 [246594]
        with MixedDiscountLine do begin
          if "Disc. Grouping Type" <> "Disc. Grouping Type"::Item then
            exit;
          GetMixedDiscountHeader(MixedDiscountLine);
          ItemCrossReference2.Reset;
          ItemCrossReference2.SetCurrentKey("Cross-Reference Type","Cross-Reference Type No.");
          ItemCrossReference2.SetFilter("Cross-Reference Type",'%1',ItemCrossReference2."Cross-Reference Type"::"Bar Code");
          ItemCrossReference2.SetFilter("Cross-Reference Type No.",'%1','');
          if PAGE.RunModal(PAGE::"Cross Reference List",ItemCrossReference2) = ACTION::LookupOK then begin
            "No." := ItemCrossReference2."Item No.";
            Validate("Cross-Reference No.",ItemCrossReference2."Cross-Reference No.");
          end;
        end;
        //+NPR5.26 [246594]
    end;

    [EventSubscriber(ObjectType::Table, 6014412, 'OnAfterValidateEvent', 'Cross-Reference No.', false, false)]
    local procedure OnAfterValidateCrossRefMixDiscount(var Rec: Record "Mixed Discount Line";var xRec: Record "Mixed Discount Line";CurrFieldNo: Integer)
    var
        ReturnedCrossRef: Record "Item Cross Reference";
    begin
        //-NPR5.26 [246594]
        with Rec do begin
          ReturnedCrossRef.Init;
          if "Cross-Reference No." <> '' then begin
            ICRLookupMixedDiscount(Rec,ReturnedCrossRef);
            Validate("No.",ReturnedCrossRef."Item No.");
            if ReturnedCrossRef."Variant Code" <> '' then
              Validate("Variant Code",ReturnedCrossRef."Variant Code");
          end;
          "Cross-Reference No." := ReturnedCrossRef."Cross-Reference No.";
          if ReturnedCrossRef.Description <> '' then
            Description := ReturnedCrossRef.Description;
        end;
        //+NPR5.26 [246594]
    end;

    procedure ICRLookupMixedDiscount(var MixedDiscountLine2: Record "Mixed Discount Line";var ReturnedCrossRef: Record "Item Cross Reference")
    var
        AlternativeNo: Record "Alternative No.";
        MixedDiscountLine: Record "Mixed Discount Line";
        ItemCrossReference: Record "Item Cross Reference";
        ItemVariant: Record "Item Variant";
    begin
        //-NPR5.26 [246594]
        with ItemCrossReference do begin
          MixedDiscountLine.Copy(MixedDiscountLine2);
          if MixedDiscountLine."Disc. Grouping Type" = MixedDiscountLine."Disc. Grouping Type"::Item then begin
              TempCrossRefItem := MixedDiscountLine2."Cross-Reference No.";
              Reset;
              SetCurrentKey("Cross-Reference No.","Cross-Reference Type","Cross-Reference Type No.","Discontinue Bar Code");
              SetRange("Cross-Reference No.",MixedDiscountLine."Cross-Reference No.");
              SetRange("Discontinue Bar Code",false);
              SetRange("Cross-Reference Type",ItemCrossReference."Cross-Reference Type"::"Bar Code");
              SetFilter("Cross-Reference Type No.",'%1','');
              SetRange("Item No.",MixedDiscountLine."No.");
              if not Find('-') then begin
                SetRange("Item No.");
                if not Find('-') then begin
                  AlternativeNo.Reset;
                  AlternativeNo.SetCurrentKey("Alt. No.",Type);
                  AlternativeNo.SetRange(Type,AlternativeNo.Type::Item);
                  AlternativeNo.SetRange("Alt. No.",MixedDiscountLine2."Cross-Reference No.");
                  if AlternativeNo.FindFirst then begin
                    ItemCrossReference."Item No." := AlternativeNo.Code ;
                    ItemCrossReference."Cross-Reference No." := AlternativeNo."Alt. No." ;
                    ItemCrossReference."Variant Code"  := AlternativeNo."Variant Code";
                    ItemCrossReference."Unit of Measure" := AlternativeNo."Base Unit of Measure";
                    ItemCrossReference."Cross-Reference Type" := ItemCrossReference."Cross-Reference Type"::"Bar Code";
                    if ItemVariant.Get(MixedDiscountLine2."No.",MixedDiscountLine2."Variant Code") then
                      ItemCrossReference.Description := ItemVariant.Description;
                  end else begin
                    Error(Text000,TempCrossRefItem)
                  end;
                end;
                if Next <> 0 then begin
                  SetRange("Cross-Reference Type No.",'');
                  if Find('-') then
                    if Next <> 0 then begin
                      SetRange("Cross-Reference Type No.");
                      if PAGE.RunModal(PAGE::"Cross Reference List",ItemCrossReference) <> ACTION::LookupOK
                      then
                        Error(Text000,TempCrossRefItem);
                    end;
                end;
              end;
              ReturnedCrossRef.Copy(ItemCrossReference);
            end;
        end;
        //+NPR5.26 [246594]
    end;

    local procedure "--Periodic Discount"()
    begin
    end;

    local procedure GetPeriodicDiscountHeader(var PeriodDiscountLine: Record "Period Discount Line")
    var
        PeriodDiscount: Record "Period Discount";
    begin
        //-NPR5.26 [246594]
        PeriodDiscount.Get(PeriodDiscountLine.Code);
        if PeriodDiscount.Status =  PeriodDiscount.Status::Active then
          Error(Text001,PeriodDiscount.Status::Active);
        //+NPR5.26 [246594]
    end;

    [IntegrationEvent(TRUE, false)]
    procedure CallCrossRefNoLookupPeriodicDiscount(var PeriodDiscountLine: Record "Period Discount Line")
    begin
        //-NPR5.26 [246594]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014528, 'CallCrossRefNoLookupPeriodicDiscount', '', false, false)]
    local procedure CrossRefNoLookupPeriodicDiscount(var Sender: Codeunit "Barcode Library";var PeriodDiscountLine: Record "Period Discount Line")
    var
        ItemCrossReference2: Record "Item Cross Reference";
    begin
        //-NPR5.26 [246594]
        with PeriodDiscountLine do begin
          GetPeriodicDiscountHeader(PeriodDiscountLine);
          ItemCrossReference2.Reset;
          ItemCrossReference2.SetCurrentKey("Cross-Reference Type","Cross-Reference Type No.");
          ItemCrossReference2.SetFilter("Cross-Reference Type",'%1',ItemCrossReference2."Cross-Reference Type"::"Bar Code");
          ItemCrossReference2.SetFilter("Cross-Reference Type No.",'%1','');
          if PAGE.RunModal(PAGE::"Cross Reference List",ItemCrossReference2) = ACTION::LookupOK then begin
            "Item No." := ItemCrossReference2."Item No.";
            Validate("Cross-Reference No.",ItemCrossReference2."Cross-Reference No.");
          end;
        end;
        //+NPR5.26 [246594]
    end;

    [EventSubscriber(ObjectType::Table, 6014414, 'OnAfterValidateEvent', 'Cross-Reference No.', false, false)]
    local procedure OnAfterValidateCrossRefPeriodicDiscount(var Rec: Record "Period Discount Line";var xRec: Record "Period Discount Line";CurrFieldNo: Integer)
    var
        ReturnedCrossRef: Record "Item Cross Reference";
    begin
        //-NPR5.26 [246594]
        with Rec do begin
          ReturnedCrossRef.Init;
          if "Cross-Reference No." <> '' then begin
            ICRLookupPeriodicDiscount(Rec,ReturnedCrossRef);
            Validate("Item No.",ReturnedCrossRef."Item No.");
            if ReturnedCrossRef."Variant Code" <> '' then
              Validate("Variant Code",ReturnedCrossRef."Variant Code");
          end;
          "Cross-Reference No." := ReturnedCrossRef."Cross-Reference No.";
          if ReturnedCrossRef.Description <> '' then
            Description := ReturnedCrossRef.Description;
        end;
        //+NPR5.26 [246594]
    end;

    procedure ICRLookupPeriodicDiscount(var PeriodDiscountLine2: Record "Period Discount Line";var ReturnedCrossRef: Record "Item Cross Reference")
    var
        AlternativeNo: Record "Alternative No.";
        PeriodDiscountLine: Record "Period Discount Line";
        ItemCrossReference: Record "Item Cross Reference";
        ItemVariant: Record "Item Variant";
    begin
        //-NPR5.26 [246594]
        with ItemCrossReference do begin
          PeriodDiscountLine.Copy(PeriodDiscountLine2);
              TempCrossRefItem := PeriodDiscountLine2."Cross-Reference No.";
              Reset;
              SetCurrentKey("Cross-Reference No.","Cross-Reference Type","Cross-Reference Type No.","Discontinue Bar Code");
              SetRange("Cross-Reference No.",PeriodDiscountLine."Cross-Reference No.");
              SetRange("Discontinue Bar Code",false);
              SetRange("Cross-Reference Type",ItemCrossReference."Cross-Reference Type"::"Bar Code");
              SetFilter("Cross-Reference Type No.",'%1','');
              SetRange("Item No.",PeriodDiscountLine."Item No.");
              if not Find('-') then begin
                SetRange("Item No.");
                if not Find('-') then begin
                  AlternativeNo.Reset;
                  AlternativeNo.SetCurrentKey("Alt. No.",Type);
                  AlternativeNo.SetRange(Type,AlternativeNo.Type::Item);
                  AlternativeNo.SetRange("Alt. No.",PeriodDiscountLine2."Cross-Reference No.");
                  if AlternativeNo.FindFirst then begin
                    ItemCrossReference."Item No." := AlternativeNo.Code ;
                    ItemCrossReference."Cross-Reference No." := AlternativeNo."Alt. No." ;
                    ItemCrossReference."Variant Code"  := AlternativeNo."Variant Code";
                    ItemCrossReference."Unit of Measure" := AlternativeNo."Base Unit of Measure";
                    ItemCrossReference."Cross-Reference Type" := ItemCrossReference."Cross-Reference Type"::"Bar Code";
                    if ItemVariant.Get(PeriodDiscountLine2."Item No.",PeriodDiscountLine2."Variant Code") then
                      ItemCrossReference.Description := ItemVariant.Description;
                  end else begin
                    Error(Text000,TempCrossRefItem)
                  end;
                end;
                if Next <> 0 then begin
                  SetRange("Cross-Reference Type No.",'');
                  if Find('-') then
                    if Next <> 0 then begin
                      SetRange("Cross-Reference Type No.");
                      if PAGE.RunModal(PAGE::"Cross Reference List",ItemCrossReference) <> ACTION::LookupOK
                      then
                        Error(Text000,TempCrossRefItem);
                    end;
                end;
              end;
              ReturnedCrossRef.Copy(ItemCrossReference);
        end;
        //+NPR5.26 [246594]
    end;
}

