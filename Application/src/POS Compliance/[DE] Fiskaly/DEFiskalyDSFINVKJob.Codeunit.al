codeunit 6014487 "NPR DE Fiskaly DSFINVK Job"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        if Rec."Parameter String" = '' then begin
            SendWithoutParameterData();
            TriggerExport();
        end else
            SendParameterStringData(Rec."Parameter String");
    end;

    local procedure SendWithoutParameterData()
    var
        DSFINVKClosing: Record "NPR DSFINVK Closing";
    begin
        DSFINVKClosing.SetCurrentKey(State, "Has Error");
        DSFINVKClosing.SetLoadFields("POS Unit No.", "Closing Date", "Closing ID");
        DSFINVKClosing.SetRange(State, DSFINVKClosing.State::" ");
        DSFINVKClosing.SetRange("Has Error", true);
        if DSFINVKClosing.FindSet(true) then
            repeat
                SendDataWithError(DSFINVKClosing);
            until DSFINVKClosing.Next() = 0;
    end;

    local procedure SendParameterStringData(ParameterString: Text)
    var
        ConnectionParameters: Record "NPR DE Audit Setup";
        DSFINVKClosing: Record "NPR DSFINVK Closing";
        POSEntry: Record "NPR POS Entry";
        DEAuditMgt: Codeunit "NPR DE Audit Mgt.";
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
        DSFINVKMng: Codeunit "NPR DE Fiskaly DSFINVK";
        ClosingDate: Date;
        DSFINVKJson: JsonObject;
        DSFINVKResponseJson: JsonToken;
        PosUnit: Code[10];
    begin
        PosUnit := CopyStr(ParameterString, 1, StrPos(ParameterString, ';'));
        Evaluate(ClosingDate, CopyStr(ParameterString, (StrPos(ParameterString, ';') + 1), StrLen(ParameterString)));

        DSFINVKClosing.Reset();
        DSFINVKClosing.SetRange("POS Unit No.", PosUnit);
        DSFINVKClosing.SetRange("Closing Date", ClosingDate);
        if not DSFINVKClosing.FindFirst() then begin
            GetPOSEntryForDSFINVKClosing(POSEntry, PosUnit, ClosingDate);

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
            DSFINVKClosing.ReadIsolation := IsolationLevel::UpdLock;
#else
            DSFINVKClosing.LockTable();
#endif
            DSFINVKClosing.Init();
            DSFINVKClosing."DSFINVK Closing No." := GetNextClosingNo(PosUnit);
            DSFINVKClosing."POS Unit No." := POSEntry."POS Unit No.";
            DSFINVKClosing."POS Entry No." := POSEntry."Entry No.";
            DSFINVKClosing."Closing Date" := WorkDate();
            DSFINVKClosing.Insert();
        end
        else
            if DSFINVKClosing.State <> DSFINVKClosing.State::" " then
                exit;

        if not ConnectionParameters.GetSetup(DSFINVKClosing) then begin
            DEAuditMgt.SetDSFINVKErrorMsg(DSFINVKClosing);
            exit;
        end;

        if not DSFINVKMng.CreateDSFINVKDocument(DSFINVKJson, DSFINVKClosing) then begin
            DEAuditMgt.SetDSFINVKErrorMsg(DSFINVKClosing);
            exit;
        end;

        DSFINVKClosing."Closing ID" := CreateGuid(); //Fiskaly does not allow update of Cash Point Closings
        if not DEFiskalyCommunication.SendRequest_DSFinV_K(DSFINVKJson, DSFINVKResponseJson, ConnectionParameters, 'PUT', StrSubstNo('/cash_point_closings/%1', Format(DSFINVKClosing."Closing ID", 0, 4))) then begin
            DEAuditMgt.SetDSFINVKErrorMsg(DSFINVKClosing);
            exit;
        end;
        DSFINVKClosing.State := DSFINVKClosing.State::PENDING;
        DSFINVKClosing.Modify();
    end;

    procedure TriggerExport()
    var
        ConnectionParameters: Record "NPR DE Audit Setup";
        DSFINVKClosing: Record "NPR DSFINVK Closing";
        DSFINVKClosing2: Record "NPR DSFINVK Closing";
        DEAuditMgt: Codeunit "NPR DE Audit Mgt.";
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
        DSFINVKMng: Codeunit "NPR DE Fiskaly DSFINVK";
        Success: Boolean;
        DSFINVKJson: JsonObject;
        DSFINVKResponseJson: JsonToken;
    begin
        UpdateClosingState();
        DSFINVKClosing.SetCurrentKey(State);
        DSFINVKClosing.SetRange(State, DSFINVKClosing.State::COMPLETED);
        if DSFINVKClosing.FindSet(true) then
            repeat
                Clear(DSFINVKJson);
                DSFINVKClosing2 := DSFINVKClosing;

                Success := ConnectionParameters.GetSetup(DSFINVKClosing2);
                if Success then begin
                    DSFINVKJson.Add('start_date', DSFINVKMng.GetUnixTime(CreateDateTime(DSFINVKClosing2."Closing Date", 0T)));
                    DSFINVKJson.Add('end_date', DSFINVKMng.GetUnixTime(CreateDateTime(DSFINVKClosing2."Closing Date", 235959T)));
                    DSFINVKClosing2."Export ID" := CreateGuid();
                    Success := DEFiskalyCommunication.SendRequest_DSFinV_K(DSFINVKJson, DSFINVKResponseJson, ConnectionParameters, 'PUT', StrSubstNo('/exports/%1', Format(DSFINVKClosing2."Export ID", 0, 4)));
                end;

                if not Success then
                    DEAuditMgt.SetDSFINVKErrorMsg(DSFINVKClosing2)
                else begin
                    DSFINVKClosing2."Trigged Export" := true;
                    DSFINVKClosing2."Has Error" := false;
                    Clear(DSFINVKClosing2."Error Message");
                    DSFINVKClosing2.Modify();
                end;
            until DSFINVKClosing.Next() = 0;
    end;

    local procedure UpdateClosingState()
    var
        ConnectionParameters: Record "NPR DE Audit Setup";
        DSFINVKClosing: Record "NPR DSFINVK Closing";
        DSFINVKClosing2: Record "NPR DSFINVK Closing";
        DEAuditMgt: Codeunit "NPR DE Audit Mgt.";
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
        Success: Boolean;
        DSFINVKJson: JsonObject;
        DSFINVKResponseJson: JsonToken;
    begin
        DSFINVKClosing.SetCurrentKey(State);
        DSFINVKClosing.SetFilter(State, '%1|%2', DSFINVKClosing.State::PENDING, DSFINVKClosing.State::WORKING);
        if DSFINVKClosing.FindSet(true) then
            repeat
                DSFINVKClosing2 := DSFINVKClosing;

                Success := ConnectionParameters.GetSetup(DSFINVKClosing2);
                if Success then
                    Success := DEFiskalyCommunication.SendRequest_DSFinV_K(DSFINVKJson, DSFINVKResponseJson, ConnectionParameters, 'GET', StrSubstNo('/cash_point_closings/%1', Format(DSFINVKClosing2."Closing ID", 0, 4)));

                if not Success then
                    DEAuditMgt.SetDSFINVKErrorMsg(DSFINVKClosing2)
                else begin
                    DSFINVKClosing2.State := GetClosingState(DSFINVKResponseJson);
                    DSFINVKClosing2.Modify();
                end;
            until DSFINVKClosing.Next() = 0;
    end;

    local procedure SendDataWithError(DSFINVKClosing: Record "NPR DSFINVK Closing")
    var
        ConnectionParameters: Record "NPR DE Audit Setup";
        DSFINVKClosing2: Record "NPR DSFINVK Closing";
        DEAuditMgt: Codeunit "NPR DE Audit Mgt.";
        DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
        DSFINVKMng: Codeunit "NPR DE Fiskaly DSFINVK";
        Success: Boolean;
        DSFINVKJson: JsonObject;
        DSFINVKResponseJson: JsonToken;
    begin
        DSFINVKClosing2 := DSFINVKClosing;

        Success := ConnectionParameters.GetSetup(DSFINVKClosing2);
        if Success then
            Success := DSFINVKMng.CreateDSFINVKDocument(DSFINVKJson, DSFINVKClosing2);
        if Success then begin
            DSFINVKClosing2."Closing ID" := CreateGuid(); //Fiskaly does not allow update of Cash Point Closings
            Success := DEFiskalyCommunication.SendRequest_DSFinV_K(DSFINVKJson, DSFINVKResponseJson, ConnectionParameters, 'PUT', StrSubstNo('/cash_point_closings/%1', Format(DSFINVKClosing2."Closing ID", 0, 4)));
        end;

        if not Success then
            DEAuditMgt.SetDSFINVKErrorMsg(DSFINVKClosing2)
        else begin
            DSFINVKClosing2.State := DSFINVKClosing2.State::PENDING;
            DSFINVKClosing2."Has Error" := false;
            Clear(DSFINVKClosing2."Error Message");
            DSFINVKClosing2.Modify();
        end;
    end;

    local procedure GetNextClosingNo(PosUnit: Code[10]) NextClosingId: Integer
    var
        DSFINVKClosing: Record "NPR DSFINVK Closing";
    begin
        DSFINVKClosing.Reset();
        DSFINVKClosing.SetRange("POS Unit No.", PosUnit);
        if DSFINVKClosing.FindLast() then
            NextClosingId := DSFINVKClosing."DSFINVK Closing No." + 1
        else
            NextClosingId := 1;
    end;

    local procedure GetPOSEntryForDSFINVKClosing(var POSEntry: Record "NPR POS Entry"; PosUnit: Code[10]; ClosingDate: Date)
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        POSEntry.ReadIsolation := IsolationLevel::ReadCommitted;
#endif
        POSEntry.SetLoadFields("POS Unit No.", "Entry No.");
        POSEntry.SetRange("POS Unit No.", PosUnit);
        POSEntry.SetRange("Entry Date", ClosingDate);
        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::Balancing);

        if not POSEntry.FindFirst() then
            exit;
    end;

    procedure GetClosingState(DSFINVKResponseJson: JsonToken): Enum "NPR DSFINVK State"
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
            else
                exit(DSFINVKState::" ");
        end;
    end;
}
