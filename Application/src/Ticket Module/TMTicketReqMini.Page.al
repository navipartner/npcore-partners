page 6060101 "NPR TM Ticket Req. Mini"
{
    Caption = 'Ticket Request Mini';
    InsertAllowed = false;
    InstructionalText = 'Set quantity to the number of guest for each line';
    PageType = List;
    SourceTable = "NPR TM Ticket Reservation Req.";
    SourceTableTemporary = true;
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("External Item Code"; Rec."External Item Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the External Item Code field';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Quantity field';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Admission Code"; Rec."Admission Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field("Admission Description"; Rec."Admission Description")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Admission Description field';
                }
                field("Notification Method"; Rec."Notification Method")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Method field';
                }
                field("Notification Address"; Rec."Notification Address")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Address field';
                }
            }
        }
    }

    procedure FillRequestTable(var TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary)
    begin
        if TmpTicketReservationRequest.FindSet() then
            repeat
                Rec.TransferFields(TmpTicketReservationRequest, true);
                Rec.Insert();
            until (TmpTicketReservationRequest.Next() = 0);
    end;

    procedure GetTicketRequest(var TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary)
    begin
        Rec.Reset();
        if Rec.FindSet() then
            repeat
                TmpTicketReservationRequest.TransferFields(Rec, true);
                TmpTicketReservationRequest.Insert();
            until Rec.Next() = 0;
    end;
}

