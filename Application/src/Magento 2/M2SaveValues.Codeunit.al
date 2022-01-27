codeunit 6059834 "NPR M2 Save Values"
{
    Access = Internal;
    trigger OnRun()
    begin
        ShowContactBuffer();
    end;

    procedure ShowContactBuffer()
    var
        Customer: Record Customer;
        Contact: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
        TempMagentoContactBuffer: Record "NPR M2 Contact Buffer" temporary;
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
                        TempMagentoContactBuffer."Entry No." += 1;
                        TempMagentoContactBuffer."Customer No." := Customer."No.";
                        TempMagentoContactBuffer."Customer Name" := Customer.Name;
                        TempMagentoContactBuffer."Contact No." := Contact."No.";
                        TempMagentoContactBuffer."Contact Name" := Contact.Name;
                        TempMagentoContactBuffer."Contact Email" := Contact."E-Mail";
                        TempMagentoContactBuffer."Magento Contact" := Contact."NPR Magento Contact";
                        TempMagentoContactBuffer."Magento Store Code" := Customer."NPR Magento Store Code";
                        TempMagentoContactBuffer.Insert();
                    end;
                end;
            until Contact.Next() = 0;

        Page.Run(Page::"NPR M2 Contact List", TempMagentoContactBuffer);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustCont-Update", 'OnBeforeOnDelete', '', true, true)]
    local procedure OnBeforeOnDelete(Customer: Record Customer)
    begin
        if Customer.IsTemporary() then
            exit;

        ClearMagentoContact(Customer);
    end;

    local procedure ClearMagentoContact(Customer: Record Customer)
    var
        ContBusRel: Record "Contact Business Relation";
        Contact: Record Contact;
        POSEntry: Record "NPR POS Entry";
    begin
        ContBusRel.SetCurrentKey("Link to Table", "No.");
        ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Customer);
        ContBusRel.SetRange("No.", Customer."No.");
        if ContBusRel.IsEmpty() then
            exit;
        ContBusRel.FindSet();
        repeat
            Contact.Reset();
            Contact.SetRange("No.", ContBusRel."Contact No.");
            Contact.SetRange("NPR Magento Contact", true);
            if not Contact.IsEmpty() then begin
                POSEntry.Reset();
                POSEntry.SetRange("Contact No.", ContBusRel."No.");
                POSEntry.SetFilter("Customer No.", '%1', '');
                if POSEntry.IsEmpty() then begin
                    Contact.ModifyAll("E-Mail", '');
                    Contact.ModifyAll("E-Mail 2", '');
                end;
                Contact.ModifyAll("NPR Magento Contact", false);
            end;
        until ContBusRel.Next() = 0;
    end;
}
