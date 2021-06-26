codeunit 6014507 "NPR Blob To Media Migration JQ"
{
    TableNo = "Job Queue Entry";
    Permissions =
        tabledata "NPR Blob To Media Migration" = rim,
        tabledata "NPR AF Args: Spire Barcode" = rm,
        tabledata "NPR MCS Faces" = rm,
        tabledata "NPR Magento Picture" = rm,
        tabledata "NPR MM Member" = rm,
        tabledata "NPR MPOS QR Code" = rm,
        tabledata "NPR Display Content Lines" = rm,
        tabledata "NPR Retail Logo" = rm,
        tabledata "NPR RP Template Media Info" = rm,
        tabledata "NPR NpRv Arch. Voucher" = rm,
        tabledata "NPR NpRv Voucher" = rm;

    var
        JobQueueParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
        BlobToMediaMigrationIm: Codeunit "NPR Blob To Media Migration Im";
        MaxIterPerTableTok: Label 'MAX ITERATIONS PER TABLE', Locked = true;
        NofIterations: Integer;

    trigger OnRun()
    begin
        JobQueueParamStrMgt.Parse(Rec."Parameter String");
        NofIterations := JobQueueParamStrMgt.GetInteger(MaxIterPerTableTok);
        if NofIterations <= 0 then
            NofIterations := 100;

        BlobToMediaMigrationIm.MigrateAFArgsSpireBarcode(NofIterations, false);
        BlobToMediaMigrationIm.MigrateMCSFaces(NofIterations, false);
        BlobToMediaMigrationIm.MigrateMagentoPicture(NofIterations, false);
        BlobToMediaMigrationIm.MigrateMMMember(NofIterations, false);
        BlobToMediaMigrationIm.MigrateMPOSQRCode(NofIterations, false);
        BlobToMediaMigrationIm.MigrateDisplayContentLines(NofIterations, false);
        BlobToMediaMigrationIm.MigrateRetailLogo(NofIterations, false);
        BlobToMediaMigrationIm.MigrateTemplateMediaInfo(NofIterations, false);
        BlobToMediaMigrationIm.MigrateNpRvArchVoucher(NofIterations, false);
        BlobToMediaMigrationIm.MigrateNpRvVoucher(NofIterations, false);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR Blob To Media Migration JQ");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", 'OnAfterValidateEvent', 'Object ID to Run', true, true)]
    local procedure OnValidateJobQueueEntryObjectIDtoRun(var Rec: Record "Job Queue Entry"; var xRec: Record "Job Queue Entry"; CurrFieldNo: Integer)
    var
        ParameterString: Text;
    begin
        if Rec."Object Type to Run" <> Rec."Object Type to Run"::Codeunit then
            exit;

        if Rec."Object ID to Run" <> CurrCodeunitId() then
            exit;

        ParameterString := MaxIterPerTableTok + '=100';

        Rec.Validate("Parameter String", CopyStr(ParameterString, 1, MaxStrLen(Rec."Parameter String")));
    end;
}