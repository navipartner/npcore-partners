codeunit 6014487 "NPR DE Fiskaly DSFINVK Job"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        if Rec."Parameter String" = '' then begin
            SendDataWithError();
            TriggerExport();
        end
        else
            SendParameterStringData(Rec."Parameter String");
    end;

    local procedure SendDataWithError()
    var
        DSFINVKClosing: Record "NPR DSFINVK Closing";
        DEAuditSetup: Record "NPR DE Audit Setup";
        DSFINVKMng: Codeunit "NPR DE Fiskaly DSFINVK";
        DEAuditMgt: Codeunit "NPR DE Audit Mgt.";
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
        DSFINVKJson: JsonObject;
        DSFINVKResponseJson: JsonObject;
        AccessToken: Text;
    begin
        DEAuditSetup.Get();
        DSFINVKClosing.Reset();
        DSFINVKClosing.SetRange("Has Error", true);
        DSFINVKClosing.SetRange(State, DSFINVKClosing.State::" ");

        if DSFINVKClosing.FindSet(true) then
            repeat
                Clear(DSFINVKJson);
                Clear(DSFINVKResponseJson);
                Clear(AccessToken);

                if not DSFINVKMng.CreateDSFINVKDocument(DSFINVKJson, DSFINVKClosing) then
                    DEAuditMgt.SetDSFINVKErrorMsg(DSFINVKClosing);

                if not DEAuditMgt.GetJwtToken(AccessToken) then
                    DEAuditMgt.SetDSFINVKErrorMsg(DSFINVKClosing);

                DSFINVKClosing."Closing ID" := CreateGuid(); //Fiskaly does not allow update of Cash Point Closings 
                if not DEFiskalyCommunication.SendDSFINVK(DSFINVKJson, DSFINVKResponseJson, DEAuditSetup, 'PUT', '/cash_point_closings/' + Format(DSFINVKClosing."Closing ID", 0, 4), AccessToken) then
                    DEAuditMgt.SetDSFINVKErrorMsg(DSFINVKClosing)
                else begin
                    DSFINVKClosing.State := DSFINVKClosing.State::PENDING;
                    DSFINVKClosing."Has Error" := false;
                    Clear(DSFINVKClosing."Error Message");
                    DSFINVKClosing.Modify();
                end;
            until DSFINVKClosing.Next() = 0;
    end;

    local procedure SendParameterStringData(ParameterString: Text)
    var
        DSFINVKClosing: Record "NPR DSFINVK Closing";
        DEAuditSetup: Record "NPR DE Audit Setup";
        POSEntry: Record "NPR POS Entry";
        DSFINVKMng: Codeunit "NPR DE Fiskaly DSFINVK";
        DEAuditMgt: Codeunit "NPR DE Audit Mgt.";
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
        DSFINVKJson: JsonObject;
        DSFINVKResponseJson: JsonObject;
        NextClosingId: Integer;
        AccessToken: Text;
        PosUnit: Text;
        ClosingDate: Date;
    begin
        PosUnit := CopyStr(ParameterString, 1, StrPos(ParameterString, ';'));
        Evaluate(ClosingDate, CopyStr(ParameterString, (StrPos(ParameterString, ';') + 1), StrLen(ParameterString)));

        DSFINVKClosing.Reset();
        DSFINVKClosing.SetRange("POS Unit No.", PosUnit);
        DSFINVKClosing.SetRange("Closing Date", ClosingDate);
        if not DSFINVKClosing.FindFirst() then begin
            DSFINVKClosing.LockTable();
            POSEntry.Reset();
            POSEntry.SetRange("POS Unit No.", PosUnit);
            POSEntry.SetRange("Entry Date", ClosingDate);
            POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::Balancing);

            if not POSEntry.FindFirst() then
                exit;

            DSFINVKClosing.Reset();
            DSFINVKClosing.SetRange("POS Unit No.", PosUnit);
            if DSFINVKClosing.FindLast() then
                NextClosingId := DSFINVKClosing."DSFINVK Closing No." + 1
            else
                NextClosingId := 1;

            DSFINVKClosing.Init();
            DSFINVKClosing."DSFINVK Closing No." := NextClosingId;
            DSFINVKClosing."POS Unit No." := POSEntry."POS Unit No.";
            DSFINVKClosing."POS Entry No." := POSEntry."Entry No.";
            DSFINVKClosing."Closing Date" := WorkDate();
            DSFINVKClosing.Insert();
        end
        else
            if DSFINVKClosing.State <> DSFINVKClosing.State::" " then
                exit;

        if not DSFINVKMng.CreateDSFINVKDocument(DSFINVKJson, DSFINVKClosing) then begin
            DEAuditMgt.SetDSFINVKErrorMsg(DSFINVKClosing);
            exit;
        end;

        if not DEAuditMgt.GetJwtToken(AccessToken) then begin
            DEAuditMgt.SetDSFINVKErrorMsg(DSFINVKClosing);
            exit;
        end;

        DSFINVKClosing."Closing ID" := CreateGuid(); //Fiskaly does not allow update of Cash Point Closings 
        if not DEFiskalyCommunication.SendDSFINVK(DSFINVKJson, DSFINVKResponseJson, DEAuditSetup, 'PUT', '/cash_point_closings/' + Format(DSFINVKClosing."Closing ID", 0, 4), AccessToken) then begin
            DEAuditMgt.SetDSFINVKErrorMsg(DSFINVKClosing);
            exit;
        end;
        DSFINVKClosing.State := DSFINVKClosing.State::PENDING;
        DSFINVKClosing.Modify();
    end;

    procedure TriggerExport()
    var
        DSFINVKClosing: Record "NPR DSFINVK Closing";
        DEAuditSetup: Record "NPR DE Audit Setup";
        DSFINVKMng: Codeunit "NPR DE Fiskaly DSFINVK";
        DEAuditMgt: Codeunit "NPR DE Audit Mgt.";
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
        DSFINVKJson: JsonObject;
        DSFINVKResponseJson: JsonObject;
        AccessToken: Text;
    begin
        UpdateClosingState();
        DEAuditSetup.Get();
        DSFINVKClosing.Reset();
        DSFINVKClosing.SetRange(State, DSFINVKClosing.State::COMPLETED);

        if DSFINVKClosing.FindSet(true) then
            repeat
                if not DEAuditMgt.GetJwtToken(AccessToken) then
                    DEAuditMgt.SetDSFINVKErrorMsg(DSFINVKClosing);

                Clear(DSFINVKJson);
                DSFINVKJson.Add('start_date', DSFINVKMng.GetUnixTime(CreateDateTime(DSFINVKClosing."Closing Date", 0T)));
                DSFINVKJson.Add('end_date', DSFINVKMng.GetUnixTime(CreateDateTime(DSFINVKClosing."Closing Date", 235959T)));

                DSFINVKClosing."Export ID" := CreateGuid();
                if not DEFiskalyCommunication.SendDSFINVK(DSFINVKJson, DSFINVKResponseJson, DEAuditSetup, 'PUT', '/exports/' + Format(DSFINVKClosing."Export ID", 0, 4), AccessToken) then
                    DEAuditMgt.SetDSFINVKErrorMsg(DSFINVKClosing)
                else begin
                    DSFINVKClosing."Trigged Export" := true;
                    DSFINVKClosing."Has Error" := false;
                    Clear(DSFINVKClosing."Error Message");
                    DSFINVKClosing.Modify();
                end;
            until DSFINVKClosing.Next() = 0;
    end;

    local procedure UpdateClosingState()
    var
        DSFINVKClosing: Record "NPR DSFINVK Closing";
        DEAuditSetup: Record "NPR DE Audit Setup";
        DEAuditMgt: Codeunit "NPR DE Audit Mgt.";
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
        DSFINVKJson: JsonObject;
        DSFINVKResponseJson: JsonObject;
        AccessToken: Text;
    begin
        DEAuditSetup.Get();
        DSFINVKClosing.Reset();
        DSFINVKClosing.SetFilter(State, '%1|%2', DSFINVKClosing.State::PENDING, DSFINVKClosing.State::WORKING);

        if DSFINVKClosing.FindSet(true) then
            repeat
                if not DEAuditMgt.GetJwtToken(AccessToken) then
                    DEAuditMgt.SetDSFINVKErrorMsg(DSFINVKClosing);

                if not DEFiskalyCommunication.SendDSFINVK(DSFINVKJson, DSFINVKResponseJson, DEAuditSetup, 'GET', '/cash_point_closings/' + Format(DSFINVKClosing."Closing ID", 0, 4), AccessToken) then
                    DEAuditMgt.SetDSFINVKErrorMsg(DSFINVKClosing)
                else begin
                    DSFINVKClosing.State := GetClosingState(DSFINVKResponseJson);
                    DSFINVKClosing.Modify();
                end;
            until DSFINVKClosing.Next() = 0;
    end;

    procedure GetClosingState(DSFINVKResponseJson: JsonObject): Enum "NPR DSFINVK State"
    var
        DSFINVKState: Enum "NPR DSFINVK State";
        StateToken: JsonToken;
        StateValue: Text;
    begin
        DSFINVKResponseJson.SelectToken('state', StateToken);
        StateToken.WriteTo(StateValue);

        case StateValue of
            '"PENDING"':
                exit(DSFINVKState::PENDING);
            '"WORKING"':
                exit(DSFINVKState::WORKING);
            '"COMPLETED"':
                exit(DSFINVKState::COMPLETED);
            '"CANCELLED"':
                exit(DSFINVKState::CANCELLED);
            '"EXPIRED"':
                exit(DSFINVKState::EXPIRED);
            '"DELETED"':
                exit(DSFINVKState::DELETED);
            '"ERROR"':
                exit(DSFINVKState::ERROR);
        end;
        exit(DSFINVKState::" ");
    end;
}
