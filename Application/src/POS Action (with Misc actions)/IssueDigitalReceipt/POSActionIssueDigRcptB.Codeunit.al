codeunit 6060074 "NPR POS Action: IssueDigRcpt B"
{
    Access = Internal;

    internal procedure CreateDigitalReceipt(SalesTicketNo: Code[20]; var DigitalReceiptLink: Text; var FooterText: Text)
    var
        POSEntry: Record "NPR POS Entry";
        DigitalReceiptSetup: Record "NPR Digital Rcpt. Setup";
        TempPOSSaleDigitalReceiptEntry: Record "NPR POSSale Dig. Receipt Entry" temporary;
        FiskalyAPI: Codeunit "NPR Fiskaly API";
        SendAuthRequest: Boolean;
        BearerTokenValue: Text;
        ErrorText: Text;
        TokenExpiresAt: DateTime;
    begin
        DigitalReceiptSetup.SetLoadFields("Enable", "Bearer Token Value", "Bearer Token Expires At");
        if not DigitalReceiptSetup.Get() then
            exit;
        if not DigitalReceiptSetup."Enable" then
            exit;

        SendAuthRequest := true;
        POSEntry.Reset();
        POSEntry.SetRange("Document No.", SalesTicketNo);
        POSEntry.FindFirst();

        if not (POSEntry."Entry Type" in [POSEntry."Entry Type"::"Direct Sale", POSEntry."Entry Type"::"Cancelled Sale"]) then
            exit;

        if DigitalReceiptSetup."Bearer Token Value" <> '' then
            if CurrentDateTime() <= DigitalReceiptSetup."Bearer Token Expires At" then begin
                SendAuthRequest := false;
                BearerTokenValue := DigitalReceiptSetup."Bearer Token Value";
            end;

        if SendAuthRequest then begin
            if not FiskalyAPI.TryCallApiAuth(BearerTokenValue, TokenExpiresAt) then begin
                ErrorText := GetLastErrorText();
                Error(ErrorText);
            end;
            DigitalReceiptSetup."Bearer Token Value" := CopyStr(BearerTokenValue, 1, MaxStrLen(DigitalReceiptSetup."Bearer Token Value"));
            DigitalReceiptSetup."Bearer Token Expires At" := TokenExpiresAt;
            DigitalReceiptSetup.Modify();
        end;

        if not FiskalyAPI.TryCallApiPost(POSEntry, BearerTokenValue) then begin
            ErrorText := GetLastErrorText();
            Error(ErrorText);
        end;

        FiskalyAPI.GetResponseAsBuffer(POSEntry, TempPOSSaleDigitalReceiptEntry);
        FiskalyAPI.CreatePOSSaleDigitalReceiptEntry(TempPOSSaleDigitalReceiptEntry);

        DigitalReceiptLink := TempPOSSaleDigitalReceiptEntry."QR Code Link";
        if FooterText = '' then
            FooterText := SetFooterText();
    end;

    internal procedure CheckIfGlobalSetupEnabledAndCreateReceipt(SalesTicketNo: Code[20]; var DigitalReceiptLink: Text; var FooterText: Text)
    var
        DigitalReceiptSetup: Record "NPR Digital Rcpt. Setup";
        GlobalDigitalRcptNotEnabledErr: Label 'Global Digital Receipt Setup is not enabled. Please enable it to proceed with receipt generation.';
    begin
        DigitalReceiptSetup.SetLoadFields("Enable");
        DigitalReceiptSetup.Get();
        if not DigitalReceiptSetup."Enable" then
            Error(GlobalDigitalRcptNotEnabledErr);
        CreateDigitalReceipt(SalesTicketNo, DigitalReceiptLink, FooterText);
    end;

    internal procedure SetFooterText() FooterText: Text
    var
        FooterTextPlaceholderLabel: Label '<div style="text-align: center; margin-top: 10px">%1<a href="https://www.fiskaly.com/legal-terms-of-use" target="_blank">%2</a>%3</div>', Comment = '%1 - Main text placeholder, %2 - Terms placeholder, %3 - Conditons placeholder', Locked = true;
        FooterTextLbl: Label 'By using the digital receipt you agree to Fiskaly''s ';
        FooterTermsLbl: Label 'terms';
        FooterConditionsLbl: Label ' and conditions.';
    begin
        FooterText := StrSubstNo(FooterTextPlaceholderLabel, FooterTextLbl, FooterTermsLbl, FooterConditionsLbl);
    end;

    internal procedure CreateDigitalReceipt(POSEntry: Record "NPR POS Entry")
    var
        DigitalReceiptLink: Text;
        FooterText: Text;
    begin
        CreateDigitalReceipt(POSEntry."Document No.", DigitalReceiptLink, FooterText);
    end;
}
