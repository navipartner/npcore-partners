codeunit 6014667 "NPR EFT Recon. Teller / AMEX"
{
    Access = Internal;

    trigger OnRun()
    begin
    end;

    var
        CSVFileType: label 'CSV Files (*.csv)|*.csv|All Files (*.*)|*.*', Comment = '{Split=r''\|''}{Locked=s''1''}';
        UnexpectedLineTypeErr: label 'Linetype %1 was not expected. Line number = %2';
        FeeTransactionNotFoundErr: label 'Transaction for fee not found. %1 Line number = %2';
        StatusDialogTxt: label 'Importing file #1##########';


    procedure ImportFile(var EFTReconciliation: Record "NPR EFT Reconciliation"): Boolean
    var
        // TempBlob: Record TempBlob temporary;
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        IStream: InStream;
        Filename: Text;
    begin
        Filename := FileManagement.BLOBImportWithFilter(TempBlob, 'Import', EFTReconciliation.Filename, CSVFileType, '*.*');
        if Filename <> '' then begin
            EFTReconciliation.Filename := FileManagement.GetFileName(Filename);
            EFTReconciliation.Modify(true);
            TempBlob.CreateInstream(IStream, Textencoding::Windows);
            ImportStream(EFTReconciliation, IStream);
        end;
        exit(true);
    end;


    procedure ImportStream(var Reconciliation: Record "NPR EFT Reconciliation"; var DataStream: InStream)
    var
        DataLine: Text;
        DataArray: array[40] of Text;
        LineCounter: Integer;
        EntryType: Integer;
        LastDialogUpdate: DateTime;
        Progress: Text;
        Window: Dialog;
    begin
        if GuiAllowed then begin
            Window.Open(StatusDialogTxt);
            LastDialogUpdate := CurrentDatetime;
        end;
        repeat
            if GuiAllowed then
                if LastDialogUpdate + 1000 < CurrentDatetime then begin
                    LastDialogUpdate := CurrentDatetime;
                    Progress += '.';
                    if StrLen(Progress) > 10 then
                        Progress := '.';
                    Window.Update(1, Progress);
                end;
            DataStream.ReadText(DataLine);
            Split(DataLine, DataArray);
            LineCounter += 1;
            case Strip(DataArray[1]) of
                '100':
                    begin
                        if Evaluate(EntryType, Strip(DataArray[21])) then;
                        if Reconciliation."Advis ID" = '' then
                            Reconciliation."Advis ID" := Strip(DataArray[19]);
                        if Reconciliation."Account ID" = '' then
                            Reconciliation."Account ID" := Strip(DataArray[16]);
                    end;
                '110':
                    HandleLineType110(Reconciliation, DataArray, LineCounter, EntryType);
                '120':
                    HandleLineType120(Reconciliation, DataArray, LineCounter, EntryType);
                '200':
                    HandleLineType200(Reconciliation, DataArray, EntryType);
                '300':
                    HandleLineType300(Reconciliation, DataArray);
            end;
        until DataStream.eos;
        StripReferenceNo(Reconciliation);
        Reconciliation.Modify(true);
    end;

    local procedure HandleLineType110(var ReconHeader: Record "NPR EFT Reconciliation"; DataArray: array[40] of Text; LineCounter: Integer; EntryType: Integer)
    var
        ReconLine: Record "NPR EFT Recon. Line";
        AltNo: Text;
    begin
        if EntryType <> 1 then
            Error(UnexpectedLineTypeErr, '110', LineCounter);
        ReconLine.Init();

        ReconLine."Reconciliation No." := ReconHeader."No.";
        ReconLine."Line No." := LineCounter;
        ReconLine."Transaction Date" := String2Date(DataArray[2]);
        ReconLine.Amount := String2Decimal(DataArray[8], DataArray[9]);
        if (DataArray[12] = '1440') then
            ReconLine.Amount := -ReconLine.Amount;
        ReconLine."Currency Code" := Strip(DataArray[7]);
        ReconLine."Hardware ID" := Strip(DataArray[15]);
        ReconLine."Reference Number" := Strip(DataArray[10]);
        AltNo := Strip(DataArray[21]);
        if AltNo <> ReconLine."Reference Number" then
            ReconLine."Alt. Reference Number" := AltNo;
        ReconLine."Card Number" := Strip(DataArray[6]);
        ReconLine."Application Account ID" := Strip(DataArray[16]);
        ReconLine.Insert();
        if (ReconHeader."First Transaction Date" = 0D) or (ReconLine."Transaction Date" < ReconHeader."First Transaction Date")
        then
            ReconHeader."First Transaction Date" := ReconLine."Transaction Date";
        if (ReconLine."Transaction Date" > ReconHeader."Last Transaction Date") then
            ReconHeader."Last Transaction Date" := ReconLine."Transaction Date";
    end;

    local procedure HandleLineType120(var ReconHeader: Record "NPR EFT Reconciliation"; DataArray: array[40] of Text; LineCounter: Integer; EntryType: Integer)
    var
        ReconLine: Record "NPR EFT Recon. Line";
        FeeAmount: Decimal;
    begin
        if EntryType <> 2 then
            Error(UnexpectedLineTypeErr, '120', LineCounter);

        ReconLine.SetRange("Reconciliation No.", ReconHeader."No.");
        ReconLine.SetRange("Hardware ID", Strip(DataArray[15]));
        ReconLine.SetRange("Reference Number", Strip(DataArray[10]));
        ReconLine.SetRange("Application Account ID", Strip(DataArray[16]));
        if not ReconLine.FindFirst() then begin
            ReconLine.SetRange("Reference Number");
            ReconLine.SetRange("Alt. Reference Number", Strip(DataArray[21]));
            if not ReconLine.FindFirst() then begin
                ReconLine.SetRange("Alt. Reference Number");
                ReconLine.SetRange("Reference Number", Strip(DataArray[21]));
                if not ReconLine.FindFirst() then
                    Error(FeeTransactionNotFoundErr, ReconLine.GetFilters, LineCounter);
            end;
        end;
        FeeAmount := String2Decimal(DataArray[8], DataArray[9]);
        FeeAmount := ROUND(FeeAmount, 0.001);
        ReconLine."Fee Amount" += FeeAmount;
        ReconLine.Modify(true);
    end;

    local procedure HandleLineType200(var ReconHeader: Record "NPR EFT Reconciliation"; DataArray: array[40] of Text; EntryType: Integer)
    var
        BankAmount: Record "NPR EFT Recon. Bank Amount";
        LineAmount: Decimal;
    begin
        if not BankAmount.Get(ReconHeader."No.", Strip(DataArray[16])) then begin
            BankAmount.Init();
            BankAmount."Reconciliation No." := ReconHeader."No.";
            BankAmount."Application Account ID" := Strip(DataArray[16]);
            BankAmount."Bank Information" := Strip(DataArray[5]);
            BankAmount.Insert(true);
        end;
        LineAmount := String2Decimal(DataArray[14], DataArray[15]);
        case EntryType of
            1:
                begin
                    BankAmount."Transaction Amount" += LineAmount;
                    ReconHeader."Transaction Amount" += LineAmount;
                end;
            2:
                begin
                    BankAmount."Transaction Fee Amount" += LineAmount;
                    ReconHeader."Transaction Fee Amount" += LineAmount;
                end;
            3:
                BankAmount."Subscription Amount" += LineAmount;
            4:
                BankAmount."Adjustment Amount" += LineAmount;
            6:
                BankAmount."Chargeback Amount" += LineAmount;
        end;
        BankAmount.Modify(true);
    end;

    local procedure HandleLineType300(var ReconHeader: Record "NPR EFT Reconciliation"; DataArray: array[40] of Text)
    var
        BankAmount: Record "NPR EFT Recon. Bank Amount";
    begin
        if BankAmount.Get(ReconHeader."No.", Strip(DataArray[16])) then begin
            BankAmount."Bank Amount" += String2Decimal(DataArray[14], DataArray[15]);
            BankAmount."Bank Transfer Date" := String2Date(DataArray[2]);
            BankAmount.Modify(true);
        end else begin
            BankAmount.Init();
            BankAmount."Reconciliation No." := ReconHeader."No.";
            BankAmount."Application Account ID" := Strip(DataArray[16]);
            BankAmount."Bank Information" := Strip(DataArray[5]);
            BankAmount."Bank Transfer Date" := String2Date(DataArray[2]);
            BankAmount."Bank Amount" := String2Decimal(DataArray[14], DataArray[15]);
            BankAmount.Insert(true);
        end;
        ReconHeader."Bank Information" := Strip(DataArray[5]);
        ReconHeader."Bank Transfer Date" := String2Date(DataArray[2]);
        ReconHeader."Bank Amount" += String2Decimal(DataArray[14], DataArray[15]);
    end;

    local procedure StripReferenceNo(Reconciliation: Record "NPR EFT Reconciliation")
    var
        EFTReconLine: Record "NPR EFT Recon. Line";
        Changed: Boolean;
    begin
        EFTReconLine.SetRange("Reconciliation No.", Reconciliation."No.");
        if EFTReconLine.FindSet() then
            repeat
                Changed := false;
                if CopyStr(EFTReconLine."Reference Number", 1, 1) = 'C' then begin
                    EFTReconLine."Reference Number" := CopyStr(EFTReconLine."Reference Number", 2);
                    Changed := true;
                end;
                if CopyStr(EFTReconLine."Alt. Reference Number", 1, 1) = 'C' then begin
                    EFTReconLine."Alt. Reference Number" := CopyStr(EFTReconLine."Alt. Reference Number", 2);
                    Changed := true;
                end;
                if Changed then
                    EFTReconLine.Modify(false);
            until EFTReconLine.Next() = 0;
    end;

    local procedure Split(Input: Text; var OutputArray: array[40] of Text)
    var
        RegEx: dotnet Regex;
        Parts: dotnet Array;
        I: Integer;
        NoOfParts: Integer;
    begin
        Parts := RegEx.Split(Input, '(?:,|\n|^)("(?:(?:"")*[^"]*)*"|[^",\n]*|(?:\n|$))');
        // element 0, 2, 4, 6, ... are blank ?? bug in regex-expression?
        NoOfParts := Parts.Length;
        NoOfParts := (NoOfParts DIV 2);
        for I := 0 to NoOfParts - 1 do
            OutputArray[I + 1] := Parts.GetValue((I * 2) + 1);
    end;

    local procedure Strip(Input: Text): Text
    begin
        if Input = '' then
            exit('');
        if Input = '""' then
            exit('');
        if (Input[1] = '"') and (Input[StrLen(Input)] = '"') then
            exit(CopyStr(Input, 2, StrLen(Input) - 2));
        exit(Input);
    end;

    local procedure String2Date(Input: Text): Date
    var
        Day: Integer;
        Month: Integer;
        Year: Integer;
    begin
        Input := Strip(Input);
        Evaluate(Day, CopyStr(Input, 1, 2));
        Evaluate(Month, CopyStr(Input, 4, 2));
        Evaluate(Year, CopyStr(Input, 7, 4));
        exit(Dmy2date(Day, Month, Year));
    end;

    local procedure String2Decimal(Input: Text; SignString: Text): Decimal
    var
        DecimalValue: Decimal;
    begin
        Input := Strip(Input);
        if Input = '' then
            exit(0);
        Input := DelChr(Input, '<=>', '.');
        Input := ConvertStr(Input, ',', '.');
        Evaluate(DecimalValue, Input, 9);
        SignString := Strip(SignString);
        if SignString = 'K' then
            DecimalValue *= -1;
        exit(DecimalValue);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Reconciliation Mgt.", 'OnImportReconciliationFile', '', false, false)]
    local procedure OnImport(var EFTReconciliation: Record "NPR EFT Reconciliation"; EFTReconSubscriber: Record "NPR EFT Recon. Subscriber"; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if (EFTReconSubscriber."Subscriber Codeunit ID" = Codeunit::"NPR EFT Recon. Teller / AMEX") and (EFTReconSubscriber."Subscriber Function" = 'OnImport') then
            Handled := ImportFile(EFTReconciliation);
    end;
}

