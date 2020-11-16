codeunit 6150731 "NPR POS Action: Transf. Order"
{
    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built-in action for handling Transfer Orders';
        CreateNewRecordCaption: Label 'Create new record with "%1" and "%2"';
        RegisterLocationOptionCaption: Label ' ,Use as Transfer-from filter,Use as Transfer-to filter';
        RegisterLocationCaption: Label 'Register Location';
        RegisterLocationDescriptionCaption: Label 'The location for the register';
        TransferFromFilterCaption: Label 'Transfer-from Filter';
        TransferFilterDescriptionCaption: Label 'Set filter on "%1" of the "%2"';
        TransferToFilterCaption: Label 'Transfer-to Filter';
        NewRecordCaption: Label 'New record';
        NewRecordDescriptionCaption: Label 'Gives option to create a new record of type "%1" directly';
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        DefaultTransferToCodeCaption: Label 'Default Transfer-to Code';
        DefaultTransferToCodeDescription: Label 'Default Transfer-to location code for newly created transfer orders';

    local procedure ActionCode(): Text
    begin
        exit('TRANSFER_ORDER');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.2');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode,
          ActionDescription,
          ActionVersion,
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Single)
        then begin
            Sender.RegisterWorkflow(false);
            Sender.RegisterOptionParameter('Register Location', ' ,Use as Transfer-from filter,Use as Transfer-to filter', ' ');
            Sender.RegisterTextParameter('Transfer-from Filter', '');
            Sender.RegisterTextParameter('Transfer-to Filter', '');
            Sender.RegisterBooleanParameter('NewRecord', false);
            Sender.RegisterTextParameter('DefaultTransferToCode', '');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', true, true)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSSetup: Codeunit "NPR POS Setup";
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        TransferHeader: Record "Transfer Header";
        UsePOSLocationAs: Integer;
        TransferFromFilter: Text;
        TransferToFilter: Text;
        TemplateMgt: Codeunit "NPR RP Template Mgt.";
        ReportSelection: Record "Report Selections";
        Template: Text;
        TransferOrderList: Page "Transfer Orders";
        Codeunit6059823: Codeunit "NPR TransferOrder-Post + Print";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScope('parameters', true);
        UsePOSLocationAs := JSON.GetInteger('Register Location', true);

        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        POSSetup.GetPOSStore(POSStore);

        case UsePOSLocationAs of
            1:
                TransferFromFilter := POSStore."Location Code";
            2:
                TransferToFilter := POSStore."Location Code";
        end;

        if JSON.GetBooleanParameter('NewRecord', true) then begin
            if Confirm(CreateNewRecordCaption, true, TransferHeader.FieldCaption("Transfer-from Code"), TransferHeader.FieldCaption("Shortcut Dimension 1 Code")) then
                AddNewRecord(Posstore, POSUnit, JSON.GetStringParameter('DefaultTransferToCode', false));
        end else begin
            if TransferFromFilter = '' then
                TransferFromFilter := JSON.GetString('Transfer-from Filter', true);
            if TransferToFilter = '' then
                TransferToFilter := JSON.GetString('Transfer-to Filter', true);

            if TransferFromFilter <> '' then
                TransferHeader.SetFilter("Transfer-from Code", TransferFromFilter);
            if TransferToFilter <> '' then
                TransferHeader.SetFilter("Transfer-to Code", TransferToFilter);

            ReportSelectionRetail.Reset;
            ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Transfer Order");
            if ReportSelectionRetail.FindFirst then begin
                Template := ReportSelectionRetail."Print Template";
                Codeunit6059823.SetValues(true);
            end;

            Clear(TransferOrderList);
            TransferOrderList.SetTableView(TransferHeader);
            TransferOrderList.SetValues(Template);
            TransferOrderList.Run();
        end;

        POSSession.RequestRefreshData;
    end;

    //--- Subscribers ---

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterNameCaption', '', false, false)]
    procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
            'Register Location':
                Caption := RegisterLocationCaption;
            'Transfer-from Filter':
                Caption := TransferFromFilterCaption;
            'Transfer-to Filter':
                Caption := TransferToFilterCaption;
            'NewRecord':
                Caption := NewRecordCaption;
            'DefaultTransferToCode':
                Caption := DefaultTransferToCodeCaption;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterDescriptionCaption', '', false, false)]
    procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        TransferHeader: Record "Transfer Header";
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
            'Register Location':
                Caption := RegisterLocationDescriptionCaption;
            'Transfer-from Filter':
                Caption := StrSubstNo(TransferFilterDescriptionCaption, TransferHeader.FieldCaption("Transfer-from Code"), TransferHeader.TableCaption);
            'Transfer-to Filter':
                Caption := StrSubstNo(TransferFilterDescriptionCaption, TransferHeader.FieldCaption("Transfer-to Code"), TransferHeader.TableCaption);
            'NewRecord':
                Caption := StrSubstNo(NewRecordDescriptionCaption, TransferHeader.TableCaption);
            'DefaultTransferToCode':
                Caption := DefaultTransferToCodeDescription;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterOptionStringCaption', '', false, false)]
    procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
            'Register Location':
                Caption := RegisterLocationOptionCaption;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', false, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        Location: Record Location;
        LocationList: Page "Location List";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        if POSParameterValue.Name in
            ['Transfer-from Filter',
             'Transfer-to Filter',
             'DefaultTransferToCode']
        then begin
            Location.FilterGroup(2);
            Location.SetRange("Use As In-Transit", false);
            Location.FilterGroup(0);
        end;

        case POSParameterValue.Name of
            'Transfer-from Filter',
            'Transfer-to Filter':
                begin
                    Clear(LocationList);
                    LocationList.SetTableView(Location);
                    LocationList.LookupMode(true);
                    if LocationList.RunModal = ACTION::LookupOK then
                        POSParameterValue.Value := CopyStr(LocationList.GetSelectionFilter(), 1, MaxStrLen(POSParameterValue.Value));
                end;

            'DefaultTransferToCode':
                begin
                    if POSParameterValue.Value <> '' then begin
                        Location.Code := CopyStr(POSParameterValue.Value, 1, MaxStrLen(Location.Code));
                        if Location.Find('=><') then;
                    end;
                    if PAGE.RunModal(0, Location) = ACTION::LookupOK then
                        POSParameterValue.Value := Location.Code;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', false, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        Location: Record Location;
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'DefaultTransferToCode':
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    Location.SetRange("Use As In-Transit", false);
                    Location.Code := CopyStr(POSParameterValue.Value, 1, MaxStrLen(Location.Code));
                    Location.Find;
                end;
        end;
    end;

    //--- Auxiliary ---

    local procedure AddNewRecord(POSStore: Record "NPR POS Store"; POSUnit: Record "NPR POS Unit"; TransferToCodeString: Text)
    var
        Location: Record Location;
        TransferHeader: Record "Transfer Header";
        TransferOrder: Page "Transfer Order";
    begin
        TransferHeader.Insert(true);
        TransferHeader.Validate("Transfer-from Code", POSStore."Location Code");
        if Location.Get(CopyStr(TransferToCodeString, 1, MaxStrLen(Location.Code))) then
            if not Location."Use As In-Transit" and (TransferHeader."Transfer-from Code" <> Location.Code) then
                TransferHeader.Validate("Transfer-to Code", TransferToCodeString);
        TransferHeader.Validate("Shortcut Dimension 1 Code", POSUnit."Global Dimension 1 Code");  //Why only 1st global dim?
        TransferHeader.Modify;

        TransferOrder.SetRecord(TransferHeader);
        TransferOrder.Run;
    end;
}