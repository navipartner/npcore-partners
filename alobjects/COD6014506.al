codeunit 6014506 "Accessory Unfold Mgt."
{
    // 288039/MHA /20180214  CASE 288039 Object created - unfold Accessory Items
    // NPR5.40/NPKNAV/20180330  CASE 288039 Transport NPR5.40 - 30 March 2018


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Generate Accessory Unfold Worksheet';
        Text001: Label 'Generating Unfold Lines: @1@@@@@@@@@@@@@@';
        Text002: Label '%1 must be the same as on Master Item %2: %3';
        Text003: Label 'Checking Accessories: @1@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\Posting Accessories:  @2@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@';

    local procedure "--- Generate Worksheet"()
    begin
    end;

    procedure GenerateWorksheet(var AccessoryUnfoldWorksheet: Record "Accessory Unfold Worksheet")
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        TempAccessorySparePart: Record "Accessory/Spare Part" temporary;
        Window: Dialog;
        Counter: Integer;
        Total: Integer;
    begin
        ItemLedgEntry.FilterGroup(40);
        ItemLedgEntry.SetRange("Entry Type",ItemLedgEntry."Entry Type"::Sale);
        ItemLedgEntry.FilterGroup(41);
        ItemLedgEntry.SetFilter("Item No.",AccessoryUnfoldWorksheet."Accessory Item No.");
        if not RunDynamicRequestPage(ItemLedgEntry) then
          exit;

        if not ItemLedgEntry.FindSet then
          exit;

        if GuiAllowed then begin
          Total := ItemLedgEntry.Count;
          Window.Open(Text001);
        end;

        repeat
          if GuiAllowed then begin
            Counter += 1;
            Window.Update(1,Round((Counter / Total) * 10000,1));
          end;

          if FindAccessories(ItemLedgEntry."Item No.",TempAccessorySparePart) then
            ItemLedgEntry2Worksheet(AccessoryUnfoldWorksheet,ItemLedgEntry,TempAccessorySparePart);
        until ItemLedgEntry.Next = 0;

        if GuiAllowed then
          Window.Close;
    end;

    local procedure ItemLedgEntry2Worksheet(AccessoryUnfoldWorksheet: Record "Accessory Unfold Worksheet";ItemLedgEntry: Record "Item Ledger Entry";var TempAccessorySparePart: Record "Accessory/Spare Part" temporary)
    begin
        if UnfoldEntryExists(ItemLedgEntry) then
          exit;

        if not AccessoryUnfoldWorksheet.Get(ItemLedgEntry."Item No.",ItemLedgEntry."Entry No.",'') then begin
          AccessoryUnfoldWorksheet.Init;
          AccessoryUnfoldWorksheet.Validate("Accessory Item No.",ItemLedgEntry."Item No.");
          AccessoryUnfoldWorksheet.Validate("Item Ledger Entry No.",ItemLedgEntry."Entry No.");
          AccessoryUnfoldWorksheet.Validate("Item No.",'');
          AccessoryUnfoldWorksheet.Insert(true);
        end;

        SetAccessoryFilter(ItemLedgEntry."Item No.",TempAccessorySparePart);
        TempAccessorySparePart.FindSet;
        repeat
          if not AccessoryUnfoldWorksheet.Get(ItemLedgEntry."Item No.",ItemLedgEntry."Entry No.",TempAccessorySparePart."Item No.") then begin
            AccessoryUnfoldWorksheet.Init;
            AccessoryUnfoldWorksheet.Validate("Accessory Item No.",ItemLedgEntry."Item No.");
            AccessoryUnfoldWorksheet.Validate("Item Ledger Entry No.",ItemLedgEntry."Entry No.");
            AccessoryUnfoldWorksheet.Validate("Item No.",TempAccessorySparePart."Item No.");
            AccessoryUnfoldWorksheet.Insert(true);
          end;
        until TempAccessorySparePart.Next = 0;
    end;

    local procedure FindAccessories(AccessoryItemNo: Code[20];var TempAccessorySparePart: Record "Accessory/Spare Part" temporary): Boolean
    var
        AccessorySparePart: Record "Accessory/Spare Part";
    begin
        SetAccessoryFilter(AccessoryItemNo,TempAccessorySparePart);
        if TempAccessorySparePart.FindFirst then
          exit(true);

        SetAccessoryFilter(AccessoryItemNo,AccessorySparePart);
        if AccessorySparePart.IsEmpty then
          exit(false);

        AccessorySparePart.FindSet;
        repeat
          TempAccessorySparePart.Init;
          TempAccessorySparePart := AccessorySparePart;
          TempAccessorySparePart.Insert;
        until AccessorySparePart.Next = 0;

        exit(true);
    end;

    local procedure SetAccessoryFilter(AccessoryItemNo: Code[20];var AccessorySparePart: Record "Accessory/Spare Part")
    begin
        Clear(AccessorySparePart);
        AccessorySparePart.SetRange(Type,AccessorySparePart.Type::Accessory);
        AccessorySparePart.SetRange(Code,AccessoryItemNo);
        AccessorySparePart.SetFilter("Item No.",'<>%1','');
        AccessorySparePart.SetFilter(Quantity,'<>%1',0);
        AccessorySparePart.SetRange("Unfold in Worksheet",true);
    end;

    local procedure UnfoldEntryExists(ItemLedgEntry: Record "Item Ledger Entry"): Boolean
    var
        AccessoryUnfoldEntry: Record "Accessory Unfold Entry";
    begin
        AccessoryUnfoldEntry.SetRange("Accessory Item No.",ItemLedgEntry."Item No.");
        AccessoryUnfoldEntry.SetRange("Item Ledger Entry No.",ItemLedgEntry."Entry No.");
        if AccessoryUnfoldEntry.FindFirst then
          exit(true);

        AccessoryUnfoldEntry.Reset;
        AccessoryUnfoldEntry.SetRange("Accessory Item No.",ItemLedgEntry."Item No.");
        AccessoryUnfoldEntry.SetRange("Unfold Item Ledger Entry No.",ItemLedgEntry."Entry No.");
        exit(AccessoryUnfoldEntry.FindFirst);
    end;

    local procedure RunDynamicRequestPage(var ItemLedgEntry: Record "Item Ledger Entry"): Boolean
    var
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
        FilterPageBuilder: FilterPageBuilder;
        FilterName: Text;
        FilterView: Text;
    begin
        if not GuiAllowed then
          exit(true);

        FilterPageBuilder.PageCaption := Text000;

        FilterName := GetTableName(DATABASE::"Item Ledger Entry");
        FilterPageBuilder.AddTable(FilterName,DATABASE::"Item Ledger Entry");

        FilterPageBuilder.AddRecord(FilterName,ItemLedgEntry);
        FilterPageBuilder.ADdField(FilterName,ItemLedgEntry."Item No.");
        FilterPageBuilder.ADdField(FilterName,ItemLedgEntry."Posting Date");
        FilterPageBuilder.ADdField(FilterName,ItemLedgEntry."Location Code");
        FilterPageBuilder.ADdField(FilterName,ItemLedgEntry."Document No.");
        FilterPageBuilder.SetView(FilterName,ItemLedgEntry.GetView(false));

        if not FilterPageBuilder.RunModal then
          exit(false);

        ItemLedgEntry.SetView(FilterPageBuilder.GetView(FilterName,false));
        exit(true);
    end;

    local procedure GetTableName(TableID: Integer): Text
    var
        TableMetadata: Record "Table Metadata";
    begin
        TableMetadata.Get(TableID);
        exit(CopyStr(TableMetadata.Name,1,20));
    end;

    local procedure "--- Post Worksheet"()
    begin
    end;

    procedure PostWorksheet(var AccessoryUnfoldWorksheet: Record "Accessory Unfold Worksheet"): Boolean
    var
        AccessoryUnfoldWorksheet2: Record "Accessory Unfold Worksheet";
        TempItemJnlLine: Record "Item Journal Line" temporary;
        Window: Dialog;
        Counter: Integer;
        LineNo: Integer;
        Total: Integer;
    begin
        AccessoryUnfoldWorksheet2.Copy(AccessoryUnfoldWorksheet);
        AccessoryUnfoldWorksheet2.FilterGroup(40);
        AccessoryUnfoldWorksheet2.SetFilter("Accessory Item No.",'<>%1','');
        AccessoryUnfoldWorksheet2.SetFilter("Item Ledger Entry No.",'>%1',0);
        if not AccessoryUnfoldWorksheet2.FindSet then
          exit(false);

        if GuiAllowed then begin
          Total := AccessoryUnfoldWorksheet2.Count;
          Window.Open(Text003);
        end;

        repeat
          if UseDialog() then begin
            Counter += 1;
            Window.Update(1,Round((Counter / Total) * 10000,1));
          end;
          TestVatSetup(AccessoryUnfoldWorksheet2."Accessory Item No.",AccessoryUnfoldWorksheet2."Item No.");
        until AccessoryUnfoldWorksheet2.Next = 0;

        if UseDialog() then
          Counter := 0;

        AccessoryUnfoldWorksheet2.FindSet;
        repeat
          if UseDialog() then begin
            Counter += 1;
            Window.Update(2,Round((Counter / Total) * 10000,1));
          end;
          Worksheet2ItemJnlLine(AccessoryUnfoldWorksheet2,LineNo,TempItemJnlLine);
          TransferWorksheet2UnfoldEntry(AccessoryUnfoldWorksheet2);
          AccessoryUnfoldWorksheet2.Delete(true);
          PostItemJnlLine(TempItemJnlLine);
        until AccessoryUnfoldWorksheet2.Next = 0;

        if UseDialog() then
          Window.Close;

        exit(true);
    end;

    local procedure TransferWorksheet2UnfoldEntry(var AccessoryUnfoldWorksheet: Record "Accessory Unfold Worksheet")
    var
        AccessoryUnfoldEntry: Record "Accessory Unfold Entry";
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        ItemLedgEntry.LockTable;
        if ItemLedgEntry.FindLast then;

        AccessoryUnfoldEntry.Init;
        AccessoryUnfoldEntry."Accessory Item No." := AccessoryUnfoldWorksheet."Accessory Item No.";
        AccessoryUnfoldEntry."Item Ledger Entry No." := AccessoryUnfoldWorksheet."Item Ledger Entry No.";
        AccessoryUnfoldEntry."Item No." := AccessoryUnfoldWorksheet."Item No.";
        AccessoryUnfoldEntry.Description := AccessoryUnfoldWorksheet.Description;
        AccessoryUnfoldEntry.Quantity := AccessoryUnfoldWorksheet.Quantity;
        AccessoryUnfoldEntry."Unit Price" := AccessoryUnfoldWorksheet."Unit Price";
        AccessoryUnfoldEntry."Unfold Item Ledger Entry No." := ItemLedgEntry."Entry No." + 1;
        AccessoryUnfoldEntry.Insert(true);
    end;

    local procedure Worksheet2ItemJnlLine(var AccessoryUnfoldWorksheet: Record "Accessory Unfold Worksheet";var LineNo: Integer;var TempItemJnlLine: Record "Item Journal Line" temporary)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
    begin
        ItemLedgEntry.Get(AccessoryUnfoldWorksheet."Item Ledger Entry No.");
        ValueEntry.SetRange("Item Ledger Entry No.",ItemLedgEntry."Entry No.");
        ValueEntry.FindFirst;

        LineNo += 10000;

        TempItemJnlLine.Init;
        TempItemJnlLine."Line No." := LineNo;
        if AccessoryUnfoldWorksheet."Item No." <> '' then
          TempItemJnlLine.Validate("Item No.",AccessoryUnfoldWorksheet."Item No.")
        else
          TempItemJnlLine.Validate("Item No.",AccessoryUnfoldWorksheet."Accessory Item No.");
        TempItemJnlLine.Validate("Posting Date",ItemLedgEntry."Posting Date");
        TempItemJnlLine."Document No." := ItemLedgEntry."Document No.";
        TempItemJnlLine."Register Number" := ItemLedgEntry."Register Number";
        TempItemJnlLine."Document Time" := ItemLedgEntry."Document Time";
        TempItemJnlLine.Validate("Entry Type",ItemLedgEntry."Entry Type");
        TempItemJnlLine.Validate("Source Type",ItemLedgEntry."Source Type");
        TempItemJnlLine.Validate("Source No.",ItemLedgEntry."Source No.");
        TempItemJnlLine.Validate("Source Code",ValueEntry."Source Code");
        TempItemJnlLine.Validate("Gen. Bus. Posting Group",ValueEntry."Gen. Bus. Posting Group");
        TempItemJnlLine.Validate("Gen. Prod. Posting Group",ValueEntry."Gen. Prod. Posting Group");
        TempItemJnlLine.Validate(Quantity,AccessoryUnfoldWorksheet.Quantity);
        TempItemJnlLine.Validate("Location Code",ItemLedgEntry."Location Code");
        TempItemJnlLine.Validate("Shortcut Dimension 1 Code",ItemLedgEntry."Global Dimension 1 Code");
        TempItemJnlLine.Validate("Shortcut Dimension 2 Code",ItemLedgEntry."Global Dimension 2 Code");
        TempItemJnlLine.Validate("Salespers./Purch. Code",ItemLedgEntry."Salesperson Code");
        TempItemJnlLine.Validate("Unit Amount",AccessoryUnfoldWorksheet."Unit Price");
        TempItemJnlLine.Insert;
    end;

    local procedure PostItemJnlLine(var TempItemJnlLine: Record "Item Journal Line" temporary)
    var
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin
        ItemJnlPostLine.Run(TempItemJnlLine);
    end;

    local procedure "--- Test"()
    begin
    end;

    procedure TestVatSetup(AccessoryItemNo: Code[20];ItemNo: Code[20])
    var
        Item: Record Item;
        Item2: Record Item;
    begin
        if AccessoryItemNo = '' then
          exit;
        if ItemNo = '' then
          exit;

        Item.Get(AccessoryItemNo);
        Item2.Get(ItemNo);
        if Item."VAT Prod. Posting Group" <> Item2."VAT Prod. Posting Group" then
          Error(Text002,Item.FieldCaption("VAT Prod. Posting Group"),Item."No.",Item."VAT Prod. Posting Group");
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure UseDialog(): Boolean
    begin
        exit(GuiAllowed);
    end;
}

