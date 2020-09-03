// TODO: CTRLUPGRADE - uses old Standard code; must be removed or refactored
codeunit 6150640 "NPR POS Info Management"
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
    // NPR5.51/ALPO/20190912 CASE 368351 Apply red color to POS sale lines only for selected POS info codes
    // NPR5.52/ALPO/20190927 CASE 364558 Data Source changed to 'BUILTIN_SALE'. Ensure front end update is scheduled after POS info has been changed
    // NPR5.53/TJ  /20191022 CASE 370575 Implemented new Type option: "Write Default Message"
    // NPR5.53/ALPO/20200204 CASE 387750 Table "POS Info POS Entry": added fields: "Document No.", "Entry Date", "POS Unit No.", "Salesperson Code"
    // NPR5.53/ALPO/20200204 CASE 388697 Entries with Type = Write Default Message were not saved to "POS Info Transaction"/"POS Info POS Entry" tables
    //                                   (+refactored code to avoid unnecessary duplication)
    //                                   (+deleted old commented lines)


    trigger OnRun()
    begin
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
        ApplicScope: Option " ","Current Line","All Lines","New Lines",Ask;
        MustBeSpecified: Label 'You cannot leave this field blank.';
        ConfirmRetry: Label 'Do you want to try again?';

    [EventSubscriber(ObjectType::Table, 6014406, 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure OnAfterValidateSalesLineNoSaleLinePos(var Rec: Record "NPR Sale Line POS"; var xRec: Record "NPR Sale Line POS"; CurrFieldNo: Integer)
    var
        POSInfoLinkTable: Record "NPR POS Info Link Table";
        POSInfoTransaction: Record "NPR POS Info Transaction";
        FrontEndUpdateIsNeeded: Boolean;
    begin
        if Rec.Type = Rec.Type::Item then begin
            POSInfoLinkTable.Reset;
            POSInfoLinkTable.SetRange("Table ID", DATABASE::Item);
            POSInfoLinkTable.SetRange("Primary Key", Rec."No.");
            //-NPR5.53 [388697]-revoked
            /*
            IF POSInfoLinkTable.FINDFIRST THEN REPEAT
              CLEAR(Info);
              BEGIN
                POSInfo.GET(POSInfoLinkTable."POS Info Code");
                POSInfoTransaction.SETRANGE("Register No.",Rec."Register No.");
                POSInfoTransaction.SETRANGE("Sales Ticket No.",Rec."Sales Ticket No.");
                IF NOT POSInfo."Once per Transaction" THEN
                  POSInfoTransaction.SETRANGE("Sales Line No.",Rec."Line No.")
                ELSE
                  POSInfoTransaction.SETRANGE("Sales Line No.");

                POSInfoTransaction.SETRANGE("POS Info Code",POSInfoLinkTable."POS Info Code");
                IF NOT POSInfoTransaction.FINDFIRST THEN BEGIN
                  //-NPR5.53 [370575]
                  //IF POSInfo.Type = POSInfo.Type::"Request Data" THEN BEGIN
                  CASE POSInfo.Type OF
                    POSInfo.Type::"Request Data":
                  //+NPR5.53 [370575]
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
                  //-NPR5.53 [370575]
                  {
                  END ELSE BEGIN
                    MESSAGE(POSInfo.Message);
                    Info := POSInfo.Message;
                  END;
                  }
                    POSInfo.Type::"Show Message":
                      BEGIN
                        MESSAGE(POSInfo.Message);
                        Info := POSInfo.Message;
                      END;
                    POSInfo.Type::"Write Default Message":
                      Info := POSInfo.Message;
                  END;
                  //+NPR5.53 [370575]

                  TempPOSInfoTransaction.INIT;
                  TempPOSInfoTransaction."Register No." := Rec."Register No.";
                  TempPOSInfoTransaction."Sales Ticket No." := Rec."Sales Ticket No.";
                  IF NOT POSInfo."Once per Transaction" THEN
                    TempPOSInfoTransaction."Sales Line No." := Rec."Line No.";
                  TempPOSInfoTransaction."Sale Date" := Rec.Date;
                  TempPOSInfoTransaction."Receipt Type" := Rec.Type;
                  TempPOSInfoTransaction."Entry No." := 0;
                  TempPOSInfoTransaction."POS Info Code" := POSInfo.Code;
                  TempPOSInfoTransaction."POS Info" := Info;
                  TempPOSInfoTransaction.INSERT(TRUE);
                END;
              END;
            UNTIL POSInfoLinkTable.NEXT = 0;
            FrontEndUpdateIsNeeded := TempPOSInfoTransaction.FINDSET;
            IF FrontEndUpdateIsNeeded THEN
              REPEAT
                POSInfoTransaction := TempPOSInfoTransaction;
                POSInfoTransaction."Entry No." := 0;
                POSInfoTransaction.INSERT(TRUE);
              UNTIL TempPOSInfoTransaction.NEXT = 0;
            */
            //+NPR5.53 [388697]-revoked
            //-NPR5.53 [388697]
            FrontEndUpdateIsNeeded := ProcessPOSInfoLinkEntries(POSInfoLinkTable, Rec, ApplicScope::"Current Line");
            //+NPR5.53 [388697]
        end;
        FrontEndUpdateIsNeeded := CopyPOSInfoTransFromHeader(Rec, POSInfoTransaction) or FrontEndUpdateIsNeeded;
        if FrontEndUpdateIsNeeded then
            CallFrontEndUpdate();

    end;

    [EventSubscriber(ObjectType::Table, 6014405, 'OnBeforeValidateEvent', 'Customer No.', false, false)]
    local procedure OnBeforeValidateCustomerNoSalePos(var Rec: Record "NPR Sale POS"; var xRec: Record "NPR Sale POS"; CurrFieldNo: Integer)
    var
        POSInfoLinkTable: Record "NPR POS Info Link Table";
        pSaleLinePos: Record "NPR Sale Line POS";
        FrontEndUpdateIsNeeded: Boolean;
    begin
        //CLEAR(Info);  //NPR5.53 [388697]-revoked
        POSInfoLinkTable.Reset;
        POSInfoLinkTable.SetRange("Table ID", DATABASE::Customer);
        POSInfoLinkTable.SetRange("Primary Key", Rec."Customer No.");

        //-NPR5.53 [388697]
        pSaleLinePos.Init;
        pSaleLinePos."Register No." := Rec."Register No.";
        pSaleLinePos."Sales Ticket No." := Rec."Sales Ticket No.";
        pSaleLinePos.Date := Rec.Date;
        pSaleLinePos."Sale Type" := pSaleLinePos."Sale Type"::Sale;
        pSaleLinePos."Line No." := 0;

        FrontEndUpdateIsNeeded := ProcessPOSInfoLinkEntries(POSInfoLinkTable, pSaleLinePos, ApplicScope::"All Lines");

        if FrontEndUpdateIsNeeded then
            CallFrontEndUpdate();
        //+NPR5.53 [388697]
        //-NPR5.53 [388697]-revoked
        /*
        IF POSInfoLinkTable.FINDFIRST THEN REPEAT
          CLEAR(Info);
          POSInfo.GET(POSInfoLinkTable."POS Info Code");
          POSInfoTransaction.SETRANGE("Register No.",Rec."Register No.");
          POSInfoTransaction.SETRANGE("Sales Ticket No.",Rec."Sales Ticket No.");
          POSInfoTransaction.SETRANGE("POS Info Code",POSInfoLinkTable."POS Info Code");
          IF NOT POSInfoTransaction.FINDFIRST THEN BEGIN
            IF POSInfo.Type = POSInfo.Type::"Request Data" THEN BEGIN
              Info := POSEventMarshaller.SearchBox (POSInfo.Message, POSInfo.Description, MAXSTRLEN(POSInfoTransaction."POS Info"));
              IF Info = '' THEN
                IF POSInfo."Input Mandatory" THEN
                  POSEventMarshaller.DisplayError('Error','Error',TRUE);
        
              TempPOSInfoTransaction.INIT;
              TempPOSInfoTransaction."Register No." := Rec."Register No.";
              TempPOSInfoTransaction."Sales Ticket No." := Rec."Sales Ticket No.";
              TempPOSInfoTransaction."Sale Date" := Rec.Date;
              TempPOSInfoTransaction."Receipt Type" := POSInfoTransaction."Receipt Type"::Customer;
              TempPOSInfoTransaction."Entry No." := 0;
              TempPOSInfoTransaction."POS Info Code" := POSInfo.Code;
              TempPOSInfoTransaction."POS Info" := Info;
              TempPOSInfoTransaction."No." := Rec."Customer No.";
              TempPOSInfoTransaction.INSERT(TRUE);
            END;
          END;
        UNTIL POSInfoLinkTable.NEXT = 0;
        
        IF TempPOSInfoTransaction.FINDSET THEN
          REPEAT
            POSInfoTransaction := TempPOSInfoTransaction;
            POSInfoTransaction."Entry No." := 0;
            POSInfoTransaction.INSERT(TRUE);
          UNTIL TempPOSInfoTransaction.NEXT = 0;
        */
        //+NPR5.53 [388697]-revoked

    end;

    [EventSubscriber(ObjectType::Table, 6014405, 'OnAfterValidateEvent', 'Customer No.', false, false)]
    local procedure OnAfterValidateCustomerNoSalePos(var Rec: Record "NPR Sale POS"; var xRec: Record "NPR Sale POS"; CurrFieldNo: Integer)
    var
        POSInfoLinkTable: Record "NPR POS Info Link Table";
        POSInfo: Record "NPR POS Info";
        Info: Text;
        POSInfoTransaction: Record "NPR POS Info Transaction";
        TempPOSInfoTransaction: Record "NPR POS Info Transaction" temporary;
    begin
        //-NPR5.53 [388697]-revoked
        /*
        CLEAR(Info);
        POSInfoLinkTable.RESET;
        POSInfoLinkTable.SETRANGE("Table ID",18);
        POSInfoLinkTable.SETRANGE("Primary Key",Rec."Customer No.");
        IF POSInfoLinkTable.FINDFIRST THEN REPEAT
          CLEAR(Info);
          POSInfo.GET(POSInfoLinkTable."POS Info Code");
          POSInfoTransaction.SETRANGE("Register No.",Rec."Register No.");
          POSInfoTransaction.SETRANGE("Sales Ticket No.",Rec."Sales Ticket No.");
          POSInfoTransaction.SETRANGE("POS Info Code",POSInfoLinkTable."POS Info Code");
          IF NOT POSInfoTransaction.FINDFIRST THEN BEGIN
             MESSAGE(POSInfo.Message);
            Info := POSInfo.Message;
        
            TempPOSInfoTransaction.INIT;
            TempPOSInfoTransaction."Register No." := Rec."Register No.";
            TempPOSInfoTransaction."Sales Ticket No." := Rec."Sales Ticket No.";
            TempPOSInfoTransaction."Sale Date" := Rec.Date;
            TempPOSInfoTransaction."Receipt Type" := TempPOSInfoTransaction."Receipt Type"::Customer;
            TempPOSInfoTransaction."Entry No." := 0;
            TempPOSInfoTransaction."POS Info Code" := POSInfo.Code;
            TempPOSInfoTransaction."POS Info" := Info;
            TempPOSInfoTransaction."No." := Rec."Customer No.";
            TempPOSInfoTransaction.INSERT(TRUE);
          END;
        UNTIL POSInfoLinkTable.NEXT = 0;
        IF TempPOSInfoTransaction.FINDSET THEN
          REPEAT
            POSInfoTransaction := TempPOSInfoTransaction;
            POSInfoTransaction."Entry No." := 0;
            POSInfoTransaction.INSERT(TRUE);
          UNTIL TempPOSInfoTransaction.NEXT = 0;
        */
        //+NPR5.53 [388697]-revoked

    end;

    [EventSubscriber(ObjectType::Codeunit, 6150614, 'OnAfterInsertPOSEntry', '', true, true)]
    local procedure OnAfterInsertPOSEntry(var SalePOS: Record "NPR Sale POS"; var POSEntry: Record "NPR POS Entry")
    var
        POSInfoTransaction: Record "NPR POS Info Transaction";
        POSInfoAuditRoll: Record "NPR POS Info Audit Roll";
        POSInfoPOSEntry: Record "NPR POS Info POS Entry";
    begin
        POSInfoTransaction.SetRange("Register No.", SalePOS."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if POSInfoTransaction.FindSet then begin
            repeat
                UpdatePOSInfoTransaction(POSInfoTransaction);
                POSInfoPOSEntry.Init;
                POSInfoPOSEntry."POS Entry No." := POSEntry."Entry No.";
                POSInfoPOSEntry."POS Info Code" := POSInfoTransaction."POS Info Code";
                POSInfoPOSEntry."Entry No." := POSInfoTransaction."Entry No.";
                POSInfoPOSEntry.TransferFields(POSInfoTransaction, false);
                //-NPR5.53 [388666]
                POSInfoPOSEntry."POS Unit No." := POSEntry."POS Unit No.";
                POSInfoPOSEntry."Salesperson Code" := POSEntry."Salesperson Code";
                //+NPR5.53 [388666]
                POSInfoPOSEntry.Insert;
            until POSInfoTransaction.Next = 0;
        end else begin
            POSInfoAuditRoll.SetRange("Register No.", SalePOS."Register No.");
            POSInfoAuditRoll.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
            if POSInfoAuditRoll.FindFirst then
                repeat
                    POSInfoPOSEntry.Init;
                    POSInfoPOSEntry."POS Entry No." := POSEntry."Entry No.";
                    POSInfoPOSEntry."POS Info Code" := POSInfoAuditRoll."POS Info Code";
                    POSInfoPOSEntry."Entry No." := POSInfoAuditRoll."Entry No.";
                    POSInfoPOSEntry.TransferFields(POSInfoAuditRoll, false);
                    //-NPR5.53 [388666]
                    POSInfoPOSEntry."POS Unit No." := POSEntry."POS Unit No.";
                    POSInfoPOSEntry."Salesperson Code" := POSEntry."Salesperson Code";
                    //+NPR5.53 [388666]
                    POSInfoPOSEntry.Insert;
                until POSInfoAuditRoll.Next = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6014405, 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDeleteSalePOS(var Rec: Record "NPR Sale POS"; RunTrigger: Boolean)
    var
        POSInfoTransaction: Record "NPR POS Info Transaction";
    begin
        POSInfoTransaction.SetRange("Register No.", Rec."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", Rec."Sales Ticket No.");
        POSInfoTransaction.SetRange("Sales Line No.", 0);
        POSInfoTransaction.DeleteAll;
    end;

    [EventSubscriber(ObjectType::Table, 6014406, 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDeleteSaleLinePOS(var Rec: Record "NPR Sale Line POS"; RunTrigger: Boolean)
    begin
        DeleteLine(Rec);
    end;

    local procedure ProcessPOSInfoLinkEntries(var POSInfoLinkTable: Record "NPR POS Info Link Table"; pSaleLinePos: Record "NPR Sale Line POS"; pApplicScope: Option " ","Current Line","All Lines","New Lines",Ask) FrontEndUpdateIsNeeded: Boolean
    var
        POSInfo: Record "NPR POS Info";
        TempPOSInfoTransaction: Record "NPR POS Info Transaction" temporary;
    begin
        //-NPR5.53 [388697]
        if POSInfoLinkTable.FindSet then
            repeat
                POSInfo.Get(POSInfoLinkTable."POS Info Code");
                ConfirmPOSInfoTransOverwrite(pSaleLinePos, POSInfo, pApplicScope);

                TempPOSInfoTransaction.Init;
                TempPOSInfoTransaction.CopyFromPOSInfo(POSInfo);
                TempPOSInfoTransaction."POS Info" := CopyStr(GetPosInfoOutput(POSInfo), 1, MaxStrLen(TempPOSInfoTransaction."POS Info"));
                TempPOSInfoTransaction.Insert(true);
            until POSInfoLinkTable.Next = 0;

        FrontEndUpdateIsNeeded := false;
        if TempPOSInfoTransaction.FindSet then
            repeat
                TempPOSInfoTransaction.ShowMessage;
                if SaleLineApplyPOSInfo(pSaleLinePos, TempPOSInfoTransaction, pApplicScope, false) then
                    FrontEndUpdateIsNeeded := true;
            until TempPOSInfoTransaction.Next = 0;
        //+NPR5.53 [388697]
    end;

    procedure ProcessPOSInfoMenuFunction(pSaleLinePos: Record "NPR Sale Line POS"; pPOSInfoCode: Code[20]; pApplicScope: Option " ","Current Line","All Lines","New Lines",Ask; pClearInfo: Boolean) FrontEndUpdateIsNeeded: Boolean
    var
        POSInfo: Record "NPR POS Info";
        POSInfoTransaction: Record "NPR POS Info Transaction";
        POSInfoTransParam: Record "NPR POS Info Transaction";
        SaleLinePos2: Record "NPR Sale Line POS";
        SaleLinePosTmp: Record "NPR Sale Line POS" temporary;
    begin
        //-NPR5.53 [388697]-revoked
        /*
        CLEAR(Info);
        POSInfo.GET(pPOSInfoCode);
        IF pApplicScope = pApplicScope::"New Lines" THEN
          POSInfo.TESTFIELD("Copy from Header",TRUE);
        
        SaleLinePos2.SETRANGE("Register No.",pSaleLinePos."Register No.");
        SaleLinePos2.SETRANGE("Sales Ticket No.",pSaleLinePos."Sales Ticket No.");
        SaleLinePos2.SETRANGE(Date,pSaleLinePos.Date);
        SaleLinePos2.SETRANGE("Sale Type",pSaleLinePos."Sale Type");
        IF SaleLinePos2.ISEMPTY AND (pApplicScope IN [pApplicScope::" ",pApplicScope::Ask]) THEN
          pApplicScope := pApplicScope::"New Lines";
        IF pApplicScope = pApplicScope::" " THEN
          pApplicScope := pApplicScope::"Current Line";
        
        IF pApplicScope = pApplicScope::Ask THEN
          pApplicScope := STRMENU(DialogOptionsLbl,1,DialogInstructionsLbl);
        IF NOT (pApplicScope IN [pApplicScope::"Current Line" .. pApplicScope::"New Lines"]) THEN
          POSEventMarshaller.DisplayError('Error',ErrText003,TRUE);
        
        POSInfoTransaction.SETRANGE("Register No.",pSaleLinePos."Register No.");
        POSInfoTransaction.SETRANGE("Sales Ticket No.",pSaleLinePos."Sales Ticket No.");
        IF NOT POSInfo."Once per Transaction" AND (pApplicScope = pApplicScope::"Current Line") THEN
          POSInfoTransaction.SETRANGE("Sales Line No.",pSaleLinePos."Line No.")
        ELSE IF pApplicScope = pApplicScope::"New Lines" THEN
          POSInfoTransaction.SETRANGE("Sales Line No.",0)
        ELSE
          POSInfoTransaction.SETRANGE("Sales Line No.");
        POSInfoTransaction.SETRANGE("POS Info Code",pPOSInfoCode);
        Confirmed := POSInfoTransaction.ISEMPTY OR pClearInfo;
        IF NOT Confirmed THEN
          Confirmed := CONFIRM(STRSUBSTNO(ConfText001,pPOSInfoCode),TRUE);
        IF NOT Confirmed THEN
          POSEventMarshaller.DisplayError('Error',ErrText003,TRUE);
        
        FrontEndUpdateIsNeeded := FALSE;
        IF POSInfo.GET(pPOSInfoCode) THEN BEGIN
          IF NOT pClearInfo THEN
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
        
          IF NOT POSInfo."Once per Transaction" AND (pApplicScope IN [pApplicScope::"Current Line",pApplicScope::"All Lines"]) THEN BEGIN
            SaleLinePos2.SETRANGE("Register No.",pSaleLinePos."Register No.");
            SaleLinePos2.SETRANGE("Sales Ticket No.",pSaleLinePos."Sales Ticket No.");
            SaleLinePos2.SETRANGE(Date,pSaleLinePos.Date);
            SaleLinePos2.SETRANGE("Sale Type",pSaleLinePos."Sale Type");
            IF pApplicScope = pApplicScope::"Current Line" THEN
              SaleLinePos2.SETRANGE("Line No.",pSaleLinePos."Line No.");
            IF SaleLinePos2.FINDSET THEN
              REPEAT
                SaleLinePosTmp := SaleLinePos2;
                SaleLinePosTmp.INSERT;
              UNTIL SaleLinePos2.NEXT = 0;
          END;
          IF POSInfo."Once per Transaction" OR (pApplicScope IN [pApplicScope::"All Lines",pApplicScope::"New Lines"]) THEN BEGIN
            SaleLinePosTmp.INIT;
            SaleLinePosTmp."Register No." := pSaleLinePos."Register No.";
            SaleLinePosTmp."Sales Ticket No." := pSaleLinePos."Sales Ticket No.";
            SaleLinePosTmp.Date := pSaleLinePos.Date;
            SaleLinePosTmp."Sale Type" := pSaleLinePos."Sale Type";
            SaleLinePosTmp.Type := SaleLinePosTmp.Type::Item;
            SaleLinePosTmp."Line No." := 0;
            SaleLinePosTmp.INSERT;
          END;
          IF SaleLinePosTmp.FINDSET THEN
            REPEAT
              POSInfoTransaction.SETRANGE("Sales Line No.",SaleLinePosTmp."Line No.");
              IF POSInfoTransaction.FINDFIRST THEN BEGIN
                IF pClearInfo THEN
                  POSInfoTransaction.DELETE
                ELSE BEGIN
                  POSInfoTransaction."POS Info" := Info;
                  POSInfoTransaction.MODIFY;
                END;
                FrontEndUpdateIsNeeded := TRUE;
              END ELSE IF NOT pClearInfo THEN BEGIN
                POSInfoTransaction.INIT;
                POSInfoTransaction."Register No." := SaleLinePosTmp."Register No.";
                POSInfoTransaction."Sales Ticket No." := SaleLinePosTmp."Sales Ticket No.";
                POSInfoTransaction."Sales Line No." := SaleLinePosTmp."Line No.";
                POSInfoTransaction."Sale Date" := SaleLinePosTmp.Date;
                POSInfoTransaction."Receipt Type" := SaleLinePosTmp.Type;
                POSInfoTransaction."Entry No." := 0;
                POSInfoTransaction."POS Info Code" := POSInfo.Code;
                POSInfoTransaction."POS Info" := Info;
                POSInfoTransaction.INSERT(TRUE);
                FrontEndUpdateIsNeeded := TRUE;
              END;
            UNTIL SaleLinePosTmp.NEXT = 0;
        END;
        */
        //+NPR5.53 [388697]-revoked
        //-NPR5.53 [388697]
        POSInfo.Get(pPOSInfoCode);
        CheckAndAdjustApplicationScope(pSaleLinePos, POSInfo, pApplicScope);
        if not pClearInfo then
            ConfirmPOSInfoTransOverwrite(pSaleLinePos, POSInfo, pApplicScope);

        POSInfoTransParam.Init;
        POSInfoTransParam.CopyFromPOSInfo(POSInfo);
        if not pClearInfo then begin
            POSInfoTransParam."POS Info" := CopyStr(GetPosInfoOutput(POSInfo), 1, MaxStrLen(POSInfoTransParam."POS Info"));
            POSInfoTransParam.ShowMessage;
        end;

        FrontEndUpdateIsNeeded := SaleLineApplyPOSInfo(pSaleLinePos, POSInfoTransParam, pApplicScope, pClearInfo);
        //+NPR5.53 [388697]

        if FrontEndUpdateIsNeeded then
            CallFrontEndUpdate();

    end;

    local procedure CheckAndAdjustApplicationScope(pSaleLinePos: Record "NPR Sale Line POS"; POSInfo: Record "NPR POS Info"; var pApplicScope: Option " ","Current Line","All Lines","New Lines",Ask)
    var
        SaleLinePos2: Record "NPR Sale Line POS";
    begin
        //-NPR5.53 [388697]
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
            Error('');
        //+NPR5.53 [388697]
    end;

    local procedure ConfirmPOSInfoTransOverwrite(pSaleLinePos: Record "NPR Sale Line POS"; POSInfo: Record "NPR POS Info"; pApplicScope: Option " ","Current Line","All Lines","New Lines",Ask)
    var
        POSInfoTransaction: Record "NPR POS Info Transaction";
        Confirmed: Boolean;
    begin
        //-NPR5.53 [388697]
        SetPosInfoTransactionFilters(POSInfoTransaction, pSaleLinePos, POSInfo, pApplicScope);
        Confirmed := POSInfoTransaction.IsEmpty;
        if not Confirmed then
            Confirmed := Confirm(StrSubstNo(ConfText001, POSInfo.Code), true);
        if not Confirmed then
            Error('');
        //+NPR5.53 [388697]
    end;

    local procedure SetPosInfoTransactionFilters(var POSInfoTransaction: Record "NPR POS Info Transaction"; pSaleLinePos: Record "NPR Sale Line POS"; POSInfo: Record "NPR POS Info"; pApplicScope: Option " ","Current Line","All Lines","New Lines",Ask)
    begin
        //-NPR5.53 [388697]
        POSInfoTransaction.SetRange("Register No.", pSaleLinePos."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", pSaleLinePos."Sales Ticket No.");
        case true of
            not POSInfo."Once per Transaction" and (pApplicScope = pApplicScope::"Current Line"):
                POSInfoTransaction.SetRange("Sales Line No.", pSaleLinePos."Line No.");
            pApplicScope = pApplicScope::"New Lines":
                POSInfoTransaction.SetRange("Sales Line No.", 0);
            else
                POSInfoTransaction.SetRange("Sales Line No.");
        end;
        POSInfoTransaction.SetRange("POS Info Code", POSInfo.Code);
        //+NPR5.53 [388697]
    end;

    local procedure GetPosInfoOutput(POSInfo: Record "NPR POS Info") Info: Text
    var
        POSInfoLookupTable: Record "NPR POS Info Lookup";
        //POSEventMarshaller: Codeunit "POS Event Marshaller";
        POSInfoLookupPage: Page "NPR POS Info Lookup";
        RecRef: RecordRef;
        Cancelled: Boolean;
    begin
        // TODO: Uses POS Event Marshaller, refactoring required!!!
        Error('TODO: Uses POS Event Marshaller, refactoring required!!!');
        /*
        //-NPR5.53 [388697]        
        Info := '';
        case POSInfo.Type of
          POSInfo.Type::"Request Data":
            case POSInfo."Input Type" of
              POSInfo."Input Type"::Text: begin
                while (Info = '') and not Cancelled do begin
                  Info := POSEventMarshaller.SearchBox(POSInfo.Message,POSInfo.Description,30);
                  if Info = '' then begin
                    Cancelled := not POSInfo."Input Mandatory";
                    if not Cancelled then
                      Cancelled := not POSEventMarshaller.Confirm(POSInfo.Description,StrSubstNo('%1.\%2',MustBeSpecified,ConfirmRetry));
                  end;
                end;
                if (Info = '') and POSInfo."Input Mandatory" then
                  Error('');
              end;

              POSInfo."Input Type"::Table: begin
                POSInfoLookupPage.SetPOSInfo(POSInfo);
                POSInfoLookupPage.LookupMode(true);
                if POSInfoLookupPage.RunModal = ACTION::LookupOK then begin
                  POSInfoLookupPage.GetRecord(POSInfoLookupTable);
                  RecRef.Open(POSInfo."Table No.");
                  RecRef.Get(POSInfoLookupTable.RecID);
                  Info := CreatePrimKeyString(RecRef);
                end;
              end;

              POSInfo."Input Type"::SubCode: begin
                POSInfoLookupPage.SetPOSInfo(POSInfo);
                POSInfoLookupPage.LookupMode(true);
                if POSInfoLookupPage.RunModal = ACTION::LookupOK then begin
                  POSInfoLookupPage.GetRecord(POSInfoLookupTable);
                  Info := POSInfoLookupTable."Field 1";
                end;
              end;
            end;

          POSInfo.Type::"Show Message",
          POSInfo.Type::"Write Default Message":
            Info := POSInfo.Message;
        end;
        //+NPR5.53 [388697]
        */
    end;

    local procedure SaleLineApplyPOSInfo(pSaleLinePos: Record "NPR Sale Line POS"; POSInfoTransParam: Record "NPR POS Info Transaction"; pApplicScope: Option " ","Current Line","All Lines","New Lines",Ask; pClearInfo: Boolean) FrontEndUpdateIsNeeded: Boolean
    var
        POSInfo: Record "NPR POS Info";
        POSInfoTransaction: Record "NPR POS Info Transaction";
        SaleLinePos2: Record "NPR Sale Line POS";
        SaleLinePosTmp: Record "NPR Sale Line POS" temporary;
    begin
        //-NPR5.53 [388697]
        FrontEndUpdateIsNeeded := false;
        if not POSInfoTransParam."Once per Transaction" and (pApplicScope in [pApplicScope::"Current Line", pApplicScope::"All Lines"]) then begin
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
        if POSInfoTransParam."Once per Transaction" or (pApplicScope in [pApplicScope::"All Lines", pApplicScope::"New Lines"]) then begin
            SaleLinePosTmp.Init;
            SaleLinePosTmp."Register No." := pSaleLinePos."Register No.";
            SaleLinePosTmp."Sales Ticket No." := pSaleLinePos."Sales Ticket No.";
            SaleLinePosTmp.Date := pSaleLinePos.Date;
            SaleLinePosTmp."Sale Type" := pSaleLinePos."Sale Type";
            SaleLinePosTmp.Type := SaleLinePosTmp.Type::Item;
            SaleLinePosTmp."Line No." := 0;
            SaleLinePosTmp.Insert;
        end;
        POSInfo.Get(POSInfoTransParam."POS Info Code");
        SetPosInfoTransactionFilters(POSInfoTransaction, pSaleLinePos, POSInfo, pApplicScope);
        if SaleLinePosTmp.FindSet then
            repeat
                POSInfoTransaction.SetRange("Sales Line No.", SaleLinePosTmp."Line No.");
                if POSInfoTransaction.FindFirst then begin
                    if pClearInfo then
                        POSInfoTransaction.Delete
                    else begin
                        POSInfoTransaction."POS Info" := POSInfoTransParam."POS Info";
                        POSInfoTransaction.Modify;
                    end;
                    FrontEndUpdateIsNeeded := true;
                end else
                    if not pClearInfo then begin
                        POSInfoTransaction.Init;
                        POSInfoTransaction."Register No." := SaleLinePosTmp."Register No.";
                        POSInfoTransaction."Sales Ticket No." := SaleLinePosTmp."Sales Ticket No.";
                        POSInfoTransaction."Sales Line No." := SaleLinePosTmp."Line No.";
                        POSInfoTransaction."Sale Date" := SaleLinePosTmp.Date;
                        POSInfoTransaction."Receipt Type" := SaleLinePosTmp.Type;
                        POSInfoTransaction."Entry No." := 0;
                        POSInfoTransaction."POS Info Code" := POSInfoTransParam."POS Info Code";
                        POSInfoTransaction."POS Info" := POSInfoTransParam."POS Info";
                        POSInfoTransaction."POS Info Type" := POSInfoTransParam."POS Info Type";
                        POSInfoTransaction."Once per Transaction" := POSInfoTransParam."Once per Transaction";
                        POSInfoTransaction.Insert(true);
                        FrontEndUpdateIsNeeded := true;
                    end;
            until SaleLinePosTmp.Next = 0;
        //+NPR5.53 [388697]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014407, 'OnAfterDebitSalePostEvent', '', true, true)]
    local procedure OnAfterDebitSalePostEvent(var Sender: Codeunit "NPR Sales Doc. Exp. Mgt."; SalePOS: Record "NPR Sale POS"; SalesHeader: Record "Sales Header"; Posted: Boolean; WriteInAuditRoll: Boolean)
    begin
        PostPOSInfo(SalePOS);
    end;

    procedure PostPOSInfo(PSalePos: Record "NPR Sale POS")
    var
        POSInfoTransaction: Record "NPR POS Info Transaction";
        POSInfoAuditRoll: Record "NPR POS Info Audit Roll";
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

    local procedure GetRecordFromPrimKeyString(pPOSInfoLookup: Record "NPR POS Info Lookup"; var pRecRef: RecordRef)
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

    procedure DeleteLine(SaleLinePOS: Record "NPR Sale Line POS")
    var
        POSInfoTransaction: Record "NPR POS Info Transaction";
    begin
        POSInfoTransaction.SetRange("Register No.", SaleLinePOS."Register No.");
        POSInfoTransaction.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        POSInfoTransaction.SetRange("Sales Line No.", SaleLinePOS."Line No.");
        POSInfoTransaction.DeleteAll;
    end;

    procedure RetrieveSavedLines(ToSalePOS: Record "NPR Sale POS"; FromSalePOS: Record "NPR Sale POS")
    var
        POSInfoTransactionOld: Record "NPR POS Info Transaction";
        POSInfoTransactionNew: Record "NPR POS Info Transaction";
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

    local procedure UpdatePOSInfoTransaction(var POSInfoTransaction: Record "NPR POS Info Transaction")
    var
        SaleLinePOS: Record "NPR Sale Line POS";
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

    procedure ProcessPOSInfoText(pSaleLinePos: Record "NPR Sale Line POS"; pSalePos: Record "NPR Sale POS"; pPOSInfoCode: Code[20]; pInfoText: Text)
    var
        POSInfo: Record "NPR POS Info";
        Info: Text;
        POSInfoTransaction: Record "NPR POS Info Transaction";
    begin
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
    end;

    procedure CopyPOSInfoTransFromHeader(SaleLinePos: Record "NPR Sale Line POS"; var POSInfoTransaction: Record "NPR POS Info Transaction"): Boolean
    var
        POSInfo: Record "NPR POS Info";
        POSInfoTransaction_Hdr: Record "NPR POS Info Transaction";
        Updated: Boolean;
    begin
        if not (SaleLinePos.Type in [SaleLinePos.Type::Item, SaleLinePos.Type::"Item Group", SaleLinePos.Type::"G/L Entry"]) or
          (SaleLinePos."Sale Type" = SaleLinePos."Sale Type"::Comment)
        then
            exit(false);

        POSInfoTransaction_Hdr.SetRange("Register No.", SaleLinePos."Register No.");
        POSInfoTransaction_Hdr.SetRange("Sales Ticket No.", SaleLinePos."Sales Ticket No.");
        POSInfoTransaction_Hdr.SetRange("Sales Line No.", 0);
        POSInfoTransaction_Hdr.SetFilter("POS Info Code", '<>%1', '');
        if not POSInfoTransaction_Hdr.FindSet then
            exit(false);

        Updated := false;
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
                    if not Updated then
                        Updated := true;
                end;
            end;
        until POSInfoTransaction_Hdr.Next = 0;
        POSInfoTransaction.Reset;
        exit(Updated);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150853, 'OnGetLineStyle', '', false, false)]
    local procedure FormatSaleLine_OnPOSInfoAssigment(var Color: Text; var Weight: Text; var Style: Text; SaleLinePOS: Record "NPR Sale Line POS"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSInfo: Record "NPR POS Info";
        POSInfoTransaction: Record "NPR POS Info Transaction";
        Found: Boolean;
    begin
        FilterPOSInfoTrans(POSInfoTransaction, '', SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.");
        Found := false;
        if POSInfoTransaction.FindSet then
            repeat
                if POSInfo.Get(POSInfoTransaction."POS Info Code") then
                    Found := POSInfo."Set POS Sale Line Color to Red";
            until (POSInfoTransaction.Next = 0) or Found;
        if Found then
            Color := 'red';
        POSSession.RequestRefreshData();
    end;

    local procedure FilterPOSInfoTrans(var POSInfoTransaction: Record "NPR POS Info Transaction"; POSInfoCode: Code[20]; RegisterNo: Code[10]; SalesTicketNo: Code[20]; LineNo: Integer)
    begin
        POSInfoTransaction.Reset;
        if POSInfoCode <> '' then
            POSInfoTransaction.SetRange("POS Info Code", POSInfoCode);
        POSInfoTransaction.SetRange("Register No.", RegisterNo);
        POSInfoTransaction.SetRange("Sales Ticket No.", SalesTicketNo);
        POSInfoTransaction.SetRange("Sales Line No.", LineNo);
    end;

    local procedure "--- DataSource Extension"()
    begin
    end;

    local procedure ThisDataSource(): Text
    begin
        exit('BUILTIN_SALE');
    end;

    local procedure ThisExtension(): Text
    begin
        exit('POS_INFO');
    end;

    local procedure DataSoucePOSInfoColumnName(POSInfoCode: Code[20]): Text
    begin
        exit(StrSubstNo('%1', POSInfoCode));
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDiscoverDataSourceExtensions', '', false, false)]
    local procedure OnDiscoverDataSourceExtension(DataSourceName: Text; Extensions: DotNet NPRNetList_Of_T)
    var
        POSInfo: Record "NPR POS Info";
    begin
        if ThisDataSource <> DataSourceName then
            exit;
        POSInfo.SetRange("Available in Front-End", true);
        if POSInfo.IsEmpty then
            exit;

        Extensions.Add(ThisExtension);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnGetDataSourceExtension', '', false, false)]
    local procedure OnGetDataSourceExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: DotNet NPRNetDataSource0; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        POSInfo: Record "NPR POS Info";
        DataType: DotNet NPRNetDataType;
    begin
        if (DataSourceName <> ThisDataSource) or (ExtensionName <> ThisExtension) then
            exit;

        Handled := true;

        POSInfo.SetRange("Available in Front-End", true);
        if not POSInfo.FindSet then
            exit;
        repeat
            DataSource.AddColumn(DataSoucePOSInfoColumnName(POSInfo.Code), StrSubstNo('POS Info: %1', POSInfo.Code), DataType.String, false);
        until POSInfo.Next = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150710, 'OnDataSourceExtensionReadData', '', false, false)]
    local procedure OnDataSourceExtensionReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: DotNet NPRNetDataRow0; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        POSInfo: Record "NPR POS Info";
        POSInfoTransaction: Record "NPR POS Info Transaction";
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        if (DataSourceName <> ThisDataSource) or (ExtensionName <> ThisExtension) then
            exit;

        Handled := true;

        POSInfo.SetRange("Available in Front-End", true);
        if not POSInfo.FindSet then
            exit;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        if SaleLinePOS."Line No." = 0 then begin  //new sale
            SaleLinePOS."Register No." := SalePOS."Register No.";
            SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
        end;

        repeat
            FilterPOSInfoTrans(POSInfoTransaction, POSInfo.Code, SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.");
            if POSInfoTransaction.IsEmpty then
                POSInfoTransaction.SetRange("Sales Line No.", 0);
            if not POSInfoTransaction.FindFirst then
                POSInfoTransaction.Init;
            DataRow.Add(DataSoucePOSInfoColumnName(POSInfo.Code), POSInfoTransaction."POS Info");
        until POSInfo.Next = 0;
    end;

    local procedure CallFrontEndUpdate()
    var
        POSFrontEndManagement: Codeunit "NPR POS Front End Management";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
    begin
        if POSSession.IsActiveSession(POSFrontEndManagement) then begin
            POSFrontEndManagement.GetSession(POSSession);
            POSSession.GetSale(POSSale);
            //POSSale.Modify(TRUE,TRUE);  //NPR5.53 [388697]-revoked
            POSSale.SetModified;  //NPR5.53 [388697]
            POSSession.RequestRefreshData();
        end;
    end;
}

