codeunit 6060074 "NPR POS Action: IssueDigRcpt B"
{
    Access = Internal;

    internal procedure CreateDigitalReceipt(SalesTicketNo: Code[20]; var DigitalReceiptLink: Text; var FooterText: Text)
    var
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        POSReceiptProfile: Record "NPR POS Receipt Profile";
        DigitalReceiptSetup: Record "NPR Digital Receipt Setup";
        TempPOSSaleDigitalReceiptEntry: Record "NPR POSSaleDigitalReceiptEntry" temporary;
        FiskalyAPI: Codeunit "NPR Fiskaly API";
        SendAuthRequest: Boolean;
        BearerTokenValue: Text;
        ErrorText: Text;
        TokenExpiresAt: DateTime;
    begin
        SendAuthRequest := true;
        POSEntry.Reset();
        POSEntry.SetRange("Document No.", SalesTicketNo);
        POSEntry.FindFirst();

        POSUnit.SetLoadFields("POS Receipt Profile");
        if not POSUnit.Get(POSEntry."POS Unit No.") then
            exit;
        POSReceiptProfile.SetLoadFields("Enable Digital Receipt", "QRCode Time Interval Enabled", "QRCode Timeout Interval(sec.)");
        if not POSReceiptProfile.Get(POSUnit."POS Receipt Profile") then
            exit;
        if not POSReceiptProfile."Enable Digital Receipt" then
            exit;

        if not (POSEntry."Entry Type" in [POSEntry."Entry Type"::"Direct Sale", POSEntry."Entry Type"::"Cancelled Sale"]) then
            exit;

        DigitalReceiptSetup.SetLoadFields("Bearer Token Value", "Bearer Token Expires At");
        if (DigitalReceiptSetup.Get()) and (DigitalReceiptSetup."Bearer Token Value" <> '') then
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

    internal procedure SetFooterText() FooterText: Text
    var
        FooterTextPlaceholderLabel: Label '<div style="text-align: center; margin-top: 10px">%1<a href="https://www.fiskaly.com/legal-terms-of-use" target="_blank">%2</a>%3</div>', Comment = '%1 - Main text placeholder, %2 - Terms placeholder, %3 - Conditons placeholder', Locked = true;
        FooterTextLbl: Label 'By using the digital receipt you agree to Fiskaly''s ';
        FooterTermsLbl: Label 'terms';
        FooterConditionsLbl: Label ' and conditions.';
    begin
        FooterText := StrSubstNo(FooterTextPlaceholderLabel, FooterTextLbl, FooterTermsLbl, FooterConditionsLbl);
    end;
}
