codeunit 6151061 "GDPR Anonymization Request WS"
{
    // NPR5.54/TSA /20200324 CASE 389817 Initial Version


    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure AnonymizationRequest(CustomerNo: Code[20];ContactNo: Code[20]): Boolean
    var
        GDPRAnonymizationRequest: Record "GDPR Anonymization Request";
        Customer: Record Customer;
        Contact: Record Contact;
    begin

        GDPRAnonymizationRequest.Init();
        GDPRAnonymizationRequest."Customer No." := CustomerNo;

        if (not Customer.Get (CustomerNo)) then
          exit (false);

        GDPRAnonymizationRequest.Type := GDPRAnonymizationRequest.Type::COMPANY;
        if (ContactNo <> '') then begin
          if (not Contact.Get (ContactNo)) then
            exit (false);

          if (Contact.Type = Contact.Type::Person) then
            GDPRAnonymizationRequest.Type := GDPRAnonymizationRequest.Type::PERSON;

        end;

        GDPRAnonymizationRequest."Request Received" := CurrentDateTime();

        if (Customer.Anonymized) then begin
          GDPRAnonymizationRequest.Status := GDPRAnonymizationRequest.Status::ANONYMIZED;
          GDPRAnonymizationRequest."Processed At" := Customer."Anonymized Date";
        end;

        exit (GDPRAnonymizationRequest.Insert ());
    end;
}

