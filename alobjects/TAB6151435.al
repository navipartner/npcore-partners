table 6151435 "Magento Display Config"
{
    // MAG1.05/TR/20150217  CASE 206395 Object created - controls visibility in Magento
    // MAG1.06/MH/20150225  CASE 206395 Added (Hidden) Option to Field 40 Sales Type: Contact
    // MAG1.07/MH/20150309  CASE 206395 Replace "Sales Type"::"Customer Group" with "Sales Type"::Display Group
    // MAG1.08/MH/20150310  CASE 206395 Removed (Hidden) Option from Field 40 Sales Type: Contact
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Object

    Caption = 'Magento Display Config';
    DrillDownPageID = "Magento Display Config";
    LookupPageID = "Magento Display Config";

    fields
    {
        field(10;"No.";Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type=CONST(Item)) Item
                            ELSE IF (Type=CONST("Item Group")) "Magento Item Group"
                            ELSE IF (Type=CONST(Brand)) "Magento Brand";
        }
        field(20;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Item,Item Group,Brand';
            OptionMembers = Item,"Item Group",Brand;
        }
        field(30;"Sales Code";Text[32])
        {
            Caption = 'Sales Code';
            Description = 'MAG1.06,MAG1.07,MAG1.08';
            TableRelation = IF ("Sales Type"=CONST(Customer)) Customer
                            ELSE IF ("Sales Type"=CONST("Display Group")) "Magento Display Group";
        }
        field(40;"Sales Type";Option)
        {
            Caption = 'Sales Type';
            Description = 'MAG1.06,MAG1.07,MAG1.08';
            OptionCaption = 'Customer,Display Group,All Customers';
            OptionMembers = Customer,"Display Group","All Customers";
        }
        field(50;"Is Visible";Boolean)
        {
            Caption = 'Is Visible';
        }
        field(60;"Starting Date";Date)
        {
            Caption = 'Starting Date';
        }
        field(70;"Starting Time";Time)
        {
            Caption = 'Starting Time';
        }
        field(80;"Ending Date";Date)
        {
            Caption = 'Ending Date';
        }
        field(90;"Ending Time";Time)
        {
            Caption = 'Ending Time';
        }
    }

    keys
    {
        key(Key1;"No.",Type,"Sales Code","Sales Type","Starting Date","Starting Time","Ending Date","Ending Time")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if "Sales Type" = "Sales Type"::"All Customers" then
          "Sales Code" := ''
        else
          TestField("Sales Code");

        TestField("No.");
    end;

    trigger OnRename()
    begin
        if "Sales Type" <> "Sales Type"::"All Customers" then
          TestField("Sales Code");

        TestField("No.");
    end;

    var
        CustPriceGr: Record "Customer Price Group";
        Text000: Label '%1 cannot be after %2';
        Cust: Record Customer;
        Text001: Label '%1 must be blank.';
        Campaign: Record Campaign;
        Item: Record Item;
        Text002: Label 'You can only change the %1 and %2 from the Campaign Card when %3 = %4';
}

