codeunit 6150731 "POS Action - Transfer Order"
{
    // NPR5.43/THRO/20180604 CASE 315072 Transfer order list
    // NPR5.51/ALST/20190722 CASE 358552 added possibility to auto create new order woth location and global dimension set from the register
    // NPR5.52/ALST/20191009 CASE 358552 fixed new record functionality


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

    local procedure ActionCode(): Text
    begin
        exit ('TRANSFER_ORDER');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.1');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode,
          ActionDescription,
          ActionVersion,
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Single)
        then begin
          Sender.RegisterWorkflow(false);
          Sender.RegisterOptionParameter('Register Location',' ,Use as Transfer-from filter,Use as Transfer-to filter',' ');
          Sender.RegisterTextParameter('Transfer-from Filter','');
          Sender.RegisterTextParameter('Transfer-to Filter','');
          //-NPR5.51 [358552]
          Sender.RegisterBooleanParameter('NewRecord',false);
          //+NPR5.51 [358552]
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', true, true)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        POSSetup: Codeunit "POS Setup";
        Register: Record Register;
        TransferHeader: Record "Transfer Header";
        UsePOSLocationAs: Integer;
        TransferFromFilter: Text;
        TransferToFilter: Text;
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        JSON.SetScope('parameters',true);
        UsePOSLocationAs := JSON.GetInteger('Register Location',true);

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
          1 : TransferFromFilter := Register."Location Code";
          2 : TransferToFilter := Register."Location Code";
        end;

        //-NPR5.51 [358552]
        if JSON.GetBooleanParameter('NewRecord',true) then
        //-NPR5.52 [358552]
        begin
        //+NPR5.52 [358552]
          if Confirm(CreateNewRecordCaption,true,TransferHeader.FieldCaption("Transfer-from Code"),TransferHeader.FieldCaption("Shortcut Dimension 1 Code")) then
            AddNewRecord(Register);
        //-NPR5.52 [358552]
        end
        //+NPR5.52 [358552]
          else begin
        //+NPR5.51 [358552]
            if TransferFromFilter = '' then
              TransferFromFilter := JSON.GetString('Transfer-from Filter',true);
            if TransferToFilter = '' then
              TransferToFilter := JSON.GetString('Transfer-to Filter',true);

            if TransferFromFilter <> '' then
              TransferHeader.SetFilter("Transfer-from Code",TransferFromFilter);
            if TransferToFilter <> '' then
              TransferHeader.SetFilter("Transfer-to Code",TransferToFilter);

            PAGE.Run(5742,TransferHeader);
          end;

        POSSession.RequestRefreshData;
    end;

    local procedure "--- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterNameCaption', '', false, false)]
    procedure OnGetParameterNameCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
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
        end;
        //+NPR5.51 [358552]
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterDescriptionCaption', '', false, false)]
    procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
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
            Caption := StrSubstNo(TransferFilterDescriptionCaption,TransferHeader.FieldCaption("Transfer-from Code"),TransferHeader.TableCaption);
          'Transfer-to Filter':
            Caption := StrSubstNo(TransferFilterDescriptionCaption,TransferHeader.FieldCaption("Transfer-from Code"),TransferHeader.TableCaption);
          'NewRecord':
            Caption := StrSubstNo(NewRecordDescriptionCaption,TransferHeader.TableCaption);
        end;
        //+NPR5.51 [358552]
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterOptionStringCaption', '', false, false)]
    procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        //-NPR5.51 [358552]
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'Register Location':
            Caption := RegisterLocationOptionCaption;
        end;
        //+NPR5.51 [358552]
    end;

    local procedure "--- Auxiliary"()
    begin
    end;

    local procedure AddNewRecord(Register: Record Register)
    var
        TransferHeader: Record "Transfer Header";
        TransferOrder: Page "Transfer Order";
    begin
        //-NPR5.51 [358552]
        TransferHeader.Insert(true);
        TransferHeader.Validate("Transfer-from Code",Register."Location Code");
        TransferHeader.Validate("Shortcut Dimension 1 Code",Register."Global Dimension 1 Code");
        TransferHeader.Modify;

        TransferOrder.SetRecord(TransferHeader);
        TransferOrder.Run;
        //+NPR5.51 [358552]
    end;
}

