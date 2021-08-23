table 6060101 "NPR Data Cleanup GCVI"
{
    Caption = 'Data Cleanup GCVI';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Customer,Vendor,Item,G/L Account';
            OptionMembers = Customer,Vendor,Item,"G/L Account";
        }
        field(2; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST(Customer)) Customer."No."
            ELSE
            IF (Type = CONST(Vendor)) Vendor."No."
            ELSE
            IF (Type = CONST(Item)) Item."No."
            ELSE
            IF (Type = CONST("G/L Account")) "G/L Account"."No.";
        }
        field(3; Status; Text[250])
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(4; IsDeleted; Boolean)
        {
            Caption = 'Is Deleted';
            DataClassification = CustomerContent;
        }
        field(5; IsError; Boolean)
        {
            Caption = 'Is Error';
            DataClassification = CustomerContent;
        }
        field(6; Success; Boolean)
        {
            Caption = 'Success';
            DataClassification = CustomerContent;
        }
        field(7; "Approve Delete"; Boolean)
        {
            Caption = 'Approve Delete';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "User Approve Del" := CopyStr(UserId, 1, 50);
                IsApproved := "Approve Delete";
            end;
        }
        field(8; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            Description = 'NPR4.03';
        }
        field(9; "Cleanup Action"; Option)
        {
            Caption = 'Cleanup Action';
            DataClassification = CustomerContent;
            Description = 'NPR5.23';
            OptionCaption = ' ,None,Delete,Rename';
            OptionMembers = " ","None",Delete,Rename;
        }
        field(10; Retries; Integer)
        {
            Caption = 'Retries';
            DataClassification = CustomerContent;
        }
        field(11; "Date Created"; Date)
        {
            Caption = 'Date Created';
            DataClassification = CustomerContent;
        }
        field(12; "Time Created"; Time)
        {
            Caption = 'Time Created';
            DataClassification = CustomerContent;
        }
        field(13; "Date Modified"; Date)
        {
            Caption = 'Date Modified';
            DataClassification = CustomerContent;
        }
        field(14; "Time Modified"; Time)
        {
            Caption = 'Time Modified';
            DataClassification = CustomerContent;
        }
        field(15; "User Created"; Code[50])
        {
            Caption = 'User Created';
            DataClassification = CustomerContent;
        }
        field(16; "User Modified"; Code[50])
        {
            Caption = 'User Modified';
            DataClassification = CustomerContent;
        }
        field(17; "User Approve Del"; Code[50])
        {
            Caption = 'User Approve Del';
            DataClassification = CustomerContent;
        }
        field(20; "Last Entry Date"; Date)
        {
            Caption = 'Last Entry Date';
            DataClassification = CustomerContent;
        }
        field(21; IsProcessed; Boolean)
        {
            Caption = 'Is Processed';
            DataClassification = CustomerContent;
            Description = 'NPR5.23';
        }
        field(22; IsApproved; Boolean)
        {
            Caption = 'Is Approved';
            DataClassification = CustomerContent;
            Description = 'NPR5.23';
        }
        field(30; IsRenamed; Boolean)
        {
            Caption = 'Is Renamed';
            DataClassification = CustomerContent;
            Description = 'NPR5.23';
        }
        field(31; "NewNo."; Code[20])
        {
            Caption = 'New No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.23';
        }
        field(32; "xNo."; Code[20])
        {
            Caption = 'Previous No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.23';
        }
        field(33; "Approve Rename"; Boolean)
        {
            Caption = 'Approve Rename';
            DataClassification = CustomerContent;
            Description = 'NPR5.23';

            trigger OnValidate()
            begin
                "User Approve Ren" := CopyStr(UserId, 1, 50);
                IsApproved := "Approve Rename";
            end;
        }
        field(34; "User Approve Ren"; Code[50])
        {
            Caption = 'User Approve Rename';
            DataClassification = CustomerContent;
            Description = 'NPR5.23';
        }
    }

    keys
    {
        key(Key1; "Cleanup Action", Type, "No.")
        {
        }
        key(Key2; "Cleanup Action", "Approve Delete", IsError, IsDeleted, Retries)
        {
        }
        key(Key3; "Cleanup Action", "xNo.", IsError, IsRenamed, Retries)
        {
        }
    }

    trigger OnInsert()
    begin
        "Date Created" := Today();
        "Time Created" := Time;
        "User Created" := CopyStr(UserId, 1, 50);

        UpdateDescription();
    end;

    trigger OnModify()
    begin
        "Date Modified" := Today();
        "Time Modified" := Time;
        "User Modified" := CopyStr(UserId, 1, 50);

        UpdateDescription();
    end;

    trigger OnRename()
    begin
        UpdateDescription();
    end;

    var
        Customer: Record Customer;
        GLAccount: Record "G/L Account";
        Item: Record Item;
        Vendor: Record Vendor;

    local procedure UpdateDescription()
    begin
        case Type of
            Type::Customer:
                begin
                    if Customer.Get("No.") then
                        Description := Customer.Name;
                end;

            Type::Vendor:
                begin
                    if Vendor.Get("No.") then
                        Description := Vendor.Name;
                end;

            Type::Item:
                begin
                    if Item.Get("No.") then
                        Description := Item.Description;
                end;
            Type::"G/L Account":
                begin
                    if GLAccount.Get("No.") then
                        Description := GLAccount.Name;
                end;
        end;
    end;
}

