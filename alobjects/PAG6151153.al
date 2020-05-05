page 6151153 "GDPR Anonymization Request"
{
    // NPR5.54/TSA /20200324 CASE 389817 Initial Version

    Caption = 'GDPR Anonymization Request';
    Editable = false;
    PageType = List;
    SourceTable = "GDPR Anonymization Request";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                }
                field("Customer No.";"Customer No.")
                {
                }
                field("Contact No.";"Contact No.")
                {
                }
                field(Status;Status)
                {
                }
                field("Request Received";"Request Received")
                {
                }
                field("Processed At";"Processed At")
                {
                }
                field("Log Count";"Log Count")
                {
                }
                field(Reason;Reason)
                {
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
                RunObject = Page "Customer GDPR Log Entries";
                RunPageLink = "Customer No"=FIELD("Customer No.");
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
                    GDPRAnonymizationRequest: Record "GDPR Anonymization Request";
                begin

                    CurrPage.SetSelectionFilter (GDPRAnonymizationRequest);
                    AnonymizeCustomer (GDPRAnonymizationRequest);
                    CurrPage.Update (false);
                end;
            }
        }
    }

    var
        NPGDPRManagement: Codeunit "NP GDPR Management";

    local procedure AnonymizeCustomer(var GDPRAnonymizationRequest: Record "GDPR Anonymization Request")
    var
        NPGDPRManagement: Codeunit "NP GDPR Management";
        Reason: Text;
    begin

        GDPRAnonymizationRequest.SetFilter (Status, '<>%1', GDPRAnonymizationRequest.Status::ANONYMIZED);
        if (GDPRAnonymizationRequest.FindSet ()) then begin
          repeat
            Reason := '';
            GDPRAnonymizationRequest.Status := GDPRAnonymizationRequest.Status::PENDING;
            GDPRAnonymizationRequest."Processed At" := CurrentDateTime ();

            if (GDPRAnonymizationRequest.Type = GDPRAnonymizationRequest.Type::COMPANY) then begin
              if (NPGDPRManagement.DoAnonymization (GDPRAnonymizationRequest."Customer No.", Reason)) then begin
                GDPRAnonymizationRequest.Status := Rec.Status::ANONYMIZED;
              end;
              GDPRAnonymizationRequest.Reason := CopyStr (Reason, 1, MaxStrLen (GDPRAnonymizationRequest.Reason));
              GDPRAnonymizationRequest.Modify ();
            end;

            if (GDPRAnonymizationRequest.Type = GDPRAnonymizationRequest.Type::PERSON) then begin
              Reason := 'Contact of type person does not have authority to request anonymization.';
              GDPRAnonymizationRequest.Modify ();
            end;
          until (GDPRAnonymizationRequest.Next () = 0);

        end;
    end;
}

