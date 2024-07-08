codeunit 6150935 "NPR UPG Rcpt. Profile"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Rcpt. Profile', 'OnUpgradePerCompany');

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Rcpt. Profile")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        // Run upgrade code
        Upgrade();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Rcpt. Profile"));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure Upgrade()
    begin
        UpgradePOSUnitRcptTxtProfile();
        UpgradeCommentRcptTxtProfile();
    end;

    local procedure UpgradePOSUnitRcptTxtProfile()
    var
        POSUnitRcptTxtProfile: Record "NPR POS Unit Rcpt.Txt Profile";
        POSTicketRcptText: Record "NPR POS Ticket Rcpt. Text";
        DataTypeMgt: Codeunit "Data Type Management";
        ReceiptText: Text;
        FieldReference: array[9] of FieldRef;
        RecRef: RecordRef;
        LineNo, i: Integer;
    begin
        POSUnitRcptTxtProfile.SetRange("Sales Ticket Line Text off", POSUnitRcptTxtProfile."Sales Ticket Line Text off"::"Pos Unit");
        if POSUnitRcptTxtProfile.FindSet(true) then
            repeat
                clear(ReceiptText);        
                LineNo := 0;        
                POSTicketRcptText.Reset();
                POSTicketRcptText.SetRange("Rcpt. Txt. Profile Code", POSUnitRcptTxtProfile.Code);
                if POSTicketRcptText.FindLast() then
                    LineNo := POSTicketRcptText."Line No.";

                DataTypeMgt.GetRecordRef(POSUnitRcptTxtProfile, RecRef);
                for i := 1 to 9 do begin
                    FindFieldByName(RecRef, FieldReference[i], 'Sales Ticket Line Text' + Format(i));
                    if Format(FieldReference[i].Value()) <> '' then begin
                        LineNo += 10000;
                        POSTicketRcptText."Rcpt. Txt. Profile Code" := POSUnitRcptTxtProfile.Code;
                        POSTicketRcptText."Line No." := LIneNo;
                        POSTicketRcptText.Init();
                        POSTicketRcptText."Receipt Text" := CopyStr(Format(FieldReference[i].Value()), 1, MaxStrLen(POSTicketRcptText."Receipt Text"));
                        POSTicketRcptText.Insert();
                    end;
                end;
                POSUnitRcptTxtProfile.Modify();
            until POSUnitRcptTxtProfile.Next() = 0;
    end;

    local procedure UpgradeCommentRcptTxtProfile()
    var
        RetailComment: Record "NPR Retail Comment";
        POSUnitRcptTxtProfile: Record "NPR POS Unit Rcpt.Txt Profile";
        POSTicketRcptText: Record "NPR POS Ticket Rcpt. Text";
        ReceiptText: Text;
        LineNo: Integer;
    begin
        POSUnitRcptTxtProfile.SetRange("Sales Ticket Line Text off", POSUnitRcptTxtProfile."Sales Ticket Line Text off"::Comment);
        if POSUnitRcptTxtProfile.FindSet(true) then
            repeat            
                clear(ReceiptText);
                LineNo := 0;                
                POSTicketRcptText.Reset();
                POSTicketRcptText.SetRange("Rcpt. Txt. Profile Code", POSUnitRcptTxtProfile.Code);
                if POSTicketRcptText.FindLast() then
                    LineNo := POSTicketRcptText."Line No.";

                RetailComment.Reset();
                RetailComment.SetRange("Table ID", DATABASE::"NPR POS Unit");
                RetailComment.SetRange("No.", POSUnitRcptTxtProfile.Code);
                RetailComment.SetRange(Integer, 1000);
                RetailComment.SetRange("Hide on printout", false);
                if RetailComment.FindSet() then begin
                    repeat
                        LineNo += 10000;
                        POSTicketRcptText."Rcpt. Txt. Profile Code" := POSUnitRcptTxtProfile.Code;
                        POSTicketRcptText."Line No." := LineNo;
                        POSTicketRcptText.Init();
                        POSTicketRcptText."Receipt Text" := CopyStr(RetailComment.Comment, 1, MaxStrLen(POSTicketRcptText."Receipt Text"));
                        POSTicketRcptText.Insert();                        
                    until RetailComment.next() = 0;
                    POSUnitRcptTxtProfile.Modify();
                end;
            until POSUnitRcptTxtProfile.Next() = 0;
    end;

    local procedure FindFieldByName(RecordRef: RecordRef; var FieldRef: FieldRef; FieldNameTxt: Text): Boolean
    var
        "Field": Record "Field";
    begin
        Field.SetRange(TableNo, RecordRef.Number);
        Field.SetFilter(ObsoleteState, '%1|%2', Field.ObsoleteState::Removed, Field.ObsoleteState::Pending);
        Field.SetRange(FieldName, FieldNameTxt);

        if not Field.FindFirst() then
            exit(false);

        FieldRef := RecordRef.Field(Field."No.");
        exit(true);
    end;
}
