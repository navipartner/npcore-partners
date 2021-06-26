codeunit 6014499 "NPR Blob To Media Migration Im"
{
    var
        BlobToMediaMigration: Record "NPR Blob To Media Migration";
        DataLogMgt: Codeunit "NPR Data Log Management";
        TableNo: Integer;
        OrdinalNo: Integer;

    procedure MigrateAFArgsSpireBarcode(NofIterations: Integer; Overwrite: Boolean)
    var
        MigrationRec: Record "NPR AF Args: Spire Barcode";
        InStr: InStream;
        WithError: Boolean;
    begin
        if MigrationRec.IsEmpty() then
            exit;

        InitBlobToMediaMigration(Database::"NPR AF Args: Spire Barcode");

        if OrdinalNo > 0 then
            MigrationRec.GetBySystemId(BlobToMediaMigration.Id);

        MigrationRec.SetAutoCalcFields(Image);
        if MigrationRec.Find('>') then
            repeat
                if IsNullGuid(MigrationRec.Picture.MediaId()) or Overwrite then
                    if MigrationRec.Image.HasValue() then begin
                        MigrationRec.Image.CreateInStream(InStr);
                        WithError := IsNullGuid(MigrationRec.Picture.ImportStream(InStr, MigrationRec.FieldName(Picture)));
                        if not WithError then begin
                            DataLogMgt.DisableDataLog(true);
                            MigrationRec.Modify();
                            DataLogMgt.DisableDataLog(false);
                        end;
                        Clear(InStr);
                    end;

                LogBlobToMediaMigration(MigrationRec.SystemId, WithError);

                NofIterations -= 1;
            until (MigrationRec.Next() = 0) or (NofIterations <= 0);
    end;

    procedure MigrateMCSFaces(NofIterations: Integer; Overwrite: Boolean)
    var
        MigrationRec: Record "NPR MCS Faces";
        InStr: InStream;
        WithError: Boolean;
    begin
        if MigrationRec.IsEmpty() then
            exit;

        InitBlobToMediaMigration(Database::"NPR MCS Faces");

        if OrdinalNo > 0 then
            MigrationRec.GetBySystemId(BlobToMediaMigration.Id);

        MigrationRec.SetAutoCalcFields(Picture);
        if MigrationRec.Find('>') then
            repeat
                if IsNullGuid(MigrationRec.Image.MediaId()) or Overwrite then
                    if MigrationRec.Picture.HasValue() then begin
                        MigrationRec.Picture.CreateInStream(InStr);
                        WithError := IsNullGuid(MigrationRec.Image.ImportStream(InStr, MigrationRec.FieldName(Image)));
                        if not WithError then begin
                            DataLogMgt.DisableDataLog(true);
                            MigrationRec.Modify();
                            DataLogMgt.DisableDataLog(false);
                        end;
                        Clear(InStr);
                    end;

                LogBlobToMediaMigration(MigrationRec.SystemId, WithError);

                NofIterations -= 1;
            until (MigrationRec.Next() = 0) or (NofIterations <= 0);
    end;

    procedure MigrateMagentoPicture(NofIterations: Integer; Overwrite: Boolean)
    var
        MigrationRec: Record "NPR Magento Picture";
        InStr: InStream;
        WithError: Boolean;
    begin
        if MigrationRec.IsEmpty() then
            exit;

        InitBlobToMediaMigration(Database::"NPR Magento Picture");

        if OrdinalNo > 0 then
            MigrationRec.GetBySystemId(BlobToMediaMigration.Id);

        MigrationRec.SetAutoCalcFields(Picture);
        if MigrationRec.Find('>') then
            repeat
                if IsNullGuid(MigrationRec.Image.MediaId()) or Overwrite then
                    if MigrationRec.Picture.HasValue() then begin
                        MigrationRec.Picture.CreateInStream(InStr);
                        WithError := IsNullGuid(MigrationRec.Image.ImportStream(InStr, MigrationRec.FieldName(Image)));
                        if not WithError then begin
                            DataLogMgt.DisableDataLog(true);
                            MigrationRec.Modify();
                            DataLogMgt.DisableDataLog(false);
                        end;
                        Clear(InStr);
                    end;

                LogBlobToMediaMigration(MigrationRec.SystemId, WithError);

                NofIterations -= 1;
            until (MigrationRec.Next() = 0) or (NofIterations <= 0);
    end;

    procedure MigrateMMMember(NofIterations: Integer; Overwrite: Boolean)
    var
        MigrationRec: Record "NPR MM Member";
        InStr: InStream;
        WithError: Boolean;
    begin
        if MigrationRec.IsEmpty() then
            exit;

        InitBlobToMediaMigration(Database::"NPR MM Member");

        if OrdinalNo > 0 then
            MigrationRec.GetBySystemId(BlobToMediaMigration.Id);

        MigrationRec.SetAutoCalcFields(Picture);
        if MigrationRec.Find('>') then
            repeat
                if IsNullGuid(MigrationRec.Image.MediaId()) or Overwrite then
                    if MigrationRec.Picture.HasValue() then begin
                        MigrationRec.Picture.CreateInStream(InStr);
                        WithError := IsNullGuid(MigrationRec.Image.ImportStream(InStr, MigrationRec.FieldName(Image)));
                        if not WithError then begin
                            DataLogMgt.DisableDataLog(true);
                            MigrationRec.Modify();
                            DataLogMgt.DisableDataLog(false);
                        end;
                        Clear(InStr);
                    end;

                LogBlobToMediaMigration(MigrationRec.SystemId, WithError);

                NofIterations -= 1;
            until (MigrationRec.Next() = 0) or (NofIterations <= 0);
    end;

    procedure MigrateMPOSQRCode(NofIterations: Integer; Overwrite: Boolean)
    var
        MigrationRec: Record "NPR MPOS QR Code";
        InStr: InStream;
        WithError: Boolean;
    begin
        if MigrationRec.IsEmpty() then
            exit;

        InitBlobToMediaMigration(Database::"NPR MPOS QR Code");

        if OrdinalNo > 0 then
            MigrationRec.GetBySystemId(BlobToMediaMigration.Id);

        MigrationRec.SetAutoCalcFields("QR code");
        if MigrationRec.Find('>') then
            repeat
                if IsNullGuid(MigrationRec."QR Image".MediaId()) or Overwrite then
                    if MigrationRec."QR code".HasValue() then begin
                        MigrationRec."QR code".CreateInStream(InStr);
                        WithError := IsNullGuid(MigrationRec."QR Image".ImportStream(InStr, MigrationRec.FieldName("QR Image")));
                        if not WithError then begin
                            DataLogMgt.DisableDataLog(true);
                            MigrationRec.Modify();
                            DataLogMgt.DisableDataLog(false);
                        end;
                        Clear(InStr);
                    end;

                LogBlobToMediaMigration(MigrationRec.SystemId, WithError);

                NofIterations -= 1;
            until (MigrationRec.Next() = 0) or (NofIterations <= 0);
    end;

    procedure MigrateDisplayContentLines(NofIterations: Integer; Overwrite: Boolean)
    var
        MigrationRec: Record "NPR Display Content Lines";
        InStr: InStream;
        WithError: Boolean;
    begin
        if MigrationRec.IsEmpty() then
            exit;

        InitBlobToMediaMigration(Database::"NPR Display Content Lines");

        if OrdinalNo > 0 then
            MigrationRec.GetBySystemId(BlobToMediaMigration.Id);

        MigrationRec.SetAutoCalcFields(Image);
        if MigrationRec.Find('>') then
            repeat
                if IsNullGuid(MigrationRec.Picture.MediaId()) or Overwrite then
                    if MigrationRec.Image.HasValue() then begin
                        MigrationRec.Image.CreateInStream(InStr);
                        WithError := IsNullGuid(MigrationRec.Picture.ImportStream(InStr, MigrationRec.FieldName(Picture)));
                        if not WithError then begin
                            DataLogMgt.DisableDataLog(true);
                            MigrationRec.Modify();
                            DataLogMgt.DisableDataLog(false);
                        end;
                        Clear(InStr);
                    end;

                LogBlobToMediaMigration(MigrationRec.SystemId, WithError);

                NofIterations -= 1;
            until (MigrationRec.Next() = 0) or (NofIterations <= 0);
    end;

    procedure MigrateRetailLogo(NofIterations: Integer; Overwrite: Boolean)
    var
        MigrationRec: Record "NPR Retail Logo";
        InStr: InStream;
        WithError: Boolean;
    begin
        if MigrationRec.IsEmpty() then
            exit;

        InitBlobToMediaMigration(Database::"NPR Retail Logo");

        if OrdinalNo > 0 then
            MigrationRec.GetBySystemId(BlobToMediaMigration.Id);

        MigrationRec.SetAutoCalcFields(Logo);
        if MigrationRec.Find('>') then
            repeat
                if IsNullGuid(MigrationRec."POS Logo".MediaId()) or Overwrite then
                    if MigrationRec.Logo.HasValue() then begin
                        MigrationRec.Logo.CreateInStream(InStr);
                        WithError := IsNullGuid(MigrationRec."POS Logo".ImportStream(InStr, MigrationRec.FieldName("POS Logo")));
                        if not WithError then begin
                            DataLogMgt.DisableDataLog(true);
                            MigrationRec.Modify();
                            DataLogMgt.DisableDataLog(false);
                        end;
                        Clear(InStr);
                    end;

                LogBlobToMediaMigration(MigrationRec.SystemId, WithError);

                NofIterations -= 1;
            until (MigrationRec.Next() = 0) or (NofIterations <= 0);
    end;

    procedure MigrateTemplateMediaInfo(NofIterations: Integer; Overwrite: Boolean)
    var
        MigrationRec: Record "NPR RP Template Media Info";
        InStr: InStream;
        WithError: Boolean;
    begin
        if MigrationRec.IsEmpty() then
            exit;

        InitBlobToMediaMigration(Database::"NPR RP Template Media Info");

        if OrdinalNo > 0 then
            MigrationRec.GetBySystemId(BlobToMediaMigration.Id);

        MigrationRec.SetAutoCalcFields(Picture);
        if MigrationRec.Find('>') then
            repeat
                if IsNullGuid(MigrationRec.Image.MediaId()) or Overwrite then
                    if MigrationRec.Picture.HasValue() then begin
                        MigrationRec.Picture.CreateInStream(InStr);
                        WithError := IsNullGuid(MigrationRec.Image.ImportStream(InStr, MigrationRec.FieldName(Image)));
                        if not WithError then begin
                            DataLogMgt.DisableDataLog(true);
                            MigrationRec.Modify();
                            DataLogMgt.DisableDataLog(false);
                        end;
                        Clear(InStr);
                    end;

                LogBlobToMediaMigration(MigrationRec.SystemId, WithError);

                NofIterations -= 1;
            until (MigrationRec.Next() = 0) or (NofIterations <= 0);
    end;

    procedure MigrateNpRvArchVoucher(NofIterations: Integer; Overwrite: Boolean)
    var
        MigrationRec: Record "NPR NpRv Arch. Voucher";
        InStr: InStream;
        WithError: Boolean;
    begin
        if MigrationRec.IsEmpty() then
            exit;

        InitBlobToMediaMigration(Database::"NPR NpRv Arch. Voucher");

        if OrdinalNo > 0 then
            MigrationRec.GetBySystemId(BlobToMediaMigration.Id);

        MigrationRec.SetAutoCalcFields(Barcode);
        if MigrationRec.Find('>') then
            repeat
                if IsNullGuid(MigrationRec."Barcode Image".MediaId()) or Overwrite then
                    if MigrationRec.Barcode.HasValue() then begin
                        MigrationRec.Barcode.CreateInStream(InStr);
                        WithError := IsNullGuid(MigrationRec."Barcode Image".ImportStream(InStr, MigrationRec.FieldName("Barcode Image")));
                        if not WithError then begin
                            DataLogMgt.DisableDataLog(true);
                            MigrationRec.Modify();
                            DataLogMgt.DisableDataLog(false);
                        end;
                        Clear(InStr);
                    end;

                LogBlobToMediaMigration(MigrationRec.SystemId, WithError);

                NofIterations -= 1;
            until (MigrationRec.Next() = 0) or (NofIterations <= 0);
    end;

    procedure MigrateNpRvVoucher(NofIterations: Integer; Overwrite: Boolean)
    var
        MigrationRec: Record "NPR NpRv Voucher";
        InStr: InStream;
        WithError: Boolean;
    begin
        if MigrationRec.IsEmpty() then
            exit;

        InitBlobToMediaMigration(Database::"NPR NpRv Voucher");

        if OrdinalNo > 0 then
            MigrationRec.GetBySystemId(BlobToMediaMigration.Id);

        MigrationRec.SetAutoCalcFields(Barcode);
        if MigrationRec.Find('>') then
            repeat
                if IsNullGuid(MigrationRec."Barcode Image".MediaId()) or Overwrite then
                    if MigrationRec.Barcode.HasValue() then begin
                        MigrationRec.Barcode.CreateInStream(InStr);
                        WithError := IsNullGuid(MigrationRec."Barcode Image".ImportStream(InStr, MigrationRec.FieldName("Barcode Image")));
                        if not WithError then begin
                            DataLogMgt.DisableDataLog(true);
                            MigrationRec.Modify();
                            DataLogMgt.DisableDataLog(false);
                        end;
                        Clear(InStr);
                    end;

                LogBlobToMediaMigration(MigrationRec.SystemId, WithError);

                NofIterations -= 1;
            until (MigrationRec.Next() = 0) or (NofIterations <= 0);
    end;

    local procedure InitBlobToMediaMigration(NewTableNo: Integer)
    begin
        TableNo := NewTableNo;
        OrdinalNo := 0;
        BlobToMediaMigration.Reset();
        BlobToMediaMigration.SetCurrentKey("Table No.", Ordinal);
        BlobToMediaMigration.SetRange("Table No.", TableNo);
        if BlobToMediaMigration.FindLast() then
            OrdinalNo := BlobToMediaMigration.Ordinal;
    end;

    local procedure LogBlobToMediaMigration(Id: Guid; WithError: Boolean)
    begin
        OrdinalNo += 1;
        BlobToMediaMigration.Init();
        BlobToMediaMigration."Table No." := TableNo;
        BlobToMediaMigration.Id := Id;
        BlobToMediaMigration.Ordinal := OrdinalNo;
        BlobToMediaMigration.Error := WithError;
        BlobToMediaMigration.Insert();
    end;

    // This procedure is generic one that could replace any of the above procedures with same performance,
    // only issue with it is that it has to use work table for media import from which media reference is taken
    // and written to destination table. 
    // And that is all well except for the fact that if records from work table are ever deleted, any other tables 
    // with media fields that were referencing same media will loose data. As explained in MS docs: 
    // https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-working-with-media-on-records#sharing-media-objects-between-different-tables
    //
    // procedure MigrateGeneric(TableNo: Integer; BlobFieldNo: Integer; MediaFieldNo: Integer; NofIterations: Integer)
    // var
    //     BlobToMediaMigration: Record "NPR Blob To Media Migration";
    //     RR: RecordRef;
    //     MediaFR: FieldRef;
    //     CurrSystemId: Guid;
    //     DataLogMgt: Codeunit "NPR Data Log Management";
    //     TempBlob: Codeunit "Temp Blob";
    //     InStr: InStream;
    //     WithError: Boolean;
    //     OrdinalNo: Integer;
    //     Force: Boolean;
    // begin
    //     Force := true;

    //     RR.Open(TableNo);

    //     OrdinalNo := 0;
    //     BlobToMediaMigration.Reset();
    //     BlobToMediaMigration.SetCurrentKey("Table No.", Ordinal);
    //     BlobToMediaMigration.SetRange("Table No.", RR.Number);
    //     if BlobToMediaMigration.FindLast() then
    //         OrdinalNo := BlobToMediaMigration.Ordinal;

    //     if OrdinalNo > 0 then
    //         RR.GetBySystemId(BlobToMediaMigration.Id);

    //     if RR.Find('>') then
    //         repeat
    //             CurrSystemId := RR.Field(RR.SystemIdNo()).Value;
    //             OrdinalNo += 1;
    //             BlobToMediaMigration.Init();
    //             BlobToMediaMigration."Table No." := RR.Number;
    //             BlobToMediaMigration.Id := CurrSystemId;
    //             BlobToMediaMigration.Ordinal := OrdinalNo;

    //             MediaFR := RR.Field(MediaFieldNo);

    //             if (IsNullGuid(MediaFR.Value)) or Force then begin
    //                 TempBlob.FromRecordRef(RR, BlobFieldNo);
    //                 if TempBlob.HasValue() then begin
    //                     TempBlob.CreateInStream(InStr);
    //                     WithError := IsNullGuid(BlobToMediaMigration.Media.ImportStream(InStr, MediaFR.Name()));
    //                     if not WithError then begin
    //                         DataLogMgt.DisableDataLog(true);
    //                         MediaFR.Value := BlobToMediaMigration.Media.MediaId();
    //                         RR.Modify();
    //                         DataLogMgt.DisableDataLog(false);
    //                     end;
    //                     Clear(InStr);
    //                 end;
    //             end;

    //             BlobToMediaMigration.Insert();

    //             NofIterations -= 1;
    //         until (RR.Next() = 0) or (NofIterations <= 0);
    // end;
}