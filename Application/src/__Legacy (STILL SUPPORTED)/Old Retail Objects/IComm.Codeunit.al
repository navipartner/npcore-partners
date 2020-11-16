codeunit 6014503 "NPR I-Comm"
{
    // //-NAS1.3 ved Nikolai Pedersen
    // tilf¢jet funktionerne
    //   FtpGetFiles der henter navnene på filerne og ligger dem i files.txt
    //   FtpDownloadSelectFiles der giver mulighed for at vælge hvilke filer man vil hente
    // 
    // //-NAS1.4 ved Nikolai Pedersen
    // tilf¢jet funktionerne
    //   smsDll
    //   smsDllMultiple
    //   ændret SendSMS
    // NPR4.16/20151016 CASE 225285 Removed unused functions + vars
    // NPR5.36/TJ  /20170914 CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                   Removed unused variables
    // NPR5.38/MHA /20180105  CASE 301053 Converted two empty local Text Constants into one Global ErrNotOpen


    trigger OnRun()
    begin
    end;

    var
        ErrNotOpen: Label '%1 %2 is not open';

    procedure CreateGiftVoucherSQL(var GiftVoucher: Record "NPR Gift Voucher")
    var
        RecRef: RecordRef;
    begin
        //OpretGavekort
        RecRef.Open(DATABASE::"NPR Gift Voucher");
        RecRef.SetPosition(GiftVoucher.GetPosition);
        RecRef.Find;
        //DB.onImportSQL_offlineregister( DBconnect );
        //DB.insertTableRec( DBconnect, RecRef );
        //DB.Close(DBconnect);
    end;

    procedure DBGiftVoucher(var GiftVoucher: Record "NPR Gift Voucher"; IsLocal: Boolean; Status: Boolean; Update: Boolean; var GiftVoucherAmount: Decimal): Integer
    var
        RecRef: RecordRef;
        "Field": FieldRef;
        StatusInt: Integer;
    begin
        //DBGavekort
        RecRef.Open(DATABASE::"NPR Gift Voucher");
        RecRef.SetPosition(GiftVoucher.GetPosition);
        //DB.onImportSQL_offlineregister( DBconnect );
        if IsLocal then begin
            //IF DB.getTableRec( DBconnect, RecRef, RecRef, TRUE, TRUE ) = 0 THEN
            //  ERROR( ErrGiftNotFound, Gavekort.Nummer );
            Field := RecRef.Field(GiftVoucher.FieldNo(Amount));
            GiftVoucherAmount := Field.Value;
            if Status then begin
                Field := RecRef.Field(GiftVoucher.FieldNo(Status));
                if Update then begin
                    GiftVoucher.Status := Field.Value;
                    GiftVoucher.Modify;
                end;
                //DB.Close( DBconnect );
                exit(Field.Value);
            end else
                if Update then
                    RecRef.Modify;
        end else begin
            if Status then begin
                // IF DB.getTableRec( DBconnect, RecRef, RecRef, TRUE, TRUE ) = 0 THEN
                //   ERROR( ErrGiftNotFound, Gavekort.Nummer );
                StatusInt := GiftVoucher.Status;
                // DB.setTableRec( DBconnect, RecRef, STRSUBSTNO( 'F%1=%2,F%3=%4', Gavekort.FIELDNO( Status ), StatusInt,
                //                 Gavekort.FIELDNO( "Indl¢st i butik" ), pling + COMPANYNAME + pling ));
            end else begin
                RecRef.Find;
                //DB.setTableRec( DBconnect, RecRef, '' );
            end;
        end;
        //DB.Close( DBconnect );
    end;

    procedure DBCreditVoucher(var CreditVoucher: Record "NPR Credit Voucher"; IsLocal: Boolean; Status: Boolean; Update: Boolean; var CreditVoucherAmount: Decimal): Integer
    var
        RecRef: RecordRef;
        "Field": FieldRef;
        StatusInt: Integer;
    begin
        //DBTilgodebevis()
        RecRef.Open(DATABASE::"NPR Credit Voucher");
        RecRef.SetPosition(CreditVoucher.GetPosition);
        //DB.onImportSQL_offlineregister( DBconnect );
        if IsLocal then begin
            //  IF DB.getTableRec( DBconnect, RecRef, RecRef, TRUE, TRUE ) = 0 THEN
            //    ERROR( ErrCreditNotFound, Tilgodebevis.Nummer );
            Field := RecRef.Field(CreditVoucher.FieldNo(Amount));
            CreditVoucherAmount := Field.Value;
            if Status then begin
                Field := RecRef.Field(CreditVoucher.FieldNo(Status));
                if Update then begin
                    CreditVoucher.Status := Field.Value;
                    CreditVoucher.Modify;
                end;
                //DB.Close( DBconnect );
                exit(Field.Value);
            end else
                if Update then
                    RecRef.Modify;
        end else begin
            if Status then begin
                //    IF DB.getTableRec( DBconnect, RecRef, RecRef, TRUE, TRUE ) = 0 THEN
                //      ERROR( ErrCreditNotFound, Tilgodebevis.Nummer );
                StatusInt := CreditVoucher.Status;
                // DB.setTableRec( DBconnect, RecRef, STRSUBSTNO( 'F%1=%2,F%3=%4',
                //                 Tilgodebevis.FIELDNO( Status ), StatusInt,
                //                Tilgodebevis.FIELDNO( "Indl¢st i butik" ), pling + COMPANYNAME + pling ));
            end else begin
                RecRef.Find;
                // DB.setTableRec( DBconnect, RecRef, '' );
            end;
        end;
        //DB.Close( DBconnect );
    end;

    procedure TestForeignGiftVoucher(ForeignGiftVoucherNo: Code[20]) Amount: Decimal
    var
        TestGiftVoucher: Record "NPR Gift Voucher";
    begin
        //TestFremmedGavekort()
        TestGiftVoucher."No." := ForeignGiftVoucherNo;
        if not (DBGiftVoucher(TestGiftVoucher, true, true, false, Amount) = TestGiftVoucher.Status::Open) then
            //-NPR5.38 [301053]
            //ERROR(ErrNotOpen,ForeignGiftVoucherNo);
            Error(ErrNotOpen, TestGiftVoucher.TableCaption, ForeignGiftVoucherNo);
        //+NPR5.38 [301053]
    end;

    procedure TestForeignCreditVoucher(ForeignCreditVoucherNo: Code[20]) Amount: Decimal
    var
        TestCreditVoucher: Record "NPR Credit Voucher";
    begin
        //TestFremmedTilgodebevis()
        TestCreditVoucher."No." := ForeignCreditVoucherNo;
        if not (DBCreditVoucher(TestCreditVoucher, true, true, false, Amount) = TestCreditVoucher.Status::Open) then
            //-NPR5.38 [301053]
            //ERROR(ErrNotOpen,ForeignCreditVoucherNo);
            Error(ErrNotOpen, TestCreditVoucher.TableCaption, ForeignCreditVoucherNo);
        //+NPR5.38 [301053]
    end;

    procedure GetStore(ForeignNo: Code[20]; IsGiftVoucher: Boolean): Code[20]
    var
        GiftVoucher: Record "NPR Gift Voucher";
        CreditVoucher: Record "NPR Credit Voucher";
        RecRef: RecordRef;
        "Field": FieldRef;
    begin
        //HentButik()
        //DB.onImportSQL_offlineregister( DBconnect );
        if IsGiftVoucher then begin
            GiftVoucher."No." := ForeignNo;
            RecRef.Open(DATABASE::"NPR Gift Voucher");
            RecRef.SetPosition(GiftVoucher.GetPosition);
            //  IF DB.getTableRec( DBconnect, RecRef, RecRef, TRUE, TRUE ) = 0 THEN
            //    ERROR( ErrGiftNotFound, Gavekort.Nummer );
        end else begin
            CreditVoucher."No." := ForeignNo;
            RecRef.Open(DATABASE::"NPR Credit Voucher");
            RecRef.SetPosition(CreditVoucher.GetPosition);
            //  IF DB.getTableRec( DBconnect, RecRef, RecRef, TRUE, TRUE ) = 0 THEN
            //    ERROR( ErrCreditNotFound, Tilgodebevis.Nummer );
        end;
        Field := RecRef.Field(1);
        //DB.Close(DBconnect);
        exit(Field.Value);
    end;
}

