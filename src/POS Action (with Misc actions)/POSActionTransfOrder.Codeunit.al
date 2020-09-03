codeunit 6150731 "NPR POS Action: Transf. Order"
{
    // NPR5.43/THRO/20180604 CASE 315072 Transfer order list
    // NPR5.51/ALST/20190722 CASE 358552 added possibility to auto create new order woth location and global dimension set from the register
    // NPR5.52/ALST/20191009 CASE 358552 fixed new record functionality
    // NPR5.53/ALPO/20191025 CASE 371956 Dimensions: POS Store & POS Unit integration; discontinue dimensions on Cash Register
    // NPR5.55/YAHA/20191127 CASE 362312 Added Functionality to use template for printing
    // NPR5.55/ALPO/20200724 CASE 416100 A new parameter to preset Trasfer-to location code, when creating new orders


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
        exit('1.2');  //NPR5.55 [416100]
        exit('1.1');
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
            //-NPR5.51 [358552]
            Sender.RegisterBooleanParameter('NewRecord', false);
            //+NPR5.51 [358552]
            Sender.RegisterTextParameter('DefaultTransferToCode', '');  //NPR5.55 [416100]
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', true, true)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSSetup: Codeunit "NPR POS Setup";
        Register: Record "NPR Register";
        TransferHeader: Record "Transfer Header";
        UsePOSLocationAs: Integer;
        TransferFromFilter: Text;
        TransferToFilter: Text;
        TemplateMgt: Codeunit "NPR RP Template Mgt.";
        ReportSelection: Record "Report Selections";
        Template: Text;
        Page5742: Page "Transfer Orders";
        Codeunit6059823: Codeunit "NPR TransferOrder-Post + Print";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScope('parameters', true);
        UsePOSLocationAs := JSON.GetInteger('Register Location', true);

        //-NPR5.51 [358552]
        POSSession.GetSetup(POSSetup);
        POSSetup.GetRegisterRecord(Register);
        //+NPR5.51 [358552]

        //-NPR5.51 [358552]
        //  IF UsePOSLocationAs > 0 THEN BEGIN
        //    POSSession.GetSetup(POSSetup);
        //    POSSetup.GetRegisterRecord(Register);
        //+NPR5.51 [358552]
        case UsePOSLocationAs of
            1:
                TransferFromFilter := Register."Location Code";
            2:
                TransferToFilter := Register."Location Code";
        end;

        //-NPR5.51 [358552]
        if JSON.GetBooleanParameter('NewRecord', true) then
        //-NPR5.52 [358552]
        begin
            //+NPR5.52 [358552]
            if Confirm(CreateNewRecordCaption, true, TransferHeader.FieldCaption("Transfer-from Code"), TransferHeader.FieldCaption("Shortcut Dimension 1 Code")) then
                //AddNewRecord(Register);  //NPR5.55 [416100]-revoked
                AddNewRecord(Register, JSON.GetStringParameter('DefaultTransferToCode', false));  //NPR5.55 [416100]
                                                                                                  //-NPR5.52 [358552]
        end
        //+NPR5.52 [358552]
        else begin
            //+NPR5.51 [358552]
            if TransferFromFilter = '' then
                TransferFromFilter := JSON.GetString('Transfer-from Filter', true);
            if TransferToFilter = '' then
                TransferToFilter := JSON.GetString('Transfer-to Filter', true);

            if TransferFromFilter <> '' then
                TransferHeader.SetFilter("Transfer-from Code", TransferFromFilter);
            if TransferToFilter <> '' then
                TransferHeader.SetFilter("Transfer-to Code", TransferToFilter);

            //-NPR5.55 [362312]
            //PAGE.RUN(5742,TransferHeader);
            ReportSelectionRetail.Reset;
            ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Transfer Order");
            if ReportSelectionRetail.FindFirst then begin
                Template := ReportSelectionRetail."Print Template";
                Codeunit6059823.SetValues(true);
            end;
            Page5742.SetValues(Template, TransferHeader);
            Page5742.Run();
            //+NPR5.55 [362312]
        end;

        POSSession.RequestRefreshData;
    end;

    local procedure "--- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterNameCaption', '', false, false)]
    procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        //-NPR5.51 [358552]
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
            //-NPR5.55 [416100]
            'DefaultTransferToCode':
                Caption := DefaultTransferToCodeCaption;
        //+NPR5.55 [416100]
        end;
        //+NPR5.51 [358552]
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterDescriptionCaption', '', false, false)]
    procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        TransferHeader: Record "Transfer Header";
    begin
        //-NPR5.51 [358552]
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
            //-NPR5.55 [416100]
            'DefaultTransferToCode':
                Caption := DefaultTransferToCodeDescription;
        //+NPR5.55 [416100]
        end;
        //+NPR5.51 [358552]
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterOptionStringCaption', '', false, false)]
    procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        //-NPR5.55 [416100]
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
            'Register Location':
                Caption := RegisterLocationOptionCaption;
        end;
        //+NPR5.55 [416100]
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', false, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        Location: Record Location;
        LocationList: Page "Location List";
    begin
        //-NPR5.55 [416100]
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
        //+NPR5.55 [416100]
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', false, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        Location: Record Location;
    begin
        //-NPR5.54 [399189]
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
        //+NPR5.54 [399189]
    end;

    local procedure "--- Auxiliary"()
    begin
    end;

    local procedure AddNewRecord(Register: Record "NPR Register"; TransferToCodeString: Text)
    var
        Location: Record Location;
        POSUnit: Record "NPR POS Unit";
        TransferHeader: Record "Transfer Header";
        TransferOrder: Page "Transfer Order";
    begin
        //-NPR5.51 [358552]
        TransferHeader.Insert(true);
        TransferHeader.Validate("Transfer-from Code", Register."Location Code");
        //-NPR5.55 [416100]
        if Location.Get(CopyStr(TransferToCodeString, 1, MaxStrLen(Location.Code))) then
            if not Location."Use As In-Transit" and (TransferHeader."Transfer-from Code" <> Location.Code) then
                TransferHeader.Validate("Transfer-to Code", TransferToCodeString);
        //+NPR5.55 [416100]
        //TransferHeader.VALIDATE("Shortcut Dimension 1 Code",Register."Global Dimension 1 Code");  //NPR5.53 [371956]-revoked
        //-NPR5.53 [371956]
        POSUnit.Get(Register."Register No.");
        TransferHeader.Validate("Shortcut Dimension 1 Code", POSUnit."Global Dimension 1 Code");  //Why only 1st global dim?
        //+NPR5.53 [371956]
        TransferHeader.Modify;

        TransferOrder.SetRecord(TransferHeader);
        TransferOrder.Run;
        //+NPR5.51 [358552]
    end;
}

