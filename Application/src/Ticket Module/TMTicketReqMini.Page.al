page 6060101 "NPR TM Ticket Req. Mini"
{
    // TM1.19/NPKNAV/20170309  CASE 266372 Transport TM1.19 - 8 March 2017
    // TM90.1.46/TSA /20200304 CASE 399138 Added a currpage update as changes did not "stick"

    Caption = 'Ticket Request Mini';
    InsertAllowed = false;
    InstructionalText = 'Set quantity to the number of guest for each line';
    PageType = ListPlus;
    SourceTable = "NPR TM Ticket Reservation Req.";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("External Item Code"; "External Item Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the External Item Code field';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Quantity field';

                    trigger OnValidate()
                    begin

                        //-#337112 [337112]
                        CurrPage.Update(true);
                        //+#337112 [337112]
                    end;
                }
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field("Admission Description"; "Admission Description")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Admission Description field';
                }
                field("Notification Method"; "Notification Method")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Method field';
                }
                field("Notification Address"; "Notification Address")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Address field';
                }
            }
        }
    }

    actions
    {
    }

    procedure FillRequestTable(var TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary)
    begin

        if (TmpTicketReservationRequest.FindSet()) then begin
            repeat
                TransferFields(TmpTicketReservationRequest, true);
                Insert();
            until (TmpTicketReservationRequest.Next() = 0);
        end;
    end;

    procedure GetTicketRequest(var TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary)
    begin

        Reset;
        if (FindSet()) then begin
            repeat
                TmpTicketReservationRequest.TransferFields(Rec, true);
                TmpTicketReservationRequest.Insert();
            until (Next() = 0);
        end;
    end;
}

