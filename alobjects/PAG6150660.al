page 6150660 "NPRE Waiter Pad"
{
    // NPR5.34/ANEN  /2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.34/ANEN  /20170717  CASE 262628 Added support for status (fld "Status", "Status Description")
    // NPR5.35/ANEN /20170821 CASE 283376 Solution rename to NP Restaurant

    Caption = 'Waiter Pad';
    DelayedInsert = true;
    PageType = Document;
    SourceTable = "NPRE Waiter Pad";

    layout
    {
        area(content)
        {
            field("Start Time";"Start Time")
            {
                Caption = 'Opened';
                Editable = false;
            }
            field("Current Seating FF";"Current Seating FF")
            {
                Caption = 'Seating';
                Editable = false;
            }
            field("Current Seating Description";"Current Seating Description")
            {
                Editable = false;
            }
            field(Description;Description)
            {
            }
            field(Status;Status)
            {
            }
            field("Status Description FF";"Status Description FF")
            {
                Editable = false;
            }
            part(Control6014405;"NPRE Waiter Pad Subform")
            {
                SubPageLink = "Waiter Pad No."=FIELD("No.");
                UpdatePropagation = Both;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Print)
            {
                action("Send full to kitchen")
                {
                    Caption = 'Send full to kitchen';
                    Image = SendToMultiple;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        HospitalityPrint.PrintFullWaiterPadToKitchenPressed(Rec);
                    end;
                }
                action("Print Pre Receipt")
                {
                    Caption = 'Print Pre Receipt';
                    Image = PrintCheck;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        HospitalityPrint.PrintWaiterPadPreReceiptPressed(Rec);
                    end;
                }
                separator(Separator6014410)
                {
                }
            }
            group("Waiter pad")
            {
                Caption = 'Waiter pad';
                action("Move seating")
                {
                    Caption = 'Move seating';
                    Image = Change;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        NPHWaiterPadPOSManagement.MoveWaiterPadToNewSeatingUI(Rec);
                    end;
                }
                action("Merge waiter pad")
                {
                    Caption = 'Merge waiter pad';
                    Image = ChangeBatch;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        NPHWaiterPad: Page "NPRE Waiter Pad";
                    begin
                        if NPHWaiterPadPOSManagement.MergeWaiterPadUI(Rec) then begin
                          CurrPage.Close;
                        end;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        UpdateCurrentSeatingDescription;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        WaiterPadManagement.InsertWaiterPad(Rec, true);
    end;

    var
        WaiterPadManagement: Codeunit "NPRE Waiter Pad Management";
        HospitalityPrint: Codeunit "NPRE Restaurant Print";
        NPHWaiterPadPOSManagement: Codeunit "NPRE Waiter Pad POS Management";

    local procedure ActionViewLinkedSeating()
    var
        SeatingWaiterPadLinkPage: Page "NPRE Seating - Waiter Pad Link";
        SeatingWaiterPadLink: Record "NPRE Seating - Waiter Pad Link";
    begin
        SeatingWaiterPadLink.Reset;
        SeatingWaiterPadLink.SetRange("Waiter Pad No.", Rec."No.");

        Clear(SeatingWaiterPadLinkPage);
        SeatingWaiterPadLinkPage.SetTableView(SeatingWaiterPadLink);
        SeatingWaiterPadLinkPage.RunModal;
    end;

    local procedure ActionAddSeating()
    var
        SeatingList: Page "NPRE Seating List";
        Seating: Record "NPRE Seating";
        WaiterPadManagement: Codeunit "NPRE Waiter Pad Management";
    begin
        //Get a seating to add to waiter pad
        Clear(SeatingList);
        Seating.Reset;
        SeatingList.SetTableView(Seating);
        SeatingList.LookupMode(true);
        SeatingList.Editable(false);
        if SeatingList.RunModal = ACTION::LookupOK then begin
          SeatingList.GetRecord(Seating);
          WaiterPadManagement.LinkSeatingToWaiterPad(Rec."No.", Seating.Code);
        end;
    end;
}

