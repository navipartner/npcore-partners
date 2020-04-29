codeunit 6014662 "Stock-Take Manager"
{
    // 
    // //001 - ohm - samment�llingslok. kun
    // //002 - ohm
    // NPR6.000.005 20130620 LJJ - CASE 158433: Handling of dimensions.
    // NPR6.000.006 20130626 LJJ - CASE 158804: Handling of Phys. Inv. Journal Templates.
    // NPR4.02/LJ  /20150122  CASE 204496 Changed code to not modify record if it is not inserted
    // NPR4.16/TSA /20150301  CASE 208488 Physical Inventory, rewrite
    // NPR4.16/TSA /20150715  CASE 213313 Fixing the dimension value transfers
    // NPR4.16/TSA /20150721  CASE 213313 Cleaned out unused functions
    // NPR4.21/TSA /20160107  CASE 231081 Stock Take duplicate items in inv jnl
    // NPR4.21/STA /20160118  CASE 232162 Supplying default dimensions to override items dimensions
    // NPR4.21/RMT /20160205  CASE 225608 search for barcode in the item "Label barcode" field
    // NPRX.xx/TSA /20160623  CASE 245258 Enhanced error situation when all items will be out of scope
    // NPR4.xx/TSA /20160330  CASE 237925 Changed from Item.Inventory to Item."Net Change" for calculation method ADJUSTMENT and PURCHASE
    // NPR5.29/TSA /20161221  CASE 257297 Changed the suggested templates created on default to something useful suggested by Jackie.
    // NPR5.38/MHA /20180105  CASE 301053 Removed unused code from OnRum()
    // NPR5.29/TJ /20170123 CASE 263879 - Changed subtype of report variable CalcQtyOnHand from 790 to 6014663 and removed same unused variable from function TransferHandler
    // NPR5.40/TJ  /20180208  CASE 302634 Removed unused variables Ops�tning and Lagerv�rditemp
    // NPR5.40/TSA /20180307  CASE 307353 Fixing overflow in ItemJnlLine.Description assignment
    // NPR5.46/TSA /20180925 CASE 328623 Eliminating duplicate messages after transfer to inventory journal
    // NPR5.46/TSA /20181001 CASE 329899 Added RetailPrint() and FillRetailJournalLine()
    // NPR5.48/TSA /20181022 CASE 332846 Added AreaTopUp()
    // NPR5.48/CLVA/20181024 CASE 332846 Added added value
    // NPR5.51/JAKUBV/20190903  CASE 359375 Transport NPR5.51 - 3 September 2019

    TableNo = "Gift Voucher";

    trigger OnRun()
    begin
    end;

    var
        NPRDialog: Dialog;
        ProgressBarMax: Integer;
        ProgressBarIndex: Integer;
        Nprdim: Record "NPR Line Dimension";
        Varerec: Record Item;
        Licens: Codeunit "Licence information";
        RetailCode: Codeunit "NF Retail Code";
        OrgAfdelingskode: Code[20];
        OrgLokationskode: Code[20];
        "Item Variantrec": Record "Item Variant";
        Text001: Label 'The setup for this journal specifies that append is not allowed.';
        Text002: Label 'The %1 %2 %3 is not empty!';
        Text004: Label 'All lines must have "%6"!\\The setting "%1" on "%2" %3 prevents %4 lines to be transferred to the "%5"!';
        Text005: Label 'Nothing to Transfer!';
        Text006: Label 'No items where found using the specified filter!\\Either change the filter for the journal or change the option value for %1 to "Partial".';
        Text007: Label 'The item-variant %1 %2 is missing from stock-take according to the scope.\\The setting "%3" on "%4" %5 prevents processing!';
        Text008: Label 'Out-of-scope item %5 %6!\\The setting "%1" on "%2" %3 prevents this item to be transferred to the "%4"!';
        Text009: Label 'Physcial Inventory can''t be first warehouse transaction for item %1 %2!';
        Text010: Label 'Posting Date can''t be blank!';
        Text011: Label 'Aggregated Session';
        Text012: Label 'The combination of option %1 set to value "%2" and option %3 with value "%4" is not valid!';
        Text013: Label 'When using option %1 set to "%2", the same item-variant combinattion may not exist in multiple batched.\\Item-variant %3-%4 exists in batch %5 and %6!';
        Text014: Label 'Do you want to create default inventory profiles?\\Existing profiles will be updated.';
        Text015: Label '%1 %2 %3 %4 has been created.';
        Text016: Label 'New %1 have been created, select a default!';
        Text017: Label 'Item %1 requires a variant code.';
        Text018: Label 'All items have not been completely processed.\\There are items having %1 set to %2 remaining in the %3. ';
        Text019: Label 'Item %2 %3.\Having multiple lines with different %1 is not supported, lines are aggregated and %1 must be the same on all lines. ';
        Text020: Label 'Aggregation Aborted.';
        Text021: Label 'Some lines seems to be missing barcode, are you sure you want to aggregate on a blank value?';
        Text022: Label 'You must first setup the %1 for %2.';
        Text023: Label 'The %1 specifies blank filters, combined with %2 and %3, all items will be out-of-scope and thus ignored.';
        Adjustment01: Label '(not counted) %1';
        Adjustment02: Label '(adj. negative) %1';
        Adjustment03: Label '(adj. set zero) %1';
        Dialog000: Label '#1####################\@2@@@@@@@@@@@@@@@@@@@@';
        Dialog001: Label 'Aggregating...';
        Dialog002: Label 'Translating...';
        Dialog003: Label 'Transferring...';
        Dialog004: Label 'Validating...';
        Dialog005: Label 'Creating Inventory Items...';
        "Dialog005-2": Label 'Creating Inventory Items (2)...';
        Dialog007: Label 'Applying Count...';
        "Profile-STD300": Label 'Annual Stock Take';
        "Profile-STD301": Label 'Item Group Stock Take';
        "Profile-STD302": Label 'Vendor Stock Take';
        TopUpNotEmpty: Label 'The Top-Up Worksheet %1 is not empty. Do you want to append to the list?';
        TopUpFromMissing: Label 'There must be at least 2 areas defined for top-up to work.';
        TopUpDesc: Label 'Items in %1 but not in %2.';
        TopUpCreated: Label 'Worksheet %1 created.';

    procedure CheckConfigurationCode(CurrentConfigurationCode: Code[20];var StockTakeWorksheet: Record "Stock-Take Worksheet")
    begin
        //-NPR4.16
        if (CurrentConfigurationCode <> '') then
          StockTakeWorksheet.Get (CurrentConfigurationCode);
        //+NPR4.16
    end;

    procedure SetConfigurationCode(CurrentConfigurationCode: Code[20];var StockTakeWorksheet: Record "Stock-Take Worksheet")
    begin
        //-NPR4.16
        StockTakeWorksheet.FilterGroup := 2;
        StockTakeWorksheet.Reset;
        if (CurrentConfigurationCode <> '') then
          StockTakeWorksheet.SetRange ("Stock-Take Config Code", CurrentConfigurationCode);
        StockTakeWorksheet.FilterGroup := 0;
        if (StockTakeWorksheet.FindFirst ()) then;
        //+NPR4.16
    end;

    procedure LookupConfigurationCode(var CurrentConfigurationCode: Code[20];var StockTakeWorksheet: Record "Stock-Take Worksheet")
    var
        StockTakeConfig: Record "Stock-Take Configuration";
    begin
        //-NPR4.16
        Commit;
        if (StockTakeConfig.Get (CurrentConfigurationCode)) then;

        if (PAGE.RunModal (0, StockTakeConfig) = ACTION::LookupOK) then begin
          CurrentConfigurationCode := StockTakeConfig.Code;
          SetConfigurationCode (CurrentConfigurationCode, StockTakeWorksheet);
        end;
        //+NPR4.16
    end;

    procedure CheckWorksheetName(CurrentWorksheetName: Code[20];var StockTakeWorksheet: Record "Stock-Take Worksheet")
    var
        NPPhysInvJnlBatch2: Record "Stock-Take Worksheet";
    begin
        //-NPR4.16
        if (CurrentWorksheetName <> '') then
          StockTakeWorksheet.Get (StockTakeWorksheet."Stock-Take Config Code", CurrentWorksheetName);
        //+NPR4.16
    end;

    procedure SetWorksheetName(CurrentWorksheetName: Code[20];var StockTakeWorksheet: Record "Stock-Take Worksheet")
    begin
        //-NPR4.16
        StockTakeWorksheet.FilterGroup := 2;
        StockTakeWorksheet.SetRange ("Stock-Take Config Code", StockTakeWorksheet."Stock-Take Config Code");
        if (CurrentWorksheetName <> '') then
          StockTakeWorksheet.SetRange (Name, CurrentWorksheetName);
        StockTakeWorksheet.FilterGroup := 0;
        //-NPR5.38 [301053]
        //IF (StockTakeWorksheet.FINDFIRST ()) THEN
        if StockTakeWorksheet.FindFirst then;
        //+NPR5.38 [301053]
        //+NPR4.16
    end;

    procedure LookupWorksheetName(var CurrentWorksheetName: Code[20];var StockTakeWorksheet: Record "Stock-Take Worksheet")
    var
        StockTakeWorksheet2: Record "Stock-Take Worksheet";
    begin
        //-NPR4.16
        Commit;
        if (StockTakeWorksheet2.Get (StockTakeWorksheet."Stock-Take Config Code", CurrentWorksheetName)) then ;

        StockTakeWorksheet2.FilterGroup (2);
        StockTakeWorksheet2.SetRange ("Stock-Take Config Code", StockTakeWorksheet."Stock-Take Config Code");

        StockTakeWorksheet2.FilterGroup (0);

        if (PAGE.RunModal (0, StockTakeWorksheet2) = ACTION::LookupOK) then begin
          CurrentWorksheetName := StockTakeWorksheet2.Name;
          SetWorksheetName (CurrentWorksheetName, StockTakeWorksheet);
        end;
        //+NPR4.16
    end;

    procedure SelectItemJournalBatchName(JournalTemplateName: Code[10]) BatchName: Code[20]
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemJnlMgt: Codeunit ItemJnlManagement;
        CurrentBatchName: Code[20];
    begin
        //-NPR4.16
        ItemJournalLine.SetRange ("Journal Template Name", JournalTemplateName);
        ItemJournalLine.SetFilter ("Journal Batch Name", '%1..%2', '', '*');
        CurrentBatchName := '';
        ItemJnlMgt.LookupName (CurrentBatchName, ItemJournalLine);
        exit (CurrentBatchName);
        //+NPR4.16
    end;

    procedure TranslateBarcode(var StockTakeWorksheetLine: Record "Stock-Take Worksheet Line")
    begin
        //-NPR4.16
        with StockTakeWorksheetLine do
          TranslateBarcodeToItemVariant (Barcode, "Item No.", "Variant Code", "Item Translation Source");
        //+NPR4.16
    end;

    procedure TranslateBarcodeToItemVariant(Barcode: Text[50];var ItemNo: Code[20];var VariantCode: Code[10];var ResolvingTable: Integer) Found: Boolean
    var
        Item: Record Item;
        ItemCrossReference: Record "Item Cross Reference";
        AlternativeNo: Record "Alternative No.";
        ItemVariant: Record "Item Variant";
    begin
        //-NPR4.16
        ResolvingTable := 0;
        ItemNo := '';
        VariantCode := '';
        if (Barcode = '') then exit (false);

        // Try Item Table
        if (StrLen (Barcode) <= MaxStrLen (Item."No.")) then begin
          if (Item.Get (UpperCase(Barcode))) then begin
            ResolvingTable := DATABASE::Item;
            ItemNo := Item."No.";
            exit (true);
          end;
        end;

        // Try Item Cross Reference
        with ItemCrossReference do begin
          if (StrLen (Barcode) <= MaxStrLen ("Cross-Reference No.")) then begin
            SetCurrentKey ("Cross-Reference Type", "Cross-Reference No.");
            SetFilter ("Cross-Reference Type", '=%1', "Cross-Reference Type"::"Bar Code");
            SetFilter ("Cross-Reference No.", '=%1', UpperCase (Barcode));
            SetFilter ("Discontinue Bar Code", '=%1', false);
            if (FindFirst ()) then begin
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

        //-NPR4.21
        if (StrLen (Barcode) <= MaxStrLen (Item."Label Barcode")) then begin
          Item.SetRange("Label Barcode",Barcode);
          if Item.Count=1 then begin
            if (Item.FindFirst) then begin
              ResolvingTable := DATABASE::Item;
              ItemNo := Item."No.";
              exit (true);
            end;
          end;
        end;
        //+NPR4.21

        exit (false);
        //+NPR4.16
    end;

    procedure AssignItemCost(var StockTakeWorksheetLine: Record "Stock-Take Worksheet Line")
    var
        StockTakeConfig: Record "Stock-Take Configuration";
    begin
        //-NPR4.16
        if (StockTakeWorksheetLine."Item No." = '') then exit;

        StockTakeConfig.Get (StockTakeWorksheetLine."Stock-Take Config Code");
        StockTakeWorksheetLine."Unit Cost" := GetItemCost (StockTakeConfig."Suggested Unit Cost Source", StockTakeWorksheetLine."Item No.");
        //+NPR4.16
    end;

    procedure GetItemCost(SuggestedUnitCostSource: Option;ItemNo: Code[20]) ItemCost: Decimal
    var
        Item: Record Item;
        StockTakeConfig: Record "Stock-Take Configuration";
    begin
        //-NPR4.16
        if (not Item.Get (ItemNo)) then exit (0);

        case SuggestedUnitCostSource of
          StockTakeConfig."Suggested Unit Cost Source"::UNIT_COST :        exit (Item."Unit Cost");
          StockTakeConfig."Suggested Unit Cost Source"::LAST_DIRECT_COST : exit (Item."Last Direct Cost");
          StockTakeConfig."Suggested Unit Cost Source"::STANDARD_COST :    exit (Item."Standard Cost");
          else
            Error ('Unsupported option in AssignUnitCost ()');
        end;
        //+NPR4.16
    end;

    procedure TransferDimensions(StockTakeWorksheetLine: Record "Stock-Take Worksheet Line";var ItemJnlLine: Record "Item Journal Line")
    var
        DimMgr: Codeunit DimensionManagement;
        NewDimSetID: Integer;
    begin
        //-NPR4.16
        if (ItemJnlLine."Dimension Set ID" = StockTakeWorksheetLine."Dimension Set ID") then
          exit;

        ItemJnlLine."Dimension Set ID" := StockTakeWorksheetLine."Dimension Set ID";

        DimMgr.UpdateGlobalDimFromDimSetID (
          ItemJnlLine."Dimension Set ID",
          ItemJnlLine."Shortcut Dimension 1 Code", ItemJnlLine."Shortcut Dimension 2 Code");
        //+NPR4.16
    end;

    procedure CreateDefaultDim(var StockTakeWorksheetLine: Record "Stock-Take Worksheet Line")
    begin
        //-NPR4.16
        CreateDim (StockTakeWorksheetLine,
                   DATABASE::"Stock-Take Configuration", StockTakeWorksheetLine."Stock-Take Config Code",
                   DATABASE::Item, StockTakeWorksheetLine."Item No.",
                   DATABASE::"Salesperson/Purchaser",'');
        //+NPR4.16
    end;

    procedure CreateDim(var StockTakeWorksheetLine: Record "Stock-Take Worksheet Line";Type1: Integer;No1: Code[20];Type2: Integer;No2: Code[20];Type3: Integer;No3: Code[20])
    var
        TableID: array [10] of Integer;
        No: array [10] of Code[20];
        DimMgt: Codeunit DimensionManagement;
        StockTakeConfig: Record "Stock-Take Configuration";
        ItemJournalTemplate: Record "Item Journal Template";
        SourceCodeSetup: Record "Source Code Setup";
    begin
        //-NPR4.16
        TableID[1] := Type1;
        No[1] := No1;
        TableID[2] := Type2;
        No[2] := No2;
        TableID[3] := Type3;
        No[3] := No3;

        SourceCodeSetup.Get ();

        ItemJournalTemplate."Source Code" := '';
        if (StockTakeConfig.Get (StockTakeWorksheetLine."Stock-Take Config Code")) then
          if (ItemJournalTemplate.Get (StockTakeConfig."Item Journal Template Name")) then ;

        if (ItemJournalTemplate."Source Code" = '') then
          ItemJournalTemplate."Source Code" := SourceCodeSetup."Phys. Inventory Journal";

        StockTakeWorksheetLine."Shortcut Dimension 1 Code" := '';
        StockTakeWorksheetLine."Shortcut Dimension 2 Code" := '';

        StockTakeWorksheetLine."Dimension Set ID":=DimMgt.GetDefaultDimID(
          TableID, No, ItemJournalTemplate."Source Code",
            StockTakeWorksheetLine."Shortcut Dimension 1 Code", StockTakeWorksheetLine."Shortcut Dimension 2 Code",0,0);

        // IF (StockTakeWorksheetLine."Line No." <> 0) THEN
        //  DimMgt.UpdateGlobalDimFromDimSetID (
        //    StockTakeWorksheetLine."Dimension Set ID",
        //    StockTakeWorksheetLine."Shortcut Dimension 1 Code",
        //    StockTakeWorksheetLine."Shortcut Dimension 2 Code");
        //+NPR4.16
    end;

    procedure ValidateShortcutDimCode(var StockTakeWorksheetLine: Record "Stock-Take Worksheet Line";FieldNumber: Integer;var ShortcutDimCode: Code[20];DimensionSetID: Integer)
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        //-NPR4.16
        DimMgt.ValidateShortcutDimValues (FieldNumber,ShortcutDimCode,DimensionSetID);
        //+NPR4.16
    end;

    procedure ImportPreHandler(StockTakeWorksheet: Record "Stock-Take Worksheet")
    var
        StockTakeConfig: Record "Stock-Take Configuration";
        StockTakeWorksheetLine: Record "Stock-Take Worksheet Line";
    begin
        //-NPR4.16
        with StockTakeConfig do begin
          Get (StockTakeWorksheet."Stock-Take Config Code");
          case "Session Based Loading" of
            "Session Based Loading"::APPEND : ; // do nothing
            "Session Based Loading"::APPEND_UNTIL_TRANSFERRED : StockTakeWorksheet.TestField (Status, StockTakeWorksheet.Status::OPEN);
            "Session Based Loading"::APPEND_NOT_ALLOWED :
              begin
                StockTakeWorksheetLine.SetRange ("Stock-Take Config Code", StockTakeWorksheet."Stock-Take Config Code");
                StockTakeWorksheetLine.SetRange ("Worksheet Name", StockTakeWorksheet.Name);
                if (StockTakeWorksheetLine.FindFirst ()) then
                  Error (Text001);
              end;
            else
              Error ('Unsupported option in ImportPreHandling ().');
          end;
        end;
        //+NPR4.16
    end;

    procedure ImportPostHandler(StockTakeWorksheet: Record "Stock-Take Worksheet")
    var
        StockTakeConfig: Record "Stock-Take Configuration";
        StockTakeWorksheetLine: Record "Stock-Take Worksheet Line";
        sessionDatetime: DateTime;
        sessionGuid: Guid;
    begin
        //-NPR4.16
        if (GuiAllowed) then
          NPRDialog.Open (Dialog000);

        StockTakeConfig.Get (StockTakeWorksheet."Stock-Take Config Code");
        if (StockTakeConfig."Aggregation Level" <> StockTakeConfig."Aggregation Level"::NATIVE) then
          AggregateBatch (StockTakeWorksheet);

        sessionDatetime := CurrentDateTime;
        sessionGuid := CreateGuid ();
        StockTakeWorksheetLine.SetRange ("Stock-Take Config Code", StockTakeWorksheet."Stock-Take Config Code");
        StockTakeWorksheetLine.SetRange ("Worksheet Name", StockTakeWorksheet.Name);
        if (StockTakeWorksheetLine.FindSet ()) then begin
          repeat
            if (IsNullGuid (StockTakeWorksheetLine."Session ID")) then begin
              StockTakeWorksheetLine."Session DateTime" := sessionDatetime;
              StockTakeWorksheetLine."Session ID" := sessionGuid;
              TranslateBarcode (StockTakeWorksheetLine);
              AssignItemCost (StockTakeWorksheetLine);
              CreateDefaultDim (StockTakeWorksheetLine);
            end;
            StockTakeWorksheetLine.Modify ();
          until (StockTakeWorksheetLine.Next () = 0);
        end;

        if (GuiAllowed) then
          NPRDialog.Close ();
        //+NPR4.16
    end;

    procedure AggregateBatch(StockTakeWorksheet: Record "Stock-Take Worksheet")
    var
        tmpWorksheetLine: Record "Stock-Take Worksheet Line" temporary;
        WorksheetLine: Record "Stock-Take Worksheet Line";
        LineNo: Integer;
        StockTakeConfig: Record "Stock-Take Configuration";
        ShowWarning: Boolean;
    begin
        //-NPR4.16
        SetProgressPhase (Dialog001);

        StockTakeConfig.Get (StockTakeWorksheet."Stock-Take Config Code");
        WorksheetLine.SetRange ("Stock-Take Config Code", StockTakeWorksheet."Stock-Take Config Code");
        WorksheetLine.SetRange ("Worksheet Name", StockTakeWorksheet.Name);
        WorksheetLine.LockTable ();
        if (WorksheetLine.FindSet ()) then begin
          LineNo := 10000;
          ProgressBarMax := WorksheetLine.Count ();
          ProgressBarIndex := 0;
          ShowWarning := true;

          repeat
            tmpWorksheetLine.SetRange ("Stock-Take Config Code", StockTakeWorksheet."Stock-Take Config Code");
            tmpWorksheetLine.SetRange ("Worksheet Name", StockTakeWorksheet.Name);

            case StockTakeConfig."Aggregation Level" of
              StockTakeConfig."Aggregation Level"::NATIVE :
                tmpWorksheetLine.SetRange ("Line No.", WorksheetLine."Line No.");

              StockTakeConfig."Aggregation Level"::SCANNED_NUMBER :
                begin
                  if (ShowWarning) and (WorksheetLine.Barcode = '') then begin
                    if (not Confirm (Text021)) then
                      Error (Text020);
                    ShowWarning := false;
                  end;
                  tmpWorksheetLine.SetFilter (Barcode, '=%1', WorksheetLine.Barcode);
                end;

              StockTakeConfig."Aggregation Level"::SESSION :
                begin
                  tmpWorksheetLine.SetFilter (Barcode, '=%1', WorksheetLine.Barcode);
                  tmpWorksheetLine.SetFilter ("Session Name", '=%1', WorksheetLine."Session Name");
                end;

              StockTakeConfig."Aggregation Level"::CONSECUTIVE :
                begin
                  tmpWorksheetLine.SetFilter ("Line No.", '=%1', -1); // forces a new line
                  if (tmpWorksheetLine.Barcode = WorksheetLine.Barcode) then
                    tmpWorksheetLine.SetFilter ("Line No.", '=%1', tmpWorksheetLine."Line No.");
                end;

              else
                Error ('Unsupported option in AggregateBatch ().');
            end;

            // Aggregate
            if (tmpWorksheetLine.FindFirst ()) then begin
              tmpWorksheetLine."Qty. (Counted)" += WorksheetLine."Qty. (Counted)";
              tmpWorksheetLine."Transfer State" := tmpWorksheetLine."Transfer State"::READY;
              tmpWorksheetLine.Modify ();
            end else begin
              tmpWorksheetLine.TransferFields (WorksheetLine, true);
              tmpWorksheetLine."Line No." := LineNo;
              if (StockTakeConfig."Aggregation Level" = StockTakeConfig."Aggregation Level"::SCANNED_NUMBER) then
                tmpWorksheetLine."Session Name" := Text011;
              LineNo += 10000;
              tmpWorksheetLine.Insert ();
            end;

            SetProgressPhaseProgress (ProgressBarMax, ProgressBarIndex);
            ProgressBarIndex += 1;

          until (WorksheetLine.Next () = 0);

          SetProgressPhase (Dialog002);
          WorksheetLine.DeleteAll (true);

          tmpWorksheetLine.Reset();
          tmpWorksheetLine.FindSet ();
          ProgressBarMax := tmpWorksheetLine.Count ();
          ProgressBarIndex := 0;
          repeat
            WorksheetLine.TransferFields (tmpWorksheetLine, true);
            WorksheetLine.Insert ();

            SetProgressPhaseProgress (ProgressBarMax, ProgressBarIndex);
            ProgressBarIndex += 1;

          until (tmpWorksheetLine.Next () = 0);
        end;
        //+NPR4.16
    end;

    procedure TransferToItemInvJnl(StockTakeWorksheet: Record "Stock-Take Worksheet";TransferAction: Option;PostingDate: Date)
    var
        StockTakeWorksheet2: Record "Stock-Take Worksheet";
        StockTakeConfig: Record "Stock-Take Configuration";
        ItemJnlLine: Record "Item Journal Line";
        ResponseText: Text;
        MessageText: Text;
    begin
        //-NPR4.16
        if (GuiAllowed) then
          NPRDialog.Open (Dialog000);

        StockTakeConfig.Get(StockTakeWorksheet."Stock-Take Config Code");
        if (PostingDate = 0D) then
          Error (Text010);

        StockTakeWorksheet2.SetFilter ("Stock-Take Config Code", '=%1', StockTakeWorksheet."Stock-Take Config Code");
        if (StockTakeConfig."Session Based Transfer" > StockTakeConfig."Session Based Transfer"::ALL_WORKSHEETS) then
          StockTakeWorksheet2.SetFilter (Name, '=%1', StockTakeWorksheet.Name);

        // Validate that transfer is possible, processes and business rules
        StockTakeWorksheet2.FindSet ();
        repeat
          TransferPreHandler (StockTakeWorksheet2);
        until (StockTakeWorksheet2.Next () = 0);

        GetItemJnlLine (StockTakeWorksheet, ItemJnlLine, true);

        // Setup the Item Journal Line contentens and transfer the counted qty to journal
        StockTakeWorksheet2.FindSet ();
        case StockTakeConfig."Session Based Transfer" of
          StockTakeConfig."Session Based Transfer"::ALL_WORKSHEETS :
            TransferHandler (StockTakeWorksheet2, 0, ItemJnlLine, PostingDate);
          StockTakeConfig."Session Based Transfer"::WORKSHEET :
            TransferHandler (StockTakeWorksheet2, 2, ItemJnlLine, PostingDate);
          StockTakeConfig."Session Based Transfer"::SELECTED_LINES :
            TransferHandler (StockTakeWorksheet2, 2, ItemJnlLine, PostingDate);
          else
            Error ('Unsupported option in TransferToItemInvJnl ()');
        end;


        StockTakeWorksheet2.FindSet ();
        repeat
          //-NPR5.46 [328623]
          //TransferPostHandler (StockTakeWorksheet2, ItemJnlLine, TransferAction);
          ResponseText := '';
          TransferPostHandler (StockTakeWorksheet2, ItemJnlLine, TransferAction, ResponseText);
          if (ResponseText <> '') then
            MessageText += StrSubstNo ('%1\\', ResponseText);
          //+NPR5.46 [328623]

        until (StockTakeWorksheet2.Next () = 0);

        //-NPR5.46 [328623]
        if (MessageText <> '') then
          Message (MessageText);
        //+NPR5.46 [328623]

        if (GuiAllowed) then
          NPRDialog.Close ();
        //+NPR4.16
    end;

    procedure TransferPreHandler(StockTakeWorksheet: Record "Stock-Take Worksheet")
    var
        StockTakeConfig: Record "Stock-Take Configuration";
        WorksheetLine: Record "Stock-Take Worksheet Line";
        WorksheetLine2: Record "Stock-Take Worksheet Line";
        NotTranslatedCount: Integer;
        ItemJnlLine: Record "Item Journal Line";
        FilterString: array [5] of Text[200];
    begin
        //-NPR4.16
        SetProgressPhase (Dialog004);

        ProgressBarMax := 5;
        SetProgressPhaseProgress (ProgressBarMax, ProgressBarIndex);
        ProgressBarIndex += 1;

        StockTakeConfig.Get (StockTakeWorksheet."Stock-Take Config Code");
        StockTakeWorksheet.TestField (Status, StockTakeWorksheet.Status::READY_TO_TRANSFER);

        // Pre Transfer Validation
        with StockTakeConfig do begin
          case "Stock Take Method" of
            "Stock Take Method"::AREA:
              begin
                if ("Session Based Transfer" <> "Session Based Transfer"::ALL_WORKSHEETS) then
                  Error (Text012, FieldCaption ("Stock Take Method"), "Stock Take Method",
                         FieldCaption ("Session Based Transfer"), "Session Based Transfer");
                if (StockTakeWorksheet."Global Dimension 1 Code Filter" <> '') then
                  Error (Text012, FieldCaption ("Stock Take Method"), "Stock Take Method",
                         StockTakeWorksheet.FieldCaption ("Global Dimension 1 Code Filter"),
                         StockTakeWorksheet."Global Dimension 1 Code Filter");
                if (StockTakeWorksheet."Global Dimension 2 Code Filter" <> '') then
                  Error (Text012, FieldCaption ("Stock Take Method"), "Stock Take Method",
                         StockTakeWorksheet.FieldCaption ("Global Dimension 2 Code Filter"),
                         StockTakeWorksheet."Global Dimension 2 Code Filter");
               end;

            "Stock Take Method"::PRODUCT:
              begin
                if (StockTakeWorksheet."Global Dimension 1 Code Filter" <> '') then
                  Error (Text012, FieldCaption ("Stock Take Method"), "Stock Take Method",
                         StockTakeWorksheet.FieldCaption ("Global Dimension 1 Code Filter"),
                         StockTakeWorksheet."Global Dimension 1 Code Filter");
                if (StockTakeWorksheet."Global Dimension 2 Code Filter" <> '') then
                  Error (Text012, FieldCaption ("Stock Take Method"), "Stock Take Method",
                         StockTakeWorksheet.FieldCaption ("Global Dimension 2 Code Filter"),
                         StockTakeWorksheet."Global Dimension 2 Code Filter");

                // same product is not allowed to be in another batch when method product
                WorksheetLine.Reset ();
                WorksheetLine.SetRange ("Stock-Take Config Code", StockTakeWorksheet."Stock-Take Config Code");
                WorksheetLine.SetRange ("Worksheet Name", StockTakeWorksheet.Name);
                WorksheetLine.SetFilter ("Transfer State", '=%1', WorksheetLine."Transfer State"::READY);
                if (WorksheetLine.FindSet ()) then begin
                  repeat
                    WorksheetLine.CalcFields ("Qty. (Total Counted)");
                    if (WorksheetLine."Qty. (Total Counted)" <> WorksheetLine."Qty. (Counted)") then begin
                      WorksheetLine2.SetRange ("Stock-Take Config Code", WorksheetLine."Stock-Take Config Code");
                      WorksheetLine2.SetFilter("Worksheet Name",'<>%1', WorksheetLine."Worksheet Name");
                      WorksheetLine2.SetFilter ("Item No.", '=%1', WorksheetLine."Item No.");
                      WorksheetLine2.SetFilter ("Variant Code", '=%1', WorksheetLine."Variant Code");
                      WorksheetLine2.SetFilter ("Transfer State", '=%1', WorksheetLine2."Transfer State"::READY);
                      if (WorksheetLine2.FindFirst ()) then
                        Error (Text013, FieldCaption ("Stock Take Method"), "Stock Take Method",
                               WorksheetLine."Item No.", WorksheetLine."Variant Code",
                               WorksheetLine."Worksheet Name", WorksheetLine2."Worksheet Name");

                    end;
                  until (WorksheetLine.Next () = 0);
                end;
              end;

            "Stock Take Method"::DIMENSION:
              begin
                if ((StockTakeWorksheet."Global Dimension 1 Code Filter" = '') and
                    (StockTakeWorksheet."Global Dimension 2 Code Filter" = '')) then begin
                  if (StockTakeWorksheet."Global Dimension 1 Code Filter" = '') then
                    Error (Text012, FieldCaption ("Stock Take Method"), "Stock Take Method",
                           StockTakeWorksheet.FieldCaption ("Global Dimension 1 Code Filter"), '<blank>');
                  if (StockTakeWorksheet."Global Dimension 2 Code Filter" = '') then
                    Error (Text012, FieldCaption ("Stock Take Method"), "Stock Take Method",
                           StockTakeWorksheet.FieldCaption ("Global Dimension 2 Code Filter"), '<blank>');
                end;

                // same product is not allowed to be in another batch when method dimension
                WorksheetLine.Reset ();
                WorksheetLine.SetRange ("Stock-Take Config Code", StockTakeWorksheet."Stock-Take Config Code");
                WorksheetLine.SetRange ("Worksheet Name", StockTakeWorksheet.Name);
                WorksheetLine.SetFilter ("Transfer State", '=%1', WorksheetLine."Transfer State"::READY);
                if (WorksheetLine.FindSet ()) then begin
                  repeat
                    WorksheetLine.CalcFields ("Qty. (Total Counted)");
                    if (WorksheetLine."Qty. (Total Counted)" <> WorksheetLine."Qty. (Counted)") then begin
                      WorksheetLine2.SetRange ("Stock-Take Config Code", WorksheetLine."Stock-Take Config Code");
                      WorksheetLine2.SetFilter("Worksheet Name",'<>%1', WorksheetLine."Worksheet Name");
                      WorksheetLine2.SetFilter ("Item No.", '=%1', WorksheetLine."Item No.");
                      WorksheetLine2.SetFilter ("Variant Code", '=%1', WorksheetLine."Variant Code");
                      WorksheetLine2.SetFilter ("Transfer State", '=%1', WorksheetLine2."Transfer State"::READY);
                      if (WorksheetLine2.FindFirst ()) then
                        Error (Text013, FieldCaption ("Stock Take Method"), "Stock Take Method",
                               WorksheetLine."Item No.", WorksheetLine."Variant Code",
                               WorksheetLine."Worksheet Name", WorksheetLine2."Worksheet Name");

                    end;
                  until (WorksheetLine.Next () = 0);
                end;

              end;

            else
              Error ('Unsupported option in TransferPreHandler ()');

          end;
        end;

        SetProgressPhaseProgress (ProgressBarMax, ProgressBarIndex);
        ProgressBarIndex += 1;

        if (StockTakeConfig."Session Based Transfer" <> StockTakeConfig."Session Based Transfer"::SELECTED_LINES) then begin
          WorksheetLine.Reset ();
          WorksheetLine.SetRange ("Stock-Take Config Code", StockTakeWorksheet."Stock-Take Config Code");
          WorksheetLine.SetRange ("Worksheet Name", StockTakeWorksheet.Name);
          WorksheetLine.SetFilter ("Transfer State", '=%1', WorksheetLine."Transfer State"::IGNORE);
          if (WorksheetLine.FindFirst ()) then
            WorksheetLine.TestField ("Transfer State", WorksheetLine."Transfer State"::READY);
        end;

        SetProgressPhaseProgress (ProgressBarMax, ProgressBarIndex);
        ProgressBarIndex += 1;

        WorksheetLine.Reset ();
        WorksheetLine.SetRange ("Stock-Take Config Code", StockTakeWorksheet."Stock-Take Config Code");
        WorksheetLine.SetRange ("Worksheet Name", StockTakeWorksheet.Name);
        WorksheetLine.SetFilter ("Item No.", '%1', '');
        WorksheetLine.SetFilter ("Transfer State", '=%1', WorksheetLine."Transfer State"::READY);
        NotTranslatedCount := WorksheetLine.Count ();
        if (NotTranslatedCount <> 0) then begin
          case StockTakeConfig."Barcode Not Accepted" of
            StockTakeConfig."Barcode Not Accepted"::ERROR :
              Error (Text004, StockTakeConfig.FieldCaption ("Barcode Not Accepted"), StockTakeConfig.TableCaption, StockTakeConfig.Code,
                              NotTranslatedCount, ItemJnlLine.TableCaption, WorksheetLine.FieldCaption ("Item No."));
            StockTakeConfig."Barcode Not Accepted"::IGNORE : ; // Do nothing
            else
              Error ('Unsupported option in TransferPreHandler ()');
          end;
        end;

        SetProgressPhaseProgress (ProgressBarMax, ProgressBarIndex);
        ProgressBarIndex += 1;

        WorksheetLine.Reset ();
        WorksheetLine.SetRange ("Stock-Take Config Code", StockTakeWorksheet."Stock-Take Config Code");
        WorksheetLine.SetRange ("Worksheet Name", StockTakeWorksheet.Name);
        WorksheetLine.SetFilter (Blocked, '=%1', true);
        WorksheetLine.SetFilter ("Transfer State", '=%1', WorksheetLine."Transfer State"::READY);
        NotTranslatedCount := WorksheetLine.Count ();
        if (NotTranslatedCount <> 0) then begin
          case StockTakeConfig."Blocked Item" of
            StockTakeConfig."Blocked Item"::ERROR :
              Error (Text004, StockTakeConfig.FieldCaption ("Blocked Item"), StockTakeConfig.TableCaption, StockTakeConfig.Code,
                              NotTranslatedCount, ItemJnlLine.TableCaption, WorksheetLine.FieldCaption (Blocked)+'=FALSE');
            StockTakeConfig."Blocked Item"::IGNORE : ; // Do nothing
            StockTakeConfig."Blocked Item"::TEMP_UNBLOCK:
              Error ('Temporary unblocking items are not available in this version.')
            else
              Error ('Unsupported option in TransferPreHandler ()');
          end;
        end;

        SetProgressPhaseProgress (ProgressBarMax, ProgressBarIndex);
        ProgressBarIndex += 1;
        //+NPR4.16

        //-NPR5.25 [245258]
        if ((StockTakeConfig."Counting Method" <> StockTakeConfig."Counting Method"::PARTIAL) and
            (StockTakeConfig."Items Out-of-Scope" = StockTakeConfig."Items Out-of-Scope"::IGNORE)) then begin

          WorksheetLine.Reset;
          WorksheetLine.SetRange ("Stock-Take Config Code", StockTakeWorksheet."Stock-Take Config Code");
          WorksheetLine.SetRange ("Worksheet Name", StockTakeWorksheet.Name);
          WorksheetLine.SetFilter ("Transfer State", '=%1', WorksheetLine."Transfer State"::READY);
          if (WorksheetLine.FindSet ()) then begin
            // when all filters are blank, all items will be out of scope
            GetConfigurationFilterValues (StockTakeWorksheet, FilterString);
            GetWorksheetFilterValues (StockTakeWorksheet, FilterString);
            if (FilterString[1]+FilterString[2]+FilterString[3]+FilterString[4]+FilterString[5] = '') then
              Error (Text023, StockTakeWorksheet.Name, StockTakeConfig.FieldCaption ("Counting Method"), StockTakeConfig.FieldCaption("Items Out-of-Scope"));
          end;
        end;
        //+NPR5.25 [245258]
    end;

    procedure TransferHandler(StockTakeWorksheet: Record "Stock-Take Worksheet";FilterType: Option JOURNAL,BATCH,BOTH;var ItemJnlLine: Record "Item Journal Line";PostingDate: Date)
    var
        StockTakeConfig: Record "Stock-Take Configuration";
        Item: Record Item;
        ItemJnlBatch: Record "Item Journal Batch";
        tmpWorksheetLine: Record "Stock-Take Worksheet Line" temporary;
        WorksheetLine: Record "Stock-Take Worksheet Line";
        ItemsNotOnInventory: Boolean;
        DoTransfer: Boolean;
        ItemVariant: Record "Item Variant";
    begin
        //-NPR4.16
        SetProgressPhase (Dialog003);

        StockTakeConfig.Get (StockTakeWorksheet."Stock-Take Config Code");
        StockTakeConfig.TestField ("Inventory Calc. Date");

        // Prepare the list with items that have been stock taken
        WorksheetLine.SetRange ("Stock-Take Config Code", StockTakeWorksheet."Stock-Take Config Code");
        if (FilterType in  [FilterType::BATCH, FilterType::BOTH]) then
          WorksheetLine.SetRange ("Worksheet Name", StockTakeWorksheet.Name);

        if (WorksheetLine.FindSet ()) then begin
          repeat
            DoTransfer := ((WorksheetLine."Item No." <> '') and
                           (WorksheetLine."Transfer State" = WorksheetLine."Transfer State"::READY));
            if (DoTransfer) then begin
              tmpWorksheetLine.TransferFields (WorksheetLine, true);
              tmpWorksheetLine.Insert ();
            end;
          until (WorksheetLine.Next () = 0);
        end;

        if (tmpWorksheetLine.IsEmpty ()) then
          Error (Text005);

        // use the setting and filters to create the main inventory lines in the journal
        CreateItemJnlLine (StockTakeWorksheet, FilterType, StockTakeConfig."Counting Method", ItemJnlLine, tmpWorksheetLine, PostingDate);

        // update items in item inv jnl with the counted qty
        ApplyCountToItemInvJnl (ItemJnlLine, tmpWorksheetLine,
                                StockTakeConfig."Items in Scope Not Counted",
                                StockTakeConfig."Suppress Not Counted", StockTakeConfig.Code);

        // The remaining items are to out-of-scoop, check setup and act
        tmpWorksheetLine.Reset ();
        if (tmpWorksheetLine.Count () <> 0) then begin
          tmpWorksheetLine.FindFirst ();

          case StockTakeConfig."Items Out-of-Scope" of
            StockTakeConfig."Items Out-of-Scope"::ERROR :
              Error (Text008, StockTakeConfig.FieldCaption ("Items Out-of-Scope"), StockTakeConfig.TableCaption, StockTakeConfig.Code,
                              ItemJnlLine.TableCaption, tmpWorksheetLine."Item No.", tmpWorksheetLine."Variant Code");
            StockTakeConfig."Items Out-of-Scope"::IGNORE :
              tmpWorksheetLine.DeleteAll ();
            StockTakeConfig."Items Out-of-Scope"::ACCEPT_COUNT :
              begin
                // the inital count was "complete" but this setting allows us to accept the extra items user has counted
                CreateItemJnlLine (StockTakeWorksheet, FilterType, StockTakeConfig."Counting Method"::PARTIAL,
                                   ItemJnlLine, tmpWorksheetLine, PostingDate);

                ApplyCountToItemInvJnl (ItemJnlLine, tmpWorksheetLine,
                                        StockTakeConfig."Items in Scope Not Counted"::ACCEPT_CURRENT, true, StockTakeConfig.Code);
                tmpWorksheetLine.Reset ();
                if (tmpWorksheetLine.FindFirst ()) then begin
                  if (StockTakeConfig."Session Based Transfer" = StockTakeConfig."Session Based Transfer"::SELECTED_LINES) then begin
                    repeat
                      WorksheetLine.Get (tmpWorksheetLine."Stock-Take Config Code",
                                               tmpWorksheetLine."Worksheet Name",
                                               tmpWorksheetLine."Line No.");
                      WorksheetLine."Transfer State" := WorksheetLine."Transfer State"::IGNORE;
                      WorksheetLine.Modify ();
                    until (tmpWorksheetLine.Next () = 0);
                  end else begin

                    if (tmpWorksheetLine."Variant Code" = '') then begin
                      ItemVariant.SetFilter ("Item No.", '=%1', tmpWorksheetLine."Item No.");
                      if (ItemVariant.FindFirst ()) then
                        Error (Text017, tmpWorksheetLine."Item No.");
                     end;
                     Error (Text009, tmpWorksheetLine."Item No.", tmpWorksheetLine."Variant Code");

                  end;
                end;
              end;

            else
              Error ('Unsupported option in TransferHandler ()');
          end;
        end;
        //+NPR4.16
    end;

    procedure ApplyCountToItemInvJnl(var ItemJnlLine: Record "Item Journal Line";var tmpWorksheetLine: Record "Stock-Take Worksheet Line" temporary;ItemsInScopeNotCounted: Integer;SuppressNotCounted: Boolean;StockTakeConfigCode: Code[20])
    var
        Item: Record Item;
        StockTakeConfig: Record "Stock-Take Configuration";
        WorksheetLine: Record "Stock-Take Worksheet Line";
        StockTakeWorksheet: Record "Stock-Take Worksheet";
        tmpWorksheetLine2: Record "Stock-Take Worksheet Line" temporary;
        markForDelete: Boolean;
        adjustedQty: Decimal;
    begin
        //-NPR4.16

        // This function is invoked in 2 different contexts:
        // 1) the user context for which all rules of the user applies
        // 2) do-what-I-mean handling of out-of-scope items. This implies ACCEPT_CURRENT and SuppressNotCount = TRUE

        SetProgressPhase (Dialog007);

        tmpWorksheetLine.Reset ();
        Item.Reset ();

        StockTakeConfig.Get (StockTakeConfigCode);
        if (tmpWorksheetLine.SetCurrentKey ("Item No.", "Variant Code")) then ;

        ItemJnlLine.SetCurrentKey ("Journal Template Name", "Journal Batch Name", "Line No.");
        ItemJnlLine.FindSet (true, false);
        ProgressBarMax := ItemJnlLine.Count ();
        ProgressBarIndex := 0;
        repeat

          tmpWorksheetLine.Reset ();
          tmpWorksheetLine.SetFilter ("Item No.", '=%1', ItemJnlLine."Item No.");
          tmpWorksheetLine.SetFilter ("Variant Code", '=%1', ItemJnlLine."Variant Code");

          if (not tmpWorksheetLine.FindFirst ()) then begin

            case StockTakeConfig."Adjustment Method" of
              StockTakeConfig."Adjustment Method"::STOCKTAKE :
                markForDelete := AdjustForStockTake (ItemsInScopeNotCounted, SuppressNotCounted, StockTakeConfig, ItemJnlLine);

              StockTakeConfig."Adjustment Method"::ADJUSTMENT :
                markForDelete := AdjustForAdjustment (ItemsInScopeNotCounted, SuppressNotCounted, StockTakeConfig, ItemJnlLine);

              StockTakeConfig."Adjustment Method"::PURCHASE :
                markForDelete := AdjustForPurchase (ItemsInScopeNotCounted, SuppressNotCounted, StockTakeConfig, ItemJnlLine);
              else
                Error ('Unsupported option in ApplyCountToItemInvJnl ()');
            end;

            if (markForDelete) then begin
              ItemJnlLine.Delete (true);
            end else begin
              // Create a temp count line, apply default dimensions, and transfer to item jnl
              Clear (tmpWorksheetLine2);
              tmpWorksheetLine2."Stock-Take Config Code" := StockTakeConfigCode;
              tmpWorksheetLine2."Item No." := ItemJnlLine."Item No.";
              //-NPR4.21
              tmpWorksheetLine2."Variant Code" := ItemJnlLine."Variant Code";
              //+NPR4.21
              tmpWorksheetLine2."Line No." := -1;
              tmpWorksheetLine2.Insert ();
              CreateDefaultDim (tmpWorksheetLine2);
              TransferDimensions (tmpWorksheetLine2, ItemJnlLine);
              ItemJnlLine.Modify ();
              tmpWorksheetLine2.Delete (true);
            end;

          end else begin
            tmpWorksheetLine.CalcFields ("Qty. (Total Counted)");
            markForDelete := false;

            case StockTakeConfig."Adjustment Method" of
              StockTakeConfig."Adjustment Method"::STOCKTAKE :
                ItemJnlLine.Validate ("Qty. (Phys. Inventory)", tmpWorksheetLine."Qty. (Total Counted)");
              StockTakeConfig."Adjustment Method"::ADJUSTMENT :
                begin

                  adjustedQty := ItemJnlLine.Quantity - tmpWorksheetLine."Qty. (Total Counted)";

                  if (adjustedQty = 0) then begin
                    markForDelete := true;
                    ItemJnlLine.Validate (Quantity, 0);
                  end else if (adjustedQty < 0) then begin
                    ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::"Positive Adjmt.";
                    ItemJnlLine.Validate (Quantity, Abs (adjustedQty));
                  end else if (adjustedQty > 0) then begin
                    ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::"Negative Adjmt.";
                    ItemJnlLine.Validate (Quantity, adjustedQty);
                  end;

                end;
              StockTakeConfig."Adjustment Method"::PURCHASE :
                ItemJnlLine.Validate (Quantity, tmpWorksheetLine."Qty. (Total Counted)");
              else
                Error ('Unsupported option in ApplyCountToItemInvJnl ()');
            end;

            if (markForDelete = false) then begin
              Item.Get (tmpWorksheetLine."Item No.");
              if (Item."Costing Method" <> Item."Costing Method"::Standard) then
                ItemJnlLine.Validate ("Unit Cost", tmpWorksheetLine."Unit Cost");

              if (StockTakeWorksheet.Get (tmpWorksheetLine."Stock-Take Config Code",
                                       tmpWorksheetLine."Worksheet Name")) then begin
                if (StockTakeWorksheet."Global Dimension 1 Code Filter" <> '') then
                  ItemJnlLine.Validate ("Shortcut Dimension 1 Code", StockTakeWorksheet."Global Dimension 1 Code Filter");
                if (StockTakeWorksheet."Global Dimension 2 Code Filter" <> '') then
                  ItemJnlLine.Validate ("Shortcut Dimension 2 Code", StockTakeWorksheet."Global Dimension 2 Code Filter");
              end;

              TransferDimensions (tmpWorksheetLine, ItemJnlLine);
            end;

            ItemJnlLine.Modify (true);

            WorksheetLine.Reset ();
            WorksheetLine.CopyFilters (tmpWorksheetLine);
            //-NPR4.21
            WorksheetLine.SetFilter ("Stock-Take Config Code", '=%1', tmpWorksheetLine."Stock-Take Config Code");
            //+NPR4.21
            WorksheetLine.ModifyAll ("Transfer State", WorksheetLine."Transfer State"::TRANSFERRED);

            tmpWorksheetLine.DeleteAll ();
            if (markForDelete) then
              ItemJnlLine.Delete (true);
          end;

          SetProgressPhaseProgress (ProgressBarMax, ProgressBarIndex);
          ProgressBarIndex += 1;

        until (ItemJnlLine.Next () = 0);
        //+NPR4.16
    end;

    procedure AdjustForStockTake(ItemsInScopeNotCounted: Integer;SuppressNotCounted: Boolean;StockTakeConfig: Record "Stock-Take Configuration";var ItemJnlLine: Record "Item Journal Line") MarkForDelete: Boolean
    begin

        MarkForDelete := false;

        case ItemsInScopeNotCounted of
          StockTakeConfig."Items in Scope Not Counted"::ERROR :
            Error (Text007, ItemJnlLine."Item No.", ItemJnlLine."Variant Code",
                   StockTakeConfig.FieldCaption ("Items in Scope Not Counted"), StockTakeConfig.TableCaption, StockTakeConfig.Code);

          StockTakeConfig."Items in Scope Not Counted"::IGNORE :
            MarkForDelete := true;

          StockTakeConfig."Items in Scope Not Counted"::ACCEPT_CURRENT :
            begin
              if (SuppressNotCounted = false) then begin
                //-+NPR5.40 [307353] STRSUBSTNO (Adjustment01, COPYSTR (ItemJnlLine.Description, 1, MAXSTRLEN (ItemJnlLine.Description)-16));
                ItemJnlLine.Description := StrSubstNo (Adjustment01, CopyStr (ItemJnlLine.Description, 1, MaxStrLen (ItemJnlLine.Description)-StrLen (Adjustment01)+2));
                ItemJnlLine.Modify (true);
              end;
            end;

          StockTakeConfig."Items in Scope Not Counted"::ADJUST_IF_NEGATIVE :
            if (ItemJnlLine."Qty. (Calculated)" < 0) then begin
              ItemJnlLine.Validate ("Qty. (Phys. Inventory)", 0);
              //-+NPR5.40 [307353] STRSUBSTNO (Adjustment02, COPYSTR (ItemJnlLine.Description, 1, MAXSTRLEN (ItemJnlLine.Description)-16));
              ItemJnlLine.Description := StrSubstNo (Adjustment02, CopyStr (ItemJnlLine.Description, 1, MaxStrLen (ItemJnlLine.Description)-StrLen(Adjustment02)+2));

              ItemJnlLine.Modify (true);
            end else begin
              if (SuppressNotCounted = false) then begin
                //-+NPR5.40 [307353] STRSUBSTNO (Adjustment01, COPYSTR (ItemJnlLine.Description, 1, MAXSTRLEN (ItemJnlLine.Description)-16));
                ItemJnlLine.Description := StrSubstNo (Adjustment01, CopyStr (ItemJnlLine.Description, 1, MaxStrLen (ItemJnlLine.Description)-StrLen(Adjustment01)+2));
                ItemJnlLine.Modify (true);
              end;
            end;

          StockTakeConfig."Items in Scope Not Counted"::ADJUST_SET_ZERO :
            if (ItemJnlLine."Qty. (Calculated)" <> 0) then begin
              ItemJnlLine.Validate ("Qty. (Phys. Inventory)", 0);
              //-+NPR5.40 [307353] STRSUBSTNO (Adjustment03, COPYSTR (ItemJnlLine.Description, 1, MAXSTRLEN (ItemJnlLine.Description)-16));
              ItemJnlLine.Description := StrSubstNo (Adjustment03, CopyStr (ItemJnlLine.Description, 1, MaxStrLen (ItemJnlLine.Description)-StrLen (Adjustment03)+2));
              ItemJnlLine.Modify (true);
            end else begin
              if (SuppressNotCounted = false) then begin
                //-+NPR5.40 [307353] STRSUBSTNO (Adjustment01, COPYSTR (ItemJnlLine.Description, 1, MAXSTRLEN (ItemJnlLine.Description)-16));
                ItemJnlLine.Description := StrSubstNo (Adjustment01, CopyStr (ItemJnlLine.Description, 1, MaxStrLen (ItemJnlLine.Description)-StrLen(Adjustment01)+2));
                ItemJnlLine.Modify (true);
              end;
            end;

          else
            Error ('Unsupported option in AdjustForStockTake ()');
        end;

        exit (MarkForDelete);
    end;

    procedure AdjustForAdjustment(ItemsInScopeNotCounted: Integer;SuppressNotCounted: Boolean;StockTakeConfig: Record "Stock-Take Configuration";var ItemJnlLine: Record "Item Journal Line") MarkForDelete: Boolean
    begin

        MarkForDelete := false;

        case ItemsInScopeNotCounted of
          StockTakeConfig."Items in Scope Not Counted"::ERROR :
            Error (Text007, ItemJnlLine."Item No.", ItemJnlLine."Variant Code",
                   StockTakeConfig.FieldCaption ("Items in Scope Not Counted"), StockTakeConfig.TableCaption, StockTakeConfig.Code);

          StockTakeConfig."Items in Scope Not Counted"::IGNORE :
            MarkForDelete := true;

          StockTakeConfig."Items in Scope Not Counted"::ACCEPT_CURRENT :
            begin
              if (SuppressNotCounted = false) then
                //-+NPR5.40 [307353]  ItemJnlLine.Description := STRSUBSTNO (Adjustment01, COPYSTR (ItemJnlLine.Description, 1, MAXSTRLEN (ItemJnlLine.Description)-16));
                ItemJnlLine.Description := StrSubstNo (Adjustment01, CopyStr (ItemJnlLine.Description, 1, MaxStrLen (ItemJnlLine.Description)-StrLen(Adjustment01)+2));
              ItemJnlLine.Modify (true);
            end;

          StockTakeConfig."Items in Scope Not Counted"::ADJUST_IF_NEGATIVE :
            if (ItemJnlLine.Quantity < 0) then begin
              ItemJnlLine.Validate (Quantity, Abs(ItemJnlLine.Quantity));
              //-+NPR5.40 [307353] ItemJnlLine.Description := STRSUBSTNO (Adjustment02, COPYSTR (ItemJnlLine.Description, 1, MAXSTRLEN (ItemJnlLine.Description)-16));
              ItemJnlLine.Description := StrSubstNo (Adjustment02, CopyStr (ItemJnlLine.Description, 1, MaxStrLen (ItemJnlLine.Description)-StrLen(Adjustment02)+2));
              ItemJnlLine.Modify (true);
            end else begin
              ItemJnlLine.Validate (Quantity, 0);
            end;

          StockTakeConfig."Items in Scope Not Counted"::ADJUST_SET_ZERO :
            if (ItemJnlLine.Quantity < 0) then begin
              ItemJnlLine.Validate (Quantity, Abs(ItemJnlLine.Quantity));
              //-+NPR5.40 [307353] ItemJnlLine.Description := STRSUBSTNO (Adjustment02, COPYSTR (ItemJnlLine.Description, 1, MAXSTRLEN (ItemJnlLine.Description)-16));
              ItemJnlLine.Description := StrSubstNo (Adjustment02, CopyStr (ItemJnlLine.Description, 1, MaxStrLen (ItemJnlLine.Description)-StrLen(Adjustment02)+2));
              ItemJnlLine.Modify (true);
            end else if (ItemJnlLine.Quantity > 0) then begin
              ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::"Negative Adjmt.";
              ItemJnlLine.Validate (Quantity, Abs(ItemJnlLine.Quantity));
              //-+NPR5.40 [307353] ItemJnlLine.Description := STRSUBSTNO (Adjustment02, COPYSTR (ItemJnlLine.Description, 1, MAXSTRLEN (ItemJnlLine.Description)-16));
              ItemJnlLine.Description := StrSubstNo (Adjustment02, CopyStr (ItemJnlLine.Description, 1, MaxStrLen (ItemJnlLine.Description)-StrLen(Adjustment02)+2));
              ItemJnlLine.Modify (true);
            end;

          else
            Error ('Unsupported option in AdjustForAdjustment ()');
        end;

        if (ItemJnlLine.Quantity = 0) then
          MarkForDelete := true;

        exit (MarkForDelete);
    end;

    procedure AdjustForPurchase(ItemsInScopeNotCounted: Integer;SuppressNotCounted: Boolean;StockTakeConfig: Record "Stock-Take Configuration";var ItemJnlLine: Record "Item Journal Line") MarkForDelete: Boolean
    begin

        MarkForDelete := false;

        case ItemsInScopeNotCounted of
          StockTakeConfig."Items in Scope Not Counted"::ERROR :
            Error (Text007, ItemJnlLine."Item No.", ItemJnlLine."Variant Code",
                   StockTakeConfig.FieldCaption ("Items in Scope Not Counted"), StockTakeConfig.TableCaption, StockTakeConfig.Code);

          StockTakeConfig."Items in Scope Not Counted"::IGNORE :
            MarkForDelete := true;

          StockTakeConfig."Items in Scope Not Counted"::ACCEPT_CURRENT : // Not Applicable
            MarkForDelete := true;

          StockTakeConfig."Items in Scope Not Counted"::ADJUST_IF_NEGATIVE : // Not Applicable
            MarkForDelete := true;

          StockTakeConfig."Items in Scope Not Counted"::ADJUST_SET_ZERO : // Not Applicable
            MarkForDelete := true;

          else
            Error ('Unsupported option in AdjustForPurchase ()');
        end;

        if (ItemJnlLine.Quantity = 0) then
          MarkForDelete := true;

        exit (MarkForDelete);
    end;

    procedure TransferPostHandler(StockTakeWorksheet: Record "Stock-Take Worksheet";var ItemJnlLine: Record "Item Journal Line";TransferAction: Option;var ResponseText: Text)
    var
        WorksheetLine: Record "Stock-Take Worksheet Line";
        StockTakeConfig: Record "Stock-Take Configuration";
        ItemJnlMgt: Codeunit ItemJnlManagement;
    begin
        //-NPR4.16
        StockTakeConfig.Get (StockTakeWorksheet."Stock-Take Config Code");

        //-NPR4.16
        if (ItemJnlLine.Count () = 0) then
          exit;
        //+NPR4.16

        case TransferAction of
          StockTakeConfig."Transfer Action"::TRANSFER : ; // Done
          StockTakeConfig."Transfer Action"::TRANSFER_POST :
            CODEUNIT.Run (CODEUNIT::"Item Jnl.-Post", ItemJnlLine);
          StockTakeConfig."Transfer Action"::TRANSFER_POST_PRINT:
            CODEUNIT.Run (CODEUNIT::"Item Jnl.-Post+Print", ItemJnlLine);
          else
            Error ('Unsupported option in TransferPostHandler ()');
        end;

        WorksheetLine.SetRange ("Stock-Take Config Code", StockTakeWorksheet."Stock-Take Config Code");
        WorksheetLine.SetRange ("Worksheet Name", StockTakeWorksheet.Name);
        WorksheetLine.SetFilter ("Transfer State", '=%1', WorksheetLine."Transfer State"::IGNORE);
        if (WorksheetLine.FindFirst ()) then
          Message (Text018, WorksheetLine.FieldCaption ("Transfer State"), WorksheetLine."Transfer State", WorksheetLine.TableCaption ());

        WorksheetLine.SetRange ("Stock-Take Config Code", StockTakeWorksheet."Stock-Take Config Code");
        WorksheetLine.SetRange ("Worksheet Name", StockTakeWorksheet.Name);
        WorksheetLine.SetFilter ("Transfer State", '<>%1', WorksheetLine."Transfer State"::TRANSFERRED);

        StockTakeWorksheet.Status := StockTakeWorksheet.Status::COMPLETE;
        if (not WorksheetLine.IsEmpty ()) then
          StockTakeWorksheet.Status := StockTakeWorksheet.Status::PARTIALLY_TRANSFERRED;
        StockTakeWorksheet.Modify ();

        case StockTakeConfig."Data Release" of
          StockTakeConfig."Data Release"::MANUAL : ;
          StockTakeConfig."Data Release"::ON_TRANSFER :
            begin
              WorksheetLine.Reset ();
              WorksheetLine.SetRange ("Stock-Take Config Code", StockTakeWorksheet."Stock-Take Config Code");
              WorksheetLine.SetRange ("Worksheet Name", StockTakeWorksheet.Name);
              WorksheetLine.SetFilter ("Transfer State", '=%1', WorksheetLine."Transfer State"::TRANSFERRED);
              WorksheetLine.DeleteAll (true);
            end;

          StockTakeConfig."Data Release"::ON_FINAL_TRANSFER :
            if (StockTakeWorksheet.Status = StockTakeWorksheet.Status::COMPLETE) then begin
              //-NPR5.51 [359375]
              //IF (StockTakeConfig."Session Based Transfer" = StockTakeConfig."Session Based Transfer"::WORKSHEET) THEN
              //  StockTakeWorksheet.DELETE (TRUE);
              if (StockTakeConfig."Session Based Transfer" = StockTakeConfig."Session Based Transfer"::WORKSHEET) then begin
                if (StockTakeConfig."Keep Worksheets") then begin
                  WorksheetLine.Reset ();
                  WorksheetLine.SetRange ("Stock-Take Config Code", StockTakeWorksheet."Stock-Take Config Code");
                  WorksheetLine.SetRange ("Worksheet Name", StockTakeWorksheet.Name);
                  WorksheetLine.DeleteAll (true);
                end else begin
                  StockTakeWorksheet.Delete (true);
                end;
              end;
              //+NPR5.51 [359375]

              if (StockTakeConfig."Session Based Transfer" = StockTakeConfig."Session Based Transfer"::ALL_WORKSHEETS) then begin
                StockTakeWorksheet.Reset ();
                StockTakeWorksheet.SetFilter ("Stock-Take Config Code", '=%1', StockTakeConfig.Code);
                StockTakeWorksheet.SetFilter (Status, '<>%1', StockTakeWorksheet.Status::COMPLETE);
                if (StockTakeWorksheet.IsEmpty ()) then begin
                  //-NPR5.51 [359375]
                  // StockTakeWorksheet.RESET ();
                  // StockTakeWorksheet.SETFILTER ("Stock-Take Config Code", '=%1', StockTakeConfig.Code);
                  // StockTakeWorksheet.DELETEALL (TRUE);
                  if (StockTakeConfig."Keep Worksheets") then begin
                    WorksheetLine.Reset ();
                    WorksheetLine.SetRange ("Stock-Take Config Code", StockTakeWorksheet."Stock-Take Config Code");
                    WorksheetLine.DeleteAll (true);
                  end else begin
                    StockTakeWorksheet.Reset ();
                    StockTakeWorksheet.SetFilter ("Stock-Take Config Code", '=%1', StockTakeConfig.Code);
                    StockTakeWorksheet.DeleteAll (true);
                  end;
                  //+NPR5.51 [359375]
                end;
              end;
            end;
          else
            Error ('Unsupported option in TransferPostHandler ()');
        end;

        if (TransferAction = StockTakeConfig."Transfer Action"::TRANSFER) then begin
          // ItemJnlLine.FINDFIRST ();
          //ItemJnlMgt.OpenJnl (StockTakeConfig."Item Journal Batch Name", ItemJnlLine);
          // ItemJnlLine.FILTERGROUP := 2;
          // ItemJnlLine.SETRANGE ("Journal Template Name", StockTakeConfig."Item Journal Template Name");
          // ItemJnlLine.SETRANGE("Journal Batch Name", StockTakeConfig."Item Journal Batch Name");
          // ItemJnlLine.FILTERGROUP := 0;
          // COMMIT;
          // FORM.RUN (FORM::"Phys. Inventory Journal", ItemJnlLine);

          //-NPR5.46 [328623]
          //MESSAGE (Text015, ItemJnlLine.COUNT, ItemJnlLine.TABLECAPTION,
          //         ItemJnlLine."Journal Template Name", ItemJnlLine."Journal Batch Name");

          ResponseText := StrSubstNo (Text015, ItemJnlLine.Count, ItemJnlLine.TableCaption, ItemJnlLine."Journal Template Name", ItemJnlLine."Journal Batch Name");
          //+NPR5.46 [328623]

        end;
    end;

    procedure GetItemJnlLine(StockTakeWorksheet: Record "Stock-Take Worksheet";var ItemJnlLine: Record "Item Journal Line";WithCheck: Boolean)
    var
        StockTakeConfig: Record "Stock-Take Configuration";
        ItemJnlBatch: Record "Item Journal Batch";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        //-NPR4.16
        // Setup target journal
        StockTakeConfig.Get(StockTakeWorksheet."Stock-Take Config Code");

        with StockTakeConfig do begin
          TestField ("Item Journal Template Name");
          TestField ("Item Journal Batch Name");

          if ("Item Journal Batch Usage" = "Item Journal Batch Usage"::TEMPLATE) then begin
            ItemJnlBatch.Get ("Item Journal Template Name", "Item Journal Batch Name");
            ItemJnlBatch.TestField ("No. Series");
            ItemJnlBatch.Name := StockTakeWorksheet.Name;
            if (not ItemJnlBatch.Insert ()) then ; // already exist - OK
            "Item Journal Batch Name" := ItemJnlBatch.Name; // Non-persitent storage
          end;
          ItemJnlLine.FilterGroup := 2;
          ItemJnlLine.SetRange ("Journal Template Name", "Item Journal Template Name");
          ItemJnlLine.SetRange ("Journal Batch Name", "Item Journal Batch Name");
          ItemJnlLine.FilterGroup := 0;

          ItemJnlLine."Journal Template Name" := "Item Journal Template Name";
          ItemJnlLine."Journal Batch Name" := "Item Journal Batch Name";
          ItemJnlLine.SetUpNewLine (ItemJnlLine);

          // check if empty
          if ((WithCheck) and (ItemJnlLine.FindFirst ())) then
            Error (Text002, ItemJnlBatch.TableCaption, "Item Journal Template Name", "Item Journal Batch Name");
        end;
        //+NPR4.16
    end;

    procedure CreateItemJnlLine(StockTakeWorksheet: Record "Stock-Take Worksheet";FilterType: Option;CountingMethod: Option;ItemJnlLine: Record "Item Journal Line";var tmpWorksheetLine: Record "Stock-Take Worksheet Line" temporary;PostingDate: Date)
    var
        StockTakeConfig: Record "Stock-Take Configuration";
        Item: Record Item;
        CalcQtyOnHand: Report "Retail Calculate Inventory";
        ItemsNotOnInventory: Boolean;
        tmpAdjmtWorksheetLine: Record "Stock-Take Worksheet Line" temporary;
        tmpCompressedWorksheet: Record "Stock-Take Worksheet Line" temporary;
        ItemJnlLineCopy: Record "Item Ledger Entry";
        LineNo: Integer;
    begin
        //-NPR4.16
        StockTakeConfig.Get (StockTakeWorksheet."Stock-Take Config Code");

        if (StockTakeConfig."Adjustment Method" = StockTakeConfig."Adjustment Method"::STOCKTAKE) then begin
          if (CountingMethod <> StockTakeConfig."Counting Method"::PARTIAL) then begin

            SetProgressPhase (Dialog005);
            SetItemFilter (StockTakeWorksheet, FilterType, Item);

            // run std report with filters
            ItemsNotOnInventory := (StockTakeConfig."Counting Method" = StockTakeConfig."Counting Method"::COMPLETE_ALL);
            Clear (CalcQtyOnHand);
            CalcQtyOnHand.SetTableView (Item);
            CalcQtyOnHand.SetItemJnlLine (ItemJnlLine);
            CalcQtyOnHand.UseRequestPage (false);
            CalcQtyOnHand.NPR_SetReportOptions (ItemsNotOnInventory, PostingDate, false);
            CalcQtyOnHand.Run ();

            if (ItemJnlLine.IsEmpty ()) then
              Error (Text006, StockTakeConfig.FieldCaption ("Counting Method"));
          end;

          // In partial / Ad-Hoc mode, we add the items one-by-one which is a lot slower
          if (CountingMethod = StockTakeConfig."Counting Method"::PARTIAL) then begin
            CreateAdhocStockTakeLine (StockTakeConfig.Code, ItemJnlLine, tmpWorksheetLine, PostingDate);
          end;
        end;


        if ((StockTakeConfig."Adjustment Method" = StockTakeConfig."Adjustment Method"::ADJUSTMENT) or
            (StockTakeConfig."Adjustment Method" = StockTakeConfig."Adjustment Method"::PURCHASE)) then begin

          StockTakeWorksheet.CalcFields ("Conf Location Code");

          SetProgressPhase (Dialog005);
          tmpAdjmtWorksheetLine.DeleteAll ();

          tmpAdjmtWorksheetLine.Init ();
          tmpAdjmtWorksheetLine."Stock-Take Config Code" := StockTakeWorksheet."Stock-Take Config Code";
          tmpAdjmtWorksheetLine."Worksheet Name" := '';

           // In partial / Ad-Hoc mode, we add the items one-by-one which is a lot slower
          if (CountingMethod = StockTakeConfig."Counting Method"::PARTIAL) then begin

            tmpWorksheetLine.FindSet ();
            repeat
              tmpCompressedWorksheet.SetFilter ("Item No.", '=%1', tmpWorksheetLine."Item No.");
              tmpCompressedWorksheet.SetFilter ("Variant Code", '=%1', tmpWorksheetLine."Variant Code");

              // Compress - get rid of duplicate entries in worksheet lines
              if (tmpCompressedWorksheet.IsEmpty) then begin
                tmpCompressedWorksheet.TransferFields (tmpWorksheetLine, true);
                tmpCompressedWorksheet.CalcFields ("Qty. (Total Counted)");
                // tmpCompressedWorksheet."Qty. (Counted)" := tmpCompressedWorksheet."Qty. (Total Counted)";
                tmpCompressedWorksheet."Line No." := LineNo;
                tmpCompressedWorksheet."Session Name" := Text011;
                LineNo += 100;
                tmpCompressedWorksheet.Insert ();
              end;
            until (tmpWorksheetLine.Next () = 0);

            tmpCompressedWorksheet.Reset;
            tmpCompressedWorksheet.FindSet ();

            Item.Reset ();
            Item.SetFilter ("Location Filter", '=%1', StockTakeConfig."Location Code");
            Item.SetFilter ("Date Filter", '..%1', StockTakeConfig."Inventory Calc. Date");
            Item.SetFilter (Blocked, '=%1', false);

            // Calc inventory for each line
            repeat
              Item.SetFilter ("No.", '=%1', tmpCompressedWorksheet."Item No.");
              Item.SetFilter ("Variant Filter", '=%1', tmpCompressedWorksheet."Variant Code");
              GetItemInventory (Item, tmpAdjmtWorksheetLine, CountingMethod);
            until (tmpCompressedWorksheet.Next () = 0);

            CreateAdhocItemJnlLine (StockTakeConfig.Code, ItemJnlLine, tmpAdjmtWorksheetLine, PostingDate, true, false);

          end else begin
            // fill up a new local tmpWorksheet line using the filters from Stock Take worksheet
            // Location Code, Item, Variant, Qty
            SetItemFilter (StockTakeWorksheet, FilterType, Item);

            GetItemInventory (Item, tmpAdjmtWorksheetLine, CountingMethod);
            CreateAdhocItemJnlLine (StockTakeConfig.Code, ItemJnlLine, tmpAdjmtWorksheetLine, PostingDate, true, true);
          end;

        end;
        //+NPR4.16
    end;

    procedure CreateAdhocStockTakeLine(StockTakeConfigCode: Code[20];ItemJnlLine: Record "Item Journal Line";var tmpWorksheetLine: Record "Stock-Take Worksheet Line" temporary;PostingDate: Date)
    var
        StockTakeConfig: Record "Stock-Take Configuration";
        CalcQtyOnHand: Report "Retail Calculate Inventory";
        Item: Record Item;
        ItemJnlLineCopy: Record "Item Journal Line";
        PrevItemNo: Code[20];
        PrevVariantCode: Code[20];
        NextItemVariant: Boolean;
        StockTakeWorksheet: Record "Stock-Take Worksheet";
    begin
        //-NPR4.16
        SetProgressPhase (Dialog005);
        StockTakeConfig.Get (StockTakeConfigCode);

        //NPR4.21 Reset should be before setcurrentkey
        tmpWorksheetLine.Reset ();
        tmpWorksheetLine.SetCurrentKey ("Item No.", "Variant Code");
        tmpWorksheetLine.FindSet ();

        ProgressBarMax := tmpWorksheetLine.Count ();
        ProgressBarIndex := 0;
        repeat

          NextItemVariant := (not ((tmpWorksheetLine."Item No." = PrevItemNo) and
                                   (tmpWorksheetLine."Variant Code" = PrevVariantCode)));

          if (NextItemVariant) then begin

            StockTakeWorksheet.Get (tmpWorksheetLine."Stock-Take Config Code", tmpWorksheetLine."Worksheet Name");

            // run std report with filters
            Item.Reset ();
            Item.SetFilter ("No.", '=%1', tmpWorksheetLine."Item No.");
            Item.SetFilter ("Variant Filter", '=%1', tmpWorksheetLine."Variant Code");
            Item.SetFilter ("Location Filter", '=%1', StockTakeConfig."Location Code");
            Item.SetFilter ("Date Filter", '..%1', StockTakeConfig."Inventory Calc. Date");
            Item.SetFilter (Blocked, '=%1', false);

            CalcQtyOnHand.SetTableView (Item);
            CalcQtyOnHand.SetItemJnlLine (ItemJnlLine);
            CalcQtyOnHand.UseRequestPage (false);
            CalcQtyOnHand.NPR_SetReportOptions (true, PostingDate, true);
            CalcQtyOnHand.Run ();
            Clear (CalcQtyOnHand);
          end;

          PrevItemNo := tmpWorksheetLine."Item No.";
          PrevVariantCode := tmpWorksheetLine."Variant Code";

          SetProgressPhaseProgress (ProgressBarMax, ProgressBarIndex);
          ProgressBarIndex += 1;

        until (tmpWorksheetLine.Next () = 0);
        //+NPR4.16
    end;

    procedure CreateAdhocItemJnlLine(StockTakeConfigCode: Code[20];ItemJnlLine: Record "Item Journal Line";var tmpWorksheetLine: Record "Stock-Take Worksheet Line" temporary;PostingDate: Date;WithCompress: Boolean;Distinct: Boolean)
    var
        StockTakeConfig: Record "Stock-Take Configuration";
        LineNo: Integer;
        tmpAggrWorksheetLine: Record "Stock-Take Worksheet Line" temporary;
        ItemJnlLineCopy: Record "Item Journal Line";
    begin
        //-NPR4.16
        StockTakeConfig.Get (StockTakeConfigCode);
        SetProgressPhase (Dialog001);

        ProgressBarMax := tmpWorksheetLine.Count ();
        ProgressBarIndex := 0;

        if (WithCompress) then begin
          tmpAggrWorksheetLine.SetCurrentKey ("Item No.", "Variant Code");

          if (tmpWorksheetLine.FindSet ()) then begin
            repeat
              tmpAggrWorksheetLine.SetFilter ("Item No.", '=%1', tmpWorksheetLine."Item No.");
              tmpAggrWorksheetLine.SetFilter ("Variant Code", '=%1', tmpWorksheetLine."Variant Code");

              // Aggregate
              if (tmpAggrWorksheetLine.FindFirst ()) then begin
                if (tmpAggrWorksheetLine."Unit Cost" <> tmpWorksheetLine."Unit Cost") then
                  Error (Text019, tmpWorksheetLine.FieldCaption ("Unit Cost"),tmpWorksheetLine."Item No.",tmpWorksheetLine."Variant Code" );
                if (Distinct = false) then
                  tmpAggrWorksheetLine."Qty. (Counted)" += tmpWorksheetLine."Qty. (Counted)";
                tmpAggrWorksheetLine."Transfer State" := tmpWorksheetLine."Transfer State"::READY;
                tmpAggrWorksheetLine.Modify ();
              end else begin
                tmpAggrWorksheetLine.TransferFields (tmpWorksheetLine, true);
                tmpAggrWorksheetLine."Line No." := LineNo;
                tmpAggrWorksheetLine."Session Name" := Text011;
                LineNo += 100;
                tmpAggrWorksheetLine.Insert ();
              end;

              SetProgressPhaseProgress (ProgressBarMax, ProgressBarIndex);
              ProgressBarIndex += 1;

            until (tmpWorksheetLine.Next () = 0);

            // swap to compressed table
            tmpWorksheetLine.Reset ();
            tmpWorksheetLine.DeleteAll ();

            tmpAggrWorksheetLine.Reset ();
            tmpAggrWorksheetLine.FindSet ();
            repeat
              tmpWorksheetLine.TransferFields (tmpAggrWorksheetLine, true);
              tmpWorksheetLine.Insert ();
            until (tmpAggrWorksheetLine.Next () = 0);
          end;
        end;

        SetProgressPhase ("Dialog005-2");
        ProgressBarMax := tmpWorksheetLine.Count ();
        ProgressBarIndex := 0;

        if (tmpWorksheetLine.FindSet ()) then begin

          LineNo := 0;
          ItemJnlLineCopy.CopyFilters (ItemJnlLine);
          if (ItemJnlLineCopy.FindLast ()) then
            LineNo := ItemJnlLineCopy."Line No.";

          repeat
            LineNo += 100;

            ItemJnlLine."Line No." := LineNo;

            ItemJnlLine.Validate ("Entry Type", ItemJnlLine."Entry Type"::"Positive Adjmt.");
            if ((StockTakeConfig."Adjustment Method" = StockTakeConfig."Adjustment Method"::PURCHASE)) then
              ItemJnlLine.Validate ("Entry Type", ItemJnlLine."Entry Type"::Purchase);

            ItemJnlLine.Validate ("Posting Date", PostingDate);
            ItemJnlLine.Validate ("Item No.", tmpWorksheetLine."Item No.");
            ItemJnlLine.Validate ("Variant Code", tmpWorksheetLine."Variant Code");

            ItemJnlLine.Validate ("Location Code", StockTakeConfig."Location Code");
            ItemJnlLine.Validate (Quantity, tmpWorksheetLine."Qty. (Counted)");

            ItemJnlLine.Insert ();

            SetProgressPhaseProgress (ProgressBarMax, ProgressBarIndex);
            ProgressBarIndex += 1;

          until (tmpWorksheetLine.Next () = 0);
        end;
        //+NPR4.16
    end;

    procedure GetItemInventory(var Item: Record Item;var tmpAdjmtWorksheetLine: Record "Stock-Take Worksheet Line" temporary;CountingMethod: Option)
    var
        LineNo: Integer;
        ItemVariant: Record "Item Variant";
        StockTakeConfig: Record "Stock-Take Configuration";
    begin
        //-NPR4.16

        LineNo := 100;
        if (tmpAdjmtWorksheetLine.FindLast ()) then
          LineNo += tmpAdjmtWorksheetLine."Line No.";

        if (Item.FindSet ()) then begin
          ProgressBarMax := Item.Count ();
          ProgressBarIndex := 0;
          repeat
            tmpAdjmtWorksheetLine.Init ();
            tmpAdjmtWorksheetLine."Line No." := LineNo;
            tmpAdjmtWorksheetLine."Item No." := Item."No.";

            ItemVariant.Reset ();
            ItemVariant.SetFilter ("Item No.", '=%1', Item."No.");
            if (Item.GetFilter ("Variant Filter") <> '=''''') then
              ItemVariant.SetFilter (Code, Item.GetFilter ("Variant Filter"));

            if (ItemVariant.FindSet ()) then begin
              repeat
                tmpAdjmtWorksheetLine."Line No." := LineNo;
                tmpAdjmtWorksheetLine."Variant Code" := ItemVariant.Code;
                Item.SetFilter ("Variant Filter", '=%1', ItemVariant.Code);
                //-NPR5.28 [237925]
                //Item.CALCFIELDS (Inventory);
                //tmpAdjmtWorksheetLine."Qty. (Counted)" := Item.Inventory;
                Item.CalcFields ("Net Change");
                tmpAdjmtWorksheetLine."Qty. (Counted)" := Item."Net Change";
                //+NPR5.28 [237925]
                if ((tmpAdjmtWorksheetLine."Qty. (Counted)" = 0) and
                    (CountingMethod = StockTakeConfig."Counting Method"::COMPLETE_NONZERO)) then begin
                  // no insert!
                end else begin
                  tmpAdjmtWorksheetLine.Insert;
                  LineNo += 100;
                end;
              until (ItemVariant.Next () = 0);
            end else begin
              Item.SetFilter ("Variant Filter", '=%1', '');
              //-NPR5.28 [237925]
              //Item.CALCFIELDS (Inventory);
              //tmpAdjmtWorksheetLine."Qty. (Counted)" := Item.Inventory;
              Item.CalcFields ("Net Change");
              tmpAdjmtWorksheetLine."Qty. (Counted)" := Item."Net Change";
              //+NPR5.28 [237925]
              if ((tmpAdjmtWorksheetLine."Qty. (Counted)" = 0) and
                  (CountingMethod = StockTakeConfig."Counting Method"::COMPLETE_NONZERO)) then begin
                // no insert!
              end else begin
                tmpAdjmtWorksheetLine.Insert;
                LineNo += 100;
              end;
            end;

            SetProgressPhaseProgress (ProgressBarMax, ProgressBarIndex);
            ProgressBarIndex += 1;

           until (Item.Next () = 0);
        end;
        //+NPR4.16
    end;

    procedure SetItemFilter(StockTakeWorksheet: Record "Stock-Take Worksheet";FilterType: Option JOURNAL,BATCH,BOTH;var Item: Record Item)
    var
        StockTakeConfig: Record "Stock-Take Configuration";
        FilterString: array [5] of Text[200];
    begin
        //-NPR4.16
        StockTakeConfig.Get (StockTakeWorksheet."Stock-Take Config Code");

        Item.Reset ();
        Clear (FilterString);

        if (FilterType = FilterType::JOURNAL) then begin
          GetConfigurationFilterValues (StockTakeWorksheet, FilterString);
        end;

        if (FilterType = FilterType::BATCH) then begin
          GetWorksheetFilterValues (StockTakeWorksheet, FilterString);
        end;

        if (FilterType = FilterType::BOTH) then begin
          GetConfigurationFilterValues (StockTakeWorksheet, FilterString);
          GetWorksheetFilterValues (StockTakeWorksheet, FilterString);
        end;

        if (FilterString[1] <> '') then
          Item.SetFilter ("Item Group", FilterString[1]);
        if (FilterString[2] <> '') then
          Item.SetFilter ("Vendor No.", FilterString[2]);
        if (FilterString[3] <> '') then
          Item.SetFilter ("Global Dimension 1 Code", FilterString[3]);
        if (FilterString[4] <> '') then
          Item.SetFilter ("Global Dimension 2 Code", FilterString[4]);

        Item.SetFilter ("Location Filter", '=%1', StockTakeConfig."Location Code");
        Item.SetFilter ("Date Filter", '..%1', StockTakeConfig."Inventory Calc. Date");
        Item.SetFilter (Blocked, '=%1', false);
        //+NPR4.16
    end;

    procedure GetConfigurationFilterValues(StockTakeWorksheet: Record "Stock-Take Worksheet";var FilterString: array [5] of Text[200])
    var
        StockTakeConfig: Record "Stock-Take Configuration";
    begin
        //-NPR4.16
        StockTakeConfig.Get (StockTakeWorksheet."Stock-Take Config Code");
        with StockTakeConfig do begin
          AppendAndFilter (FilterString[1], "Item Group Filter");
          AppendAndFilter (FilterString[2], "Vendor Code Filter");
          AppendAndFilter (FilterString[3], "Global Dimension 1 Code");
          AppendAndFilter (FilterString[4], "Global Dimension 2 Code");
        end;
        //+NPR4.16
    end;

    procedure GetWorksheetFilterValues(StockTakeWorksheet: Record "Stock-Take Worksheet";var FilterString: array [5] of Text[200])
    begin
        //-NPR4.16
        with StockTakeWorksheet do begin
          AppendAndFilter (FilterString[1], "Item Group Filter");
          AppendAndFilter (FilterString[2], "Vendor Code Filter");
          AppendAndFilter (FilterString[3], "Global Dimension 1 Code Filter");
          AppendAndFilter (FilterString[4], "Global Dimension 2 Code Filter");
        end;
        //+NPR4.16
    end;

    procedure AppendAndFilter(var FilterString: Text[200];FilterValue: Text[200])
    begin
        //-NPR4.16
        if (FilterString = '') then
          FilterString := FilterValue
        else if (FilterValue <> '') then
          FilterString := StrSubstNo ('(%1)&(%2)', FilterString, FilterValue);
        //+NPR4.16
    end;

    procedure SetProgressPhase(dialogText: Text[1024])
    begin
        //-NPR4.16
        if (GuiAllowed) then begin
          NPRDialog.Update (1, dialogText);
          NPRDialog.Update (2, 0);
        end;
        //+NPR4.16
    end;

    procedure SetProgressPhaseProgress(progressMax: Integer;progressIndex: Integer)
    var
        progressBase: Integer;
    begin
        //-NPR4.16
        if (GuiAllowed) then begin
          progressBase := 1;
          if (progressMax > 100) then
            progressBase := Round (progressMax / 100, 1, '<');

          if (progressIndex mod progressBase = 0) then
            NPRDialog.Update (2, Round (progressIndex/progressMax*10000,1));
        end;
        //+NPR4.16
    end;

    procedure CreateDefaultTemplates()
    var
        StockTakeTemplate: Record "Stock-Take Template";
        ItemJnlTemplate: Record "Item Journal Template";
        ItemJnlBatch: Record "Item Journal Batch";
    begin

        if (not Confirm (Text014, false)) then Error ('');

        ItemJnlTemplate.SetFilter (Type, '=%1', ItemJnlTemplate.Type::"Phys. Inventory");
        if (not (ItemJnlTemplate.FindFirst ())) then
          Error (Text022, ItemJnlTemplate.TableCaption(), ItemJnlTemplate.Type::"Phys. Inventory");

        ItemJnlBatch.SetRange ("Journal Template Name", ItemJnlTemplate.Name);
        if (not (ItemJnlBatch.FindFirst ())) then
          Error (Text022, ItemJnlBatch.TableCaption(), ItemJnlTemplate.Name);

        //-NPR5.29 [257297] - Changes to default templates
        with StockTakeTemplate do begin
          Code := 'ANNUAL';
          if (Get (Code)) then Delete;
          Init;

          // General Setting
          Description := CopyStr ("Profile-STD300", 1, MaxStrLen (Description));
          "Stock Take Method" := "Stock Take Method"::AREA;
          "Adjustment Method" := "Adjustment Method"::STOCKTAKE;
          "Counting Method" := "Counting Method"::COMPLETE_ALL;
          "Suggested Unit Cost Source" := "Suggested Unit Cost Source"::UNIT_COST;
          "Transfer Action" := "Transfer Action"::TRANSFER;
          "Aggregation Level" := "Aggregation Level"::NATIVE;
          "Session Based Loading" := "Session Based Loading"::APPEND;
          "Session Based Transfer" := "Session Based Transfer"::ALL_WORKSHEETS;
          "Data Release" := "Data Release"::MANUAL;
          "Defaul Profile" := true;
          "Allow User Modification" := true;
          "Allow Unit Cost Change" := true;

          // Scope
          "Location Code" := '';
          "Vendor Code Filter" := '';
          "Item Group Filter" := '*';

          // Transfer
          "Item Journal Template Name" := ItemJnlBatch."Journal Template Name";
          "Item Journal Batch Name" := ItemJnlBatch.Name;
          "Item Journal Batch Usage" := "Item Journal Batch Usage"::DIRECT;
          "Items Out-of-Scope" := "Items Out-of-Scope"::IGNORE;
          "Suppress Not Counted" := false;
          "Items in Scope Not Counted" := "Items in Scope Not Counted"::ADJUST_SET_ZERO;
          "Barcode Not Accepted" := "Barcode Not Accepted"::IGNORE;
          "Blocked Item" := "Blocked Item"::ERROR;
          Insert ();
        end;

        with StockTakeTemplate do begin
          Code := 'ITEMGROUP';
          if (Get (Code)) then Delete;
          Init;

          // General Setting
          Description := CopyStr ("Profile-STD301", 1, MaxStrLen (Description));;
          "Stock Take Method" := "Stock Take Method"::AREA;
          "Adjustment Method" := "Adjustment Method"::STOCKTAKE;
          "Counting Method" := "Counting Method"::PARTIAL;
          "Suggested Unit Cost Source" := "Suggested Unit Cost Source"::UNIT_COST;
          "Transfer Action" := "Transfer Action"::TRANSFER;
          "Aggregation Level" := "Aggregation Level"::NATIVE;
          "Session Based Loading" := "Session Based Loading"::APPEND;
          "Session Based Transfer" := "Session Based Transfer"::SELECTED_LINES;
          "Data Release" := "Data Release"::MANUAL;
          "Defaul Profile" := false;
          "Allow User Modification" := true;
          "Allow Unit Cost Change" := true;

          // Scope
          "Location Code" := '';
          "Vendor Code Filter" := '';
          "Item Group Filter" := '<enter item grp filter>';

          // Transfer
          "Item Journal Template Name" := ItemJnlBatch."Journal Template Name";
          "Item Journal Batch Name" := ItemJnlBatch.Name;
          "Item Journal Batch Usage" := "Item Journal Batch Usage"::DIRECT;
          "Items Out-of-Scope" := "Items Out-of-Scope"::IGNORE;
          "Suppress Not Counted" := false;
          "Items in Scope Not Counted" := "Items in Scope Not Counted"::ADJUST_SET_ZERO;
          "Barcode Not Accepted" := "Barcode Not Accepted"::IGNORE;
          "Blocked Item" := "Blocked Item"::ERROR;
          Insert ();
        end;

        with StockTakeTemplate do begin
          Code := 'VENDOR';
          if (Get (Code)) then Delete;
          Init;

          // General Setting
          Description := CopyStr ("Profile-STD302", 1, MaxStrLen (Description));;
          "Stock Take Method" := "Stock Take Method"::PRODUCT;
          "Adjustment Method" := "Adjustment Method"::STOCKTAKE;
          "Counting Method" := "Counting Method"::PARTIAL;
          "Suggested Unit Cost Source" := "Suggested Unit Cost Source"::UNIT_COST;
          "Transfer Action" := "Transfer Action"::TRANSFER;
          "Aggregation Level" := "Aggregation Level"::NATIVE;
          "Session Based Loading" := "Session Based Loading"::APPEND;
          "Session Based Transfer" := "Session Based Transfer"::SELECTED_LINES;
          "Data Release" := "Data Release"::MANUAL;
          "Defaul Profile" := false;
          "Allow User Modification" := true;
          "Allow Unit Cost Change" := true;

          // Scope
          "Location Code" := '';
          "Vendor Code Filter" := '<enter vendor filter>';
          "Item Group Filter" := '';

          // Transfer
          "Item Journal Template Name" := ItemJnlBatch."Journal Template Name";
          "Item Journal Batch Name" := ItemJnlBatch.Name;
          "Item Journal Batch Usage" := "Item Journal Batch Usage"::DIRECT;
          "Items Out-of-Scope" := "Items Out-of-Scope"::IGNORE;
          "Suppress Not Counted" := false;
          "Items in Scope Not Counted" := "Items in Scope Not Counted"::ADJUST_SET_ZERO;
          "Barcode Not Accepted" := "Barcode Not Accepted"::IGNORE;
          "Blocked Item" := "Blocked Item"::ERROR;
          Insert ();
        end;

        //+NPR5.29 [257297] - Changes to default templates
        // // Smaller shop, single or no location code
        // // stock take with several people, organized by area
        // WITH StockTakeTemplate DO BEGIN
        //  Code := 'STD-001';
        //  IF (GET (Code)) THEN DELETE;
        //  INIT;
        //
        //  Description := "Profile-STD001";
        //  "Aggregation Level" := "Aggregation Level"::CONSECUTIVE;
        //  "Allow User Modification" := TRUE;
        //  "Items Out-of-Scope" := "Items Out-of-Scope"::ACCEPT_COUNT;
        //  "Items in Scope Not Counted" := "Items in Scope Not Counted"::ADJUST_IF_NEGATIVE;
        //  "Barcode Not Accepted" := "Barcode Not Accepted"::ERROR;
        //  "Blocked Item" := "Blocked Item"::ERROR;
        //  "Item Journal Template Name" := ItemJnlBatch."Journal Template Name";
        //  "Item Journal Batch Name" := ItemJnlBatch.Name;
        //  INSERT ();
        // END;
        //
        // // Trust me, I am a doctor!
        // WITH StockTakeTemplate DO BEGIN
        //  Code := 'STD-002';
        //  IF (GET (Code)) THEN DELETE;
        //  INIT;
        //
        //  Description := "Profile-STD002";
        //  "Counting Method" := "Counting Method"::COMPLETE_ALL;
        //  "Aggregation Level" := "Aggregation Level"::SCANNED_NUMBER;
        //  "Session Based Transfer" := "Session Based Transfer"::SELECTED_LINES;
        //  "Allow User Modification" := TRUE;
        //  "Items Out-of-Scope" := "Items Out-of-Scope"::ACCEPT_COUNT;
        //  "Items in Scope Not Counted" := "Items in Scope Not Counted"::IGNORE;
        //  "Barcode Not Accepted" := "Barcode Not Accepted"::IGNORE;
        //  "Blocked Item" := "Blocked Item"::IGNORE;
        //  "Item Journal Template Name" := ItemJnlBatch."Journal Template Name";
        //  "Item Journal Batch Name" := ItemJnlBatch.Name;
        //  INSERT ();
        // END;
        //
        // // Regular shop, one or more location codes
        // // stock take with several people, organized by product
        // WITH StockTakeTemplate DO BEGIN
        //  Code := 'STD-101';
        //  IF (GET (Code)) THEN DELETE;
        //  INIT;
        //
        //  Description := "Profile-STD101";
        //  "Stock Take Method" := "Stock Take Method"::PRODUCT;
        //  "Aggregation Level" := "Aggregation Level"::SCANNED_NUMBER;
        //  "Session Based Transfer" := "Session Based Transfer"::SELECTED_LINES;
        //  "Allow User Modification" := TRUE;
        //  "Items Out-of-Scope" := "Items Out-of-Scope"::ACCEPT_COUNT;
        //  "Items in Scope Not Counted" := "Items in Scope Not Counted"::ADJUST_IF_NEGATIVE;
        //  "Barcode Not Accepted" := "Barcode Not Accepted"::ERROR;
        //  "Blocked Item" := "Blocked Item"::ERROR;
        //  "Item Journal Template Name" := ItemJnlBatch."Journal Template Name";
        //  "Item Journal Batch Name" := ItemJnlBatch.Name;
        //  INSERT ();
        // END;
        //
        // // Regular shop, one or more location codes
        // // stock take with several people, organized by product, STRICT!
        // WITH StockTakeTemplate DO BEGIN
        //  Code := 'STD-102';
        //  IF (GET (Code)) THEN DELETE;
        //  INIT;
        //
        //  Description := "Profile-STD102";
        //  "Stock Take Method" := "Stock Take Method"::PRODUCT;
        //  "Aggregation Level" := "Aggregation Level"::SCANNED_NUMBER;
        //  "Session Based Transfer" := "Session Based Transfer"::SELECTED_LINES;
        //  "Allow User Modification" := TRUE;
        //  "Items Out-of-Scope" := "Items Out-of-Scope"::ERROR;
        //  "Items in Scope Not Counted" := "Items in Scope Not Counted"::ADJUST_IF_NEGATIVE;
        //  "Barcode Not Accepted" := "Barcode Not Accepted"::ERROR;
        //  "Blocked Item" := "Blocked Item"::ERROR;
        //  "Item Journal Template Name" := ItemJnlBatch."Journal Template Name";
        //  "Item Journal Batch Name" := ItemJnlBatch.Name;
        //  INSERT ();
        // END;
        //
        //
        // // Regular shop, one or more location codes
        // // stock take with several people, organized by products and dimensions
        // WITH StockTakeTemplate DO BEGIN
        //  Code := 'STD-201';
        //  IF (GET (Code)) THEN DELETE;
        //  INIT;
        //
        //  Description := "Profile-STD201";
        //  "Stock Take Method" := "Stock Take Method"::DIMENSION;
        //  "Aggregation Level" := "Aggregation Level"::SCANNED_NUMBER;
        //  "Session Based Transfer" := "Session Based Transfer"::SELECTED_LINES;
        //  "Allow User Modification" := TRUE;
        //  "Items Out-of-Scope" := "Items Out-of-Scope"::ACCEPT_COUNT;
        //  "Items in Scope Not Counted" := "Items in Scope Not Counted"::ADJUST_IF_NEGATIVE;
        //  "Barcode Not Accepted" := "Barcode Not Accepted"::ERROR;
        //  "Blocked Item" := "Blocked Item"::ERROR;
        //  "Item Journal Template Name" := ItemJnlBatch."Journal Template Name";
        //  "Item Journal Batch Name" := ItemJnlBatch.Name;
        //  INSERT ();
        // END;

        Message (Text016, StockTakeTemplate.TableCaption);
    end;

    procedure RetailPrint(var StockTakeWorksheetLine: Record "Stock-Take Worksheet Line")
    var
        RetailJournalLine: Record "Retail Journal Line";
    begin

        //-NPR5.46 [329899]

        //-NPR5.48 [332846]
        //FillRetailJournalLine (StockTakeWorksheetLine, RetailJournalLine);
        FillRetailJournalLine ('', StockTakeWorksheetLine, RetailJournalLine);
        //+NPR5.48 [332846]


        if (RetailJournalLine.IsEmpty ()) then
          exit;

        Commit;
        PAGE.RunModal(PAGE::"Retail Journal Print", RetailJournalLine);
        RetailJournalLine.DeleteAll;
        //+NPR5.46 [329899]
    end;

    local procedure FillRetailJournalLine(SelectionID: Code[40];var StockTakeWorksheetLine: Record "Stock-Take Worksheet Line";var RetailJournalLine: Record "Retail Journal Line")
    var
        LineCount: Integer;
    begin

        //-NPR5.46 [329899]
        LineCount := StockTakeWorksheetLine.Count();
        if (LineCount = 0) then
          exit;

        //-NPR5.48 [332846]
        //SelectionID := FORMAT (CREATEGUID ());
        if (SelectionID = '') then
          SelectionID := Format (CreateGuid ());
        //+NPR5.48 [332846]

        RetailJournalLine.SelectRetailJournal (SelectionID);

        if (LineCount > 20) then
          RetailJournalLine.UseGUI (LineCount);

        StockTakeWorksheetLine.FindSet ();
        repeat

          RetailJournalLine.InitLine ();
          RetailJournalLine.SetItem (StockTakeWorksheetLine."Item No.", StockTakeWorksheetLine."Variant Code", StockTakeWorksheetLine.Barcode);
          RetailJournalLine."Quantity to Print" := 1;
          RetailJournalLine.Insert ();

        until (StockTakeWorksheetLine.Next() = 0);

        RetailJournalLine.CloseGUI ();
        RetailJournalLine.SetFilter ("No.", '=%1', SelectionID);

        //+NPR5.46 [329899]
    end;

    procedure AreaTopUp(var TopUpToWorksheet: Record "Stock-Take Worksheet")
    var
        TopUpFromWorksheet: Record "Stock-Take Worksheet";
        TopUpResultWorksheet: Record "Stock-Take Worksheet";
        LineLeft: Record "Stock-Take Worksheet Line";
        LineRight: Record "Stock-Take Worksheet Line";
        TmpWorksheetLine: Record "Stock-Take Worksheet Line" temporary;
        WorksheetLine: Record "Stock-Take Worksheet Line";
        RetailJournalHeader: Record "Retail Journal Header";
        RetailJournalLine: Record "Retail Journal Line";
        StockTakeWorksheetsPage: Page "Stock-Take Worksheets";
        PageAction: Action;
        TopUpWorksheetName: Code[10];
    begin

        //-NPR5.48 [332846]
        Commit;

        TopUpToWorksheet.CalcFields ("Conf Stock Take Method");
        TopUpToWorksheet.TestField (TopUpToWorksheet."Conf Stock Take Method", TopUpToWorksheet."Conf Stock Take Method"::AREA);

        TopUpFromWorksheet.SetFilter ("Stock-Take Config Code", '=%1', TopUpToWorksheet."Stock-Take Config Code");
        TopUpFromWorksheet.SetFilter (Name, '<>%1', TopUpToWorksheet.Name);
        if (TopUpFromWorksheet.IsEmpty ()) then
          Error (TopUpFromMissing);

        TopUpFromWorksheet.FindFirst ();

        if (TopUpFromWorksheet.Count () > 1) then begin
          StockTakeWorksheetsPage.SetTableView (TopUpFromWorksheet);
          StockTakeWorksheetsPage.Editable (false);
          StockTakeWorksheetsPage.LookupMode (true);
          PageAction := StockTakeWorksheetsPage.RunModal ();
          if (PageAction = ACTION::LookupOK) then begin
            StockTakeWorksheetsPage.GetRecord (TopUpFromWorksheet);
          end else begin
            exit; // Lookup cancelled
          end;

        end;

        LineLeft.SetFilter ("Stock-Take Config Code", '=%1', TopUpToWorksheet."Stock-Take Config Code");
        LineLeft.SetFilter ("Worksheet Name", '=%1', TopUpToWorksheet.Name);

        LineRight.SetFilter ("Stock-Take Config Code", '=%1', TopUpFromWorksheet."Stock-Take Config Code");
        LineRight.SetFilter ("Worksheet Name", '=%1', TopUpFromWorksheet.Name);

        TopUpWorksheetName := StrSubstNo ('TOPUP-%1', CopyStr (TopUpToWorksheet.Name, 1, 4));
        if (LineRight.FindSet ()) then begin
          WorksheetLine.SetFilter ("Stock-Take Config Code", '=%1', TopUpToWorksheet."Stock-Take Config Code");
          WorksheetLine.SetFilter ("Worksheet Name", '=%1', TopUpWorksheetName);
          if (not WorksheetLine.IsEmpty ()) then
            if (not Confirm (TopUpNotEmpty, true, TopUpWorksheetName)) then
              WorksheetLine.DeleteAll ();

          repeat
            LineLeft.SetFilter ("Item No.", '=%1', LineRight."Item No.");
            LineLeft.SetFilter ("Variant Code", '=%1', LineRight."Variant Code");
            if (LineLeft.IsEmpty ()) then begin

              // Dont insert multiple occurences of same item
              TmpWorksheetLine.SetFilter ("Item No.", '=%1', LineRight."Item No.");
              TmpWorksheetLine.SetFilter ("Variant Code", '=%1', LineRight."Variant Code");
              if (TmpWorksheetLine.IsEmpty ()) then begin
                TmpWorksheetLine.TransferFields (LineRight, true);
                TmpWorksheetLine."Worksheet Name" := TopUpWorksheetName;
                TmpWorksheetLine."Qty. (Counted)" := 1;
                TmpWorksheetLine.Insert ();
              end;

            end;
          until (LineRight.Next () = 0);
        end;

        TmpWorksheetLine.Reset ();
        if (TmpWorksheetLine.IsEmpty ()) then
          exit;

        TmpWorksheetLine.FindSet ();
        repeat
          WorksheetLine.TransferFields (TmpWorksheetLine, true);
          if (not WorksheetLine.Insert ()) then ;
        until (TmpWorksheetLine.Next () = 0);

        if (not TopUpResultWorksheet.Get (TopUpToWorksheet."Stock-Take Config Code", TopUpWorksheetName)) then begin
          TopUpResultWorksheet.TransferFields (TopUpToWorksheet, true);
          TopUpResultWorksheet.Name := TopUpWorksheetName;
          TopUpResultWorksheet.Insert ();
        end;

        //-NPR5.48 [332846]
        TopUpResultWorksheet."Topup Worksheet" := true;
        //+NPR5.48 [332846]
        TopUpResultWorksheet.Description := StrSubstNo (TopUpDesc, TopUpFromWorksheet.Name, TopUpToWorksheet.Name);
        TopUpResultWorksheet.Modify ();

        Message (TopUpCreated, TopUpWorksheetName);

        //
        // RetailJournalHeader.INIT ();
        // RetailJournalHeader.INSERT (TRUE);
        // FillRetailJournalLine (RetailJournalHeader."No.", TmpWorksheetLine, RetailJournalLine);
        //
        // IF (RetailJournalLine.ISEMPTY ()) THEN
        //  EXIT;
        //
        // COMMIT;
        // PAGE.RUNMODAL(PAGE::"Retail Journal Print", RetailJournalLine);
    end;
}

