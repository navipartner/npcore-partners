table 6151363 "CS Warehouse Activity Setup"
{
    // NPR5.55/ALPO/20200729 CASE 404663 Possibility to use vendor item number & description for CS warehouse activity lines

    Caption = 'CS Warehouse Activity Setup';
    DrillDownPageID = "CS Warehouse Activity Setup";
    LookupPageID = "CS Warehouse Activity Setup";

    fields
    {
        field(1;"Source Document";Option)
        {
            Caption = 'Source Document';
            OptionCaption = ' ,Sales Order,,,Sales Return Order,Purchase Order,,,Purchase Return Order,Inbound Transfer,Outbound Transfer,Prod. Consumption,Prod. Output,,,,,,Service Order,,Assembly Consumption,Assembly Order';
            OptionMembers = " ","Sales Order",,,"Sales Return Order","Purchase Order",,,"Purchase Return Order","Inbound Transfer","Outbound Transfer","Prod. Consumption","Prod. Output",,,,,,"Service Order",,"Assembly Consumption","Assembly Order";
        }
        field(2;"Activity Type";Option)
        {
            Caption = 'Activity Type';
            OptionCaption = ' ,Put-away,Pick,Movement,Invt. Put-away,Invt. Pick,Invt. Movement,Whse. Receipt,Whse. Shipment';
            OptionMembers = " ","Put-away",Pick,Movement,"Invt. Put-away","Invt. Pick","Invt. Movement","Whse. Receipt","Whse. Shipment";
        }
        field(10;"Show as Item No.";Option)
        {
            Caption = 'Show as Item No.';
            OptionCaption = 'Item No.,Vendor Item No.';
            OptionMembers = "Item No.","Vendor Item No.";
        }
    }

    keys
    {
        key(Key1;"Source Document","Activity Type")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Initialized: Boolean;
        UnsupportedRecordId: Label 'Unsupported record: %1';

    procedure GetSetup(SourceDocument: Option;ActivityType: Option)
    begin
        SetRange("Source Document", SourceDocument);
        SetRange("Activity Type", ActivityType);
        if IsEmpty then begin
          SetRange("Source Document", "Source Document"::" ");
          if IsEmpty then begin
            SetRange("Source Document", SourceDocument);
            SetRange("Activity Type", "Activity Type"::" ");
          end;
          if IsEmpty then
            SetRange("Source Document", "Source Document"::" ");
        end;
        if not FindFirst then
          Clear(Rec);
        Initialized := true;
    end;

    procedure ItemIdentifier(RecId: RecordID;WithVariantCode: Boolean;VariantSeparatorChars: Text[3]): Text
    var
        Item: Record Item;
        ItemCrossRef: Record "Item Cross Reference";
        WhseActivityLine: Record "Warehouse Activity Line";
        WhseReceiptLine: Record "Warehouse Receipt Line";
        WhseShipmentLine: Record "Warehouse Shipment Line";
        RecRef: RecordRef;
        ItemNo: Code[20];
        VariantCode: Code[10];
        VendorNo: Code[20];
    begin
        RecRef.Get(RecId);
        case RecRef.Number of
          DATABASE::"Warehouse Activity Line": begin
            RecRef.SetTable(WhseActivityLine);
            if WhseActivityLine."Item No." = '' then
              exit('');
            GetSetup(WhseActivityLine."Source Document", WhseActivityLine."Activity Type");
            ItemNo := WhseActivityLine."Item No.";
            VariantCode := WhseActivityLine."Variant Code";
          end;

          DATABASE::"Warehouse Receipt Line": begin
            RecRef.SetTable(WhseReceiptLine);
            if WhseReceiptLine."Item No." = '' then
              exit('');
            GetSetup(WhseReceiptLine."Source Document", "Activity Type"::"Whse. Receipt");
            ItemNo := WhseReceiptLine."Item No.";
            VariantCode := WhseReceiptLine."Variant Code";
          end;

          DATABASE::"Warehouse Shipment Line": begin
            RecRef.SetTable(WhseShipmentLine);
            if WhseShipmentLine."Item No." = '' then
              exit('');
            GetSetup(WhseShipmentLine."Source Document", "Activity Type"::"Whse. Shipment");
            ItemNo := WhseShipmentLine."Item No.";
            VariantCode := WhseShipmentLine."Variant Code";
          end;

          else
            Error(UnsupportedRecordId, Format(RecId));
        end;

        if VariantSeparatorChars = '' then
          VariantSeparatorChars := '-';

        if "Show as Item No." = "Show as Item No."::"Vendor Item No." then begin
          VendorNo := GetDocumentVendorNo(RecId);
          if VendorNo = '' then
            if Item.Get(ItemNo) then
              VendorNo := Item."Vendor No.";
          if VendorNo <> '' then begin
            ItemCrossRef.SetRange("Item No.", ItemNo);
            ItemCrossRef.SetRange("Variant Code", VariantCode);
            ItemCrossRef.SetRange("Cross-Reference Type", ItemCrossRef."Cross-Reference Type"::Vendor);
            ItemCrossRef.SetRange("Cross-Reference Type No.", VendorNo);
            if ItemCrossRef.IsEmpty then
              ItemCrossRef.SetRange("Variant Code", '');
            if ItemCrossRef.FindFirst then
              if ItemCrossRef."Cross-Reference No." <> '' then
                if WithVariantCode and (VariantCode <> '') then
                  exit(ItemCrossRef."Cross-Reference No." + VariantSeparatorChars + VariantCode)
                else
                  exit(ItemCrossRef."Cross-Reference No.");
          end;

          if Item."No." <> ItemNo then
            Item.Get(ItemNo);
          if Item."Vendor Item No." <> '' then
            if WithVariantCode and (VariantCode <> '') then
              exit(Item."Vendor Item No." + VariantSeparatorChars + VariantCode)
            else
              exit(Item."Vendor Item No.");
        end;

        if WithVariantCode and (VariantCode <> '') then
          exit(ItemNo + VariantSeparatorChars + VariantCode)
        else
          exit(ItemNo);
    end;

    local procedure GetDocumentVendorNo(RecId: RecordID): Code[20]
    var
        PurchLine: Record "Purchase Line";
        WhseActivityLine: Record "Warehouse Activity Line";
        WhseReceiptLine: Record "Warehouse Receipt Line";
        WhseShipmentLine: Record "Warehouse Shipment Line";
        RecRef: RecordRef;
    begin
        RecRef.Get(RecId);
        case RecRef.Number of
          DATABASE::"Warehouse Activity Line": begin
            RecRef.SetTable(WhseActivityLine);
            case WhseActivityLine."Source Type" of
              DATABASE::"Purchase Line":
                begin
                  PurchLine.SetRange("Document Type", WhseActivityLine."Source Subtype");
                  PurchLine.SetRange("Document No.", WhseActivityLine."Source No.");
                  PurchLine.SetRange("Line No.", WhseActivityLine."Source Line No.");
                  if PurchLine.FindFirst and (PurchLine."Buy-from Vendor No." <> '') then
                    exit(PurchLine."Buy-from Vendor No.");
                end;
            end;
          end;

          DATABASE::"Warehouse Receipt Line": begin
            RecRef.SetTable(WhseReceiptLine);
            case WhseReceiptLine."Source Type" of
              DATABASE::"Purchase Line":
                begin
                  PurchLine.SetRange("Document Type", WhseReceiptLine."Source Subtype");
                  PurchLine.SetRange("Document No.", WhseReceiptLine."Source No.");
                  PurchLine.SetRange("Line No.", WhseReceiptLine."Source Line No.");
                  if PurchLine.FindFirst and (PurchLine."Buy-from Vendor No." <> '') then
                    exit(PurchLine."Buy-from Vendor No.");
                end;
            end;
          end;

          DATABASE::"Warehouse Shipment Line": begin
            RecRef.SetTable(WhseShipmentLine);
            case WhseShipmentLine."Source Type" of
              DATABASE::"Purchase Line":
                begin
                  PurchLine.SetRange("Document Type", WhseShipmentLine."Source Subtype");
                  PurchLine.SetRange("Document No.", WhseShipmentLine."Source No.");
                  PurchLine.SetRange("Line No.", WhseShipmentLine."Source Line No.");
                  if PurchLine.FindFirst and (PurchLine."Buy-from Vendor No." <> '') then
                    exit(PurchLine."Buy-from Vendor No.");
                end;
            end;
          end;

          else
            Error(UnsupportedRecordId, Format(RecId));
        end;

        exit('');
    end;
}

