codeunit 6059956 "MCS Webcam API"
{
    // NPR5.29/CLVA/20170125 CASE 264333 Added functionality to support image orientation;
    // NPR5.33/TSA /20170629 CASE 279495 Adopted to transcendence
    // NPR5.35/TSA /20170809 CASE 276102 Wrong table reference in CallIdentifyStart()

    var
        WebcamArgumentTable: Record "MCS Webcam Argument Table" temporary;
        CognitivityAPISetup: Record "MCS API Setup";
        PersonGroupsSetup: Record "MCS Person Groups Setup";
        PersonGroups: Record "MCS Person Groups";
        OutS: OutStream;
        Convert: DotNet npNetConvert;
        Bytes: DotNet npNetArray;
        MemoryStream: DotNet npNetMemoryStream;
        // TODO: CTRLUPGRADE - obsolete Standard functionality
        //ProxyDialog: Page "Proxy Dialog";
        // TODO: CTRLUPGRADE - obsolete Standard functionality
        //WebcamProxy: Codeunit "MCS Webcam Proxy";
        Txt003: Label 'Salesperson does not exist';
        WebcamProxyTSD: Codeunit "MCS Webcam Proxy TSD";
        RecRef: RecordRef;
        POSSession: Codeunit "POS Session";
        FrontEnd: Codeunit "POS Front End Management";
        Base64String: Text;

    procedure CallCaptureStartByMMMemberInfoCapture(var MMMemberInfoCapture: Record "MM Member Info Capture"; ModifyVar: Boolean)
    var
        MemberName: Text;
        WebcamProxyTSD: Codeunit "MCS Webcam Proxy TSD";
    begin
        RecRef := MMMemberInfoCapture.RecordId.GetRecord;
        WebcamArgumentTable.Action := WebcamArgumentTable.Action::CaptureImage;
        WebcamArgumentTable.Key := MMMemberInfoCapture.RecordId;
        WebcamArgumentTable."Table Id" := RecRef.Number;

        if CognitivityAPISetup.Get(CognitivityAPISetup.API::Face) then begin
            //-NPR5.29
            WebcamArgumentTable."Image Orientation" := CognitivityAPISetup."Image Orientation";
            //+NPR5.29
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
                WebcamArgumentTable."API Key 1" := CognitivityAPISetup."Key 1";
                WebcamArgumentTable."API Key 2" := CognitivityAPISetup."Key 2";
                WebcamArgumentTable."Person Group Id" := PersonGroups.PersonGroupId;

                MemberName := MMMemberInfoCapture."First Name";
                if MMMemberInfoCapture."Middle Name" <> '' then
                    MemberName := MemberName + ' ' + MMMemberInfoCapture."Middle Name";
                if MMMemberInfoCapture."Last Name" <> '' then
                    MemberName := MemberName + ' ' + MMMemberInfoCapture."Last Name";

                WebcamArgumentTable.Name := MemberName;
            end;
        end;

        //#-279495 [279495]
        // WebcamProxy.InitializeProtocol();
        // WebcamProxy.SetState(WebcamArgumentTable);
        // ProxyDialog.RunProtocolModal(CODEUNIT::"MCS Webcam Proxy");
        //
        // IF WebcamProxy.GetBase64String <> '' THEN BEGIN
        //   Bytes := Convert.FromBase64String(WebcamProxy.GetBase64String);
        //   MemoryStream := MemoryStream.MemoryStream(Bytes);
        //   MMMemberInfoCapture.Picture.CREATEOUTSTREAM(OutS);
        //   MemoryStream.WriteTo(OutS);
        //   IF ModifyVar THEN
        //     MMMemberInfoCapture.MODIFY;
        // END;

        if (POSSession.IsActiveSession(FrontEnd)) then begin
            Clear(WebcamProxyTSD);
            WebcamProxyTSD.SetState(WebcamArgumentTable);
            WebcamProxyTSD.InvokeDevice();
            Base64String := WebcamProxyTSD.GetBase64String();
        end else begin
            // TODO: CTRLUPGRADE - Invkoing old functionality
            ERROR('CTRLUPGRADE');
            /*
            WebcamProxy.InitializeProtocol();
            WebcamProxy.SetState(WebcamArgumentTable);
            ProxyDialog.RunProtocolModal(CODEUNIT::"MCS Webcam Proxy");
            Base64String := WebcamProxy.GetBase64String();
            */
        end;

        if Base64String <> '' then begin
            Bytes := Convert.FromBase64String(Base64String);
            MemoryStream := MemoryStream.MemoryStream(Bytes);
            MMMemberInfoCapture.Picture.CreateOutStream(OutS);
            MemoryStream.WriteTo(OutS);
            if ModifyVar then
                MMMemberInfoCapture.Modify;
        end;
        //#+279495 [279495]
    end;

    procedure CallCaptureStartByMMMember(var MMMember: Record "MM Member"; ModifyVar: Boolean)
    var
        MemberName: Text;
    begin
        RecRef := MMMember.RecordId.GetRecord;
        WebcamArgumentTable.Action := WebcamArgumentTable.Action::CaptureImage;
        WebcamArgumentTable.Key := MMMember.RecordId;
        WebcamArgumentTable."Table Id" := RecRef.Number;

        if CognitivityAPISetup.Get(CognitivityAPISetup.API::Face) then begin
            //-NPR5.29
            WebcamArgumentTable."Image Orientation" := CognitivityAPISetup."Image Orientation";
            //+NPR5.29
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
                WebcamArgumentTable."API Key 1" := CognitivityAPISetup."Key 1";
                WebcamArgumentTable."API Key 2" := CognitivityAPISetup."Key 2";
                WebcamArgumentTable."Person Group Id" := PersonGroups.PersonGroupId;

                MemberName := MMMember."First Name";
                if MMMember."Middle Name" <> '' then
                    MemberName := MemberName + ' ' + MMMember."Middle Name";
                if MMMember."Last Name" <> '' then
                    MemberName := MemberName + ' ' + MMMember."Last Name";

                WebcamArgumentTable.Name := MemberName;
            end;
        end;

        //#-279495 [279495]
        // WebcamProxy.InitializeProtocol();
        // WebcamProxy.SetState(WebcamArgumentTable);
        // ProxyDialog.RunProtocolModal(CODEUNIT::"MCS Webcam Proxy");
        //
        // IF WebcamProxy.GetBase64String <> '' THEN BEGIN
        //  Bytes := Convert.FromBase64String(WebcamProxy.GetBase64String);
        //  MemoryStream := MemoryStream.MemoryStream(Bytes);
        //  MMMember.Picture.CREATEOUTSTREAM(OutS);
        //  MemoryStream.WriteTo(OutS);
        //  IF ModifyVar THEN
        //    MMMember.MODIFY;
        // END;

        if (POSSession.IsActiveSession(FrontEnd)) then begin
            Clear(WebcamProxyTSD);
            WebcamProxyTSD.SetState(WebcamArgumentTable);
            WebcamProxyTSD.InvokeDevice();
            Base64String := WebcamProxyTSD.GetBase64String();
        end else begin
            // TODO: CTRLUPGRADE - Obsolete functionality
            ERROR('CTRLUPGRADE');
            /*
            WebcamProxy.InitializeProtocol();
            WebcamProxy.SetState(WebcamArgumentTable);
            ProxyDialog.RunProtocolModal(CODEUNIT::"MCS Webcam Proxy");
            Base64String := WebcamProxy.GetBase64String();
            */
        end;

        if Base64String <> '' then begin
            Bytes := Convert.FromBase64String(Base64String);
            MemoryStream := MemoryStream.MemoryStream(Bytes);
            MMMember.Picture.CreateOutStream(OutS);
            MemoryStream.WriteTo(OutS);
            if ModifyVar then
                MMMember.Modify;
        end;
        //#+279495 [279495]
    end;

    procedure CallIdentifyStart(RecordVariant: Variant; var MCSWebcamArgumentTable: Record "MCS Webcam Argument Table"; ShowDialog: Boolean): Boolean
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
        MCSWebcamArgumentTable."API Key 1" := CognitivityAPISetup."Key 1";
        MCSWebcamArgumentTable."API Key 2" := CognitivityAPISetup."Key 2";
        MCSWebcamArgumentTable."Person Group Id" := PersonGroups.PersonGroupId;
        MCSWebcamArgumentTable."Table Id" := RecRef.Number;
        //-NPR5.29
        WebcamArgumentTable."Image Orientation" := CognitivityAPISetup."Image Orientation";
        //+NPR5.29

        //#-279495 [279495]
        // WebcamProxy.InitializeProtocol();
        // WebcamProxy.SetState(MCSWebcamArgumentTable);
        // ProxyDialog.RunProtocolModal(CODEUNIT::"MCS Webcam Proxy");
        // WebcamProxy.GetState(MCSWebcamArgumentTable);
        if (POSSession.IsActiveSession(FrontEnd)) then begin
            Clear(WebcamProxyTSD);
            //-NPR5.35 [276102]
            //WebcamProxyTSD.SetState(WebcamArgumentTable);
            WebcamProxyTSD.SetState(MCSWebcamArgumentTable);
            //+NPR5.35 [276102]
            WebcamProxyTSD.InvokeDevice();
            WebcamProxyTSD.GetState(MCSWebcamArgumentTable);
        end else begin
            // TODO: CTRLUPGRADE - Obsolete functionality
            ERROR('CTRLUPGRADE');
            /*
            WebcamProxy.InitializeProtocol();
            WebcamProxy.SetState(MCSWebcamArgumentTable);
            ProxyDialog.RunProtocolModal(CODEUNIT::"MCS Webcam Proxy");
            WebcamProxy.GetState(MCSWebcamArgumentTable);
            */
        end;
        //#-279495 [279495]

        if MCSWebcamArgumentTable."Is Identified" then
            exit(true)
        else begin
            if ShowDialog then
                Error(Txt003);
            exit(false);
        end;
    end;
}

