tableextension 6014434 "NPR Purchase Header" extends "Purchase Header"
{
    fields
    {
        field(6014401; "NPR Sent"; Boolean)
        {
            Caption = 'Sent';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014414; "NPR Pay-to E-mail"; Text[80])
        {
            Caption = 'Pay-to E-mail';
            DataClassification = CustomerContent;
            Description = 'PN1.00';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014415; "NPR Document Processing"; Option)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Document Sending Profile from Vendor is used.';
            Caption = 'Document Processing';
            DataClassification = CustomerContent;
            Description = 'PN1.00';
            OptionCaption = 'Print,E-mail,,Print and E-Mail';
            OptionMembers = Print,Email,OIO,PrintAndEmail;
        }
    }
}