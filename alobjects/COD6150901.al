codeunit 6150901 "HC Post audit roll"
{
    // NPR5.37/BR  /20171027 CASE 267552 HQ Connector Created Object based on Codeunit 6014409
    // NPR5.38/BR  /20171128 CASE 297946 Added support for HQ Processing
    // NPR5.38/JDH /20180116 CASE 302570 Renamed Danish Characters to English
    // NPR5.38/BR  /20171128 CASE 297946 Skip posted lines and transfer Sales Ticket no.
    // NPR5.44/MHA /20180704 CASE 318391 Added Location Code to ProcessToSalesDocument()
    // NPR5.47/JDH /20181015 CASE 325323 Changed Tryfunction to a codeunit.RUN instead, due to 2017 compatability issue - deleted function PostSalesDoc
    // NPR5.48/MHA /20181121 CASE 326055 Added "Reference" to ProcessToSalesDocument()

    TableNo = "HC Audit Roll";

    trigger OnRun()
    var
        t001: Label 'Posting of audit roll is not possible in offline mode';
    begin
        RunCode( Rec );
    end;

    var
        Revisionsrulle: Record "HC Audit Roll";
        tRevisionsrulle: Record "HC Audit Roll Posting" temporary;
        HCRetailSetup: Record "HC Retail Setup";
        HCPostTempAuditRoll: Codeunit "HC Post Temp Audit Roll";
        Fejl: Label 'There is nothing to post!';
        Tekst: Label 'Posting done! \posted documents are on %1 of %2 installed cash registers';
        ProgressVis: Boolean;
        pRevisionsrulle: Record "HC Audit Roll Posting";
        SkipPostGL: Boolean;
        SkipPostItem: Boolean;

    procedure ShowProgress(Set: Boolean)
    begin
        //ShowProgress
        ProgressVis := Set;
    end;

    procedure PostPerRegisterTmp(Kasse: Record "HC Register"): Boolean
    var
        TempPost: Record "HC Audit Roll Posting" temporary;
    begin
        if tRevisionsrulle.Count > 0 then begin
          //ohm-
          //IF Kasse."Last G/L Posting No." = '' THEN
          //  Kasse."Last G/L Posting No." := '0';
          //Kasse."Last G/L Posting No." := INCSTR(Kasse."Last G/L Posting No.");
          //Kasse.MODIFY;
          HCPostTempAuditRoll.setPostingNo(HCPostTempAuditRoll.getNewPostingNo(true));
          //ohm+

          tRevisionsrulle.ModifyAll("Internal Posting No.",0);

          if tRevisionsrulle.Find('-') then repeat
            HCPostTempAuditRoll.ClearStatusWindow();
            tRevisionsrulle.SetRange("Sale Date", tRevisionsrulle."Sale Date");
            TempPost.Reset;
            TempPost.TransferFromTemp( TempPost, tRevisionsrulle );
            HCPostTempAuditRoll.RunPost( TempPost );
            tRevisionsrulle.Find('+');
            tRevisionsrulle.SetRange( "Sale Date" );
            TempPost.Reset;
            HCPostTempAuditRoll.RunUpdateChanges( TempPost );
            TempPost.DeleteAll;
          until tRevisionsrulle.Next = 0;
          exit(true);
        end else
          exit(false);
    end;

    procedure PostPerRegisterTmpItemLedger(Kasse: Record "HC Register"): Boolean
    var
        TempPost: Record "HC Audit Roll Posting" temporary;
    begin
        if tRevisionsrulle.Count > 0 then begin
          //ohm-
          //IF Kasse."Last G/L Posting No." = '' THEN
          //  Kasse."Last G/L Posting No." := '0';
          //Kasse."Last G/L Posting No." := INCSTR(Kasse."Last G/L Posting No.");
          //Kasse.MODIFY;
          //HCPostTempAuditRoll.setPostingNo(HCPostTempAuditRoll.getNewPostingNo(TRUE));
          //ohm+

          tRevisionsrulle.ModifyAll("Internal Posting No.",0);

          if tRevisionsrulle.Find('-') then repeat
            HCPostTempAuditRoll.ClearStatusWindow();
            tRevisionsrulle.SetRange("Sale Date", tRevisionsrulle."Sale Date");
            TempPost.Reset;
            TempPost.TransferFromTemp( TempPost, tRevisionsrulle );
            HCPostTempAuditRoll.RunPostItemLedger( TempPost );
            tRevisionsrulle.Find('+');
            tRevisionsrulle.SetRange( "Sale Date" );
            TempPost.Reset;
            HCPostTempAuditRoll.RunUpdateChanges( TempPost );
            TempPost.DeleteAll;

          until tRevisionsrulle.Next = 0;
          exit(true);
        end else
          exit(false);
    end;

    procedure RunCode(var Rec: Record "HC Audit Roll")
    var
        Kasse: Record "HC Register";
        t001: Label 'Posting of audit roll is not possible in offline mode';
        Dummy: Record "HC Audit Roll" temporary;
    begin
        //RunKode()
        //-NPR5.38 [297946]
        HCRetailSetup.Get();
        ProcessToSalesDocuments(Rec);
        //+NPR5.38 [297946]
        
        //-NPR5.29 [262116]
        //dummy.COPYFILTERS(Rec);
        Dummy.Copy(Rec);
        //+NPR5.29 [262116]
        
        //-NPR5.38 [297946]
        //Ops�tning.GET();
        //+NPR5.38 [297946]
        Clear(tRevisionsrulle);
        
        //IF Ops�tning."Company - Function" = Ops�tning."Company - Function"::Offline THEN
        //  ERROR(t001);
        
        HCRetailSetup.Validate("Posting Source Code",HCRetailSetup."Posting Source Code");
        
        Kasse.SetFilter( "Register No.", Rec.GetFilter( "Register No." ));
        
        if ProgressVis then begin
          HCPostTempAuditRoll.OpenStatusWindow();
        end;
        
        /* G/L ENTRY POSTING */
        //-NPR5.23
        if not SkipPostGL then begin
        //+NPR5.23
          if not HCRetailSetup."Post registers compressed" then begin
            if Kasse.Find('-') then repeat
              HCPostTempAuditRoll.SetProgressVis( ProgressVis );
        
              Rec.SetRange( "Register No.", Kasse."Register No." );
        
              HCPostTempAuditRoll.RunTransfer( tRevisionsrulle, Rec );
              HCPostTempAuditRoll.RemoveSuspendedPayouts( tRevisionsrulle );
        
              tRevisionsrulle.Reset;
        
              HCPostTempAuditRoll.RunTest( tRevisionsrulle );
        
              PostPerRegisterTmp( Kasse );
              tRevisionsrulle.DeleteAll;
            until Kasse.Next = 0;
          end else begin
            HCPostTempAuditRoll.SetProgressVis( ProgressVis );
        
            HCPostTempAuditRoll.RunTransfer( tRevisionsrulle, Rec );
            HCPostTempAuditRoll.RemoveSuspendedPayouts( tRevisionsrulle );
        
            tRevisionsrulle.Reset;
        
            HCPostTempAuditRoll.RunTest( tRevisionsrulle );
        
            PostPerRegisterTmp( Kasse );
            tRevisionsrulle.DeleteAll;
        
          end;
        
        //-NPR5.23
        end;
        //+NPR5.23
        
        
        /* ITEM ENTRY POSTING */
        Clear(tRevisionsrulle);
        tRevisionsrulle.DeleteAll;
        Rec.CopyFilters(Dummy);
        Kasse.Reset;
        Kasse.SetFilter( "Register No.", Rec.GetFilter( "Register No." ));
        pRevisionsrulle.DeleteAll;
        
        //-NPR5.23
        if not SkipPostItem then begin
        //+NPR5.23
          //-NPR5.29 [262116]
          Rec.SetRange(Posted);
          Rec.SetRange("Item Entry Posted",false);
          Rec.SetRange("Sale Type",Rec."Sale Type"::Sale);
          Rec.SetRange(Type,Rec.Type::Item);
          //+NPR5.29 [262116]
        
          if not HCRetailSetup."Post registers compressed" then begin
            if Kasse.Find('-') then repeat
              HCPostTempAuditRoll.SetProgressVis( ProgressVis );
              Rec.SetRange( "Register No.", Kasse."Register No." );
              HCPostTempAuditRoll.RunTransferItemLedger( tRevisionsrulle, Rec );
              HCPostTempAuditRoll.RunTest( tRevisionsrulle );
              tRevisionsrulle.Reset;
              PostPerRegisterTmpItemLedger( Kasse );
              tRevisionsrulle.DeleteAll;
            until Kasse.Next = 0;
          end else begin
            HCPostTempAuditRoll.SetProgressVis( ProgressVis );
            HCPostTempAuditRoll.RunTransferItemLedger( tRevisionsrulle, Rec );
            HCPostTempAuditRoll.RunTest( tRevisionsrulle );
            tRevisionsrulle.Reset;
            PostPerRegisterTmpItemLedger( Kasse );
            tRevisionsrulle.DeleteAll;
          end;
        //-NPR5.23
        end;
        //+NPR5.23
        
        //-NPR5.29 [262116]
        //dummy.COPYFILTERS(Rec);
        Rec.Copy(Dummy);
        //+NPR5.29 [262116]
        
        if ProgressVis then
          HCPostTempAuditRoll.CloseStatusWindow('');

    end;

    procedure SetPostingParameters(SkipPostGLEntry: Boolean;SkipPostItemLedgerEntry: Boolean)
    begin
        //-NPR5.23
        SkipPostGL := SkipPostGLEntry;
        SkipPostItem := SkipPostItemLedgerEntry;
        //+NPR5.23
    end;

    local procedure ProcessToSalesDocuments(var HCAuditRoll: Record "HC Audit Roll")
    var
        HCAuditRollToSalesDocument: Record "HC Audit Roll";
        HCPaymentTypePOS: Record "HC Payment Type POS";
    begin
        //-NPR5.38 [297946]
        HCAuditRollToSalesDocument.CopyFilters(HCAuditRoll);
        HCAuditRollToSalesDocument.SetFilter("Sale Type",'=%1',HCAuditRollToSalesDocument."Sale Type"::Payment);
        HCAuditRollToSalesDocument.SetFilter("Amount Including VAT",'<>0');
        HCAuditRollToSalesDocument.SetRange(Posted,false);
        if HCAuditRollToSalesDocument.FindSet then repeat
          HCPaymentTypePOS.Get(HCAuditRollToSalesDocument."No.");
          if HCPaymentTypePOS."HQ Processing" > 0 then begin
            ProcessToSalesDocument(HCAuditRollToSalesDocument,HCPaymentTypePOS);
            MarkAllLinesAsPosted(HCAuditRollToSalesDocument);
          end;
        until HCAuditRollToSalesDocument.Next = 0;
        //+NPR5.38 [297946]
    end;

    local procedure ProcessToSalesDocument(var HCAuditRoll: Record "HC Audit Roll";HCPaymentTypePOS: Record "HC Payment Type POS")
    var
        HCAuditRollToSalesDocument: Record "HC Audit Roll";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        HCPostTempAuditRoll: Codeunit "HC Post Temp Audit Roll";
        LineNo: Integer;
        SuccessPosting: Boolean;
        HCAuditRollPosting: Record "HC Audit Roll Posting";
        AccountType: Integer;
        AccountNo: Code[20];
        PostPayment: Boolean;
        PaymentMethod: Record "Payment Method";
        HCPostSalesHeader: Codeunit "HC Post Sales Header";
    begin
        //-NPR5.38 [297946]
        HCAuditRoll.TestField("Customer No.");
        SalesHeader.Init;
        case HCPaymentTypePOS."HQ Processing" of
          HCPaymentTypePOS."HQ Processing"::SalesInvoice:
            if HCAuditRoll."Amount Including VAT" >  0 then
              SalesHeader.Validate("Document Type",SalesHeader."Document Type"::Invoice)
            else
              SalesHeader.Validate("Document Type",SalesHeader."Document Type"::"Credit Memo");
          HCPaymentTypePOS."HQ Processing"::SalesQuote:
            SalesHeader.Validate("Document Type",SalesHeader."Document Type"::Quote);
          HCPaymentTypePOS."HQ Processing"::SalesOrder:
            if HCAuditRoll."Amount Including VAT" >  0 then
              SalesHeader.Validate("Document Type",SalesHeader."Document Type"::Order)
            else
              SalesHeader.Validate("Document Type",SalesHeader."Document Type"::"Return Order");
        end;
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.",HCAuditRoll."Customer No.");
        SalesHeader.Validate("Document Date",HCAuditRoll."Sale Date");
        SalesHeader.Validate("External Document No.",HCAuditRoll."Sales Ticket No.");
        //-NPR5.48 [326055]
        //SalesHeader.VALIDATE("Your Reference",HCAuditRoll."Sales Ticket No.");
        SalesHeader.Validate("Your Reference",HCAuditRoll.Reference);
        //+NPR5.48 [326055]
        //-NPR5.44 [318391]
        SalesHeader.Validate("Location Code",HCAuditRoll.Lokationskode);
        //+NPR5.44 [318391]
        if HCPaymentTypePOS."Payment Method Code" <> '' then
          SalesHeader.Validate("Payment Method Code",HCPaymentTypePOS."Payment Method Code");
        SalesHeader.Modify(true);

        LineNo := 0;
        HCAuditRollToSalesDocument.SetRange("Sales Ticket No.",HCAuditRoll."Sales Ticket No.");
        HCAuditRollToSalesDocument.SetRange("Register No.",HCAuditRoll."Register No.");
        if HCAuditRollToSalesDocument.FindSet then repeat
          //CreateLine
          if HCAuditRollToSalesDocument."Sale Type" = HCAuditRollToSalesDocument."Sale Type"::Sale then begin
            if HCAuditRollToSalesDocument.Type in [HCAuditRollToSalesDocument.Type::Item,HCAuditRollToSalesDocument.Type::"G/L"] then begin
              LineNo := LineNo + 10000;
              SalesLine.Init;
              SalesLine.Validate("Document Type",SalesHeader."Document Type");
              SalesLine.Validate("Document No.",SalesHeader."No.");
              SalesLine."Line No." := LineNo;
              SalesLine.Insert(true);
              case HCAuditRollToSalesDocument.Type of
                HCAuditRollToSalesDocument.Type::Item :
                   SalesLine.Validate(Type,SalesLine.Type::Item);
                HCAuditRollToSalesDocument.Type::"G/L" :
                   SalesLine.Validate(Type,SalesLine.Type::"G/L Account");
              end;
              SalesLine.Validate("No.",HCAuditRollToSalesDocument."No.");
              //-NPR5.44 [318391]
              SalesLine.Validate("Location Code",HCAuditRollToSalesDocument.Lokationskode);
              //+NPR5.44 [318391]
              if HCAuditRollToSalesDocument.Unit <> '' then
                SalesLine.Validate("Unit of Measure Code",HCAuditRollToSalesDocument.Unit);
              SalesLine.Validate(Quantity,HCAuditRollToSalesDocument.Quantity);
              SalesLine.Validate(Amount,HCAuditRoll.Amount);
              SalesLine.Modify(true);
            end;
          end;
        until HCAuditRollToSalesDocument.Next = 0;

        OnAfterCreateSalesDoc(SalesHeader);

        if HCPaymentTypePOS."HQ Post Sales Document" then begin
          Commit;
          //-NPR5.47 [325323]
          // SuccessPosting :=  PostSalesDoc(SalesHeader);
          SuccessPosting := HCPostSalesHeader.Run(SalesHeader);
          //+NPR5.47 [325323]
          OnAfterTryPostingSalesDoc(SalesHeader,SuccessPosting);
        end;

        PostPayment := HCPaymentTypePOS."HQ Post Payment";
        if (SalesHeader."Payment Method Code" <> '') and PostPayment then
          if PaymentMethod.Get(SalesHeader."Payment Method Code") then
            if PaymentMethod."Bal. Account No." <> '' then
              PostPayment := false;

        if PostPayment then begin
          HCAuditRoll.SetRecFilter;
          HCPostTempAuditRoll.RunTransfer(HCAuditRollPosting,HCAuditRoll);
          HCPostTempAuditRoll.PostTransaction(
                HCAuditRoll."Customer No.",
                HCAuditRoll."Amount Including VAT",
                HCAuditRoll."Register No.",
                1, //debitor
                HCAuditRoll."Department Code",
                HCAuditRoll.Description,
                HCAuditRoll."Sale Date",
                HCAuditRollPosting );
          if HCPaymentTypePOS."HQ Post Sales Document" and SuccessPosting then
            HCPostTempAuditRoll.ApplyToSalesDoc(SalesHeader);

          //Balancing entry
          case HCPaymentTypePOS."Account Type" of
            HCPaymentTypePOS."Account Type"::Bank :
              begin
                AccountType := 3; // Finans,Debitor,Kreditor,Bank,Anl�g
                AccountNo := HCPaymentTypePOS."G/L Account No.";
              end;
            HCPaymentTypePOS."Account Type"::"G/L Account" :
              begin
                AccountType := 0; // Finans,Debitor,Kreditor,Bank,Anl�g
                AccountNo := HCPaymentTypePOS."Bank Acc. No.";
              end;
          end;
          HCPostTempAuditRoll.PostTransaction(
           AccountNo,
            HCAuditRoll."Amount Including VAT",
            HCAuditRoll."Register No.",
            AccountType,
            HCAuditRoll."Department Code",
            HCAuditRoll.Description,
            HCAuditRoll."Sale Date",
            HCAuditRollPosting );
          if HCRetailSetup."Gen. Journal Batch" = ''  then
            HCPostTempAuditRoll.PostTodaysGLEntries(HCAuditRollPosting);
        end;
        //+NPR5.38 [297946]
    end;

    local procedure MarkAllLinesAsPosted(var HCAuditRoll: Record "HC Audit Roll")
    var
        HCAuditRollTomarkAsProcessed: Record "HC Audit Roll";
    begin
        //-NPR5.38 [297946]
        HCAuditRollTomarkAsProcessed.SetRange("Sales Ticket No.",HCAuditRoll."Sales Ticket No.");
        HCAuditRollTomarkAsProcessed.SetRange("Register No.",HCAuditRoll."Register No.");
        if HCAuditRollTomarkAsProcessed.FindSet then repeat
          HCAuditRollTomarkAsProcessed.Posted := true;
          HCAuditRollTomarkAsProcessed.Modify;
        until HCAuditRollTomarkAsProcessed.Next = 0;
        //+NPR5.38 [297946]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateSalesDoc(var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTryPostingSalesDoc(var SalesHeader: Record "Sales Header";SuccessfulPosting: Boolean)
    begin
    end;
}

