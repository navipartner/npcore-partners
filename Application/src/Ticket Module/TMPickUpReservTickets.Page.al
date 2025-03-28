﻿page 6060095 "NPR TM Pick-Up Reserv. Tickets"
{
    Extensible = False;

    Caption = 'Pick-Up Reserved Tickets';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR TM Ticket Reservation Req.";
    SourceTableView = SORTING("Entry No.") ORDER(Descending);
    UsageCategory = Tasks;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/intro/';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Order No."; Rec."External Order No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the External Order No. field';
                }
                field("Created Date Time"; Rec."Created Date Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Created Date Time field';
                }
                field("External Member No."; Rec."External Member No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the External Member No. field';
                }
                field("Request Status"; Rec."Request Status")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Request Status field';
                }
                field("Payment Option"; Rec."Payment Option")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Payment Option field';
                }
                field(TicketHolderName; Rec.TicketHolderName)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Holder Name field';
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
                field("Admission Code"; Rec."Admission Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field("Scheduled Time Description"; Rec."Scheduled Time Description")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Scheduled Time Description field';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field("External Ticket Number"; Rec."External Ticket Number")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the External Ticket Number field';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field(NPRAttrTextArray_01; NPRAttrTextArray[1])
                {
                    ApplicationArea = NPRTicketAdvanced;
                    CaptionClass = '6014555,6060116,1,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible01;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[1] field';

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetEntryAttributeValue(DATABASE::"NPR TM Ticket Reservation Req.", 1, Rec."Entry No.", NPRAttrTextArray[1]);
                    end;
                }
                field(NPRAttrTextArray_02; NPRAttrTextArray[2])
                {
                    ApplicationArea = NPRTicketAdvanced;
                    CaptionClass = '6014555,6060116,2,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible02;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[2] field';

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetEntryAttributeValue(DATABASE::"NPR TM Ticket Reservation Req.", 2, Rec."Entry No.", NPRAttrTextArray[2]);
                    end;
                }
                field(NPRAttrTextArray_03; NPRAttrTextArray[3])
                {
                    ApplicationArea = NPRTicketAdvanced;
                    CaptionClass = '6014555,6060116,3,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible03;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[3] field';

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetEntryAttributeValue(DATABASE::"NPR TM Ticket Reservation Req.", 3, Rec."Entry No.", NPRAttrTextArray[3]);
                    end;
                }
                field(NPRAttrTextArray_04; NPRAttrTextArray[4])
                {
                    ApplicationArea = NPRTicketAdvanced;
                    CaptionClass = '6014555,6060116,4,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible04;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[4] field';

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetEntryAttributeValue(DATABASE::"NPR TM Ticket Reservation Req.", 4, Rec."Entry No.", NPRAttrTextArray[4]);
                    end;
                }
                field(NPRAttrTextArray_05; NPRAttrTextArray[5])
                {
                    ApplicationArea = NPRTicketAdvanced;
                    CaptionClass = '6014555,6060116,5,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible05;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[5] field';

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetEntryAttributeValue(DATABASE::"NPR TM Ticket Reservation Req.", 5, Rec."Entry No.", NPRAttrTextArray[5]);
                    end;
                }
                field(NPRAttrTextArray_06; NPRAttrTextArray[6])
                {
                    ApplicationArea = NPRTicketAdvanced;
                    CaptionClass = '6014555,6060116,6,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible06;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[6] field';

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetEntryAttributeValue(DATABASE::"NPR TM Ticket Reservation Req.", 6, Rec."Entry No.", NPRAttrTextArray[6]);
                    end;
                }
                field(NPRAttrTextArray_07; NPRAttrTextArray[7])
                {
                    ApplicationArea = NPRTicketAdvanced;
                    CaptionClass = '6014555,6060116,7,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible07;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[7] field';

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetEntryAttributeValue(DATABASE::"NPR TM Ticket Reservation Req.", 7, Rec."Entry No.", NPRAttrTextArray[7]);
                    end;
                }
                field(NPRAttrTextArray_08; NPRAttrTextArray[8])
                {
                    ApplicationArea = NPRTicketAdvanced;
                    CaptionClass = '6014555,6060116,8,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible08;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[8] field';

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetEntryAttributeValue(DATABASE::"NPR TM Ticket Reservation Req.", 8, Rec."Entry No.", NPRAttrTextArray[8]);
                    end;
                }
                field(NPRAttrTextArray_09; NPRAttrTextArray[9])
                {
                    ApplicationArea = NPRTicketAdvanced;
                    CaptionClass = '6014555,6060116,9,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible09;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[9] field';

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetEntryAttributeValue(DATABASE::"NPR TM Ticket Reservation Req.", 9, Rec."Entry No.", NPRAttrTextArray[9]);
                    end;
                }
                field(NPRAttrTextArray_10; NPRAttrTextArray[10])
                {
                    ApplicationArea = NPRTicketAdvanced;
                    CaptionClass = '6014555,6060116,10,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible10;
                    ToolTip = 'Specifies the value of the NPRAttrTextArray[10] field';

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetEntryAttributeValue(DATABASE::"NPR TM Ticket Reservation Req.", 10, Rec."Entry No.", NPRAttrTextArray[10]);
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Confirm & Print")
            {
                ToolTip = 'Confirm and print ticket reservation.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Confirm & Print';
                Image = Confirm;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    ConfirmAndPrint();
                end;
            }

            action(PostPay)
            {
                ToolTip = 'Mark ticket to be post paid.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Postpaid';
                Image = Payment;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    MarkAsPostPaid();
                end;
            }
            action(Print)
            {
                ToolTip = 'Print reservation.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Print';
                Image = Print;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    PrintTicket();
                end;
            }

            action(ListTickets)
            {
                ToolTip = 'Navigate to Ticket List';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'List Tickets';
                Image = Navigate;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                RunObject = Page "NPR TM Ticket List";
                RunPageLink = "Ticket Reservation Entry No." = FIELD("Entry No.");
            }
        }
    }

    trigger OnAfterGetRecord()
    begin

        NPRAttrManagement.GetEntryAttributeValue(NPRAttrTextArray, DATABASE::"NPR TM Ticket Reservation Req.", Rec."Entry No.");
        NPRAttrEditable := CurrPage.Editable();
    end;

    trigger OnOpenPage()
    begin

        Rec.FilterGroup(2);
        Rec.SetFilter("Request Status", '=%1|=%2', Rec."Request Status"::CONFIRMED, Rec."Request Status"::RESERVED);
        Rec.FilterGroup(0);
        Rec.FindFirst();

        NPRAttrManagement.GetAttributeVisibility(DATABASE::"NPR TM Ticket Reservation Req.", NPRAttrVisibleArray);
        NPRAttrVisible01 := NPRAttrVisibleArray[1];
        NPRAttrVisible02 := NPRAttrVisibleArray[2];
        NPRAttrVisible03 := NPRAttrVisibleArray[3];
        NPRAttrVisible04 := NPRAttrVisibleArray[4];
        NPRAttrVisible05 := NPRAttrVisibleArray[5];
        NPRAttrVisible06 := NPRAttrVisibleArray[6];
        NPRAttrVisible07 := NPRAttrVisibleArray[7];
        NPRAttrVisible08 := NPRAttrVisibleArray[8];
        NPRAttrVisible09 := NPRAttrVisibleArray[9];
        NPRAttrVisible10 := NPRAttrVisibleArray[10];

        NPRAttrEditable := CurrPage.Editable();
    end;

    var
        NOT_PAID: Label 'Ticket %1 has not been paid yet.';
        TICKET_IS_PAID: Label 'Ticket %1 has been paid.';
        NPRAttrTextArray: array[40] of Text[250];
        NPRAttrManagement: Codeunit "NPR Attribute Management";
        NPRAttrEditable: Boolean;
        NPRAttrVisibleArray: array[40] of Boolean;
        NPRAttrVisible01: Boolean;
        NPRAttrVisible02: Boolean;
        NPRAttrVisible03: Boolean;
        NPRAttrVisible04: Boolean;
        NPRAttrVisible05: Boolean;
        NPRAttrVisible06: Boolean;
        NPRAttrVisible07: Boolean;
        NPRAttrVisible08: Boolean;
        NPRAttrVisible09: Boolean;
        NPRAttrVisible10: Boolean;

    local procedure ConfirmAndPrint()
    begin
        Rec.TestField("Admission Created", true);
        if (Rec."Payment Option" = Rec."Payment Option"::UNPAID) then
            Error(NOT_PAID, Rec."External Ticket Number");

        if (Rec."Request Status" = Rec."Request Status"::RESERVED) then
            Rec."Request Status" := Rec."Request Status"::CONFIRMED;

        PrintTicket();
        CurrPage.Update(true);
    end;

    local procedure MarkAsPostPaid()
    begin
        if (Rec."Payment Option" = Rec."Payment Option"::DIRECT) then
            Error(TICKET_IS_PAID, Rec."External Ticket Number");

        Rec.TestField("Customer No.");
        Rec.TestField("External Order No.");
        Rec."Payment Option" := Rec."Payment Option"::POSTPAID;
        Rec."Request Status" := Rec."Request Status"::CONFIRMED;
        CurrPage.Update(true);
    end;

    local procedure PrintTicket()
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
        Ticket: Record "NPR TM Ticket";
    begin

        Rec.TestField("Admission Created", true);
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', Rec."Entry No.");
        Ticket.FindFirst();

        if (TicketManagement.PrintSingleTicket(Ticket)) then begin
            Ticket."Printed Date" := Today();
            Ticket.Modify();
        end;
    end;
}

