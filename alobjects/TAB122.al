tableextension 70000011 tableextension70000011 extends "Purch. Inv. Header" 
{
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //   - Added Field 6014414 "Pay-to E-mail" for defining Recipient when sending E-mail using PDF2NAV.
    //   - Added Field 6014415 "Document Processing" for defining Print action on Purch. Doc. Posting.
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)
    // NPR5.44/BHR/20180709 CASE 321560 New fields "Sell-to" 6014420 to 6014430
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to Sell To Phone No.
    fields
    {
        field(6014414;"Pay-to E-mail";Text[80])
        {
            Caption = 'Pay-to E-mail';
            Description = 'PN1.00';
        }
        field(6014415;"Document Processing";Option)
        {
            Caption = 'Document Processing';
            Description = 'PN1.00';
            OptionCaption = 'Print,E-mail,,Print and E-Mail';
            OptionMembers = Print,Email,OIO,PrintAndEmail;
        }
        field(6014420;"Sell-to Customer Name";Text[50])
        {
            CalcFormula = Lookup(Customer.Name WHERE ("No."=FIELD("Sell-to Customer No.")));
            Caption = 'Sell-to Customer Name';
            FieldClass = FlowField;
        }
        field(6014421;"Sell-to Customer Name 2";Text[50])
        {
            CalcFormula = Lookup(Customer."Name 2" WHERE ("No."=FIELD("Sell-to Customer No.")));
            Caption = 'Sell-to Customer Name 2';
            FieldClass = FlowField;
        }
        field(6014422;"Sell-to Address";Text[50])
        {
            CalcFormula = Lookup(Customer.Address WHERE ("No."=FIELD("Sell-to Customer No.")));
            Caption = 'Sell-to Address';
            FieldClass = FlowField;
        }
        field(6014423;"Sell-to Address 2";Text[50])
        {
            CalcFormula = Lookup(Customer."Address 2" WHERE ("No."=FIELD("Sell-to Customer No.")));
            Caption = 'Sell-to Address 2';
            FieldClass = FlowField;
        }
        field(6014424;"Sell-to City";Text[30])
        {
            CalcFormula = Lookup(Customer.City WHERE ("No."=FIELD("Sell-to Customer No.")));
            Caption = 'Sell-to City';
            FieldClass = FlowField;
        }
        field(6014425;"Sell-to Post Code";Code[20])
        {
            CalcFormula = Lookup(Customer."Post Code" WHERE ("No."=FIELD("Sell-to Customer No.")));
            Caption = 'Sell-to Post Code';
            FieldClass = FlowField;
        }
        field(6014430;"Sell-to Phone No.";Text[30])
        {
            CalcFormula = Lookup(Customer."Phone No." WHERE ("No."=FIELD("Sell-to Customer No.")));
            Caption = 'Sell-to Phone No.';
            FieldClass = FlowField;
        }
    }
}

