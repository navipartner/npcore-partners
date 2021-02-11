codeunit 6014438 "NPR Scanner - Functions"
{
    var
        SH: Record "Sales Header";
        SL: Record "Sales Line";
        KH: Record "Purchase Header";
        KL: Record "Purchase Line";
        IL: Record "Requisition Line";
        TL: Record "Transfer Line";
        IJL: Record "Item Journal Line";
        Vare: Record Item;
        RecNo: Integer;
        ID: Code[10];
        i: Integer;
        nextRecNo: Integer;
        DataInput: Text[250];
        txtDec: Code[250];
        Line_ItemNo: Code[20];
        Line_Quantity: Decimal;
        FindesVare: Boolean;
        Dialog1: Dialog;
        Placering: Code[10];
        Kladdetypenavn: Code[10];
        Kladdenavn: Code[10];
        Vend: Record Vendor;
        fejlfundet: Boolean;
        item: Record Item;
        tempIL: Record "NPR TEMP Buffer" temporary;
        "Retail Journal Header": Record "NPR Retail Journal Header";
        "Retail Journal Line": Record "NPR Retail Journal Line";
        EkspeditionLinie: Record "NPR Sale Line POS";
        Kassenummer: Code[10];
        Bonnummer: Code[10];
        ScannerSetup: Record "NPR Scanner - Setup";
        PeriodeRabatLinie: Record "NPR Period Discount Line";
        Code20: Code[20];
        MiksrabatLinie: Record "NPR Mixed Discount Line";
        dato: Date;
        tidspunkt: Time;
        Variantkode: Code[20];
        //StockTakeWorkSheet: Record "NPR Stock-Take Worksheet";
        //StockTakeWorksheetLine: Record "NPR Stock-Take Worksheet Line";
        t001: Label 'Item number %1 doesn''t exist';
        t002: Label 'is blocked';
        t003: Label 'Vendor';
        t004: Label 'Not Found';

    local procedure InsertLine()
    var
        param: Text[30];
        param2: Text[30];
        t001: Label 'Importing to table %1 not reconized!';
        t002: Label 'Unknown: %1';
    begin
        //InsertLine()

        if Line_ItemNo <> '' then begin
            case RecNo of
                37: /* SALES */
                    begin
                        SL.Init;
                        SL.Validate("Document Type", SH."Document Type");
                        SL.Validate("Document No.", SH."No.");
                        SL.Validate("Line No.", nextRecNo);
                        SL.Validate(Type, SL.Type::Item); //NPR-Scanner1.1u
                        getItem(Line_ItemNo, param, param2, Variantkode);
                        if Line_ItemNo <> '' then begin
                            SL.Validate("No.", Line_ItemNo);
                            SL.Validate(Quantity, Line_Quantity);
                            SL.Validate("Variant Code", Variantkode); //NPR-Scanner1.1u
                        end else begin
                            SL."No." := Line_ItemNo;
                            SL."Description 2" := param2;
                            SL.Quantity := Line_Quantity;
                        end;
                        SL.Description := param;
                        SL."Description 2" := param2;
                        SL.Insert;
                    end;
                39:  /* PURCHASE */
                    begin
                        KL.Init;
                        KL.Validate("Document Type", KH."Document Type");
                        KL.Validate("Document No.", KH."No.");
                        KL.Validate("Line No.", nextRecNo);
                        KL.Validate(Type, KL.Type::Item);
                        getItem(Line_ItemNo, param, param2, Variantkode);
                        if Line_ItemNo <> '' then begin
                            item.Get(Line_ItemNo);
                            KL.Validate("No.", Line_ItemNo);
                            if (item."Vendor No." <> '') then
                                KL.Validate("Pay-to Vendor No.", item."Vendor No.");
                            KL.Validate(Quantity, Line_Quantity);
                        end else begin
                            KL."No." := Line_ItemNo;
                            KL.Quantity := Line_Quantity;
                            KL.Description := param;
                        end;
                        KL.Description := param;
                        KL."Description 2" := param2;
                        KL.Insert;
                    end;
                83:    /* ITEM JOURNAL LINE */
                    begin
                        IJL.Reset;
                        IJL.Validate("Journal Template Name", Kladdetypenavn);
                        IJL.Validate("Journal Batch Name", Kladdenavn);
                        IJL."Line No." := nextRecNo;
                        getItem(Line_ItemNo, param, param2, Variantkode);
                        if Line_ItemNo <> '' then begin
                            IJL.Validate("Item No.", Line_ItemNo);
                            IJL.Validate(Quantity, Line_Quantity);
                            IJL.Validate("Variant Code", Variantkode); //NPR-Scanner1.1u
                        end else begin
                            IJL."Item No." := Line_ItemNo;
                            IJL.Quantity := Line_Quantity;
                        end;
                        IJL.Description := param;
                        IJL.Insert;
                    end;
                246:   /* PURCHASE JOURNAL LINE */
                    begin
                        IL.Init;
                        IL.Validate("Worksheet Template Name", Kladdetypenavn);
                        IL.Validate("Journal Batch Name", Kladdenavn);
                        IL.Validate(Type, IL.Type::Item);
                        IL."Line No." := nextRecNo;
                        getItem(Line_ItemNo, param, param2, Variantkode);
                        if Line_ItemNo <> '' then begin
                            IL.Validate("No.", Line_ItemNo);
                            IL.Validate(Quantity, Line_Quantity);
                        end else begin
                            IL."No." := Line_ItemNo;
                            IL.Description := StrSubstNo(t002, param2);
                            IL.Quantity := Line_Quantity;
                        end;
                        IL.Description := param;
                        IL."Description 2" := param2;
                        IL.Insert;
                    end;
                5741:
                    begin
                        TL.Init;
                        TL.Validate("Document No.", Code20);
                        TL."Line No." := nextRecNo;
                        getItem(Line_ItemNo, param, param2, Variantkode);
                        if Line_ItemNo <> '' then begin
                            TL.Validate("Item No.", Line_ItemNo);
                            TL.Validate(Quantity, Line_Quantity);
                        end else begin
                            TL.Validate("Item No.", param2);
                            TL.Quantity := Line_Quantity;
                        end;
                        TL.Insert;
                    end;

                6014422:  /* LABELS */
                    begin
                        getItem(Line_ItemNo, param, param2, Variantkode);
                        "Retail Journal Line".Init;
                        "Retail Journal Line"."No." := "Retail Journal Header"."No.";
                        "Retail Journal Line"."Line No." := nextRecNo;
                        if Line_ItemNo <> '' then begin
                            "Retail Journal Line".Validate("Item No.", Line_ItemNo);
                            "Retail Journal Line".Validate("Variant Code", Variantkode); //NPR-Scanner1.1u
                        end else begin
                            "Retail Journal Line"."Item No." := Line_ItemNo;
                            "Retail Journal Line".Barcode := param2;
                            "Retail Journal Line".Description := param;
                        end;
                        "Retail Journal Line"."Quantity to Print" := Line_Quantity;
                        "Retail Journal Line".Insert;
                    end;
                6014406:   /* POS SALE */
                    begin
                        getItem(Line_ItemNo, param, param2, Variantkode);
                        EkspeditionLinie.Init;
                        EkspeditionLinie."Register No." := Kassenummer;
                        EkspeditionLinie."Sales Ticket No." := Bonnummer;
                        EkspeditionLinie.Date := Today;
                        EkspeditionLinie."Sale Type" := EkspeditionLinie."Sale Type"::Sale;
                        EkspeditionLinie."Line No." := nextRecNo;
                        if Line_ItemNo <> '' then begin
                            EkspeditionLinie.Validate(Type, EkspeditionLinie.Type::Item);
                            EkspeditionLinie.Validate("No.", Line_ItemNo);
                        end else begin
                            EkspeditionLinie.Validate(Type, EkspeditionLinie.Type::Comment);
                            EkspeditionLinie."No." := param2;
                            EkspeditionLinie.Description := param;
                        end;
                        EkspeditionLinie.Validate(Quantity, Line_Quantity);
                        EkspeditionLinie.Insert;
                    end;
                6014414:   /* CAMPAIGN DISCOUNT */
                    begin
                        getItem(Line_ItemNo, param, param2, Variantkode);
                        PeriodeRabatLinie.Init;
                        PeriodeRabatLinie.Validate(Code, Code20);
                        if Line_ItemNo <> '' then begin
                            PeriodeRabatLinie.Validate("Item No.", Line_ItemNo);
                        end else begin
                            PeriodeRabatLinie."Item No." := param2;
                            PeriodeRabatLinie.Description := param;
                        end;
                        PeriodeRabatLinie.Validate("Campaign Unit Price", 1);
                        PeriodeRabatLinie.Insert;
                    end;
                6014412:   /* MIXED DISCOUNT */
                    begin
                        getItem(Line_ItemNo, param, param2, Variantkode);
                        MiksrabatLinie.Init;
                        MiksrabatLinie.Validate(Code, Code20);
                        if Line_ItemNo <> '' then begin
                            MiksrabatLinie.Validate("No.", Line_ItemNo);
                        end else begin
                            MiksrabatLinie."No." := param2;
                            MiksrabatLinie.Description := param;
                        end;
                        MiksrabatLinie.Validate(Quantity, Line_Quantity);
                        MiksrabatLinie.Insert;
                    end;
                6014664:   /* Stock take */
                    begin
                        //REFACTORING NEEDED - STOCKTAKE MOVED TO NP Warehouse!
                        // StockTakeWorksheetLine.Init;
                        // StockTakeWorksheetLine."Stock-Take Config Code" := StockTakeWorkSheet."Stock-Take Config Code";
                        // StockTakeWorksheetLine."Worksheet Name" := StockTakeWorkSheet.Name;
                        // StockTakeWorksheetLine."Line No." := nextRecNo;
                        // StockTakeWorksheetLine.Validate(Barcode, Line_ItemNo);
                        // StockTakeWorksheetLine."Qty. (Counted)" := Line_Quantity;
                        // StockTakeWorksheetLine."Shelf  No." := Placering;
                        // StockTakeWorksheetLine.Insert();
                    end;
                else
                    Error(t001, RecNo);
            end;
        end;

        nextRecNo := nextRecNo + 10000;
        Line_ItemNo := '';
        Line_Quantity := 0;

    end;

    local procedure getItem(var vnr: Code[30]; var beskr: Text[30]; var beskr2: Text[30]; var Varkode: Code[20]): Integer
    var
        vnr_orig: Text[30];
        ItemReference: Record "Item Reference";
        BarcodeLibrary: Codeunit "NPR Barcode Lookup Mgt.";
        ResTable: Integer;
        Item2: Record Item;
        ItemNo: Code[20];
    begin
        ItemNo := vnr;
        if not BarcodeLibrary.TranslateBarcodeToItemVariant(vnr, ItemNo, Varkode, ResTable, false) then begin
            vnr := '';
            beskr := StrSubstNo(t001, ItemNo);
            beskr2 := ItemNo;
            exit;
        end;

        Item2.Get(ItemNo);
        case true of
            (Item2.Blocked):
                begin
                    beskr := CopyStr('---> ' + ItemNo + ' ' + t002, 1, MaxStrLen(beskr));
                    beskr2 := vnr;
                    vnr := '';
                    exit;
                end;
            ((Item2."Vendor No." <> '') and (not Vend.Get(Item2."Vendor No."))):
                begin
                    beskr := CopyStr('--->' + t003 + Item2."Vendor No." + ' ' + t004, 1, MaxStrLen(beskr));
                    beskr2 := vnr;
                    vnr := ItemNo;
                    exit;
                end;
        end;
        beskr := CopyStr(Item2.Description, 1, MaxStrLen(beskr));
        beskr2 := CopyStr(Item2."Description 2", 1, MaxStrLen(beskr2));
        vnr := ItemNo;
    end;

    local procedure askScanner(var ScannerSetup: Record "NPR Scanner - Setup" temporary)
    var
        Scanner: Record "NPR Scanner - Setup";
        askStr: Text[1024];
        menuID: Integer;
        t001: Label 'No scanner setup found! Use "Retail > Setup > General > Setup > Scanner Setup" to setup your scanners.';
        scannerArray: array[10] of Code[20];
        i: Integer;
        t002: Label 'No scanner selected. Scanning stopped!';
    begin
        askStr := '';
        i := 0;

        Scanner.Reset;
        if Scanner.Find('-') then
            repeat
                i += 1;
                askStr += Scanner.Description + ',';
                scannerArray[i] := Scanner.ID;
            until Scanner.Next = 0;

        case Scanner.Count of
            0:
                Error(t001);
            1:
                ScannerSetup.Get(Scanner.ID);
            else begin
                    askStr := CopyStr(askStr, 1, StrLen(askStr) - 1);
                    menuID := StrMenu(askStr);
                    if menuID = 0 then Error(t002);
                    ScannerSetup.Get(scannerArray[menuID]);
                end;
        end;
    end;

    local procedure FileGo(Filename1: Text[1024]; Filename2: Text[1024]; Function1: Option " ",Backup,Delete,"Backup+Delete")
    begin
        //fileGo

        case Function1 of
            Function1::Backup:
                CopyClientFile(Filename1, Filename2);
            Function1::Delete:
                EraseClientFile(Filename1);
            Function1::"Backup+Delete":
                begin
                    CopyClientFile(Filename1, Filename2);
                    EraseClientFile(Filename1);
                end;
        end;
    end;

    local procedure GetBackupFilename(Filename: Text; ScannerSetup: Record "NPR Scanner - Setup") BackupFilename: Text
    begin
        BackupFilename := Filename;
        if ScannerSetup."Backup Filename" <> '' then
            BackupFilename := StrSubstNo(ScannerSetup."Backup Filename", ConvertStr(DelChr(Format(CurrentDateTime, 19, 9), '=', ',:Z'), 'T', ' '));
        exit(BackupFilename);
    end;

    local procedure CopyClientFile(ClientFilenameFrom: Text; ClientFilenameTo: Text)
    var
        FileMgt: Codeunit "File Management";
    begin
        FileMgt.CopyClientFile(ClientFilenameFrom, ClientFilenameTo, true);
    end;

    local procedure EraseClientFile(ClientFilename: Text)
    var
        FileMgt: Codeunit "File Management";
    begin
        FileMgt.DeleteClientFile(ClientFilename);
    end;

    local procedure formatDecimal(Dec1: Decimal; nDec: Integer): Text[30]
    var
        decp: Text[3];
    begin
        //formatDecimal

        decp := Format(nDec + 1);
        exit(Format(Round(Dec1, 1 / Power(10, nDec)), 0, '<Integer><Decimal,' + decp + '>'));
    end;

    local procedure filenameCreate(FilenameType: Option GUID,DATETIME,Prefix,"Fixed",fixedask; Direction: Option Load,Save): Text[250]
    var
        FileMgt: Codeunit "File Management";
        guid1: Guid;
        tmp: Text[250];
        tmp2: Text[250];
        t002: Label 'No filename';
        ETDTO: Label 'Choose file...';
    begin
        //filenameCreate
        case FilenameType of
            FilenameType::GUID:
                begin
                    guid1 := CreateGuid();
                    exit(DelChr(Format(guid1), '=', '{}:-'));
                end;
            FilenameType::DATETIME:
                exit(DelChr(Format(Today) + '_' + Format(Time), '=', '{}:-'));
            FilenameType::Prefix:
                begin
                    exit(ScannerSetup."File - Name/Prefix");
                end;
            FilenameType::Fixed:
                exit(ScannerSetup."File - Name/Prefix");
            FilenameType::fixedask:
                begin
                    tmp2 := ScannerSetup."Path - Pickup Directory" + '\status.dat';
                    if Direction = Direction::Save then
                        tmp := FileMgt.OpenFileDialog(ETDTO, '*.*', 'All Files(*.*)|*.*')
                    else
                        tmp := FileMgt.SaveFileDialog(ETDTO, '*.*', 'All Files(*.*)|*.*');
                    if tmp = '' then Error(t002);
                    exit(tmp);
                end;
        end;
    end;

    local procedure ReadUntil(var text250: Text[250]; Char1: Text[30]) ret: Text[250]
    var
        TABchar: Char;
        EOLchar: Char;
        NLchar: Char;
        EOTchar: Char;
        pos1: Integer;
    begin
        //ReadUntilTAB

        TABchar := 9;     // horiz tab
        EOLchar := 10;    // new line
        NLchar := 13;    // carriage return
        EOTchar := 4;     // end of transmission

        pos1 := StrPos(text250, Char1);
        if pos1 > 0 then begin
            ret := CopyStr(text250, 1, pos1 - 1);
            text250 := DelStr(text250, 1, pos1);
        end else begin
            ret := text250;
            text250 := '';
        end;
    end;

    procedure UploadProgram2Scanner("Scanner Setup": Record "NPR Scanner - Setup")
    begin
        //UploadProgram2Scanner
        RunProcess("Scanner Setup"."EXE - Update Scanner", "Scanner Setup"."EXE - Update Scanner Param.", true);
    end;

    local procedure CopyClientDir2ServerDir(ClientDir: Text; ServerDir: Text)
    var
        NameValueBuffer: Record "Name/Value Buffer" temporary;
        FileMgt: Codeunit "File Management";
        Filename: Text;
    begin
        if not FileMgt.ServerDirectoryExists(ServerDir) then
            FileMgt.ServerCreateDirectory(ServerDir);

        FileMgt.GetClientDirectoryFilesList(NameValueBuffer, ClientDir);
        if NameValueBuffer.FindSet then
            repeat
                Filename := FileMgt.GetFileName(NameValueBuffer.Name);
                FileMgt.UploadFileSilentToServerPath(NameValueBuffer.Name, ServerDir + '\' + Filename);
            until NameValueBuffer.Next = 0;
    end;

    local procedure Endswith(var String: Text; EndsWith: Text; AddEndsWith: Boolean): Boolean
    var
        // NetString has been converted from DotNet
        NetString: Text;
    begin
        NetString := String;
        if NetString.EndsWith(EndsWith) then
            exit(true);

        if AddEndsWith then
            String := String + EndsWith;

        exit(false);
    end;

    local procedure FTPDownloadFile(ScannerSetup2: Record "NPR Scanner - Setup"): Boolean
    var
        FtpWebRequest: DotNet NPRNetFtpWebRequest;
        FtpWebResponse: DotNet NPRNetFtpWebResponse;
        NetworkCredential: DotNet NPRNetNetworkCredential;
        Stream: DotNet NPRNetStream;
        StreamReader: DotNet NPRNetStreamReader;
        SIOFile: DotNet NPRNetFile;
        ServerFile: Text;
    begin
        FtpWebRequest := FtpWebRequest.Create(ScannerSetup2."FTP Site address" + '/' + ScannerSetup2."FTP Filename");
        FtpWebRequest.Credentials := NetworkCredential.NetworkCredential(ScannerSetup2."FTP Username", ScannerSetup2."FTP Password");

        FtpWebRequest.Method := 'RETR';
        FtpWebRequest.KeepAlive := true;
        FtpWebRequest.UseBinary := true;

        ServerFile := ScannerSetup2."Path - Pickup Directory";
        Endswith(ServerFile, '\', true);
        ServerFile += ScannerSetup2."File - Name/Prefix";

        if Exists(ServerFile) then
            if Erase(ServerFile) then;

        FtpWebResponse := FtpWebRequest.GetResponse;
        Stream := FtpWebResponse.GetResponseStream;

        StreamReader := StreamReader.StreamReader(Stream);
        SIOFile.WriteAllText(ServerFile, StreamReader.ReadToEnd);

        Stream.Close;

        exit(Exists(ServerFile));
    end;

    local procedure FTPDeleteFile(ScannerSetup2: Record "NPR Scanner - Setup")
    var
        FtpWebRequest: DotNet NPRNetFtpWebRequest;
        FtpWebResponse: DotNet NPRNetFtpWebResponse;
        NetworkCredential: DotNet NPRNetNetworkCredential;
    begin
        FtpWebRequest := FtpWebRequest.Create(ScannerSetup2."FTP Site address" + '/' + ScannerSetup2."FTP Filename");
        FtpWebRequest.Credentials := NetworkCredential.NetworkCredential(ScannerSetup2."FTP Username", ScannerSetup2."FTP Password");

        FtpWebRequest.Method := 'DELE';
        FtpWebRequest.KeepAlive := true;
        FtpWebRequest.UseBinary := true;

        FtpWebResponse := FtpWebRequest.GetResponse;
    end;

    local procedure RunProcess(Filename: Text; Arguments: Text; Modal: Boolean)
    var
        [RunOnClient]
        Process: DotNet NPRNetProcess;
        [RunOnClient]
        ProcessStartInfo: DotNet NPRNetProcessStartInfo;
    begin
        ProcessStartInfo := ProcessStartInfo.ProcessStartInfo(Filename, Arguments);
        Process := Process.Start(ProcessStartInfo);
        if Modal then
            Process.WaitForExit();
    end;
}