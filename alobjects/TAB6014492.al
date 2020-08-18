table 6014492 "Archive NpRv SL POS Voucher"
{
    // The purpose of this table:
    //   All existing unfinished sale transactions have been moved to archive tables
    //   The table may be deleted later, when it is no longer relevant.
    // 
    // NPR5.54/ALPO/20200203 CASE 364658 Resume POS Sale
    // NPR5.55/ALPO/20200423 CASE 401611 5.54 upgrade performace optimization

    Caption = 'Sale Line POS Retail Voucher';
    DrillDownPageID = "NpRv Sales Lines";
    LookupPageID = "NpRv Sales Lines";

    fields
    {
        field(1;"Register No.";Code[10])
        {
            Caption = 'Cash Register No.';
            NotBlank = true;
            TableRelation = Register;
        }
        field(5;"Sales Ticket No.";Code[20])
        {
            Caption = 'Sales Ticket No.';
            Editable = false;
            NotBlank = true;
        }
        field(10;"Sale Type";Option)
        {
            Caption = 'Sale Type';
            OptionCaption = 'Sale,Payment,Debit Sale,Gift Voucher,Credit Voucher,Deposit,Out payment,Comment,Cancelled,Open/Close';
            OptionMembers = Sale,Payment,"Debit Sale","Gift Voucher","Credit Voucher",Deposit,"Out payment",Comment,Cancelled,"Open/Close";
        }
        field(15;"Sale Date";Date)
        {
            Caption = 'Sale Date';
        }
        field(20;"Sale Line No.";Integer)
        {
            Caption = 'Sale Line No.';
        }
        field(25;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(30;Type;Option)
        {
            Caption = 'Type';
            Description = 'NPR5.50';
            OptionCaption = 'New Voucher,Payment,Top-up,Partner Issue Voucher';
            OptionMembers = "New Voucher",Payment,"Top-up","Partner Issue Voucher";
        }
        field(40;"Applies-to Sale Line No.";Integer)
        {
            Caption = 'Applies-to Sale Line No.';
        }
        field(45;"Applies-to Voucher Line No.";Integer)
        {
            Caption = 'Applies-to Voucher Line No.';
        }
        field(50;"Voucher Type";Code[20])
        {
            Caption = 'Voucher Type';
            TableRelation = "NpRv Voucher Type";
        }
        field(55;"Voucher No.";Code[20])
        {
            Caption = 'Voucher No.';
            TableRelation = "NpRv Voucher";
        }
        field(60;"Reference No.";Text[30])
        {
            Caption = 'Reference No.';
            Description = 'NPR5.49';
        }
        field(65;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(80;"Starting Date";DateTime)
        {
            Caption = 'Starting Date';
        }
        field(103;"Send via Print";Boolean)
        {
            Caption = 'Send via Print';
            Description = 'NPR5.48';
        }
        field(105;"Send via E-mail";Boolean)
        {
            Caption = 'Send via E-mail';
            Description = 'NPR5.48';
        }
        field(107;"Send via SMS";Boolean)
        {
            Caption = 'Send via SMS';
            Description = 'NPR5.48';
        }
        field(200;"Customer No.";Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;

            trigger OnValidate()
            begin
                UpdateContactInfo();
            end;
        }
        field(205;"Contact No.";Code[20])
        {
            Caption = 'Contact No.';
            TableRelation = Contact;

            trigger OnLookup()
            var
                Cont: Record Contact;
                ContBusinessRelation: Record "Contact Business Relation";
            begin
                if "Customer No." <> '' then
                  if Cont.Get("Contact No.") then
                    Cont.SetRange("Company No.",Cont."Company No.")
                  else begin
                    ContBusinessRelation.SetCurrentKey("Link to Table","No.");
                    ContBusinessRelation.SetRange("Link to Table",ContBusinessRelation."Link to Table"::Customer);
                    ContBusinessRelation.SetRange("No.","Customer No.");
                    if ContBusinessRelation.FindFirst then
                      Cont.SetRange("Company No.",ContBusinessRelation."Contact No.")
                    else
                      Cont.SetRange("No.",'');
                  end;

                if "Contact No." <> '' then
                  if Cont.Get("Contact No.") then;
                if PAGE.RunModal(0,Cont) <> ACTION::LookupOK then
                  exit;

                xRec := Rec;
                Validate("Contact No.",Cont."No.");
            end;

            trigger OnValidate()
            var
                Cont: Record Contact;
                ContBusinessRelation: Record "Contact Business Relation";
                Cust: Record Customer;
            begin
                if ("Contact No." <> '') and Cont.Get("Contact No.") and (Cont."Company No." <> '') then begin
                  ContBusinessRelation.SetRange("Contact No.",Cont."Company No.");
                  ContBusinessRelation.SetRange("Link to Table",ContBusinessRelation."Link to Table"::Customer);
                  ContBusinessRelation.SetFilter("No.",'<>%1','');
                  if ContBusinessRelation.FindFirst and Cust.Get(ContBusinessRelation."No.") then
                    "Customer No." := Cust."No.";
                end;

                UpdateContactInfo();
            end;
        }
        field(210;Name;Text[50])
        {
            Caption = 'Name';
            TableRelation = Customer;
            ValidateTableRelation = false;
        }
        field(215;"Name 2";Text[50])
        {
            Caption = 'Name 2';
        }
        field(220;Address;Text[50])
        {
            Caption = 'Address';
        }
        field(225;"Address 2";Text[50])
        {
            Caption = 'Address 2';
        }
        field(230;"Post Code";Code[20])
        {
            Caption = 'Post Code';
            TableRelation = IF ("Country/Region Code"=CONST('')) "Post Code"
                            ELSE IF ("Country/Region Code"=FILTER(<>'')) "Post Code" WHERE ("Country/Region Code"=FIELD("Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                PostCode: Record "Post Code";
            begin
                PostCode.ValidatePostCode(
                  City,"Post Code",County,"Country/Region Code",(CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(235;City;Text[30])
        {
            Caption = 'City';
            TableRelation = IF ("Country/Region Code"=CONST('')) "Post Code".City
                            ELSE IF ("Country/Region Code"=FILTER(<>'')) "Post Code".City WHERE ("Country/Region Code"=FIELD("Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                PostCode: Record "Post Code";
            begin
                PostCode.ValidateCity(
                  City,"Post Code",County,"Country/Region Code",(CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(240;County;Text[30])
        {
            Caption = 'County';
        }
        field(245;"Country/Region Code";Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(255;"E-mail";Text[80])
        {
            Caption = 'E-mail';
        }
        field(260;"Phone No.";Text[30])
        {
            Caption = 'Phone No.';
        }
        field(300;"Voucher Message";Text[250])
        {
            Caption = 'Voucher Message';
        }
        field(310;Posted;Boolean)
        {
            Caption = 'Posted';
        }
    }

    keys
    {
        key(Key1;"Register No.","Sales Ticket No.","Sale Type","Sale Date","Sale Line No.","Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    local procedure UpdateContactInfo()
    var
        ContBusinessRelation: Record "Contact Business Relation";
        Cust: Record Customer;
        Cont: Record Contact;
    begin
        if "Contact No." <> '' then begin
          Cont.Get("Contact No.");
          Name := Cont.Name;
          //-NPR5.53 [384055]
          "Name 2" := Cont."Name 2";
          //+NPR5.53 [384055]
          Address := Cont.Address;
          "Address 2" := Cont."Address 2";
          City := Cont.City;
          "Post Code" := Cont."Post Code";
          County := Cont.County;
          "Country/Region Code" := Cont."Country/Region Code";
          "E-mail" := Cont."E-Mail";
          "Phone No." := Cont."Phone No.";
          exit;
        end;

        if "Customer No." <> '' then begin
          Cust.Get("Customer No.");
          Name := Cust.Name;
          //-NPR5.53 [384055]
          "Name 2" := Cust."Name 2";
          //+NPR5.53 [384055]
          Address := Cust.Address;
          "Address 2" := Cust."Address 2";
          City := Cust.City;
          "Post Code" := Cust."Post Code";
          County := Cust.County;
          "Country/Region Code" := Cust."Country/Region Code";
          "E-mail" := Cust."E-Mail";
          "Phone No." := Cust."Phone No.";
          exit;
        end;
    end;
}

