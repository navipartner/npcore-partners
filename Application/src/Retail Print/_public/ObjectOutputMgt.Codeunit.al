codeunit 6014580 "NPR Object Output Mgt."
{
    var
        ErrNoOutputFound: Label 'No output found for\Object: %1 %2\Template: %3';
        Error_UnsupportedOutput: Label 'Output Type %1 is not supported for %2';

    internal procedure GetCodeunitOutputPath(ObjectID: Integer) Path: Text[250]
    var
        ObjectOutputSelection: Record "NPR Object Output Selection";
    begin
        Path := GetOutputPath(ObjectOutputSelection."Object Type"::Codeunit, ObjectID, '');
    end;

    internal procedure GetCodeunitOutputPath2(ObjectID: Integer; PrintCode: Code[20]) Path: Text[250]
    var
        ObjectOutputSelection: Record "NPR Object Output Selection";
    begin
        Path := GetOutputPath(ObjectOutputSelection."Object Type"::Codeunit, ObjectID, PrintCode);
    end;

    internal procedure GetOutputPath(ObjectType: Integer; ObjectID: Integer; PrintCode: Code[20]) Path: Text[250]
    var
        ObjectOutputSelection: Record "NPR Object Output Selection";
    begin
        if TryGetOutputRec(ObjectType, ObjectID, PrintCode, UserId, ObjectOutputSelection) then
            Path := ObjectOutputSelection."Output Path"
        else begin
            ObjectOutputSelection."Object Type" := ObjectType;
            Error(ErrNoOutputFound, Format(ObjectOutputSelection."Object Type"), ObjectID, PrintCode);
        end;
    end;

    internal procedure GetCodeunitOutputType(ObjectID: Integer): Integer
    var
        ObjectOutputSelection: Record "NPR Object Output Selection";
    begin
        exit(GetOutputType(ObjectOutputSelection."Object Type"::Codeunit, ObjectID, ''));
    end;

    internal procedure GetCodeunitOutputType2(ObjectID: Integer; PrintCode: Code[20]): Integer
    var
        ObjectOutputSelection: Record "NPR Object Output Selection";
    begin
        exit(GetOutputType(ObjectOutputSelection."Object Type"::Codeunit, ObjectID, PrintCode));
    end;

    internal procedure GetOutputType(ObjectType: Integer; ObjectID: Integer; PrintCode: Code[20]): Integer
    var
        ObjectOutputSelection: Record "NPR Object Output Selection";
    begin
        if TryGetOutputRec(ObjectType, ObjectID, PrintCode, UserId, ObjectOutputSelection) then
            exit(ObjectOutputSelection."Output Type".AsInteger())
        else begin
            ObjectOutputSelection."Object Type" := ObjectType;
            Error(ErrNoOutputFound, Format(ObjectOutputSelection."Object Type"), ObjectID, PrintCode);
        end;
    end;

    procedure TryGetOutputRec(ObjectType: Integer; ObjectID: Integer; PrintCode: Code[20]; User: Text; var ObjectOutputSelection: Record "NPR Object Output Selection"): Boolean
    begin
        if ObjectOutputSelection.Get(User, ObjectType, ObjectID, PrintCode) then
            exit(true);

        if ObjectID <> 0 then
            if ObjectOutputSelection.Get(User, ObjectType, 0, PrintCode) then
                exit(true);

        if StrLen(PrintCode) > 0 then
            if ObjectOutputSelection.Get(User, ObjectType, ObjectID, '') then
                exit(true);

        if not ((ObjectID = 0) and (StrLen(PrintCode) = 0)) then
            if ObjectOutputSelection.Get(User, ObjectType, 0, '') then
                exit(true);

        if StrLen(User) = 0 then
            exit(false)
        else
            exit(TryGetOutputRec(ObjectType, ObjectID, PrintCode, '', ObjectOutputSelection));
    end;

#pragma warning disable AA0139
    local procedure TryGetPrintOutput(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer; var ObjectOutputSelection: Record "NPR Object Output Selection"): Boolean
    begin
        case true of
            ReportId <> 0:
                if not TryGetOutputRec(ObjectOutputSelection."Object Type"::Report, ReportId, TemplateCode, UserId, ObjectOutputSelection) then
                    exit(false);

            CodeunitId <> 0,
          TemplateCode <> '':
                if not TryGetOutputRec(ObjectOutputSelection."Object Type"::Codeunit, CodeunitId, TemplateCode, UserId, ObjectOutputSelection) then
                    exit(false);
            else
                exit(false);
        end;

        exit(true);
    end;
#pragma warning restore AA0139

    internal procedure PrintMatrixJob(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer; var Printer: Interface "NPR IMatrix Printer"; NoOfPrints: Integer)
    var
        ObjectOutput: Record "NPR Object Output Selection";
        PrintMethodMgt: Codeunit "NPR Print Method Mgt.";
        PrintJob: Text;
        HTTPEndpoint: Text;
        Skip: Boolean;
        i: Integer;
    begin
        if NoOfPrints < 1 then
            exit;
        OnBeforeSendMatrixPrint(TemplateCode, CodeunitId, ReportId, Printer, NoOfPrints, Skip);
        if Skip then
            exit;

        if not TryGetPrintOutput(TemplateCode, CodeunitId, ReportId, ObjectOutput) then
            exit;

        case ObjectOutput."Output Type" of
            ObjectOutput."Output Type"::"Printer Name":
                begin
                    PrintJob := Printer.GetPrintBufferAsBase64();
                    for i := 1 to NoOfPrints do
                        PrintMethodMgt.PrintBytesLocal(ObjectOutput."Output Path", PrintJob);
                end;

            ObjectOutput."Output Type"::HTTP:
                begin
                    if not Printer.PrepareJobForHTTP(HTTPEndpoint) then
                        Error(Error_UnsupportedOutput, Format(ObjectOutput."Output Type"::HTTP), TemplateCode);
                    PrintJob := Printer.GetPrintBufferAsBase64();
                    for i := 1 to NoOfPrints do
                        PrintMethodMgt.PrintBytesHTTP(ObjectOutput."Output Path", HTTPEndpoint, PrintJob);
                end;

            ObjectOutput."Output Type"::Bluetooth:
                begin
                    if not Printer.PrepareJobForBluetooth() then
                        Error(Error_UnsupportedOutput, Format(ObjectOutput."Output Type"::Bluetooth), TemplateCode);
                    PrintJob := Printer.GetPrintBufferAsBase64();
                    for i := 1 to NoOfPrints do
                        PrintMethodMgt.PrintBytesBluetooth(ObjectOutput."Output Path", PrintJob);
                end;
            ObjectOutput."Output Type"::"PrintNode Raw":
                begin
                    PrintJob := Printer.GetPrintBufferAsBase64();
                    for i := 1 to NoOfPrints do
                        PrintMethodMgt.PrintViaPrintNodeRaw(ObjectOutput."Output Path", PrintJob, 1, CodeunitId);
                end;
        end;
    end;

    internal procedure PrintLineJob(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer; var Printer: Interface "NPR ILine Printer"; NoOfPrints: Integer)
    var
        ObjectOutput: Record "NPR Object Output Selection";
        PrintMethodMgt: Codeunit "NPR Print Method Mgt.";
        PrintJob: Text;
        HTTPEndpoint: Text;
        Skip: Boolean;
        i: Integer;
    begin
        if NoOfPrints < 1 then
            exit;
        OnBeforeSendLinePrint(TemplateCode, CodeunitId, ReportId, Printer, NoOfPrints, Skip);
        if Skip then
            exit;
        if not TryGetPrintOutput(TemplateCode, CodeunitId, ReportId, ObjectOutput) then
            exit;


        case ObjectOutput."Output Type" of
            ObjectOutput."Output Type"::"Printer Name":
                begin
                    PrintJob := Printer.GetPrintBufferAsBase64();
                    for i := 1 to NoOfPrints do
                        PrintMethodMgt.PrintBytesLocal(ObjectOutput."Output Path", PrintJob);
                end;

            ObjectOutput."Output Type"::HTTP:
                begin
                    if not Printer.PrepareJobForHTTP(HTTPEndpoint) then
                        Error(Error_UnsupportedOutput, Format(ObjectOutput."Output Type"::HTTP), TemplateCode);
                    PrintJob := Printer.GetPrintBufferAsBase64();
                    for i := 1 to NoOfPrints do
                        PrintMethodMgt.PrintBytesHTTP(ObjectOutput."Output Path", HTTPEndpoint, PrintJob);
                end;

            ObjectOutput."Output Type"::Bluetooth:
                begin
                    if not Printer.PrepareJobForBluetooth() then
                        Error(Error_UnsupportedOutput, Format(ObjectOutput."Output Type"::Bluetooth), TemplateCode);
                    PrintJob := Printer.GetPrintBufferAsBase64();
                    for i := 1 to NoOfPrints do
                        PrintMethodMgt.PrintBytesBluetooth(ObjectOutput."Output Path", PrintJob);
                end;

            ObjectOutput."Output Type"::"PrintNode Raw":
                begin
                    PrintJob := Printer.GetPrintBufferAsBase64();
                    for i := 1 to NoOfPrints do
                        PrintMethodMgt.PrintViaPrintNodeRaw(ObjectOutput."Output Path", PrintJob, 1, CodeunitId);
                end;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSendMatrixPrint(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer; var Printer: Interface "NPR IMatrix Printer"; NoOfPrints: Integer; var Skip: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSendLinePrint(TemplateCode: Text; CodeunitId: Integer; ReportId: Integer; var Printer: Interface "NPR ILine Printer"; NoOfPrints: Integer; var Skip: Boolean)
    begin
    end;
}

