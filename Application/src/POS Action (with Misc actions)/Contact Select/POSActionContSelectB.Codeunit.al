codeunit 6059949 "NPR POS Action: Cont. Select-B"
{
    Access = Internal;

    procedure AttachContact(var SalePOS: Record "NPR POS Sale"; ContactTableView: Text; ContactLookupPage: Integer)
    var
        Contact: Record Contact;
    begin
        if ContactTableView <> '' then
            Contact.SetView(ContactTableView);

        if PAGE.RunModal(ContactLookupPage, Contact) <> ACTION::LookupOK then
            exit;

        SalePOS.Validate("Contact No.", Contact."No.");
        SalePOS.Modify(true);
    end;

    procedure RemoveContact(var SalePOS: Record "NPR POS Sale")
    begin
        SalePOS.Validate("Contact No.", '');
        SalePOS.Modify(true);
    end;
}