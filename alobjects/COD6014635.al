codeunit 6014635 "Item Block Mgt."
{
    // NPR5.38/MHA /20170104  CASE 299272 Object created - manages Item Sale- and Purchase Block
    // NPR5.43/MHA /20180619  CASE 319425 Added OnAfterInsertSaleLine POS Sales Workflow
    // NPR5.45/JKL /20180830 CASE 299272 added setup to bypass item block on different levels
    // NPR5.55/TILA/20200416  CASE 400483 Added code that checks Purchase and Sale Blocked for Item only if Item Block module is enabled


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Test Item."Sale Blocked" on Sales Line Insert';
        TextItemBlock2: Label 'Exclude Item Block on Sales Line';
        TextItemBlock3: Label 'Exclude Item Block on Std. Sales Line';
        TextItemBlock4: Label 'Exclude Item Block on Purch. Line';
        TextItemBlock5: Label 'Exclude Item Block on Std. Purch. Line';
        TextItemBlock6: Label 'Exclude Item Block on Item Jnl. Line Sales';
        TextItemBlock7: Label 'Exclude Item Block on Item Jnl. Line Purch.';
        TextItemBlock8: Label 'Exclude Item Block on Std. Item Jnl. Line Sales';
        TextItemBlock9: Label 'Exclude Item Block on Std. Item Jnl. Line Purch.';
        TextItemBlock10: Label 'Exclude Item Block on Item Req. Line';
        TextItemBlock11: Label 'Exclude Item Block on Sales Item Posting';
        TextItemBlock12: Label 'Exclude Item Block on Purch. Item Posting';

    local procedure "--- Sales Triggers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 37, 'OnBeforeValidateEvent', 'No.', true, true)]
    local procedure OnValidateNoSalesLine(var Rec: Record "Sales Line";var xRec: Record "Sales Line";CurrFieldNo: Integer)
    var
        Item: Record Item;
        DynamicModuleHelper: Codeunit "Dynamic Module Helper";
        Value: Variant;
        SetupValue: Boolean;
        SettingID: Integer;
    begin
        if Rec.Type <> Rec.Type::Item then
          exit;

        //-NPR5.45 [299272]
        //TestSaleBlocked(Rec."No.");
        begin
          SettingID := 2;
          if DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(),SettingID,Value) then
            SetupValue := Value;
          if not SetupValue then
            TestSaleBlocked(Rec."No.");
        end;
        //+NPR5.45 [299272]
    end;

    [EventSubscriber(ObjectType::Table, 171, 'OnBeforeValidateEvent', 'No.', true, true)]
    local procedure OnValidateNoStdSalesLine(var Rec: Record "Standard Sales Line";var xRec: Record "Standard Sales Line";CurrFieldNo: Integer)
    var
        Item: Record Item;
        DynamicModuleHelper: Codeunit "Dynamic Module Helper";
        Value: Variant;
        SetupValue: Boolean;
        SettingID: Integer;
    begin
        if Rec.Type <> Rec.Type::Item then
          exit;

        //-NPR5.45 [299272]
        //TestSaleBlocked(Rec."No.");
        begin
          SettingID := 3;
          if DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(),SettingID,Value) then
            SetupValue := Value;
          if not SetupValue then
            TestSaleBlocked(Rec."No.");
        end;
        //+NPR5.45 [299272]
    end;

    local procedure "--- Purch. Triggers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnBeforeValidateEvent', 'No.', true, true)]
    local procedure OnValidateNoPurchLine(var Rec: Record "Purchase Line";var xRec: Record "Purchase Line";CurrFieldNo: Integer)
    var
        Item: Record Item;
        DynamicModuleHelper: Codeunit "Dynamic Module Helper";
        Value: Variant;
        SetupValue: Boolean;
        SettingID: Integer;
    begin
        if Rec.Type <> Rec.Type::Item then
          exit;

        //-NPR5.45 [299272]
        //TestPurchBlocked(Rec."No.");
        begin
          SettingID := 4;
          if DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(),SettingID,Value) then
            SetupValue := Value;
          if not SetupValue then
            TestPurchBlocked(Rec."No.");
        end;
        //+NPR5.45 [299272]
    end;

    [EventSubscriber(ObjectType::Table, 174, 'OnBeforeValidateEvent', 'No.', true, true)]
    local procedure OnValidateNoStdPurchLine(var Rec: Record "Standard Purchase Line";var xRec: Record "Standard Purchase Line";CurrFieldNo: Integer)
    var
        Item: Record Item;
        DynamicModuleHelper: Codeunit "Dynamic Module Helper";
        Value: Variant;
        SetupValue: Boolean;
        SettingID: Integer;
    begin
        if Rec.Type <> Rec.Type::Item then
          exit;

        //-NPR5.45 [299272]
        //TestPurchBlocked(Rec."No.");
        begin
          SettingID := 5;
          if DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(),SettingID,Value) then
            SetupValue := Value;
          if not SetupValue then
            TestPurchBlocked(Rec."No.");
        end;
        //+NPR5.45 [299272]
    end;

    local procedure "--- Journal Triggers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 83, 'OnBeforeValidateEvent', 'Item No.', true, true)]
    local procedure OnValidateItemNoItemJnlLine(var Rec: Record "Item Journal Line";var xRec: Record "Item Journal Line";CurrFieldNo: Integer)
    var
        Item: Record Item;
        DynamicModuleHelper: Codeunit "Dynamic Module Helper";
        Value: Variant;
        SetupValue: Boolean;
        SettingID: Integer;
    begin
        case Rec."Entry Type" of
          Rec."Entry Type"::Sale:
            //-NPR5.45 [299272]
            //TestSaleBlocked(Rec."Item No.");
            begin
              SettingID := 6;
              if DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(),SettingID,Value) then
                SetupValue := Value;
              if not SetupValue then
                TestSaleBlocked(Rec."Item No.");
            end;
            //+NPR5.45 [299272]
          Rec."Entry Type"::Purchase:
            //-NPR5.45 [299272]
            //TestPurchBlocked(Rec."Item No.");
            begin
              SettingID := 7;
              if DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(),SettingID,Value) then
                SetupValue := Value;
              if not SetupValue then
                TestPurchBlocked(Rec."Item No.");
            end;
            //+NPR5.45 [299272]
        end;
    end;

    [EventSubscriber(ObjectType::Table, 753, 'OnBeforeValidateEvent', 'Item No.', true, true)]
    local procedure OnValidateItemNoStdItemJnlLine(var Rec: Record "Standard Item Journal Line";var xRec: Record "Standard Item Journal Line";CurrFieldNo: Integer)
    var
        Item: Record Item;
        DynamicModuleHelper: Codeunit "Dynamic Module Helper";
        Value: Variant;
        SetupValue: Boolean;
        SettingID: Integer;
    begin
        case Rec."Entry Type" of
          Rec."Entry Type"::Sale:
            //-NPR5.45 [299272]
            //TestSaleBlocked(Rec."Item No.");
            begin
              SettingID := 8;
              if DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(),SettingID,Value) then
                SetupValue := Value;
              if not SetupValue then
                TestSaleBlocked(Rec."Item No.");
            end;
            //+NPR5.45 [299272]
          Rec."Entry Type"::Purchase:
            //-NPR5.45 [299272]
            //TestPurchBlocked(Rec."Item No.");
            begin
              SettingID := 9;
              if DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(),SettingID,Value) then
                SetupValue := Value;
              if not SetupValue then
                TestPurchBlocked(Rec."Item No.");
            end;
            //+NPR5.45 [299272]
        end;
    end;

    [EventSubscriber(ObjectType::Table, 246, 'OnBeforeValidateEvent', 'No.', true, true)]
    local procedure OnValidateNoReqLine(var Rec: Record "Requisition Line";var xRec: Record "Requisition Line";CurrFieldNo: Integer)
    var
        Item: Record Item;
        DynamicModuleHelper: Codeunit "Dynamic Module Helper";
        Value: Variant;
        SetupValue: Boolean;
        SettingID: Integer;
    begin
        if Rec.Type <> Rec.Type::Item then
          exit;

        //-NPR5.45 [299272]
        //TestPurchBlocked(Rec."No.");
        begin
          SettingID := 10;
          if DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(),SettingID,Value) then
            SetupValue := Value;
          if not SetupValue then
            TestPurchBlocked(Rec."No.");
        end;
        //+NPR5.45 [299272]
    end;

    local procedure "--- Posting Triggers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 22, 'OnBeforePostItemJnlLine', '', true, true)]
    local procedure OnBeforePostItemJnlLine(var ItemJournalLine: Record "Item Journal Line")
    var
        DynamicModuleHelper: Codeunit "Dynamic Module Helper";
        Value: Variant;
        SetupValue: Boolean;
        SettingID: Integer;
    begin
        case ItemJournalLine."Entry Type" of
          ItemJournalLine."Entry Type"::Sale:
            //-NPR5.45 [299272]
            //TestSaleBlocked(ItemJournalLine."Item No.");
            begin
              SettingID := 11;
              if DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(),SettingID,Value) then
                SetupValue := Value;
              if not SetupValue then
                TestSaleBlocked(ItemJournalLine."Item No.");
            end;
            //+NPR5.45 [299272]
          ItemJournalLine."Entry Type"::Purchase:
            //-NPR5.45 [299272]
            //TestPurchBlocked(ItemJournalLine."Item No.");
            begin
              SettingID := 12;
              if DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(),SettingID,Value) then
                SetupValue := Value;
              if not SetupValue then
                TestPurchBlocked(ItemJournalLine."Item No.");
            end;
            //+NPR5.45 [299272]
        end;
    end;

    local procedure "--- OnAfterInsertSaleLine Workflow"()
    begin
        //-NPR5.43 [319425]
        //+NPR5.43 [319425]
    end;

    [EventSubscriber(ObjectType::Table, 6150730, 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "POS Sales Workflow Step";RunTrigger: Boolean)
    begin
        //-NPR5.43 [319425]
        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
          exit;

        case Rec."Subscriber Function" of
          'TestBlockedOnPOSSaleLineInsert':
            begin
              Rec.Description := Text000;
              Rec."Sequence No." := 10;
            end;
        end;
        //+NPR5.43 [319425]
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        //-NPR5.43 [319425]
        exit(CODEUNIT::"Item Block Mgt.");
        //+NPR5.43 [319425]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150706, 'OnBeforeInsertSaleLine', '', true, true)]
    local procedure TestBlockedOnPOSSaleLineInsert(POSSalesWorkflowStep: Record "POS Sales Workflow Step";SaleLinePOS: Record "Sale Line POS")
    begin
        //-NPR5.43 [319425]
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
          exit;

        if POSSalesWorkflowStep."Subscriber Function" <> 'TestBlockedOnPOSSaleLineInsert' then
          exit;

        if SaleLinePOS.Type <> SaleLinePOS.Type::Item then
          exit;

        TestSaleBlocked(SaleLinePOS."No.");
        //+NPR5.43 [319425]
    end;

    local procedure "--- Test"()
    begin
    end;

    local procedure TestSaleBlocked(ItemNo: Code[20])
    var
        Item: Record Item;
        DynamicModule: Record "Dynamic Module";
    begin
        if ItemNo = '' then
          exit;
        if not Item.Get(ItemNo) then
          exit;

        //-NPR5.55 [400483]
        DynamicModule.SetRange("Module Name", GetModuleName);
        if not DynamicModule.FindFirst then
          exit;
        if not DynamicModule.Enabled then
          exit;
        //+NPR5.55 [400483]

        Item.TestField("Sale Blocked",false);
    end;

    local procedure TestPurchBlocked(ItemNo: Code[20])
    var
        Item: Record Item;
        DynamicModule: Record "Dynamic Module";
    begin
        if ItemNo = '' then
          exit;
        if not Item.Get(ItemNo) then
          exit;

        //-NPR5.55 [400483]
        DynamicModule.SetRange("Module Name", GetModuleName);
        if not DynamicModule.FindFirst then
          exit;
        if not DynamicModule.Enabled then
          exit;
        //+NPR5.55 [400483]

        Item.TestField("Purchase Blocked",false);
    end;

    local procedure "---Setup"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6014479, 'OnDiscoverModule', '', true, true)]
    local procedure LoadBlockSetting(var Sender: Record "Dynamic Module")
    var
        DynamicModuleSetting: Record "Dynamic Module Setting";
        DateFormulaValue: DateFormula;
        DecimalValue: Decimal;
        DurationValue: Duration;
        DynamicModuleHelper: Codeunit "Dynamic Module Helper";
        AdditionalPropertyType: Option " ",Length,OptionString,DecimalPrecision;
    begin
        //-NPR5.45 [299272]
        DynamicModuleHelper.CreateOrFindModule(GetModuleName(),Sender);

        DynamicModuleHelper.CreateModuleSetting(Sender,2,TextItemBlock2,DynamicModuleSetting."Data Type"::Boolean,AdditionalPropertyType::" ",'',false);
        DynamicModuleHelper.CreateModuleSetting(Sender,3,TextItemBlock3,DynamicModuleSetting."Data Type"::Boolean,AdditionalPropertyType::" ",'',false);
        DynamicModuleHelper.CreateModuleSetting(Sender,4,TextItemBlock4,DynamicModuleSetting."Data Type"::Boolean,AdditionalPropertyType::" ",'',false);
        DynamicModuleHelper.CreateModuleSetting(Sender,5,TextItemBlock5,DynamicModuleSetting."Data Type"::Boolean,AdditionalPropertyType::" ",'',false);
        DynamicModuleHelper.CreateModuleSetting(Sender,6,TextItemBlock6,DynamicModuleSetting."Data Type"::Boolean,AdditionalPropertyType::" ",'',false);
        DynamicModuleHelper.CreateModuleSetting(Sender,7,TextItemBlock7,DynamicModuleSetting."Data Type"::Boolean,AdditionalPropertyType::" ",'',false);
        DynamicModuleHelper.CreateModuleSetting(Sender,8,TextItemBlock8,DynamicModuleSetting."Data Type"::Boolean,AdditionalPropertyType::" ",'',false);
        DynamicModuleHelper.CreateModuleSetting(Sender,9,TextItemBlock9,DynamicModuleSetting."Data Type"::Boolean,AdditionalPropertyType::" ",'',false);
        DynamicModuleHelper.CreateModuleSetting(Sender,10,TextItemBlock10,DynamicModuleSetting."Data Type"::Boolean,AdditionalPropertyType::" ",'',false);
        DynamicModuleHelper.CreateModuleSetting(Sender,11,TextItemBlock11,DynamicModuleSetting."Data Type"::Boolean,AdditionalPropertyType::" ",'',false);
        DynamicModuleHelper.CreateModuleSetting(Sender,12,TextItemBlock12,DynamicModuleSetting."Data Type"::Boolean,AdditionalPropertyType::" ",'',false);
        //+NPR5.45 [299272]
    end;

    procedure GetModuleName(): Text
    begin
        //-NPR5.45 [299272]
        exit('ItemBlock');
        //+NPR5.45 [299272]
    end;
}

