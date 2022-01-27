table 6014451 "NPR Retail Journal Header"
{
    Access = Internal;
    Caption = 'Label Printing Header';
    LookupPageID = "NPR Retail Journal List";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[40])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Date of creation"; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }
        field(4; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson';
            TableRelation = "Salesperson/Purchaser".Code;
            DataClassification = CustomerContent;
        }
        field(6; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(7; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
            DataClassification = CustomerContent;
        }
        field(8; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            DataClassification = CustomerContent;
        }
        field(9; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
            DataClassification = CustomerContent;
        }
        field(20; "Register No."; Code[20])
        {
            Caption = 'POS Unit No.';
            TableRelation = "NPR POS Unit";
            DataClassification = CustomerContent;
        }
        field(30; "Customer Price Group"; Code[10])
        {
            Caption = 'Customer Price Group';
            TableRelation = "Customer Price Group";
            DataClassification = CustomerContent;
        }
        field(40; "Customer Disc. Group"; Code[20])
        {
            Caption = 'Customer Disc. Group';
            TableRelation = "Customer Discount Group";
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        RetailJournalLine.Reset();
        RetailJournalLine.SetRange("No.", "No.");
        RetailJournalLine.DeleteAll(true);
    end;

    trigger OnInsert()
    var
        GuidVar: Code[40];
    begin
        if Rec."No." = '' then begin
            Evaluate(GuidVar, CreateGuid());
            Rec."No." := GuidVar;
        end;
        "Date of creation" := Today();
    end;

    trigger OnModify()
    begin
        UpdateJournalLines();
    end;

    var
        RetailJournalLine: Record "NPR Retail Journal Line";


    procedure SetPrintQuantityByInventory()
    begin
        RetailJournalLine.Reset();
        RetailJournalLine.SetRange("No.", "No.");
        if RetailJournalLine.FindSet() then
            repeat
                RetailJournalLine.SetFilter("Location Filter", "Location Code");
                RetailJournalLine.CalcFields(Inventory);
                if RetailJournalLine.Inventory >= 0 then begin
                    RetailJournalLine."Quantity to Print" := RetailJournalLine.Inventory;
                    RetailJournalLine.Modify();
                end;
            until RetailJournalLine.Next() = 0;
    end;

    local procedure UpdateJournalLines()
    var
        RetailJournalLine1: Record "NPR Retail Journal Line";
    begin
        if ("Shortcut Dimension 1 Code" <> xRec."Shortcut Dimension 1 Code") or
          ("Shortcut Dimension 2 Code" <> xRec."Shortcut Dimension 2 Code") or
          ("Location Code" <> xRec."Location Code") then begin

            RetailJournalLine1.SetRange("No.", "No.");
            if RetailJournalLine1.FindSet() then
                repeat
                    RetailJournalLine1."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
                    RetailJournalLine1."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
                    RetailJournalLine1."Location Code" := "Location Code";
                    RetailJournalLine1.Modify();
                until RetailJournalLine1.Next() = 0;
        end;
    end;
}

