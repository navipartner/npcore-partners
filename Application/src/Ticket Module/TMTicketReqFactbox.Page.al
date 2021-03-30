page 6060089 "NPR TM Ticket Req. Factbox"
{
    Caption = 'NP Attributes FactBox';
    PageType = CardPart;
    SourceTable = "NPR TM Ticket Reservation Req.";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            field("Entry No."; Rec."Entry No.")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                ToolTip = 'Specifies the value of the Entry No. field';
            }

            field("Entry Type"; Rec."Entry Type")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                ToolTip = 'Specifies the value of the Entry Type field';
            }

            field("Superseeds Entry No."; Rec."Superseeds Entry No.")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
                ToolTip = 'Specifies the value of the Superseeds Entry No. field';
            }
            field("Session Token ID"; Rec."Session Token ID")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
                ToolTip = 'Specifies the value of the Session Token ID field';
            }

            field("Authorization Code"; Rec."Authorization Code")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                ToolTip = 'Specifies the value of the Authorization Code field';
            }

            field("Created Date Time"; Rec."Created Date Time")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                ToolTip = 'Specifies the value of the Created Date Time field';
            }
            field("Request Status"; Rec."Request Status")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
                ToolTip = 'Specifies the value of the Request Status field';
            }
            field("Request Status Date Time"; Rec."Request Status Date Time")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
                ToolTip = 'Specifies the value of the Request Status Date Time field';
            }
            field("Revoke Ticket Request"; Rec."Revoke Ticket Request")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
                ToolTip = 'Specifies the value of the Revoke Ticket Request field';
            }
            field("Revoke Access Entry No."; Rec."Revoke Access Entry No.")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
                ToolTip = 'Specifies the value of the Revoke Access Entry No. field';
            }
            field("External Item Code"; Rec."External Item Code")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                ToolTip = 'Specifies the value of the External Item Code field';
            }
            field("Item No."; Rec."Item No.")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                ToolTip = 'Specifies the value of the Item No. field';
            }
            field("Variant Code"; Rec."Variant Code")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                ToolTip = 'Specifies the value of the Variant Code field';
            }
            field(Quantity; Rec.Quantity)
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                ToolTip = 'Specifies the value of the Quantity field';
            }
            field("External Adm. Sch. Entry No."; Rec."External Adm. Sch. Entry No.")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
                ToolTip = 'Specifies the value of the External Adm. Sch. Entry No. field';
            }
            field("Ext. Line Reference No."; Rec."Ext. Line Reference No.")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
                ToolTip = 'Specifies the value of the Line Reference No. field';
            }
            field("External Member No."; Rec."External Member No.")
            {
                ApplicationArea = NPRTicketAdvanced;
                ToolTip = 'Specifies the value of the External Member No. field';
            }
            field("Admission Code"; Rec."Admission Code")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                ToolTip = 'Specifies the value of the Admission Code field';
            }
            field("Expires Date Time"; Rec."Expires Date Time")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
                ToolTip = 'Specifies the value of the Expires Date Time field';
            }
            field("External Ticket Number"; Rec."External Ticket Number")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
                ToolTip = 'Specifies the value of the External Ticket Number field';
            }
            field("Admission Description"; Rec."Admission Description")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
                ToolTip = 'Specifies the value of the Admission Description field';
            }
            field("Scheduled Time Description"; Rec."Scheduled Time Description")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
                ToolTip = 'Specifies the value of the Scheduled Time Description field';
            }
            field("Notification Method"; Rec."Notification Method")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
                ToolTip = 'Specifies the value of the Notification Method field';
            }
            field("Notification Address"; Rec."Notification Address")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
                ToolTip = 'Specifies the value of the Notification Address field';
            }
            field("External Order No."; Rec."External Order No.")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
                ToolTip = 'Specifies the value of the External Order No. field';
            }
            field("Admission Created"; Rec."Admission Created")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
                ToolTip = 'Specifies the value of the Admission Created field';
            }
            field("Payment Option"; Rec."Payment Option")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                ToolTip = 'Specifies the value of the Payment Option field';
            }
            field("Customer No."; Rec."Customer No.")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                ToolTip = 'Specifies the value of the Customer No. field';
            }
            field("Receipt No."; Rec."Receipt No.")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                ToolTip = 'Specifies the value of the Receipt No. field';
            }
            field("Line No."; Rec."Line No.")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = false;
                ToolTip = 'Specifies the value of the Line No. field';
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

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin

        //-TM1.23 [284752]
        NPRAttrManagement.GetEntryAttributeValue(NPRAttrTextArray, DATABASE::"NPR TM Ticket Reservation Req.", Rec."Entry No.");
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
        PAGE.Run(PAGE::"Item Card", Rec);
    end;
}

