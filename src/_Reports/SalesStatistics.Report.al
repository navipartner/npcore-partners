report 6060065 "NPR Sales Statistics"
{
    // NPR5.43/RA  /20180607  CASE 313503 Small ajustments
    // NPR5.46/TJ  /20180912  CASE 327838 Using Nonstock Item as well when searching for barcode
    // NPR5.46/TJ  /20180912  CASE 327869 Datetime is now part of the file created

    Caption = 'Sales Statistic';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Catalog Supplier"; "NPR Catalog Supplier")
        {
            DataItemTableView = WHERE("Send Sales Statistics" = CONST(true));

            trigger OnAfterGetRecord()
            var
                Item: Record Item;
                AuditRoll: Record "NPR Audit Roll";
                FieldArray: array[200] of Text[200];
            begin
                Item.SetCurrentKey("Vendor No.");
                Item.SetRange("Vendor No.", "Catalog Supplier"."Vendor No.");
                if Item.FindSet then
                    repeat
                        AuditRoll.SetCurrentKey("Register No.", "Sales Ticket No.", "Sale Date", "Sale Type", Type, "No.");
                        AuditRoll.SetRange("Sale Date", StartDate, EndDate);
                        AuditRoll.SetRange(Type, AuditRoll.Type::Item);
                        AuditRoll.SetRange("No.", Item."No.");
                        if AuditRoll.FindSet then
                            repeat
                                if AuditRoll.Quantity <> 0 then begin
                                    Clear(FieldArray);
                                    FillArray(FieldArray, AuditRoll, "Catalog Supplier");
                                    OutputText += WriteLine(FieldArray) + LF;
                                end;
                            until AuditRoll.Next = 0;
                    until Item.Next = 0;
            end;

            trigger OnPostDataItem()
            begin
                FTPput;
            end;

            trigger OnPreDataItem()
            begin
                FieldSep := ';';
                LF[1] := 10;
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        FieldSep: Char;
        Character: Char;
        AttributeSetID: Integer;
        StartDate: Date;
        EndDate: Date;
        Host: Text;
        UserName: Text;
        PassWord: Text;
        RemoteDir: Text;
        OutputText: Text;
        LF: Text;

    local procedure FillArray(var FieldArray: array[200] of Text; AuditRoll: Record "NPR Audit Roll"; CatalogSupplier: Record "NPR Catalog Supplier")
    var
        Day: Text[2];
        Month: Text[2];
        Year: Text[4];
        TransactionCode: Text[2];
    begin
        if AuditRoll.Quantity > 0 then
            TransactionCode := '14'
        else
            TransactionCode := '15';

        Day := Format(Date2DMY(AuditRoll."Sale Date", 1));
        if StrLen(Day) < 2 then
            Day := '0' + Day;
        Month := Format(Date2DMY(AuditRoll."Sale Date", 2));
        if StrLen(Month) < 2 then
            Month := '0' + Month;
        Year := Format(Date2DMY(AuditRoll."Sale Date", 3));

        FieldArray[1] := TransactionCode;
        FieldArray[2] := CatalogSupplier."Trade Number";
        FieldArray[3] := AuditRoll."Sales Ticket No.";
        FieldArray[4] := Format(AuditRoll."Line No.");
        FieldArray[5] := CatalogSupplier.Code;
        FieldArray[6] := GetBarcode(AuditRoll."No.", AuditRoll."Variant Code");
        //-NPR5.43
        //FieldArray[ 7] := FORMAT(AuditRoll."Unit Price", 0, 1);
        FieldArray[7] := ConvertStr(Format(AuditRoll."Unit Price", 0, 1), ',', '.');
        //+313503
        FieldArray[8] := Day + Month + Year;
        FieldArray[9] := Format(Abs(AuditRoll.Quantity));
        FieldArray[10] := '';
    end;

    local procedure WriteLine(var FieldArray: array[200] of Text) LineText: Text[1024]
    var
        FieldNumber: Integer;
    begin
        LineText := '';
        FieldNumber := 0;
        repeat
            FieldNumber := FieldNumber + 1;
            LineText := LineText + FieldArray[FieldNumber];
            LineText := LineText + Format(FieldSep);
        //-NPR5.43
        //UNTIL FieldNumber > 10;
        until FieldNumber > 9;
        //+NPR5.43
    end;

    local procedure GetBarcode(ItemNo: Code[20]; VariantCode: Code[10]): Text
    var
        AlternativeNo: Record "NPR Alternative No.";
        ItemCrossReference: Record "Item Cross Reference";
        NonstockItem: Record "Nonstock Item";
        EANPrefixByCountry: Record "NPR EAN Prefix per Country";
        Vendor: Record Vendor;
    begin
        with AlternativeNo do begin
            SetRange(Type, Type::Item);
            SetRange(Code, ItemNo);
            SetRange("Variant Code", VariantCode);
            SetRange("Blocked Reason Code", '');
            if FindFirst then
                if StrLen(AlternativeNo."Alt. No.") = 13 then
                    exit("Alt. No.");
        end;

        with ItemCrossReference do begin
            SetRange("Item No.", ItemNo);
            SetRange("Cross-Reference Type", "Cross-Reference Type"::"Bar Code");
            SetRange("Variant Code", VariantCode);
            SetRange("Discontinue Bar Code", false);
            //-NPR5.46 [327838]
            /*
            IF FINDFIRST THEN
              EXIT("Cross-Reference No.");
            */
            case true of
                (Count = 1):
                    begin
                        FindFirst;
                        exit("Cross-Reference No.");
                    end;
                (Count > 1):
                    begin
                        FindSet;
                        repeat
                            NonstockItem.SetRange("Bar Code", "Cross-Reference No.");
                            if not NonstockItem.IsEmpty then
                                exit("Cross-Reference No.");
                        until Next = 0;
                        //if not in Nonstock Item, pick barcode based on country prefix setup
                        if Vendor.Get("Catalog Supplier"."Vendor No.") and (Vendor."Country/Region Code" <> '') then begin
                            EANPrefixByCountry.SetRange("Country Code", Vendor."Country/Region Code");
                            if EANPrefixByCountry.FindSet then
                                repeat
                                    SetFilter("Cross-Reference No.", StrSubstNo('%1*', EANPrefixByCountry.Prefix));
                                    if FindFirst then
                                        exit("Cross-Reference No.");
                                until EANPrefixByCountry.Next = 0;
                            SetRange("Cross-Reference No.");
                        end;
                        //if not in country prefix setup, fallback to original solution
                        FindFirst;
                        exit("Cross-Reference No.");
                    end;
            end;
            //+NPR5.46 [327838]
        end;

        exit('');

    end;

    local procedure FTPput()
    var
        Encoding: DotNet NPRNetUTF8Encoding;
        FtpWebRequest: DotNet NPRNetFtpWebRequest;
        Credential: DotNet NPRNetNetworkCredential;
        IoStream: DotNet NPRNetStream;
        FtpWebResponse: DotNet NPRNetFtpWebResponse;
        FileName: Text;
    begin
        if OutputText = '' then
            exit;

        //-NPR5.46 [327869]
        FileName := 'LogiqSalesStatistics_' + Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2>_<Hours24,2><Minutes,2>') + '.csv';
        //+NPR5.46 [327869]

        Encoding := Encoding.GetEncoding('windows-1252');
        if RemoteDir <> '' then
            //-NPR5.46 [327869]
            /*
              FtpWebRequest := FtpWebRequest.Create(Host + '/' + RemoteDir + '/' + 'LogiqSalesStatistics.csv')
            ELSE
              FtpWebRequest := FtpWebRequest.Create(Host +'/' + 'LogiqSalesStatistics.csv');
            */
          FtpWebRequest := FtpWebRequest.Create(Host + '/' + RemoteDir + '/' + FileName)
        else
            FtpWebRequest := FtpWebRequest.Create(Host + '/' + FileName);
        //+NPR5.46 [327869]
        FtpWebRequest.KeepAlive := true;
        FtpWebRequest.UseBinary := true;
        FtpWebRequest.UsePassive := true;
        FtpWebRequest.Method := 'STOR';
        FtpWebRequest.Credentials := Credential.NetworkCredential(UserName, PassWord);
        FtpWebRequest.ContentLength := Encoding.GetBytes((OutputText)).Length;
        IoStream := FtpWebRequest.GetRequestStream;
        IoStream.Write(Encoding.GetBytes(OutputText), 0, FtpWebRequest.ContentLength);
        IoStream.Flush;
        IoStream.Close;
        Clear(IoStream);

        FtpWebResponse := FtpWebRequest.GetResponse;
        if GuiAllowed then
            Message(FtpWebResponse.StatusDescription + '\' + Format(FtpWebResponse.StatusCode));

    end;

    procedure SetParameter(InStartDate: Date; InEndDate: Date; InHost: Text; InUserName: Text; InPassWord: Text; InRemoteDir: Text)
    begin
        StartDate := InStartDate;
        EndDate := InEndDate;
        Host := InHost;
        UserName := InUserName;
        PassWord := InPassWord;
        RemoteDir := InRemoteDir;
    end;
}

