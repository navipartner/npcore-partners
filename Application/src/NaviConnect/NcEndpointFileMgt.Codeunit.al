codeunit 6151526 "NPR Nc Endpoint File Mgt."
{
    Access = Internal;

    local procedure FileProcessOutput(NcTaskOutput: Record "NPR Nc Task Output"; NcEndpointFile: Record "NPR Nc Endpoint File")
    var
        InStr: InStream;
        Name: Text;
    begin
        NcEndpointFile.TestField(Path);

        case NcEndpointFile."File Encoding" of
            NcEndpointFile."File Encoding"::ANSI:
                NcTaskOutput.Data.CreateInStream(InStr, TextEncoding::Windows);
            NcEndpointFile."File Encoding"::UTF8:
                NcTaskOutput.Data.CreateInStream(InStr, TextEncoding::UTF8);
            else
                NcTaskOutput.Data.CreateInStream(InStr);
        end;

        Name := NcTaskOutput.Name;
        if NcEndpointFile."Client Path" then
            DownloadFromStream(InStr, 'Save file as...', NcEndpointFile.Path, 'All Files|*.*', Name);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Nc Endpoint Type", 'OnSetupEndpointTypes', '', false, false)]
    local procedure OnSetupEndpointTypeInsertEndpointTypeCode()
    var
        NcEndpointFile: Record "NPR Nc Endpoint File";
        NcEndpointType: Record "NPR Nc Endpoint Type";
    begin
        if not NcEndpointType.Get(NcEndpointFile.GetEndpointTypeCode()) then begin
            NcEndpointType.Init();
            NcEndpointType.Code := NcEndpointFile.GetEndpointTypeCode();
            NcEndpointType.Insert();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Nc Endpoint", 'OnOpenEndpointSetup', '', false, false)]
    local procedure OnOpenEndpointSetupOpenPage(var Sender: Record "NPR Nc Endpoint"; var Handled: Boolean)
    var
        NcEndpointFile: Record "NPR Nc Endpoint File";
    begin
        if Handled then
            exit;
        if Sender."Endpoint Type" <> NcEndpointFile.GetEndpointTypeCode() then
            exit;
        if not NcEndpointFile.Get(Sender.Code) then begin
            NcEndpointFile.Init();
            NcEndpointFile.Validate(Code, Sender.Code);
            NcEndpointFile.Description := Sender.Description;
            NcEndpointFile.Insert();
        end else begin
            if NcEndpointFile.Description <> Sender.Description then begin
                NcEndpointFile.Description := Sender.Description;
                NcEndpointFile.Modify(true);
            end;
        end;
        PAGE.Run(PAGE::"NPR Nc Endpoint File Card", NcEndpointFile);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Nc Endpoint", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnDeleteEndpoint(var Rec: Record "NPR Nc Endpoint"; RunTrigger: Boolean)
    var
        NcEndpointFile: Record "NPR Nc Endpoint File";
    begin
        if NcEndpointFile.Get(Rec.Code) then
            NcEndpointFile.Delete(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Nc Endpoint Mgt.", 'OnRunEndpoint', '', true, true)]
    local procedure OnRunEndpoint(NcTaskOutput: Record "NPR Nc Task Output"; NcEndpoint: Record "NPR Nc Endpoint")
    var
        NcEndpointFile: Record "NPR Nc Endpoint File";
    begin
        if NcEndpoint."Endpoint Type" <> NcEndpointFile.GetEndpointTypeCode() then
            exit;
        if not NcEndpointFile.Get(NcEndpoint.Code) then
            exit;

        FileProcessOutput(NcTaskOutput, NcEndpointFile);
    end;
}

