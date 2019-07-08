codeunit 6014478 "POS End Sale Post Processing"
{
    // POS End Sale Post Processing
    //  Work started by Nicolai Esbensen.
    //  Contibutions adding non crucial post processing to the end of
    //  a sale in the POS shoud be put here.
    // 
    // --------------------------------------------------------
    // 
    // PN1.04/MH/20140819  NAV-AddOn: PDF2NAV
    //   - Refactored module from the "Mail And Document Handler" Module.
    // 
    // NPR4.10/VB/20150602 CASE 213003 Support for Web Client (JavaScript) client
    // NPR4.10/JDH/20150520  CASE 210564 changed error message to include sales ticket no.
    // NPR4.11/VB/20150629   CASE 213003 Fixed a text caption with incorrect spacing.
    // NPR4.13/VB/20150723   CASE 213003 Replaced a message dialog with Marshaller.Message to have consistent UI.
    // NPR4.16/MMV/20151028  CASE 225533 Added handling of "Custom Print Object Type" & "Custom Print Object ID"
    // PN1.08/MHA/20151214   CASE 228859 Pdf2Nav (New Version List)
    // TM1.02/TSA/20160105  CASE 230873 NaviPartner Ticket Management
    // NPR4.18/MMV/20160128  CASE 224257 New tax free integration
    // MM1.09/TSA/20160229 CASE 235812 Member Receipt Printing
    // NPR4.21/JHL/20160316 CASE 222417 Added CleanCash
    // NPR4.21.01/JDH/20160330 CASE 237905 Fixed problem with lacking license permissions to new object range 618xxxx
    // PN1.10/MHA/20160314 CASE 236653 Updated Record Specific Pdf2Nav functions with general Variant functions
    // NPR5.22/MMV/20160421 CASE 237314 Added support for Report Printer Interface
    // NPR5.26/MMV /20160830 CASE 241549 Added print of gift/credit vouchers here instead of in PrintReceipt() in CU 6014428.
    //                                   Removed "Custom Print Object" solution. To be refactored as part of transcendence to a simpler flow.
    //                                   Removed several old comments.
    // NPR5.26/TSA/20160901 CASE 249245 Added a commit before audit roll posing starts
    // NPR5.26/JHL/20160916 CASE 244106 Change communication with CleanCash object to event CleanCashWrapperPublish
    // NPR5.28/MMV /20161107 CASE 254575 Cleaned up.
    //                                   Added e-mail support.
    //                                   Added events.
    // NPR5.30/MMV /20170207 CASE 261964 Refactored tax free module.
    //                                   Removed unused variables.
    // NPR5.38/BR  /20180109 CASE 301600 Do not Post Audit Roll if Advanced Posting is activated
    // NPR5.39/MHA /20180202 CASE 302779 Removed direct Print Calls in OnRun() as they are replaced by OnFinishSale POS Workflow in POS Sale and deleted all unused functions
    // NPR5.42/MMV /20180524 CASE 315838 Skip audit roll checks when using POS Entry.
    //                                   ISEMPTY instead of COUNT
    //                                   Removed deprecated retail order functionality
    // NPR5.46/MMV /20180918 CASE 328879 Removed standard POS marshaller use.

    TableNo = "Sale POS";

    trigger OnRun()
    var
        AuditRoll: Record "Audit Roll";
        NPRetailSetup: Record "NP Retail Setup";
        PaymentTypePOS: Record "Payment Type POS";
        Postsale: Codeunit "Post sale";
        Register: Record Register;
        RetailSetup: Record "Retail Setup";
        ImmediatePostItemEntries: Boolean;
        PostParam: Boolean;
    begin
        //-NPR5.42 [315838]
        if not NPRetailSetup.Get then
          NPRetailSetup.Init;
        if NPRetailSetup."Advanced Posting Activated" then
          exit;
        //+NPR5.42 [315838]
        
        RetailSetup.Get ();
        Register.Get ("Register No.");
        
        //-NPR5.42 [315838]
        // AuditRoll.SETRANGE ("Register No.","Register No.");
        // AuditRoll.SETRANGE ("Sales Ticket No.","Sales Ticket No.");
        // AuditRoll.FINDSET ();
        //+NPR5.42 [315838]
        
        // {---------------------------------------------------------------------------------------------}
        // { POSTING OF AUDIT ROLL RECEIPT }
        // {---------------------------------------------------------------------------------------------}
        
        AuditRoll.Reset;
        AuditRoll.SetRange( "Register No.", "Register No." );
        AuditRoll.SetRange( "Sales Ticket No.", "Sales Ticket No." );
        
        /* Payment Post Processing */
        if AuditRoll.FindSet then repeat
          if (AuditRoll."Sale Type" = AuditRoll."Sale Type"::Payment) and
             (AuditRoll.Type = AuditRoll.Type::Payment) then
             if (PaymentTypePOS.Get(AuditRoll."No.")) and
                (PaymentTypePOS."Post Processing Codeunit" > 0)
               then
                 if CODEUNIT.Run(PaymentTypePOS."Post Processing Codeunit", AuditRoll) then;
        until AuditRoll.Next = 0;
        
        PostParam := PostParam or AuditRoll.ImmediatePost( AuditRoll );
        
        /* General */
        AuditRoll.Reset;
        AuditRoll.SetCurrentKey( "Register No.","Sales Ticket No.","Sale Type",Type );
        AuditRoll.SetRange( "Register No.", "Register No." );
        AuditRoll.SetRange( "Sales Ticket No.", "Sales Ticket No." );
        AuditRoll.SetRange( "Sale Date", Today );
        
        /* Customer payments */
        AuditRoll.SetRange( "Sale Type", AuditRoll."Sale Type"::Deposit );
        AuditRoll.SetRange( Type, AuditRoll.Type::Customer );
        //-NPR5.42 [315838]
        //IF AuditRoll.COUNT > 0 THEN
        if (not AuditRoll.IsEmpty) then
        //+NPR5.42 [315838]
          PostParam := PostParam or RetailSetup."Post Customer Payment imme.";
        
        /* Normal item sale */
        AuditRoll.SetRange( "Sale Type", AuditRoll."Sale Type"::Sale );
        AuditRoll.SetRange( Type, AuditRoll.Type::Item );
        //-NPR5.42 [315838]
        //IF AuditRoll.COUNT > 0 THEN
        if (not AuditRoll.IsEmpty) then
        //+NPR5.42 [315838]
          PostParam := PostParam or RetailSetup."Poste Sales Ticket Immediately";
        
        /* Register Payouts */
        AuditRoll.SetRange( Type );
        AuditRoll.SetRange( "Sale Type", AuditRoll."Sale Type"::"Out payment" );
        AuditRoll.SetFilter("No.", '<>%1', Register.Rounding);
        //-NPR5.42 [315838]
        //IF AuditRoll.COUNT > 0 THEN
        if (not AuditRoll.IsEmpty) then
        //+NPR5.42 [315838]
          PostParam := PostParam or RetailSetup."Post Payouts imme.";
        
        /* Payments with optional immediate posting */
        AuditRoll.SetRange( Type );
        AuditRoll.SetRange( "Sale Type", AuditRoll."Sale Type"::Payment );
        AuditRoll.SetRange("No.");
        if AuditRoll.FindSet then repeat
         if PaymentTypePOS.Get(AuditRoll."No.") then begin
           case PaymentTypePOS."Immediate Posting" of
             PaymentTypePOS."Immediate Posting"::Never:;
             PaymentTypePOS."Immediate Posting"::Always:
               PostParam := true;
             PaymentTypePOS."Immediate Posting"::Negative:
               PostParam := AuditRoll."Amount Including VAT" < 0;
             PaymentTypePOS."Immediate Posting"::Positive:
               PostParam := AuditRoll."Amount Including VAT" > 0;
           end;
         end;
        until (AuditRoll.Next = 0) or PostParam;
        
        
        AuditRoll.SetRange("Sale Type");
        AuditRoll.SetRange(Type);
        AuditRoll.SetRange("No.");
        
        ImmediatePostItemEntries := (RetailSetup."Immediate postings" <> RetailSetup."Immediate postings"::" ");
        
        //-NPR5.42 [315838]
        if PostParam or ImmediatePostItemEntries then begin
          Postsale.SetParam( Rec,ImmediatePostItemEntries,PostParam );
          if not Postsale.Run(AuditRoll) then;
        end;
        
        Commit;
        
        // IF NOT NPRetailSetup.GET THEN
        //  NPRetailSetup.INIT;
        // IF NOT NPRetailSetup."Advanced Posting Activated" THEN BEGIN
        //  IF PostParam OR ImmediatePostItemEntries THEN BEGIN
        //    Postsale.SetParam( Rec,ImmediatePostItemEntries,PostParam );
        //    IF NOT Postsale.RUN(AuditRoll) THEN;
        //   END;
        // END;
        //
        // COMMIT;
        //
        // IF RetailSetup."Create retail order" = RetailSetup."Create retail order"::"After payment" THEN BEGIN
        //  IF ("Retail Document Type" = "Retail Document Type"::"Retail Order") AND
        //     ("Retail Document No." <> '') THEN BEGIN
        //
        //  END ELSE BEGIN
        //    IF Register.Touchscreen THEN
        //      bCreateRetailOrder := Marshaller.Confirm(t003,t002)
        //    ELSE
        //      bCreateRetailOrder := CONFIRM( t002, FALSE );
        //
        //    IF bCreateRetailOrder THEN
        //      RetailFormCode.ReceiptToRetailOrder(Rec, 0, Register.Touchscreen,"Retail Document Type"::"Retail Order");
        //  END;
        // END;
        //+NPR5.42 [315838]

    end;
}

