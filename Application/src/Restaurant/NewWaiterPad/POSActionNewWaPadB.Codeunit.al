codeunit 6151346 "NPR POSAction New Wa. Pad-B"
{
    Access = Internal;

    procedure NewWaiterPad(Sale: Codeunit "NPR POS Sale"; SeatingCode: Code[20]; CustomerDetails: Dictionary of [Text, Text]; NumberOfGuests: Integer; OpenWaiterPad: Boolean; var ActionMessage: Text)
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        SalePOS: Record "NPR POS Sale";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        ActionMsgTxt: Label 'Waiter pad %1 has been created for seating %2.', Comment = '%1 - waiter pad number, %2 - seating description';
    begin
        Seating.Get(SeatingCode);
        if NumberOfGuests < 0 then
            NumberOfGuests := 0;

        Sale.GetCurrentSale(SalePOS);

        WaiterPadMgt.CreateNewWaiterPad(Seating.Code, NumberOfGuests, SalePOS."Salesperson Code", CustomerDetails, WaiterPad);

        SalePOS.Find();
        SalePOS."NPRE Number of Guests" := NumberOfGuests;
        SalePOS."NPRE Pre-Set Waiter Pad No." := WaiterPad."No.";
        SalePOS.Validate("NPRE Pre-Set Seating Code", SeatingCode);
        Sale.Refresh(SalePOS);
        Sale.Modify(true, false);
        Commit();

        if OpenWaiterPad then begin
            WaiterPadPOSMgt.UIShowWaiterPad(WaiterPad);
            exit;
        end;

        if Seating.Description = '' then
            if Seating."Seating No." <> '' then
                Seating.Description := Seating."Seating No."
            else
                Seating.Description := Seating.Code;
        ActionMessage := StrSubstNo(ActionMsgTxt, WaiterPad."No.", Seating.Description);
    end;

    procedure GetSeatingConfirmString(Seating: Record "NPR NPRE Seating") ConfirmString: Text
    var
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        ConfirmNewQst: Label 'There are the following active waiter pad(s) on seating %1:%2<br><br>Are you sure you want to create a new waiter pad for the seating?';
    begin
        SeatingWaiterPadLink.SetCurrentKey(Closed);
        SeatingWaiterPadLink.SetRange(Closed, false);
        SeatingWaiterPadLink.SetRange("Seating Code", Seating.Code);
        if SeatingWaiterPadLink.IsEmpty() then
            exit('');

        ConfirmString := '';
        SeatingWaiterPadLink.FindSet();
        repeat
            if WaiterPad.Get(SeatingWaiterPadLink."Waiter Pad No.") then begin
                ConfirmString += '<br>  - ' + WaiterPad."No.";
                ConfirmString += ' ' + Format(WaiterPad.SystemCreatedAt);
                if WaiterPad.Description <> '' then
                    ConfirmString += ' ' + WaiterPad.Description;
            end;
        until SeatingWaiterPadLink.Next() = 0;
        ConfirmString := StrSubstNo(ConfirmNewQst, Seating.Code, ConfirmString);

        exit(ConfirmString);
    end;
}