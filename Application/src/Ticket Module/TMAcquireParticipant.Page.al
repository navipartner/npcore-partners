page 6060110 "NPR TM Acquire Participant"
{
    Extensible = False;
    Caption = 'Acquire Participant';
    DataCaptionExpression = Rec."Admission Description";
    DataCaptionFields = "Admission Description";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = StandardDialog;
    SourceTable = "NPR TM Ticket Reservation Req.";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                //The GridLayout property is only supported on controls of type Grid
                //GridLayout = Columns;
                group(Control6014411)
                {
                    ShowCaption = false;
                    field("Notification Method"; Rec."Notification Method")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Notification Method field';
                    }
                    field("Notification Address"; Rec."Notification Address")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        ShowMandatory = RequireNotificationAddress;
                        Width = 40;
                        ToolTip = 'Specifies the value of the Notification Address field';

                        trigger OnValidate()
                        begin
                            CheckEmail();
                        end;
                    }
                }
            }
            group(Attributes)
            {
                Caption = 'Attributes';
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
    }

    trigger OnAfterGetCurrRecord()
    begin

        //-TM1.23 [284752]
        NPRAttrManagement.GetEntryAttributeValue(NPRAttrTextArray, DATABASE::"NPR TM Ticket Reservation Req.", Rec."Entry No.");
        NPRAttrEditable := CurrPage.Editable();
        //+TM1.23 [284752]
    end;

    trigger OnAfterGetRecord()
    begin
        //-TM1.38 [332109]
        //IF ("Notification Address" <> '') THEN BEGIN
        if ((Rec."Notification Address" <> '') or (SuggestNotificationMethod <> SuggestNotificationMethod::NA)) then begin
            //+TM1.38 [332109]

            Rec."Notification Address" := SuggestNotificationAddress;

            case SuggestNotificationMethod of
                SuggestNotificationMethod::EMAIL:
                    Rec."Notification Method" := Rec."Notification Method"::EMAIL;
                SuggestNotificationMethod::SMS:
                    Rec."Notification Method" := Rec."Notification Method"::SMS;
                else
                    Rec."Notification Method" := Rec."Notification Method"::NA;
            end;
        end;
    end;

    trigger OnOpenPage()
    begin
        //-TM1.23 [284752]

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
        //+TM1.23 [284752]
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if (CloseAction = ACTION::LookupOK) then begin
            if (RequireNotificationAddress) then
                Rec.TestField("Notification Address");

        end else begin
            if ((RequireNotificationAddress) and (Rec."Notification Address" = '')) then
                if (Confirm(EMAIL_INVALID_CONFIRM, true, Rec.FieldCaption("Notification Address"))) then
                    Error('');
        end;
    end;

    var
        INVALID_VALUE: Label 'The %1 is invalid.';
        EMAIL_INVALID_CONFIRM: Label 'The %1 seems invalid, do you want to correct it?';
        Admission: Record "NPR TM Admission";
        RequireNotificationAddress: Boolean;
        SuggestNotificationMethod: Option NA,EMAIL,SMS;
        SuggestNotificationAddress: Text[100];
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

    local procedure CheckEmail()
    var
        ValidEmail: Boolean;
    begin
        if (Rec."Notification Method" = Rec."Notification Method"::EMAIL) then begin
            ValidEmail := (StrPos(Rec."Notification Address", '@') > 1);
            if (ValidEmail) then
                ValidEmail := (StrPos(CopyStr(Rec."Notification Address", StrPos(Rec."Notification Address", '@')), '.') > 1);

            if (not ValidEmail) then
                if (Confirm(EMAIL_INVALID_CONFIRM, true, Rec.FieldCaption("Notification Address"))) then
                    Error(INVALID_VALUE, Rec.FieldCaption("Notification Address"));
        end;

        if (RequireNotificationAddress) then
            Rec.TestField("Notification Address");
    end;

    procedure SetAdmissionCode(AdmissionCode: Code[20])
    begin

        Admission.Get(AdmissionCode);
        RequireNotificationAddress := (Admission."Ticketholder Notification Type" = Admission."Ticketholder Notification Type"::REQUIRED);
    end;

    procedure SetDefaultNotification(Method: Option NA,EMAIL,SMS; Address: Text[100])
    begin

        SuggestNotificationMethod := Method;
        SuggestNotificationAddress := Address;
    end;
}

