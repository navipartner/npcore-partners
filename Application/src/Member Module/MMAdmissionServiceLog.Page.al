page 6060092 "NPR MM Admission Service Log"
{

    Caption = 'MM Admission Service Log';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR MM Admis. Service Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Action"; Rec.Action)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Action field';
                }
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created Date field';
                }
                field(Token; Rec.Token)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Token field';
                }
                field("Key"; Rec.Key)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Key field';
                }
                field("Scanner Station Id"; Rec."Scanner Station Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Scanner Station Id field';
                }
                field("Request Barcode"; Rec."Request Barcode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Request Barcode field';
                }
                field("Request Scanner Station Id"; Rec."Request Scanner Station Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Request Scanner Station Id field';
                }
                field("Request No"; Rec."Request No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Request No field';
                }
                field("Request Token"; Rec."Request Token")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Request Token field';
                }
                field("Response No"; Rec."Response No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Response No field';
                }
                field("Response Token"; Rec."Response Token")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Response Token field';
                }
                field("Response Name"; Rec."Response Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Response Name field';
                }
                field("Response PictureBase64"; Rec."Response PictureBase64")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Response PictureBase64 field';
                }
                field("Error Number"; Rec."Error Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Error Number field';
                }
                field("Error Description"; Rec."Error Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Error Description field';
                }
                field("Return Value"; Rec."Return Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Return Value field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Test)
            {
                Caption = 'Test';
                Image = TestFile;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Test action';

                trigger OnAction()
                var
                    MMAdmissionServiceWS: Codeunit "NPR MM Admission Service WS";
                    GaestByNrResponse: Boolean;
                    GaestEnteredDoorResponse: Boolean;
                    RefNo: Code[20];
                    RefToken: Code[50];
                    RefErrorNumber: Code[10];
                    RefErrorDescription: Text;
                    RefName: Text;
                    RefPictureBase64: Text;
                    RefTransaktion: Code[10];
                begin
                    GaestByNrResponse := MMAdmissionServiceWS.GuestValidation(Rec."Request Barcode", Rec."Scanner Station Id", RefNo, RefToken, RefErrorNumber, RefErrorDescription);
                    Message('Web Service function GuestValidation Status: ' + Format(GaestByNrResponse));
                    if (RefErrorNumber = '') then begin
                        GaestEnteredDoorResponse := MMAdmissionServiceWS.GuestArrivalV2(RefNo, RefToken, Rec."Scanner Station Id", RefName, RefPictureBase64, RefTransaktion, RefErrorNumber, RefErrorDescription);
                        Message('Web Service function GuestArrivalV2 Status: ' + Format(GaestEnteredDoorResponse));
                        if (RefErrorNumber = '') then begin
                            Message('Ticket/Membership validated OK');
                        end else
                            Message('Web Service function GuestArrivalV2 Error:\' + RefErrorNumber + '\' + RefErrorDescription);
                    end else
                        Message('Web Service function GuestValidation Error:\' + RefErrorNumber + '\' + RefErrorDescription);
                end;
            }
        }
    }
}

