page 6060092 "NPR MM Admission Service Log"
{
    // NPR5.31/NPKNAV/20170502  CASE 263737 Transport NPR5.31 - 2 May 2017
    // NPR5.48/CLVA  /20190102  CASE 340731 Added ActionItems Test

    Caption = 'MM Admission Service Log';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR MM Admis. Service Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Action"; Action)
                {
                    ApplicationArea = All;
                }
                field("Created Date"; "Created Date")
                {
                    ApplicationArea = All;
                }
                field(Token; Token)
                {
                    ApplicationArea = All;
                }
                field("Key"; Key)
                {
                    ApplicationArea = All;
                }
                field("Scanner Station Id"; "Scanner Station Id")
                {
                    ApplicationArea = All;
                }
                field("Request Barcode"; "Request Barcode")
                {
                    ApplicationArea = All;
                }
                field("Request Scanner Station Id"; "Request Scanner Station Id")
                {
                    ApplicationArea = All;
                }
                field("Request No"; "Request No")
                {
                    ApplicationArea = All;
                }
                field("Request Token"; "Request Token")
                {
                    ApplicationArea = All;
                }
                field("Response No"; "Response No")
                {
                    ApplicationArea = All;
                }
                field("Response Token"; "Response Token")
                {
                    ApplicationArea = All;
                }
                field("Response Name"; "Response Name")
                {
                    ApplicationArea = All;
                }
                field("Response PictureBase64"; "Response PictureBase64")
                {
                    ApplicationArea = All;
                }
                field("Error Number"; "Error Number")
                {
                    ApplicationArea = All;
                }
                field("Error Description"; "Error Description")
                {
                    ApplicationArea = All;
                }
                field("Return Value"; "Return Value")
                {
                    ApplicationArea = All;
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

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
                    GaestByNrResponse := MMAdmissionServiceWS.GuestValidation("Request Barcode", "Scanner Station Id", RefNo, RefToken, RefErrorNumber, RefErrorDescription);
                    Message('Web Service function GuestValidation Status: ' + Format(GaestByNrResponse));
                    if (RefErrorNumber = '') then begin
                        GaestEnteredDoorResponse := MMAdmissionServiceWS.GuestArrivalV2(RefNo, RefToken, "Scanner Station Id", RefName, RefPictureBase64, RefTransaktion, RefErrorNumber, RefErrorDescription);
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

