codeunit 6059834 "NPR M2 Save Values"
{
    trigger OnRun()
    begin
        ShowContactBuffer();
    end;

    procedure ShowContactBuffer()
    var
        Customer: Record Customer;
        Contact: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
        tmpMagentoContactBuffer: Record "NPR M2 Contact Buffer" temporary;
    begin
        Contact.SetFilter("NPR Magento Contact", '%1', true);
        Customer.SetFilter("NPR Magento Store Code", '<>%1', '');
        ContactBusinessRelation.SetFilter("Link to Table", '%1', ContactBusinessRelation."Link to Table"::Customer);

        if Contact.FindSet() then
            repeat
                ContactBusinessRelation.SetFilter("Contact No.", '%1', Contact."No.");
                if ContactBusinessRelation.FindFirst() then begin
                    Customer.SetFilter("No.", '%1', ContactBusinessRelation."No.");
                    if Customer.FindFirst() then begin
                        tmpMagentoContactBuffer."Entry No." += 1;
                        tmpMagentoContactBuffer."Customer No." := Customer."No.";
                        tmpMagentoContactBuffer."Customer Name" := Customer.Name;
                        tmpMagentoContactBuffer."Contact No." := Contact."No.";
                        tmpMagentoContactBuffer."Contact Name" := Contact.Name;
                        tmpMagentoContactBuffer."Contact Email" := Contact."E-Mail";
                        tmpMagentoContactBuffer."Magento Contact" := Contact."NPR Magento Contact";
                        tmpMagentoContactBuffer."Magento Store Code" := Customer."NPR Magento Store Code";
                        tmpMagentoContactBuffer.Insert();
                    end;
                end;
            until Contact.Next() = 0;

        Page.Run(Page::"NPR M2 Contact List", tmpMagentoContactBuffer);
    end;
}