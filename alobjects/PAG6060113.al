page 6060113 "TM Ticket Make Reservation"
{
    // TM1.09/TSA /20160301  CASE 235860 Sell event tickets in POS
    // TM1.12/TSA /20160407  CASE 230600 Added DAN Captions
    // TM1.17/TSA /20160930  CASE 253951 Added the drill down on the fields for access to changing the times
    // TM1.20/NPKNAV/20170331  CASE 269171 Transport TM1.20 - 31 March 2017
    // TM1.21/ANEN /20170406 CASE 271150 Aplying filter with to-date on adm. sch. entries when selecting schedule
    // TM1.21/TSA /20170503  CASE 267611 Adding possibility to change quantity on the line
    //                                    - page changed to work on temp rec (to remove the locking issues)
    //                                    - the AquireTicketAdmissionSchedule function in 6060117 handles the actual change.
    //                                    - new function SetToken
    // TM1.22/TSA /20170526  CASE 278142 Added fields Customer No. and Payment Option visible for Ticket Batch Create Mode
    // TM1.23/TSA /20170703  CASE 282137 Cancelled lines must be respected when handling override capacity
    // TM1.28/TSA /20180220  CASE 305707 Added func SetTicketItem to be able to show ticket calendar exceptions
    // TM1.33/TSA /20180528 CASE 316195 Place cursor on first record in event selection
    // TM1.38/TSA /20181012 CASE 332109 Added Deliver Ticket To field
    // TM1.38/TSA /20181018 CASE 331917 Changed PageType on page 6060112
    // TM1.38.01/TSA /20181012 CASE 332109 Missplaced code section
    // TM1.39/TS  /20181206 CASE 343939 Added Missing Picture to Action
    // TM1.42/ALST/20190718 CASE 362158 made the page of type list to be compatible with mobile app
    // TM1.43/ALST/20191015 CASE 362158 reverted 1.42, page is now back to worksheet
    // TM1.44/ALST/20191016 CASE 362158 made the page of type listPlus to be compatible with mobile app and avoid extra click situation on open

    Caption = 'Make your reservation';
    DataCaptionExpression = StrSubstNo ('%1  - %2', Today, Time);
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPlus;
    SourceTable = "TM Ticket Reservation Request";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Item Code";"External Item Code")
                {
                    Caption = 'Item No.';
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = gVisualQueueUnfavorable;
                }
                field("Customer No.";"Customer No.")
                {
                    Visible = gBatchTicketCreateMode;

                    trigger OnValidate()
                    begin

                        ModifyAll ("Customer No.", "Customer No.");
                        CurrPage.Update (false);
                    end;
                }
                field("External Order No.";"External Order No.")
                {
                    Visible = gBatchTicketCreateMode;

                    trigger OnValidate()
                    begin

                        ModifyAll ("External Order No.", "External Order No.");
                        CurrPage.Update (false);
                    end;
                }
                field("Payment Option";"Payment Option")
                {
                    Visible = false;

                    trigger OnValidate()
                    begin

                        ModifyAll ("Payment Option", "Payment Option");
                        CurrPage.Update (false);
                    end;
                }
                field("Admission Code";"Admission Code")
                {
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = gVisualQueueUnfavorable;

                    trigger OnDrillDown()
                    begin

                        SelectSchedule ();
                        CurrPage.Update (false);
                    end;
                }
                field("Admission Description";"Admission Description")
                {
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = gVisualQueueUnfavorable;

                    trigger OnDrillDown()
                    begin
                        SelectSchedule ();
                        CurrPage.Update (false);
                    end;
                }
                field(Quantity;Quantity)
                {
                    Editable = gAllowQuantityChange;
                    Style = Unfavorable;
                    StyleExpr = gVisualQueueUnfavorable;

                    trigger OnValidate()
                    var
                        TicketRequestManager: Codeunit "TM Ticket Request Manager";
                        ResponseMessage: Text;
                    begin

                        if (Quantity < 1) then
                          Error (QTY_MUST_BE_GT_ZERO);

                        if (xRec.Quantity <> Quantity) then
                          ChangeQuantity (Quantity);

                        CurrPage.Update (false);
                    end;
                }
                field("Scheduled Time Description";"Scheduled Time Description")
                {
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = gVisualQueueUnfavorable;

                    trigger OnDrillDown()
                    begin

                        SelectSchedule ();
                        CurrPage.Update (false);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        SelectSchedule ();
                        CurrPage.Update (false);
                    end;
                }
            }
            group(Control6014406)
            {
                ShowCaption = false;
                Visible = gShowDeliverTo;
                field(gDeliverTicketTo;gDeliverTicketTo)
                {
                    Caption = 'Deliver eTicket To';
                }
            }
            group(Control6014400)
            {
                ShowCaption = false;
                field(gConfirmStatusText;gConfirmStatusText)
                {
                    Caption = 'Reservation Confirm Status';
                    Enabled = false;
                    Style = Favorable;
                    StyleExpr = gConfirmStatusStyleFavorable;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Select Schedule")
            {
                Caption = 'Select Schedule';
                Image = ChangeDate;
                Promoted = true;
                PromotedIsBig = true;

                trigger OnAction()
                begin

                    SelectSchedule ();
                    CurrPage.Update (false);
                end;
            }
            action("Update Schedule")
            {
                Caption = 'Update Schedule';
                Image = "Action";

                trigger OnAction()
                var
                    AdmissionSchManagement: Codeunit "TM Admission Sch. Management";
                begin
                    AdmissionSchManagement.CreateAdmissionSchedule ("Admission Code", false, Today);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        gVisualQueueUnfavorable := CalcVisualQueueUnfavorable (Rec);


        gConfirmStatusStyleFavorable := (not gVisualQueueUnfavorable);

        if (gConfirmStatusStyleFavorable) then
          if (gReservationEdited) then
            gConfirmStatusText := STATUS_UNCONFIRMED
          else
            gConfirmStatusText := STATUS_CONFIRMED;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin

        if (CloseAction = ACTION::LookupOK) then begin

          if (gBatchTicketCreateMode) then
            if ("Payment Option" <> "Payment Option"::DIRECT) then begin
              TestField ("External Order No.");
              TestField ("Customer No.");
            end;
        end;

        exit (true);
    end;

    var
        gVisualQueueUnfavorable: Boolean;
        gConfirmStatusText: Text;
        gConfirmStatusStyleFavorable: Boolean;
        gReservationEdited: Boolean;
        gQuantityChanged: Boolean;
        gAllowQuantityChange: Boolean;
        gRequestToken: Text[100];
        STATUS_CONFIRMED: Label 'The reservation is confirmed.';
        STATUS_UNCONFIRMED: Label 'Ticket is unconfirmed. Press OK to confirm new reservation.';
        QTY_MUST_BE_GT_ZERO: Label 'Ticket quantity must be greater than zero.';
        gBatchTicketCreateMode: Boolean;
        gTicketItemNo: Code[20];
        gTicketVariantCode: Code[10];
        gDeliverTicketTo: Text;
        gShowDeliverTo: Boolean;

    local procedure ChangeQuantity(NewQuantity: Integer)
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        ResponseMessage: Text;
    begin

        gReservationEdited := true;
        gQuantityChanged := true;
        ModifyAll (Quantity, NewQuantity);
    end;

    local procedure SelectSchedule()
    var
        PageScheduleEntry: Page "TM Ticket Select Schedule";
        AdmissionScheduleEntry: Record "TM Admission Schedule Entry";
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        PageAction: Action;
        OldEntryNo: Integer;
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        ResponseMessage: Text;
        TMAdmission: Record "TM Admission";
        "0DF": DateFormula;
        ToDate: Date;
    begin

        //AdmissionScheduleEntry.FILTERGROUP (2);
        AdmissionScheduleEntry.SetFilter ("Admission Code", '=%1', "Admission Code");
        AdmissionScheduleEntry.SetFilter ("Admission Start Date", '>=%1', Today);
        AdmissionScheduleEntry.SetFilter ("Admission Is", '=%1', AdmissionScheduleEntry."Admission Is"::OPEN);
        AdmissionScheduleEntry.SetFilter (Cancelled, '=%1', false);

        //-TM1.21
        //Selecting end range for from-date
        if TMAdmission.Get("Admission Code") then begin
          if TMAdmission."POS Schedule Selection Date F." <> "0DF" then begin
            ToDate := CalcDate (TMAdmission."POS Schedule Selection Date F.", Today);
            AdmissionScheduleEntry.SetRange ("Admission Start Date", Today, ToDate);
          end;
        end;
        //-TM1.21

        Clear (PageScheduleEntry);
        PageScheduleEntry.FillPage (AdmissionScheduleEntry, Quantity, gTicketItemNo, gTicketVariantCode);
        PageScheduleEntry.LookupMode (true);
        PageAction := PageScheduleEntry.RunModal ();

        //-TM1.38 [331917]
        //IF (PageAction = ACTION::Yes) THEN BEGIN
        if ((PageAction = ACTION::Yes) or (PageAction = ACTION::LookupOK)) then begin
        //+TM1.38 [331917]
          OldEntryNo := "External Adm. Sch. Entry No.";
          PageScheduleEntry.GetRecord (AdmissionScheduleEntry);
          "External Adm. Sch. Entry No." := AdmissionScheduleEntry."External Schedule Entry No.";
          "Scheduled Time Description" := StrSubstNo ('%1 - %2', AdmissionScheduleEntry."Admission Start Date", AdmissionScheduleEntry."Admission Start Time");
          Modify ();

          if (OldEntryNo <> "External Adm. Sch. Entry No.") then begin
            gReservationEdited := true;

        //    TicketRequestManager.DeleteReservationRequest (Rec."Session Token ID", FALSE);
        //    TicketRequestManager.IssueTicketFromReservationToken (Rec."Session Token ID", TRUE, ResponseMessage);
          end;

        end else begin
          // "External Adm. Sch. Entry No." := 0;
          // "Scheduled Time Description" := '';
        end;
    end;

    local procedure CalcVisualQueueUnfavorable(TicketReservationRequest: Record "TM Ticket Reservation Request"): Boolean
    var
        AdmissionSchEntry: Record "TM Admission Schedule Entry";
        Admission: Record "TM Admission";
        ScheduleLine: Record "TM Admission Schedule Lines";
        TicketManagement: Codeunit "TM Ticket Management";
        CapacityControl: Option;
        MaxCapacity: Integer;
        Remaining: Integer;
        ResponseMessage: Text;
    begin

        gConfirmStatusText := '';

        if (TicketReservationRequest."External Adm. Sch. Entry No." <= 0) then
          exit (true);

        if (TicketReservationRequest."External Adm. Sch. Entry No." > 0) then begin
          AdmissionSchEntry.SetFilter ("External Schedule Entry No.", '=%1', TicketReservationRequest."External Adm. Sch. Entry No.");
          //-TM1.23 [282137]
          AdmissionSchEntry.SetFilter (Cancelled, '=%1', false);
          //+TM1.23 [282137]

          if (AdmissionSchEntry.FindFirst ()) then begin
            AdmissionSchEntry.CalcFields ("Open Reservations", "Open Admitted", "Initial Entry");
            ScheduleLine.Get (AdmissionSchEntry."Admission Code", AdmissionSchEntry."Schedule Code");

            //-TM1.28 [305707]
            if (TicketManagement.CheckTicketBaseCalendar (false, TicketReservationRequest."Admission Code", gTicketItemNo, gTicketVariantCode, AdmissionSchEntry."Admission Start Date", ResponseMessage) <> 0) then begin
              gConfirmStatusText := ResponseMessage;
              exit (true);
            end;
            //+TM1.28 [305707]


            //-TM1.20 [269171]
            TicketManagement.GetMaxCapacity (AdmissionSchEntry."Admission Code", AdmissionSchEntry."Schedule Code", AdmissionSchEntry."Entry No.", MaxCapacity, CapacityControl);

            case CapacityControl of
              Admission."Capacity Control"::ADMITTED : Remaining := MaxCapacity - AdmissionSchEntry."Open Admitted" - AdmissionSchEntry."Open Reservations";
              Admission."Capacity Control"::FULL : Remaining :=  MaxCapacity - AdmissionSchEntry."Open Admitted" - AdmissionSchEntry."Open Reservations";
              Admission."Capacity Control"::NONE : exit (false);
              Admission."Capacity Control"::SALES : Remaining := MaxCapacity - AdmissionSchEntry."Initial Entry";
            end;
            //IF ((ScheduleLine."Max Capacity Per Sch. Entry" - AdmissionSchEntry."Open Reservations" - AdmissionSchEntry."Open Admitted") < TicketReservationRequest.Quantity) THEN
            //  EXIT (TRUE);
            exit (Remaining < TicketReservationRequest.Quantity);
            //+TM1.20 [269171]
          end;
        end;

        exit (false);
    end;

    procedure LoadTicketRequest(Token: Text[100])
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
    begin

        TicketReservationRequest.SetFilter ("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindSet ()) then begin
          //-TM1.38 [332109]
          gDeliverTicketTo := TicketReservationRequest."Notification Address";
          //+TM1.38 [332109]

          repeat
            TransferFields (TicketReservationRequest, true);
            Insert ();

          until (TicketReservationRequest.Next () = 0);
        end;
        gReservationEdited := false;
        gBatchTicketCreateMode := (Rec."Payment Option" <> Rec."Payment Option"::DIRECT);
    end;

    procedure SetTicketItem(ItemNo: Code[20];VariantCode: Code[10])
    var
        Item: Record Item;
        TicketType: Record "TM Ticket Type";
    begin
        gTicketItemNo := ItemNo;
        gTicketVariantCode := VariantCode;

        //-TM1.38 [332109]
        if (Item.Get (ItemNo)) then
          if (TicketType.Get (Item."Ticket Type")) then
            gShowDeliverTo := TicketType."eTicket Activated";
        //+TM1.38 [332109]
    end;

    procedure AllowQuantityChange(AllowQuantityChange: Boolean)
    begin
        gAllowQuantityChange := AllowQuantityChange;
    end;

    procedure FinalizeReservationRequest(FailWithError: Boolean;var ResponseMessage: Text): Integer
    var
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        TicketReservationRequest: Record "TM Ticket Reservation Request";
    begin

        //-TM1.38 [332109]
        if (gDeliverTicketTo <> '') then begin
          Rec.Reset;
          if (Rec.FindFirst ()) then ;
          repeat
            TicketReservationRequest.Get (Rec."Entry No.");

            TicketReservationRequest."Notification Address" := gDeliverTicketTo;
            if (StrPos (gDeliverTicketTo, '@') > 0) then
              TicketReservationRequest."Notification Method" := TicketReservationRequest."Notification Method"::EMAIL
            else
              TicketReservationRequest."Notification Method" := TicketReservationRequest."Notification Method"::SMS;

            TicketReservationRequest.Modify ();
          until (Rec.Next () = 0);
        end;
        //+TM1.38 [332109]

        if (gReservationEdited) then begin
          TicketRequestManager.DeleteReservationRequest (Rec."Session Token ID", false);

          Rec.Reset;
          if (Rec.FindFirst ()) then ; //+-TM1.33 [316195]
          repeat
            TicketReservationRequest.Get (Rec."Entry No.");
            TicketReservationRequest.Quantity := Rec.Quantity;
            TicketReservationRequest."External Adm. Sch. Entry No." := Rec."External Adm. Sch. Entry No.";
            TicketReservationRequest."Scheduled Time Description" := Rec."Scheduled Time Description";
            if (gBatchTicketCreateMode) then begin
              TicketReservationRequest."External Order No." := Rec."External Order No.";
              TicketReservationRequest."Payment Option" := Rec."Payment Option";
              TicketReservationRequest."Customer No." := Rec."Customer No.";
            end;

            TicketReservationRequest.Modify ();
          until (Rec.Next () = 0);
          TicketRequestManager.SetShowProgressBar (gBatchTicketCreateMode);
          exit (TicketRequestManager.IssueTicketFromReservationToken (Rec."Session Token ID", FailWithError, ResponseMessage));
        end;

        exit (0);
    end;

    procedure GetChangedTicketQuantity(var NewQuantity: Integer) QtyChanged: Boolean
    begin

        if (Rec.FindFirst ()) then
          NewQuantity := Rec.Quantity;

        exit (gQuantityChanged);
    end;

    procedure SetTicketBatchMode()
    begin
        gBatchTicketCreateMode := true;
    end;
}

