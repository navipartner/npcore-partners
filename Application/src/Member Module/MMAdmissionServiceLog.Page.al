page 6060092 "NPR MM Admission Service Log"
{
    Extensible = False;

    Caption = 'MM Admission Service Log';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MM Admis. Service Log";
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Action"; Rec.Action)
                {

                    ToolTip = 'Specifies the value of the Action field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Created Date"; Rec."Created Date")
                {

                    ToolTip = 'Specifies the value of the Created Date field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Token; Rec.Token)
                {

                    ToolTip = 'Specifies the value of the Token field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Key"; Rec.Key)
                {

                    ToolTip = 'Specifies the value of the Key field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Scanner Station Id"; Rec."Scanner Station Id")
                {

                    ToolTip = 'Specifies the value of the Scanner Station Id field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Request Barcode"; Rec."Request Barcode")
                {

                    ToolTip = 'Specifies the value of the Request Barcode field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Request Scanner Station Id"; Rec."Request Scanner Station Id")
                {

                    ToolTip = 'Specifies the value of the Request Scanner Station Id field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Request No"; Rec."Request No")
                {

                    ToolTip = 'Specifies the value of the Request No field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Request Token"; Rec."Request Token")
                {

                    ToolTip = 'Specifies the value of the Request Token field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Response No"; Rec."Response No")
                {

                    ToolTip = 'Specifies the value of the Response No field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Response Token"; Rec."Response Token")
                {

                    ToolTip = 'Specifies the value of the Response Token field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Response Name"; Rec."Response Name")
                {

                    ToolTip = 'Specifies the value of the Response Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Response PictureBase64"; Rec."Response PictureBase64")
                {

                    ToolTip = 'Specifies the value of the Response PictureBase64 field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Error Number"; Rec."Error Number")
                {

                    ToolTip = 'Specifies the value of the Error Number field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Error Description"; Rec."Error Description")
                {

                    ToolTip = 'Specifies the value of the Error Description field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Return Value"; Rec."Return Value")
                {

                    ToolTip = 'Specifies the value of the Return Value field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
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
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

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

