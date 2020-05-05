page 6060101 "TM Ticket Request Mini"
{
    // TM1.19/NPKNAV/20170309  CASE 266372 Transport TM1.19 - 8 March 2017
    // TM90.1.46/TSA /20200304 CASE 399138 Added a currpage update as changes did not "stick"

    Caption = 'Ticket Request Mini';
    InsertAllowed = false;
    InstructionalText = 'Set quantity to the number of guest for each line';
    PageType = ListPlus;
    SourceTable = "TM Ticket Reservation Request";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("External Item Code";"External Item Code")
                {
                    Editable = false;
                }
                field(Quantity;Quantity)
                {

                    trigger OnValidate()
                    begin

                        //-#337112 [337112]
                        CurrPage.Update (true);
                        //+#337112 [337112]
                    end;
                }
                field("Admission Code";"Admission Code")
                {
                    Editable = false;
                }
                field("Admission Description";"Admission Description")
                {
                    Editable = false;
                }
                field("Notification Method";"Notification Method")
                {
                }
                field("Notification Address";"Notification Address")
                {
                }
            }
        }
    }

    actions
    {
    }

    procedure FillRequestTable(var TmpTicketReservationRequest: Record "TM Ticket Reservation Request" temporary)
    begin

        if (TmpTicketReservationRequest.FindSet ()) then begin
          repeat
            TransferFields (TmpTicketReservationRequest, true);
            Insert ();
          until (TmpTicketReservationRequest.Next () = 0);
        end;
    end;

    procedure GetTicketRequest(var TmpTicketReservationRequest: Record "TM Ticket Reservation Request" temporary)
    begin

        Reset;
        if (FindSet ()) then begin
          repeat
            TmpTicketReservationRequest.TransferFields (Rec, true);
            TmpTicketReservationRequest.Insert ();
          until (Next () = 0);
        end;
    end;
}

