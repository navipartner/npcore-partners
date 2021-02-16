codeunit 6059956 "NPR MCS Webcam API"
{
    var
        WebcamArgumentTable: Record "NPR MCS Webcam Arg. Table" temporary;
        CognitivityAPISetup: Record "NPR MCS API Setup";
        PersonGroupsSetup: Record "NPR MCS Person Groups Setup";
        PersonGroups: Record "NPR MCS Person Groups";
        OutS: OutStream;
        Txt003: Label 'Salesperson does not exist';
        WebcamProxyTSD: Codeunit "NPR MCS Webcam Proxy TSD";
        RecRef: RecordRef;
        POSSession: Codeunit "NPR POS Session";
        FrontEnd: Codeunit "NPR POS Front End Management";
        Base64String: Text;

    procedure CallCaptureStartByMMMemberInfoCapture(var MMMemberInfoCapture: Record "NPR MM Member Info Capture"; ModifyVar: Boolean)
    var
        MemberName: Text;
        WebcamProxyTSD: Codeunit "NPR MCS Webcam Proxy TSD";
        Base64Convert: Codeunit "Base64 Convert";
    begin
        RecRef := MMMemberInfoCapture.RecordId.GetRecord;
        WebcamArgumentTable.Action := WebcamArgumentTable.Action::CaptureImage;
        WebcamArgumentTable.Key := MMMemberInfoCapture.RecordId;
        WebcamArgumentTable."Table Id" := RecRef.Number;

        if CognitivityAPISetup.Get(CognitivityAPISetup.API::Face) then begin
            WebcamArgumentTable."Image Orientation" := CognitivityAPISetup."Image Orientation";
            if CognitivityAPISetup."Use Cognitive Services" then begin

                MMMemberInfoCapture.TestField("Entry No.");
                MMMemberInfoCapture.TestField("First Name");

                CognitivityAPISetup.TestField("Key 1");
                CognitivityAPISetup.TestField("Key 2");

                PersonGroupsSetup.Get(RecRef.Number);
                PersonGroups.Get(PersonGroupsSetup."Person Groups Id");
                PersonGroups.TestField(PersonGroupId);

                WebcamArgumentTable.Action := WebcamArgumentTable.Action::CaptureAndIdentifyFaces;
                WebcamArgumentTable."Allow Saving On Identifyed" := true;
                WebcamArgumentTable."API Key 1" := CognitivityAPISetup.GetAPIKey1();
                WebcamArgumentTable."API Key 2" := CognitivityAPISetup.GetAPIKey2();
                WebcamArgumentTable."Person Group Id" := PersonGroups.PersonGroupId;

                MemberName := MMMemberInfoCapture."First Name";
                if MMMemberInfoCapture."Middle Name" <> '' then
                    MemberName := MemberName + ' ' + MMMemberInfoCapture."Middle Name";
                if MMMemberInfoCapture."Last Name" <> '' then
                    MemberName := MemberName + ' ' + MMMemberInfoCapture."Last Name";

                WebcamArgumentTable.Name := MemberName;
            end;
        end;

        if (POSSession.IsActiveSession(FrontEnd)) then begin
            Clear(WebcamProxyTSD);
            WebcamProxyTSD.SetState(WebcamArgumentTable);
            WebcamProxyTSD.InvokeDevice();
            Base64String := WebcamProxyTSD.GetBase64String();
        end else
            // TODO: CTRLUPGRADE - Invkoing old functionality
            ERROR('CTRLUPGRADE');


        if Base64String <> '' then begin
            MMMemberInfoCapture.Picture.CreateOutStream(OutS);
            OutS.Write(Base64Convert.FromBase64(Base64String));
            if ModifyVar then
                MMMemberInfoCapture.Modify;
        end;
    end;

    procedure CallCaptureStartByMMMember(var MMMember: Record "NPR MM Member"; ModifyVar: Boolean)
    var
        MemberName: Text;
        Base64Convert: Codeunit "Base64 Convert";
    begin
        RecRef := MMMember.RecordId.GetRecord;
        WebcamArgumentTable.Action := WebcamArgumentTable.Action::CaptureImage;
        WebcamArgumentTable.Key := MMMember.RecordId;
        WebcamArgumentTable."Table Id" := RecRef.Number;

        if CognitivityAPISetup.Get(CognitivityAPISetup.API::Face) then begin

            WebcamArgumentTable."Image Orientation" := CognitivityAPISetup."Image Orientation";

            if CognitivityAPISetup."Use Cognitive Services" then begin

                MMMember.TestField("Entry No.");
                MMMember.TestField("First Name");

                CognitivityAPISetup.TestField("Key 1");
                CognitivityAPISetup.TestField("Key 2");

                PersonGroupsSetup.Get(RecRef.Number);
                PersonGroups.Get(PersonGroupsSetup."Person Groups Id");
                PersonGroups.TestField(PersonGroupId);

                WebcamArgumentTable.Action := WebcamArgumentTable.Action::CaptureAndIdentifyFaces;
                WebcamArgumentTable."Allow Saving On Identifyed" := true;
                WebcamArgumentTable."API Key 1" := CognitivityAPISetup.GetAPIKey1();
                WebcamArgumentTable."API Key 2" := CognitivityAPISetup.GetAPIKey2();
                WebcamArgumentTable."Person Group Id" := PersonGroups.PersonGroupId;

                MemberName := MMMember."First Name";
                if MMMember."Middle Name" <> '' then
                    MemberName := MemberName + ' ' + MMMember."Middle Name";
                if MMMember."Last Name" <> '' then
                    MemberName := MemberName + ' ' + MMMember."Last Name";

                WebcamArgumentTable.Name := MemberName;
            end;
        end;

        if (POSSession.IsActiveSession(FrontEnd)) then begin
            Clear(WebcamProxyTSD);
            WebcamProxyTSD.SetState(WebcamArgumentTable);
            WebcamProxyTSD.InvokeDevice();
            Base64String := WebcamProxyTSD.GetBase64String();
        end else
            // TODO: CTRLUPGRADE - Obsolete functionality
            ERROR('CTRLUPGRADE');

        if Base64String <> '' then begin
            MMMember.Picture.CreateOutStream(OutS);
            OutS.Write(Base64Convert.FromBase64(Base64String));
            if ModifyVar then
                MMMember.Modify;
        end;
    end;

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

