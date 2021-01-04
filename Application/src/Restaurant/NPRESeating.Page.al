page 6150665 "NPR NPRE Seating"
{
    // NPR5.34/ANEN/2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.34/ANEN/20170717 CASE 262628 Added support for status (fld "Status", "Status Description")
    // NPR5.35/ANEN/20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.53/ALPO/20191210 CASE 380609 Dimensions: NPRE Seating integration
    // NPR5.55/ALPO/20200615 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale

    Caption = 'Seating';
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR NPRE Seating";

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
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Seating Location"; "Seating Location")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Seating Location field';
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field("Blocking Reason"; "Blocking Reason")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocking Reason field';
                }
            }
            group("Capasity Tab")
            {
                Caption = 'Capasity';
                field("Fixed Capasity"; "Fixed Capasity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Fixed Capasity field';
                }
                field(Capacity; Capacity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Capacity field';
                }
            }
            group(StatusGr)
            {
                Caption = 'Status';
                field(Status; Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Status Description FF"; "Status Description FF")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Status Description field';
                }
            }
            group("Current Acvtivity")
            {
                Caption = 'Current Acvtivity';
                field("Current Waiter Pad FF"; "Current Waiter Pad FF")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Current Waiter Pad field';
                }
                field("Multiple Waiter Pad FF"; "Multiple Waiter Pad FF")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Multiple Waiter Pad field';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Dimensions action';
                }
            }
        }
    }

    local procedure ActionViewLinkedWaiterPad()
    var
        SeatingWaiterPadLinkPage: Page "NPR NPRE Seat.: WaiterPadLink";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
    begin
        SeatingWaiterPadLink.Reset;
        SeatingWaiterPadLink.SetRange("Seating Code", Rec.Code);

        Clear(SeatingWaiterPadLinkPage);
        SeatingWaiterPadLinkPage.SetTableView(SeatingWaiterPadLink);
        SeatingWaiterPadLinkPage.RunModal;
    end;

    local procedure ActionAddWaiterPad()
    var
        WaiterPadList: Page "NPR NPRE Waiter Pad List";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadManagement: Codeunit "NPR NPRE Waiter Pad Mgt.";
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

