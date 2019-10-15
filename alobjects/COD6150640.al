// TODO: CTRLUPGRADE - uses old Standard code; must be removed or refactored
codeunit 6150640 "POS Info Management"
{
    // NPR5.26/OSFI/20160810 CASE 246167 Object Created
    // NPR5.380/ANEN/20171121 CASE 296330 Added fcn. ProcessPOSInfoText
    // NPR5.38/BR  /20171222 CASE 295503 Added support for POS Entries
    // NPR5.41/THRO/20180413 CASE 308465 Added OnBeforeValidateCustomerNoSalePos for POSInfo that request data input
    //                                   Removed the handling of Request Data from OnAfterValidateCustomerNoSalePos
    //                                   Buffering entries in temp to allow multiple pop-ups
    // NPR5.41/THRO/20180416 CASE 311499 Copy PK fields to POS Info POS Entry
    // NPR5.43/THRO/20180625 CASE 320234 Added Subscribers to OnAfterDelete on Sale POS and Sale Line POS
    // NPR5.45/THRO/20180817 CASE 324021 Customer POS Info of type Show Message wasn't triggered
    // NPR5.46/TSA /20180910 CASE 327719 When ShowMessage and "Receipt Type"::Customer, the log did not record the show message
    // NPR5.46/TSA 20180910  CASE 327626 Added description
    // NPR5.46/TSA /20180925 CASE 327626 Added Debit Sale support
    // NPR5.48/TJ  /20181122 CASE 336882 Added Input Type options when item is added to sales ticket
    // NPR5.51/ALPO/20190826 CASE 364558 Define appilcation scope for POSInfo action
    //                                   Copy inheritable POS info codes from 'Sale POS' to 'Sale line POS'
    //                                   Apply red color to sales line if a POS info code is applied to it
    //                                   Make POS info available from front-end to show on the button


    trigger OnRun()
    var
        recref: RecordRef;
    begin
        recref.Open(37);
        recref.FindFirst;

        Message(CreatePrimKeyString(recref));
    end;

    var
        ErrText001: Label 'String contains less than #1#### substrings.';
        ErrText002: Label 'String contains less than #1#### commastrings.';
        ConfText001: Label 'There is already a Pos Info entry of type %1 for this sale, do you want to overwrite?';
        ErrText003: Label 'Cancelled by User';
        ERRInfoRequired: Label 'POS Info can not be empty for POS Info Code %1.';
        ERR: Label 'Error';
        DialogInstructionsLbl: Label 'Please select the scope POS info must be applied to';
        DialogOptionsLbl: Label 'Current Line,All Lines,New Lines';

    [EventSubscriber(ObjectType::Table, 6014406, 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure OnAfterValidateSalesLineNoSaleLinePos(var Rec: Record "Sale Line POS"; var xRec: Record "Sale Line POS"; CurrFieldNo: Integer)
    var
        POSInfoLinkTable: Record "POS Info Link Table";
        POSInfo: Record "POS Info";
        // TODO: CTRLUPGRADE - declares a removed codeunit; all dependent functionality must be refactored
        //POSEventMarshaller: Codeunit "POS Event Marshaller";
        Info: Text;
        POSInfoTransaction: Record "POS Info Transaction";
        TempPOSInfoTransaction: Record "POS Info Transaction" temporary;
        POSInfoLookupPage: Page "POS Info Lookup";
        RecRef: RecordRef;
        POSInfoLookupTable: Record "POS Info Lookup";
    begin

        if Rec.Type = Rec.Type::Item then begin
            POSInfoLinkTable.Reset;
            POSInfoLinkTable.SetRange("Table ID", 27);
            POSInfoLinkTable.SetRange("Primary Key", Rec."No.");
            if POSInfoLinkTable.FindFirst then
                repeat
                    Clear(Info);
                    begin
                        POSInfo.Get(POSInfoLinkTable."POS Info Code");
                        POSInfoTransaction.SetRange("Register No.", Rec."Register No.");
                        POSInfoTransaction.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");
                        if not POSInfo."Once per Transaction" then
                            POSInfoTransaction.SetRange("Sales Line No.", Rec."Line No.")
                        else
                            POSInfoTransaction.SetRange("Sales Line No.");

                        POSInfoTransaction.SetRange("POS Info Code", POSInfoLinkTable."POS Info Code");
                        if not POSInfoTransaction.FindFirst then begin

                            if POSInfo.Type = POSInfo.Type::"Request Data" then begin
                                //-NPR5.48 [336882]
                                case POSInfo."Input Type" of
                                    POSInfo."Input Type"::Text:
                                        begin
                                            //+NPR5.48 [336882]
                                            // TODO: CTRLUPGRADE - Must be refactored without Marshaller
                                            Error('CTRLUPGRADE');
                                            /*
                                            Info := POSEventMarshaller.SearchBox(POSInfo.Message, '', 30);
                                            */

                                            if Info = '' then
                                                if POSInfo."Input Mandatory" then
                                                    Error('Error');
                                            //-NPR5.48 [336882]
                                        end;
                                    POSInfo."Input Type"::Table:
                                        begin
                                            POSInfoLookupPage.SetPOSInfo(POSInfo);
                                            POSInfoLookupPage.LookupMode(true);
                                            if POSInfoLookupPage.RunModal = ACTION::LookupOK then begin
                                                POSInfoLookupPage.GetRecord(POSInfoLookupTable);
                                                RecRef.Open(POSInfo."Table No.");
                                                RecRef.Get(POSInfoLookupTable.RecID);
                                                Info := CreatePrimKeyString(RecRef);
                                            end;
                                        end;
                                    POSInfo."Input Type"::SubCode:
                                        begin
                                            POSInfoLookupPage.SetPOSInfo(POSInfo);
                                            POSInfoLookupPage.LookupMode(true);
                                            if POSInfoLookupPage.RunModal = ACTION::LookupOK then begin
                                                POSInfoLookupPage.GetRecord(POSInfoLookupTable);
                                                Info := POSInfoLookupTable."Field 1";
                                            end;
                                        end;
                                end;
                                //+NPR5.48 [336882]
                                //-NPR5.46 [327719]
                                //   END ELSE
                                //   MESSAGE(POSInfo.Message);
                            end else begin
                                Message(POSInfo.Message);
                                Info := POSInfo.Message;
                            end;
                            //-NPR5.46 [327719]

                            //-NPR5.41 [308465]
                            TempPOSInfoTransaction.Init;
                            TempPOSInfoTransaction."Register No." := Rec."Register No.";
                            TempPOSInfoTransaction."Sales Ticket No." := Rec."Sales Ticket No.";
                            if not POSInfo."Once per Transaction" then
                                TempPOSInfoTransaction."Sales Line No." := Rec."Line No.";
                            TempPOSInfoTransaction."Sale Date" := Rec.Date;
                            TempPOSInfoTransaction."Receipt Type" := Rec.Type;
                            TempPOSInfoTransaction."Entry No." := 0;
                            TempPOSInfoTransaction."POS Info Code" := POSInfo.Code;
                            TempPOSInfoTransaction."POS Info" := Info;
                            TempPOSInfoTransaction.Insert(true);
                            //+NPR5.41 [308465]
                        end;
                    end;
                until POSInfoLinkTable.Next = 0;
            //-NPR5.41 [308465]
            if TempPOSInfoTransaction.FindSet then
                repeat
                    POSInfoTransaction := TempPOSInfoTransaction;
                    POSInfoTransaction."Entry No." := 0;
                    POSInfoTransaction.Insert(true);
                until TempPOSInfoTransaction.Next = 0;
            //+NPR5.41 [308465]
        end;
        //-NPR5.51 [364558]
        CopyPOSInfoTransFromHeader(Rec, POSInfoTransaction);
        //+NPR5.51 [364558]
    end;

    [EventSubscriber(ObjectType::Table, 6014405, 'OnBeforeValidateEvent', 'Customer No.', false, false)]
    local procedure OnBeforeValidateCustomerNoSalePos(var Rec: Record "Sale POS"; var xRec: Record "Sale POS"; CurrFieldNo: Integer)
    var
        POSInfoLinkTable: Record "POS Info Link Table";
        POSInfo: Record "POS Info";
        // TODO: CTRLUPGRADE - declares a removed codeunit; all dependent functionality must be refactored
        //POSEventMarshaller: Codeunit "POS Event Marshaller";
        Info: Text;
        POSInfoTransaction: Record "POS Info Transaction";
        TempPOSInfoTransaction: Record "POS Info Transaction" temporary;
    begin
        //-NPR5.41 [308465]
        Clear(Info);
        POSInfoLinkTable.Reset;
        POSInfoLinkTable.SetRange("Table ID", 18);
        POSInfoLinkTable.SetRange("Primary Key", Rec."Customer No.");
        if POSInfoLinkTable.FindFirst then
            repeat
                Clear(Info);
                POSInfo.Get(POSInfoLinkTable."POS Info Code");
                POSInfoTransaction.SetRange("Register No.", Rec."Register No.");
                POSInfoTransaction.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");
                POSInfoTransaction.SetRange("POS Info Code", POSInfoLinkTable."POS Info Code");
                if not POSInfoTransaction.FindFirst then begin
                    if POSInfo.Type = POSInfo.Type::"Request Data" then begin
                        // TODO: CTRLUPGRADE - Refactor without Marshaller
                        Error('CTRLUPGRADE');
                        /*
                        Info := POSEventMarshaller.SearchBox(POSInfo.Message, POSInfo.Description, MaxStrLen(POSInfoTransaction."POS Info"));
                        */

                        if Info = '' then
                            if POSInfo."Input Mandatory" then
                                Error('Error');
                        //-NPR5.45 [324021]
                        //END;
                        //+NPR5.45 [324021]
                        TempPOSInfoTransaction.Init;
                        TempPOSInfoTransaction."Register No." := Rec."Register No.";
                        TempPOSInfoTransaction."Sales Ticket No." := Rec."Sales Ticket No.";
                        TempPOSInfoTransaction."Sale Date" := Rec.Date;
                        TempPOSInfoTransaction."Receipt Type" := POSInfoTransaction."Receipt Type"::Customer;
                        TempPOSInfoTransaction."Entry No." := 0;
                        TempPOSInfoTransaction."POS Info Code" := POSInfo.Code;
                        TempPOSInfoTransaction."POS Info" := Info;
                        TempPOSInfoTransaction."No." := Rec."Customer No.";
                        TempPOSInfoTransaction.Insert;
                        //-NPR5.45 [324021]
                    end;
                    //+NPR5.45 [324021]
                end;
            until POSInfoLinkTable.Next = 0;

        if TempPOSInfoTransaction.FindSet then
            repeat
                POSInfoTransaction := TempPOSInfoTransaction;
                POSInfoTransaction."Entry No." := 0;
                POSInfoTransaction.Insert(true);
            until TempPOSInfoTransaction.Next = 0;
        //+NPR5.41 [308465]
    end;

    [EventSubscriber(ObjectType::Table, 6014405, 'OnAfterValidateEvent', 'Customer No.', false, false)]
    local procedure OnAfterValidateCustomerNoSalePos(var Rec: Record "Sale POS"; var xRec: Record "Sale POS"; CurrFieldNo: Integer)
    var
        POSInfoLinkTable: Record "POS Info Link Table";
        POSInfo: Record "POS Info";
        Info: Text;
        POSInfoTransaction: Record "POS Info Transaction";
        TempPOSInfoTransaction: Record "POS Info Transaction" temporary;
    begin
        Clear(Info);
        POSInfoLinkTable.Reset;
        POSInfoLinkTable.SetRange("Table ID", 18);
        POSInfoLinkTable.SetRange("Primary Key", Rec."Customer No.");
        if POSInfoLinkTable.FindFirst then
            repeat
                Clear(Info);
                POSInfo.Get(POSInfoLinkTable."POS Info Code");
                POSInfoTransaction.SetRange("Register No.", Rec."Register No.");
                POSInfoTransaction.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");
                POSInfoTransaction.SetRange("POS Info Code", POSInfoLinkTable."POS Info Code");
                if not POSInfoTransaction.FindFirst then begin
                    Message(POSInfo.Message);

                    //   MESSAGE(POSInfo.Message);
                    Info := POSInfo.Message;
                    //-NPR5.46 [327719]

                    TempPOSInfoTransaction.Init;
                    TempPOSInfoTransaction."Register No." := Rec."Register No.";
                    TempPOSInfoTransaction."Sales Ticket No." := Rec."Sales Ticket No.";
                    TempPOSInfoTransaction."Sale Date" := Rec.Date;
                    TempPOSInfoTransaction."Receipt Type" := TempPOSInfoTransaction."Receipt Type"::Customer;
                    TempPOSInfoTransaction."Entry No." := 0;
                    TempPOSInfoTransaction."POS Info Code" := POSInfo.Code;
                    TempPOSInfoTransaction."POS Info" := Info;
                    TempPOSInfoTransaction."No." := Rec."Customer No.";
                    TempPOSInfoTransaction.Insert(true);
                    //+NPR5.41 [308465]
                end;
            until POSInfoLinkTable.Next = 0;
        //-NPR5.41 [308465]
        if TempPOSInfoTransaction.FindSet then
            repeat
                POSInfoTransaction := TempPOSInfoTransaction;
                POSInfoTransaction."Entry No." := 0;
                POSInfoTransaction.Insert(true);
            until TempPOSInfoTransaction.Next = 0;
        //+NPR5.41 [308465]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150614, 'OnAfterInsertPOSEntry', '', true, true)]
    local procedure OnAfterInsertPOSEntry(var SalePOS: Record "Sale POS"; var POSEntry: Record "POS Entry")
    var
        POSInfoTransaction: Record "POS Info Transaction";
        POSInfoAuditRoll: Record "POS Info Audit Roll";
        POSInfoPOSEntry: Record "POS Info POS Entry";
    begin
        //-NPR5.38 [295503]
        POSInfoTransaction.SetRange("Register No.", SalePOS."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if POSInfoTransaction.FindSet then begin
            repeat
                UpdatePOSInfoTransaction(POSInfoTransaction);
                POSInfoPOSEntry.Init;
                POSInfoPOSEntry."POS Entry No." := POSEntry."Entry No.";
                //-NPR5.41 [311499]
                POSInfoPOSEntry."POS Info Code" := POSInfoTransaction."POS Info Code";
                POSInfoPOSEntry."Entry No." := POSInfoTransaction."Entry No.";
                //+NPR5.41 [311499]
                POSInfoPOSEntry.TransferFields(POSInfoTransaction, false);
                POSInfoPOSEntry.Insert;
            until POSInfoTransaction.Next = 0;
        end else begin
            POSInfoAuditRoll.SetRange("Register No.", SalePOS."Register No.");
            POSInfoAuditRoll.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
            if POSInfoAuditRoll.FindFirst then
                repeat
                    POSInfoPOSEntry.Init;
                    POSInfoPOSEntry."POS Entry No." := POSEntry."Entry No.";
                    //-NPR5.41 [311499]
                    POSInfoPOSEntry."POS Info Code" := POSInfoAuditRoll."POS Info Code";
                    POSInfoPOSEntry."Entry No." := POSInfoAuditRoll."Entry No.";
                    //+NPR5.41 [311499]
                    POSInfoPOSEntry.TransferFields(POSInfoAuditRoll, false);
                    POSInfoPOSEntry.Insert;
                until POSInfoAuditRoll.Next = 0;
        end;
        //+NPR5.38 [295503]
    end;

    [EventSubscriber(ObjectType::Table, 6014405, 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDeleteSalePOS(var Rec: Record "Sale POS"; RunTrigger: Boolean)
    var
        POSInfoTransaction: Record "POS Info Transaction";
    begin
        //-NPR5.43 [320234]
        POSInfoTransaction.SetRange("Register No.", Rec."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");
        POSInfoTransaction.SetRange("Sales Line No.", 0);
        POSInfoTransaction.DeleteAll;
        //+NPR5.43 [320234]
    end;

    [EventSubscriber(ObjectType::Table, 6014406, 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDeleteSaleLinePOS(var Rec: Record "Sale Line POS"; RunTrigger: Boolean)
    begin
        //-NPR5.43 [320234]
        DeleteLine(Rec);
        //+NPR5.43 [320234]
    end;

    procedure ProcessPOSInfoMenuFunction(pSaleLinePos: Record "Sale Line POS"; pPOSInfoCode: Code[20]; pApplicScope: Option " ","Current Line","All Lines","New Lines",Ask; pClearInfo: Boolean)
    var
        POSInfo: Record "POS Info";
        // TODO: CTRLUPGRADE - declares a removed codeunit; all dependent functionality must be refactored
        //POSEventMarshaller: Codeunit "POS Event Marshaller";
        Info: Text;
        POSInfoTransaction: Record "POS Info Transaction";
        POSInfoLookupPage: Page "POS Info Lookup";
        RecRef: RecordRef;
        POSInfoLookupTable: Record "POS Info Lookup";
        SaleLinePos2: Record "Sale Line POS";
        SaleLinePosTmp: Record "Sale Line POS" temporary;
        Confirmed: Boolean;
    begin
        Clear(Info);
        POSInfo.Get(pPOSInfoCode);
        //-NPR5.51 [364558]
        if pApplicScope = pApplicScope::"New Lines" then
            POSInfo.TestField("Copy from Header", true);

        SaleLinePos2.SetRange("Register No.", pSaleLinePos."Register No.");
        SaleLinePos2.SetRange("Sales Ticket No.", pSaleLinePos."Sales Ticket No.");
        SaleLinePos2.SetRange(Date, pSaleLinePos.Date);
        SaleLinePos2.SetRange("Sale Type", pSaleLinePos."Sale Type");
        if SaleLinePos2.IsEmpty and (pApplicScope in [pApplicScope::" ", pApplicScope::Ask]) then
            pApplicScope := pApplicScope::"New Lines";
        if pApplicScope = pApplicScope::" " then
            pApplicScope := pApplicScope::"Current Line";

        if pApplicScope = pApplicScope::Ask then
            pApplicScope := StrMenu(DialogOptionsLbl, 1, DialogInstructionsLbl);
        if not (pApplicScope in [pApplicScope::"Current Line" .. pApplicScope::"New Lines"]) then
            // TODO: CTRLUPGRADE - Must be refactored without Marshaller
            Error('CTRLUPGRADE');
        /*
            POSEventMarshaller.DisplayError('Error',ErrText003,true);
        */
        //+NPR5.51 [364558]
        POSInfoTransaction.SetRange("Register No.", pSaleLinePos."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", pSaleLinePos."Sales Ticket No.");
        //IF NOT POSInfo."Once per Transaction" THEN  //NPR5.51 [364558]-revoked
        if not POSInfo."Once per Transaction" and (pApplicScope = pApplicScope::"Current Line") then  //NPR5.51 [364558]
            POSInfoTransaction.SetRange("Sales Line No.", pSaleLinePos."Line No.")
        //-NPR5.51 [364558]
        else
            if pApplicScope = pApplicScope::"New Lines" then
                POSInfoTransaction.SetRange("Sales Line No.", 0)
            //+NPR5.51 [364558]
            else
                POSInfoTransaction.SetRange("Sales Line No.");
        POSInfoTransaction.SetRange("POS Info Code", pPOSInfoCode);
        //-NPR5.51 [364558]-revoked (code duplication)
        /*IF POSInfoTransaction.FINDFIRST THEN BEGIN
          IF CONFIRM(STRSUBSTNO(ConfText001,pPOSInfoCode),TRUE) THEN BEGIN
            IF POSInfo.GET(pPOSInfoCode) THEN BEGIN
              IF POSInfo.Type = POSInfo.Type::"Request Data" THEN BEGIN
              CASE POSInfo."Input Type" OF
                POSInfo."Input Type"::Text : BEGIN
                  Info := POSEventMarshaller.SearchBox(POSInfo.Message,'',30);
                  IF Info = '' THEN
                    IF POSInfo."Input Mandatory" THEN
                      POSEventMarshaller.DisplayError('Error','Error',TRUE);
                END;
                POSInfo."Input Type"::Table : BEGIN
                  POSInfoLookupPage.SetPOSInfo(POSInfo);
                  POSInfoLookupPage.LOOKUPMODE(TRUE);
                  IF POSInfoLookupPage.RUNMODAL = ACTION::LookupOK THEN BEGIN
                    POSInfoLookupPage.GETRECORD(POSInfoLookupTable);
                    RecRef.OPEN(POSInfo."Table No.");
                    RecRef.GET(POSInfoLookupTable.RecID);
                    Info := CreatePrimKeyString(RecRef);
                  END;
                END;
                POSInfo."Input Type"::SubCode : BEGIN
                  POSInfoLookupPage.SetPOSInfo(POSInfo);
                  POSInfoLookupPage.LOOKUPMODE(TRUE);
                  IF POSInfoLookupPage.RUNMODAL = ACTION::LookupOK THEN BEGIN
                    POSInfoLookupPage.GETRECORD(POSInfoLookupTable);
                    Info := POSInfoLookupTable."Field 1";
                  END;
                END;
                END;
              END ELSE
                MESSAGE(POSInfo.Message);
        
              POSInfoTransaction."POS Info" := Info;
              POSInfoTransaction.MODIFY;
            END;
          END ELSE*/
        //+NPR5.51 [364558]-revoked
        //-NPR5.51 [364558]
        Confirmed := POSInfoTransaction.IsEmpty or pClearInfo;
        if not Confirmed then
            Confirmed := Confirm(StrSubstNo(ConfText001, pPOSInfoCode), true);
        if not Confirmed then
            //+NPR5.51 [364558]
            // TODO: CTRLUPGRADE - Refactor without Marshaller
            ERROR('CTRLUPGRADE');
        /*
        POSEventMarshaller.DisplayError('Error', ErrText003, true);
        */

        //END ELSE BEGIN  //NPR5.51 [364558]-revoked
        if POSInfo.Get(pPOSInfoCode) then begin
            if not pClearInfo then  //NPR5.51 [364558]
                if POSInfo.Type = POSInfo.Type::"Request Data" then begin
                    case POSInfo."Input Type" of
                        POSInfo."Input Type"::Text:
                            begin
                                // TODO: CTRLUPGRADE - Refactor without Marshaller
                                ERROR('CTRLUPGRADE');
                                /*
                                Info := POSEventMarshaller.SearchBox(POSInfo.Message, '', 30);
                                */
                                if Info = '' then
                                    if POSInfo."Input Mandatory" then
                                        Error('Error');
                            end;
                        POSInfo."Input Type"::Table:
                            begin
                                POSInfoLookupPage.SetPOSInfo(POSInfo);
                                POSInfoLookupPage.LookupMode(true);
                                if POSInfoLookupPage.RunModal = ACTION::LookupOK then begin
                                    POSInfoLookupPage.GetRecord(POSInfoLookupTable);
                                    RecRef.Open(POSInfo."Table No.");
                                    RecRef.Get(POSInfoLookupTable.RecID);
                                    Info := CreatePrimKeyString(RecRef);
                                end;
                            end;
                        POSInfo."Input Type"::SubCode:
                            begin
                                POSInfoLookupPage.SetPOSInfo(POSInfo);
                                POSInfoLookupPage.LookupMode(true);
                                if POSInfoLookupPage.RunModal = ACTION::LookupOK then begin
                                    POSInfoLookupPage.GetRecord(POSInfoLookupTable);
                                    Info := POSInfoLookupTable."Field 1";
                                end;
                            end;
                    end;
                end else
                    Message(POSInfo.Message);

            //-NPR5.51 [364558]
            if not POSInfo."Once per Transaction" and (pApplicScope in [pApplicScope::"Current Line", pApplicScope::"All Lines"]) then begin
                SaleLinePos2.SetRange("Register No.", pSaleLinePos."Register No.");
                SaleLinePos2.SetRange("Sales Ticket No.", pSaleLinePos."Sales Ticket No.");
                SaleLinePos2.SetRange(Date, pSaleLinePos.Date);
                SaleLinePos2.SetRange("Sale Type", pSaleLinePos."Sale Type");
                if pApplicScope = pApplicScope::"Current Line" then
                    SaleLinePos2.SetRange("Line No.", pSaleLinePos."Line No.");
                if SaleLinePos2.FindSet then
                    repeat
                        SaleLinePosTmp := SaleLinePos2;
                        SaleLinePosTmp.Insert;
                    until SaleLinePos2.Next = 0;
            end;
            if POSInfo."Once per Transaction" or (pApplicScope in [pApplicScope::"All Lines", pApplicScope::"New Lines"]) then begin
                SaleLinePosTmp.Init;
                SaleLinePosTmp."Register No." := pSaleLinePos."Register No.";
                SaleLinePosTmp."Sales Ticket No." := pSaleLinePos."Sales Ticket No.";
                SaleLinePosTmp.Date := pSaleLinePos.Date;
                SaleLinePosTmp."Sale Type" := pSaleLinePos."Sale Type";
                SaleLinePosTmp.Type := SaleLinePosTmp.Type::Item;
                SaleLinePosTmp."Line No." := 0;
                SaleLinePosTmp.Insert;
            end;
            if SaleLinePosTmp.FindSet then
                repeat
                    POSInfoTransaction.SetRange("Sales Line No.", SaleLinePosTmp."Line No.");
                    if POSInfoTransaction.FindFirst then begin
                        if pClearInfo then
                            POSInfoTransaction.Delete
                        else begin
                            POSInfoTransaction."POS Info" := Info;
                            POSInfoTransaction.Modify;
                        end;
                    end else
                        if not pClearInfo then begin
                            POSInfoTransaction.Init;
                            POSInfoTransaction."Register No." := SaleLinePosTmp."Register No.";
                            POSInfoTransaction."Sales Ticket No." := SaleLinePosTmp."Sales Ticket No.";
                            POSInfoTransaction."Sales Line No." := SaleLinePosTmp."Line No.";
                            POSInfoTransaction."Sale Date" := SaleLinePosTmp.Date;
                            POSInfoTransaction."Receipt Type" := SaleLinePosTmp.Type;
                            POSInfoTransaction."Entry No." := 0;
                            POSInfoTransaction."POS Info Code" := POSInfo.Code;
                            POSInfoTransaction."POS Info" := Info;
                            POSInfoTransaction.Insert(true);
                        end;
                until SaleLinePosTmp.Next = 0;
            //+NPR5.51 [364558]
            //-NPR5.51 [364558]-revoked
            /*POSInfoTransaction.INIT;
            POSInfoTransaction."Register No." := pSaleLinePos."Register No.";
            POSInfoTransaction."Sales Ticket No." := pSaleLinePos."Sales Ticket No.";
            IF NOT POSInfo."Once per Transaction" THEN
              POSInfoTransaction."Sales Line No." := pSaleLinePos."Line No.";
            POSInfoTransaction."Sale Date" := pSaleLinePos.Date;
            POSInfoTransaction."Receipt Type" := pSaleLinePos.Type;
            POSInfoTransaction."Entry No." := 0;
            POSInfoTransaction."POS Info Code" := POSInfo.Code;
            POSInfoTransaction."POS Info" := Info;
            POSInfoTransaction.INSERT(TRUE);
          END;*/
            //+NPR5.51 [364558]-revoked
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, 6014407, 'OnAfterDebitSalePostEvent', '', true, true)]
    local procedure OnAfterDebitSalePostEvent(var Sender: Codeunit "Retail Sales Doc. Mgt."; SalePOS: Record "Sale POS"; SalesHeader: Record "Sales Header"; Posted: Boolean; WriteInAuditRoll: Boolean)
    begin
        //-NPR5.46 [327626]
        PostPOSInfo(SalePOS);
        //+NPR5.46 [327626]
    end;

    procedure PostPOSInfo(PSalePos: Record "Sale POS")
    var
        POSInfoTransaction: Record "POS Info Transaction";
        POSInfoAuditRoll: Record "POS Info Audit Roll";
    begin
        POSInfoTransaction.SetRange("Register No.", PSalePos."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", PSalePos."Sales Ticket No.");
        if POSInfoTransaction.FindFirst then
            repeat
                UpdatePOSInfoTransaction(POSInfoTransaction);
                POSInfoAuditRoll.Init;
                POSInfoAuditRoll.TransferFields(POSInfoTransaction);
                POSInfoAuditRoll.Insert;
            until POSInfoTransaction.Next = 0;
        POSInfoTransaction.DeleteAll;
    end;

    local procedure CreatePrimKeyString(var pRecRef: RecordRef) PrimKey: Text
    var
        KeyRef: KeyRef;
        FieldRef: FieldRef;
        KeyValue: Text;
        i: Integer;
    begin

        KeyRef := pRecRef.KeyIndex(1);
        PrimKey := '';
        for i := 1 to KeyRef.FieldCount do begin
            FieldRef := KeyRef.FieldIndex(i);
            KeyValue := Format(FieldRef.Value);
            PrimKey += ';' + KeyValue;
        end;
        PrimKey := CopyStr(PrimKey, 2);
        exit;
    end;

    local procedure GetRecordFromPrimKeyString(pPOSInfoLookup: Record "POS Info Lookup"; var pRecRef: RecordRef)
    var
        FieldRef: FieldRef;
        KeyRef: KeyRef;
        GetText: Text;
        FieldValue: Text;
        i: Integer;
    begin
        KeyRef := pRecRef.KeyIndex(1);
        GetText := '';

        for i := 1 to KeyRef.FieldCount do begin
            FieldValue := SeparateKeyString(pPOSInfoLookup."Primary Key", i);
            GetText += ';' + FieldValue;
        end;
        GetText := CopyStr(GetText, 2);
        pRecRef.Open(pPOSInfoLookup."Table No.");
    end;

    local procedure SeparateKeyString(pKeyValue: Text; pFieldNo: Integer): Text
    var
        SearchStr: Text[250];
        CommaPos: Integer;
        OutPut: Text[250];
        I: Integer;
        SeparateChr: Text[1];
    begin

        SeparateChr := ';';
        SearchStr := pKeyValue;
        for I := 1 to pFieldNo do begin

            CommaPos := StrPos(SearchStr, SeparateChr);

            if CommaPos = 0 then begin
                if I = pFieldNo then
                    OutPut := SearchStr
                else
                    Error(ErrText001, pFieldNo);
            end else begin
                if I = pFieldNo then
                    OutPut := CopyStr(SearchStr, 1, CommaPos - 1)
                else begin
                    if CommaPos = StrLen(SearchStr) then
                        if I = pFieldNo - 1 then
                            SearchStr := ''
                        else
                            Error(ErrText002, pFieldNo)
                    else
                        SearchStr := CopyStr(SearchStr, CommaPos + 1, StrLen(SearchStr));
                end;
            end;
        end;
        exit(OutPut);
    end;

    procedure DeleteLine(SaleLinePOS: Record "Sale Line POS")
    var
        POSInfoTransaction: Record "POS Info Transaction";
    begin

        POSInfoTransaction.SetRange("Register No.", SaleLinePOS."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        POSInfoTransaction.SetRange("Sales Line No.", SaleLinePOS."Line No.");
        POSInfoTransaction.DeleteAll;
    end;

    procedure RetrieveSavedLines(ToSalePOS: Record "Sale POS"; FromSalePOS: Record "Sale POS")
    var
        POSInfoTransactionOld: Record "POS Info Transaction";
        POSInfoTransactionNew: Record "POS Info Transaction";
    begin
        POSInfoTransactionOld.SetRange("Register No.", FromSalePOS."Register No.");
        POSInfoTransactionOld.SetRange("Sales Ticket No.", FromSalePOS."Sales Ticket No.");
        if POSInfoTransactionOld.FindFirst then
            repeat
                POSInfoTransactionNew := POSInfoTransactionOld;
                POSInfoTransactionNew."Register No." := ToSalePOS."Register No.";
                POSInfoTransactionNew."Sales Ticket No." := ToSalePOS."Sales Ticket No.";
                POSInfoTransactionNew.Insert;
                POSInfoTransactionOld.Delete;
            until POSInfoTransactionOld.Next = 0;
    end;

    local procedure UpdatePOSInfoTransaction(var POSInfoTransaction: Record "POS Info Transaction")
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        //Register No.,Sales Ticket No.,Date,Sale Type,Line No.
        SaleLinePOS.Reset;
        SaleLinePOS.SetRange("Register No.", POSInfoTransaction."Register No.");
        SaleLinePOS.SetFilter("Sale Type", '%1|%2|%3', SaleLinePOS."Sale Type"::Sale, SaleLinePOS."Sale Type"::"Debit Sale", SaleLinePOS."Sale Type"::"Gift Voucher");
        SaleLinePOS.SetRange("Sales Ticket No.", POSInfoTransaction."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, POSInfoTransaction."Sale Date");
        if POSInfoTransaction."Sales Line No." <> 0 then
            SaleLinePOS.SetRange("Line No.", POSInfoTransaction."Sales Line No.");

        if SaleLinePOS.FindFirst then
            repeat
                if POSInfoTransaction."Sales Line No." <> 0 then begin
                    POSInfoTransaction."No." := SaleLinePOS."No.";
                    POSInfoTransaction.Price := SaleLinePOS."Unit Price";
                end;
                POSInfoTransaction.Quantity := POSInfoTransaction.Quantity + SaleLinePOS.Quantity;
                POSInfoTransaction."Net Amount" := POSInfoTransaction."Net Amount" + SaleLinePOS.Amount;
                POSInfoTransaction."Gross Amount" := POSInfoTransaction."Gross Amount" + SaleLinePOS."Amount Including VAT";
                POSInfoTransaction."Discount Amount" := POSInfoTransaction."Discount Amount" + SaleLinePOS."Discount Amount";
            until SaleLinePOS.Next = 0;
    end;

    procedure ProcessPOSInfoText(pSaleLinePos: Record "Sale Line POS"; pSalePos: Record "Sale POS"; pPOSInfoCode: Code[20]; pInfoText: Text)
    var
        POSInfo: Record "POS Info";
        Info: Text;
        POSInfoTransaction: Record "POS Info Transaction";
    begin
        //-NPR5.380 [296330]

        Info := CopyStr(pInfoText, 1, MaxStrLen(POSInfoTransaction."POS Info"));

        POSInfo.Get(pPOSInfoCode);
        POSInfo.TestField("Input Type", POSInfo."Input Type"::Text);
        POSInfo.TestField(Type, POSInfo.Type::"Request Data");
        if ((Info = '') and POSInfo."Input Mandatory") then begin
            Error(ERRInfoRequired, POSInfo.Code);
        end;

        POSInfoTransaction.SetRange("Register No.", pSalePos."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", pSalePos."Sales Ticket No.");

        if not POSInfo."Once per Transaction" then begin
            POSInfoTransaction.SetRange("Sales Line No.", pSaleLinePos."Line No.")
        end else begin
            POSInfoTransaction.SetRange("Sales Line No.");
        end;
        POSInfoTransaction.SetRange("POS Info Code", pPOSInfoCode);

        if POSInfoTransaction.FindFirst then begin
            POSInfoTransaction."POS Info" := Info;
            POSInfoTransaction.Modify;
        end else begin
            POSInfoTransaction.Init;
            POSInfoTransaction."Register No." := pSalePos."Register No.";
            POSInfoTransaction."Sales Ticket No." := pSalePos."Sales Ticket No.";

            if not POSInfo."Once per Transaction" then begin
                POSInfoTransaction."Sales Line No." := pSaleLinePos."Line No.";

                POSInfoTransaction."Sale Date" := pSaleLinePos.Date;
                POSInfoTransaction."Receipt Type" := pSaleLinePos.Type;
            end else begin
                POSInfoTransaction."Sale Date" := pSalePos.Date;
                POSInfoTransaction."Receipt Type" := pSaleLinePos.Type::Comment;
            end;


            POSInfoTransaction."Entry No." := 0;
            POSInfoTransaction."POS Info Code" := POSInfo.Code;
            POSInfoTransaction."POS Info" := Info;
            POSInfoTransaction.Insert(true);
        end;
        //+NPR5.380 [296330]
    end;

    procedure CopyPOSInfoTransFromHeader(SaleLinePos: Record "Sale Line POS"; var POSInfoTransaction: Record "POS Info Transaction")
    var
        POSInfo: Record "POS Info";
        POSInfoTransaction_Hdr: Record "POS Info Transaction";
    begin
        //-NPR5.51 [364558]
        if not (SaleLinePos.Type in [SaleLinePos.Type::Item, SaleLinePos.Type::"Item Group", SaleLinePos.Type::"G/L Entry"]) or
          (SaleLinePos."Sale Type" = SaleLinePos."Sale Type"::Comment)
        then
            exit;

        POSInfoTransaction_Hdr.SetRange("Register No.", SaleLinePos."Register No.");
        POSInfoTransaction_Hdr.SetRange("Sales Ticket No.", SaleLinePos."Sales Ticket No.");
        POSInfoTransaction_Hdr.SetRange("Sales Line No.", 0);
        POSInfoTransaction_Hdr.SetFilter("POS Info Code", '<>%1', '');
        if POSInfoTransaction_Hdr.FindSet then
            repeat
                POSInfo.Get(POSInfoTransaction_Hdr."POS Info Code");
                if not POSInfo."Once per Transaction" and POSInfo."Copy from Header" then begin
                    SaleLinePos.TestField("Line No.");  //Ensure line has been already inserted
                    POSInfoTransaction.Reset;
                    POSInfoTransaction.SetRange("Register No.", SaleLinePos."Register No.");
                    POSInfoTransaction.SetRange("Sales Ticket No.", SaleLinePos."Sales Ticket No.");
                    POSInfoTransaction.SetRange("Sales Line No.", SaleLinePos."Line No.");
                    POSInfoTransaction.SetRange("POS Info Code", POSInfoTransaction_Hdr."POS Info Code");
                    if POSInfoTransaction.IsEmpty then begin
                        POSInfoTransaction.Init;
                        POSInfoTransaction."Register No." := SaleLinePos."Register No.";
                        POSInfoTransaction."Sales Ticket No." := SaleLinePos."Sales Ticket No.";
                        POSInfoTransaction."Sales Line No." := SaleLinePos."Line No.";
                        POSInfoTransaction."Sale Date" := SaleLinePos.Date;
                        POSInfoTransaction."Receipt Type" := SaleLinePos.Type;
                        POSInfoTransaction."Entry No." := 0;
                        POSInfoTransaction."POS Info Code" := POSInfoTransaction_Hdr."POS Info Code";
                        POSInfoTransaction."POS Info" := POSInfoTransaction_Hdr."POS Info";
                        POSInfoTransaction.Insert(true);
                    end;
                end;
            until POSInfoTransaction_Hdr.Next = 0;
        POSInfoTransaction.Reset;
        //+NPR5.51 [364558]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150853, 'OnGetLineStyle', '', false, false)]
    local procedure FormatSaleLine_OnPOSInfoAssigment(var Color: Text; var Weight: Text; var Style: Text; SaleLinePOS: Record "Sale Line POS"; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management")
    var
        POSInfoTransaction: Record "POS Info Transaction";
    begin
        //-NPR5.51 [364558]
        FilterPOSInfoTrans(POSInfoTransaction, '', SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.");
        if not POSInfoTransaction.IsEmpty then
            Color := 'red';
        POSSession.RequestRefreshData();
        //+NPR5.51 [364558]
    end;

    local procedure FilterPOSInfoTrans(var POSInfoTransaction: Record "POS Info Transaction"; POSInfoCode: Code[20]; RegisterNo: Code[10]; SalesTicketNo: Code[20]; LineNo: Integer)
    begin
        //-NPR5.51 [364558]
        POSInfoTransaction.Reset;
        if POSInfoCode <> '' then
            POSInfoTransaction.SetRange("POS Info Code", POSInfoCode);
        POSInfoTransaction.SetRange("Register No.", RegisterNo);
        POSInfoTransaction.SetRange("Sales Ticket No.", SalesTicketNo);
        POSInfoTransaction.SetRange("Sales Line No.", LineNo);
        //+NPR5.51 [364558]
    end;

    local procedure "--- DataSource Extension"()
    begin
        //NPR5.51 [364558]
    end;

    local procedure ThisDataSource(): Text
    begin
        exit('BUILTIN_SALELINE');  //NPR5.51 [364558]
    end;

    local procedure ThisExtension(): Text
    begin
        exit('POS_INFO');  //NPR5.51 [364558]
    end;

    local procedure DataSoucePOSInfoColumnName(POSInfoCode: Code[20]): Text
    begin
        exit(StrSubstNo('POSInfo%1', POSInfoCode));  //NPR5.51 [364558]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDiscoverDataSourceExtensions', '', false, false)]
    local procedure OnDiscoverDataSourceExtension(DataSourceName: Text; Extensions: DotNet npNetList_Of_T)
    begin
        //-NPR5.51 [364558]
        if ThisDataSource <> DataSourceName then
            exit;

        Extensions.Add(ThisExtension);
        //+NPR5.51 [364558]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnGetDataSourceExtension', '', false, false)]
    local procedure OnGetDataSourceExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: DotNet npNetDataSource0; var Handled: Boolean; Setup: Codeunit "POS Setup")
    var
        POSInfo: Record "POS Info";
        DataType: DotNet npNetDataType;
    begin
        //-NPR5.51 [364558]
        if (DataSourceName <> ThisDataSource) or (ExtensionName <> ThisExtension) then
            exit;

        Handled := true;

        POSInfo.SetRange("Available in Front-End", true);
        if not POSInfo.FindSet then
            exit;
        repeat
            DataSource.AddColumn(DataSoucePOSInfoColumnName(POSInfo.Code), StrSubstNo('POS Info: %1', POSInfo.Code), DataType.String, false);
        until POSInfo.Next = 0;
        //+NPR5.51 [364558]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDataSourceExtensionReadData', '', false, false)]
    local procedure OnDataSourceExtensionReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: DotNet npNetDataRow0; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
    var
        POSInfo: Record "POS Info";
        POSInfoTransaction: Record "POS Info Transaction";
        SaleLinePOS: Record "Sale Line POS";
        POSSaleLine: Codeunit "POS Sale Line";
    begin
        //-NPR5.51 [364558]
        if (DataSourceName <> ThisDataSource) or (ExtensionName <> ThisExtension) then
            exit;

        Handled := true;

        POSInfo.SetRange("Available in Front-End", true);
        if not POSInfo.FindSet then
            exit;

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        repeat
            FilterPOSInfoTrans(POSInfoTransaction, POSInfo.Code, SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.");
            if POSInfoTransaction.IsEmpty then
                POSInfoTransaction.SetRange("Sales Line No.", 0);
            if not POSInfoTransaction.FindFirst then
                POSInfoTransaction.Init;
            DataRow.Add(DataSoucePOSInfoColumnName(POSInfo.Code), POSInfoTransaction."POS Info");
        until POSInfo.Next = 0;
        //+NPR5.51 [364558]
    end;
}

