table 6059774 "Member Card Issued Cards"
{
    // NPR5.22/TJ  /20160412 CASE 238601 Commented out part that uses Sync Cards To Company
    // NPR5.38/MHA /20180104  CASE 301054 Removed Property, Title, from field 10 Name, 11 Address, 13 City
    // NPR5.39/TJ  /20180206  CASE 302634 Changed OptionString property of field 8 Status to english version

    Caption = 'Point Card - Issued Cards';
    LookupPageID = "Member Card Issued Cards";

    fields
    {
        field(1;"No.";Code[20])
        {
            Caption = 'No.';
            NotBlank = false;
        }
        field(2;"Customer No";Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = IF ("Customer Type"=CONST(Customer)) Customer."No."
                            ELSE IF ("Customer Type"=CONST(Contact)) Contact."No.";

            trigger OnValidate()
            var
                Customer: Record Customer;
                Contact: Record Contact;
            begin
                if ("Customer Type" = "Customer Type"::Customer) then begin
                  Customer.Get("Customer No");
                  Validate( Name, Customer.Name );
                  Validate( Address, Customer.Address );
                  Validate( "ZIP Code", Customer."Post Code" );
                  Validate( City, Customer.City );
                end else if ("Customer Type" = "Customer Type"::Contact) then begin
                  Contact.Get("Customer No");
                  Validate(Name,Contact.Name);
                  Validate( Address, Contact.Address );
                  Validate( "ZIP Code", Contact."Post Code" );
                  Validate( City, Contact.City );
                end;
            end;
        }
        field(3;"Customer Type";Option)
        {
            Caption = 'Customer type';
            NotBlank = true;
            OptionCaption = 'Customer,Contact';
            OptionMembers = Customer,Contact;
        }
        field(4;"Issue Date";Date)
        {
            Caption = 'Issue Date';
        }
        field(5;"Card Type";Code[20])
        {
            Caption = 'Point card type';
            NotBlank = true;
            TableRelation = "Member Card Types";
            ValidateTableRelation = true;
        }
        field(6;Salesperson;Code[20])
        {
            Caption = 'Salesperson';
            TableRelation = "Salesperson/Purchaser".Code;
        }
        field(7;"Points (Total)";Decimal)
        {
            CalcFormula = Sum("Member Card Transaction Log"."Remaining Points" WHERE ("Card Code"=FIELD("No."),
                                                                                      "Posting Date"=FIELD("Expiration Date Filter")));
            Caption = 'Points (Total)';
            FieldClass = FlowField;
            MaxValue = 9.999.999;
        }
        field(8;Status;Option)
        {
            Caption = 'Status';
            OptionCaption = 'Open,Cashed,Cancelled';
            OptionMembers = Open,Cashed,Cancelled;

            trigger OnValidate()
            var
                "TestBel�b": Decimal;
            begin
            end;
        }
        field(10;Name;Text[50])
        {
            Caption = 'Name';
            Description = 'NPR5.38';
        }
        field(11;Address;Text[50])
        {
            Caption = 'Address';
            Description = 'NPR5.38';
        }
        field(12;"ZIP Code";Code[20])
        {
            Caption = 'ZIP Code';
            TableRelation = "Post Code";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(13;City;Text[50])
        {
            Caption = 'City';
            Description = 'NPR5.38';
        }
        field(33;"Date Created";DateTime)
        {
            Caption = 'Date Created';
        }
        field(34;"Valid Until";Date)
        {
            Caption = 'Valid Until';
        }
        field(35;Reference;Text[50])
        {
            Caption = 'Reference';
        }
        field(40;"Last Date Modified";Date)
        {
            Caption = 'Last Date Modified';
        }
        field(54;"Canceling Salesperson";Code[20])
        {
            Caption = 'Canceling Salesperson';
        }
        field(55;"Created in Company";Code[30])
        {
            Caption = 'Created in Company';
        }
        field(56;"Offline - No.";Code[20])
        {
            Caption = 'Offline - No.';
        }
        field(57;"Primary Key Length";Integer)
        {
            Caption = 'Primary Key Length';
        }
        field(63;"Secret Code";Code[6])
        {
            Caption = 'Secret Code';
        }
        field(70;"Expiration Date Filter";Date)
        {
            Caption = 'Expiration Date Filter';
            FieldClass = FlowFilter;
        }
        field(6014400;"No. Printed";Integer)
        {
            Caption = 'No. Printed';
        }
        field(6014401;Comment;Boolean)
        {
            CalcFormula = Exist("Retail Comment" WHERE ("Table ID"=CONST(6059974),
                                                        "No."=FIELD("No.")));
            Caption = 'Comment';
            FieldClass = FlowField;
        }
        field(6060000;"Internet Number";Integer)
        {
            Caption = 'Internet Number';
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
        key(Key2;Status,"Issue Date","Primary Key Length")
        {
        }
        key(Key3;"Customer No")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        PointCardIssuedCards: Record "Member Card Issued Cards";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        ErrPointCardLimit: Label 'Error, a customer can only have one Loyaltycard attached. (%1)';
    begin
        PointCardTypes.Get("Card Type");
        PointCardIssuedCards.SetRange("Customer No","Customer No");
        if PointCardIssuedCards.Find('-') then
          exit;
        
        if "No." = '' then begin
          PointCardTypes.TestField("Card No. Series");
        
        //-NPR5.22
        /*
          IF PointCardTypes."Sync Cards To Company" <> '' THEN
            NoSeriesManagement.SetCompany(PointCardTypes."Sync Cards To Company");
        */
        //+NPR5.22
        
          NoSeriesManagement.InitSeries(PointCardTypes."Card No. Series",
                                        PointCardTypes."Card No. Series",
                                        0D,
                                        "No.",
                                        PointCardTypes."Card No. Series");
          if PointCardTypes."EAN Prefix" <> '' then
             "No." := Utility.CreateEAN( "No.", Format( PointCardTypes."EAN Prefix"  ) );
        end;
        
        "Date Created" := CurrentDateTime;
        
        "Primary Key Length" := StrLen("No.");

    end;

    var
        PointCardTypes: Record "Member Card Types";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        Utility: Codeunit Utility;

    procedure GenerateSecretCode()
    begin
        Randomize;
        "Secret Code" := Format(Random(999999));

        while StrLen("Secret Code") < 6 do
          "Secret Code" := '0' + "Secret Code";
    end;
}

