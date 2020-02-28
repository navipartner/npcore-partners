codeunit 6014414 "Post Temp Audit Roll"
{
    // 
    // 001 NPK,MSP Rettelse s�ledes at man p� betalingsvalg lade udvalgte bev�gelser
    // bogf�re p� debitorposter i stedet som normalt p� finanskontier
    // //-002 Henrik, Overf�r SeO til varekldlinie.
    // 
    // 13-07-04 Opdateret til at k�re med temporer bogf�ring
    // 
    // NPR3.03e OHM 260107 - Posting type sale if item
    // 
    // NPR4.14/RMT /20150715  CASE 216519 - post prepayment from sales document when payment is posted
    // NPR4.18/RMT /20160128  CASE 233094 only lookup serial no in item ledger entries if full tracking for item
    // NPR5.22/JC  /20160321  CASE 237352 Error Gen. Template missing for BE
    // NPR5.22/TJ  /20160412  CASE 238601 Changed code in PosterDebitorIndbetaling to use our function when prepayment is processed
    // NPR5.22/JC  /20160421  CASE 239058 VAT calculation issue using VAT prod posting group from item, modified func PrintKey Filter from Text250 to Text500
    // NPR5.23/THRO/20160510  CASE 240004 RunUpdateChanges, RunTransfer and RunTransferItemLedger - fixed dialog not opened bug
    // NPR5.23/RMT /20160603  CASE 243209 no applies to ID in the gen. journal
    // NPR5.25/JC  /20160705  CASE 243792 Fixed VAT being added to discount amount
    // NPR5.25.01/AP/20160903 CASE 250201 Fixed posting error that may result in missing postings of Balancing and Customer Entries
    // NPR5.29/MHA /20170116  CASE 262116 Updated Gift- and Credit Voucher Text Variables to no overflow
    // NPR5.29/BHR /20170120  CASE 264068 Code to Allow Posting for Item Type::Service
    // NPR5.29/BHR /20172301  CASE 264081 Condition to check "Inventory posting Group"
    // NPR5.30/TJ  /20170224  CASE 266866 Commented out code in PosterVarekladde
    // NPR5.32/JDH /20170524  CASE 273761 Changed posting of negative sale with serial numbers
    // NPR5.36/AP  /20170705  CASE 282903 Changes to allow comments that are not directly inserted into audit roll
    //                                    Removed old and erroneous code that could update lines incorret before posting (changing posting setup).
    // NPR5.36/BR  /20170914  CASE 289641 Fill field "Bill-to/Pay-to No."
    // NPR5.36/TJ  /20170919  CASE 286283 Renamed variables/function with danish specific letter into english
    //                                    Removed unused variables
    // NPR5.38/BR  /20171030  CASE 294903 Added (Payment Type) Code to description
    // NPR5.38/JC  /20171221  CASE 300763 Fixed date formula calculation for multi languages
    // NPR5.38/BR  /20180109  CASE 301600 Added Check and Update of Audit Roll Link
    // NPR5.41/JDH /20180426 CASE 312644  Added indirect permissions to table Audit roll
    // NPR5.42/JC  /20180515 CASE 315194 Fix issue with getting register no. for Payment Type POS
    // NPR5.49/TJ  /20181210 CASE 331208 Publisher added OnAfterRunPostItemLedger
    // NPR5.51/LS  /20190709  CASE 351736  Changed function MovementEntries, length of "Global Dimension 1" from 10 to 20 as per standard Dim code
    // NPR5.53/ALPO/20191024 CASE 371955 Rounding related fields moved to POS Posting Profiles
    // NPR5.53/ALPO/20191025 CASE 371956 Dimensions: POS Store & POS Unit integration; discontinue dimensions on Cash Register
    // NPR5.53/JAKUBV/20200121  CASE 369361 Transport NPR5.53 - 21 January 2020

    Permissions = TableData "Audit Roll"=rimd;

    trigger OnRun()
    var
        RevRulle: Record "Audit Roll";
    begin
        RevRulle.SetFilter( "No.", '<>%1', '' );
        RevRulle.ModifyAll( Posted, false );
        RevRulle.ModifyAll("Item Entry Posted", false);
    end;

    var
        Dummy: Record "Audit Roll Posting" temporary;
        FinKldLinie: Record "Gen. Journal Line" temporary;
        FinKldLinieDebug: Record "Gen. Journal Line";
        GeneralPostingSetup: Record "General Posting Setup";
        BetalingsValg: Record "Payment Type POS";
        VarekldLinie: Record "Item Journal Line" temporary;
        AltVarenummer: Record "Alternative No.";
        Debitorpost: Record "Cust. Ledger Entry" temporary;
        RevisionUdbetaling: Record "Audit Roll Posting" temporary;
        RetailSetup: Record "Retail Setup";
        Debitorpost1: Record "Cust. Ledger Entry";
        Vare: Record Item;
        Kasse: Record Register;
        TmpJournalLineDim: Record TempBlob temporary;
        EkspBogfVarepost: Record "Sale POS";
        NFRetailCode: Codeunit "NF Retail Code";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        Window: Dialog;
        BogfDate: Date;
        blank: Code[10];
        AccountType: Option "G/L",Customer,Vendor,Bank,"Fixed Asset";
        Finkllbr: Integer;
        Varekllbr: Integer;
        DebPostLbrNr: Integer;
        Total: Integer;
        Counter: Integer;
        WindowIsOpen: Boolean;
        PostOnlySalesTicketNo: Boolean;
        StraksBogfVarePostFraEkspAfsl: Boolean;
        DoNotPost: Boolean;
        StraksBogf: Boolean;
        DebugPostingMsg: Boolean;
        ProgressVis: Boolean;
        GlobalPostingNo: Code[10];
        Text000: Label 'Gift Voucher %1';
        Text001: Label 'Credit Voucher %1';
        CompressedGLDescr: Label 'Todays changes %1 %2 Register %3';

    procedure PostSales(var TempPost: Record "Audit Roll Posting" temporary)
    var
        "S & R Setup": Record "Sales & Receivables Setup";
    begin
        //Bogf�rVaresalg

        with TempPost do begin
          SetRange("Sale Date", TempPost."Sale Date");
          SetFilter("Sales Ticket No.", TempPost.GetFilter("Sales Ticket No."));
          PrintKey( '"Virksomheds-bogf�ringsgruppe","Produkt-bogf�ringsgruppe", Ekspeditionsart, Type', GetFilters, 9 );
          CalcSums("Amount Including VAT", "Line Discount Amount" );
          GeneralPostingSetup.Get(GetRangeMax("Gen. Bus. Posting Group"),GetRangeMax("Gen. Prod. Posting Group"));
          GeneralPostingSetup.TestField("Sales Account");
          GeneralPostingSetup.TestField("Sales Line Disc. Account");

          PrintKey( 'F�r Dim', '', 91 );
          RetailSetup.Get;

          PrintKey( 'Efter Dim', '', 92 );

          // Posting off full amount
          "S & R Setup".Get;
          if ("S & R Setup"."Discount Posting" = "S & R Setup"."Discount Posting"::"All Discounts") or
             ("S & R Setup"."Discount Posting" = "S & R Setup"."Discount Posting"::"Line Discounts")
            then begin
              if ( "Amount Including VAT" + TempPost."Line Discount Amount" ) <> 0 then
                MovementEntries(GeneralPostingSetup."Sales Account",-( "Amount Including VAT" + TempPost."Line Discount Amount" ),
                                 "Register No.",AccountType::"G/L","Shortcut Dimension 1 Code",'',BogfDate,TempPost)
            end else
              MovementEntries(GeneralPostingSetup."Sales Account",-( "Amount Including VAT"),
                               "Register No.",AccountType::"G/L",TempPost."Shortcut Dimension 1 Code",'',BogfDate,TempPost);

          // Posting of discount amount
          if (TempPost."Line Discount Amount" <> 0) and
            ("S & R Setup"."Discount Posting" = "S & R Setup"."Discount Posting"::"All Discounts") or
            ("S & R Setup"."Discount Posting" = "S & R Setup"."Discount Posting"::"Line Discounts") then
            MovementEntries(GeneralPostingSetup."Sales Line Disc. Account",TempPost."Line Discount Amount","Register No.",AccountType::"G/L",
                            TempPost."Shortcut Dimension 1 Code",'',BogfDate,TempPost);

        end;
    end;

    procedure PostRegisterMovements(var TempPost: Record "Audit Roll Posting" temporary)
    var
        CurrentPost: Record "Audit Roll Posting" temporary;
    begin
        //Bogf�rKasseBev�gelser()

        RetailSetup.Get;

        with TempPost do begin
          SetCurrentKey( "Sale Type", Type, "No." );
          SetRange("Sale Date", "Sale Date" );
          SetRange("No.", "No.");
          PrintKey( 'Ekspeditionsart, Type, Nummer', GetFilters, 10 );
          CalcSums("Amount Including VAT");

          //-NPR5.42 [315194]
          if RetailSetup."Payment Type By Register" then begin
            if not BetalingsValg.Get("No.", "Register No.") then
              BetalingsValg.Get("No.", '');
          end else
          //+NPR5.42
            BetalingsValg.Get( "No." );
          if BetalingsValg."Account Type" = BetalingsValg."Account Type"::"G/L Account" then begin
            BetalingsValg.TestField("G/L Account No.");

            if "Amount Including VAT" <> 0 then begin
              MovementEntries(BetalingsValg."G/L Account No.","Amount Including VAT", "Register No.",AccountType::"G/L",
                              TempPost."Department Code",'', BogfDate, TempPost);
              //-NPR5.38 [300763]
              //SETFILTER( "Posting Date", '%1..', CALCDATE( '+1<D>', "Sale Date" ));
              SetFilter( "Posting Date", '%1..', CalcDate( '<+1D>', "Sale Date" ));
              //+NPR5.38
              CalcSums( "Amount Including VAT" );
              if "Amount Including VAT" <> 0 then begin
                CurrentPost := TempPost;
                FindFirst;
                repeat
                  SetRange( "Posting Date", "Posting Date" );
                  FindLast;
                  CalcSums( "Amount Including VAT" );
                  PostDayClearing( TempPost, BetalingsValg, "Amount Including VAT" );
                  SetFilter( "Posting Date", '>%1', CurrentPost."Sale Date" );
                until Next = 0;
              end;
              SetRange( "Posting Date" );
              TempPost := CurrentPost;
            end;
          end;

          if BetalingsValg."Account Type" = BetalingsValg."Account Type"::Customer then begin
            BetalingsValg.TestField("Customer No.");
            if "Amount Including VAT" <> 0 then
              MovementEntries(BetalingsValg."Customer No.","Amount Including VAT", "Register No.",AccountType::Customer,
              TempPost."Department Code",'', BogfDate, TempPost );
            end;
          if BetalingsValg."Account Type" = BetalingsValg."Account Type"::Bank then begin
            BetalingsValg.TestField( "Bank Acc. No." );
            if "Amount Including VAT" <> 0 then
              MovementEntries( BetalingsValg."Bank Acc. No.", "Amount Including VAT", "Register No.", AccountType::Bank,
                               TempPost."Department Code", '', BogfDate, TempPost );
          end;
        end;
    end;

    procedure PostRegisterMovementsPrPost(var RevRulle: Record "Audit Roll Posting" temporary)
    var
        Betalingsvalg: Record "Payment Type POS";
    begin
        //Bogf�rKassebev�gelserPrPost

        with RevRulle do begin
          //-NPR5.42 [315194]
          RetailSetup.Get;
          if RetailSetup."Payment Type By Register" then begin
            if not Betalingsvalg.Get("No.", "Register No.") then
              Betalingsvalg.Get("No.", '');
          end else
          //+NPR5.42
            Betalingsvalg.Get( "No." );

          if Betalingsvalg."Account Type" = Betalingsvalg."Account Type"::"G/L Account" then begin
            Betalingsvalg.TestField("G/L Account No.");
            if "Amount Including VAT" <> 0 then begin
              MovementEntries(
                Betalingsvalg."G/L Account No.",
                "Amount Including VAT",
                RevRulle."Register No.",
                AccountType::"G/L",
                RevRulle."Department Code",
                RevRulle.Description,
                BogfDate,
                RevRulle );
              if ( RevRulle."Posting Date" <> 0D ) and ( RevRulle."Posting Date" <> RevRulle."Sale Date" ) then begin
                PostDayClearing( RevRulle, Betalingsvalg, "Amount Including VAT" );
              end;
            end;
          end;

          if Betalingsvalg."Account Type" = Betalingsvalg."Account Type"::Customer then begin
            Betalingsvalg.TestField("Customer No.");
            if "Amount Including VAT" <> 0 then
              MovementEntries(
                Betalingsvalg."Customer No.",
                "Amount Including VAT",
                RevRulle."Register No.",
                AccountType::Customer,
                RevRulle."Department Code",
                RevRulle.Description,
                BogfDate,
                RevRulle );
          end;

          if Betalingsvalg."Account Type" = Betalingsvalg."Account Type"::Bank then begin
            Betalingsvalg.TestField( "Bank Acc. No." );
            if "Amount Including VAT" <> 0 then
              MovementEntries( Betalingsvalg."Bank Acc. No.",
                               "Amount Including VAT",
                               RevRulle."Register No.",
                               AccountType::Bank,
                               RevRulle."Department Code",
                               RevRulle.Description,
                               BogfDate,
                               RevRulle );
          end;
        end;
    end;

    procedure MovementEntries(Kontonummer: Code[20];Amount2: Decimal;Kassenr: Code[10];Kontotype: Integer;"Global Dimension 1": Code[20];ForceDesc: Text[50];"Posting Date": Date;var TempPost: Record "Audit Roll Posting" temporary)
    var
        Bogf1: Label 'Todays changes %1 Register %2';
        Bogf2: Label 'Paind on %1 Register %2';
        ItemGL: Record Item;
    begin
        //PosterBev�gelse
        Kasse.Get(Kassenr);
        Clear(FinKldLinie);
        Finkllbr += 1;
        FinKldLinie."Line No."     := Finkllbr;

        FinKldLinie."Document No." := PostedInvoiceDocumentNo( TempPost );
        //-NPR5.22
        FinKldLinie."Journal Template Name" := RetailSetup."Journal Type";
        FinKldLinie."Journal Batch Name"    := RetailSetup."Journal Name";
        //+NPR5.22
        FinKldLinie."Posting Date" := "Posting Date";
        FinKldLinie."Document Date"     := "Posting Date";
        case Kontotype of
          AccountType::"G/L":
            FinKldLinie."Account Type"  := FinKldLinie."Account Type"::"G/L Account";
          AccountType::Customer:
            FinKldLinie."Account Type"  := FinKldLinie."Account Type"::Customer;
          AccountType::Vendor:
            FinKldLinie."Account Type"  := FinKldLinie."Account Type"::Vendor;
          AccountType::Bank:
            FinKldLinie."Account Type"  := FinKldLinie."Account Type"::"Bank Account";
          AccountType::"Fixed Asset":
            FinKldLinie."Account Type"  := FinKldLinie."Account Type"::"Fixed Asset";
        end;

        FinKldLinie."Source Code"       := RetailSetup."Posting Source Code";
        FinKldLinie."Bal. Account No."  := '';
        FinKldLinie.Validate("Account No.", Kontonummer);

        if TempPost.Type = TempPost.Type::Item then
          FinKldLinie.Validate("Gen. Posting Type", FinKldLinie."Gen. Posting Type"::Sale);
        //-NPR5.36 [289641]
        if (Kasse."VAT Customer No." <> '') and (not (FinKldLinie."Account Type" in [FinKldLinie."Account Type"::Customer,FinKldLinie."Account Type"::Vendor])) then
          if (TempPost."Customer Type" = TempPost."Customer Type"::"Ord.") and (TempPost."Customer No." <> '') then
            FinKldLinie."Bill-to/Pay-to No." := TempPost."Customer No."
          else
            FinKldLinie."Bill-to/Pay-to No." := Kasse."VAT Customer No.";
        //+NPR5.36 [289641]

        //-NPR5.22
        if TempPost.Type = TempPost.Type::Item then begin
          if ItemGL.Get(TempPost."No.") then begin
            FinKldLinie.Validate("Gen. Prod. Posting Group", ItemGL."Gen. Prod. Posting Group");
            FinKldLinie.Validate("VAT Prod. Posting Group", ItemGL."VAT Prod. Posting Group");
            end;

          end;
        //+NPR5.22

        FinKldLinie.Validate(Amount,Amount2);

        case Kontotype of
          AccountType::"G/L":
            begin
              if TempPost."Gift voucher ref." <> '' then
                //-NPR5.29 [262116]
                //FinKldLinie.Description := STRSUBSTNO( Bogf3,TempPost."Gift voucher ref.",Kassenr)
                FinKldLinie.Description := CopyStr(StrSubstNo(Text000,TempPost."Gift voucher ref.",Kassenr),1,MaxStrLen(FinKldLinie.Description))
                //+NPR5.29 [262116]
              else if TempPost."Credit voucher ref." <> '' then
                //-NPR5.29 [262116]
                //FinKldLinie.Description := STRSUBSTNO( Bogf4,TempPost."Credit voucher ref.",Kassenr)
                FinKldLinie.Description := CopyStr(StrSubstNo(Text001,TempPost."Credit voucher ref.",Kassenr),1,MaxStrLen(FinKldLinie.Description))
                //+NPR5.29 [262116]
              else if RevisionUdbetaling."Sale Type" = RevisionUdbetaling."Sale Type"::"Out payment" then begin
                FinKldLinie.Description := CopyStr(RevisionUdbetaling.Description, 1, 50);
                Clear( RevisionUdbetaling );
              end else
                //-NPR5.38 [294903]
                //FinKldLinie.Description := STRSUBSTNO( Bogf1,"Posting Date",Kassenr);
                if TempPost.Type  = TempPost.Type::Payment then
                  FinKldLinie.Description := CopyStr(StrSubstNo( CompressedGLDescr,TempPost."No.","Posting Date",Kassenr),1,MaxStrLen(FinKldLinie.Description))
                else
                  FinKldLinie.Description := StrSubstNo( Bogf1,"Posting Date",Kassenr);
                //+NPR5.38 [294903]
            end;
          AccountType::Customer:
            FinKldLinie.Description := StrSubstNo( Bogf2, "Posting Date", Kassenr);
          AccountType::Bank:
            //-NPR5.38 [294903]
            //FinKldLinie.Description := STRSUBSTNO( Bogf1,"Posting Date",Kassenr);
            if TempPost.Type  = TempPost.Type::Payment then
              FinKldLinie.Description := CopyStr(StrSubstNo( CompressedGLDescr,TempPost."No.","Posting Date",Kassenr),1,MaxStrLen(FinKldLinie.Description))
            else
              FinKldLinie.Description := StrSubstNo( Bogf1,"Posting Date",Kassenr);
            //+NPR5.38 [294903]
        end;

        if ForceDesc <> '' then
          FinKldLinie.Description := ForceDesc;

        Kasse.Get(Kassenr);

        FinKldLinie."Document Date" := "Posting Date";
        FinKldLinie."System-Created Entry":=true;
        RetailSetup.Get;

        FinKldLinie."Shortcut Dimension 1 Code" := TempPost."Shortcut Dimension 1 Code" ;
        FinKldLinie."Shortcut Dimension 2 Code" := TempPost."Shortcut Dimension 2 Code" ;
        FinKldLinie."Dimension Set ID"          := TempPost."Dimension Set ID";

        if RetailSetup."Debug Posting" then begin
          FinKldLinieDebug.Copy( FinKldLinie );
          FinKldLinieDebug.Insert
        end else begin
          FinKldLinie.Insert;end;
    end;

    procedure PostTodaysGLEntries(var TempPost: Record "Audit Roll Posting" temporary)
    var
        FinKld: Record "Gen. Journal Line";
        FinKldSearch: Record "Gen. Journal Line";
        TmpJrnlLineDimloc: Record TempBlob temporary;
        NrSerieStyring: Codeunit NoSeriesManagement;
        FinKldNavn: Record "Gen. Journal Batch";
    begin
        //Bogf�rDagensFinansposteringer();
        
        RetailSetup.Get;
        Clear(Counter);
        if FinKldLinie.Find('-') then begin
          Total := FinKldLinie.Count;
          Clear( NFRetailCode );
          if RetailSetup."Post to Journal" then begin
            GlobalPostingNo := GetNewPostingNo(true);
          end;
          repeat
            Counter += 1;
            if RetailSetup."Post to Journal" then begin
              FinKld.Copy( FinKldLinie );
              FinKld."Journal Template Name" := RetailSetup."Journal Type";
              FinKld."Journal Batch Name" := RetailSetup."Journal Name";
              FinKldSearch.SetRange( "Journal Template Name", FinKld."Journal Template Name" );
              FinKldSearch.SetRange( "Journal Batch Name", FinKld."Journal Batch Name" );
              if FinKldNavn."No. Series" <> '' then begin
                FinKldNavn.Get( FinKld."Journal Template Name", FinKld."Journal Batch Name" );
                FinKld."Document No." := NrSerieStyring.GetNextNo( FinKldNavn."No. Series", Today, false );
              if FinKldSearch.Find('+') then
                FinKld."Line No." := FinKldSearch."Line No." + 10000;
              end else begin
               FinKld."Document No.":=PostedInvoiceDocumentNo( TempPost );
               if FinKldSearch.Find('+') then
                  FinKld."Line No." := FinKldSearch."Line No." + 10000;
              end;
              FinKld."System-Created Entry" := false;
              FinKld."Document Type"                  := FinKld."Document Type"::" ";
              FinKld."Shortcut Dimension 1 Code"      := FinKldLinie."Shortcut Dimension 1 Code" ;
              FinKld."Shortcut Dimension 2 Code"      := FinKldLinie."Shortcut Dimension 2 Code" ;
              FinKld."Dimension Set ID"               := FinKldLinie."Dimension Set ID" ;
        
              FinKld.Insert;
            end else begin
              //-NPR5.25.01 [250201]
              /*Removing this modification.
               Never (ever!) change active key fields while performing iteration!
               If needed, these must be set before iteration starts or in another dublicate cursor variable,
               or else FinKldLinie.NEXT will behave unexpectable.
              //-NPR5.22
              FinKldLinie."Journal Template Name" := Ops�tning."Journal Type";
              FinKldLinie."Journal Batch Name"    := Ops�tning.Journalname;
              //+NPR5.22
              */
              //+NPR5.25.01 [250201]
              NFRetailCode.CR414PostTodaysGLEntries( FinKldLinie );
            end;
            StatusVindueOpdater(10,'',Round(Counter / Total) * 10000);
          until FinKldLinie.Next = 0;
        end;
        
        Clear(Counter);
        
        if VarekldLinie.Find('-') then begin
          Total := VarekldLinie.Count;
          repeat
            Counter += 1;
            TmpJrnlLineDimloc.DeleteAll;
            ItemJnlPostLine.RunWithCheck(VarekldLinie);
            StatusVindueOpdater(11,'',Round(Counter / Total) * 10000);
          until VarekldLinie.Next = 0;
        end else
          StatusVindueOpdater(11,'', 10000);
        
        Debitorpost1.LockTable;
        if Debitorpost.Find('-') then begin
          if Debitorpost1.Find('+') then;
          DebPostLbrNr := Debitorpost1."Entry No.";
          repeat
            Debitorpost1 := Debitorpost;
            Debitorpost1."Entry No." := Debitorpost."Entry No." + DebPostLbrNr;
            RetailSetup.Get;
          until Debitorpost.Next = 0;
        end;

    end;

    procedure PostTodaysItemEntries(var TempPost: Record "Audit Roll Posting" temporary)
    var
        TmpJrnlLineDimloc: Record TempBlob temporary;
    begin
        //Bogf�rDagensFinansposteringer();

        RetailSetup.Get;
        Clear(Counter);

        if VarekldLinie.Find('-') then begin
          Total := VarekldLinie.Count;
          repeat
            Counter += 1;
            TmpJrnlLineDimloc.DeleteAll;
            ItemJnlPostLine.RunWithCheck(VarekldLinie);
            StatusVindueOpdater(11,'',Round(Counter / Total) * 10000);
          until VarekldLinie.Next = 0;
        end else
          StatusVindueOpdater(11,'', 10000);
    end;

    procedure PosterFremValDifferencer(var Rec: Record "Audit Roll Posting" temporary)
    var
        DiffTekst: Label 'Cash register %1, Difference %2 %3';
        AuditRoll: Record "Audit Roll";
        Period: Record Period;
        PeriodLine: Record "Period Line";
        CurrencyAmount: Decimal;
        Counting: Decimal;
        Difference: Decimal;
        ErrNotSet: Label 'Fixedprice on paymentsselection %1 has not been set';
    begin
        //PosterKasseafslutning()
        RetailSetup.Get();
        Kasse.Get(Rec."Register No.");

        Rec.TestField(Type,Rec.Type::"Open/Close");
        Rec.TestField(Posted,false);
        Rec.TestField(Balancing,true);

        PeriodLine.SetRange("Register No.",Rec."Register No.");
        PeriodLine.SetRange("Sales Ticket No.",Rec."Sales Ticket No.");

        Period.SetRange("Register No.", Rec."Register No.");
        Period.SetRange("Sales Ticket No.",Rec."Sales Ticket No.");
        Period.FindSet;

        BetalingsValg.SetRange("To be Balanced",true);
        BetalingsValg.SetRange("Processing Type",
                               BetalingsValg."Processing Type"::"Foreign Currency");

        if BetalingsValg.FindSet then repeat
          Counting := 0;
          CurrencyAmount := 0;

          AuditRoll.SetRange("Register No.", Rec."Register No.");
          AuditRoll.SetRange("Sales Ticket No.",
                             Period."Opening Sales Ticket No.",
                             Period."Sales Ticket No.");
          AuditRoll.SetRange("Sale Type",AuditRoll."Sale Type"::Payment);
          AuditRoll.SetRange(Type,AuditRoll.Type::Payment);
          AuditRoll.SetRange("No.",BetalingsValg."No.");

          if AuditRoll.FindSet then begin
            CurrencyAmount += AuditRoll."Currency Amount";
          end;

          PeriodLine.SetRange("Payment Type No.", BetalingsValg."No.");

          if PeriodLine.FindSet then repeat
            Counting += PeriodLine.Amount;
          until PeriodLine.Next = 0;

          Difference := CurrencyAmount - Counting;

          // Insert G/L journal line.
          if Difference > 0 then begin
            Finkllbr += 1;
            FinKldLinie.Init;
            //-NPR5.25.01 [250201]
            FinKldLinie."Journal Template Name" := RetailSetup."Journal Type";
            FinKldLinie."Journal Batch Name"    := RetailSetup."Journal Name";
            //+NPR5.25.01 [250201]
            FinKldLinie."Line No." := Finkllbr;

            FinKldLinie."Document No."  := PostedInvoiceDocumentNo( Rec );

            FinKldLinie."Posting Date"  := Rec."Sale Date";
            FinKldLinie."Document Date" := Rec."Sale Date";
            FinKldLinie."Source Code"   := RetailSetup."Posting Source Code";

            if Difference > 0 then
              FinKldLinie.Validate("Account No.",Kasse."Difference Account");
            if Difference < 0 then
              FinKldLinie.Validate("Account No.",Kasse."Difference Account - Neg.");

            if (BetalingsValg."Fixed Rate" <= 0) and
               (BetalingsValg."Processing Type" <> BetalingsValg."Processing Type"::Cash) then
              Error( ErrNotSet, BetalingsValg."No." );

            if BetalingsValg."Processing Type" <> BetalingsValg."Processing Type"::Cash then
              FinKldLinie.Validate( Amount, Difference * BetalingsValg."Fixed Rate" / 100 )
            else
              FinKldLinie.Validate( Amount, Difference * BetalingsValg."Fixed Rate" / 100 );

            if BetalingsValg."Account Type" = BetalingsValg."Account Type"::"G/L Account" then begin
              FinKldLinie."Account Type" := FinKldLinie."Account Type"::"G/L Account";
              FinKldLinie.Validate("Bal. Account No.", BetalingsValg."G/L Account No." );
            end;
            if BetalingsValg."Account Type" = BetalingsValg."Account Type"::Bank then begin
              FinKldLinie."Account Type" := FinKldLinie."Account Type"::"Bank Account";
              FinKldLinie.Validate("Bal. Account No.", BetalingsValg."Bank Acc. No." );
            end;

            FinKldLinie.Description := StrSubstNo(DiffTekst, Rec."Register No.", Difference, BetalingsValg.Description);

            FinKldLinie."Shortcut Dimension 1 Code" := Rec."Shortcut Dimension 1 Code";
            FinKldLinie."Shortcut Dimension 2 Code" := Rec."Shortcut Dimension 2 Code";
            FinKldLinie."Dimension Set ID"          := Rec."Dimension Set ID";

            RetailSetup.Get;

            FinKldLinie."System-Created Entry" := true;

            if RetailSetup."Debug Posting" then begin
              FinKldLinieDebug.Copy( FinKldLinie );
              FinKldLinieDebug.Insert;
            end else
              FinKldLinie.Insert;
          end;
        until BetalingsValg.Next = 0;
    end;

    procedure PosterVarekladde(var RevRulle: Record "Audit Roll Posting" temporary;Straks: Boolean;Bogfdate: Date): Boolean
    var
        Sporing: Record "Reservation Entry";
        Varepost: Record "Item Ledger Entry";
        tVareKld: Record "Item Journal Line";
        ItemTrackingCode: Record "Item Tracking Code";
        VendorReturnReason: Codeunit "Vendor Return Reason";
        ItemJrnl: Record Item;
        POSUnit: Record "POS Unit";
    begin
        //Postervarekladde()
        RetailSetup.Get;

        with RevRulle do begin
          VendorReturnReason.CreateRetPurchOrder(RevRulle);

          Kasse.Get("Register No.");
          POSUnit.Get("Register No.");  //NPR5.53 [371956]
          VarekldLinie.Init;
          Varekllbr += 1;

          VarekldLinie."Line No."                := Varekllbr;

          if RetailSetup."Appendix no. eq Sales Ticket" then
            VarekldLinie."Document No." := "Sales Ticket No."
          else
            VarekldLinie."Document No." := PostedInvoiceDocumentNo( RevRulle );

          VarekldLinie."Entry Type"                  := VarekldLinie."Entry Type"::Sale;
          VarekldLinie."Source No."                  := "Customer No.";
          VarekldLinie."Source Type"                 := VarekldLinie."Source Type"::Customer;

          //-NPR5.30 [266866]
          //IF "Customer Type" = "Customer Type"::Kontant THEN
          //  VarekldLinie."Cash Customer Number"      := "Customer No.";
          //+NPR5.30 [266866]

          VarekldLinie."Posting Date"           := Bogfdate;
          VarekldLinie."Document Time"          := "Closing Time";
          VarekldLinie."Document Date"          := Bogfdate;
          //-NPR5.30 [266866]
          //VarekldLinie.Color                    := Color;
          //VarekldLinie.Size                     := Size;
          //+NPR5.30 [266866]
          VarekldLinie."Discount Amount"        := "Line Discount Amount";
          //-NPR5.25 [243792]
          if (VarekldLinie."Discount Amount" <> 0) and ItemJrnl.Get(RevRulle."No.") then begin
            if ItemJrnl."Price Includes VAT" then
              VarekldLinie."Discount Amount" := VarekldLinie."Discount Amount"/((100 + RevRulle."VAT %")/100);
          end;
          //+NPR5.25 [243792]
          VarekldLinie."Discount Type"          := "Discount Type";
          VarekldLinie."Discount Code"          := CopyStr("Discount Code",1,10);
          //-NPR5.30 [266866]
          //VarekldLinie."Term Discount Code"     := "Period Discount code";
          //+NPR5.30 [266866]
          VarekldLinie."Vendor No."            := Vendor;
          VarekldLinie."Item Group No."   := "Item Group";
          VarekldLinie."Register Number"        := "Register No.";
          VarekldLinie."Reason Code"            := "Reason Code";
          VarekldLinie."Bin Code"               := "Bin Code";

          //-NPR5.30 [266866]
          //IF Ops�tning."Transfer SeO Item Entry" THEN
          //  VarekldLinie."Serial No. not Created"           := "Serial No. not Created";
          //+NPR5.30 [266866]

          if not Vare.Get("No.") then begin
            AltVarenummer.SetCurrentKey("Alt. No.");
            AltVarenummer.SetRange("Alt. No.","No.");
            if AltVarenummer.Find('-') then
              "No." := AltVarenummer.Code
            else
              Vare.Get( "No." );
            Vare.Get(AltVarenummer.Code);
          end;

          //-NPR5.29 [264068]
          //VarekldLinie.VALIDATE("Item No.","No.");
          if Vare.Type <> Vare.Type::Service then
          VarekldLinie.Validate("Item No.","No.")
          else begin
          VarekldLinie."Item No." := "No.";
          VarekldLinie."Gen. Bus. Posting Group" := "Gen. Bus. Posting Group";
          VarekldLinie."Gen. Prod. Posting Group" := "Gen. Prod. Posting Group";
          end;
          //+NPR5.29 [264068]
          VarekldLinie.Validate(Quantity,Quantity);
          VarekldLinie.Validate("Unit of Measure Code",Unit);
          VarekldLinie.Validate(Amount,Amount);
          VarekldLinie."Gen. Bus. Posting Group" := "Gen. Bus. Posting Group";
          VarekldLinie.Description                    := Description;
          VarekldLinie."Salespers./Purch. Code"         := "Salesperson Code";
          if Lokationskode='' then
          VarekldLinie."Location Code"                  := Kasse."Location Code" else
            VarekldLinie."Location Code"                := Lokationskode;
          VarekldLinie."Source Code"                      := RetailSetup."Posting Source Code";
          if "Serial No." <> '' then begin
            Sporing.SetCurrentKey("Entry No." ,Positive );
            Sporing.SetRange( Positive, false );
            if Sporing.Find('+') then;
            Sporing.Init;
            Sporing."Entry No." += 1;
            Sporing.Positive := false;
            Sporing."Item No." := "No.";
            Sporing."Location Code" := Lokationskode;
            Sporing."Quantity (Base)" := -Quantity;
            Sporing."Reservation Status" := Sporing."Reservation Status"::Prospect;
            //-NPR4.18
            //IF Quantity > 0 THEN BEGIN
            Vare.TestField("Item Tracking Code");
            ItemTrackingCode.Get(Vare."Item Tracking Code");
            if ItemTrackingCode."SN Specific Tracking" then begin
            //+NPR4.18
              //-NPR5.32 [273761]
              if (Quantity <= 0) then begin
                //Return Sale
                Sporing."Creation Date" := Today;
              end else begin
                //Normal Sale
                //+NPR5.32 [273761]

                Varepost.SetCurrentKey( Open, Positive, "Item No.", "Serial No." );
                Varepost.SetRange( Open, true );
                Varepost.SetRange( Positive, true );
                Varepost.SetRange( "Serial No.", "Serial No." );
                Varepost.SetRange( "Item No.", "No." );
                Varepost.FindFirst;
                Sporing."Creation Date" := Varepost."Posting Date";
              //-NPR5.32 [273761]
              end;
              //+NPR5.32 [273761]

            end else begin
              //-NPR4.18
              if Quantity<=0 then begin
              //+NPR4.18
                Sporing."Creation Date" := Today;
                VarekldLinie.Validate( Amount, -VarekldLinie.Amount );
              //-NPR4.18
              end;
              //+NPR4.18
            end;
            Sporing."Source Type" := 83;
            Sporing."Source Subtype" := 1;
            Sporing."Source ID" := VarekldLinie."Journal Template Name";
            Sporing."Source Batch Name" := VarekldLinie."Journal Batch Name";
            Sporing."Source Ref. No." := VarekldLinie."Line No.";
            Sporing."Expected Receipt Date" := Today;
            Sporing."Serial No." := "Serial No.";
            Sporing."Created By" := RevRulle."Salesperson Code";
            Sporing."Qty. per Unit of Measure" := Quantity;
            Sporing.Quantity := -Quantity;
            Sporing."Qty. to Handle (Base)" := -Quantity;
            Sporing."Qty. to Invoice (Base)" := -Quantity;
            Sporing.Insert;
          end;
          VarekldLinie."Vendor No."                 := Vendor;
          VarekldLinie."Variant Code"                := CopyStr( "Variant Code", 1, 10 );
          VarekldLinie."Group Sale" := Vare."Group sale";

          if "Unit Cost" <> 0 then
            VarekldLinie.Validate("Unit Cost","Unit Cost")
          else if "Unit Cost (LCY)"<>0 then
            VarekldLinie."Unit Cost" := Vare."Unit Cost";

          VarekldLinie.Validate( "Return Reason Code", "Return Reason Code" );

          //-NPR5.53 [371956]-revoked
        //  IF RevRulle."Shortcut Dimension 1 Code" = '' THEN
        //    VarekldLinie.VALIDATE("Shortcut Dimension 1 Code",Kasse."Global Dimension 1 Code")
        //  ELSE
        //    VarekldLinie.VALIDATE("Shortcut Dimension 1 Code","Shortcut Dimension 1 Code");
        //
        //  IF RevRulle."Shortcut Dimension 2 Code" = '' THEN
        //    VarekldLinie.VALIDATE("Shortcut Dimension 2 Code",Kasse."Global Dimension 2 Code")
        //  ELSE
        //    VarekldLinie.VALIDATE("Shortcut Dimension 2 Code","Shortcut Dimension 2 Code");
          //+NPR5.53 [371956]-revoked

          VarekldLinie."Dimension Set ID" := "Dimension Set ID";
          //-NPR5.53 [371956]
          if "Shortcut Dimension 1 Code" = '' then
            VarekldLinie.Validate("Shortcut Dimension 1 Code",POSUnit."Global Dimension 1 Code")
          else
            VarekldLinie."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
          if "Shortcut Dimension 2 Code" = '' then
            VarekldLinie.Validate("Shortcut Dimension 2 Code",POSUnit."Global Dimension 2 Code")
          else
            VarekldLinie."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
          //+NPR5.53 [371956]

          if not RetailSetup."Debug Posting" then begin
            VarekldLinie.Insert;
          end else begin
            tVareKld.Copy( VarekldLinie );
            tVareKld.Insert;
          end;

          if Straks then begin
            //+DIM
            ItemJnlPostLine.RunWithCheck(VarekldLinie);
            //-DIM
          end;
        end;
    end;

    procedure PosterDebitorIndbetaling(var RevRulle: Record "Audit Roll Posting" temporary)
    var
        Kasse: Record Register;
        txtIndbetaling: Label 'Payment';
        txtIndbetalingSales: Label 'Payment on %1 %2';
        Bogf1: Label 'POS-Debitsale on %1 Register %2';
        txtKasse: Label '%1/Register %2';
        SalesHeader: Record "Sales Header";
        SalesPost: Codeunit "Sales-Post";
        SalesDocTypeText: Text;
        txtSalesQuote: Label 'quote';
        txtSalesOrder: Label 'order';
        txtSalesInoice: Label 'invoice';
        txtSalesCreditMemo: Label 'credit memo';
        txtSalesBlanketOrder: Label 'blanket order';
        txtSalesReturnOrder: Label 'return order';
        StdCodeunitCode: Codeunit "Std. Codeunit Code";
    begin
        //PosterDebitorIndbetaling()
        
        Clear(FinKldLinie);
        
        with RevRulle do begin
            RetailSetup.Get;
        
            Finkllbr += 1;
            FinKldLinie."Line No."  := Finkllbr;
            //-NPR5.25.01 [250201]
            FinKldLinie."Journal Template Name" := RetailSetup."Journal Type";
            FinKldLinie."Journal Batch Name"    := RetailSetup."Journal Name";
            //+NPR5.25.01 [250201]
        
            FinKldLinie."Document No." := PostedInvoiceDocumentNo( RevRulle );
        
            FinKldLinie."Posting Date" := BogfDate;
            FinKldLinie."Document Date" := BogfDate;
            FinKldLinie."Source Code" := RetailSetup."Posting Source Code";
            FinKldLinie."Bal. Account No." := '';
            if "Sale Type" = "Sale Type"::Deposit then begin
              FinKldLinie.Validate("Document Type",FinKldLinie."Document Type"::Payment);
              FinKldLinie."Account Type" := FinKldLinie."Account Type"::Customer;
              FinKldLinie.Validate("Account No.","No.");
              FinKldLinie.Validate(Amount,-"Amount Including VAT");
              FinKldLinie."Allow Application" := true;
              /*************************************************************************
              * Bruges kun i forbindelse med udl�sninger fa gl.Butik3 / Butik2000     *
              * l�sninger. Konverterer debetsalg til finansposteringer p� debitor     *
              *************************************************************************/
              if "N3 Debit Sale Conversion" then
                FinKldLinie.Description := StrSubstNo( Bogf1, BogfDate, "Register No.")
              else begin
                //-NPR4.14
                //FinKldLinie.Description := txtIndbetaling;
                if RevRulle."Sales Document No."<>'' then begin
                  case RevRulle."Sales Document Type" of
                    SalesHeader."Document Type"::Quote: SalesDocTypeText := txtSalesQuote;
                    SalesHeader."Document Type"::Order: SalesDocTypeText := txtSalesOrder;
                    SalesHeader."Document Type"::Invoice: SalesDocTypeText := txtSalesInoice;
                    SalesHeader."Document Type"::"Credit Memo": SalesDocTypeText := txtSalesCreditMemo;
                    SalesHeader."Document Type"::"Blanket Order": SalesDocTypeText := txtSalesBlanketOrder;
                    SalesHeader."Document Type"::"Return Order": SalesDocTypeText := txtSalesReturnOrder;
                  end;
                  FinKldLinie.Description := StrSubstNo(txtIndbetalingSales,SalesDocTypeText,RevRulle."Sales Document No.");
                end else
                  FinKldLinie.Description := txtIndbetaling;
                //+NPR4.14
              end;
            end;
        
        
            if (Type = Type::Payment) then begin
              BetalingsValg.Get("No.");
              FinKldLinie."Account Type" := FinKldLinie."Account Type"::"G/L Account";
              FinKldLinie.Validate("Account No.",BetalingsValg."G/L Account No.");
              FinKldLinie.Validate(Amount,"Amount Including VAT");
              FinKldLinie.Description := StrSubstNo( txtKasse,Description,"Register No." );
            end;
        
            if (Type = Type::"G/L") then begin
              FinKldLinie."Account Type" := FinKldLinie."Account Type"::"G/L Account";
              FinKldLinie.Validate("Account No.","No.");
              FinKldLinie.Validate(Amount,"Amount Including VAT");
              FinKldLinie.Description := StrSubstNo( txtKasse, Description, "Register No.")
            end;
        
            Kasse.Get( "Register No." );
        
            FinKldLinie."Document Date" := BogfDate;
            FinKldLinie."Applies-to Doc. Type" := RevRulle."Buffer Document Type";
            FinKldLinie.Validate("Applies-to Doc. No.",RevRulle."Buffer Invoice No.");
            //-NPR5.23
            //FinKldLinie.VALIDATE("Applies-to ID","Buffer ID");
            //+NPR5.23
            FinKldLinie."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
            FinKldLinie."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
            FinKldLinie."Dimension Set ID"          := "Dimension Set ID";
        
            RetailSetup.Get;
        
            FinKldLinie."System-Created Entry" := true;
        
            if RetailSetup."Debug Posting" then begin
              FinKldLinieDebug.Copy( FinKldLinie );
              FinKldLinieDebug.Insert;
            end else begin
              FinKldLinie.Insert;
            end;
        
            Modify;
        
            //-NPR4.14
            if SalesHeader.Get("Sales Document Type","Sales Document No.") then begin
              if "Sales Document Prepayment" then begin
                SalesHeader.CalcFields("Amount Including VAT");
                SalesHeader.SetHideValidationDialog(true);
                SalesHeader.Validate("Prepayment %",RevRulle."Sales Doc. Prepayment %");
                SalesHeader.Modify(true);
        
        //-NPR5.22
        //        SalesPostYNPrepmt.SetHideValidationDialog(TRUE);
        //        SalesPostYNPrepmt.PostPrepmtInvoiceYN(SalesHeader,FALSE);
                  StdCodeunitCode.PostPrepmtInvoiceYN(SalesHeader);
        //+NPR5.22
        
              end;
              if "Sales Document Invoice" or "Sales Document Ship" then begin
                SalesHeader.Ship := "Sales Document Ship";
                SalesHeader.Invoice := "Sales Document Invoice";
                SalesHeader.Modify;
                SalesPost.Run(SalesHeader);
              end;
            end;
            //+NPR4.14
        end;

    end;

    procedure PosterKasseAfslutning(var Rec: Record "Audit Roll Posting" temporary)
    var
        "Bogf. Tekst 1": Label 'EOD register %1';
        "Bogf. Tekst 2": Label 'Cash register %1 to bank';
        Betalingsvalg: Record "Payment Type POS";
        "Bogf. Tekst 3": Label 'Register %1 to Change Register';
        Period: Record Period;
    begin
        //PosterKasseafslutning()

        RetailSetup.Get();
        Kasse.Get(Rec."Register No.");

        Rec.TestField(Type,Rec.Type::"Open/Close");
        Rec.TestField(Posted,false);
        Rec.TestField(Balancing,true);

        // ********************************
        //  Difference
        // ********************************

        if Rec.Difference <> 0 then begin
          Finkllbr += 1;
          FinKldLinie.Init;
          FinKldLinie."Line No."      := Finkllbr;
          //-NPR5.25.01 [250201]
          FinKldLinie."Journal Template Name" := RetailSetup."Journal Type";
          FinKldLinie."Journal Batch Name"    := RetailSetup."Journal Name";
          //+NPR5.25.01 [250201]

          FinKldLinie."Document No."  := PostedInvoiceDocumentNo( Rec );

          FinKldLinie."Posting Date"  := Rec."Sale Date";
          FinKldLinie."Document Date" := Rec."Sale Date";
          FinKldLinie."Source Code"   := RetailSetup."Posting Source Code";

          if Rec.Difference > 0 then
            FinKldLinie.Validate("Account No.",Kasse."Difference Account");

          if Rec.Difference < 0 then
            FinKldLinie.Validate("Account No.",Kasse."Difference Account - Neg.");

          FinKldLinie.Validate( Amount, Rec.Difference );
          FinKldLinie."Account Type" := FinKldLinie."Account Type"::"G/L Account";

          FinKldLinie.Validate("Bal. Account No.",Kasse.Account);
          FinKldLinie.Description := StrSubstNo("Bogf. Tekst 1",Rec."Register No.");
          FinKldLinie."Shortcut Dimension 1 Code" := Rec."Shortcut Dimension 1 Code";
          FinKldLinie."Shortcut Dimension 2 Code" := Rec."Shortcut Dimension 2 Code";
          FinKldLinie."Dimension Set ID"          := Rec."Dimension Set ID";

          RetailSetup.Get;

          FinKldLinie."System-Created Entry" := true;

          if RetailSetup."Debug Posting" then begin
            FinKldLinieDebug.Copy( FinKldLinie );
            FinKldLinieDebug.Insert;
          end else
            FinKldLinie.Insert;
        end;

        PosterFremValDifferencer(Rec);

        // ********************************
        //  Overf�r til Bank
        // ********************************

        if Rec."Transferred to Balance Account" <> 0 then begin
          Finkllbr += 1;
          FinKldLinie.Init;
          //-NPR5.25.01 [250201]
          FinKldLinie."Journal Template Name" := RetailSetup."Journal Type";
          FinKldLinie."Journal Batch Name"    := RetailSetup."Journal Name";
          //+NPR5.25.01 [250201]
          FinKldLinie."Line No." := Finkllbr;

          FinKldLinie."Document No." := PostedInvoiceDocumentNo( Rec );

          FinKldLinie."Posting Date" := Rec."Sale Date";
          FinKldLinie."Document Date" := Rec."Sale Date";
          if Kasse."Balanced Type" = Kasse."Balanced Type"::Finans then
            FinKldLinie."Account Type" := FinKldLinie."Account Type"::"G/L Account"
          else
            FinKldLinie."Account Type" := FinKldLinie."Account Type"::"Bank Account";
          FinKldLinie."Source Code" := RetailSetup."Posting Source Code";

          Period.SetRange("Register No.",     Rec."Register No.");
          Period.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");
          Period.Find('-');

          FinKldLinie."External Document No." := Period."Money bag no.";

          FinKldLinie.Validate( "Account No.", Kasse."Balance Account" );
          FinKldLinie.Validate( Amount, Rec."Transferred to Balance Account" );

          FinKldLinie.Validate("Bal. Account No.",Kasse.Account);

          if Period.Comment = '' then
            FinKldLinie.Description := StrSubstNo("Bogf. Tekst 2",Rec."Register No.")
          else
            FinKldLinie.Description := CopyStr( Period.Comment, 1, 50);

          FinKldLinie."Shortcut Dimension 1 Code" := Rec."Shortcut Dimension 1 Code";
          FinKldLinie."Shortcut Dimension 2 Code" := Rec."Shortcut Dimension 2 Code";
          FinKldLinie."Dimension Set ID"          := Rec."Dimension Set ID";

          RetailSetup.Get;

          FinKldLinie."System-Created Entry" := true;

          if RetailSetup."Debug Posting" then begin
            FinKldLinieDebug.Copy( FinKldLinie );
            FinKldLinieDebug.Insert;
          end else
            FinKldLinie.Insert;
        end;


        // ********************************
        //  Overf�r til Vekselkasse
        // ********************************

        if Rec."Change Register" <> 0 then begin
          Finkllbr += 1;
          FinKldLinie.Init;
          //-NPR5.25.01 [250201]
          FinKldLinie."Journal Template Name" := RetailSetup."Journal Type";
          FinKldLinie."Journal Batch Name"    := RetailSetup."Journal Name";
          //+NPR5.25.01 [250201]
          FinKldLinie."Line No." := Finkllbr;

          FinKldLinie."Document No." := PostedInvoiceDocumentNo( Rec );

          FinKldLinie."Posting Date" := Rec."Sale Date";
          FinKldLinie."Document Date" := Rec."Sale Date";
          if Kasse."Balanced Type" = Kasse."Balanced Type"::Finans then
            FinKldLinie."Account Type" := FinKldLinie."Account Type"::"G/L Account";

          FinKldLinie."Source Code" := RetailSetup."Posting Source Code";
          Kasse.TestField( "Register Change Account" );
          FinKldLinie.Validate( "Account No.", Kasse."Register Change Account" );
          FinKldLinie.Validate( Amount, Rec."Change Register" );

          FinKldLinie.Validate("Bal. Account No.",Kasse.Account);
          FinKldLinie.Description := StrSubstNo("Bogf. Tekst 3",Rec."Register No.");

          FinKldLinie."Shortcut Dimension 1 Code" := Rec."Shortcut Dimension 1 Code";
          FinKldLinie."Shortcut Dimension 2 Code" := Rec."Shortcut Dimension 2 Code";
          FinKldLinie."Dimension Set ID"          := Rec."Dimension Set ID";

          RetailSetup.Get;

          FinKldLinie."System-Created Entry" := true;

          if RetailSetup."Debug Posting" then begin
            FinKldLinieDebug.Copy( FinKldLinie );
            FinKldLinieDebug.Insert;
          end else
            FinKldLinie.Insert;
        end;
    end;

    procedure StatusWindowOpen()
    var
        ln100: Label ' Transferring             @100@@@@@@@@@@@@@@@@ \';
        ln101: Label ' Removing Old Lines       @101@@@@@@@@@@@@@@@@ \';
        ln102: Label ' Testing                  @102@@@@@@@@@@@@@@@@ \\';
        ln103: Label ' Updating Changes         @103@@@@@@@@@@@@@@@@ \';
        ln1: Label ' G/L Posting \';
        ln2: Label ' Processing Date          #1################## \';
        ln3: Label ' Register No.             #2################## \';
        ln5: Label ' Customer payment         @6@@@@@@@@@@@@@@@@@@ \';
        ln4: Label ' Debit No-Sale Entry      @8@@@@@@@@@@@@@@@@@@ \';
        ln6: Label ' Item Posting             @3@@@@@@@@@@@@@@@@@@ \';
        ln7: Label ' G/L Item Posting         @4@@@@@@@@@@@@@@@@@@ \';
        ln8: Label ' Net Change               @5@@@@@@@@@@@@@@@@@@ \';
        ln9: Label ' Gift/Credit Voucher      @9@@@@@@@@@@@@@@@@@@ \';
        ln10: Label ' G/L / Payout             @7@@@@@@@@@@@@@@@@@@ \\';
        ln11: Label ' Posting G/L Entries      @10@@@@@@@@@@@@@@@@@ \';
        ln12: Label ' Posting Item Entries     @11@@@@@@@@@@@@@@@@@ \\';
    begin
        //StatusVindue�ben()

        WindowIsOpen := true;

        Window.Open( ln100 + ln101 + ln102 + ln1 + ln2 + ln3 + ln4 + ln5 + ln7 + ln8 + ln9 + ln10 + ln11 + ln6 + ln12 + ln103 );
    end;

    procedure StatusVindueClear()
    var
        heltal: Record "Integer";
    begin
        //StatusVindueClear
        if not WindowIsOpen then
          exit;

        heltal.SetRange(Number,3,11);
        if heltal.Find('-') then repeat
          Window.Update(heltal.Number,0);
        until heltal.Next = 0;

        Window.Update( 103, 0 );
    end;

    procedure StatusVindueLuk(Text: Text[100])
    begin
        //StatusVindueLuk()
        if not WindowIsOpen then
          exit;
        Window.Close;
        WindowIsOpen := false;
    end;

    procedure StatusVindueOpdater(Number: Integer;Text: Text[100];Value: Integer)
    begin
        //StatusVindueOpdater()
        if not WindowIsOpen then
          exit;

        if (Number in [1,2]) then
          Window.Update(Number,Text)
        else
          Window.Update(Number,Value)
    end;

    procedure PostedInvoiceDocumentNo(var TempPost: Record "Audit Roll Posting" temporary): Code[20]
    var
        txtPos: Label 'POS %1-%2';
    begin
        //Bogf�rtBilagsNrFkt

        if PostOnlySalesTicketNo then
          if  GlobalPostingNo = '' then
            exit(StrSubstNo(txtPos, TempPost."Register No.", TempPost."Sales Ticket No."))
          else
            exit(StrSubstNo(txtPos, Kasse."Register No.", GlobalPostingNo))
        else
          exit(StrSubstNo(txtPos, Kasse."Register No.", GlobalPostingNo));
    end;

    procedure StraksBogfVarePostFraAfslEksp(var Ekspedition: Record "Sale POS";StraksBogf: Boolean;PostParam: Boolean)
    begin
        //StraksBogfVarePostFraAfslEksp

        EkspBogfVarepost.Copy(Ekspedition);
        StraksBogfVarePostFraEkspAfsl := StraksBogf;
        DoNotPost := not PostParam;
    end;

    procedure StraksBogfCurrent(SetProp: Boolean)
    begin
        //StraksBogfCurrent()
        StraksBogf := SetProp;
    end;

    procedure PrintKey("Key": Text[250];"Filter": Text[500];ID: Integer)
    var
        Msg: Label 'Key : %1\Filter : %2\ID : %3';
        t001: Label 'Debug posting stopped';
    begin
        if DebugPostingMsg then
          if not Confirm( Msg, true, Key, Filter, ID ) then
            Error( t001 );
    end;

    procedure RunPost(var Rec: Record "Audit Roll Posting" temporary)
    var
        BetValgRec: Record "Payment Type POS";
        POSUnit: Record "POS Unit";
        XBonNr: Code[20];
        ChangeSum: Decimal;
        ChangeDep: Code[20];
        t002: Label 'Posting of audit roll is not possible in offline mode';
        POSAuditRollIntegration: Codeunit "POS-Audit Roll Integration";
        POSSetup: Codeunit "POS Setup";
    begin
        //RunPost
        
        with Rec do begin
        DebugPostingMsg := false;
        RetailSetup.Get();
        
        //-NPR5.53 [369361]
        //IF RetailSetup."Company - Function" = RetailSetup."Company - Function"::Offline THEN
        //  ERROR(t002);
        //+NPR5.53 [369361]
        
        if not Rec.FindLast then
          exit;
        
        if not DoNotPost then begin
          Kasse.Get("Register No.");
          //-NPR5.53 [371955]
          POSUnit.Get("Register No.");
          POSSetup.SetPOSUnit(POSUnit);
          //+NPR5.53 [371955]
          PostOnlySalesTicketNo := true;
          if FindSet then begin
            XBonNr := "Sales Ticket No.";
            repeat
              if (XBonNr <> "Sales Ticket No.") then
                PostOnlySalesTicketNo := false;
              XBonNr := "Sales Ticket No.";
            until (Next = 0) or (not PostOnlySalesTicketNo);
          end;
        
          RetailSetup.Get;
          if RetailSetup."Debug Posting" then begin
            FinKldLinieDebug.DeleteAll;
          end;
        
          FinKldLinie.DeleteAll;
          VarekldLinie.DeleteAll;
          Debitorpost.DeleteAll;
          TmpJournalLineDim.DeleteAll;
        
          RetailSetup.TestField("Posting Source Code");
          BogfDate := Rec."Sale Date";
        
          StatusVindueOpdater(1,Format(BogfDate),0);
          StatusVindueOpdater(2,"Register No.",0);
        
            LockTable;
        
            /* #########################################
               Post register balancing (end-of-day )
              ######################################### */
        
            Reset;
            SetCurrentKey( Type, Balancing );
            SetRange(Type,Type::"Open/Close");
            SetRange(Balancing,true);
            PrintKey( 'Type,Kasseafslutning', GetFilters, 1 );
            if FindFirst then repeat
              PosterKasseAfslutning(Rec);
            until Next = 0;
        
            /* #########################################
               Post customer entries to debit zero sales
              ######################################### */
        
            Clear(Quantity);
            Clear(Dummy);
            Reset;
            if Debitorpost.Find('+')
              then;
            SetCurrentKey( "Sale Type", Type, "Customer Type", "Customer No." );
            SetRange("Sale Type","Sale Type"::Payment);
            SetRange(Type,Type::Payment);
            SetRange("Customer Type","Customer Type"::"Ord.");
            SetFilter("Customer No.",'<> %1',blank);
            Total := Count;
            PrintKey( 'Ekspeditionsart, Type, Debitortype, Kundenummer', GetFilters, 2 );
            Dummy.CopyFilters( Rec );
            if FindSet then begin
              repeat
                Counter += Count;
                SetCurrentKey( "Sale Type", Type, "Customer Type", "Customer No." );
                CopyFilters( Dummy );
                FindLast;
                StatusVindueOpdater(8,'',Round(Counter / Total) * 10000);
              until Next = 0;
            end;
            StatusVindueOpdater(8,'',10000);
        
            /* ########################################
              Post payments on customer account
              ######################################## */
        
            Reset;
            Clear(Quantity);
            SetCurrentKey( "Sale Type", Type );
            SetRange("Sale Type","Sale Type"::Deposit);
            SetRange(Type,Type::Customer);
            Total := Count;
            PrintKey( 'Ekspeditionsart, Type', GetFilters, 3 );
            if FindSet then begin
              repeat
                Counter += 1;
                PosterDebitorIndbetaling( Rec );
                StatusVindueOpdater(6,'',Round(Counter / Total) * 10000);
              until Next = 0
            end;
            StatusVindueOpdater(6,'',10000);
        
            /* ################################################
              Post (item) sales on g/l accounts
              ################################################ */
        
            Clear(Dummy);
            Clear(Counter);
            Reset;
            //-NPR5.22
            //    SETCURRENTKEY( "Sale Type",Type,
            //                   "Gen. Bus. Posting Group","Gen. Prod. Posting Group",
            //                   "Shortcut Dimension 1 Code","Shortcut Dimension 2 Code","Dimension Set ID"
            //                 );
            SetCurrentKey( "Sale Type",Type,
                            "Gen. Bus. Posting Group","Gen. Prod. Posting Group",
                            "Shortcut Dimension 1 Code","Shortcut Dimension 2 Code","Dimension Set ID",
                            "VAT Bus. Posting Group","VAT Prod. Posting Group");
            //-NPR5.22
            SetRange("Sale Type","Sale Type"::Sale);
            SetRange(Type,Type::Item);
            Total := Count;
            PrintKey( 'Kassenummer,Ekspeditionsdato,Ekspeditionsart,Type,Bogf�rt...', GetFilters, 5 );
            PrintKey( '"Virksomheds-bogf�ringsgruppe","Produkt-bogf�ringsgruppe"', GetFilters, 5 );
            Dummy.CopyFilters( Rec );
            if FindFirst then begin
              repeat
                SetRange("Gen. Bus. Posting Group", "Gen. Bus. Posting Group");
                SetRange("Gen. Prod. Posting Group", "Gen. Prod. Posting Group");
                //-NPR5.22
                SetRange("VAT Bus. Posting Group", "VAT Bus. Posting Group");
                SetRange("VAT Prod. Posting Group", "VAT Prod. Posting Group");
                //+NPR5.22
                SetRange("Shortcut Dimension 1 Code", "Shortcut Dimension 1 Code");
                SetRange("Shortcut Dimension 2 Code", "Shortcut Dimension 2 Code");
                SetRange("Dimension Set ID", "Dimension Set ID");
                Counter += Count;
                PostSales( Rec );
                //-NPR5.22
                //    SETCURRENTKEY( "Sale Type",Type,
                //                   "Gen. Bus. Posting Group","Gen. Prod. Posting Group",
                //                   "Shortcut Dimension 1 Code","Shortcut Dimension 2 Code","Dimension Set ID"
                //                 );
                SetCurrentKey( "Sale Type",Type,
                                "Gen. Bus. Posting Group","Gen. Prod. Posting Group",
                                "Shortcut Dimension 1 Code","Shortcut Dimension 2 Code","Dimension Set ID",
                                "VAT Bus. Posting Group","VAT Prod. Posting Group");
                //-NPR5.22
                FindLast;
                CopyFilters( Dummy );
                StatusVindueOpdater(4,'',Round(Counter / Total) * 10000);
              until Next = 0;
            end;
            StatusVindueOpdater(4,'',10000);
        
            /* ##############################################
              Post money transactions - Payments
              ############################################## */
        
            Clear(Counter);
            Clear(Dummy);
            Reset;
            SetCurrentKey( "Sale Type",Type,"No.","Posting Date","Shortcut Dimension 1 Code","Shortcut Dimension 2 Code","Dimension Set ID" );
            SetRange("Sale Type","Sale Type"::Payment);
            SetRange(Type,Type::Payment);
            Total := Count;
            PrintKey( 'Ekspeditionsart, Type, Nummer', GetFilters, 6 );
            Dummy.CopyFilters( Rec );
            if FindSet then begin
              repeat
                //-NPR5.42 [315194]
                if RetailSetup."Payment Type By Register" then begin
                  if not BetValgRec.Get("No.", "Register No.") then
                    BetValgRec.Get("No.", '');
                end else
                //+NPR5.42
                  BetValgRec.Get("No.");
                case BetValgRec.Posting of
                  BetValgRec.Posting::Condensed :
                    begin
                      SetRange("Shortcut Dimension 1 Code", "Shortcut Dimension 1 Code");
                      SetRange("Shortcut Dimension 2 Code", "Shortcut Dimension 2 Code");
                      SetRange("Dimension Set ID", "Dimension Set ID");
                      PostRegisterMovements( Rec );
                      Counter += Count;
                      SetCurrentKey( "Sale Type",Type,"No.","Posting Date","Shortcut Dimension 1 Code","Shortcut Dimension 2 Code","Dimension Set ID" );
                      FindLast;
                      CopyFilters( Dummy );
                      StatusVindueOpdater(5,'',Round(Counter / Total) * 10000);
                    end;
                  BetValgRec.Posting::"Single Entry" :
                    begin
                      PostRegisterMovementsPrPost( Rec );
                      Counter += 1;
                      StatusVindueOpdater(5,'',Round(Counter / Total) * 10000);
                    end;
                end;
              until Next = 0;
            end;
            StatusVindueOpdater(5,'',10000);
        
            /* #################################################################
              Post payments on g/l account - gift/credit vouchers
              ################################################################# */
        
            Clear(Counter);
            Reset;
            SetCurrentKey( "Sale Type", Type );
            SetRange("Sale Type","Sale Type"::Deposit);
            SetRange(Type,Type::"G/L");
            Total := Count;
            PrintKey( 'Ekspeditionsart, Type', GetFilters, 7 );
            if FindSet then repeat
              Counter += 1;
              MovementEntries("No.",-"Amount Including VAT","Register No.",AccountType::"G/L","Department Code", '', BogfDate, Rec );
              StatusVindueOpdater(9,'',Round(Counter / Total) * 10000);
            until Next = 0;
            StatusVindueOpdater(9,'',10000);
        
            /* ##############################################
              Post outpayments on g/l accounts
              ############################################## */
        
            Clear(Counter);
            Reset;
            SetCurrentKey( "Sale Type", Type );
            SetRange("Sale Type","Sale Type"::"Out payment");
            SetRange(Type,Type::"G/L");
            Total := Count;
            PrintKey( 'Ekspeditionsart,Type', GetFilters, 8 );
            if FindSet then repeat
              RevisionUdbetaling := Rec;
              Counter += 1;
              //IF "No." = Kasse.Rounding THEN BEGIN  //NPR5.53 [371955]-revoked
              if "No." = POSSetup.RoundingAccount(true) then begin  //NPR5.53 [371955]
                ChangeSum += "Amount Including VAT";
                ChangeDep := "Department Code";
              end else
                MovementEntries("No.","Amount Including VAT","Register No.",AccountType::"G/L","Department Code", '', BogfDate, Rec );
              StatusVindueOpdater(7,'',Round(Counter / Total) * 10000);
            until Next = 0;
            if ChangeSum <> 0 then
              //MovementEntries( Kasse.Rounding, ChangeSum, "Register No.", AccountType::"G/L", ChangeDep, '', BogfDate, Rec );  //NPR5.53 [371955]-revoked
              MovementEntries(POSSetup.RoundingAccount(true),ChangeSum,"Register No.",AccountType::"G/L",ChangeDep,'',BogfDate,Rec);  //NPR5.53 [371955]
        
            StatusVindueOpdater(7,'',10000);
        
          Reset;
        
          PostTodaysGLEntries( Rec );
        
          Reset;
        
          //-NPR5.38 [301600]
          if FindSet then repeat
            POSAuditRollIntegration.CheckPostingStatusFromAuditRollPosting(Rec,false,true);
          until Next = 0;
          //+NPR5.38 [301600]
        
          if not RetailSetup."Debug Posting" then begin
            SetRange("Posted Doc. No.",'');
            ModifyAll("Posted Doc. No.", PostedInvoiceDocumentNo( Rec ));
            SetRange("Posted Doc. No.");
            ModifyAll(Posted,true);
            FinKldLinie.DeleteAll( true );
            VarekldLinie.DeleteAll( true );
          end;
        
        end;   /*** DoNotbogf�r ***/
        
        Reset;
        
        end;

    end;

    procedure RunPostItemLedger(var Rec: Record "Audit Roll Posting" temporary)
    var
        XBonNr: Code[20];
        t002: Label 'Posting of audit roll is not possible in offline mode';
        POSAuditRollIntegration: Codeunit "POS-Audit Roll Integration";
    begin
        //RunPostItemLedger
        
        with Rec do begin
        DebugPostingMsg := false;
        RetailSetup.Get();
        
        //-NPR5.53 [369361]
        //IF RetailSetup."Company - Function" = RetailSetup."Company - Function"::Offline THEN
        //  ERROR(t002);
        //+NPR5.53 [369361]
        
        if not Rec.FindLast then
          exit;
        
        if not DoNotPost then begin
          PostOnlySalesTicketNo := true;
          if Find('-') then begin
            XBonNr := "Sales Ticket No.";
            repeat
              if (XBonNr <> "Sales Ticket No.") then
                PostOnlySalesTicketNo := false;
              XBonNr := "Sales Ticket No.";
            until (Next = 0) or (not PostOnlySalesTicketNo);
          end;
        
          RetailSetup.Get;
          if RetailSetup."Debug Posting" then begin
            FinKldLinieDebug.DeleteAll;
          end;
        
          FinKldLinie.DeleteAll;
          VarekldLinie.DeleteAll;
          Debitorpost.DeleteAll;
          TmpJournalLineDim.DeleteAll;
        
        
          RetailSetup.TestField("Posting Source Code");
          BogfDate := Rec."Sale Date";
        
          StatusVindueOpdater(1,Format(BogfDate),0);
          StatusVindueOpdater(2,"Register No.",0);
        
            LockTable;
        
            /* ##############################################
              Post�rer Varebev�gelser
              ############################################## */
        
            Reset;
            SetCurrentKey( "Sale Type", Type, "Item Entry Posted" );
            SetRange("Sale Type","Sale Type"::Sale);
            SetRange(Type,Type::Item);
            SetRange( "Item Entry Posted", false );
            Total := Count;
            Clear(Counter);
            PrintKey( 'Ekspeditionsart, Type, "Varepost bogf�rt"', GetFilters, 4 );
            if FindSet then begin
              repeat
                Counter += 1;
                //-NPR5.38 [301600]
                POSAuditRollIntegration.CheckPostingStatusFromAuditRollPosting(Rec,true,false);
                //+NPR5.38 [301600]
                if Quantity <> 0 then begin
                      PosterVarekladde( Rec, false, BogfDate );
                end;
                StatusVindueOpdater(3,'',Round(Counter / Total) * 10000);
              until Next = 0;
            end;
            StatusVindueOpdater(3,'',10000);
        
          Rec.ModifyAll("Item Entry Posted", true);
        
          Reset;
        
          PostTodaysItemEntries( Rec );
        
          Reset;
        
        end;   /*** DoNotbogf�r ***/
        
        if StraksBogfVarePostFraEkspAfsl then begin
          SetCurrentKey( "Sale Type", Type, "Item Entry Posted" );
          SetRange("Sale Type","Sale Type"::Sale);
          SetRange(Type,Type::Item);
          SetRange( "Item Entry Posted", false );
        
          if RetailSetup."Immediate postings" = RetailSetup."Immediate postings"::"Serial No." then
            SetFilter( "Serial No.", '<>%1', '' );
        
          if FindSet then repeat
            PosterVarekladde( Rec, true, Rec."Sale Date" );
            Modify;
          until Next = 0;
          ModifyAll( "Item Entry Posted", true );
        end;
        
        Reset;
        
        end;
        
        //-NPR5.49 [331208]
        OnAfterRunPostItemLedger(Rec);
        //+NPR5.49 [331208]

    end;

    procedure SetProgressVis(Vis: Boolean)
    begin
        //SetProgressVis
        ProgressVis := Vis;
    end;

    procedure RunTest(var Rec: Record "Audit Roll Posting" temporary)
    var
        Debitor: Record Customer;
        Finanskonto: Record "G/L Account";
        Betalingsvalg: Record "Payment Type POS";
        "BogfOps.": Record "General Posting Setup";
        MomsbogfOps: Record "VAT Posting Setup";
        VirksBogfGrp: Record "Gen. Business Posting Group";
        ProdBogfGrp: Record "Gen. Product Posting Group";
        DebBogfGrp: Record "Customer Posting Group";
        t002: Label 'Customer %1 %2 does not exists. Posting terminated!';
        t003: Label 'Financialaccount %1 %2 does not exists. Posting terminated!';
        nCount: Integer;
        nTotal: Integer;
    begin
        //RunTest
        
        with Rec do  begin
          Reset;
          SetCurrentKey("Sale Date");
          nTotal := Rec.Count;
        
          if Find('-') then repeat
            if ProgressVis then begin
              nCount += 1;
              Window.Update( 102, Round( nCount / nTotal * 10000, 1, '>' ));
            end;
        
            //-NPR5.36 [282903]
            if ("Sale Type" <> "Sale Type"::Comment) and not (Type in [Type::Cancelled,Type::Comment]) then
            //+NPR5.36 [282903]
            TestField("No.");
            case "Sale Type" of
        
        /*-1-*/ "Sale Type"::Sale : begin
        
        //-NPR5.36 [282903]
        //        {##########################################################
        //         ## Kodestykket er tilf�jet i forbindelse med indl�sning ##
        //         ## fra tekstbaseret Navision ---28012000 NP-MD V1.8     ##
        //         ##########################################################}
        //
        //         IF "System-Created Entry" THEN BEGIN
        //           Vare.LOCKTABLE;
        //           IF NOT Vare.GET("No.") THEN BEGIN
        //             IF STRLEN("No.") > 10 THEN
        //               Varegruppe.SETRANGE("No.",DELSTR("No.",9))
        //             ELSE
        //               Varegruppe.SETRANGE("No.","No.");
        //             IF NOT Varegruppe.FIND('-') THEN BEGIN
        //               Vare.INIT;
        //               Vare."No." := "No.";
        //               Vare.VALIDATE(Description,Description);
        //               Vare.VALIDATE("Item Group",'1');
        //               Vare.INSERT;
        //             END ELSE BEGIN
        //               Vare.INIT;
        //               Vare."No." := "No.";
        //               Vare.VALIDATE(Description, txtAuto + Description);
        //               Vare.VALIDATE("Item Group","No.");
        //               Vare."Group sale" := TRUE;
        //               Vare.INSERT;
        //             END;
        //           END;
        //         END;
        //
        //        {######------SLUT------######}
        //
        //        IF NOT Vare.GET("No.") THEN ERROR(t001,"No.",Description);
        //        Vare.TESTFIELD(Blocked,FALSE);
        //        Vare.TESTFIELD("VAT Bus. Posting Gr. (Price)");
        //        Vare.TESTFIELD("Gen. Prod. Posting Group");
        //        //-NPR5.29 [264081]
        //        IF Vare.Type <> Vare.Type::Service THEN
        //        //-NPR5.29 [264081]
        //        Vare.TESTFIELD("Inventory Posting Group");
        //        Vare.TESTFIELD("VAT Prod. Posting Group");
        //
        //
        //        {##########################################################
        //         ## Kodestykket er tilf�jet i forbindelse med indl�sning ##
        //         ## fra tekstbaseret Navision ---30112000 NP-MD          ##
        //         ##########################################################}
        //
        //        "VAT Bus. Posting Group" := Vare."VAT Bus. Posting Gr. (Price)";
        //        "VAT Prod. Posting Group" := Vare."VAT Prod. Posting Group";
        //        "Gen. Prod. Posting Group" := Vare."Gen. Prod. Posting Group";
        //        MODIFY;
        //+NPR5.36 [282903]
                TestField("Gen. Bus. Posting Group");
                "BogfOps.".Get("Gen. Bus. Posting Group","Gen. Prod. Posting Group");
                "BogfOps.".TestField("Sales Account");
                Finanskonto.Get("BogfOps."."Sales Account");
                VirksBogfGrp.Get("Gen. Bus. Posting Group");
                ProdBogfGrp.Get("Gen. Prod. Posting Group");
                MomsbogfOps.Get(VirksBogfGrp."Def. VAT Bus. Posting Group",ProdBogfGrp."Def. VAT Prod. Posting Group");
                MomsbogfOps.TestField("Sales VAT Account");
                Finanskonto.Get(MomsbogfOps."Sales VAT Account");
                Finanskonto.TestField(Blocked,false);
        
                /*######------SLUT------######*/
        
              end;
        
        
        /*-2-*/ "Sale Type"::Deposit : begin
        
                if Type = Type::Customer then begin
                  if not Debitor.Get("No.") then
                    Error(t002,"No.",Description);
        
                /*##########################################################
                 ## Kodestykket er tilf�jet i forbindelse med indl�sning ##
                 ## fra tekstbaseret Navision ---30112000 NP-MD          ##
                 ##########################################################*/
        
                DebBogfGrp.Get(Debitor."Customer Posting Group");
                DebBogfGrp.TestField("Receivables Account");
                Finanskonto.Get(DebBogfGrp."Receivables Account");
                Finanskonto.TestField(Blocked,false);
        
                /*######------SLUT------######*/
        
                end;
              end;
        
        
        /*-3-*/ "Sale Type"::"Out payment" : begin
                if Type = Type::"G/L" then begin
                  if not Finanskonto.Get("No.") then
                    Error(t003,
                      "No.",Description);
                  Finanskonto.TestField(Blocked,false);
                end;
              end;
        
        /*-4-*/ "Sale Type"::Payment : begin
        
                Betalingsvalg.Get("No.");
                /*##########################################################
                 ## Kodestykket er tilf�jet i forbindelse med indl�sning ##
                 ## fra tekstbaseret Navision ---30112000 NP-MD          ##
                 ##########################################################*/
        
                case Betalingsvalg."Account Type" of
                  Betalingsvalg."Account Type"::"G/L Account" : begin
                    Betalingsvalg.TestField("G/L Account No.");
                    Finanskonto.Get(Betalingsvalg."G/L Account No.");
                  end;
                  Betalingsvalg."Account Type"::Customer : begin
                    Betalingsvalg.TestField( "Customer No." );
                    Debitor.Get( Betalingsvalg."Customer No." );
                  end;
                end;
        
                Finanskonto.TestField(Blocked,false);
        
                /*######------SLUT------######*/
        
              end;
            end;
          until Next = 0;
        end;
        //-NPR5.23
        if ProgressVis then
        //+NPR5.23
          Window.Update( 102, 10000 );

    end;

    procedure RunTransfer(var TempPost: Record "Audit Roll Posting" temporary;var Revisionsrulle: Record "Audit Roll"): Integer
    begin
        //RunTransfer()
        //-NPR5.23
        //EXIT(TempPost.TransferFromRev( Revisionsrulle, TempPost, Window ));
        if WindowIsOpen then
          exit(TempPost.TransferFromRev( Revisionsrulle, TempPost, Window ))
        else
          exit(TempPost.TransferFromRevSilent( Revisionsrulle, TempPost ));
        //+NPR5.23
    end;

    procedure RunTransferItemLedger(var TempPost: Record "Audit Roll Posting" temporary;var Revisionsrulle: Record "Audit Roll"): Integer
    begin
        //RunTransferItemLedger
        //-NPR5.23
        //EXIT(TempPost.TransferFromRevItemLedger( Revisionsrulle, TempPost, Window ));
        if WindowIsOpen then
          exit(TempPost.TransferFromRevItemLedger( Revisionsrulle, TempPost, Window ))
        else
          exit(TempPost.TransferFromRevSilentItemLedg( Revisionsrulle, TempPost));
        //+NPR5.23
    end;

    procedure RemoveSuspendedPayouts(var Rulle: Record "Audit Roll Posting" temporary)
    var
        nCount: Integer;
        nTotal: Integer;
        Linie: Record "Audit Roll Posting" temporary;
    begin
        //FjernH�ngendeUdbetalingerTemp

        Rulle.SetCurrentKey( "Sale Type", Type, "No." );
        Rulle.SetRange("Sale Type",Rulle."Sale Type"::"Out payment");
        Rulle.SetRange(Type,Rulle.Type::"G/L");
        Rulle.SetRange("No.",'*');

        nTotal := Rulle.Count;
        nCount := 0;

        Linie.CopyFilters( Rulle );
        if Rulle.Find('-') then repeat
          if ProgressVis then begin
            nCount += 1;
            Window.Update( 101, Round( nCount / nTotal * 5000, 1, '>' ));
          end;
          Rulle.Reset;
          Rulle.SetCurrentKey( "Sales Ticket No." );
          Rulle.SetRange( "Sales Ticket No.", Rulle."Sales Ticket No." );
          Rulle.DeleteAll;
          Rulle.SetCurrentKey( "Sale Type", Type, "No." );
          Rulle.CopyFilters( Linie );
        until Rulle.Next = 0;

        Rulle.SetRange("Sale Type",Rulle."Sale Type"::Deposit);
        Rulle.SetRange(Type,Rulle.Type::Customer);
        nTotal := Rulle.Count;
        nCount := 0;

        Linie.CopyFilters( Rulle );
        if Rulle.Find('-') then repeat
          if ProgressVis then begin
            nCount += 1;
            Window.Update( 101, Round( nCount / nTotal * 5000 + 50000, 1, '>' ));
          end;
          Rulle.Reset;
          Rulle.SetCurrentKey( "Sales Ticket No." );
          Rulle.SetRange( "Sales Ticket No.", Rulle."Sales Ticket No." );
          Rulle.DeleteAll;
          Rulle.SetCurrentKey( "Sale Type", Type, "No." );
          Rulle.CopyFilters( Linie );
        until Rulle.Next = 0;
        if ProgressVis then
          Window.Update( 101, 10000 );
    end;

    procedure RunUpdateChanges(var TempPost: Record "Audit Roll Posting" temporary)
    begin
        //RunUpdateChanges()
        //-NPR5.23
        //TempPost.UpdateChanges( Window );
        if WindowIsOpen then
          TempPost.UpdateChanges( Window )
        else
          TempPost.UpdateChangesSilent();
        //+NPR5.23
    end;

    procedure PostDayClearing(var TempAuditRoll: Record "Audit Roll Posting" temporary;var PaymentType: Record "Payment Type POS";Amount: Decimal)
    begin
        //PostDayClearing()
        PaymentType.TestField( "Day Clearing Account" );

        with TempAuditRoll do begin
          MovementEntries(
            PaymentType."G/L Account No.", -"Amount Including VAT", "Register No.", AccountType::"G/L",
            "Department Code", Description, BogfDate, TempAuditRoll );
          MovementEntries(
            PaymentType."Day Clearing Account", "Amount Including VAT", "Register No.", AccountType::"G/L",
            "Department Code", Description, BogfDate, TempAuditRoll );
          MovementEntries(
            PaymentType."G/L Account No.", "Amount Including VAT", "Register No.", AccountType::"G/L",
            "Department Code", Description, "Posting Date", TempAuditRoll );
          MovementEntries(
            PaymentType."Day Clearing Account", -"Amount Including VAT", "Register No.", AccountType::"G/L",
            "Department Code", Description, "Posting Date", TempAuditRoll );
        end;
    end;

    procedure GetNewPostingNo(increment1: Boolean): Code[20]
    var
        Nos: Codeunit NoSeriesManagement;
        npc: Record "Retail Setup";
        code20: Code[20];
    begin
        //getNewPostingNo
        //Instead of kasse."Last G/L Posting No."

        npc.Get;
        code20 := Nos.GetNextNo(npc."Posting No. Management",Today,increment1);

        exit(code20);
    end;

    procedure SetPostingNo("Last G/L Posting No. 1": Code[20])
    begin
        //setPostingNo

        GlobalPostingNo := "Last G/L Posting No. 1";
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRunPostItemLedger(var Rec: Record "Audit Roll Posting")
    begin
    end;
}

