page 6150665 "NPRE Seating"
{
    // NPR5.34/ANEN  /2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.34/ANEN  /20170717  CASE 262628 Added support for status (fld "Status", "Status Description")
    // NPR5.35/ANEN /20170821 CASE 283376 Solution rename to NP Restaurant

    Caption = 'Seating';
    PageType = Card;
    SourceTable = "NPRE Seating";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Seating Location";"Seating Location")
                {
                }
            }
            group("Capasity Tab")
            {
                Caption = 'Capasity';
                field("Fixed Capasity";"Fixed Capasity")
                {
                }
                field(Capacity;Capacity)
                {
                }
            }
            group(StatusGr)
            {
                Caption = 'Status';
                field(Status;Status)
                {
                }
                field("Status Description FF";"Status Description FF")
                {
                    Editable = false;
                }
            }
            group("Current Acvtivity")
            {
                Caption = 'Current Acvtivity';
                field("Current Waiter Pad FF";"Current Waiter Pad FF")
                {
                    Editable = false;
                }
                field("Multiple Waiter Pad FF";"Multiple Waiter Pad FF")
                {
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
        }
    }

    local procedure ActionViewLinkedWaiterPad()
    var
        SeatingWaiterPadLinkPage: Page "NPRE Seating - Waiter Pad Link";
        SeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link";
    begin
        SeatingWaiterPadLink.Reset;
        SeatingWaiterPadLink.SetRange("Seating Code", Rec.Code);

        Clear(SeatingWaiterPadLinkPage);
        SeatingWaiterPadLinkPage.SetTableView(SeatingWaiterPadLink);
        SeatingWaiterPadLinkPage.RunModal;
    end;

    local procedure ActionAddWaiterPad()
    var
        WaiterPadList: Page "NPRE Waiter Pad List";
        WaiterPad: Record "NPRE Waiter Pad";
        WaiterPadManagement: Codeunit "NPRE Waiter Pad Management";
    begin
        //Get a waiter pad to add to seating
        Clear(WaiterPadList);
        WaiterPad.Reset;
        WaiterPadList.SetTableView(WaiterPad);
        WaiterPadList.LookupMode(true);
        WaiterPadList.Editable(false);
        if WaiterPadList.RunModal = ACTION::LookupOK then begin
          WaiterPadList.GetRecord(WaiterPad);
          WaiterPadManagement.LinkSeatingToWaiterPad(WaiterPad."No.", Rec.Code);
        end;
    end;
}

