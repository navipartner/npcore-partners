codeunit 6014442 "NPR Event Subscriber (Cust)"
{
    // NPR5.23/JDH /20160516 CASE 241673 Created for customer events
    // NPR5.22.01/TJ/20160517 CASE 241673 Rearranged code and added events
    // NPR5.23/LS  /20160608 CASE 226819 Exit OnBeforeInsertEvent - Replaced by new Phone Lookup Functionality
    // NPR5.25/TS/20160622 CASE 244813 Added Action Item Ledger Entries
    // NPR5.26/JDH/20160923 CASE 253243 Removed function that was just doing nothing (OnbeforeInsert subscriber)
    // NPR5.29/TJ /20170113 CASE 262797 Added new subscribers to page 21 Customer Card
    // NPR5.31/TJ  /20170425 CASE 271060 Exiting if Payment Terms Code is empty in function OnAfterValidateEventPaymentTermsCode
    // NPR5.33/BHR /20170526 CASE 277663 Add subscriber to page 21(Action Auditroll) "Customer card"
    // NPR5.40/BHR /20180306 CASE 307028 Allow rename of customers for POS transactions
    // NPR5.41/JDH /20180426 CASE 312644  Added indirect permissions to table Audit roll

    Permissions = TableData "Audit Roll"=rimd;

    trigger OnRun()
    begin
    end;

    var
        SalesSetup: Record "Sales & Receivables Setup";
        SalesSetupFetched: Boolean;
        RetailSetup: Record "Retail Setup";
        RetailSetupFetched: Boolean;

    [EventSubscriber(ObjectType::Table, 18, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertEvent(var Rec: Record Customer;RunTrigger: Boolean)
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Text001: Label 'Number must not be blank!';
    begin
        //-NPR5.22.01
        /*
        IF RunTrigger THEN
        //-NPR70.00.00.00
          StdTableCode.DebitorOnInsert(Rec);
        //+NPR70.00.00.00
        */
        if not RunTrigger then
          exit;
        
        with Rec do begin
          if Type <> Type::Cash then begin
            if "No." = '' then begin
              GetSalesSetup;
              SalesSetup.TestField("Customer Nos.");
        //-NPR5.22
        //      NrSerieStyring.InitSeries(SalgOpsæt."Customer Nos.",xIDeb."No. Series",0D,"No.","No. Series");
              NoSeriesMgt.InitSeries(SalesSetup."Customer Nos.",'',0D,"No.","No. Series");
        //+NPR5.22
              "Invoice Disc. Code" := "No.";
            end;
          end else
            if "No." = '' then
              Error(Text001);
          "Primary Key Length" := StrLen("No.");
          Modify;
        end;
        //+NPR5.22.01

    end;

    [EventSubscriber(ObjectType::Table, 18, 'OnBeforeDeleteEvent', '', true, false)]
    local procedure OnBeforeDeleteEvent(var Rec: Record Customer;RunTrigger: Boolean)
    var
        SalesPOS: Record "Sale POS";
        SalesLinePOS: Record "Sale Line POS";
        AuditRoll: Record "Audit Roll";
        Text001: Label 'You can''t delete customer %1 as there are one or more non posted entries.';
        Text002: Label 'You can''t delete customer %1 as it is used on an active sales document.';
        Text003: Label 'You can''t delete customer %1 as it is used on active cash payment.';
    begin
        //-NPR5.22.01
        /*
        IF RunTrigger THEN
        //-NPR70.00.00.00
          StdTableCode.DebitorOnDelete1(Rec);
        //+NPR70.00.00.00
        */
        if not RunTrigger then
          exit;
        
        with Rec do begin
          if "No." = '' then
            exit;
        
          AuditRoll.SetCurrentKey("Sale Type",Type,"No.",Posted);
          AuditRoll.SetRange("Sale Type",AuditRoll."Sale Type"::Deposit );
          AuditRoll.SetRange(Type,AuditRoll.Type::Customer );
        
        //-NPR5.22
        //  Revisionsrulle.SETRANGE("No.",xDDeb."No.");
          AuditRoll.SetRange("No.","No.");
        //+NPR5.22
        
          AuditRoll.SetRange(Posted,false);
          if AuditRoll.FindFirst then
            Error(Text001,"No.");
        
          SalesPOS.SetRange("Customer No.","No.");
          if SalesPOS.FindFirst then
            Error(Text002,"No.");
        
          SalesLinePOS.SetRange("Sale Type",SalesLinePOS."Sale Type"::Deposit);
          SalesLinePOS.SetRange(Type,SalesLinePOS.Type::Customer);
          SalesLinePOS.SetRange("No.","No.");
          if SalesLinePOS.FindFirst then
            Error(Text003,"No.");
        end;
        //+NPR5.22.01

    end;

    [EventSubscriber(ObjectType::Table, 18, 'OnBeforeRenameEvent', '', false, false)]
    local procedure OnBeforeRenameEvent(var Rec: Record Customer;var xRec: Record Customer;RunTrigger: Boolean)
    var
        SalesPOS: Record "Sale POS";
        SalesLinePOS: Record "Sale Line POS";
        Text001: Label 'You can''t rename customer %1 as it is used on an active sales document.';
        Text002: Label 'You can''t rename customer %1 as it is used on active cash payment.';
    begin


         //-NPR5.22.01
         if not RunTrigger then
          exit;

        //-NPR5.40 [307028]
        // SalesPOS.SETRANGE("Customer No.",xRec."No.");
        // IF SalesPOS.FINDFIRST THEN
        //  ERROR(Text001,xRec."No.");
        //
        // SalesLinePOS.SETRANGE("Sale Type",SalesLinePOS."Sale Type"::Deposit);
        // SalesLinePOS.SETRANGE(Type,SalesLinePOS.Type::Customer);
        // SalesLinePOS.SETRANGE("No.",xRec."No.");
        // IF SalesLinePOS.FINDFIRST THEN
        //  ERROR(Text002,xRec."No.");
        //+NPR5.40 [307028]
         //+NPR5.22.01
    end;

    [EventSubscriber(ObjectType::Table, 18, 'OnAfterRenameEvent', '', true, false)]
    local procedure OnAfterRenameEvent(var Rec: Record Customer;var xRec: Record Customer;RunTrigger: Boolean)
    var
        AuditRoll: Record "Audit Roll";
        SalesPOS: Record "Sale POS";
        SalesLinePOS: Record "Sale Line POS";
    begin
        //-NPR5.22.01
        //took part of the code from StdTableCode.DebitorOnRename(Rec,xRec) and split it into OnBefore and OnAfter
        /*
        IF RunTrigger THEN
        //-NPR70.00.00.00
          StdTableCode.DebitorOnRename(Rec,xRec);
        //+NPR70.00.00.00
        */
        if not RunTrigger then
          exit;
        
        AuditRoll.SetCurrentKey("Sale Type",Type,"No.",Posted);
        AuditRoll.SetRange("Sale Type",AuditRoll."Sale Type"::Deposit );
        AuditRoll.SetRange(Type,AuditRoll.Type::Customer);
        AuditRoll.SetRange("No.",xRec."No.");
        AuditRoll.SetRange(Posted,false);
        if AuditRoll.FindFirst then
          AuditRoll.ModifyAll("No.",Rec."No.");
        //+NPR5.22.01
        
        
        //-NPR5.40 [307028]
         if not RunTrigger then
          exit;
        
         SalesPOS.SetRange("Customer No.",xRec."No.");
         SalesPOS.ModifyAll("Customer No.",Rec."No.");
        
         SalesLinePOS.SetRange("Sale Type",SalesLinePOS."Sale Type"::Deposit);
         SalesLinePOS.SetRange(Type,SalesLinePOS.Type::Customer);
         SalesLinePOS.SetRange("No.",xRec."No.");
         SalesLinePOS.ModifyAll("No.",Rec."No.");
        
        //+NPR5.40 [307028]

    end;

    [EventSubscriber(ObjectType::Table, 18, 'OnAfterValidateEvent', 'Payment Terms Code', true, false)]
    local procedure OnAfterValidateEventPaymentTermsCode(var Rec: Record Customer;var xRec: Record Customer;CurrFieldNo: Integer)
    var
        PaymentTerms: Record "Payment Terms";
        Text001: Label 'Specify %1 for %2!';
        Text002: Label 'Want to convert customer %1 from type cash to type customer?';
    begin
        //-NPR5.22.01
        /*
        //-NPR70.00.00.00
        StdTableCode.DebitorBetaling(Rec,xRec);
        //+NPR70.00.00.00
        */
        
        with Rec do begin
          //-NPR5.31 [271060]
          if "Payment Terms Code" = '' then
            exit;
          //+NPR5.31 [271060]
          PaymentTerms.Get("Payment Terms Code");
          if Format(PaymentTerms."Due Date Calculation") = '' then
            Error(Text001,PaymentTerms.FieldCaption("Due Date Calculation"),PaymentTerms.Code); //FIELDNAME changed to FIELDCAPTION and needs to be translated to english
          if Format(PaymentTerms."Due Date Calculation") = Format(0D) then
            Type := Type::Cash
          else
            Type := Type::Customer;
        
          if (xRec.Type = xRec.Type::Cash) and (xRec.Type <> Type) then begin
            if not Confirm(Text002,false) then begin
              "Payment Terms Code" := xRec."Payment Terms Code";
              Type := Type::Cash;
            end else
              Type := Type::Customer;
          end;
        end;
        //+NPR5.22.01

    end;

    local procedure GetSalesSetup(): Boolean
    begin
        if SalesSetupFetched then
          exit(true);

        if not SalesSetup.Get then
          exit(false);
        SalesSetupFetched := true;
        exit(true);
    end;

    local procedure GetRetailSetup(): Boolean
    begin
        if RetailSetupFetched then
          exit(true);

        if not RetailSetup.Get then
          exit(false);
        RetailSetupFetched := true;
        exit(true);
    end;

    [EventSubscriber(ObjectType::Page, 22, 'OnAfterActionEvent', 'ItemLedgerEntries', false, false)]
    local procedure Page22CustomerListActionEventItemLedgerEntries(var Rec: Record Customer)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        //-NPR5.25
        ItemLedgerEntry.SetRange("Source No.",Rec."No.");
        PAGE.RunModal(PAGE::"Item Ledger Entries",ItemLedgerEntry);
        //+NPR5.25
    end;

    [EventSubscriber(ObjectType::Page, 22, 'OnAfterActionEvent', 'AuditRoll', false, false)]
    local procedure Page22OnAfterActionEventAuditRoll(var Rec: Record Customer)
    var
        AuditRoll: Record "Audit Roll";
    begin
        //-NPR5.33 [277663]
        AuditRoll.SetCurrentKey("Customer No.");
        AuditRoll.SetRange("Customer No.",Rec."No.");
        PAGE.RunModal(PAGE::"Audit Roll",AuditRoll);
        //+NPR5.33 [277663]
    end;

    [EventSubscriber(ObjectType::Page, 21, 'OnAfterActionEvent', 'ItemLedgerEntries', false, false)]
    local procedure Page21OnAfterActionEventItemLedgerEntries(var Rec: Record Customer)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        //-NPR5.29 [262797]
        ItemLedgerEntry.SetRange("Source No.",Rec."No.");
        PAGE.RunModal(PAGE::"Item Ledger Entries",ItemLedgerEntry);
        //+NPR5.29 [262797]
    end;

    [EventSubscriber(ObjectType::Page, 21, 'OnAfterActionEvent', 'AlternativeNo', false, false)]
    local procedure Page21OnAfterActionEventAlternativNo(var Rec: Record Customer)
    var
        AlternativeNo: Record "Alternative No.";
    begin
        //-NPR5.29 [262797]
        AlternativeNo.SetRange(Type,AlternativeNo.Type::Customer);
        AlternativeNo.SetRange(AlternativeNo.Code,Rec."No.");
        PAGE.RunModal(PAGE::"Alternative Number",AlternativeNo);
        //+NPR5.29 [262797]
    end;

    [EventSubscriber(ObjectType::Page, 21, 'OnAfterActionEvent', 'PrintShippingLabel', false, false)]
    local procedure Page21OnAfterActionEventPrintShippingLabel(var Rec: Record Customer)
    var
        LabelLibrary: Codeunit "Label Library";
        RecRef: RecordRef;
        Customer: Record Customer;
    begin
        //-NPR5.29 [262797]
        Customer := Rec;
        Customer.SetRecFilter;
        RecRef.GetTable(Customer);
        LabelLibrary.PrintCustomShippingLabel(RecRef,'');
        //+NPR5.29 [262797]
    end;

    [EventSubscriber(ObjectType::Page, 21, 'OnAfterActionEvent', 'AuditRoll', false, false)]
    local procedure Page21OnAfterActionEventAuditRoll(var Rec: Record Customer)
    var
        AuditRoll: Record "Audit Roll";
    begin
        //-NPR5.33 [277663]
        AuditRoll.SetCurrentKey("Customer No.");
        AuditRoll.SetRange("Customer No.",Rec."No.");
        PAGE.RunModal(PAGE::"Audit Roll",AuditRoll);
        //+NPR5.33 [277663]
    end;
}

