codeunit 6150935 "NPR UPG Rcpt. Profile"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        UpgTagDef: Codeunit "NPR UPG Rcpt. Profile Tag Def";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag()) then
            exit;

        // Run upgrade code
        Upgrade();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag());
    end;

    local procedure Upgrade()
    begin
        UpgradePOSUnitRcptTxtProfile();
        UpgradeCommentRcptTxtProfile();
    end;

    local procedure UpgradePOSUnitRcptTxtProfile()
    var
        POSUnitRcptTxtProfile: Record "NPR POS Unit Rcpt.Txt Profile";
        ReceiptFooterMgt: codeunit "NPR Receipt Footer Mgt.";
        DataTypeMgt: Codeunit "Data Type Management";
        ReceiptText: Text;
        FieldReference: array[9] of FieldRef;
        RecRef: RecordRef;
        i: Integer;
    begin
        POSUnitRcptTxtProfile.SetRange("Sales Ticket Line Text off", POSUnitRcptTxtProfile."Sales Ticket Line Text off"::"Pos Unit");
        if not POSUnitRcptTxtProfile.FindSet() then
            exit;
        repeat
            clear(ReceiptText);

            DataTypeMgt.GetRecordRef(POSUnitRcptTxtProfile, RecRef);
            for i := 1 to 9 do begin
                FindFieldByName(RecRef, FieldReference[i], 'Sales Ticket Line Text' + Format(i));
                if Format(FieldReference[i].Value()) <> '' then
                    ReceiptText += Format(FieldReference[i].Value()) + ' ';
            end;
            ReceiptFooterMgt.SetDefaultBreakLineNumberOfCharacters(POSUnitRcptTxtProfile);
            if ReceiptText <> '' then begin
                ReceiptText := CopyStr(ReceiptText, 1, StrLen(ReceiptText) - 1);
                POSUnitRcptTxtProfile."Sales Ticket Rcpt. Text" := ReceiptText;
            end;
            POSUnitRcptTxtProfile.Modify();
        until POSUnitRcptTxtProfile.Next() = 0;
    end;

    local procedure UpgradeCommentRcptTxtProfile()
    var
        RetailComment: Record "NPR Retail Comment";
        POSUnitRcptTxtProfile: Record "NPR POS Unit Rcpt.Txt Profile";
        ReceiptFooterMgt: codeunit "NPR Receipt Footer Mgt.";
        ReceiptText: Text;
    begin
        POSUnitRcptTxtProfile.SetRange("Sales Ticket Line Text off", POSUnitRcptTxtProfile."Sales Ticket Line Text off"::Comment);
        if not POSUnitRcptTxtProfile.FindSet() then
            exit;
        repeat
            clear(ReceiptText);
            RetailComment.Reset();
            RetailComment.SetRange("Table ID", DATABASE::"NPR POS Unit");
            RetailComment.SetRange("No.", POSUnitRcptTxtProfile.Code);
            RetailComment.SetRange(Integer, 1000);
            RetailComment.SetRange("Hide on printout", false);
            if RetailComment.FindSet() then begin
                ReceiptFooterMgt.SetDefaultBreakLineNumberOfCharacters(POSUnitRcptTxtProfile);
                repeat
                    ReceiptText += RetailComment.Comment + ' ';
                until RetailComment.next() = 0;
                if ReceiptText <> '' then begin
                    ReceiptText := CopyStr(ReceiptText, 1, StrLen(ReceiptText) - 1);
                    POSUnitRcptTxtProfile."Sales Ticket Rcpt. Text" := ReceiptText;
                end;
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

        if not Field.FindFirst then
            exit(false);

        FieldRef := RecordRef.Field(Field."No.");
        exit(true);
    end;
}