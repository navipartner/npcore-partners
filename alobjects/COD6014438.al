codeunit 6014438 "Scanner - Functions"
{
    // NPR-Scanner1.1t, NPK, DL, 17-01-08, Added an InsertLine when line type is record in GoGet
    //                                     Changed code in insertline on rec 83
    //                                     Added code in initTransfer to get it to work
    // 
    // NPR-Scanner1.1u, NPK, DL, 11-03-08, Changed faulty code.
    //                                     Inserts variant code on relevant records (function insertline)
    // 
    // //Issues.
    // CU412 deprecated
    // Used in filenameCreate(FilenameType : 'GUID,DATETIME,Prefix,Fixed,fixedask';Direction : 'Load,Save') : Text[250]
    // 
    // NPR4.16/TSA/20150317 CASE 213313  Implemented new status module
    // NPR5.23/JDH /20160517 CASE 240916 Removed old VariaX Solution
    // NPR5.29/CLVA/20161122 CASE 252352 Added ftp functionality
    // NPR5.38/CLVA/20171115 CASE 296307 Added support for Webclient
    // NPR5.38/MHA /20171222 CASE 299271 Added functions CopyClientFile(), EraseClientFile() and GetBackupFilename()
    // NPR5.38/MHA /20180105 CASE 301053 Removed references to Utility
    // NPR5.44/TS  /20180723 CASE 321232 Check for Item in Cross Reference in GetItems, restructured getitem function to use barcode library
    // NPR5.50/BHR /20190508 CASE 348372 Validate Barcode
    // NPR5.51/THRO/20190822 CASE 366006 Check string lenght before padding in GoSend(). Remove leading Zeroes if string longer than Lenght for Padding::"Pre Zeroes"
    // NPR5.53/THRO/20191220 CASE 383414 getItem() didn't return found Item No.


    trigger OnRun()
    begin
    end;

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
        AltVare: Record "Alternative No.";
        Placering: Code[10];
        Kladdetypenavn: Code[10];
        Kladdenavn: Code[10];
        Vend: Record Vendor;
        fejlfundet: Boolean;
        item: Record Item;
        tempIL: Record "NPR - TEMP Buffer" temporary;
        "Retail Journal Header": Record "Retail Journal Header";
        "Retail Journal Line": Record "Retail Journal Line";
        EkspeditionLinie: Record "Sale Line POS";
        Kassenummer: Code[10];
        Bonnummer: Code[10];
        ScannerSetup: Record "Scanner - Setup";
        PeriodeRabatLinie: Record "Period Discount Line";
        Code20: Code[20];
        MiksrabatLinie: Record "Mixed Discount Line";
        dato: Date;
        tidspunkt: Time;
        Variantkode: Code[20];
        StockTakeWorkSheet: Record "Stock-Take Worksheet";
        StockTakeWorksheetLine: Record "Stock-Take Worksheet Line";
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
            37 : /* SALES */
              begin
                SL.Init;
                SL.Validate("Document Type", SH."Document Type");
                SL.Validate("Document No.", SH."No.");
                SL.Validate("Line No.", nextRecNo);
                SL.Validate(Type, SL.Type::Item); //NPR-Scanner1.1u
                getItem(Line_ItemNo,param,param2,Variantkode);
                if Line_ItemNo <> '' then begin
                  SL.Validate("No.", Line_ItemNo);
                  SL.Validate(Quantity, Line_Quantity);
                  SL.Validate("Variant Code", Variantkode); //NPR-Scanner1.1u
                end else begin
                  SL."No." := Line_ItemNo;
                  SL."Description 2" := param2;
                  SL.Quantity   := Line_Quantity;
                end;
                SL.Description := param;
                SL."Description 2" := param2;
                SL.Insert;
              end;
            39 :  /* PURCHASE */
              begin
                KL.Init;
                KL.Validate("Document Type", KH."Document Type");
                KL.Validate("Document No.", KH."No.");
                KL.Validate("Line No.", nextRecNo);
                KL.Validate(Type, KL.Type::Item);
                getItem(Line_ItemNo,param,param2,Variantkode);
                if Line_ItemNo <> '' then begin
                  item.Get(Line_ItemNo);
                  KL.Validate("No.",Line_ItemNo);
                  if (item."Vendor No." <> '') then
                    KL.Validate("Pay-to Vendor No.", item."Vendor No.");
                  KL.Validate(Quantity, Line_Quantity);
                end else begin
                  KL."No." := Line_ItemNo;
                  KL.Quantity := Line_Quantity;
                  KL.Description := param;
                end;
                KL.Description   := param;
                KL."Description 2" := param2;
                KL.Insert;
              end;
            83 :    /* ITEM JOURNAL LINE */
              begin
                IJL.Reset;
                IJL.Validate("Journal Template Name", Kladdetypenavn);
                IJL.Validate("Journal Batch Name", Kladdenavn);
                IJL."Line No." := nextRecNo;
                getItem(Line_ItemNo,param,param2,Variantkode);
                if Line_ItemNo <> '' then begin
                  IJL.Validate("Item No.", Line_ItemNo);
                  IJL.Validate(Quantity,Line_Quantity);
                  IJL.Validate("Variant Code", Variantkode); //NPR-Scanner1.1u
                end else begin
                  IJL."Item No." := Line_ItemNo;
                  IJL.Quantity := Line_Quantity;
                end;
                IJL.Description   := param;
                IJL.Insert;
              end;
            246 :   /* PURCHASE JOURNAL LINE */
              begin
                IL.Init;
                IL.Validate("Worksheet Template Name", Kladdetypenavn);
                IL.Validate("Journal Batch Name", Kladdenavn);
                IL.Validate(Type,IL.Type::Item);
                IL."Line No." := nextRecNo;
                getItem(Line_ItemNo,param,param2,Variantkode);
                if Line_ItemNo <> '' then begin
                  IL.Validate("No.", Line_ItemNo);
                  IL.Validate(Quantity,Line_Quantity);
                end else begin
                  IL."No." := Line_ItemNo;
                  IL.Description := StrSubstNo(t002, param2);
                  IL.Quantity := Line_Quantity;
                end;
                IL.Description   := param;
                IL."Description 2" := param2;
                IL.Insert;
              end;
            5741 :
              begin
                TL.Init;
                TL.Validate("Document No.", Code20);
                TL."Line No." := nextRecNo;
                getItem(Line_ItemNo, param, param2,Variantkode);
                if Line_ItemNo <> '' then begin
                  TL.Validate("Item No.", Line_ItemNo);
                  TL.Validate(Quantity, Line_Quantity);
                end else begin
                  TL.Validate("Item No.", param2);
                  TL.Quantity := Line_Quantity;
                end;
                TL.Insert;
              end;
            //-NPR5.27 [252676]
        //    6014420 :  { INVENTORY BALANCING }
        //      BEGIN
        //        StatusLin.INIT;
        //        StatusLin.VALIDATE(Code, Status.Code);
        //        //StatusLin.VALIDATE(line_itemno);
        //        StatusLin.VALIDATE("Line No.", nextRecNo);
        //        getItem(Line_ItemNo, param, param2,Variantkode);
        //        IF Line_ItemNo <> '' THEN BEGIN
        //          StatusLin.VALIDATE("Item No.", Line_ItemNo);
        //          StatusLin.VALIDATE("Quantity counted", Line_Quantity);
        //        END ELSE BEGIN
        //          StatusLin.VALIDATE("Item No.", param2);
        //          StatusLin."Quantity counted" := Line_Quantity;
        //        END;
        //        StatusLin."Variant Code"     := Variantkode;
        //        StatusLin.Placement          := Placering;
        //        StatusLin."Dept."            := Status."Dept. code";
        //        StatusLin.Location           := Status."Loc. Code";
        //        StatusLin.INSERT;
        //      END;
            //+NPR5.27 [252676]
            6014422 :  /* LABELS */
              begin
                getItem(Line_ItemNo, param, param2,Variantkode);
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
            6014406 :   /* POS SALE */
              begin
                getItem(Line_ItemNo, param, param2,Variantkode);
                EkspeditionLinie.Init;
                EkspeditionLinie."Register No." := Kassenummer;
                EkspeditionLinie."Sales Ticket No." := Bonnummer;
                EkspeditionLinie.Date  := Today;
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
            6014414 :   /* CAMPAIGN DISCOUNT */
              begin
                getItem(Line_ItemNo, param, param2,Variantkode);
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
            6014412 :   /* MIXED DISCOUNT */
              begin
                getItem(Line_ItemNo, param, param2,Variantkode);
                MiksrabatLinie.Init;
                MiksrabatLinie.Validate(Code, Code20);
                if Line_ItemNo <> '' then begin
                  MiksrabatLinie.Validate("No.", Line_ItemNo);
                end else begin
                  MiksrabatLinie."No." := param2;
                  MiksrabatLinie.Description := param;
                end;
                MiksrabatLinie.Validate(Quantity,Line_Quantity);
                MiksrabatLinie.Insert;
              end;
            //-NPR4.16
            6014664 :   /* Stock take */
              begin
                StockTakeWorksheetLine.Init;
                StockTakeWorksheetLine."Stock-Take Config Code" := StockTakeWorkSheet."Stock-Take Config Code";
                StockTakeWorksheetLine."Worksheet Name" := StockTakeWorkSheet.Name;
                StockTakeWorksheetLine."Line No." := nextRecNo;
        
                //-NPR5.50 [348372]
                //StockTakeWorksheetLine.Barcode := Line_ItemNo;
                  StockTakeWorksheetLine.Validate(Barcode,Line_ItemNo);
                //+NPR5.50 [348372]
                StockTakeWorksheetLine."Qty. (Counted)" := Line_Quantity;
                StockTakeWorksheetLine."Shelf  No." := Placering;
        
                StockTakeWorksheetLine.Insert ();
              end;
            //+NPR4.16
        
            else
              Error(t001, RecNo);
          end;
        end;
        
        nextRecNo := nextRecNo + 10000;
        Line_ItemNo := '';
        Line_Quantity := 0;

    end;

    procedure initPurchJnl(var initIL: Record "Requisition Line")
    begin
        //initIndk�bskladde
        
        Kladdetypenavn := initIL."Worksheet Template Name";
        Kladdenavn := initIL."Journal Batch Name";
        RecNo := 246;  /*Indk�bskladde*/
        GoGet;

    end;

    procedure initRetailJournal(var initRJH: Record "Retail Journal Header")
    begin
        //initLabel

        "Retail Journal Line".Reset;
        "Retail Journal Line".SetRange("No.", initRJH."No.");
        "Retail Journal Header" := initRJH;
        RecNo := 6014422;
        GoGet;
    end;

    procedure initSale(var Eksp: Record "Sale POS")
    begin
        //initEksp
        
        EkspeditionLinie.Reset;
        EkspeditionLinie.SetRange("Register No.", Eksp."Register No.");
        EkspeditionLinie.SetRange("Sales Ticket No.", Eksp."Sales Ticket No.");
        Kassenummer := Eksp."Register No.";
        Bonnummer := Eksp."Sales Ticket No.";
        RecNo := 6014406;  /*Ekspedition*/
        GoGet;

    end;

    procedure initCampaignDiscount(var PeriodeRabat: Record "Period Discount")
    begin
        //initPerioderabat
        
        PeriodeRabatLinie.Reset;
        PeriodeRabatLinie.SetRange(Code, PeriodeRabat.Code);
        Code20 := PeriodeRabat.Code;
        RecNo := 6014414;  /*Perioderabat*/
        GoGet;

    end;

    procedure initMixedDiscount(var Miksrabat: Record "Mixed Discount")
    begin
        //initMixRabat
        
        Code20 := Miksrabat.Code;
        RecNo := 6014412;  /*Miksrabat*/
        GoGet;

    end;

    procedure initItemJnl(var "Item Journal Line": Record "Item Journal Line")
    begin
        //initItemJnl

        RecNo := 83;

        IJL.Reset;
        IJL.SetRange("Journal Template Name", "Item Journal Line"."Journal Template Name");
        IJL.SetRange("Journal Batch Name", "Item Journal Line"."Journal Batch Name");
        if IJL.Find('+') then
          nextRecNo := IJL."Line No." + 10000
        else
          nextRecNo := 10000;

        Kladdetypenavn := "Item Journal Line"."Journal Template Name";
        Kladdenavn    := "Item Journal Line"."Journal Batch Name";

        GoGet;
    end;

    procedure initTransfer(var "Transfer Header": Record "Transfer Header")
    begin
        //initTransfer

        RecNo := 5741;

        TL.Reset;
        TL.SetRange("Document No.", "Transfer Header"."No.");
        if TL.Find('+') then
          nextRecNo := TL."Line No." + 10000
        else
          nextRecNo := 10000;

        //-Scanner1.1t
        Code20 := "Transfer Header"."No.";
        //+Scanner1.1t

        GoGet;
    end;

    procedure initStockTake(var initStatus: Record "Stock-Take Worksheet")
    begin
        //initStocktake
        //-NPR4.16
        StockTakeWorkSheet.Reset;
        StockTakeWorkSheet.SetFilter("Stock-Take Config Code", initStatus."Stock-Take Config Code");
        StockTakeWorkSheet.SetRange (Name, initStatus.Name);
        StockTakeWorkSheet.Find('-');
        RecNo := 6014664;  /*Stock Take*/
        GoGet;
        //+NPR4.16

    end;

    local procedure GoGet(): Boolean
    var
        t001: Label 'The Function must be called with a parameter!';
        t002: Label 'No Lines from Scanner!';
        t003: Label 'Input ....: #1###########################################################################  \\';
        t004: Label 'Enter "%1" + ENTER, when everything is imported.';
        t006: Label 'This scanner reading type %1 is not supported at the moment!';
        Files: Record File;
        ScannerSetupFields: Record "Scanner - Field Setup";
        TempBolb: Record TempBlob;
        Fil: Codeunit "DotNet File Library";
        FileManagement: Codeunit "File Management";
        InputDialog: Page "Input Dialog";
        Guid1: Guid;
        Data: InStream;
        t007: Label 'File %1%2 could not be opened!';
        t009: Label 'Scanner prefix %1 unknown!';
        Countdown: Integer;
        Len1: Integer;
        Len2: Integer;
        Len3: Integer;
        WindowStyle: Integer;
        ExitLoop: Boolean;
        WaitOnReturn: Boolean;
        ParamStr: Text;
        PortStr: Text;
        BackupFilename: Text;
        Filename: Text;
        Filepath: Text;
        InText250: Text[250];
        TmpText: Text;
        t011: Label 'Counting position (max. 10 characters)';
        t012: Label 'No. of records in the TEMP table: %1';
        t013: Label 'Datainput: %1';
        t014: Label 'Intext250: %1';
        t015: Label 'Not supported yet: %1';
        FirstPrefix: Text;
        Code250: Code[250];
        Fname: Text;
        SavePath: Text;
    begin
        //GoGet
        if RecNo = 0 then
          Error(t001);
        
        askScanner(ScannerSetup);
        
        if ScannerSetup."Alt. Import Codeunit" > 0 then begin
          CODEUNIT.Run(ScannerSetup."Alt. Import Codeunit", ScannerSetup);
          exit(true);
        end;
        
        fejlfundet := false;
        FindesVare := false;
        
        case RecNo of
          39 :
            begin
              KL.SetCurrentKey("Document Type", "Document No.","Line No.");
              KL.SetRange("Document Type", KH."Document Type");
              KL.SetRange("Document No.",KH."No.");
              if KL.Find('+') then
                nextRecNo := KL."Line No." + 10000
              else
                nextRecNo := 10000;
            end;
          246 :
            begin
              IL.SetCurrentKey("Worksheet Template Name","Journal Batch Name","Line No.");
              IL.SetRange("Worksheet Template Name",Kladdetypenavn);
              IL.SetRange("Journal Batch Name",Kladdenavn);
              if IL.Find('+') then
                nextRecNo := IL."Line No." + 10000
              else
                nextRecNo := 10000;
            end;
          5741 :
            begin
        
            end;
          //-NPR5.27 [252676]
        //  6014420 :
        //    BEGIN
        //      StatusLin.SETCURRENTKEY(Code);   // ,line_itemno - fjernet
        //      StatusLin.SETRANGE(Code, Status.Code);
        //      IF StatusLin.FIND('+') THEN
        //        nextRecNo := StatusLin."Line No." + 10000
        //      ELSE
        //        nextRecNo := 10000;
        //    END;
          //+NPR5.27 [252676]
          6014422 :
            begin
              if "Retail Journal Line".Find('+') then
                nextRecNo := "Retail Journal Line"."Line No." + 10000
              else
                nextRecNo := 10000;
            end;
          6014406 :
            begin
             if EkspeditionLinie.Find('+') then
               nextRecNo += EkspeditionLinie."Line No." + 10000
             else
               nextRecNo := 10000;
            end;
          6014414 : /*tom*/;
          6014412 : /*tom*/;
          //-NPR4.16
          6014664 :
            begin
              StockTakeWorksheetLine.Reset ();
              StockTakeWorksheetLine.SetCurrentKey ("Stock-Take Config Code", "Worksheet Name");
              StockTakeWorksheetLine.SetRange ("Stock-Take Config Code", StockTakeWorkSheet."Stock-Take Config Code");
              StockTakeWorksheetLine.SetRange ("Worksheet Name", StockTakeWorkSheet.Name);
              if StockTakeWorksheetLine.Find('+') then
                nextRecNo := StockTakeWorksheetLine."Line No." + 10000
              else
                nextRecNo := 10000;
            end;
          //+NPR4.16
        end;
        
        Line_ItemNo := '';
        Placering := '';
        
        // Ask for parameters
        if ScannerSetup."Placement Popup" then begin
          InputDialog.SetInput(1,Placering,t011);
          if InputDialog.RunModal = ACTION::OK then
            InputDialog.InputCode(1,Placering);
          Clear(InputDialog);
        end;
        
        i := 1;
        
        Guid1 := CreateGuid();
        tempIL.Init;
        tempIL.Template := Format(Guid1);
        
        DataInput := '';
        
        case ScannerSetup.Type of
             ScannerSetup.Type::"Direct Cable" :
                begin
                  if StrPos(ScannerSetup."Scanning End String", '#') = 0 then
                    TmpText := StrSubstNo(t004, ScannerSetup."Scanning End String")
                  else
                    TmpText := '';
                  Error('%1 not supported',ScannerSetup.Type::"Direct Cable");
                end;
             ScannerSetup.Type::File :
                begin
                  Filename := '';
                  if ScannerSetup."Import to Server Folder First" <> '' then begin
                    //-NPR5.38 [301053]
                    //Utility.CopyFilesDir(ScannerSetup."Local Client Scanner Folder", ScannerSetup."Path - Pickup Directory");
                    CopyClientDir2ServerDir(ScannerSetup."Local Client Scanner Folder",ScannerSetup."Path - Pickup Directory");
                    //+NPR5.38 [301053]
                  end;
        
                  //-NPR5.29
                  if ScannerSetup."FTP Download to Server Folder" then begin
                    ScannerSetup.TestField("FTP Site address");
                    ScannerSetup.TestField("FTP Filename");
                    ScannerSetup.TestField("Path - Pickup Directory");
                    //-NPR5.38 [301053]
                    //IF Utility.FTPDownloadFile(ScannerSetup."FTP Site address",ScannerSetup."Path - Pickup Directory",ScannerSetup."File - Name/Prefix",ScannerSetup."FTP Filename",ScannerSetup."FTP Username",ScannerSetup."FTP Password",FALSE) THEN
                    //  Utility.FTPDeleteFile(ScannerSetup."FTP Site address",ScannerSetup."FTP Filename",ScannerSetup."FTP Username",ScannerSetup."FTP Password",FALSE);
                    if FTPDownloadFile(ScannerSetup) then
                      FTPDeleteFile(ScannerSetup);
                    //+NPR5.38 [301053]
                  end;
                  //+NPR5.29
        
                  case ScannerSetup."File - Name Type" of
                    ScannerSetup."File - Name Type"::GUID : Filename := filenameCreate(0,0) + '.dat';
                    ScannerSetup."File - Name Type"::DateTime : Filename := filenameCreate(1,0) + '.dat';
                    ScannerSetup."File - Name Type"::Prefix :
                      begin
                        Files.Reset;
                        Files.SetRange(Path, ScannerSetup."Path - Pickup Directory" + '\');
                        Files.SetRange("Is a file", true);
                        Files.SetFilter(Name, '%1', '@' + ScannerSetup."File - Name/Prefix" + '*');
                      end;
                    ScannerSetup."File - Name Type"::Fixed :
                      begin
                        Filename := ScannerSetup."File - Name/Prefix";
                    end;            ScannerSetup."File - Name Type"::FixedAsk :
        
                      begin
                        //-NPR5.38 [299271]
                        //Filename := filenameCreate(4,0);
                        Filename := filenameCreate(4,1);
                        //+NPR5.38 [299271]
                      end;
                  end;
                  case ScannerSetup.Port of
                     ScannerSetup.Port::COM1 : PortStr := '1';
                     ScannerSetup.Port::COM2 : PortStr := '2';
                     else
                       PortStr := '';
                  end;
        
                  ParamStr += ' ' + PortStr +' '+ScannerSetup."Clear Scanner Option";
        
                  Filepath := ScannerSetup."Path - Pickup Directory" + '\';
        
                  if ScannerSetup."EXE - In" <> '' then begin
                    //-NPR5.38 [301053]
                    // WindowStyle := 1;
                    // WaitOnReturn := TRUE;
                    // {
                    // CREATE(Wsh);
                    // CMDID := Wsh.Run(ScannerSetup."Sti - EXE / DLL dir" + '\' +
                    //                  ScannerSetup."EXE - In" + ' ' +
                    //                  '"' + Filepath + Filename + '" ' + ParamStr,
                    //                  WindowStyle,
                    //                  WaitOnReturn);
                    // }
                    //
                    // CMDID := Utility.RunCmdModal('"' + ScannerSetup."Path - EXE / DLL Directory" + '\' +
                    //                  ScannerSetup."EXE - In" + '"'+''+
                    //                  '"' + Filepath + Filename + '"'+''+ ParamStr);
                    // CLEAR(Wsh);
                    RunProcess(ScannerSetup."Path - EXE / DLL Directory" + '\' + ScannerSetup."EXE - In",'"' + Filepath + Filename + '"'+''+ ParamStr,true);
                    //+NPR5.38 [301053]
                  end;
        
                  if ScannerSetup."File - Name Type" = ScannerSetup."File - Name Type"::FixedAsk then begin
                    //-NPR5.38 [299271]
                    //Filepath := '';
                    Filepath := FileManagement.GetDirectoryName(Filename) + '\';
                    Filename := FileManagement.GetFileName(Filename);
                    //+NPR5.38 [299271]
                  end;
        
        //TS
                  if Files.Find('-') or (Filename <> '') then repeat
                    //-NPR5.38 [296307]
                    if (CurrentClientType in [CLIENTTYPE::Web, CLIENTTYPE::Phone, CLIENTTYPE::Tablet]) then begin
                      Fname:=FileManagement.BLOBImport(TempBolb,SavePath);
                      if TempBolb.Blob.HasValue then begin
                        TempBolb.Blob.CreateInStream(Data);
        
                        for Countdown := 1 to ScannerSetup."File - Line Skip Pre" do begin
                          Data.ReadText(InText250);
                          if (StrLen(InText250) = 0) or (MaxStrLen(InText250)<>StrLen(InText250)) then
                            exit;
                        end;
        
                        while not Data.EOS do begin
                          case ScannerSetup."File - In Record Sep. Type" of
                             ScannerSetup."File - In Record Sep. Type"::"New Line" :
                               begin
                                 Data.ReadText(InText250);
                                 tempIL."Line No." := i;
                                 tempIL.Description := InText250;
                                 tempIL.Insert;
                                 i += 10000;
                               end;
                             ScannerSetup."File - In Record Sep. Type"::Char : Error(t015, Format(ScannerSetup."File - In Record Sep. Type"));
                          end;
                        end;
                      end;
                    end else begin
                    //+NPR5.38 [296307]
                      if Filename = '' then Filename := Files.Name;
                        if not Fil.OPEN(Filepath + Filename) then Error(t007,Filepath,Filename);
                        Fil.TEXTMODE(true);
        
                          for Countdown := 1 to ScannerSetup."File - Line Skip Pre" do begin
                            Fil.READ(InText250);
                            if (StrLen(InText250) = 0) or (MaxStrLen(InText250)<>StrLen(InText250)) then
                              exit;
                          end;
                       // Fil.CREATEINSTREAM(InS);
                         //WHILE NOT InS.EOS DO BEGIN
                         repeat
                          case ScannerSetup."File - In Record Sep. Type" of
                             ScannerSetup."File - In Record Sep. Type"::"New Line" :
                               begin
                                 Fil.READ(InText250);
                                 tempIL."Line No." := i;
                                 tempIL.Description := InText250;
                                 tempIL.Insert;
                                 i += 10000;
                               end;
                             ScannerSetup."File - In Record Sep. Type"::Char : Error(t015, Format(ScannerSetup."File - In Record Sep. Type"));
                          end;
                         until Fil.POS=Fil.LEN;
                      Fil.CLOSE;
                      //-NPR5.38 [296307]
                      //fileGo(Filepath+Filename, ScannerSetup."File - Backup Directory" + '\' + Filename, ScannerSetup."File - After");
                      BackupFilename := GetBackupFilename(Filename,ScannerSetup);
                      FileGo(Filepath + Filename,ScannerSetup."File - Backup Directory" + '\' + BackupFilename,ScannerSetup."File - After");
                      //+NPR5.38 [296307]
                      Filename := '';
                    //-NPR5.38 [296307]
                    end;
                    //+NPR5.38 [296307]
                  until Files.Next = 0;
                end;
             ScannerSetup.Type::WiFi : Error(t006, ScannerSetup.Type);
        end;
        
        Dialog1.Open(t003);
        tempIL.Reset;
        tempIL.SetRange(Template, Format(Guid1));
        if not tempIL.Find('-') then
          Error(t002);
        
        if ScannerSetup.Debug then
          if not Confirm(t012, true, tempIL.Count) then Error('');
        
        i := 1;
        
        ScannerSetupFields.Reset;
        ScannerSetupFields.SetRange(ID, ScannerSetup.ID);
        ScannerSetupFields.SetRange("Where To", ScannerSetupFields."Where To"::Input);
        
        ExitLoop := false;
        FirstPrefix := '';
        
        repeat
          case ScannerSetup."Line Type" of
            ScannerSetup."Line Type"::Field :
              begin
                DataInput := tempIL.Description;
                Len1 := StrLen(DataInput);
                Len2 := StrLen(ScannerSetupFields.Postfix);
                Len3 := StrLen(ScannerSetup."Scanning End String");
        //        IF UPPERCASE(COPYSTR(DataInput, len1-len2+1, len3)) <> ScannerSetup."Scanning End String" THEN
                DataInput := DelStr(DataInput, Len1-Len2+1);
                if ScannerSetup.Debug then
                  if not Confirm(t013, true, DataInput) then Error('');
        
                Dialog1.Update(1, DataInput);
                if UpperCase(DataInput) <> ScannerSetup."Scanning End String" then begin
                  ID := CopyStr(UpperCase(DataInput), 1, ScannerSetup."Prefix Length");
                  ScannerSetupFields.SetRange(Prefix, ID);
                  if not ScannerSetupFields.Find('-') then
                    Error(t009);
        
                  if ScannerSetupFields.Prefix = FirstPrefix then
                    InsertLine;
                  if FirstPrefix = '' then
                    FirstPrefix :=  ScannerSetupFields.Prefix;
        
                  case ScannerSetupFields.Type of
                      ScannerSetupFields.Type::ItemNo :
                        begin
                          Line_ItemNo := CopyStr(DataInput, StrLen(ScannerSetupFields.Prefix)+1);
                        end;
                      ScannerSetupFields.Type::Quantity :
                        begin
                          Evaluate(Line_Quantity, CopyStr(DataInput, StrLen(ScannerSetupFields.Prefix)+1));
                        end;
                      ScannerSetupFields.Type::Placement :
                        begin
                          Placering := CopyStr(DataInput, StrLen(ScannerSetupFields.Prefix)+1,10);
                        end;
                      ScannerSetupFields.Type::Date :
                        begin
                          Evaluate(dato, CopyStr(DataInput, StrLen(ScannerSetupFields.Prefix)+1));
                        end;
                      ScannerSetupFields.Type::Time :
                        begin
                          Evaluate(tidspunkt, CopyStr(DataInput, StrLen(ScannerSetupFields.Prefix)+1));
                        end;
                      ScannerSetupFields.Type::DateTime :
                        begin
                        end;
                  end;
                end else begin
                  Dialog1.Close;
                  exit;
                end;
                DataInput := '';
              end;
            ScannerSetup."Line Type"::Record :
              begin
                Code250 := '??????????????????????????????????';
                if (Code250 <> ScannerSetup."Scanning End String") then begin //OR (ScannerSetup."Scanning End String" = '') THEN BEGIN
                  ScannerSetupFields.SetCurrentKey(Order);
                  ScannerSetupFields.SetRange(ID, ScannerSetup.ID);
                  //-NPR-Scanner1.1u
                  DataInput := tempIL.Description;
                  //+NPR-Scanner1.1u
                  if ScannerSetupFields.Find('-') then repeat
                    Code250 := UpperCase(DataInput);
                    if ScannerSetup.Debug then
                      if not Confirm(t013, true, DataInput) then Error('');
        
                    case ScannerSetup."Field Type" of
                      ScannerSetup."Field Type"::Fixed :
                        InText250 := CopyStr(DataInput, ScannerSetupFields.Position, ScannerSetupFields.Length);
                      ScannerSetup."Field Type"::Dynamic :
                        InText250 := ReadUntil(DataInput, ScannerSetup."Record Field Sep.");
                    end;
        
                    /*fjern prefix fra feltet*/
                    Len3 := StrLen(ScannerSetupFields.Prefix);
                    if Len3 > 0 then
                      InText250 := DelStr(InText250,1,Len3);
        
                    /*fjern postfix fra feltet*/
                    Len1 := StrLen(InText250);
                    Len2 := StrLen(ScannerSetupFields.Postfix);
                    if Len2 > 0 then
                      InText250 := DelStr(InText250, Len2);
        
                    if ScannerSetup.Debug then
                      if not Confirm(t014, true, InText250) then Error('');
        
                    case ScannerSetupFields.Type of
                      ScannerSetupFields.Type::ItemNo,
                      ScannerSetupFields.Type::EAN :
                        begin
                          Line_ItemNo := InText250;
                        end;
                      ScannerSetupFields.Type::Quantity :
                        begin
                          txtDec := InText250;
                          if ScannerSetup."Decimal Point" = '' then
                            txtDec := InsStr(txtDec, ',', StrLen(txtDec)-ScannerSetup."Leading Decimals"+1)
                          else
                            txtDec := ConvertStr(txtDec, ScannerSetup."Decimal Point", ',');
                          Evaluate(Line_Quantity, txtDec);
                        end;
                      ScannerSetupFields.Type::Placement :
                        begin
                          Placering := CopyStr(InText250, StrLen(ScannerSetupFields.Prefix)+1,10);
                        end;
                      ScannerSetupFields.Type::Date :
                        begin
                          Evaluate(dato, CopyStr(InText250, StrLen(ScannerSetupFields.Prefix)+1));
                        end;
                    end;
                  until ScannerSetupFields.Next = 0;
                end;
                //-Scanner1.1t
                InsertLine;
                //+Scanner1.1t
              end;  /*"line type"::record*/
          end;
        until (tempIL.Next = 0);
        case ScannerSetup."Line Type" of
          ScannerSetup."Line Type"::Field :
            InsertLine;
        end;
        
        Dialog1.Close;

    end;

    local procedure getItem(var vnr: Code[30];var beskr: Text[30];var beskr2: Text[30];var Varkode: Code[20]): Integer
    var
        vnr_orig: Text[30];
        ItemCrossReference: Record "Item Cross Reference";
        BarcodeLibrary: Codeunit "Barcode Library";
        ResTable: Integer;
        Item2: Record Item;
        ItemNo: Code[20];
    begin
        //-NPR5.44 [321232]
        ItemNo := vnr;
        if not BarcodeLibrary.TranslateBarcodeToItemVariant(vnr, ItemNo, Varkode, ResTable, false) then begin
          vnr := '';
          beskr   := StrSubstNo(t001, ItemNo);
          beskr2 := ItemNo;
          exit;
        end;

        Item2.Get(ItemNo);
        case true of
          (Item2.Blocked):
            begin
              beskr := CopyStr('---> ' + ItemNo + ' ' + t002, 1, MaxStrLen(beskr));
              beskr2 := vnr;
              vnr := ''; //dont want to use this item, as its blocked
              exit;
            end;
          ((Item2."Vendor No." <> '') and (not Vend.Get(Item2."Vendor No."))):
            begin
              beskr  := CopyStr('--->' + t003 + Item2."Vendor No." + ' ' + t004, 1, MaxStrLen(beskr));
              beskr2 := vnr;
              //-NPR5.53 [383414]
              vnr := ItemNo;
              //+NPR5.53 [383414]
              exit;
            end;
        end;
        beskr := CopyStr(Item2.Description, 1, MaxStrLen(beskr));
        beskr2 := CopyStr(Item2."Description 2", 1, MaxStrLen(beskr2));
        //-NPR5.53 [383414]
        vnr := ItemNo;
        //+NPR5.53 [383414]

        // vnr_orig := vnr;
        //
        // FindesVare := FALSE;
        //
        // Vare.SETRANGE("No.", vnr);
        // IF Vare.FIND('-') THEN BEGIN
        //  IF Vare.Blocked THEN BEGIN
        //    beskr := '---> ' + vnr + ' ' + t002;
        //    beskr2 := vnr_orig;
        //    vnr := '';
        //    FindesVare := FALSE;
        //  END ELSE BEGIN
        //    IF (NOT Vend.GET(Vare."Vendor No.")) AND (Vare."Vendor No." <> '') THEN BEGIN
        //      beskr  := '--->' + t003 + Vare."Vendor No." + ' ' + t004;
        //      beskr2 := vnr_orig;
        //      FindesVare := TRUE;
        //    END ELSE BEGIN
        //      beskr := COPYSTR(Vare.Description,1,30);
        //      beskr2 := COPYSTR(Vare."Description 2",1,30);
        //      FindesVare := TRUE;
        //    END;
        //  END;
        // END ELSE BEGIN
        //  AltVare.SETCURRENTKEY("Alt. No.");
        //  AltVare.SETRANGE("Alt. No.", vnr);
        //  IF AltVare.FIND('-') THEN BEGIN
        //    IF Vare.GET(AltVare.Code) THEN BEGIN
        //      vnr      := AltVare.Code;
        //      Varkode  := AltVare."Variant Code";
        //      IF Vare.Blocked THEN BEGIN
        //        beskr  := '--->' + vnr + ' '+ t002;
        //        beskr2 := vnr_orig;
        //        vnr := '';
        //        FindesVare := FALSE;
        //      END ELSE BEGIN
        //        IF (NOT Vend.GET(Vare."Vendor No.")) AND (Vare."Vendor No." <> '') THEN BEGIN
        //          beskr  := '>' + t003 + Vare."Vendor No." + ' ' + t004;
        //          beskr2 := vnr_orig;
        //          FindesVare := TRUE;
        //        END ELSE BEGIN
        //          beskr := COPYSTR(Vare.Description,1,30);
        //          beskr2 := COPYSTR(Vare."Description 2",1,30);
        //          FindesVare := TRUE;
        //        END;
        //      END;
        //    END ELSE BEGIN
        //      FindesVare := FALSE;
        //      beskr   := t001;
        //      beskr2 := vnr_orig;
        //      vnr  := '';
        //    END;
        //  END ELSE BEGIN
        //    //-NPR5.23 [240916]
        // //    variation.SETCURRENTKEY("EAN Code");
        // //    variation.SETRANGE("EAN Code", vnr);
        // //    IF variation.FIND('-') THEN BEGIN
        // //      beskr    := variation.Description;
        // //      beskr2   := vnr;
        // //      Varkode  := variation."EAN Code";
        // //      FindesVare := TRUE;
        // //    END ELSE BEGIN
        // //+NPR5.23 [240916]
        //    //-NPR5.44 [321232]
        //    ItemCrossReference.SETRANGE("Cross-Reference No.",vnr);
        //    IF ItemCrossReference.FINDFIRST THEN BEGIN
        //      IF item.GET(ItemCrossReference."Item No.") THEN BEGIN
        //        FindesVare := TRUE;
        //        vnr := item."No.";
        //        beskr := COPYSTR(item.Description,1,30);
        //        beskr2 := COPYSTR(item."Description 2",1,30);
        //      END;
        //    END ELSE BEGIN
        //    //+NPR5.44 [321232]
        //      FindesVare := FALSE;
        //      beskr   := t001;
        //      beskr2 := vnr_orig;
        //      vnr  := '';
        //    //-NPR5.44 [321232]
        //    END;
        //    //+NPR5.44 [321232]
        // //-NPR5.23 [240916]
        // //    END;
        // //+NPR5.23 [240916]
        //  END;
        // END;
        //+NPR5.44 [321232]
    end;

    local procedure askScanner(var ScannerSetup: Record "Scanner - Setup" temporary)
    var
        Scanner: Record "Scanner - Setup";
        askStr: Text[1024];
        menuID: Integer;
        t001: Label 'No scanner setup found! Use "Retail > Setup > General > Setup > Scanner Setup" to setup your scanners.';
        scannerArray: array [10] of Code[20];
        i: Integer;
        t002: Label 'No scanner selected. Scanning stopped!';
    begin
        //askScanner

        askStr := '';
        i := 0;

        Scanner.Reset;
        if Scanner.Find('-') then repeat
          i += 1;
          askStr += Scanner.Description + ',';
          scannerArray[i] := Scanner.ID;
        until Scanner.Next = 0;

        case Scanner.Count of
          0 : Error(t001);
          1 : ScannerSetup.Get(Scanner.ID);
          else
            begin
              askStr := CopyStr(askStr,1,StrLen(askStr)-1);
              menuID := StrMenu(askStr);
              if menuID = 0 then Error(t002);
              ScannerSetup.Get(scannerArray[menuID]);
            end;
        end;
    end;

    procedure GoSend(var RetailJournalLine: Record "Retail Journal Line")
    var
        ScannerSetupFields: Record "Scanner - Field Setup";
        Fil: Codeunit "DotNet File Library";
        BackupFilename: Text;
        Filename: Text;
        Filepath: Text;
        ParamStr: Text;
        PortStr: Text;
        Str: Text;
        CMDID: Integer;
        t001: Label 'File %1%2 could not be created!';
        Int1: Integer;
        t003: Label 'Execution error %1';
        Dec: Decimal;
    begin
        //GoSend

        askScanner(ScannerSetup);

        ScannerSetupFields.SetCurrentKey(Order);
        ScannerSetupFields.SetRange(ID, ScannerSetup.ID);
        ScannerSetupFields.SetRange("Where To", ScannerSetupFields."Where To"::Output);
        ScannerSetupFields.Find('-');

        case ScannerSetup.Type of
          ScannerSetup.Type::"Direct Cable" : ;
          ScannerSetup.Type::File :
            begin
              Filename := filenameCreate(ScannerSetup."File - Name Type", 1);
              Filepath  := ScannerSetup."Path - Drop Directory" + '\';
              Fil.WRITEMODE(true);
              Fil.TEXTMODE(true);
              if not Fil.CREATE(Filepath + Filename) then
                Error(t001);
              if "Retail Journal Line".Find('-') then repeat
                if ScannerSetupFields.Find('-') then repeat
                  case ScannerSetupFields.Type of
                    ScannerSetupFields.Type::ItemNo :
                      Str := "Retail Journal Line"."Item No.";
                    ScannerSetupFields.Type::Quantity :
                      Str := Format("Retail Journal Line"."Quantity to Print");
                    ScannerSetupFields.Type::Placement : ;
                    ScannerSetupFields.Type::Color :;
                    ScannerSetupFields.Type::Size :;
                    ScannerSetupFields.Type::Code :;
                    ScannerSetupFields.Type::ScannerNo :;
                    ScannerSetupFields.Type::SerialNo :           Str := "Retail Journal Line"."Serial No.";
                    ScannerSetupFields.Type::KolliAntal :
                      begin
                        if item.Get("Retail Journal Line"."Item No.") then
                          Str := Format(item."Units per Parcel")
                        else
                          Str := '0';
                      end;
                    ScannerSetupFields.Type::"Item Description" :
                      //-NPR5.38 [301053]
                      //Str := Utility.Ascii2Ansi(COPYSTR("Retail Journal Line".Description,1,ScannerSetupFields.Length));
                      Str := CopyStr("Retail Journal Line".Description,1,ScannerSetupFields.Length);
                      //+NPR5.38 [301053]
                    ScannerSetupFields.Type::Sign :
                      begin
                        "Retail Journal Line".CalcFields(Inventory);
                        Str := Format("Retail Journal Line".Inventory);
                        Evaluate(Dec, Str);
                        if Dec >= 0 then
                          Str := ScannerSetupFields.Prefix
                        else
                          Str := ScannerSetupFields.Postfix;
                      end;
                    ScannerSetupFields.Type::"Unit Price" :
                      begin
                        Dec := "Retail Journal Line"."Discount Price Incl. Vat";
                        Str := formatDecimal(Dec, ScannerSetup."Leading Decimals");
                        if ScannerSetup."Decimal Point" <> '' then begin
                          Str := DelChr(Str, '=', ',.');
                          Str := InsStr(Str, ScannerSetup."Decimal Point", StrLen(Str) - ScannerSetup."Leading Decimals" + 1);
                        end else
                          Str := DelChr(Str, '=', ',.');
                      end;
                    ScannerSetupFields.Type::"Unit Cost" :
                      begin
                        Dec := "Retail Journal Line"."Last Direct Cost";
                        Str := formatDecimal(Dec, ScannerSetup."Leading Decimals");
                        if ScannerSetup."Decimal Point" <> '' then begin
                          Str := DelChr(Str, '=', ',.');
                          Str := InsStr(Str, ScannerSetup."Decimal Point", StrLen(Str) - ScannerSetup."Leading Decimals" + 1);
                        end else
                          Str := DelChr(Str, '=', ',.');
                      end;
                    ScannerSetupFields.Type::Inventory :
                      begin
                        "Retail Journal Line".CalcFields(Inventory);
                        Str := Format("Retail Journal Line".Inventory);
                      end;
                    ScannerSetupFields.Type::EAN :
                      begin
                        Str := "Retail Journal Line".Barcode;
                        if Str = '' then
                          Str := "Retail Journal Line"."Item No.";
                      end;
                    ScannerSetupFields.Type::Text :
                      Str := ScannerSetupFields.Prefix + ScannerSetupFields.Postfix;
                  end;

                  //-NPR5.51 [366006]
                  if ScannerSetupFields.Length > 0 then begin
                  //+NPR5.51 [366006]
                    case ScannerSetupFields.Padding of
                      ScannerSetupFields.Padding::" " :;
                      ScannerSetupFields.Padding::"Pre Zeroes" :
                        //-NPR5.51 [366006]
                        begin
                          Str := DelChr(Str,'<','0');
                          if StrLen(Str) < ScannerSetupFields.Length then
                            Str := PadStr('', ScannerSetupFields.Length-StrLen(Str), '0') + Str;
                        end;
                        //-NPR5.51 [366006]
                      ScannerSetupFields.Padding::"Leading Spaces" :
                        //-NPR5.51 [366006]
                        if StrLen(Str) < ScannerSetupFields.Length then
                          Str := Str + PadStr('', ScannerSetupFields.Length-StrLen(Str), ' ');
                        //+NPR5.51 [366006]
                    end;

                    Str := CopyStr(Str, 1, ScannerSetupFields.Length);
                  //-NPR5.51 [366006]
                  end;
                  //+NPR5.51 [366006]
                  case ScannerSetup."Field Type" of
                    ScannerSetup."Field Type"::Fixed :
                      begin
                        Int1 := StrLen(Str);
                        if Int1 < ScannerSetupFields.Length then begin
                          case ScannerSetupFields.Padding of
                            ScannerSetupFields.Padding::"Pre Zeroes" :
                              Str := PadStr('', ScannerSetupFields.Length-Int1, '0') + Str;
                            ScannerSetupFields.Padding::"Leading Spaces" :
                              Str := Str + PadStr('', ScannerSetupFields.Length-Int1, ' ');
                          end;
                        end;
                        Fil.WRITE(Str);
                      end;
                    ScannerSetup."Field Type"::Dynamic :
                      begin
                        Fil.WRITE(ScannerSetupFields.Prefix);
                        Fil.SEEK(Fil.POS-2);
                        Fil.WRITE(Str);
                        Fil.SEEK(Fil.POS-2);
                        Fil.WRITE(ScannerSetupFields.Postfix);
                      end;
                  end;
                  if ScannerSetup."Line Type" = ScannerSetup."Line Type"::Record then
                    Fil.SEEK(Fil.POS-2);
                until ScannerSetupFields.Next = 0;
                if ScannerSetup."Line Type" = ScannerSetup."Line Type"::Record then
                  Fil.WRITE('');
              until "Retail Journal Line".Next = 0;
              Fil.CLOSE;
              case ScannerSetup.Port of
                ScannerSetup.Port::COM1 : PortStr := '1';
                ScannerSetup.Port::COM2 : PortStr := '2';
                else
                  PortStr := '';
              end;
              ParamStr += ' ' + PortStr;
              //-NPR5.38 [301053]
              // CMDID := Utility.RunCmdModal(ScannerSetup."Path - EXE / DLL Directory" + '\' +
              //                  ScannerSetup."EXE - Out"+''+ '"' + Filepath + Filename + '"' + ' ' + ParamStr);
              //
              // IF CMDID <> 0 THEN
              //   MESSAGE(t003, CMDID, Str);
              RunProcess(ScannerSetup."Path - EXE / DLL Directory" + '\' + ScannerSetup."EXE - Out",'"' + Filepath + Filename + '"' + ' ' + ParamStr,true);
              //+NPR5.38 [301053]
              //-NPR5.38 [296307]
              //fileGo(Filepath+Filename, ScannerSetup."File - Backup Directory" + '\' + Filename, ScannerSetup."File - After");
              BackupFilename := GetBackupFilename(Filename,ScannerSetup);
              FileGo(Filepath+Filename,ScannerSetup."File - Backup Directory" + '\' + BackupFilename,ScannerSetup."File - After");
              //+NPR5.38 [296307]
            end;
          ScannerSetup.Type::WiFi : Error('ikke supporteret');
        end;
    end;

    local procedure FileGo(Filename1: Text[1024];Filename2: Text[1024];Function1: Option " ",Backup,Delete,"Backup+Delete")
    begin
        //fileGo

        //-NPR5.38 [299271]
        // CASE Function1 OF
        //  Function1::" " : ;
        //  Function1::Backup : COPY(Filename1, Filename2);
        //  Function1::Delete : ERASE(Filename1);
        //  Function1::"Backup+Delete" :
        //    BEGIN
        //      COPY(Filename1, Filename2);
        //      ERASE(Filename1);
        //    END;
        // END;
        case Function1 of
          Function1::Backup:
            CopyClientFile(Filename1,Filename2);
          Function1::Delete:
            EraseClientFile(Filename1);
          Function1::"Backup+Delete":
            begin
              CopyClientFile(Filename1,Filename2);
              EraseClientFile(Filename1);
            end;
        end;
        //+NPR5.38 [299271]
    end;

    local procedure GetBackupFilename(Filename: Text;ScannerSetup: Record "Scanner - Setup") BackupFilename: Text
    begin
        //-NPR5.38 [299271]
        BackupFilename := Filename;
        if ScannerSetup."Backup Filename" <> '' then
          BackupFilename := StrSubstNo(ScannerSetup."Backup Filename",ConvertStr(DelChr(Format(CurrentDateTime,19,9),'=',',:Z'),'T',' '));
        exit(BackupFilename);
        //+NPR5.38 [299271]
    end;

    local procedure CopyClientFile(ClientFilenameFrom: Text;ClientFilenameTo: Text)
    var
        FileMgt: Codeunit "File Management";
    begin
        //-NPR5.38 [299271]
        FileMgt.CopyClientFile(ClientFilenameFrom,ClientFilenameTo,true);
        //+NPR5.38 [299271]
    end;

    local procedure EraseClientFile(ClientFilename: Text)
    var
        FileMgt: Codeunit "File Management";
    begin
        //-NPR5.38 [299271]
        FileMgt.DeleteClientFile(ClientFilename);
        //+NPR5.38 [299271]
    end;

    local procedure formatDecimal(Dec1: Decimal;nDec: Integer): Text[30]
    var
        decp: Text[3];
    begin
        //formatDecimal

        decp := Format(nDec+1);

        exit(Format(Round(Dec1, 1/Power(10,nDec)), 0, '<Integer><Decimal,' + decp + '>'));
    end;

    local procedure filenameCreate(FilenameType: Option GUID,DATETIME,Prefix,"Fixed",fixedask;Direction: Option Load,Save): Text[250]
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
          FilenameType::GUID :
            begin
              guid1 := CreateGuid();
              exit(DelChr(Format(guid1), '=', '{}:-'));
            end;
          FilenameType::DATETIME :
            exit(DelChr(Format(Today) + '_' + Format(Time), '=', '{}:-'));
          FilenameType::Prefix :
            begin
              exit(ScannerSetup."File - Name/Prefix");
            end;
          FilenameType::Fixed :
            exit(ScannerSetup."File - Name/Prefix");
          FilenameType::fixedask :
            begin
              tmp2 := ScannerSetup."Path - Pickup Directory" + '\status.dat';
              if Direction = Direction::Save then
                tmp  := FileMgt.OpenFileDialog(ETDTO,'*.*','All Files(*.*)|*.*')
              else
                tmp  := FileMgt.SaveFileDialog(ETDTO,'*.*','All Files(*.*)|*.*');
              if tmp = '' then Error(t002);
              exit(tmp);
            end;
        end;
    end;

    local procedure ReadUntil(var text250: Text[250];Char1: Text[30]) ret: Text[250]
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
        NLchar  := 13;    // carriage return
        EOTchar := 4;     // end of transmission

        pos1 := StrPos(text250, Char1);
        if pos1 > 0 then begin
          ret  := CopyStr(text250, 1, pos1-1);
          text250 := DelStr(text250, 1, pos1);
        end else begin
          ret  := text250;
          text250 := '';
        end;
    end;

    procedure UploadProgram2Scanner("Scanner Setup": Record "Scanner - Setup")
    begin
        //UploadProgram2Scanner
        //-NPR5.38 [301053]
        //Utility.RunCmdModal('"' + "Scanner Setup"."EXE - Update Scanner" + '"'+''+ "Scanner Setup"."EXE - Update Scanner Param.");
        RunProcess("Scanner Setup"."EXE - Update Scanner","Scanner Setup"."EXE - Update Scanner Param.",true);
        //+NPR5.38 [301053]
    end;

    local procedure CopyClientDir2ServerDir(ClientDir: Text;ServerDir: Text)
    var
        NameValueBuffer: Record "Name/Value Buffer" temporary;
        FileMgt: Codeunit "File Management";
        Filename: Text;
    begin
        //-NPR5.38 [301053]
        if not FileMgt.ServerDirectoryExists(ServerDir) then
          FileMgt.ServerCreateDirectory(ServerDir);

        FileMgt.GetClientDirectoryFilesList(NameValueBuffer,ClientDir);
        if NameValueBuffer.FindSet then
          repeat
            Filename := FileMgt.GetFileName(NameValueBuffer.Name);
            FileMgt.UploadFileSilentToServerPath(NameValueBuffer.Name,ServerDir + '\' + Filename);
          until NameValueBuffer.Next = 0;
        //+NPR5.38 [301053]
    end;

    local procedure Endswith(var String: Text;EndsWith: Text;AddEndsWith: Boolean): Boolean
    var
        NetString: DotNet npNetString;
    begin
        //-NPR5.38 [301053]
        NetString := String;
        if NetString.EndsWith(EndsWith) then
          exit(true);

        if AddEndsWith then
          String := String + EndsWith;

        exit(false);
        //+NPR5.38 [301053]
    end;

    local procedure FTPDownloadFile(ScannerSetup2: Record "Scanner - Setup"): Boolean
    var
        FtpWebRequest: DotNet npNetFtpWebRequest;
        FtpWebResponse: DotNet npNetFtpWebResponse;
        NetworkCredential: DotNet npNetNetworkCredential;
        Stream: DotNet npNetStream;
        StreamReader: DotNet npNetStreamReader;
        SIOFile: DotNet npNetFile;
        ServerFile: Text;
    begin
        //-NPR5.38 [301053]
        FtpWebRequest := FtpWebRequest.Create(ScannerSetup2."FTP Site address" + '/' + ScannerSetup2."FTP Filename");
        FtpWebRequest.Credentials := NetworkCredential.NetworkCredential(ScannerSetup2."FTP Username",ScannerSetup2."FTP Password");

        FtpWebRequest.Method := 'RETR';
        FtpWebRequest.KeepAlive := true;
        FtpWebRequest.UseBinary := true;

        ServerFile := ScannerSetup2."Path - Pickup Directory";
        Endswith(ServerFile,'\',true);
        ServerFile += ScannerSetup2."File - Name/Prefix";

        if Exists(ServerFile) then
          if Erase(ServerFile) then;

        FtpWebResponse := FtpWebRequest.GetResponse;
        Stream := FtpWebResponse.GetResponseStream;

        StreamReader := StreamReader.StreamReader(Stream);
        SIOFile.WriteAllText(ServerFile,StreamReader.ReadToEnd);

        Stream.Close;

        exit(Exists(ServerFile));
        //+NPR5.38 [301053]
    end;

    local procedure FTPDeleteFile(ScannerSetup2: Record "Scanner - Setup")
    var
        FtpWebRequest: DotNet npNetFtpWebRequest;
        FtpWebResponse: DotNet npNetFtpWebResponse;
        NetworkCredential: DotNet npNetNetworkCredential;
    begin
        //-NPR5.38 [301053]
        FtpWebRequest := FtpWebRequest.Create(ScannerSetup2."FTP Site address" + '/' + ScannerSetup2."FTP Filename");
        FtpWebRequest.Credentials := NetworkCredential.NetworkCredential(ScannerSetup2."FTP Username",ScannerSetup2."FTP Password");

        FtpWebRequest.Method := 'DELE';
        FtpWebRequest.KeepAlive := true;
        FtpWebRequest.UseBinary := true;

        FtpWebResponse := FtpWebRequest.GetResponse;
        //+NPR5.38 [301053]
    end;

    local procedure RunProcess(Filename: Text;Arguments: Text;Modal: Boolean)
    var
        [RunOnClient]
        Process: DotNet npNetProcess;
        [RunOnClient]
        ProcessStartInfo: DotNet npNetProcessStartInfo;
    begin
        //-NPR5.38 [301053]
        ProcessStartInfo := ProcessStartInfo.ProcessStartInfo(Filename,Arguments);
        Process := Process.Start(ProcessStartInfo);
        if Modal then
          Process.WaitForExit();
        //+NPR5.38 [301053]
    end;
}

