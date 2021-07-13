page 6060092 "NPR MM Admission Service Log"
{

    Caption = 'MM Admission Service Log';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MM Admis. Service Log";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Action"; Rec.Action)
                {

                    ToolTip = 'Specifies the value of the Action field';
                    ApplicationArea = NPRRetail;
                }
                field("Created Date"; Rec."Created Date")
                {

                    ToolTip = 'Specifies the value of the Created Date field';
                    ApplicationArea = NPRRetail;
                }
                field(Token; Rec.Token)
                {

                    ToolTip = 'Specifies the value of the Token field';
                    ApplicationArea = NPRRetail;
                }
                field("Key"; Rec.Key)
                {

                    ToolTip = 'Specifies the value of the Key field';
                    ApplicationArea = NPRRetail;
                }
                field("Scanner Station Id"; Rec."Scanner Station Id")
                {

                    ToolTip = 'Specifies the value of the Scanner Station Id field';
                    ApplicationArea = NPRRetail;
                }
                field("Request Barcode"; Rec."Request Barcode")
                {

                    ToolTip = 'Specifies the value of the Request Barcode field';
                    ApplicationArea = NPRRetail;
                }
                field("Request Scanner Station Id"; Rec."Request Scanner Station Id")
                {

                    ToolTip = 'Specifies the value of the Request Scanner Station Id field';
                    ApplicationArea = NPRRetail;
                }
                field("Request No"; Rec."Request No")
                {

                    ToolTip = 'Specifies the value of the Request No field';
                    ApplicationArea = NPRRetail;
                }
                field("Request Token"; Rec."Request Token")
                {

                    ToolTip = 'Specifies the value of the Request Token field';
                    ApplicationArea = NPRRetail;
                }
                field("Response No"; Rec."Response No")
                {

                    ToolTip = 'Specifies the value of the Response No field';
                    ApplicationArea = NPRRetail;
                }
                field("Response Token"; Rec."Response Token")
                {

                    ToolTip = 'Specifies the value of the Response Token field';
                    ApplicationArea = NPRRetail;
                }
                field("Response Name"; Rec."Response Name")
                {

                    ToolTip = 'Specifies the value of the Response Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Response PictureBase64"; Rec."Response PictureBase64")
                {

                    ToolTip = 'Specifies the value of the Response PictureBase64 field';
                    ApplicationArea = NPRRetail;
                }
                field("Error Number"; Rec."Error Number")
                {

                    ToolTip = 'Specifies the value of the Error Number field';
                    ApplicationArea = NPRRetail;
                }
                field("Error Description"; Rec."Error Description")
                {

                    ToolTip = 'Specifies the value of the Error Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Return Value"; Rec."Return Value")
                {

                    ToolTip = 'Specifies the value of the Return Value field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Test action';
                ApplicationArea = NPRRetail;

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

