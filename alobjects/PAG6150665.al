page 6150665 "NPRE Seating"
{
    // NPR5.34/ANEN/2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.34/ANEN/20170717 CASE 262628 Added support for status (fld "Status", "Status Description")
    // NPR5.35/ANEN/20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.53/ALPO/20191210 CASE 380609 Dimensions: NPRE Seating integration
    // NPR5.55/ALPO/20200615 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale

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
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Seating Location"; "Seating Location")
                {
                    ApplicationArea = All;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                }
                field("Blocking Reason"; "Blocking Reason")
                {
                    ApplicationArea = All;
                }
            }
            group("Capasity Tab")
            {
                Caption = 'Capasity';
                field("Fixed Capasity"; "Fixed Capasity")
                {
                    ApplicationArea = All;
                }
                field(Capacity; Capacity)
                {
                    ApplicationArea = All;
                }
            }
            group(StatusGr)
            {
                Caption = 'Status';
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Status Description FF"; "Status Description FF")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            group("Current Acvtivity")
            {
                Caption = 'Current Acvtivity';
                field("Current Waiter Pad FF"; "Current Waiter Pad FF")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Multiple Waiter Pad FF"; "Multiple Waiter Pad FF")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Seating)
            {
                Caption = 'Seating';
                action(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID" = CONST(6150665),
                                  "No." = FIELD(Code);
                    ShortCutKey = 'Shift+Ctrl+D';
                }
            }
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

