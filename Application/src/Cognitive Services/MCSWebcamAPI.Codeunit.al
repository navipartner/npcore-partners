codeunit 6059956 "NPR MCS Webcam API"
{
    var
        WebcamArgumentTable: Record "NPR MCS Webcam Arg. Table" temporary;
        CognitivityAPISetup: Record "NPR MCS API Setup";
        PersonGroupsSetup: Record "NPR MCS Person Groups Setup";
        PersonGroups: Record "NPR MCS Person Groups";
        Txt003: Label 'Salesperson does not exist';
        WebcamProxyTSD: Codeunit "NPR MCS Webcam Proxy TSD";
        RecRef: RecordRef;
        POSSession: Codeunit "NPR POS Session";
        FrontEnd: Codeunit "NPR POS Front End Management";



    procedure CallIdentifyStart(RecordVariant: Variant; var MCSWebcamArgumentTable: Record "NPR MCS Webcam Arg. Table"; ShowDialog: Boolean): Boolean
    begin
        if not RecordVariant.IsRecord then
            exit;

        RecRef.GetTable(RecordVariant);

        CognitivityAPISetup.Get(CognitivityAPISetup.API::Face);
        CognitivityAPISetup.TestField("Key 1");
        CognitivityAPISetup.TestField("Key 2");

        RecRef.GetTable(RecordVariant);
        PersonGroupsSetup.Get(RecRef.Number);
        PersonGroups.Get(PersonGroupsSetup."Person Groups Id");
        PersonGroups.TestField(PersonGroupId);

        MCSWebcamArgumentTable.Action := MCSWebcamArgumentTable.Action::IdentifyFaces;
        MCSWebcamArgumentTable."API Key 1" := CognitivityAPISetup.GetAPIKey1();
        MCSWebcamArgumentTable."API Key 2" := CognitivityAPISetup.GetAPIKey2();
        MCSWebcamArgumentTable."Person Group Id" := PersonGroups.PersonGroupId;
        MCSWebcamArgumentTable."Table Id" := RecRef.Number;

        WebcamArgumentTable."Image Orientation" := CognitivityAPISetup."Image Orientation";

        if (POSSession.IsActiveSession(FrontEnd)) then begin
            Clear(WebcamProxyTSD);
            WebcamProxyTSD.SetState(MCSWebcamArgumentTable);
            WebcamProxyTSD.InvokeDevice();
            WebcamProxyTSD.GetState(MCSWebcamArgumentTable);
        end else
            // TODO: CTRLUPGRADE - Obsolete functionality
            ERROR('CTRLUPGRADE');


        if MCSWebcamArgumentTable."Is Identified" then
            exit(true)
        else begin
            if ShowDialog then
                Error(Txt003);
            exit(false);
        end;
    end;
}

