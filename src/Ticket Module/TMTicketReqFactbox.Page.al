page 6060089 "NPR TM Ticket Req. Factbox"
{
    // TM1.23/TSA /20170724 CASE 284752 Initial Version
    // TM1.43/TSA /20190910 CASE 368043 Refactored usage of "External Item Code"

    Caption = 'NP Attributes FactBox';
    PageType = CardPart;
    SourceTable = "NPR TM Ticket Reservation Req.";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            field("Entry No."; "Entry No.")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
            }

            field("Entry Type"; "Entry Type")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
            }

            field("Superseeds Entry No."; "Superseeds Entry No.")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
            }
            field("Session Token ID"; "Session Token ID")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
            }

            field("Authorization Code"; "Authorization Code")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
            }

            field("Created Date Time"; "Created Date Time")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
            }
            field("Request Status"; "Request Status")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
            }
            field("Request Status Date Time"; "Request Status Date Time")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
            }
            field("Revoke Ticket Request"; "Revoke Ticket Request")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
            }
            field("Revoke Access Entry No."; "Revoke Access Entry No.")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
            }
            field("External Item Code"; "External Item Code")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
            }
            field("Item No."; "Item No.")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
            }
            field("Variant Code"; "Variant Code")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
            }
            field(Quantity; Quantity)
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
            }
            field("External Adm. Sch. Entry No."; "External Adm. Sch. Entry No.")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
            }
            field("Ext. Line Reference No."; "Ext. Line Reference No.")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
            }
            field("External Member No."; "External Member No.")
            {
                ApplicationArea = NPRTicketAdvanced;
            }
            field("Admission Code"; "Admission Code")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
            }
            field("Expires Date Time"; "Expires Date Time")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
            }
            field("External Ticket Number"; "External Ticket Number")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
            }
            field("Admission Description"; "Admission Description")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
            }
            field("Scheduled Time Description"; "Scheduled Time Description")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
            }
            field("Notification Method"; "Notification Method")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
            }
            field("Notification Address"; "Notification Address")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
            }
            field("External Order No."; "External Order No.")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
            }
            field("Admission Created"; "Admission Created")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
            }
            field("Payment Option"; "Payment Option")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
            }
            field("Customer No."; "Customer No.")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
            }
            field("Receipt No."; "Receipt No.")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
            }
            field("Line No."; "Line No.")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
            }
            field(NPRAttrTextArray_01; NPRAttrTextArray[1])
            {
                ApplicationArea = NPRTicketAdvanced;
                CaptionClass = '6014555,6060116,1,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible01;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetEntryAttributeValue(DATABASE::"NPR TM Ticket Reservation Req.", 1, "Entry No.", NPRAttrTextArray[1]);
                end;
            }
            field(NPRAttrTextArray_02; NPRAttrTextArray[2])
            {
                ApplicationArea = NPRTicketAdvanced;
                CaptionClass = '6014555,6060116,2,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible02;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetEntryAttributeValue(DATABASE::"NPR TM Ticket Reservation Req.", 2, "Entry No.", NPRAttrTextArray[2]);
                end;
            }
            field(NPRAttrTextArray_03; NPRAttrTextArray[3])
            {
                ApplicationArea = NPRTicketAdvanced;
                CaptionClass = '6014555,6060116,3,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible03;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetEntryAttributeValue(DATABASE::"NPR TM Ticket Reservation Req.", 3, "Entry No.", NPRAttrTextArray[3]);
                end;
            }
            field(NPRAttrTextArray_04; NPRAttrTextArray[4])
            {
                ApplicationArea = NPRTicketAdvanced;
                CaptionClass = '6014555,6060116,4,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible04;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetEntryAttributeValue(DATABASE::"NPR TM Ticket Reservation Req.", 4, "Entry No.", NPRAttrTextArray[4]);
                end;
            }
            field(NPRAttrTextArray_05; NPRAttrTextArray[5])
            {
                ApplicationArea = NPRTicketAdvanced;
                CaptionClass = '6014555,6060116,5,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible05;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetEntryAttributeValue(DATABASE::"NPR TM Ticket Reservation Req.", 5, "Entry No.", NPRAttrTextArray[5]);
                end;
            }
            field(NPRAttrTextArray_06; NPRAttrTextArray[6])
            {
                ApplicationArea = NPRTicketAdvanced;
                CaptionClass = '6014555,6060116,6,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible06;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetEntryAttributeValue(DATABASE::"NPR TM Ticket Reservation Req.", 6, "Entry No.", NPRAttrTextArray[6]);
                end;
            }
            field(NPRAttrTextArray_07; NPRAttrTextArray[7])
            {
                ApplicationArea = NPRTicketAdvanced;
                CaptionClass = '6014555,6060116,7,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible07;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetEntryAttributeValue(DATABASE::"NPR TM Ticket Reservation Req.", 7, "Entry No.", NPRAttrTextArray[7]);
                end;
            }
            field(NPRAttrTextArray_08; NPRAttrTextArray[8])
            {
                ApplicationArea = NPRTicketAdvanced;
                CaptionClass = '6014555,6060116,8,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible08;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetEntryAttributeValue(DATABASE::"NPR TM Ticket Reservation Req.", 8, "Entry No.", NPRAttrTextArray[8]);
                end;
            }
            field(NPRAttrTextArray_09; NPRAttrTextArray[9])
            {
                ApplicationArea = NPRTicketAdvanced;
                CaptionClass = '6014555,6060116,9,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible09;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetEntryAttributeValue(DATABASE::"NPR TM Ticket Reservation Req.", 9, "Entry No.", NPRAttrTextArray[9]);
                end;
            }
            field(NPRAttrTextArray_10; NPRAttrTextArray[10])
            {
                ApplicationArea = NPRTicketAdvanced;
                CaptionClass = '6014555,6060116,10,2';
                Editable = NPRAttrEditable;
                Visible = NPRAttrVisible10;

                trigger OnValidate()
                begin
                    NPRAttrManagement.SetEntryAttributeValue(DATABASE::"NPR TM Ticket Reservation Req.", 10, "Entry No.", NPRAttrTextArray[10]);
                end;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin

        //-TM1.23 [284752]
        NPRAttrManagement.GetEntryAttributeValue(NPRAttrTextArray, DATABASE::"NPR TM Ticket Reservation Req.", "Entry No.");
        NPRAttrEditable := CurrPage.Editable();
        //+TM1.23 [284752]
    end;

    trigger OnOpenPage()
    begin

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

    procedure ShowDetails()
    begin
        //-NPR4.21
        //PAGE.RUN(PAGE::"Item Card",Rec);
        PAGE.Run(PAGE::"NPR Retail Item Card", Rec);
        //+NPR4.21
    end;
}

