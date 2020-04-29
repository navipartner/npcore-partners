codeunit 6059981 "Item Repair"
{
    // VRT1.20/JDH /20170106 CASE 251896 TestTool to analyse and fix Variants
    // NPR5.29/TJ  /20170119 CASE 263917 Changed how function GetFromVariety is called in function DoAction


    trigger OnRun()
    begin
        if Confirm('Delete Test Data before start', false) then
          DeleteTestData;

        if Confirm('Insert Entries', false) then
          InsertLine;

        if Confirm('Analyse Entries', false) then
          TestAllRepairEntries;

        if Confirm('Suggest Actions', false) then
          SuggestAllActions;
    end;

    var
        NoOfRecords: Integer;
        LineCount: Integer;
        Dia: Dialog;

    procedure InsertLine()
    var
        ItemVar: Record "Item Variant";
        Item: Record Item;
    begin
        LineCount := 0;
        NoOfRecords := ItemVar.Count;
        Dia.Open('Inserting Entries @1@@@@@@@@@');
        if ItemVar.FindSet then repeat
          LineCount += 1;
          Dia.Update(1, Round(LineCount / NoOfRecords * 10000,1));
          if Item."No." <> ItemVar."Item No." then
            if not Item.Get(ItemVar."Item No.") then
              Clear(Item);
          InsertRepairEntry(ItemVar, Item);
        until ItemVar.Next = 0;
        Dia.Close;
    end;

    local procedure InsertRepairEntry(ItemVar: Record "Item Variant";Item: Record Item)
    var
        ItemRepair: Record "Item Repair";
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        with ItemRepair do begin
          if Get(ItemVar."Item No.", ItemVar.Code) then
            exit;
          Init;
          "Item No." := ItemVar."Item No.";
          "Variant Code" := ItemVar.Code;
          Description := Item.Description;
          "Variety 1 (Item)" := Item."Variety 1";
          "Variety 1 Table (Item)" := Item."Variety 1 Table";
          "Variety 2 (Item)" := Item."Variety 2";
          "Variety 2 Table (Item)" := Item."Variety 2 Table";
          "Variety 3 (Item)" := Item."Variety 3";
          "Variety 3 Table (Item)" := Item."Variety 3 Table";
          "Variety 4 (Item)" := Item."Variety 4";
          "Variety 4 Table (Item)" := Item."Variety 4 Table";
          "Cross Variety No." := Item."Cross Variety No.";
          "Variety Group" := Item."Variety Group";
          "Variety 1 (Var)" := ItemVar."Variety 1";
          "Variety 1 Table (Var)" := ItemVar."Variety 1 Table";
          "Variety 1 Value (Var)" := ItemVar."Variety 1 Value";
          "Variety 2 (Var)" := ItemVar."Variety 2";
          "Variety 2 Table (Var)" := ItemVar."Variety 2 Table";
          "Variety 2 Value (Var)" := ItemVar."Variety 2 Value";
          "Variety 3 (Var)" := ItemVar."Variety 3";
          "Variety 3 Table (Var)" := ItemVar."Variety 3 Table";
          "Variety 3 Value (Var)" := ItemVar."Variety 3 Value";
          "Variety 4 (Var)" := ItemVar."Variety 4";
          "Variety 4 Table (Var)" := ItemVar."Variety 4 Table";
          "Variety 4 Value (Var)" := ItemVar."Variety 4 Value";
          "Variety 1 Used" := ("Variety 1 (Item)" <> '') or ("Variety 1 (Var)" <> '') or ("Variety 1 Table (Item)" <> '') or ("Variety 1 Table (Var)" <> '') or ("Variety 1 Value (Var)" <> '');
          "Variety 2 Used" := ("Variety 2 (Item)" <> '') or ("Variety 2 (Var)" <> '') or ("Variety 2 Table (Item)" <> '') or ("Variety 2 Table (Var)" <> '') or ("Variety 2 Value (Var)" <> '');
          "Variety 3 Used" := ("Variety 3 (Item)" <> '') or ("Variety 3 (Var)" <> '') or ("Variety 3 Table (Item)" <> '') or ("Variety 3 Table (Var)" <> '') or ("Variety 3 Value (Var)" <> '');
          "Variety 4 Used" := ("Variety 4 (Item)" <> '') or ("Variety 4 (Var)" <> '') or ("Variety 4 Table (Item)" <> '') or ("Variety 4 Table (Var)" <> '') or ("Variety 4 Value (Var)" <> '');
          "Blocked (Var)" := ItemVar.Blocked;
          ItemLedgEntry.SetCurrentKey("Item No.",Open,"Variant Code",Positive,"Location Code","Posting Date");
          ItemLedgEntry.SetRange("Item No.", "Item No.");
          ItemLedgEntry.SetRange("Variant Code", "Variant Code");
          "Item Ledger Entry Exist" := not ItemLedgEntry.IsEmpty;
          Insert;
        end;
    end;

    procedure TestAllRepairEntries()
    var
        ItemRepair: Record "Item Repair";
    begin
        LineCount := 0;
        Dia.Open('Analysing Entries @1@@@@@@@@@');
        NoOfRecords := ItemRepair.Count;
        if ItemRepair.FindFirst then repeat
          LineCount += 1;
          Dia.Update(1, Round(LineCount / NoOfRecords * 10000,1));
          TestRepairEntry(ItemRepair);
        until ItemRepair.Next = 0;
        Dia.Close;
    end;

    procedure TestSelectedRepairEntries(var ItemRepair: Record "Item Repair")
    begin
        LineCount := 0;
        Dia.Open('Analysing Entries @1@@@@@@@@@');
        NoOfRecords := ItemRepair.Count;
        if ItemRepair.FindFirst then repeat
          LineCount += 1;
          Dia.Update(1, Round(LineCount / NoOfRecords * 10000,1));
          TestRepairEntry(ItemRepair);
        until ItemRepair.Next = 0;
        Dia.Close;
    end;

    local procedure TestRepairEntry(ItemRepair: Record "Item Repair")
    var
        Item: Record Item;
        ItemVar: Record "Item Variant";
        ItemExists: Boolean;
        VarExists: Boolean;
        VarietyTable: Record "Variety Table";
        VarietyValue: Record "Variety Value";
    begin
        ItemExists := Item.Get(ItemRepair."Item No.");
        VarExists := ItemVar.Get(ItemRepair."Item No.", ItemRepair."Variant Code");
        InsertTestEntry(ItemRepair, 1, ItemExists, 'Item Exists');
        InsertTestEntry(ItemRepair, 2, VarExists, 'Variant Exists');
        if not ItemExists or not VarExists then
          exit;

        if ItemRepair."Variety 1 Used" then begin
          InsertTestEntry(ItemRepair, 10, Item."Variety 1" = ItemVar."Variety 1" ,'Variety 1 match');
          InsertTestEntry(ItemRepair, 11, Item."Variety 1 Table" = ItemVar."Variety 1 Table" ,'Variety 1 table match');
          InsertTestEntry(ItemRepair, 15, VarietyTable.Get(Item."Variety 1", Item."Variety 1 Table") ,'Variety 1 table exists (Item)');
          InsertTestEntry(ItemRepair, 16, VarietyTable.Get(ItemVar."Variety 1", ItemVar."Variety 1 Table") ,'Variety 1 table exists (Variant)');
          InsertTestEntry(ItemRepair, 17, VarietyValue.Get(ItemVar."Variety 1", ItemVar."Variety 1 Table", ItemVar."Variety 1 Value") ,'Variety 1 Value exists (Variant)');
        end;

        if ItemRepair."Variety 2 Used" then begin
          InsertTestEntry(ItemRepair, 20, Item."Variety 2" = ItemVar."Variety 2" ,'Variety 2 match');
          InsertTestEntry(ItemRepair, 21, Item."Variety 2 Table" = ItemVar."Variety 2 Table" ,'Variety 2 table match');
          InsertTestEntry(ItemRepair, 25, VarietyTable.Get(Item."Variety 2", Item."Variety 2 Table") ,'Variety 2 table exists (Item)');
          InsertTestEntry(ItemRepair, 26, VarietyTable.Get(ItemVar."Variety 2", ItemVar."Variety 2 Table") ,'Variety 2 table exists (Variant)');
          InsertTestEntry(ItemRepair, 27, VarietyValue.Get(ItemVar."Variety 2", ItemVar."Variety 2 Table", ItemVar."Variety 2 Value") ,'Variety 2 Value exists (Variant)');
        end;

        if ItemRepair."Variety 3 Used" then begin
          InsertTestEntry(ItemRepair, 30, Item."Variety 3" = ItemVar."Variety 3" ,'Variety 3 match');
          InsertTestEntry(ItemRepair, 31, Item."Variety 3 Table" = ItemVar."Variety 3 Table" ,'Variety 3 table match');
          InsertTestEntry(ItemRepair, 35, VarietyTable.Get(Item."Variety 3", Item."Variety 3 Table") ,'Variety 3 table exists (Item)');
          InsertTestEntry(ItemRepair, 36, VarietyTable.Get(ItemVar."Variety 3", ItemVar."Variety 3 Table") ,'Variety 3 table exists (Variant)');
          InsertTestEntry(ItemRepair, 37, VarietyValue.Get(ItemVar."Variety 3", ItemVar."Variety 3 Table", ItemVar."Variety 3 Value") ,'Variety 3 Value exists (Variant)');
        end;

        if ItemRepair."Variety 4 Used" then begin
          InsertTestEntry(ItemRepair, 40, Item."Variety 4" = ItemVar."Variety 4" ,'Variety 4 match');
          InsertTestEntry(ItemRepair, 41, Item."Variety 4 Table" = ItemVar."Variety 4 Table" ,'Variety 4 table match');
          InsertTestEntry(ItemRepair, 45, VarietyTable.Get(Item."Variety 4", Item."Variety 4 Table") ,'Variety 4 table exists (Item)');
          InsertTestEntry(ItemRepair, 46, VarietyTable.Get(ItemVar."Variety 4", ItemVar."Variety 4 Table") ,'Variety 4 table exists (Variant)');
          InsertTestEntry(ItemRepair, 47, VarietyValue.Get(ItemVar."Variety 4", ItemVar."Variety 4 Table", ItemVar."Variety 4 Value") ,'Variety 4 Value exists (Variant)');
        end;
    end;

    local procedure InsertTestEntry(var ItemRepair: Record "Item Repair";TestNo: Integer;IsSuccess: Boolean;Desc: Text[50])
    var
        ItemRepairTest: Record "Item Repair Tests";
    begin
        with ItemRepairTest do begin
          Init;
          "Item No." := ItemRepair."Item No.";
          "Variant Code" := ItemRepair."Variant Code";
          "Test No." := TestNo;
          Description := Desc;
          Success := IsSuccess;
          case TestNo of
            1..9:   "Test Group" := 0;
            10..19: "Test Group" := 1;
            20..29: "Test Group" := 2;
            30..39: "Test Group" := 3;
            40..49: "Test Group" := 4;
            else
              "Test Group" := 9;
          end;
          if not Insert then
            Modify;
          if (not Success) and (not ItemRepair."Errors Exists") then begin
            ItemRepair."Errors Exists" := true;
            ItemRepair.Modify;
          end;
        end;
    end;

    procedure DeleteTestData()
    var
        ItemRepairTest: Record "Item Repair Tests";
        ItemRepair: Record "Item Repair";
        ItemRepairAction: Record "Item Repair Action";
    begin
        ItemRepairTest.DeleteAll;
        ItemRepair.DeleteAll;
        ItemRepairAction.DeleteAll;
    end;

    procedure SuggestAllActions()
    var
        ItemRepair: Record "Item Repair";
    begin
        LineCount := 0;
        Dia.Open('Analysing Entries @1@@@@@@@@@');
        ItemRepair.SetRange("Errors Exists", true);
        NoOfRecords := ItemRepair.Count;
        if ItemRepair.FindFirst then repeat
          LineCount += 1;
          Dia.Update(1, Round(LineCount / NoOfRecords * 10000,1));
          SuggestAction(ItemRepair);
        until ItemRepair.Next = 0;
        Dia.Close;
    end;

    procedure SuggestSelectedActions(var ItemRepair: Record "Item Repair")
    begin
        LineCount := 0;
        Dia.Open('Analysing Entries @1@@@@@@@@@');
        NoOfRecords := ItemRepair.Count;
        if ItemRepair.FindFirst then repeat
          LineCount += 1;
          Dia.Update(1, Round(LineCount / NoOfRecords * 10000,1));
          SuggestAction(ItemRepair);
        until ItemRepair.Next = 0;
        Dia.Close;
    end;

    local procedure SuggestAction(ItemRepair: Record "Item Repair")
    var
        ItemRepairTest: Record "Item Repair Tests";
        ItemVarietyCombOK: Boolean;
        VarVarietyCombOK: Boolean;
        Item: Record Item;
        ItemVar: Record "Item Variant";
        VarietyTable: Record "Variety Table";
        VarietyValue: Record "Variety Value";
        ItemRepairActionItem: Record "Item Repair Action";
        ItemRepairActionVariant: Record "Item Repair Action";
        BreakLoop: Boolean;
    begin
        ItemRepairTest.SetRange("Item No.", ItemRepair."Item No.");
        ItemRepairTest.SetRange("Variant Code", ItemRepair."Variant Code");
        ItemRepairTest.SetRange(Success, false);
        if not ItemRepairActionItem.Get(ItemRepair."Item No.", '') then
          Clear(ItemRepairActionItem);

        if ItemRepairTest.FindSet then repeat
          BreakLoop := false;
          case ItemRepairTest."Test No." of
            1://Item Doesnt exists
              begin
                if not ItemRepairActionVariant.Get(ItemRepairTest."Item No.", ItemRepairTest."Variant Code") then begin
                  ItemRepairActionVariant."Item No." := ItemRepairTest."Item No.";
                  ItemRepairActionVariant."Variant Code" := ItemRepairTest."Variant Code";
                end;
                if ItemRepair."Item Ledger Entry Exist" then
                  ItemRepairActionVariant."Variant Action" := ItemRepairActionVariant."Variant Action"::BlockVariant
                else
                  ItemRepairActionVariant."Variant Action" := ItemRepairActionVariant."Variant Action"::DeleteVariant;
                if not ItemRepairActionVariant.Insert then
                  ItemRepairActionVariant.Modify;
              end;
            10..19: //variety 1 is not ok
              begin
                Item.Get(ItemRepair."Item No.");
                ItemVar.Get(ItemRepair."Item No.", ItemRepair."Variant Code");
                //order is: push from variant to item, if this is a valid combination. else push it the other way
                if (ItemVar."Variety 1" <> '') and (ItemVar."Variety 1 Table" <> '') then begin
                  if not VarietyTable.Get(ItemVar."Variety 1", ItemVar."Variety 1 Table") then
                    Clear(VarietyTable);
                  if not VarietyValue.Get(ItemVar."Variety 1", ItemVar."Variety 1 Table", ItemVar."Variety 1 Value") then
                    Clear(VarietyValue);
                  if (VarietyTable.Code <> '') and (VarietyValue.Value <> '') then begin//its a valid combination
                    SetAction(ItemRepairActionItem,ItemRepair."Item No.",1,1, VarietyTable.Type, VarietyTable.Code);
                    BreakLoop := true;
                  end;
                end;

                if not BreakLoop then begin
                  if (Item."Variety 1" <> '') and (Item."Variety 1 Table" <> '') then begin
                    if not VarietyTable.Get(Item."Variety 1", Item."Variety 1 Table") then
                      Clear(VarietyTable);
                    if not VarietyValue.Get(Item."Variety 1", Item."Variety 1 Table", ItemVar."Variety 1 Value") then
                      Clear(VarietyValue);
                    if (VarietyTable.Code <> '') and (VarietyValue.Value <> '') then //its a valid combination
                      SetAction(ItemRepairActionItem,ItemRepair."Item No.",1,2, VarietyTable.Type, VarietyTable.Code);
                  end;
                end;
                //item info could not be used - try with variant info
              end;
              20..29: //variety 2 is not ok
              begin
                Item.Get(ItemRepair."Item No.");
                ItemVar.Get(ItemRepair."Item No.", ItemRepair."Variant Code");
                //order is: push from variant to item, if this is a valid combination. else push it the other way
                if (ItemVar."Variety 2" <> '') and (ItemVar."Variety 2 Table" <> '') then begin
                  if not VarietyTable.Get(ItemVar."Variety 2", ItemVar."Variety 2 Table") then
                    Clear(VarietyTable);
                  if not VarietyValue.Get(ItemVar."Variety 2", ItemVar."Variety 2 Table", ItemVar."Variety 2 Value") then
                    Clear(VarietyValue);
                  if (VarietyTable.Code <> '') and (VarietyValue.Value <> '') then begin //its a valid combination
                    SetAction(ItemRepairActionItem,ItemRepair."Item No.",2,1, VarietyTable.Type, VarietyTable.Code);
                    BreakLoop := true;
                  end;
                end;

                //item info could not be used - try with variant info
                if not BreakLoop then begin
                  if (Item."Variety 2" <> '') and (Item."Variety 2 Table" <> '') then begin
                    if not VarietyTable.Get(Item."Variety 2", Item."Variety 2 Table") then
                      Clear(VarietyTable);
                    if not VarietyValue.Get(Item."Variety 2", Item."Variety 2 Table", ItemVar."Variety 2 Value") then
                      Clear(VarietyValue);
                    if (VarietyTable.Code <> '') and (VarietyValue.Value <> '') then //its a valid combination
                      SetAction(ItemRepairActionItem,ItemRepair."Item No.",2,2, VarietyTable.Type, VarietyTable.Code);

                  end;
                end;
              end;
          end;
        until ItemRepairTest.Next = 0;
    end;

    procedure SetAction(var ItemRepairAction: Record "Item Repair Action";ItemNo: Code[20];VarietyNo: Integer;"Action": Integer;NewVariety: Code[20];NewVarietyTable: Code[20])
    begin
        if ItemRepairAction."Item No." <> ItemNo then
          if not ItemRepairAction.Get(ItemNo,'') then begin
            ItemRepairAction.Init;
            ItemRepairAction."Item No." := ItemNo;
            ItemRepairAction."Variant Code" := '';
          end;

        case VarietyNo of
          1:
            begin
              case true of
                ItemRepairAction."Variety 1 Action" = ItemRepairAction."Variety 1 Action"::None :
                  begin
                    ItemRepairAction."Variety 1 Action" := Action;
                    ItemRepairAction."New Variety 1" := NewVariety;
                    ItemRepairAction."New Variety 1 Table" := NewVarietyTable;
                  end;
                Action = ItemRepairAction."Variety 1 Action":
                  begin
                    if ((NewVariety = ItemRepairAction."New Variety 1") and (NewVarietyTable = ItemRepairAction."New Variety 1 Table")) then
                      exit
                    else
                      ItemRepairAction."Variety 1 Action" := ItemRepairAction."Variety 1 Action"::UseItemSetup; //variety tabel is not the same on the variants
                  end;
                else
                  ItemRepairAction."Variety 1 Action" := ItemRepairAction."Variety 1 Action"::SelectManual;
              end;
            end;
          2:
            begin
              case true of
                ItemRepairAction."Variety 2 Action" = ItemRepairAction."Variety 2 Action"::None :
                  begin
                    ItemRepairAction."Variety 2 Action" := Action;
                    ItemRepairAction."New Variety 2" := NewVariety;
                    ItemRepairAction."New Variety 2 Table" := NewVarietyTable;
                  end;
                Action = ItemRepairAction."Variety 2 Action":
                  begin
                    if ((NewVariety = ItemRepairAction."New Variety 2") and (NewVarietyTable = ItemRepairAction."New Variety 2 Table")) then
                      exit
                    else
                      ItemRepairAction."Variety 2 Action" := ItemRepairAction."Variety 2 Action"::UseItemSetup; //variety tabel is not the same on the variants
                  end;
                else
                  ItemRepairAction."Variety 2 Action" := ItemRepairAction."Variety 2 Action"::SelectManual;
              end;
            end;

          else
            Error('Please implement');
        end;
        if not ItemRepairAction.Insert then
          ItemRepairAction.Modify;
    end;

    procedure ManualSetActionSelected(var ItemRepair: Record "Item Repair";ActionType: Option Item,Variant;ActionVariant: Integer)
    begin
        LineCount := 0;
        Dia.Open('Updating Actions @1@@@@@@@@@');
        NoOfRecords := ItemRepair.Count;
        if ItemRepair.FindFirst then repeat
          LineCount += 1;
          Dia.Update(1, Round(LineCount / NoOfRecords * 10000,1));
          ManualSetAction(ItemRepair, ActionType, ActionVariant);
          Commit;
        until ItemRepair.Next = 0;
        Dia.Close;
    end;

    procedure ManualSetAction(ItemRepair: Record "Item Repair";ActionType: Option Item,Variant;ActionVariant: Integer)
    var
        ItemRepairAction: Record "Item Repair Action";
    begin
        if ActionType = ActionType::Item then begin
          if ItemRepairAction.Get(ItemRepair."Item No.", '') then
            Error('Action already exists');
          ItemRepairAction.Init;
          ItemRepairAction."Item No." := ItemRepair."Item No.";
          ItemRepairAction.Insert;
        end else begin
          if ItemRepairAction.Get(ItemRepair."Item No.", ItemRepair."Variant Code") then
            Error('Action already exists');

          ItemRepairAction.Init;
          ItemRepairAction."Item No." := ItemRepair."Item No.";
          ItemRepairAction."Variant Code" := ItemRepair."Variant Code";
          ItemRepairAction."Variant Action" := ActionVariant;
          ItemRepairAction.Insert;
        end;
    end;

    procedure SetNewVarietyValues(var ItemRepair: Record "Item Repair")
    begin
        LineCount := 0;
        Dia.Open('Setting New Variety Values @1@@@@@@@@@');
        NoOfRecords := ItemRepair.Count;
        if ItemRepair.FindFirst then repeat
          LineCount += 1;
          Dia.Update(1, Round(LineCount / NoOfRecords * 10000,1));
          SetNewVarietyValue(ItemRepair);
          Commit;
        until ItemRepair.Next = 0;
        Dia.Close;
    end;

    procedure SetNewVarietyValue(ItemRepair: Record "Item Repair")
    var
        ItemRepairAction: Record "Item Repair Action";
        DoAction: Boolean;
    begin
        with ItemRepair do begin
          if "Variety 1 Value (Var) (NEW)" <> '' then begin
            TestField("Variety 1 Used");
            TestField("Variety 1 (Item)");
            TestField("Variety 1 Table (Item)");
            DoAction := true;
          end;

          if "Variety 2 Value (Var) (NEW)" <> '' then begin
            TestField("Variety 2 Used");
            TestField("Variety 2 (Item)");
            TestField("Variety 2 Table (Item)");
            DoAction := true;
          end;

          if "Variety 3 Value (Var) (NEW)" <> '' then begin
            TestField("Variety 3 Used");
            TestField("Variety 3 (Item)");
            TestField("Variety 3 Table (Item)");
            DoAction := true;
          end;

          if "Variety 4 Value (Var) (NEW)" <> '' then begin
            TestField("Variety 4 Used");
            TestField("Variety 4 (Item)");
            TestField("Variety 4 Table (Item)");
            DoAction := true;
          end;

          if not DoAction then
            exit;

          if ItemRepairAction.Get("Item No.", "Variant Code") then
            Error('Action already exists for this item. No more actions can be done now');

          ItemRepairAction.Init;
          ItemRepairAction."Item No." := ItemRepair."Item No.";
          ItemRepairAction."Variant Code" := ItemRepair."Variant Code";
          ItemRepairAction."Variant Action" := ItemRepairAction."Variant Action"::UpdateFromItem;
          ItemRepairAction.Insert;

          if "Variety 1 Value (Var) (NEW)" <> '' then begin
            ItemRepairAction."Variety 1 Action" := ItemRepairAction."Variety 1 Action"::UseItemSetup;
            ItemRepairAction."New Variety 1" := ItemRepair."Variety 1 (Item)";
            ItemRepairAction."New Variety 1 Table" := ItemRepair."Variety 1 Table (Item)";
            ItemRepairAction."New Variety 1 Value" := "Variety 1 Value (Var) (NEW)";
          end;

          if "Variety 2 Value (Var) (NEW)" <> '' then begin
            ItemRepairAction."Variety 2 Action" := ItemRepairAction."Variety 2 Action"::UseItemSetup;
            ItemRepairAction."New Variety 2" := ItemRepair."Variety 2 (Item)";
            ItemRepairAction."New Variety 2 Table" := ItemRepair."Variety 2 Table (Item)";
            ItemRepairAction."New Variety 2 Value" := "Variety 2 Value (Var) (NEW)";
          end;

          if "Variety 3 Value (Var) (NEW)" <> '' then begin
            ItemRepairAction."Variety 3 Action" := ItemRepairAction."Variety 3 Action"::UseItemSetup;
            ItemRepairAction."New Variety 3" := ItemRepair."Variety 3 (Item)";
            ItemRepairAction."New Variety 3 Table" := ItemRepair."Variety 3 Table (Item)";
            ItemRepairAction."New Variety 3 Value" := "Variety 3 Value (Var) (NEW)";
          end;

          if "Variety 4 Value (Var) (NEW)" <> '' then begin
            ItemRepairAction."Variety 4 Action" := ItemRepairAction."Variety 2 Action"::UseItemSetup;
            ItemRepairAction."New Variety 4" := ItemRepair."Variety 4 (Item)";
            ItemRepairAction."New Variety 4 Table" := ItemRepair."Variety 4 Table (Item)";
            ItemRepairAction."New Variety 4 Value" := "Variety 4 Value (Var) (NEW)";
          end;

          ItemRepairAction.Modify;
        end;
    end;

    procedure DoAction(ItemRepairAction: Record "Item Repair Action")
    var
        ItemVar: Record "Item Variant";
        ItemVarTest: Record "Item Variant";
        Item: Record Item;
        DoModify: Boolean;
        VarietyCloneData: Codeunit "Variety Clone Data";
    begin
        if ItemRepairAction."Variant Code" = '' then begin
          ItemRepairAction.TestField("Variant Action", ItemRepairAction."Variant Action"::None);
        end else begin
          if ItemRepairAction."Variant Action" <> ItemRepairAction."Variant Action"::UpdateFromItem then begin
            ItemRepairAction.TestField("Variety 1 Action", ItemRepairAction."Variety 1 Action"::None);
            ItemRepairAction.TestField("Variety 2 Action", ItemRepairAction."Variety 2 Action"::None);
            ItemRepairAction.TestField("Variety 3 Action", ItemRepairAction."Variety 3 Action"::None);
            ItemRepairAction.TestField("Variety 4 Action", ItemRepairAction."Variety 4 Action"::None);
          end;
        end;

        if ItemRepairAction."Variant Action" = ItemRepairAction."Variant Action"::BlockVariant then begin
          ItemVar.Get(ItemRepairAction."Item No.",ItemRepairAction."Variant Code");
          InsertLogEntry(ItemVar."Item No.",ItemVar.Code, 'Blocking Variant Item', '', '');
          ItemVar.Blocked := true;
          ItemVar.Modify;
          ItemRepairAction.Delete;
          exit;
        end;

        if ItemRepairAction."Variant Action" = ItemRepairAction."Variant Action"::DeleteVariant then begin
          ItemVar.Get(ItemRepairAction."Item No.",ItemRepairAction."Variant Code");
          InsertLogEntry(ItemVar."Item No.",ItemVar.Code, 'Deleting Variant Item', '', '');
          ItemVar.Delete(true);
          ItemRepairAction.Delete;
          exit;
        end;


        Item.Get(ItemRepairAction."Item No.");
        ItemVar.Reset;
        ItemVar.SetRange("Item No.", ItemRepairAction."Item No.");
        if ItemRepairAction."Variant Code" <> '' then
          ItemVar.SetRange(Code, ItemRepairAction."Variant Code");

        if ItemVar.FindSet then repeat
          DoModify := false;
          if ItemRepairAction."Variety 1 Action" = ItemRepairAction."Variety 1 Action"::UseItemSetup then begin
            if ItemVar."Variety 1" <> ItemRepairAction."New Variety 1" then begin
              InsertLogEntry(ItemVar."Item No.", ItemVar.Code,'Item Variant Updated (Variety 1)', ItemVar."Variety 1", ItemRepairAction."New Variety 1");
              ItemRepairAction.TestField("New Variety 1");
              ItemVar."Variety 1" := ItemRepairAction."New Variety 1";
              DoModify := true;
            end;

            if ItemVar."Variety 1 Table" <> ItemRepairAction."New Variety 1 Table" then begin
              InsertLogEntry(ItemVar."Item No.", ItemVar.Code,'Item Variant Updated (Variety 1 Table)', ItemVar."Variety 1 Table", ItemRepairAction."New Variety 1 Table");
              ItemRepairAction.TestField("New Variety 1 Table");
              ItemVar."Variety 1 Table" := ItemRepairAction."New Variety 1 Table";
              DoModify := true;
            end;

            if (ItemVar."Variety 1 Value" <> ItemRepairAction."New Variety 1 Value") then begin
              InsertLogEntry(ItemVar."Item No.", ItemVar.Code,'Item Variant Updated (Variety 1 Value)', ItemVar."Variety 1 Value", ItemRepairAction."New Variety 1 Value");
              ItemRepairAction.TestField("New Variety 1 Value");
              ItemVar."Variety 1 Value" := ItemRepairAction."New Variety 1 Value";
              DoModify := true;
            end;

          end;

          if ItemRepairAction."Variety 2 Action" = ItemRepairAction."Variety 2 Action"::UseItemSetup then begin
            if ItemVar."Variety 2" <> ItemRepairAction."New Variety 2" then begin
              InsertLogEntry(ItemVar."Item No.", ItemVar.Code,'Item Variant Updated (Variety 2)', ItemVar."Variety 2", ItemRepairAction."New Variety 2");
              ItemRepairAction.TestField("New Variety 2");
              ItemVar."Variety 2" := ItemRepairAction."New Variety 2";
              DoModify := true;
            end;

            if ItemVar."Variety 2 Table" <> ItemRepairAction."New Variety 2 Table" then begin
              InsertLogEntry(ItemVar."Item No.", ItemVar.Code,'Item Variant Updated (Variety 2 Table)', ItemVar."Variety 2 Table", ItemRepairAction."New Variety 2 Table");
              ItemRepairAction.TestField("New Variety 2 Table");
              ItemVar."Variety 2 Table" := ItemRepairAction."New Variety 2 Table";
              DoModify := true;
            end;

            if (ItemVar."Variety 2 Value" <> ItemRepairAction."New Variety 2 Value") then begin
              InsertLogEntry(ItemVar."Item No.", ItemVar.Code,'Item Variant Updated (Variety 2 Value)', ItemVar."Variety 2 Value", ItemRepairAction."New Variety 2 Value");
              ItemRepairAction.TestField("New Variety 2 Value");
              ItemVar."Variety 2 Value" := ItemRepairAction."New Variety 2 Value";
              DoModify := true;
            end;

          end;

          if DoModify then begin
            //-NPR5.29 [263917]
            //IF ItemVarTest.GetFromVariety(ItemVar."Item No.", ItemVar."Variety 1 Value", ItemVar."Variety 2 Value", ItemVar."Variety 3 Value", ItemVar."Variety 4 Value") THEN
            if VarietyCloneData.GetFromVariety(ItemVarTest, ItemVar."Item No.", ItemVar."Variety 1 Value", ItemVar."Variety 2 Value", ItemVar."Variety 3 Value", ItemVar."Variety 4 Value") then
            //+NPR5.29 [263917]
              Error('Item Variant already exists.\Variant Code %1',ItemVarTest.Code);
            ItemVar.Modify;
          end;
        until ItemVar.Next = 0;

        DoModify := false;
        if ItemRepairAction."Variety 1 Action" = ItemRepairAction."Variety 1 Action"::UseVariantSetup then begin
          if ItemRepairAction."New Variety 1" <> Item."Variety 1" then begin
            InsertLogEntry(Item."No.", '', 'Item Updated (Variety 1)', Item."Variety 1", ItemRepairAction."New Variety 1");
            ItemRepairAction.TestField("New Variety 1");
            Item."Variety 1" := ItemRepairAction."New Variety 1";
            DoModify := true;
          end;

          if ItemRepairAction."New Variety 1 Table" <> Item."Variety 1 Table" then begin
            InsertLogEntry(Item."No.", '', 'Item Variant Updated (Variety 1 Table)', Item."Variety 1 Table", ItemRepairAction."New Variety 1 Table");
            ItemRepairAction.TestField("New Variety 1 Table");
            Item."Variety 1 Table" := ItemRepairAction."New Variety 1 Table";
            DoModify := true;
          end;
        end;

        if ItemRepairAction."Variety 2 Action" = ItemRepairAction."Variety 2 Action"::UseVariantSetup then begin
          if ItemRepairAction."New Variety 2" <> Item."Variety 2" then begin
            InsertLogEntry(Item."No.", '', 'Item Updated (Variety 2)', Item."Variety 2", ItemRepairAction."New Variety 2");
            ItemRepairAction.TestField("New Variety 2");
            Item."Variety 2" := ItemRepairAction."New Variety 2";
            DoModify := true;
          end;

          if ItemRepairAction."New Variety 2 Table" <> Item."Variety 2 Table" then begin
            InsertLogEntry(Item."No.", '', 'Item Variant Updated (Variety 2 Table)', Item."Variety 2 Table", ItemRepairAction."New Variety 2 Table");
            ItemRepairAction.TestField("New Variety 2 Table");
            Item."Variety 2 Table" := ItemRepairAction."New Variety 2 Table";
            DoModify := true;
          end;
        end;

        if DoModify then
          Item.Modify;

        ItemRepairAction.Delete;
    end;

    procedure DoSelectedActions(var ItemRepairAction: Record "Item Repair Action")
    begin
        LineCount := 0;
        Dia.Open('Executing Actions @1@@@@@@@@@');
        NoOfRecords := ItemRepairAction.Count;
        if ItemRepairAction.FindFirst then repeat
          LineCount += 1;
          Dia.Update(1, Round(LineCount / NoOfRecords * 10000,1));
          DoAction(ItemRepairAction);
        until ItemRepairAction.Next = 0;
        Dia.Close;
    end;

    local procedure InsertLogEntry(ItemNo: Code[20];VariantCode: Code[20];ActionDesc: Text[50];FromValue: Text[50];ToValue: Text[50])
    var
        ItemRepairLog: Record "Item Repair Log";
    begin
        ItemRepairLog.Init;
        ItemRepairLog."Entry No." := 0;
        ItemRepairLog."Item No." := ItemNo;
        ItemRepairLog."Variant Code" := VariantCode;
        ItemRepairLog.Description := ActionDesc;
        ItemRepairLog."From value" := FromValue;
        ItemRepairLog."To Value" := ToValue;
        ItemRepairLog."Changed By" := UserId;
        ItemRepairLog."Executed at" := CurrentDateTime;
        ItemRepairLog.Insert;
    end;
}

