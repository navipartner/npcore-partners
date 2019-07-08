codeunit 6150731 "POS Action - Transfer Order"
{
    // NPR5.43/THRO/20180604 CASE 315072 Transfer order list


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built-in action for handling Transfer Orders';

    local procedure ActionCode(): Text
    begin
        exit ('TRANSFER_ORDER');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
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
        if UsePOSLocationAs > 0 then begin
          POSSession.GetSetup(POSSetup);
          POSSetup.GetRegisterRecord(Register);
          case UsePOSLocationAs of
            1 : TransferFromFilter := Register."Location Code";
            2 : TransferToFilter := Register."Location Code";
          end;
        end;
        if TransferFromFilter = '' then
          TransferFromFilter := JSON.GetString('Transfer-from Filter',true);
        if TransferToFilter = '' then
          TransferToFilter := JSON.GetString('Transfer-to Filter',true);

        if TransferFromFilter <> '' then
          TransferHeader.SetFilter("Transfer-from Code",TransferFromFilter);
        if TransferToFilter <> '' then
          TransferHeader.SetFilter("Transfer-to Code",TransferToFilter);

        PAGE.Run(5742,TransferHeader);

        POSSession.RequestRefreshData;
    end;
}

