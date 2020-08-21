page 6060095 "TM Pick-Up Reserved Tickets"
{
    // TM1.23/TSA /20170717 CASE 284248 Initial Version
    // TM1.25/TSA /20171003 CASE 286397 Added Client Attributes to list
    // #334163/JDH /20181109 CASE 334163 Added Caption to Actions and the object
    // TM1.39/NPKNAV/20190125  CASE 343941 Transport TM1.39 - 25 January 2019

    Caption = 'TM Pick-Up Reserved Tickets';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "TM Ticket Reservation Request";
    SourceTableView = SORTING("Entry No.")
                      ORDER(Descending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Created Date Time"; "Created Date Time")
                {
                    ApplicationArea = All;
                }
                field("External Member No."; "External Member No.")
                {
                    ApplicationArea = All;
                }
                field("External Order No."; "External Order No.")
                {
                    ApplicationArea = All;
                }
                field("Request Status"; "Request Status")
                {
                    ApplicationArea = All;
                }
                field("Payment Option"; "Payment Option")
                {
                    ApplicationArea = All;
                }
                field("Notification Method"; "Notification Method")
                {
                    ApplicationArea = All;
                }
                field("Notification Address"; "Notification Address")
                {
                    ApplicationArea = All;
                }
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = All;
                }
                field("Scheduled Time Description"; "Scheduled Time Description")
                {
                    ApplicationArea = All;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                }
                field("External Ticket Number"; "External Ticket Number")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field(NPRAttrTextArray_01; NPRAttrTextArray[1])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,6060116,1,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible01;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetEntryAttributeValue(DATABASE::"TM Ticket Reservation Request", 1, "Entry No.", NPRAttrTextArray[1]);
                    end;
                }
                field(NPRAttrTextArray_02; NPRAttrTextArray[2])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,6060116,2,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible02;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetEntryAttributeValue(DATABASE::"TM Ticket Reservation Request", 2, "Entry No.", NPRAttrTextArray[2]);
                    end;
                }
                field(NPRAttrTextArray_03; NPRAttrTextArray[3])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,6060116,3,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible03;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetEntryAttributeValue(DATABASE::"TM Ticket Reservation Request", 3, "Entry No.", NPRAttrTextArray[3]);
                    end;
                }
                field(NPRAttrTextArray_04; NPRAttrTextArray[4])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,6060116,4,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible04;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetEntryAttributeValue(DATABASE::"TM Ticket Reservation Request", 4, "Entry No.", NPRAttrTextArray[4]);
                    end;
                }
                field(NPRAttrTextArray_05; NPRAttrTextArray[5])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,6060116,5,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible05;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetEntryAttributeValue(DATABASE::"TM Ticket Reservation Request", 5, "Entry No.", NPRAttrTextArray[5]);
                    end;
                }
                field(NPRAttrTextArray_06; NPRAttrTextArray[6])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,6060116,6,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible06;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetEntryAttributeValue(DATABASE::"TM Ticket Reservation Request", 6, "Entry No.", NPRAttrTextArray[6]);
                    end;
                }
                field(NPRAttrTextArray_07; NPRAttrTextArray[7])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,6060116,7,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible07;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetEntryAttributeValue(DATABASE::"TM Ticket Reservation Request", 7, "Entry No.", NPRAttrTextArray[7]);
                    end;
                }
                field(NPRAttrTextArray_08; NPRAttrTextArray[8])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,6060116,8,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible08;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetEntryAttributeValue(DATABASE::"TM Ticket Reservation Request", 8, "Entry No.", NPRAttrTextArray[8]);
                    end;
                }
                field(NPRAttrTextArray_09; NPRAttrTextArray[9])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,6060116,9,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible09;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetEntryAttributeValue(DATABASE::"TM Ticket Reservation Request", 9, "Entry No.", NPRAttrTextArray[9]);
                    end;
                }
                field(NPRAttrTextArray_10; NPRAttrTextArray[10])
                {
                    ApplicationArea = All;
                    CaptionClass = '6014555,6060116,10,2';
                    Editable = NPRAttrEditable;
                    Visible = NPRAttrVisible10;

                    trigger OnValidate()
                    begin
                        NPRAttrManagement.SetEntryAttributeValue(DATABASE::"TM Ticket Reservation Request", 10, "Entry No.", NPRAttrTextArray[10]);
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
                Caption = 'Confirm & Print';
                Image = Confirm;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin

                    ConfirmAndPrint();
                end;
            }
            action(Pay)
            {
                Caption = 'Pay';
                Ellipsis = true;
                Image = Payment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin

                    CreatePosSale();
                end;
            }
            action(Print)
            {
                Caption = 'Print';
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin

                    PrintTicket();
                end;
            }
        }
        area(navigation)
        {
            action("Show Ticket")
            {
                Caption = 'Ticket';
                Image = Navigate;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Page "TM Ticket List";
                RunPageLink = "Ticket Reservation Entry No." = FIELD("Entry No.");
            }
        }
    }

    trigger OnAfterGetRecord()
    begin

        NPRAttrManagement.GetEntryAttributeValue(NPRAttrTextArray, DATABASE::"TM Ticket Reservation Request", "Entry No.");
        NPRAttrEditable := CurrPage.Editable();
    end;

    trigger OnOpenPage()
    begin

        FilterGroup(2);
        SetFilter("Request Status", '=%1|=%2', "Request Status"::CONFIRMED, "Request Status"::RESERVED);
        FilterGroup(0);
        FindFirst();

        NPRAttrManagement.GetAttributeVisibility(DATABASE::"TM Ticket Reservation Request", NPRAttrVisibleArray);
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

        TestField("Admission Created", true);
        if ("Payment Option" = "Payment Option"::DIRECT) then
            Error(NOT_PAID, "External Ticket Number");

        if ("Request Status" = "Request Status"::RESERVED) then
            "Request Status" := "Request Status"::CONFIRMED;

        PrintTicket();
    end;

    local procedure CreatePosSale()
    begin

        if ("Payment Option" <> "Payment Option"::DIRECT) then
            Error(TICKET_IS_PAID, "External Ticket Number");
    end;

    local procedure PrintTicket()
    var
        TicketManagement: Codeunit "TM Ticket Management";
        Ticket: Record "TM Ticket";
    begin

        TestField("Admission Created", true);
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', "Entry No.");
        Ticket.FindFirst();

        TicketManagement.PrintSingleTicket(Ticket);
    end;
}

