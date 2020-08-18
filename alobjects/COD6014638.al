codeunit 6014638 "Dynamic Module Item Wsht Setup"
{
    // NPR5.55/TJ  /20200303 CASE 388960 New object


    trigger OnRun()
    begin
    end;

    var
        DynamicModuleHelper: Codeunit "Dynamic Module Helper";
        AdditionalPropertyType: Option " ",Length,OptionString,DecimalPrecision;
        DynamicModuleSetting: Record "Dynamic Module Setting";
        TransferItemsToRetJnlConfirm: Label 'Do you want to transfer items to Retail Journal %1?';
        RetailJnlNotSpecifiedErr: Label 'You need to specify Retail Journal Code. Please refer to Dynamics Module %1.';
        RetailJnlCodeDoesntExistErr: Label 'Retail Journal %1 doesn''t exist. Please refer to Dynamics Module %2.';
        RetailJnlContainsDataMsg: Label 'Retail Journal %1 is not empty. %2';
        RetailJnlDeleteMsg: Label 'Please check the journal if the content can be removed/processed and try again.';
        RetailJnlDeleteQst: Label 'Do you want to delete its content now?';

    [EventSubscriber(ObjectType::Table, 6014479, 'OnDiscoverModule', '', true, true)]
    local procedure LoadModule(var Sender: Record "Dynamic Module")
    begin
        DynamicModuleHelper.CreateOrFindModule(GetModuleName(),Sender);
        DynamicModuleHelper.CreateModuleSetting(Sender,1,'Transfer to Retail Journal',DynamicModuleSetting."Data Type"::Option,AdditionalPropertyType::OptionString,'Never,Ask,Allways',0);
        DynamicModuleHelper.CreateModuleSetting(Sender,2,'Retail Journal Code',DynamicModuleSetting."Data Type"::Code,AdditionalPropertyType::Length,'40','');
        DynamicModuleHelper.CreateModuleSetting(Sender,3,'If Retail Journal Not Empty Do',DynamicModuleSetting."Data Type"::Option,AdditionalPropertyType::OptionString,'Error,Ask,Delete',0);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060044, 'OnAfterRegisterLines', '', true, true)]
    local procedure TransferToRetailJournal(var ItemWorksheetLine: Record "Item Worksheet Line")
    var
        ItemWorksheetLine2: Record "Item Worksheet Line";
        ItemWkshVariantLine: Record "Item Worksheet Variant Line";
        RetailJournalLine: Record "Retail Journal Line";
        RetailJournalHeader: Record "Retail Journal Header";
        Value: Variant;
        TransferToRetailJnlOption: Integer;
        RetailJnlCode: Text;
        RetailJnlStatusAction: Integer;
        Continue: Boolean;
        ItemNo: Code[20];
        VariantCode: Code[20];
    begin
        ItemWorksheetLine2.Copy(ItemWorksheetLine);
        if not DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(),1,Value) then
          exit;
        TransferToRetailJnlOption := Value;

        Clear(Value);
        if not DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(),2,Value) then
          exit;
        RetailJnlCode := Value;

        Clear(Value);
        if not DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(),3,Value) then
          exit;
        RetailJnlStatusAction := Value;

        case TransferToRetailJnlOption of
          0:
            exit;
          1:
            Continue := Confirm(StrSubstNo(TransferItemsToRetJnlConfirm,RetailJnlCode));
          2:
            Continue := true;
        end;
        if not Continue then
          exit;

        if RetailJnlCode = '' then
          Error(RetailJnlNotSpecifiedErr,GetModuleName());
        if not RetailJournalHeader.Get(RetailJnlCode) then
          Error(RetailJnlCodeDoesntExistErr,RetailJnlCode,GetModuleName());

        RetailJournalLine.SetRange("No.",RetailJnlCode);
        if not RetailJournalLine.IsEmpty then
          case RetailJnlStatusAction of
            0:
              Error(RetailJnlContainsDataMsg,RetailJnlCode,RetailJnlDeleteMsg);
            1:
              Continue := Confirm(StrSubstNo(RetailJnlContainsDataMsg,RetailJnlCode,RetailJnlDeleteQst));
            2:
              Continue := true;
          end;
        if not Continue then
          Error('');

        RetailJournalLine.DeleteAll(true);

        ItemWorksheetLine2.SetFilter(Action,'<>%1',ItemWorksheetLine2.Action::Skip);
        if ItemWorksheetLine2.FindSet then
          repeat
            ItemNo := ItemWorksheetLine2."Existing Item No.";
            if ItemNo = '' then
              ItemNo := ItemWorksheetLine2."Item No.";
            ItemWkshVariantLine.SetRange("Worksheet Template Name",ItemWorksheetLine2."Worksheet Template Name");
            ItemWkshVariantLine.SetRange("Worksheet Name",ItemWorksheetLine2."Worksheet Name");
            ItemWkshVariantLine.SetRange("Worksheet Line No.",ItemWorksheetLine2."Line No.");
            ItemWkshVariantLine.SetFilter(Action,'%1|%2',ItemWkshVariantLine.Action::CreateNew,ItemWkshVariantLine.Action::Update);
            if ItemWkshVariantLine.FindSet then
              repeat
                VariantCode := ItemWkshVariantLine."Existing Variant Code";
                if VariantCode = '' then
                  VariantCode := ItemWkshVariantLine."Variant Code";
                CreateRetailJournalLine(RetailJnlCode,ItemNo,VariantCode);
              until ItemWkshVariantLine.Next = 0
            else
              CreateRetailJournalLine(RetailJnlCode,ItemNo,'');
          until ItemWorksheetLine2.Next = 0;
    end;

    local procedure CreateRetailJournalLine(RetailJnlCode: Text;ItemNo: Code[20];VariantCode: Code[10])
    var
        RetailJournalLine: Record "Retail Journal Line";
        LineNo: Integer;
    begin
        LineNo := 10000;
        RetailJournalLine.SetRange("No.",RetailJnlCode);
        if RetailJournalLine.FindLast then
          LineNo := RetailJournalLine."Line No." + 10000;

        RetailJournalLine.Init;
        RetailJournalLine.Validate("No.",RetailJnlCode);
        RetailJournalLine.Validate("Line No.",LineNo);
        RetailJournalLine.Validate("Item No.",ItemNo);
        if VariantCode <> '' then
          RetailJournalLine.Validate("Variant Code",VariantCode);
        RetailJournalLine.Insert(false);
    end;

    [Scope('Personalization')]
    procedure GetModuleName(): Text
    begin
        exit('Item Worksheet Setup');
    end;
}

