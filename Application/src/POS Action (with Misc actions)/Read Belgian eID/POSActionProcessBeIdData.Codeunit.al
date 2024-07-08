codeunit 6184579 "NPR POS Action:ProcessBeIdData"
{
    Access = Internal;

    internal procedure ProcessCardData(POSStore: Record "NPR POS Store"; POSUnit: Record "NPR POS Unit"; SalePOS: Record "NPR POS Sale"; Salesperson: Record "Salesperson/Purchaser"; HwcResponse: JsonObject) Result: JsonObject
    var
        IsHandled: Boolean;
        ProcessBeId: Codeunit "NPR POS Action: Process BeId";
    begin
        ProcessBeId.OnProcessCardData(POSStore, POSUnit, SalePOS, Salesperson, HwcResponse, IsHandled, Result);

        if (not IsHandled) then begin
            Result.Add('ShowSuccessMessage', true);
            Result.Add('Success', true);
            Result.Add('Message', 'Processing of eID card not implemented!');
        end;
    end;
}