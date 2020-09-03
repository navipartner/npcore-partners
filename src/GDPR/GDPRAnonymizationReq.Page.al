page 6151153 "NPR GDPR Anonymization Req."
{
    // NPR5.54/TSA /20200324 CASE 389817 Initial Version
    // NPR5.55/TSA /20200716 CASE 388813 Fixed handling of deleted customer.

    Caption = 'GDPR Anonymization Request';
    Editable = false;
    PageType = List;
    SourceTable = "NPR GDPR Anonymization Request";

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
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Contact No."; "Contact No.")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Request Received"; "Request Received")
                {
                    ApplicationArea = All;
                }
                field("Processed At"; "Processed At")
                {
                    ApplicationArea = All;
                }
                field("Log Count"; "Log Count")
                {
                    ApplicationArea = All;
                }
                field(Reason; Reason)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Anonymization Log")
            {
                Caption = 'Anonymization Log';
                Ellipsis = true;
                Image = ChangeLog;
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Page "NPR Customer GDPR Log Entries";
                RunPageLink = "Customer No" = FIELD("Customer No.");
            }
        }
        area(processing)
        {
            action(Anonymize)
            {
                Caption = 'Anonymize';
                Image = Absence;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    GDPRAnonymizationRequest: Record "NPR GDPR Anonymization Request";
                begin

                    CurrPage.SetSelectionFilter(GDPRAnonymizationRequest);
                    AnonymizeCustomer(GDPRAnonymizationRequest);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        NPGDPRManagement: Codeunit "NPR GDPR Management";

    local procedure AnonymizeCustomer(var GDPRAnonymizationRequest: Record "NPR GDPR Anonymization Request")
    var
        Customer: Record Customer;
        NPGDPRManagement: Codeunit "NPR NP GDPR Management";
        Reason: Text;
    begin

        //-NPR5.55 [388813]
        //GDPRAnonymizationRequest.SETFILTER (Status, '<>%1', GDPRAnonymizationRequest.Status::ANONYMIZED);
        GDPRAnonymizationRequest.SetFilter(Status, '=%1|=%2', GDPRAnonymizationRequest.Status::NEW, GDPRAnonymizationRequest.Status::PENDING);
        //+NPR5.55 [388813]

        if (GDPRAnonymizationRequest.FindSet()) then begin
            repeat
                Reason := '';
                GDPRAnonymizationRequest.Status := GDPRAnonymizationRequest.Status::PENDING;
                GDPRAnonymizationRequest."Processed At" := CurrentDateTime();

                if (GDPRAnonymizationRequest.Type = GDPRAnonymizationRequest.Type::COMPANY) then begin
                    //-NPR5.55 [388813]
                    // IF (NPGDPRManagement.DoAnonymization (GDPRAnonymizationRequest."Customer No.", Reason)) THEN BEGIN
                    //   GDPRAnonymizationRequest.Status := Rec.Status::ANONYMIZED;
                    // END;
                    // GDPRAnonymizationRequest.Reason := COPYSTR (Reason, 1, MAXSTRLEN (GDPRAnonymizationRequest.Reason));
                    // GDPRAnonymizationRequest.MODIFY ();

                    if (Customer.Get(GDPRAnonymizationRequest."Customer No.")) then begin
                        if (NPGDPRManagement.DoAnonymization(GDPRAnonymizationRequest."Customer No.", Reason)) then begin
                            GDPRAnonymizationRequest.Status := Rec.Status::ANONYMIZED;
                        end;
                        GDPRAnonymizationRequest.Reason := CopyStr(Reason, 1, MaxStrLen(GDPRAnonymizationRequest.Reason));
                        GDPRAnonymizationRequest.Modify();
                    end else begin
                        Reason := 'Customer not found.';
                        GDPRAnonymizationRequest.Reason := CopyStr(Reason, 1, MaxStrLen(GDPRAnonymizationRequest.Reason));
                        GDPRAnonymizationRequest.Status := GDPRAnonymizationRequest.Status::REJECTED;
                        GDPRAnonymizationRequest.Modify();
                    end;
                    //+NPR5.55 [388813]

                end;

                if (GDPRAnonymizationRequest.Type = GDPRAnonymizationRequest.Type::PERSON) then begin
                    Reason := 'Contact of type person does not have authority to request anonymization.';
                    //-NPR5.55 [388813]
                    GDPRAnonymizationRequest.Reason := CopyStr(Reason, 1, MaxStrLen(GDPRAnonymizationRequest.Reason));
                    GDPRAnonymizationRequest.Status := GDPRAnonymizationRequest.Status::REJECTED;
                    //+NPR5.55 [388813]
                    GDPRAnonymizationRequest.Modify();
                end;
            until (GDPRAnonymizationRequest.Next() = 0);

        end;
    end;
}

