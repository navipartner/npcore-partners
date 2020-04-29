page 6060092 "MM Admission Service Log"
{
    // NPR5.31/NPKNAV/20170502  CASE 263737 Transport NPR5.31 - 2 May 2017
    // NPR5.48/CLVA  /20190102  CASE 340731 Added ActionItems Test

    Caption = 'MM Admission Service Log';
    Editable = false;
    PageType = List;
    SourceTable = "MM Admission Service Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                }
                field("No.";"No.")
                {
                }
                field("Action";Action)
                {
                }
                field("Created Date";"Created Date")
                {
                }
                field(Token;Token)
                {
                }
                field("Key";Key)
                {
                }
                field("Scanner Station Id";"Scanner Station Id")
                {
                }
                field("Request Barcode";"Request Barcode")
                {
                }
                field("Request Scanner Station Id";"Request Scanner Station Id")
                {
                }
                field("Request No";"Request No")
                {
                }
                field("Request Token";"Request Token")
                {
                }
                field("Response No";"Response No")
                {
                }
                field("Response Token";"Response Token")
                {
                }
                field("Response Name";"Response Name")
                {
                }
                field("Response PictureBase64";"Response PictureBase64")
                {
                }
                field("Error Number";"Error Number")
                {
                }
                field("Error Description";"Error Description")
                {
                }
                field("Return Value";"Return Value")
                {
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

                trigger OnAction()
                var
                    MMAdmissionServiceWS: Codeunit "MM Admission Service WS";
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
                    GaestByNrResponse := MMAdmissionServiceWS.GuestValidation("Request Barcode","Scanner Station Id",RefNo,RefToken,RefErrorNumber, RefErrorDescription);
                    Message('Web Service function GuestValidation Status: ' + Format(GaestByNrResponse));
                    if (RefErrorNumber = '') then begin
                      GaestEnteredDoorResponse := MMAdmissionServiceWS.GuestArrivalV2(RefNo,RefToken,"Scanner Station Id",RefName, RefPictureBase64,RefTransaktion,RefErrorNumber, RefErrorDescription);
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

